//
//  MBExporter.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 27.09.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import "MBExporter.h"
#import "MBItem.h"
#import "MBItemValue.h"
#import "MBThreadedProgressSheetController.h"
#import "MBImExportPrefsViewController.h"
#import "globals.h"
#import "MBHTMLGenerator.h"
#import "MBElementBaseController.h"
#import "MBTextItemValue.h"
#import "MBURLItemValue.h"
#import "MBExtendedTextItemValue.h"
#import "GlobalWindows.h"
#import "MBRefItem.h"

#define THREADEDEXPORTER_PARAMS_ITEMS_KEY		@"ThreadedExporterItemsKey"
#define THREADEDEXPORTER_PARAMS_PATH_KEY		@"ThreadedExporterPathKey"
#define THREADEDEXPORTER_PARAMS_TYPE_KEY		@"ThreadedExporterTypeKey"

NSString *SingleExportContext =	@"SingleExportContext";
NSString *MultipleExportContext = @"MultipleExportContext";

@interface MBExporter (privateAPI)

- (NSString *)findNextFilenameFor:(NSString *)filename inDict:(NSDictionary *)dict;
- (BOOL)batchExport:(NSDictionary *)params;
- (void)setExportInProgress:(BOOL)flag;
- (void)setExportedFilenames:(NSMutableArray *)filenames;
- (BOOL)recursiveExportItem:(MBItem *)aItem toPath:(NSString *)dirName;

- (void)setExportItemTypeIdentifier:(MBTypeIdentifier)aType;
- (MBTypeIdentifier)exportItemTypeIdentifier;
- (void)setExportFileType:(MBExportFileType)aType;
- (MBExportFileType)exportFileType;
- (void)setExportFileTypeString:(NSString *)typeString;
- (NSString *)exportFileTypeString;

@end

@implementation MBExporter (privateAPI)

- (void)setExportItemTypeIdentifier:(MBTypeIdentifier)aType {
	exportItemTypeIdentifier = aType;
}

- (MBTypeIdentifier)exportItemTypeIdentifier {
	return exportItemTypeIdentifier;
}

- (void)setExportFileType:(MBExportFileType)aType {
	exportFileType = aType;
}

- (MBExportFileType)exportFileType {
	return exportFileType;
}

- (void)setExportFileTypeString:(NSString *)typeString {
	typeString = [typeString copy];
	[exportFileTypeString release];
	exportFileTypeString = typeString;
}

- (NSString *)exportFileTypeString {
	return exportFileTypeString;
}

- (void)setExportedFilenames:(NSMutableArray *)filenames {
	[filenames retain];
	[exportedFilenames release];
	exportedFilenames = filenames;
}

- (void)setExportInProgress:(BOOL)flag {
	exportInProgress = flag;
}

/**
 \brief this method works nearly the same as -findNextFileNameFor: but it does no filesystem action.
 Instead it searches the given dictionary for the filename
*/
- (NSString *)findNextFilenameFor:(NSString *)filename inDict:(NSDictionary *)dict {
	NSString *newFilename = nil;

	if(dict == nil) {
		CocoLog(LEVEL_WARN,@"[MBExporter -findNextFilenameFor:inDict:] dict is nil!");
	} else {
		id object = [dict objectForKey:filename];
		// if we get a object, then filename exists
		if(object != nil) {
			NSMutableArray *pathComps = [NSMutableArray arrayWithArray:[filename pathComponents]];
			NSMutableString *name = [NSMutableString stringWithString:[pathComps objectAtIndex:[pathComps count]-1]];
			NSString *extension = [filename pathExtension];
			[pathComps removeLastObject];
			NSString *dir = [NSString pathWithComponents:pathComps];
			NSString *newPath = nil;
			// remove pathExtension from name
			NSRange extRange = [name rangeOfString:extension options:NSBackwardsSearch];
			extRange.location = extRange.location - 1;	// we want to get rid of the dot as well
			extRange.length = extRange.length + 1;
			// remove range from name
			[name deleteCharactersInRange:extRange];
			// loop until we found a not existing filename
			int i = 1;
			while(object != nil) {
				// change filename as long as we have one that does not exist already
				NSString *newName = [name stringByAppendingFormat:@"_%d",i];
				newName = [newName stringByAppendingFormat:@".%@",extension];
				newPath = [dir stringByAppendingPathComponent:newName];
				// take another look
				object = [dict objectForKey:newPath];
				i++;
			}
			
			// copy new name
			newFilename = [NSString stringWithString:newPath];
		} else {
			newFilename = [NSString stringWithString:filename];
		}		
	}
	
	return newFilename;	
}

/**
 \brief this method exports a Item recursively
 Given is the Item itself and the fullpath to the directory that should be created for this item
*/
- (BOOL)recursiveExportItem:(MBItem *)aItem toPath:(NSString *)dirName {
	BOOL ret = YES;
	
	if(aItem != nil) {
		if(dirName != nil) {
			NSFileManager *fm = [NSFileManager defaultManager];
			// create directory if it does not exist
			BOOL isDir = NO;
			if(![fm fileExistsAtPath:dirName isDirectory:&isDir]) {
				// create the dir
				if(![fm createDirectoryAtPath:dirName attributes:nil]) {
					CocoLog(LEVEL_ERR,@"[MBExporter -recursiveExportItem:toPath:] could not create directory at: %@",dirName);
					return NO;
				}
			}
			
			// TODO --- create Comment.txt file in this directory
			
			NSString *exportedFilename = @"";
			// process all subitems
			NSEnumerator *iter = [[aItem children] objectEnumerator];
			MBItem *item = nil;
			while((item = [iter nextObject])) {
				// is a ref?
				if([item identifier] == ItemRefID) {
					item = (MBItem *)[(MBRefItem *)item target];
				}
				
				// target is nil, not allowed
				if(item != nil) {
					// get filename for this item
					NSString *filename = [self guessFilenameFor:item];
					// build complete path
					filename = [NSString pathWithComponents:[NSArray arrayWithObjects:dirName,filename,nil]];
					// call export as native again to go deeper
					[self exportAsNative:item toFile:filename exportedFile:&exportedFilename exportedData:nil];
				} else {
					CocoLog(LEVEL_WARN,@"[MBExporter -recursiveExportItem:toPath:] target of MBRefItem is nil!");					
				}				
			}
			
			// export all values of this item
			iter = [[aItem itemValues] objectEnumerator];
			MBItemValue *itemval = nil;
			while((itemval = [iter nextObject])) {
				// get filename for this item
				NSString *filename = [self guessFilenameFor:itemval];
				// get extension for value
				NSString *ext = [self guessFileExtensionFor:itemval];
				// build filename
				NSString *name = [self generateFilenameWithExtension:ext fromFilename:filename];
				// build complete path
				name = [NSString pathWithComponents:[NSArray arrayWithObjects:dirName,name,nil]];
				// call export as native again to go deeper
				[self exportAsNative:itemval toFile:name exportedFile:&exportedFilename exportedData:nil];
			}
		} else {
			CocoLog(LEVEL_WARN,@"[MBExporter -recursiveExportItem:toPath:] have a nil path!");
		}
	} else {
		CocoLog(LEVEL_WARN,@"[MBExporter -recursiveExportItem:toPath:] have a nil item!");
	}
	
	return ret;
}

