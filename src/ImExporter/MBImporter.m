//
//  MBImporter.m
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

#import <CocoLogger/CocoLogger.h>
#import "MBImporter.h"
#import "MBItemBaseController.h"
#import "MBItem.h"
#import "globals.h"
#import "MBStdItem.h"
#import "MBRefItem.h"
#import "MBImExportPrefsViewController.h"
#import "MBThreadedProgressSheetController.h"
#import "MBDBAccess.h"
#import "MBExporter.h"
#import "MBURLItemValue.h"
#import "MBPDFItemValue.h"
#import "MBExtendedTextItemValue.h"
#import "MBElementBaseController.h"
#import "MBImageItemValue.h"
#import "GlobalWindows.h"

#define FILEIMPORTER_PARAMS_FILENAMES_KEY			@"FileImporterFilenamesKey"
#define FILEIMPORTER_PARAMS_DESTITEM_KEY			@"FileImporterDestItemKey"
#define FILEIMPORTER_PARAMS_TYPESPEC_KEY			@"FileImporterTypeSpecKey"
#define FILEIMPORTER_PARAMS_IMORTASLINK_KEY			@"FileImporterImportAsLinkKey"
#define FILEIMPORTER_PARAMS_IMORTWITHAUTOLOAD_KEY	@"FileImporterImportWithAutoloadKey"
#define FILEIMPORTER_PARAMS_RECURSIVE_KEY			@"FileImporterRecusriveKey"

@interface MBImporter (privateAPI)

- (void)batchFileImport:(NSDictionary *)params;
- (void)resetSettings;
- (void)importDirectoryAtPath:(NSString *)path toItem:(MBItem *)item;

@end

@implementation MBImporter (privateAPI)

/**
 \brief import this full drirectory
 The given Item must not be a reference item
*/
- (void)importDirectoryAtPath:(NSString *)path toItem:(MBItem *)item {
	// check destination again
	if(item == nil) {
		CocoLog(LEVEL_WARN,@"have no destination item, using imports!");
		item = [itemController importItem];
	}
	// if item is a reference, dereference it
	if([item identifier] == ItemRefID) {
		item = (MBItem *)[(MBRefItem *)item target];
	}
	// adding a item to a item ref with out target is not allowed
	if(item == nil) {
		NSAlert *alert = [NSAlert alertWithMessageText:MBLocaleStr(@"CannotImportToItemRefWithoutTargetTitle") 
										 defaultButton:MBLocaleStr(@"OK") 
									   alternateButton:nil 
										   otherButton:nil 
							 informativeTextWithFormat:MBLocaleStr(@"CannotImportToItemRefWithoutTargetMsg")];
		[alert runModal];
	} else {
		if(path == nil) {
			CocoLog(LEVEL_WARN,@"given path is nil!");
		} else {
			// get filemanager
			NSFileManager *fm = [NSFileManager defaultManager];
			// check, if path exists
			NSArray *dirContent = [fm directoryContentsAtPath:path];
			if(!dirContent) {
				CocoLog(LEVEL_WARN,@"path does not exist!");
			} else {
				// path seems to exist, now create a item for the directoryname
				NSString *dirName = [path lastPathComponent];
				if(!dirName) {
					CocoLog(LEVEL_WARN,@"could not get directory name!");
				} else {
					// create item
					MBStdItem *newItem = [[[MBStdItem alloc] initWithDb] autorelease];
					// set state to init that no notifications are sent
					[newItem setState:InitState];
					
					// give it a name
					[newItem setName:dirName];
					// add it to the given Item
					[item addChildItem:newItem];
					
					// set state back to normal
					[newItem setState:NormalState];
					
					NSEnumerator *iter = [dirContent objectEnumerator];
					NSString *file = nil;
					while((file = [iter nextObject])) {
						// this helper method calls import for regular files again
						CocoLog(LEVEL_DEBUG,@"filename in dir: %@",file);

						NSString *absPath = [path stringByAppendingPathComponent:file];
						// if we do not import recursive, do not process subdirectories
						NSFileWrapper *fileWrapper = [[[NSFileWrapper alloc] initWithPath:absPath] autorelease];
						if([fileWrapper isDirectory] && (importRecursive == NO)) {
							CocoLog(LEVEL_DEBUG,@"no recursive, passing dir!");
						} else {
							// call normal file import for all content
							[self fileImport:absPath toItem:newItem asTransaction:NO];
						}
					}
				}
			}
		}		
	}
}

/**
 \brief reset import settings
*/
- (void)resetSettings {
	// get defaults
	importAsLink = (BOOL)[userDefaults integerForKey:MBDefaultsImportAsLinkKey];
	[importAsLinkButton setState:(int)importAsLink];
	[importWithAutoloadButton setEnabled:importAsLink];

	importWithAutoload = (BOOL)[userDefaults integerForKey:MBDefaultsImportWithAutoloadKey];
	[importWithAutoloadButton setState:(int)importWithAutoload];

	importRecursive = (BOOL)[userDefaults integerForKey:MBDefaultsImportRecursiveKey];
	[importRecursiveButton setState:(int)importRecursive];
	
	importAllAsFileValue = (BOOL)[userDefaults integerForKey:MBDefaultsImportAllAsFilesKey];	
	[importAccordingToFiletypesButtonCell setSelectable:YES];
	[importAllAsFileValueButtonCell setSelectable:YES];
	
	if(importAllAsFileValue == YES) {
		[buttonMatrix selectCellWithTag:0];
	} else {
		[buttonMatrix selectCellWithTag:1];
	}	
}

/**
 \brief import file with seperate thread to show progress in threaded progres indicator
 @param params is a NSDictionbary which contains all nessesary entries for importing files.
 that is: 
	filenames array with absolute filenames
	MBItem to where the files should be imported
	fileextension itemvalue assignment spec. if this is nil all files will be imported as filevalues
 @return YES for import success, NO for import failure
*/
- (void)batchFileImport:(NSDictionary *)params {
	// if this method gets it's own ARP
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// extract dictionary
	NSArray *filenames = [params objectForKey:FILEIMPORTER_PARAMS_FILENAMES_KEY];
	MBItem *item = [params objectForKey:FILEIMPORTER_PARAMS_DESTITEM_KEY];
	//NSMutableDictionary *typeSpec = [NSMutableDictionary dictionaryWithDictionary:[params objectForKey:FILEIMPORTER_PARAMS_TYPESPEC_KEY]];
	//BOOL asLink = (BOOL)[[params objectForKey:FILEIMPORTER_PARAMS_IMORTASLINK_KEY] intValue];
	//BOOL withAutoload = (BOOL)[[params objectForKey:FILEIMPORTER_PARAMS_IMORTWITHAUTOLOAD_KEY] intValue];
	//BOOL recursive = (BOOL)[[params objectForKey:FILEIMPORTER_PARAMS_RECURSIVE_KEY] intValue];

	if((filenames == nil) && (item == nil)) {
		CocoLog(LEVEL_WARN,@"filenames or item is nil!");
	} else {
		// get progress sheet controller
		MBThreadedProgressSheetController *pSheet = [MBThreadedProgressSheetController standardProgressSheetController];

		// Cancel indicator
		BOOL isCanceled = NO;
		
		// prepare max progress items
		int len = [filenames count];
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
		
		// get dbConnection and begin transaction
		MBDBAccess *dbAccess = [MBDBAccess sharedConnection];
		// begin transaction
		[dbAccess sendBeginTransaction];
		
		// get a FileManager
		NSFileManager *fm = [NSFileManager defaultManager];
		// go through filenames and import
		NSEnumerator *iter = [filenames objectEnumerator];
		NSString *file = nil;
		NSAutoreleasePool *fileArp = nil;
		while((file = [iter nextObject]) && (isCanceled == NO)) {
			// use a seperate ARP for every file
			fileArp = [[NSAutoreleasePool alloc] init];

			// check, if file exists and type of file
			BOOL isDir = NO;
			if([fm fileExistsAtPath:file isDirectory:&isDir]) {
				if([[file pathExtension] isEqualToString:EXPORT_IKAMARCHIVE_TYPESTRING]) {
					// this is a IKAM Package, do appropriate import
					CocoLog(LEVEL_DEBUG,@"file to import is IKAM package!");

					// set progress indicator to indeterminate
					[pSheet performSelectorOnMainThread:@selector(setIsIndeterminateProgress:) 
											 withObject:[NSNumber numberWithBool:YES]
										  waitUntilDone:YES];
					// and start
					[pSheet performSelectorOnMainThread:@selector(startProgressAnimation) 
											 withObject:nil 
										  waitUntilDone:YES];
					
					// call ikam import
					[self ikamImport:file toItem:item asTransaction:NO];
				} else {
					// file to import is a normal file
					CocoLog(LEVEL_DEBUG,@"file to import is normal file!");
					
					// lets get some progress messages to the progress sheet
					[pSheet performSelectorOnMainThread:@selector(setCurrentStepMessage:)
											 withObject:file 
										  waitUntilDone:YES];
					
					// get complete number of files in directory if file is dir
					if(isDir) {
						int files = [[fm subpathsAtPath:file] count];
						if(!importRecursive) {
							files -= [[fm directoryContentsAtPath:file] count];
						}
						
						len += files;
						
						// set to indeterminate
						[pSheet performSelectorOnMainThread:@selector(setIsIndeterminateProgress:) 
												 withObject:[NSNumber numberWithBool:NO]
											  waitUntilDone:YES];		
						
						// set maximum value
						[pSheet performSelectorOnMainThread:@selector(setMaxProgressValue:)
												 withObject:[NSNumber numberWithDouble:len] 
											  waitUntilDone:YES];						

						// lets get some progress messages to the progress sheet
						[pSheet performSelectorOnMainThread:@selector(setCurrentStepMessage:)
												 withObject:file 
											  waitUntilDone:YES];
					}
					
					// call general file importer
					[self fileImport:file toItem:item asTransaction:NO];
				}
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
			
			// release fileArp
			[fileArp release];
		}
		
		// do commit only if cancel has not been pressed
		if(isCanceled == NO) {
			// commit transaction
			[dbAccess sendCommitTransaction];
			
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
		
		// send notification to update treeview
		MBSendNotifyItemTreeChanged(nil);
		MBSendNotifyItemValueListChanged(nil);
	}
	
	// release pool
	[pool release];
}

@end

@implementation MBImporter

+ (MBImporter *)defaultImporter {
	static MBImporter *singleton;
	
	if(singleton == nil) {
		singleton = [[MBImporter alloc] init];
	}
	
	return singleton;
}

/**
\brief init is called after alloc:. some initialization work can be done here.
 No GUI elements are available here. It additinally calls the init method of superclass
 @returns initialized not nil object
 */
- (id)init {
	CocoLog(LEVEL_DEBUG,@"init of MBImporter");
	
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"cannot alloc MBImporter!");
	} else {
		BOOL success = [NSBundle loadNibNamed:IMPORTACCESSORY_CONTROLLER_NIB_NAME owner:self];
		if(success == YES) {
            /*
			// register notification for threads that are exited
			[[NSNotificationCenter defaultCenter] addObserver:self 
													 selector:@selector(threadWillExit:)
														 name:NSThreadWillExitNotification object:nil];
			*/
			// init lock
			importerLock = [[NSLock alloc] init];
		} else {
			CocoLog(LEVEL_ERR, @"cannot load ExportAccessoryNib!");
		}		
	}
	
	return self;
}