/**
 \brief export multiple items or itemvalues
*/
- (BOOL)batchExport:(NSDictionary *)params {
	// if this method runs in a thread, we need a seperate ARP
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	// Cancel indicator
	BOOL isCanceled = NO;

	NSArray *items = [params valueForKey:THREADEDEXPORTER_PARAMS_ITEMS_KEY];
	// contains path for exporting multiple items, absolute filename for one item
	NSString *path = [params valueForKey:THREADEDEXPORTER_PARAMS_PATH_KEY];
	int type = [[params valueForKey:THREADEDEXPORTER_PARAMS_TYPE_KEY] intValue];
	
	// Cancel indicator
	isCanceled = NO;
	if((items == nil) || ([items count] == 0)) {
		CocoLog(LEVEL_WARN,@"[MBExporter -batchExport:] have no input!");
	} else if((path == nil) || ([path length] == 0)) {
		CocoLog(LEVEL_WARN,@"[MBExporter -batchExport:] have no export path!");		
	} else {
		// get progress sheet controller
		MBThreadedProgressSheetController *pSheet = [MBThreadedProgressSheetController standardProgressSheetController];
		
		// prepare max progress items
		int len = [items count];
		if(len > 1) {
			// set to indeterminate
			[pSheet performSelectorOnMainThread:@selector(setIsIndeterminateProgress:) 
									 withObject:[NSNumber numberWithBool:NO]
								  waitUntilDone:YES];		
			
			// set maximum value
			[pSheet performSelectorOnMainThread:@selector(setMaxProgressValue:)
									 withObject:[NSNumber numberWithDouble:len] 
								  waitUntilDone:YES];		
		} else {
			// set to indeterminate
			[pSheet performSelectorOnMainThread:@selector(setIsIndeterminateProgress:) 
									 withObject:[NSNumber numberWithBool:YES]
								  waitUntilDone:YES];		
		}
		// begin sheet
		[pSheet performSelectorOnMainThread:@selector(beginSheet) 
								 withObject:nil 
							  waitUntilDone:YES];	
		// are we indeterminate?
		if([pSheet isIndeterminateProgress] == YES) {
			// start
			[pSheet performSelectorOnMainThread:@selector(startProgressAnimation) 
									 withObject:nil 
								  waitUntilDone:YES];
		}	
		
		// if we export as HTML, do this here
		if(type == Export_HTML) {
			// export as HTML
			[self exportAsHTML:items toFile:path exportedFile:nil];
			// add this to array of exported filenames
			//[exportedFilenames addObject:exportedFilename];
		} else {
			// here we process all items
			if(len == 1) {
				MBCommonItem *item = [items objectAtIndex:0];
				
				// lets get some progress messages to the progress sheet
				[pSheet performSelectorOnMainThread:@selector(setCurrentStepMessage:)
										 withObject:[(MBItem *)item name]
									  waitUntilDone:YES];
				
				if(type == Export_IKAM) {
					// export as ikam
					NSString *exportedFilename = [NSString string];
					[self exportAsIkam:item toFile:path exportedFile:&exportedFilename exportedData:nil];
					// add this to array of exported filenames
					[exportedFilenames addObject:exportedFilename];
				} else if(type == Export_Native) {
					// export as native
					NSString *exportedFilename = [NSString string];
					[self exportAsNative:item toFile:path exportedFile:&exportedFilename exportedData:nil];
					// add this to array of exported filenames
					[exportedFilenames addObject:exportedFilename];
				}
			} else {
				NSEnumerator *iter = [items objectEnumerator];
				MBCommonItem *item = nil;
				while((item = [iter nextObject]) && (isCanceled == NO)) {
					// lets get some progress messages to the progress sheet
					[pSheet performSelectorOnMainThread:@selector(setCurrentStepMessage:)
											 withObject:[(MBItem *)item name]
										  waitUntilDone:YES];
					
					// export here
					if(type == Export_IKAM) {
						// export as ikam
						NSString *name = [self guessFilenameFor:item];
						
						NSString *absolutePath = [NSString pathWithComponents:[NSArray arrayWithObjects:path,name,nil]];
						
						NSString *exportedFilename = [NSString string];
						[self exportAsIkam:item toFile:absolutePath exportedFile:&exportedFilename exportedData:nil];
						// add this to array of exported filenames
						[exportedFilenames addObject:exportedFilename];
					} else {
						// export native where posible
						NSString *filename = nil;
						NSString *name = [self guessFilenameFor:item];
						if(NSLocationInRange([item identifier],ITEM_ID_RANGE)) {
							filename = name;
						} else {
							NSString *extension = [self guessFileExtensionFor:item];
							filename = [self generateFilenameWithExtension:extension 
																		fromFilename:name];
						}
						
						NSString *absolutePath = [NSString pathWithComponents:[NSArray arrayWithObjects:path,filename,nil]];
						
						NSString *exportedFilename = [NSString string];
						[self exportAsNative:item toFile:absolutePath exportedFile:&exportedFilename exportedData:nil];
						// add this to array of exported filenames
						[exportedFilenames addObject:exportedFilename];
					}
					
					// increment progress
					if([pSheet isIndeterminateProgress] == NO) {
						[pSheet performSelectorOnMainThread:@selector(incrementProgressBy:)
												 withObject:[NSNumber numberWithDouble:1.0]
											  waitUntilDone:YES];		
					}
					// check returnvalue of sheet, has cancel been pressed?
					if([pSheet sheetReturnCode] != 0) {
						// cancel has been pressed, break import process
						isCanceled = YES;
					}
				}
			}
		}
		
		// do commit only if cancel has not been pressed
		if(isCanceled == NO) {
			// are we indeterminate?
			if([pSheet isIndeterminateProgress] == YES) {
				// start
				[pSheet performSelectorOnMainThread:@selector(stopProgressAnimation) 
										 withObject:nil 
									  waitUntilDone:YES];
			} else {
				// set progress to max value
				[pSheet performSelectorOnMainThread:@selector(setProgressValue:)
										 withObject:[NSNumber numberWithDouble:len] 
									  waitUntilDone:YES];
			}
		}
		
		// end sheet
		[pSheet performSelectorOnMainThread:@selector(endSheet) 
								 withObject:nil 
							  waitUntilDone:YES];
		
		// set end itemValues to sheet
		[pSheet setShouldKeepTrackOfProgress:[NSNumber numberWithBool:NO]];
		[pSheet setProgressAction:[NSNumber numberWithInt:NONE_PROGRESS_ACTION]];
		[pSheet resetProgressValue];
	}
			
	// we are ready
	exportInProgress = NO;

	// release pool
	[pool release];

	return isCanceled;
}

@end

@implementation MBExporter

+ (MBExporter *)defaultExporter {
	static MBExporter *singleton;
	
	if(singleton == nil) {
		singleton = [[MBExporter alloc] init];
	}
	
	return singleton;
}

- (id)init {
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"cannot alloc MBExporter!");		
	} else {
		BOOL success = [NSBundle loadNibNamed:EXPORTACCESSORY_CONTROLLER_NIB_NAME owner:self];
		if(success == YES) {
			// nil exportitems
			[self setExportedFilenames:nil];
			[self setExportItems:nil];
			[self setExportInProgress:NO];
			
			// init lock
			exporterLock = [[NSLock alloc] init];
			
			// get UserDefaults and set export flags
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			exportLinksAsLink = (BOOL)[defaults integerForKey:MBDefaultsExportLinksAsLinkKey];
			
			// register notification for threads that are exited
			/*
			[[NSNotificationCenter defaultCenter] addObserver:self 
													 selector:@selector(threadWillExit:)
														 name:NSThreadWillExitNotification object:nil];			
			 */
		} else {
			CocoLog(LEVEL_ERR,@"[MBExporter]: cannot load ExportAccessoryNib!");
		}		
	}
	
	return self;
}

- (void)awakeFromNib {
	CocoLog(LEVEL_DEBUG,@"[MBExporter -awakeFromNib]");
	
	// set values to html export options
	NSDictionary *dict = [userDefaults valueForKey:MBDefaultsHTMLExportDefaultsOptionsKey];
	[htmlOptionCopyLocalExternalsButton setState:[[dict valueForKey:MBHTMLGenCopyLocalExternals] intValue]];
	[htmlOptionCopyRemoteExternalsButton setState:[[dict valueForKey:MBHTMLGenCopyRemoteExternals] intValue]];
	
	// set initial accessories options view
	[accessoryOptionsBox setContentView:ikamExportOptionsView];
}

/**
\brief dealloc of this class is called on closing this document
 */
- (void)dealloc {
	// release lock
	[exporterLock release];
	
	// nil typeString
	[self setExportFileTypeString:nil];
	// nil exportitems
	[self setExportItems:nil];
	[self setExportedFilenames:nil];
	// dealloc object
	[super dealloc];
}

- (void)setExportItems:(NSArray *)items {
	[items retain];
	[exportItems release];
	exportItems = items;
}

- (NSArray *)exportItems {
	return exportItems;
}

- (NSArray *)exportedFilenames {
	return exportedFilenames;
}

- (BOOL)exportInProgress {
	return exportInProgress;
}

- (void)setExportLinksAsLink:(BOOL)flag {
	exportLinksAsLink = flag;
}

- (BOOL)exportLinksAsLink {
	return exportLinksAsLink;
}

/**
 \brief export aItem as ikam archiv.
 Exported IKAM Archiv is a Bundle.
 The file "ItemInfo" is the Object structure archived with NSKeyedArchiver.
 Bevor archiving with archiver a exportPath should be set to ElementBaseController so that MBElementValues are able to
 write oversize data to the filesystem ("<elementvalueid>.ikamex").
*/
- (BOOL)exportAsIkam:(MBCommonItem *)aItem toFile:(NSString *)filename exportedFile:(NSString **)exportedFilename exportedData:(NSData **)exportData {
	BOOL ret = YES;
	NSMutableData *data = nil;
	
	// save data to filename
	if(filename != nil) {
		NSString *newFilename = [self generateFilenameWithExtension:EXPORT_IKAMARCHIVE_TYPESTRING
													   fromFilename:filename];
		
		// check for file existance and if it exist create a new filename
		NSString *exportFilename = [self findNextFilenameFor:newFilename];
		
		if(*exportedFilename != nil) {
			*exportedFilename = [NSString stringWithString:exportFilename];
		}
		
		// create dir
		NSFileManager *fm = [NSFileManager defaultManager];
		// create export dir
		BOOL success = [fm createDirectoryAtPath:exportFilename attributes:nil];
		if(success) {
			// set export path
			[elementController setOversizeDataExportPath:exportFilename];

			// create archiv
			data = [NSMutableData data];
			NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
			[archiver setOutputFormat:NSPropertyListBinaryFormat_v1_0];
			[archiver encodeInt:[aItem identifier] forKey:@"ExportTypeIdentifier"];
			[archiver encodeObject:aItem forKey:@"ExportData"];
			[archiver finishEncoding];
			[archiver release];			
			
			if(data != nil) {
				// create filename for iteminfo
				NSString *itemInfoFilename = [NSString pathWithComponents:[NSArray arrayWithObjects:exportFilename,@"ItemInfo",nil]];
				[data writeToFile:itemInfoFilename atomically:YES];			
			} else {
				ret = NO;
				CocoLog(LEVEL_ERR,@"[MBExported -exportAsIkam:toFile:exportedFile:exportedData:] could not create archiv!");
			}			
		}
	}
	
	// set for export data
	if(exportData != nil) {
		*exportData = data;
	}
	
	return ret;
}