- (void)awakeFromNib {
	if(self != nil) {
		[self resetSettings];
	}
}

/**
\brief dealloc of this class is called on closing this document
 */
- (void)dealloc {
	CocoLog(LEVEL_DEBUG, @"dealloc of MBImporter");
	
	// release lock
	[importerLock release];
	
	// dealloc object
	[super dealloc];
}

/**
 \brief create a new URLValue and init this with the give url
*/
- (void)urlValueImport:(NSURL *)url toItem:(MBItem *)item asTransaction:(BOOL)transact  {
	// check destination again
	if(item == nil) {
		CocoLog(LEVEL_WARN,@"[MBImporter -URLValueImport:] have no destination item, using imports!");
		item = [itemController importItem];
	}
	// if item is a reference, dereference it
	if([item identifier] == ItemRefID) {
		item = (MBItem *)[(MBRefItem *)item target];
	}
	// adding a item to a item ref with out target is not allowed
	if(item == nil) {
		NSAlert *alert = [NSAlert alertWithMessageText:MBLocaleStr(@"CannotImportToItemRefWithoutTargetTitle") 
										 defaultButton:MBLocaleStr(@"OK") 
									   alternateButton:nil 
										   otherButton:nil 
							 informativeTextWithFormat:MBLocaleStr(@"CannotImportToItemRefWithoutTargetMsg")];
		[alert runModal];
	} else {
		// get dbConnection and begin transaction
		MBDBAccess *dbAccess = [MBDBAccess sharedConnection];
		if(transact) {
			// begin transaction
			[dbAccess sendBeginTransaction];
		}

		// create URLValue to current selected item
		MBURLItemValue *itemval = [[MBURLItemValue alloc] initWithDb];
		// set state to init that no notifications are sent
		[itemval setState:InitState];
		// set value
		[itemval setValueData:url];
		// set name
		[itemval setName:[url relativeString]];
		
		// set state back to normal
		[itemval setState:NormalState];
		
		// add it
		[itemController addItemValue:itemval 
							  toItem:item 
				 withConnectingValue:YES 
						   operation:AddOperation 
				   withDbTransaction:NO];

		// release itemval
		[itemval release];

		if(transact) {
			// commit transaction
			[dbAccess sendCommitTransaction];
		}

		// send notification to reload tableview
		MBSendNotifyItemValueListChanged(item);
	}
}