/**
 \brief expport aItem as native value.
 exportedData argument has no effect here
*/
- (BOOL)exportAsNative:(MBCommonItem *)aItem toFile:(NSString *)filename exportedFile:(NSString **)exportedFilename exportedData:(NSData **)exportedData {
	BOOL ret = YES;
	
	// check,if filename exists, if yes, create a new
	NSString *exportFilename = [self findNextFilenameFor:filename];
	if(*exportedFilename != nil) {
		// check for file existance and if it exist create a new filename
		*exportedFilename = [NSString stringWithString:exportFilename];
	}
	
	// transform path into URL
	NSURL *url = [NSURL fileURLWithPath:exportFilename];
	if(url == nil) {
		CocoLog(LEVEL_ERR,@"[MBExporter -exportAsNative:toFile:] could not convert path to url!");
		ret = NO;
	} else {
		// export with separate ARP
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];		
		
		// determine itemtype
		if(NSLocationInRange([aItem identifier],ITEMVALUE_ID_RANGE)) {
			MBItemValue *itemval = (MBItemValue *)aItem;

			// is a ref?
			if([itemval identifier] == ItemValueRefID) {
				itemval = (MBItemValue *)[(MBRefItem *)itemval target];
			}
			
			// target is nil, not allowed
			if(itemval != nil) {
				// first determine the itemvalue type
				switch([itemval valuetype])
				{
					case NumberItemValueType:
					case CurrencyItemValueType:
					case BoolItemValueType:
					case DateItemValueType:
					case ItemValueRefType:
					{
						// these types cannot be exported natively, export them as ikam
						// use aItem here, the original
						ret = [self exportAsIkam:aItem toFile:filename exportedFile:exportedFilename exportedData:nil];
						break;
					}
					// for all others use itemval, because of Alias
					case SimpleTextItemValueType:
					{
						// write simple text
						MBTextItemValue *val = (MBTextItemValue *)itemval;
                        id value = [val valueData];
                        if([val isKindOfClass:[NSString class]]) {
                            ret = [(NSString *)value writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:NULL];                        
                        } else {
                            ret = [(NSData *)value writeToURL:url atomically:YES];
                        }
						break;
					}
					case URLItemValueType:
					{
						// write url as webloc plist
						MBURLItemValue *val = (MBURLItemValue *)itemval;
						NSDictionary *weblocDict = [val exportAsWebloc];
						ret = [weblocDict writeToURL:url atomically:YES];
						break;
					}
					case ExtendedTextItemValueType:
					{
						MBExtendedTextItemValue *val = (MBExtendedTextItemValue *)itemval;
						// write text data to file
						NSData *valueData = [val valueDataByLoadingFromTarget];
						// check text type
						if([val textType] == TextTypeRTFD)
						{
							NSAttributedString *attrString = [[[NSAttributedString alloc] initWithRTFD:valueData documentAttributes:nil] autorelease];
							NSFileWrapper *wrapper = [attrString RTFDFileWrapperFromRange:NSMakeRange(0, [attrString length]) documentAttributes:nil];
							NSString *filename = [url path];
							if([[filename pathExtension] isEqualToString:@""])
							{
								filename = [filename stringByAppendingString:@".rtfd"];
							}
							[wrapper writeToFile:filename atomically:YES updateFilenames:YES];
						}
						else
						{
							ret = [valueData writeToURL:url atomically:YES];
						}
						break;
					}
					case FileItemValueType:
					case ImageItemValueType:
                    case PDFItemValueType:
					{
						MBFileItemValue *val = (MBFileItemValue *)itemval;
						// write image data to file
						NSData *valueData = [val valueDataByLoadingFromTarget];
						ret = [valueData writeToURL:url atomically:YES];
						break;
					}
				}
			} else {
				CocoLog(LEVEL_WARN,@"[MBExporter -exportAsNative:toFile:exportedData:] target of MBRefItemValue is nil!");
			}
		} else if(NSLocationInRange([aItem identifier],ITEM_ID_RANGE)) {
			// these types cannot be exported natively, export them as ikam
			//ret = [self exportAsIkam:aItem toFile:filename exportedFile:exportedFilename exportedData:nil];
			ret = [self recursiveExportItem:(MBItem *)aItem toPath:filename];
		}
		
		// release ARP
		[pool release];
	}
	
	return ret;
}

/**
 \brief this method exports the aItem to a HTML file hierarchy to filename
 the actual exported filename is exportFilename
 The HTML export options are taken from NSUserDefaults
 It uses the MBHTMLGenerator to export
*/
- (BOOL)exportAsHTML:(NSArray *)array toFile:(NSString *)filename exportedFile:(NSString **)exportFilename {
	BOOL ret = YES;
	
	// we need a directory for exporting html
	// so check, if the given filename is a directory
	NSFileManager *fm = [NSFileManager defaultManager];
	BOOL isDir;
	if([fm fileExistsAtPath:filename isDirectory:&isDir]) {
		// check, which type of data we have in the array
		if([array count] > 0) {
			// get HTMLGenerator end export
			MBHTMLGenerator *htmlGen = [MBHTMLGenerator defaultGenerator];

			MBCommonItem *item = [array objectAtIndex:0];
			if(NSLocationInRange([item identifier],ITEM_ID_RANGE)) {
				[htmlGen generateHTMLForItemList:array 
									 toOutputDir:filename 
										 options:[userDefaults valueForKey:MBDefaultsHTMLExportDefaultsOptionsKey]];
			} else {
				[htmlGen generateHTMLForItemValueList:array 
										  toOutputDir:filename 
											  options:[userDefaults valueForKey:MBDefaultsHTMLExportDefaultsOptionsKey]];
			}
		}
	} else {
		// export directory does not exist
		CocoLog(LEVEL_ERR,@"[MBExporter -exportAsHTML:toFile:exportedFilename:] export directory does not exist!");
		ret = NO;
	}
	
	return ret;
}


/**
\brief takes a filename, extracts the relative filename, adds or replaces the extension snd returns a new filename
 */ 
- (NSString *)generateFilenameWithExtension:(NSString *)extension fromFilename:(NSString *)aFilename {
	NSString *ret = nil;
	
	if(aFilename != nil) {
		// export stuff
		// get relative filename
		NSMutableArray *pathComps = [NSMutableArray arrayWithArray:[aFilename pathComponents]];
		NSMutableString *relname = nil;
		NSString *dir = nil;
		if([pathComps count] > 0) {
			relname = [NSMutableString stringWithString:[pathComps objectAtIndex:([pathComps count]-1)]];
		}
		if([pathComps count] > 1) {
			// remove last entry
			[pathComps removeLastObject];
			// build dir
			dir = [NSString pathWithComponents:pathComps];
		}

		// check current fileextension
		NSString *ext = [relname pathExtension];
		
		BOOL addExtension = YES;
		// do not remove old extension
		if([ext length] > 0) {
			// if the same extension is already there, do not add it
			if([extension isEqualToString:ext]) {
				addExtension = NO;
			}
//			else
//			{
//				// remove existing extension
//				NSRange extRange = [relname rangeOfString:ext options:NSBackwardsSearch];
//				extRange.location = extRange.location - 1;	// we want to get rid of the dot as well
//				extRange.length = extRange.length + 1;
//				// remove range from name
//				[relname deleteCharactersInRange:extRange];
//			}
		}

		// set extension
		if((extension != nil) && addExtension) {
			[relname appendFormat:@".%@",extension];
		}
		
		if(dir != nil) {
			// build absolute path
			ret = [dir stringByAppendingPathComponent:relname];
		} else {
			ret = [NSString stringWithString:relname];
		}
	} else {
		CocoLog(LEVEL_WARN,@"[MBExporter -generateFilenameWithExtension:] input filename is nil!");
	}
	
	return ret;
}