- (void)pdfValueImport:(NSData *)pdfData toItem:(MBItem *)item asTransaction:(BOOL)transact {
	// check destination again
	if(item == nil) {
		CocoLog(LEVEL_WARN,@"[MBImporter -ETextValueImport:] have no destination item, using import item!");
		item = [itemController importItem];
	}
    
	// if item is a reference, dereference it
	if([item identifier] == ItemRefID) {
		item = (MBItem *)[(MBRefItem *)item target];
	}
	// adding a item to a item ref with out target is not allowed
	if(item == nil) {
		NSAlert *alert = [NSAlert alertWithMessageText:MBLocaleStr(@"CannotImportToItemRefWithoutTargetTitle") 
										 defaultButton:MBLocaleStr(@"OK") 
									   alternateButton:nil 
										   otherButton:nil 
							 informativeTextWithFormat:MBLocaleStr(@"CannotImportToItemRefWithoutTargetMsg")];
		[alert runModal];
	} else {
		// get dbConnection and begin transaction
		MBDBAccess *dbAccess = [MBDBAccess sharedConnection];
		if(transact) {
			// begin transaction
			[dbAccess sendBeginTransaction];
            // create Extended text item value
            MBPDFItemValue *itemval = [[MBPDFItemValue alloc] initWithDb];
            // set state to init that no notifications are sent
            [itemval setState:InitState];
            // set value
            [itemval setValueData:pdfData];
            // set name
            [itemval setName:[NSString stringWithFormat:@"PDF import %@", [[NSDate date] description]]];
            
            // set state back to normal
            [itemval setState:NormalState];
            
            // add it
            [itemController addItemValue:itemval 
                                  toItem:item 
                     withConnectingValue:YES 
                               operation:AddOperation 
                       withDbTransaction:NO];
            
            // release itemval
            [itemval release];
            
            if(transact) {
                // commit transaction
                [dbAccess sendCommitTransaction];
            }
            
            // send notification to reload tableview
            MBSendNotifyItemValueListChanged(item);
		}
    }        
}

- (void)eTextValueImport:(NSData *)textData toItem:(MBItem *)item forType:(MBTextType)type asTransaction:(BOOL)transact  {
	// check destination again
	if(item == nil) {
		CocoLog(LEVEL_WARN,@"[MBImporter -ETextValueImport:] have no destination item, using import item!");
		item = [itemController importItem];
	}

	// if item is a reference, dereference it
	if([item identifier] == ItemRefID) {
		item = (MBItem *)[(MBRefItem *)item target];
	}
	// adding a item to a item ref with out target is not allowed
	if(item == nil) {
		NSAlert *alert = [NSAlert alertWithMessageText:MBLocaleStr(@"CannotImportToItemRefWithoutTargetTitle") 
										 defaultButton:MBLocaleStr(@"OK") 
									   alternateButton:nil 
										   otherButton:nil 
							 informativeTextWithFormat:MBLocaleStr(@"CannotImportToItemRefWithoutTargetMsg")];
		[alert runModal];
	} else {
		// get dbConnection and begin transaction
		MBDBAccess *dbAccess = [MBDBAccess sharedConnection];
		if(transact) {
			// begin transaction
			[dbAccess sendBeginTransaction];
		}
		
		// create Extended text item value
		MBExtendedTextItemValue *itemval = [[MBExtendedTextItemValue alloc] initWithDb];
		// set state to init that no notifications are sent
		[itemval setState:InitState];
		// set text type
		[itemval setTextType:type];
		// set value
		[itemval setValueData:textData];
		// set name
		[itemval setName:[NSString stringWithFormat:@"eText import %@",[[NSDate date] description]]];
		
		// set state back to normal
		[itemval setState:NormalState];
		
		// add it
		[itemController addItemValue:itemval 
							  toItem:item 
				 withConnectingValue:YES 
						   operation:AddOperation 
				   withDbTransaction:NO];
		
		// release itemval
		[itemval release];

		if(transact) {
			// commit transaction
			[dbAccess sendCommitTransaction];
		}
		
		// send notification to reload tableview
		MBSendNotifyItemValueListChanged(item);
	}
}

/**
 \brief this method imports a ikam archive
*/
- (void)ikamImport:(NSString *)file toItem:(MBItem *)item asTransaction:(BOOL)transact {
	// check destination again
	if(item == nil) {
		CocoLog(LEVEL_WARN,@"have no destination item, using import item!");
		item = [itemController importItem];
	}	
	
	// if item is a reference, dereference it
	if([item identifier] == ItemRefID) {
		item = (MBItem *)[(MBRefItem *)item target];
	}
	// adding a item to a item ref with out target is not allowed
	if(item == nil) {
		NSAlert *alert = [NSAlert alertWithMessageText:MBLocaleStr(@"CannotImportToItemRefWithoutTargetTitle") 
										 defaultButton:MBLocaleStr(@"OK") 
									   alternateButton:nil 
										   otherButton:nil 
							 informativeTextWithFormat:MBLocaleStr(@"CannotImportToItemRefWithoutTargetMsg")];
		[alert runModal];
	} else {
		// get dbConnection and begin transaction
		MBDBAccess *dbAccess = [MBDBAccess sharedConnection];
		if(transact) {
			// begin transaction
			[dbAccess sendBeginTransaction];
		}

		// use own arp for IKAM import
		NSAutoreleasePool *ikamArp = [[NSAutoreleasePool alloc] init];
		
		// start decoding
		// set exportpath
		[elementController setOversizeDataImportPath:file];
		// get ItemInfo file in package
		NSString *itemInfoFilename = [NSString pathWithComponents:[NSArray arrayWithObjects:file,@"ItemInfo",nil]];
		NSData *itemInfoData = [NSData dataWithContentsOfFile:itemInfoFilename];
		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:itemInfoData];
		// get exporttypeidentifier
		int exportTypeIdentifier = [unarchiver decodeIntForKey:@"ExportTypeIdentifier"];
		// get exported Data
		id exportedItem = [unarchiver decodeObjectForKey:@"ExportData"];
		[unarchiver finishDecoding];
		// release unarchiver, we do not need it anymore
		[unarchiver release];
		
		if(exportedItem != nil) {
			// add it to target
			if(NSLocationInRange(exportTypeIdentifier,ITEMVALUE_ID_RANGE)) {
				[itemController addItemValue:exportedItem 
									  toItem:item 
						 withConnectingValue:YES 
								   operation:AddOperation 
						   withDbTransaction:NO];
			} else {
				[itemController addItem:exportedItem 
								 toItem:item 
							  withIndex:-1 
					 withConnectingItem:YES 
							  operation:AddOperation 
					  withDbTransaction:NO];
			}
		}
		
		// release ikam ARP
		[ikamArp release];
		
		if(transact) {
			// commit transaction
			[dbAccess sendCommitTransaction];
		}
		
		// send notification to reload tableview
		MBSendNotifyItemValueListChanged(item);
	}
}

/**
 \brief this method imports all other stuff from file except the ikam archive itself
 for options parameter you have to specify
*/
- (void)fileImport:(NSString *)file toItem:(MBItem *)item asTransaction:(BOOL)transact {
	// check destination again
	if(item == nil) {
		CocoLog(LEVEL_WARN,@"have no destination item, using import item!");
		item = [itemController importItem];
	}	
	
	// if item is a reference, dereference it
	if([item identifier] == ItemRefID) {
		item = (MBItem *)[(MBRefItem *)item target];
	}
	// adding a item to a item ref with out target is not allowed
	if(item == nil) {
		NSAlert *alert = [NSAlert alertWithMessageText:MBLocaleStr(@"CannotImportToItemRefWithoutTargetTitle") 
										 defaultButton:MBLocaleStr(@"OK") 
									   alternateButton:nil 
										   otherButton:nil 
							 informativeTextWithFormat:MBLocaleStr(@"CannotImportToItemRefWithoutTargetMsg")];
		[alert runModal];
	} else {
		// get dbConnection and begin transaction
		MBDBAccess *dbAccess = [MBDBAccess sharedConnection];
		if(transact) {
			// begin transaction
			[dbAccess sendBeginTransaction];
		}

		// get file attributes
		NSFileManager *fm = [NSFileManager defaultManager];
		NSDictionary *fileAttribs = [fm fileAttributesAtPath:file traverseLink:YES];
		if(fileAttribs == nil) {
			CocoLog(LEVEL_WARN,@"cannot get file attributes of file: %@",file);
		} else {
			// do we keep track of progress?
			MBThreadedProgressSheetController *pController = [MBThreadedProgressSheetController standardProgressSheetController];

			// create a separate Autoreleasepool
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			
			// we only import files that are regular files
			// get filetype
			NSString *filetype = [fileAttribs objectForKey:NSFileType];
			if([filetype isEqualToString:NSFileTypeDirectory]) {
				// import directory and all it's content
				[self importDirectoryAtPath:file toItem:item];
			} else {
				// set current processing file
				if([pController shouldKeepTrackOfProgress]) {
					[pController performSelectorOnMainThread:@selector(setCurrentStepMessage:)
												  withObject:file
											   waitUntilDone:YES];		
				}
				
				// file import indicator
				BOOL doFileImport = NO;
				
				// generate fileURL
				NSURL *fileURL = [NSURL fileURLWithPath:file];
				// get path components
				NSArray *pathComponents = [file pathComponents];
				// get fileextension
				NSString *extension = [[file pathExtension] lowercaseString];
				
				NSData *fileData = nil;
				// load filedata if we import not as link
				if(importAsLink == NO) {
					fileData = [NSData dataWithContentsOfFile:file];
					if(fileData == nil) {
						NSString *str = [NSString stringWithFormat:@"cannot read filedata: %@",file];
						CocoLog(LEVEL_WARN, @"%@", str);
					}
				}
				
				// if we have a typeSpec dict, import according to the settings in there
				if(importAllAsFileValue) {
					doFileImport = YES;
				} else {
					// get default filespec
					NSMutableDictionary *typeSpec = [NSMutableDictionary dictionaryWithDictionary:[userDefaults objectForKey:MBDefaultsFileValueTypeSpecKey]];
					
					// add typespecs for webloc and fileloc
					[typeSpec setObject:[NSNumber numberWithInt:URLItemValueType] forKey:@"webloc"];
					[typeSpec setObject:[NSNumber numberWithInt:URLItemValueType] forKey:@"fileloc"];
					
					// get type to be imported
					NSNumber *type = [typeSpec objectForKey:extension];
					if(type == nil) {
						NSString *str = [NSString stringWithFormat:@"[MBImporter -batchFileImport:] no typespec for key: %@",extension];
						CocoLog(LEVEL_WARN, @"%@", str);
						
						doFileImport = YES;
					} else {
						int typeInt = [type intValue];
						// care for type
						if((typeInt == ExtendedTextTXTValueType) ||
						   (typeInt == ExtendedTextRTFValueType) ||
						   (typeInt == ExtendedTextRTFDValueType)) {
							// extended text
							// create Extended text item value
							MBExtendedTextItemValue *itemval = [[MBExtendedTextItemValue alloc] initWithDb];
							// set state to init that no notifications are sent
							[itemval setState:InitState];

							// set text type
							switch(typeInt) {
								case ExtendedTextTXTValueType:
									[itemval setTextType:TextTypeTXT];
									break;
								case ExtendedTextRTFValueType:
									[itemval setTextType:TextTypeRTF];
									break;
								case ExtendedTextRTFDValueType:
									[itemval setTextType:TextTypeRTFD];
									break;
							}
							// set value
							// on link, this is nil
							[itemval setValueData:fileData];
							// set name
							[itemval setName:[pathComponents objectAtIndex:([pathComponents count]-1)]];
							// set link
							[itemval setLinkValueAsURL:fileURL];
							// as link?
							if(importAsLink) {
								[itemval setIsLink:YES];
								[itemval setAutoHandleLoadSave:importWithAutoload];
							}		
							
							// set state back to normal
							[itemval setState:NormalState];
							
							// add it
							[itemController addItemValue:itemval 
												  toItem:item 
									 withConnectingValue:YES 
											   operation:AddOperation 
									   withDbTransaction:NO];
							
							// release itemval
							[itemval release];
						} else if(typeInt == ImageItemValueType) {
							// load filedata to generate thumbnail
							if(fileData == nil) {
								fileData = [NSData dataWithContentsOfFile:file];
							}
							
							// still nil?
							if(fileData == nil) {
								NSString *str = [NSString stringWithFormat:@"cannot read filedata: %@",file];
								CocoLog(LEVEL_WARN, @"%@", str);
							} else {
								// create NSBitmapImageRep
								NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithData:fileData];
								if(bitmapRep == nil) {
									NSString *str = [NSString stringWithFormat:@"cannot get BitmapImageRep from: %@",file];
									CocoLog(LEVEL_WARN, @"%@", str);
								} else {
									// image
									MBImageItemValue *itemval = [[MBImageItemValue alloc] initWithDb];
									// set state to init that no notifications are sent
									[itemval setState:InitState];

									// set imagetype
									[itemval setImageType:extension];
									// save size
									[itemval setImageSize:NSMakeSize([bitmapRep pixelsWide],[bitmapRep pixelsHigh])];
									// create a thumbnail image
									NSImage *thumb = [itemval generateThumbnailOfImageRep:bitmapRep];
									if(thumb != nil) {
										// save thumbimage to db
										[itemval setThumbImage:thumb];
									}
									// release imageRep
									[bitmapRep release];
									
									// set name
									[itemval setName:[pathComponents objectAtIndex:([pathComponents count]-1)]];
									// set link
									[itemval setLinkValueAsURL:fileURL];
									// as link?
									if(importAsLink) {
										[itemval setIsLink:YES];
										[itemval setAutoHandleLoadSave:importWithAutoload];
									} else {
										// set value
										[itemval setValueData:fileData];
									}
									
									// set state back to normal
									[itemval setState:NormalState];

									// add it
									[itemController addItemValue:itemval 
														  toItem:item 
											 withConnectingValue:YES 
													   operation:AddOperation 
											   withDbTransaction:NO];
									
									// release itemval
									[itemval release];												
								}
							}
						} else if(typeInt == PDFItemValueType) {
							MBPDFItemValue *itemval = [[MBPDFItemValue alloc] initWithDb];
							// set state to init that no notifications are sent
							[itemval setState:InitState];
                            // set value
							// on link, this is nil
							[itemval setValueData:fileData];
							// set name
							[itemval setName:[pathComponents objectAtIndex:([pathComponents count]-1)]];
							// set link
							[itemval setLinkValueAsURL:fileURL];
							// as link?
							if(importAsLink) {
								[itemval setIsLink:YES];
								[itemval setAutoHandleLoadSave:importWithAutoload];
							}
							// set state back to normal
							[itemval setState:NormalState];
							
							// add it
							[itemController addItemValue:itemval 
												  toItem:item 
									 withConnectingValue:YES 
											   operation:AddOperation 
									   withDbTransaction:NO];
							
							// release itemval
							[itemval release];
						} else if(typeInt == URLItemValueType) {
							// url value										
							NSString *name = nil;
							NSString *value = nil;
							
							// extract the name of the URLValue out of the filename
							// get last path Component
							NSString *lastPathComp = [[file pathComponents] objectAtIndex:([[file pathComponents] count]-1)];
							// get exporter, he has some methods we can use here
							MBExporter *exporter = [MBExporter defaultExporter];
							// get filename only, without extension
							name = [NSString stringWithString:[exporter generateFilenameWithExtension:nil fromFilename:lastPathComp]];
							
							// there are two version available to webloc/fileloc files
							// one is to store the URL in a NSDictionary with KEY = URL (Camino, We)
							// the other is to store all informstion in the resource fork of the file (safari)
							// try the first
							NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:file];
							if(dict != nil) {
								// we have the first method
								value = [dict valueForKey:@"URL"];
							} else {
								// get url out of resource
								NSData *urlData = nil;
								int stat = [MBFileItemValue getResourceDataForResType:1413830740 
																			   atPath:file data:&urlData];
								if(stat == 0) {
									value = [[[NSString alloc] initWithData:urlData 
																   encoding:NSUTF8StringEncoding] autorelease];
								}
							}
							
							// create URL value
							MBURLItemValue *itemval = [[MBURLItemValue alloc] initWithDb];
							// set state to init that no notifications are sent
							[itemval setState:InitState];

							// set value
							if(value != nil) {
								[itemval setValueData:[NSURL URLWithString:value]];
							}
							// set name
							if(name != nil) {
								[itemval setName:name];
							}
							
							// set state back to normal
							[itemval setState:NormalState];
							
							// add it
							[itemController addItemValue:itemval 
												  toItem:item 
									 withConnectingValue:YES 
											   operation:AddOperation 
									   withDbTransaction:NO];
							
							// release itemval
							[itemval release];										
						} else {
							doFileImport = YES;
						}
					}
				}	
				
				if(doFileImport == YES) {
					// import as file
					// create file item value
					MBFileItemValue *itemval = [[MBFileItemValue alloc] initWithDb];
					// set state init that no notifications are sent
					[itemval setState:InitState];
					// set value
					[itemval setValueData:fileData];
					// set name
					[itemval setName:[pathComponents objectAtIndex:([pathComponents count]-1)]];
					// set link
					[itemval setLinkValueAsURL:fileURL];
					// as link?
					if(importAsLink) {
						[itemval setIsLink:YES];
					} else {
						// get file attributes
						if(fileAttribs != nil)
						{
							[itemval setFileAttributesDict:fileAttribs];
						}
					}
					
					// set state back to normal
					[itemval setState:NormalState];
					
					// add it
					[itemController addItemValue:itemval 
										  toItem:item 
							 withConnectingValue:YES 
									   operation:AddOperation 
							   withDbTransaction:NO];
					
					// release itemval
					[itemval release];								
				}
			}
			
			// release ARP
			[pool release];
			
			// do we keep track of progress?
			if([pController shouldKeepTrackOfProgress]) {
				// we processed one file
				[pController performSelectorOnMainThread:@selector(incrementProgressBy:)
											  withObject:[NSNumber numberWithDouble:1.0]
										   waitUntilDone:YES];		
			}
		}		
		
		if(transact) {
			// commit transaction
			[dbAccess sendCommitTransaction];
			// send notification to reload tableview
			MBSendNotifyItemValueListChanged(item);
		}		
	}
}