/**
\brief returns the next filename, if this file exists, by adding _1, _2, ... to the filename itself
 with preserving the filename extension
 */
- (NSString *)findNextFilenameFor:(NSString *)path {
	NSString *newFilename = nil;
	
	NSFileManager *fm = [NSFileManager defaultManager];
	
	BOOL exists = [fm fileExistsAtPath:path];
	if(exists == YES) {
		NSMutableArray *pathComps = [NSMutableArray arrayWithArray:[path pathComponents]];
		NSMutableString *name = [NSMutableString stringWithString:[pathComps objectAtIndex:[pathComps count]-1]];
		NSString *extension = [path pathExtension];
		[pathComps removeLastObject];
		NSString *dir = [NSString pathWithComponents:pathComps];
		NSString *newPath = nil;
		// remove pathExtension from name
		if([extension length] > 0) {
			NSRange extRange = [name rangeOfString:extension options:NSBackwardsSearch];
			extRange.location = extRange.location - 1;	// we want to get rid of the dot as well
			extRange.length = extRange.length + 1;
			// remove range from name
			[name deleteCharactersInRange:extRange];
		}
		// loop until we found a not existing filename
		int i = 1;
		while(exists == YES) {
			// change filename as long as we have one that does not exist already
			NSString *newName = [name stringByAppendingFormat:@"_%d",i];
			if([extension length] > 0) {
				newName = [newName stringByAppendingFormat:@".%@",extension];
			}
			newPath = [dir stringByAppendingPathComponent:newName];
			exists = [fm fileExistsAtPath:newPath];
			i++;
		}
		
		// copy new name
		newFilename = [NSString stringWithString:newPath];
	} else {
		newFilename = [NSString stringWithString:path];
	}
	
	return newFilename;
}

/**
\brief guess filename (relative) for this commonItem
 */
- (NSString *)guessFilenameFor:(MBCommonItem *)commonItem {
	NSMutableString *filename = nil;
	
	// check for reference
	if((([commonItem identifier] == ItemRefID) ||
		([commonItem identifier] == ItemValueRefID)) &&
	   ([(MBRefItem *)commonItem target] != nil)) {
		commonItem = [(MBRefItem *)commonItem target];
	}

	// export the current selected item or itemvalue
	if(NSLocationInRange([commonItem identifier],ITEMVALUE_ID_RANGE)) {
		MBItemValue *itemval = (MBItemValue *)commonItem;
		// first determine the itemvalue type
		switch([itemval valuetype])
		{
			case NumberItemValueType:
			case CurrencyItemValueType:
			case BoolItemValueType:
			case DateItemValueType:
			case SimpleTextItemValueType:
			case ItemValueRefType:
			case URLItemValueType:
			{
				//MBURLItemValue *urlval = (MBURLItemValue *)itemval;
				
				filename = [NSMutableString stringWithString:[itemval name]];
				
				// if itemval name has a resource specifier, we have to remove it
				NSURL *url = [NSURL URLWithString:filename];
				NSString *scheme = [url scheme];
				if(scheme != nil)
				{
					// remove it
					filename = [NSMutableString stringWithString:scheme];
				}
				
				/*
				// lets see if there is a linkvalue
				NSURL *url = [urlval valueData];
				if(url != nil)
				{
					// try get host
					filename = [url host];
					if(filename != nil)
					{
						break;
					}
					
					// try
					// get filename
					NSString *path = [MBURLItemValue pathComponentOfURL:url];
					if(path != nil)
					{
						NSArray *pathComponents = [path pathComponents];
						if([pathComponents count] > 0)
						{
							filename = [NSString stringWithString:[pathComponents objectAtIndex:([pathComponents count]-1)]];
						}
					}
				}
				 */
				break;
			}
			case ExtendedTextItemValueType:
			{
				MBExtendedTextItemValue *val = (MBExtendedTextItemValue *)itemval;
				// is this a link?
				if([val isLink] == NO) {
					filename = [NSMutableString stringWithString:[val name]];
                    break;
                }
			}
			case FileItemValueType:
			case ImageItemValueType:
            case PDFItemValueType:
			{
				MBFileItemValue *val = (MBFileItemValue *)itemval;
				// lets see if there is a linkvalue
				NSURL *url = [val linkValueAsURL];
				if(url != nil) {
					// get filename
					NSString *path = [MBURLItemValue pathComponentOfURL:url];
					if(path != nil) {
						NSArray *pathComponents = [path pathComponents];
						if([pathComponents count] > 0) {
							filename = [NSMutableString stringWithString:[pathComponents objectAtIndex:([pathComponents count]-1)]];
						}
					}
				}
				break;
			}
		}
	} else if(NSLocationInRange([commonItem identifier],ITEM_ID_RANGE)) {
		MBItem *item = (MBItem *)commonItem;
		
		// for items set filename to itemname and extension to ikam
		filename = [NSMutableString stringWithString:[item name]];
	}	

	// encode any strange characters
//	NSString *escape = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
//																		   (CFStringRef)filename,
//																		   NULL,
//																		   CFSTR("/"),
//																		   kCFStringEncodingUTF8);
	// replace any occurences of "/"
	[filename replaceOccurrencesOfString:@"/" withString:@"_" options:0 range:NSMakeRange(0,[filename length])];
	//CocoLog(LEVEL_DEBUG,@"filename = %@",filename);
	
	return filename;
}