/**
 \brief import whole directories
*/
- (void)directoryImport:(NSString *)file toItem:(MBItem *)item asTransaction:(BOOL)transact {
}

/**
 \brief import files from finder or promised files
 @param filenames array of absolute paths to import
 @param typeSpec fileextension itemvalue assignments, if nil import all as file
 @param requester show import requester where user can set fileextension itemvalue issignments
*/
- (void)fileValueImport:(NSArray *)filenames toItem:(MBItem *)item {
	// lock this
	if([importerLock tryLock]) {
		NSDictionary *defaultFileSpec = [userDefaults valueForKey:MBDefaultsFileValueTypeSpecKey];
		
		// if item is a reference, dereference it
		if([item identifier] == ItemRefID) {
			item = (MBItem *)[(MBRefItem *)item target];
		}
		// adding a item to a item ref with out target is not allowed
		if(item == nil) {
			NSAlert *alert = [NSAlert alertWithMessageText:MBLocaleStr(@"CannotImportToItemRefWithoutTargetTitle") 
											 defaultButton:MBLocaleStr(@"OK") 
										   alternateButton:nil 
											   otherButton:nil 
								 informativeTextWithFormat:MBLocaleStr(@"CannotImportToItemRefWithoutTargetMsg")];
			[alert runModal];
		} else {
			// buffer parameters
			targetItem = item;

			// if filenames is nil
			// show filerequester
			if(filenames == nil) {
				// reset import settings
				[self resetSettings];
								
				// open panel
				NSOpenPanel *oPanel = [NSOpenPanel openPanel];
				// setup openpanel to only choose directories
				[oPanel setCanChooseFiles:YES];
				[oPanel setCanChooseDirectories:YES];
				[oPanel setCanCreateDirectories:NO];
				[oPanel setAllowsMultipleSelection:YES];
				//[oPanel setCanSelectHiddenExtension:YES];
				// set accessory panel
				[oPanel setAccessoryView:accessoryView];	
				// open openpanel
				[oPanel beginSheetForDirectory:nil 
										  file:nil
								modalForWindow:[GlobalWindows mainAppWindow] 
								 modalDelegate:self
								didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:) 
								   contextInfo:nil];
			} else {
				// do we have enough files
				if([filenames count] > 0) {
					/*
					// make new Array with all files that are regular files
					NSMutableArray *files = [NSMutableArray array];
					
					// precheck files for regular files
					NSFileManager *fm = [NSFileManager defaultManager];
					NSEnumerator *iter = [filenames objectEnumerator];
					NSString *path = nil;
					while((path = [iter nextObject]))
					{
						// get file attributes of file
						NSDictionary *fileAttribs = [fm fileAttributesAtPath:path traverseLink:NO];
						if(fileAttribs == nil)
						{
							
						}
					}
					 */
					
					// check destination again
					if(item == nil) {
						CocoLog(LEVEL_WARN,@"[MBImporter -fileValueImport:typeSpec:showRequester:] have no destination item, using importItem");
						item = [itemController importItem];
					}

					// bring up progress sheet
					MBThreadedProgressSheetController *pSheet = [MBThreadedProgressSheetController standardProgressSheetController];
					[pSheet setMinProgressValue:[NSNumber numberWithDouble:0.0]];
					[pSheet setIsThreaded:[NSNumber numberWithBool:YES]];
					[pSheet setIsIndeterminateProgress:[NSNumber numberWithBool:NO]];
					[pSheet setShouldKeepTrackOfProgress:[NSNumber numberWithBool:YES]];
					[pSheet setProgressAction:[NSNumber numberWithInt:IMPORT_PROGRESS_ACTION]];
					[pSheet setActionMessage:MBLocaleStr(@"Import...")];

					// generate dict
					NSMutableDictionary *params = [NSMutableDictionary dictionary];
					// add filenames
					[params setObject:filenames forKey:FILEIMPORTER_PARAMS_FILENAMES_KEY];
					// item
					[params setObject:item forKey:FILEIMPORTER_PARAMS_DESTITEM_KEY];
					// typespec
					if(importAllAsFileValue == NO) {
						[params setObject:defaultFileSpec forKey:FILEIMPORTER_PARAMS_TYPESPEC_KEY];
					}
					// as Link
					[params setObject:[NSNumber numberWithBool:importAsLink] 
							   forKey:FILEIMPORTER_PARAMS_IMORTASLINK_KEY];
					// with Autoload
					[params setObject:[NSNumber numberWithBool:importWithAutoload] 
							   forKey:FILEIMPORTER_PARAMS_IMORTWITHAUTOLOAD_KEY];
					// recursive?
					[params setObject:[NSNumber numberWithBool:importRecursive] 
							   forKey:FILEIMPORTER_PARAMS_RECURSIVE_KEY];
					
					// start this in an own thread
					//[NSThread detachNewThreadSelector:@selector(batchFileImport:) toTarget:self withObject:params];
					[self batchFileImport:params];
					
					// reset import settings after import
					[self resetSettings];
				} else {
					CocoLog(LEVEL_WARN,@"[MBImporter -fileValueImport:typeSpec:showRequester:] no files!");
				}
			}
		}
		
		// unlock
		[importerLock unlock];
	} else {
		CocoLog(LEVEL_WARN,@"[MBImporter -fileValueImport:toItem:] import in progress, cannot proceed!");
		NSRunAlertPanel(MBLocaleStr(@"ImportInProgressTitle"),
						MBLocaleStr(@"ImportInProgressMsg"),
						MBLocaleStr(@"OK"),nil,nil);
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
		NSArray *filenames = [panel filenames];
		[self fileValueImport:filenames toItem:targetItem];
	}
}

// ---------------------------------------------------------------------
// Accessors
// ---------------------------------------------------------------------
- (IBAction)importAsLinkSwitch:(id)sender {
	importAsLink = (BOOL)[(NSButton *)sender state];
	[importWithAutoloadButton setEnabled:importAsLink];
}

- (IBAction)importWithAutoloadSwitch:(id)sender {
	importWithAutoload = (BOOL)[(NSButton *)sender state];
}

- (IBAction)importRecursiveSwitch:(id)sender {
	importRecursive = (BOOL)[(NSButton *)sender state];
}

- (IBAction)importAllAsFileValue:(id)sender {
	importAllAsFileValue = YES;
}

- (IBAction)importAccordingToFiletypes:(id)sender {
	importAllAsFileValue = NO;
}

@end