/**
 \brief guess file extionsion for this commonItem
*/
- (NSString *)guessFileExtensionFor:(MBCommonItem *)commonItem {
	NSString *extension = nil;
	
	// check for reference
	if((([commonItem identifier] == ItemRefID) ||
		([commonItem identifier] == ItemValueRefID)) &&
	   ([(MBRefItem *)commonItem target] != nil)) {
		commonItem = [(MBRefItem *)commonItem target];
	}

	// export the current selected item or itemvalue
	if(NSLocationInRange([commonItem identifier],ITEMVALUE_ID_RANGE)) {
		MBItemValue *itemval = (MBItemValue *)commonItem;
		// first determine the itemvalue type
		switch([itemval valuetype])
		{
			case NumberItemValueType:
			case CurrencyItemValueType:
			case BoolItemValueType:
			case DateItemValueType:
			case ItemValueRefType:
				extension = EXPORT_IKAMARCHIVE_TYPESTRING;
				break;
			case SimpleTextItemValueType:
				extension = @"txt";
				break;
			case URLItemValueType:
			{
				MBURLItemValue *val = (MBURLItemValue *)itemval;
				if([[val valueData] isFileURL]) {
					extension = @"fileloc";
				} else {
					extension = @"webloc";
				}
				break;
			}
			case ExtendedTextItemValueType:
			{
				MBExtendedTextItemValue *val = (MBExtendedTextItemValue *)itemval;
				
				// lets see if there is a linkvalue
				NSURL *url = [val linkValueAsURL];
				if((url != nil) && ([[url absoluteString] length] > 0)) {
					// get filename
					NSString *path = [MBURLItemValue pathComponentOfURL:url];
					if(path != nil) {
						NSArray *pathComponents = [path pathComponents];
						if([pathComponents count] > 0) {
							NSString *filename = [pathComponents objectAtIndex:([pathComponents count]-1)];
							extension = [filename pathExtension];
						}
					} else {
						CocoLog(LEVEL_WARN,@"[MBExporter -guessFileExtensionFor:] have URL but no path!");
					}
				} else {
					switch([val textType]) {
						case TextTypeTXT:
							extension = @"txt";
							break;
						case TextTypeRTF:
							extension = @"rtf";
							break;
						case TextTypeRTFD:
							extension = @"rtfd";
							break;
					}
				}
				break;
			}
			case FileItemValueType:
			case ImageItemValueType:
            case PDFItemValueType:
			{
				MBFileItemValue *val = (MBFileItemValue *)itemval;
				// lets see if there is a linkvalue
				NSURL *url = [val linkValueAsURL];
				if((url != nil) && ([[url absoluteString] length] > 0)) {
					// get filename
					NSString *path = [MBURLItemValue pathComponentOfURL:url];
					if(path != nil)
					{
						NSArray *pathComponents = [path pathComponents];
						if([pathComponents count] > 0)
						{
							NSString *filename = [pathComponents objectAtIndex:([pathComponents count]-1)];
							extension = [filename pathExtension];
						}
					}
				}
				break;
			}
		}
	}
	else if(NSLocationInRange([commonItem identifier],ITEM_ID_RANGE))
	{
		// set native export filetype String
		//extension = EXPORT_IKAMARCHIVE_TYPESTRING;		
		extension = @"";
	}	
	
	return extension;
}

/**
 \brief this method for simulating an export process.
 For exporting item or itemvalues per drag and drop from tableview or outlineview the DataSource delegate method
 wants us to return filenames where we save the promised files to
 The export method itself is using a thread to export the files and waiting for this thread to be ended ends up in blocking the
 EventLoop.
*/
- (void)simulateExport:(NSArray *)items exportFolder:(NSString *)folderPath exportType:(int)exportType exportedFilenames:(NSArray **)filenames {
	// go through the list of items and find out the correct filenames
	
	NSString *guessedFilename = nil;
	NSString *guessedExtension = nil;
	NSString *filename = nil;
	NSString *actualFilename = nil;
	
	NSMutableDictionary *filenameDict = [NSMutableDictionary dictionaryWithCapacity:[items count]];
	NSEnumerator *iter = [items objectEnumerator];
	MBCommonItem *item = nil;
	while((item = [iter nextObject])) {
		// guess filename and file extension
		guessedFilename = [self guessFilenameFor:item];
		guessedExtension = [self guessFileExtensionFor:item];
		if(exportType == Export_IKAM) {
			filename = [self generateFilenameWithExtension:EXPORT_IKAMARCHIVE_TYPESTRING fromFilename:guessedFilename];
		} else {
			filename = [self generateFilenameWithExtension:guessedExtension fromFilename:guessedFilename];		
		}

		// add the filename for this item to the dict
		actualFilename = [self findNextFilenameFor:filename inDict:filenameDict];
		if(actualFilename != nil) {
			// add as key
			[filenameDict setObject:@"" forKey:actualFilename];
		} else {
			CocoLog(LEVEL_WARN,@"[MBExporter -simulateExport:exportFolder:exportType:exportedFilenames:] actualFilename is nil!");
		}
	}
	
	// create array out of keys and return them
	*filenames = [NSArray arrayWithArray:[filenameDict allKeys]];
}

/**
 \brief export this item value
 Bring up a save panel and for itemvalues types where the user can choose the export type, add chooseview to savepanel
 If given exportType = -1, asl for type
*/
- (void)export:(NSArray *)items exportFolder:(NSString *)folderPath exportType:(int)exportType {	
	NSString *context = nil;
	NSString *guessedFilename = nil;
	NSString *guessedExtension = nil;
	
	NSSavePanel *sPanel = nil;
	NSOpenPanel *oPanel = nil;
	
	id panel = nil;
	int count = [items count];
	if(count > 0) {
		if(count == 1) {
			// take filename
			context = SingleExportContext;
			// guess filename
			guessedFilename = [self guessFilenameFor:[items objectAtIndex:0]];
			guessedExtension = [self guessFileExtensionFor:[items objectAtIndex:0]];
		} else {
			// take directory
			context = MultipleExportContext;
		}
		
		if(exportType == -1) {
			// set export items
			[self setExportItems:items];
			// set export type
			//[self setExportFileType:Export_IKAM];
			// export as ikam
			[self setExportFileTypeString:guessedExtension];			

			// set initial value to ikam archive
			if(count == 1) {
				// create save panel
				sPanel = [NSSavePanel savePanel];
				panel = sPanel;
				// set required extension
				//[sPanel setRequiredFileType:EXPORT_IKAMARCHIVE_TYPESTRING];
				// set accessory panel
				[sPanel setAccessoryView:accessoryView];
				
				// hide extension
				[sPanel setExtensionHidden:NO];
				[sPanel beginSheetForDirectory:nil 
										  file:guessedFilename
								modalForWindow:[GlobalWindows mainAppWindow] 
								 modalDelegate:self
								didEndSelector:@selector(savePanelDidEnd:returnCode:contextInfo:) 
								   contextInfo:(__bridge void *)(context)];
			} else {
				// create open panel for exporting multiple files
				oPanel = [NSOpenPanel openPanel];
				panel = oPanel;
				// setup openpanel to only choose directories
				[oPanel setCanChooseFiles:NO];
				[oPanel setCanChooseDirectories:YES];
				[oPanel setCanCreateDirectories:YES];
				[oPanel setCanSelectHiddenExtension:YES];
				// set accessory panel
				[oPanel setAccessoryView:accessoryView];
				
				// open openpanel
				[oPanel beginSheetForDirectory:nil 
										  file:nil
								modalForWindow:[GlobalWindows mainAppWindow] 
								 modalDelegate:self
								didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:) 
								   contextInfo:(__bridge void *)(context)];
			}
		} else if(exportType == Export_IKAM) {
			// bring up progress sheet
			MBThreadedProgressSheetController *pSheet = [MBThreadedProgressSheetController standardProgressSheetController];
			[pSheet setMinProgressValue:[NSNumber numberWithDouble:0.0]];
			[pSheet setIsThreaded:[NSNumber numberWithBool:YES]];
			[pSheet setIsIndeterminateProgress:[NSNumber numberWithBool:NO]];
			[pSheet setShouldKeepTrackOfProgress:[NSNumber numberWithBool:YES]];
			[pSheet setProgressAction:[NSNumber numberWithInt:EXPORT_PROGRESS_ACTION]];
			[pSheet setActionMessage:MBLocaleStr(@"Exporting...")];
			
			// if more than one item
			NSString *absolutePath = nil;
			if(count == 1) {
				// build another path (path+filename)
				absolutePath = [folderPath stringByAppendingPathComponent:[self generateFilenameWithExtension:EXPORT_IKAMARCHIVE_TYPESTRING 
																								 fromFilename:guessedFilename]];
			} else {
				absolutePath = folderPath;
			}
			
			// generate dict
			NSMutableDictionary *params = [NSMutableDictionary dictionary];
			// add filenames
			[params setObject:items forKey:THREADEDEXPORTER_PARAMS_ITEMS_KEY];
			[params setObject:absolutePath forKey:THREADEDEXPORTER_PARAMS_PATH_KEY];
			[params setObject:[NSNumber numberWithInt:Export_IKAM] forKey:THREADEDEXPORTER_PARAMS_TYPE_KEY];
			
			// set flag that we are exporting
			exportInProgress = YES;
			// start this in an own thread
			//[NSThread detachNewThreadSelector:@selector(batchExport:) toTarget:self withObject:params];
			[self batchExport:params];
		} else if(exportType == Export_Native) {
			// bring up progress sheet
			MBThreadedProgressSheetController *pSheet = [MBThreadedProgressSheetController standardProgressSheetController];
			[pSheet setMinProgressValue:[NSNumber numberWithDouble:0.0]];
			[pSheet setIsThreaded:[NSNumber numberWithBool:YES]];
			[pSheet setIsIndeterminateProgress:[NSNumber numberWithBool:NO]];
			[pSheet setShouldKeepTrackOfProgress:[NSNumber numberWithBool:YES]];
			[pSheet setProgressAction:[NSNumber numberWithInt:EXPORT_PROGRESS_ACTION]];
			[pSheet setActionMessage:MBLocaleStr(@"Exporting...")];
			
			// if more than one item
			NSString *absolutePath = nil;
			if(count == 1) {
				// build another path (path+filename)
				absolutePath = [folderPath stringByAppendingPathComponent:[self generateFilenameWithExtension:guessedExtension 
																								 fromFilename:guessedFilename]];
			} else {
				absolutePath = folderPath;
			}

			// generate dict
			NSMutableDictionary *params = [NSMutableDictionary dictionary];
			// add filenames
			[params setObject:items forKey:THREADEDEXPORTER_PARAMS_ITEMS_KEY];
			[params setObject:absolutePath forKey:THREADEDEXPORTER_PARAMS_PATH_KEY];
			[params setObject:[NSNumber numberWithInt:Export_Native] forKey:THREADEDEXPORTER_PARAMS_TYPE_KEY];
			
			// set flag that we are exporting
			exportInProgress = YES;
			// start this in an own thread
			//[NSThread detachNewThreadSelector:@selector(batchExport:) toTarget:self withObject:params];
			[self batchExport:params];
		} else if(exportType == Export_HTML) {
			// bring up progress sheet
			MBThreadedProgressSheetController *pSheet = [MBThreadedProgressSheetController standardProgressSheetController];
			[pSheet setMinProgressValue:[NSNumber numberWithDouble:0.0]];
			[pSheet setIsThreaded:[NSNumber numberWithBool:YES]];
			[pSheet setIsIndeterminateProgress:[NSNumber numberWithBool:YES]];
			[pSheet setShouldKeepTrackOfProgress:[NSNumber numberWithBool:NO]];
			[pSheet setProgressAction:[NSNumber numberWithInt:EXPORT_PROGRESS_ACTION]];
			[pSheet setActionMessage:MBLocaleStr(@"Exporting...")];
			
			// export html to given export Folder
			if(folderPath == nil) {
				CocoLog(LEVEL_ERR,@"[MBExporter -export:exportFolder:exportType:] have no exportFolder!");
			} else {
				// generate dict
				NSMutableDictionary *params = [NSMutableDictionary dictionary];
				// add filenames
				[params setObject:items forKey:THREADEDEXPORTER_PARAMS_ITEMS_KEY];
				[params setObject:folderPath forKey:THREADEDEXPORTER_PARAMS_PATH_KEY];
				[params setObject:[NSNumber numberWithInt:Export_HTML] forKey:THREADEDEXPORTER_PARAMS_TYPE_KEY];
				
				// set flag that we are exporting
				exportInProgress = YES;
				// start this in an own thread
				//[NSThread detachNewThreadSelector:@selector(batchExport:) toTarget:self withObject:params];
				[self batchExport:params];
			}
		}
	} else {
		CocoLog(LEVEL_WARN,@"[MBExporter -export:toFile:exportType:] have no input!");
	}	
}

//--------------------------------------------------------------------
//----------- SavePanel didEndSelector -------------------------------
//--------------------------------------------------------------------
- (void)savePanelDidEnd:(NSSavePanel *)panel returnCode:(int)returnCode contextInfo:(void *)x {
	// order panel out
	[panel orderOut:nil];
	
	// check panel result
	if(returnCode == NSOKButton)  {
		NSString *filename = [panel filename];
		NSString *dir = [panel directory];
		CocoLog(LEVEL_DEBUG,dir);
		
		// bring up progress sheet
		MBThreadedProgressSheetController *pSheet = [MBThreadedProgressSheetController standardProgressSheetController];
		[pSheet setMinProgressValue:[NSNumber numberWithDouble:0.0]];
		[pSheet setIsThreaded:[NSNumber numberWithBool:YES]];
		[pSheet setIsIndeterminateProgress:[NSNumber numberWithBool:NO]];
		[pSheet setShouldKeepTrackOfProgress:[NSNumber numberWithBool:YES]];
		[pSheet setProgressAction:[NSNumber numberWithInt:EXPORT_PROGRESS_ACTION]];
		[pSheet setActionMessage:MBLocaleStr(@"Exporting...")];

		// exchange file extension for type
		NSString *exportFilename = nil;
		if([self exportFileType] == Export_IKAM) {
			exportFilename = [self generateFilenameWithExtension:EXPORT_IKAMARCHIVE_TYPESTRING fromFilename:filename];		
		} else if([self exportFileType] == Export_Native) {
			//exportFilename = [self generateFilenameWithExtension:[self exportFileTypeString] fromFilename:filename];		
			// we can export items as native now
			exportFilename = filename;
		} else if([self exportFileType] == Export_HTML) {
			exportFilename = dir;
		}
		
		// generate dict
		NSMutableDictionary *params = [NSMutableDictionary dictionary];
		// add filenames
		[params setObject:[self exportItems] forKey:THREADEDEXPORTER_PARAMS_ITEMS_KEY];
		[params setObject:[NSNumber numberWithInt:[self exportFileType]] forKey:THREADEDEXPORTER_PARAMS_TYPE_KEY];

		if(x == (__bridge void *)(SingleExportContext)) {
			[params setObject:exportFilename forKey:THREADEDEXPORTER_PARAMS_PATH_KEY];
			
			// set flag that we are exporting
			exportInProgress = YES;
			// start this in an own thread
			//[NSThread detachNewThreadSelector:@selector(batchExport:) toTarget:self withObject:params];			
			[self batchExport:params];
		}
		/*
		else if(x == MultipleExportContext)
		{
			[params setObject:dir forKey:THREADEDEXPORTER_PARAMS_PATH_KEY];
			
			// start this in an own thread
			[NSThread detachNewThreadSelector:@selector(batchExport:) toTarget:self withObject:params];			
		}		
		 */
	} else {
		// set flag that we are exporting
		exportInProgress = NO;
	}
}

//--------------------------------------------------------------------
//----------- OpenPanel didEndSelector -------------------------------
//--------------------------------------------------------------------
- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode contextInfo:(void *)x {
	// order panel out
	[panel orderOut:nil];
	
	// check panel result
	if(returnCode == NSOKButton)  {
		NSString *filename = [panel filename];
		NSLog(filename);
		NSString *dir = [panel directory];
		NSLog(dir);
		
		// bring up progress sheet
		MBThreadedProgressSheetController *pSheet = [MBThreadedProgressSheetController standardProgressSheetController];
		[pSheet setMinProgressValue:[NSNumber numberWithDouble:0.0]];
		[pSheet setIsThreaded:[NSNumber numberWithBool:YES]];
		[pSheet setIsIndeterminateProgress:[NSNumber numberWithBool:NO]];
		[pSheet setShouldKeepTrackOfProgress:[NSNumber numberWithBool:YES]];
		[pSheet setProgressAction:[NSNumber numberWithInt:EXPORT_PROGRESS_ACTION]];
		[pSheet setActionMessage:MBLocaleStr(@"Exporting...")];
		
		// generate dict
		NSMutableDictionary *params = [NSMutableDictionary dictionary];
		// add filenames
		[params setObject:[self exportItems] forKey:THREADEDEXPORTER_PARAMS_ITEMS_KEY];
		[params setObject:[NSNumber numberWithInt:[self exportFileType]] forKey:THREADEDEXPORTER_PARAMS_TYPE_KEY];
		
		/*
		if(x == SingleExportContext)
		{
			[params setObject:filename forKey:THREADEDEXPORTER_PARAMS_PATH_KEY];
			
			// start this in an own thread
			[NSThread detachNewThreadSelector:@selector(batchExport:) toTarget:self withObject:params];			
		}
		 */
		if(x == (__bridge void *)(MultipleExportContext)) {
			[params setObject:dir forKey:THREADEDEXPORTER_PARAMS_PATH_KEY];
			
			// set flag that we are exporting
			exportInProgress = YES;
			// start this in an own thread
			//[NSThread detachNewThreadSelector:@selector(batchExport:) toTarget:self withObject:params];			
			[self batchExport:params];
		}		
	} else {
		// set flag that we are exporting
		exportInProgress = NO;
	}
}

// ---------------------------------------------------------------------
// Notifications
// ---------------------------------------------------------------------
- (void)threadWillExit:(NSNotification *)notify {
	CocoLog(LEVEL_DEBUG,@"[MBExporter -threadWillExit:]");
	
	exportInProgress = NO;
	
	// reset export flags
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	exportLinksAsLink = (BOOL)[defaults integerForKey:MBDefaultsExportLinksAsLinkKey];
}

//--------------------------------------------------------------------
//----------- Accessory View actions -------------------------------
//--------------------------------------------------------------------
- (IBAction)exportTypeChange:(id)sender {
	CocoLog(LEVEL_DEBUG,@"export type changed to :%d",[sender tag]);
	[self setExportFileType:[sender tag]];
	
	switch([sender tag]) {
		case Export_IKAM:
		case Export_Native:
			// change contentview of nsbox
			// set ikamExportOptionsView
			[accessoryOptionsBox setContentView:ikamExportOptionsView];
			break;
		case Export_HTML:
			// set htmlExportOptionsView
			[accessoryOptionsBox setContentView:htmlExportOptionsView];
			break;			
	}
}

- (IBAction)exportAsLinkButton:(id)sender {
	CocoLog(LEVEL_DEBUG,@"switch to export as link!");

	exportLinksAsLink = YES;
}

- (IBAction)exportWithLoadingDataButton:(id)sender {
	CocoLog(LEVEL_DEBUG,@"switch to export with loading data!");

	exportLinksAsLink = NO;
}

- (IBAction)htmlExportOptionChange:(id)sender {
	// get Options dict
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[userDefaults valueForKey:MBDefaultsHTMLExportDefaultsOptionsKey]];
	
	if([sender tag] == 3) {
		// copy local externals
		[dict setObject:[NSNumber numberWithInt:[(NSButton *)sender state]] forKey:MBHTMLGenCopyLocalExternals];
	} else if([sender tag] == 4) {
		// copy remote externals
		[dict setObject:[NSNumber numberWithInt:[(NSButton *)sender state]] forKey:MBHTMLGenCopyRemoteExternals];
	}
	
	// write backto user defaults
	[userDefaults setObject:(NSDictionary *)dict forKey:MBDefaultsHTMLExportDefaultsOptionsKey];
}

@end
