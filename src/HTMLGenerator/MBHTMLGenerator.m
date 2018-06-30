//
//  MBHTMLGenerator.m
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

#import "MBHTMLGenerator.h"
#import "MBCommonItem.h"
#import "MBExporter.h"
#import "MBTemplate.h"
#import "globals.h"
#import "MBImExportPrefsViewController.h"
#import "MBItem.h"
#import "MBTextItemValue.h"
#import "MBNumberItemValue.h"
#import "MBBoolItemValue.h"
#import "MBDateItemValue.h"
#import "MBURLItemValue.h"
#import "MBExtendedTextItemValue.h"
#import "MBImageItemValue.h"
#import "MBRefItem.h"

@interface MBHTMLGenerator (privateAPI)

- (NSString *)filenameForItem:(MBCommonItem *)item withPath:(NSString *)path;

- (NSString *)generateHTMLFromItemDictList:(NSArray *)items withOptions:(NSDictionary *)options;
- (NSString *)generateHTMLFromItemValueDictList:(NSArray *)itemValues withOptions:(NSDictionary *)options;

- (NSString *)createHTMLValueTableFromDict:(NSDictionary *)itemDict withOptions:(NSDictionary *)options;
- (NSString *)createHTMLTableFromDict:(NSDictionary *)itemDict withOptions:(NSDictionary *)options;

@end

@implementation MBHTMLGenerator (privateAPI)

- (NSString *)filenameForItem:(MBCommonItem *)item withPath:(NSString *)path {
	NSString *abspath = nil;
	
	// get a exporter
	MBExporter *exporter = [MBExporter defaultExporter];
	// get name propusal
	NSString *filename = [exporter guessFilenameFor:item];
	CocoLog(LEVEL_DEBUG,@"guessed filename: %@",filename);
	NSString *extension = [exporter guessFileExtensionFor:item];
	CocoLog(LEVEL_DEBUG,@"guessed extension: %@",extension);
	NSString *absname = [exporter generateFilenameWithExtension:extension 
												   fromFilename:filename];
	CocoLog(LEVEL_DEBUG,@"generated filename: %@",absname);
	
	// generate absolute path
	abspath = [NSString pathWithComponents:[NSArray arrayWithObjects:path,absname,nil]];
	
	// if this file exists already, we have to find a new filename
	abspath = [exporter findNextFilenameFor:abspath];
	CocoLog(LEVEL_DEBUG,@"abs path: %@",abspath);
	
	return abspath;
}

- (NSString *)generateHTMLFromItemDictList:(NSArray *)items withOptions:(NSDictionary *)options {
    NSString *ret = @"";
    
    // check items and options
    if(options == nil) {
        CocoLog(LEVEL_ERR, @"have nil options!");
    } else {
        if(items == nil) {
            CocoLog(LEVEL_ERR, @"have nil items array!");
        } else {
            NSMutableString *htmlString = [NSMutableString string];
            NSDictionary *itemDict = nil;
            NSEnumerator *iter = [items objectEnumerator];
            while((itemDict = [iter nextObject])) {
                // check identifier
                int identifier = [(NSNumber *)[itemDict objectForKey:HTMLItemIdentifierKey] intValue];
                if(identifier >= StdItemID) {
                    // ok, we have the source item, create list with this dict
                    [htmlString appendString:[self createHTMLValueTableFromDict:itemDict withOptions:options]];
                    [htmlString appendString:@"<br>"];
                }
            }
            
            // get main template
            // use template for producing html
            NSString *templatePath = [options objectForKey:MBHTMLGenTemplatesPath];
            NSString *mainTemplatePath = [templatePath stringByAppendingPathComponent:@"MainTemplate.tmpl"];
            
            // the templates strings
            NSString *mainTemplSource = [NSString stringWithContentsOfFile:mainTemplatePath];        
            
            // create dictionary for the two values
            NSString *cssString = [options objectForKey:MBHTMLGenStyleSheetPath];
            NSDictionary *mainDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:htmlString, cssString, nil] 
                                                                 forKeys:[NSArray arrayWithObjects:HTMLMainTable, HTMLStyleSheetFileURLStringKey, nil]];
            
            // process template
            NSString *templResult = [MBTemplate replaceTemplateStringSource:mainTemplSource withDict:mainDict];
            if(templResult != nil) {
                ret = [NSString stringWithString:templResult];
            } else {
                CocoLog(LEVEL_ERR, @"got nil result from main template processing!");
            }
        }
    }
        
    return ret;
}

- (NSString *)generateHTMLFromItemValueDictList:(NSArray *)itemValues withOptions:(NSDictionary *)options {
    NSString *ret = @"";
    
    // check items and options
    if(options == nil) {
        CocoLog(LEVEL_ERR, @"have nil options!");
    } else {
        if(itemValues == nil) {
            CocoLog(LEVEL_ERR, @"have nil items array!");
        } else {
            NSMutableString *htmlString = [NSMutableString string];
            NSDictionary *itemValDict = nil;
            NSEnumerator *iter = [itemValues objectEnumerator];
            while((itemValDict = [iter nextObject])) {
                // check identifier
                int identifier = [(NSNumber *)[itemValDict objectForKey:HTMLItemIdentifierKey] intValue];
                if(identifier >= StdItemID) {
                    // ok, we have the source item, create list with this dict
                    [htmlString appendString:[self createHTMLTableFromDict:itemValDict withOptions:options]];
                    [htmlString appendString:@"<br>"];
                }
            }
            
            // get main template
            // use template for producing html
            NSString *templatePath = [options objectForKey:MBHTMLGenTemplatesPath];
            NSString *mainTemplatePath = [templatePath stringByAppendingPathComponent:@"MainTemplate.tmpl"];
            
            // the templates strings
            NSString *mainTemplSource = [NSString stringWithContentsOfFile:mainTemplatePath];        
            
            // create dictionary for the two values
            NSString *cssString = [options objectForKey:MBHTMLGenStyleSheetPath];
            NSDictionary *mainDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:htmlString, cssString, nil] 
                                                                 forKeys:[NSArray arrayWithObjects:HTMLMainTable, HTMLStyleSheetFileURLStringKey, nil]];
            
            // process template
            NSString *templResult = [MBTemplate replaceTemplateStringSource:mainTemplSource withDict:mainDict];
            if(templResult != nil) {
                ret = [NSString stringWithString:templResult];
            } else {
                CocoLog(LEVEL_ERR, @"got nil result from main template processing!");
            }
        }
    }
    
    return ret;
}

- (NSString *)createHTMLValueTableFromDict:(NSDictionary *)itemDict withOptions:(NSDictionary *)options {
    NSString *ret = @"";
    
    NSArray *values = [itemDict objectForKey:HTMLItemValuesKey];
    if(values == nil) {
        CocoLog(LEVEL_ERR, @"values array is nil!");
    } else {
        // get some options
        //BOOL makeLinkURLs = (BOOL)[(NSNumber *)[options objectForKey:MBHTMLGenMakeLinkURLs] intValue];
        //BOOL linkItems = (BOOL)[(NSNumber *)[options objectForKey:MBHTMLGenLinkItems] intValue];
        
        // use template for producing html
        NSString *templatePath = [options objectForKey:MBHTMLGenTemplatesPath];
        NSString *valueListTableTemplatePath = [templatePath stringByAppendingPathComponent:@"ValueListTable.tmpl"];
        NSString *valueListRowTemplatePath = [templatePath stringByAppendingPathComponent:@"ValueListRow.tmpl"];

        // the templates strings
        NSString *valListTableTemplSource = [NSString stringWithContentsOfFile:valueListTableTemplatePath];        
        NSString *valListRowTemplSource = [NSString stringWithContentsOfFile:valueListRowTemplatePath];

        // loop over values
        NSMutableString *rowString = [NSMutableString string];
        NSDictionary *valueDict = nil;
        NSEnumerator *iter = [values objectEnumerator];
        while((valueDict = [iter nextObject])) {
            NSString *rowResult = [MBTemplate replaceTemplateStringSource:valListRowTemplSource withDict:valueDict];
            if(rowResult != nil) {
                [rowString appendString:rowResult];
            } else {
                CocoLog(LEVEL_WARN, @"got nil from template row creation!");
            }
        }
        
        // create dict for the table template creation
        NSString *itemNameURL = [itemDict objectForKey:HTMLItemNameURLKey];
        NSDictionary *tableTempDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:rowString, itemNameURL, nil] 
                                                                  forKeys:[NSArray arrayWithObjects:HTMLSimpleValueTableRow, HTMLItemNameURLKey, nil]];
        
        // gen html for table
        NSString *tableString = [MBTemplate replaceTemplateStringSource:valListTableTemplSource withDict:tableTempDict];
        // check for error
        if(tableString != nil) {
            ret = [NSString stringWithString:tableString];
        } else {
            CocoLog(LEVEL_WARN, @"got nil from template table creation!");
        }
    }
    
    return ret;
}

- (NSString *)createHTMLTableFromDict:(NSDictionary *)itemDict withOptions:(NSDictionary *)options {
    NSString *ret = @"";
    
    NSArray *values = [itemDict objectForKey:HTMLItemValuesKey];
    if(values == nil) {
        CocoLog(LEVEL_ERR, @"values array is nil!");
    } else {
        // get some options
        //BOOL makeLinkURLs = (BOOL)[(NSNumber *)[options objectForKey:MBHTMLGenMakeLinkURLs] intValue];
        //BOOL linkItems = (BOOL)[(NSNumber *)[options objectForKey:MBHTMLGenLinkItems] intValue];
        //BOOL printSelf = (BOOL)[(NSNumber *)[itemDict objectForKey:HTMLItemPrintSelfKey] intValue];
        
        // use template for producing html
        NSString *templatePath = [options objectForKey:MBHTMLGenTemplatesPath];
        NSString *valueListStdValTemplPath = [templatePath stringByAppendingPathComponent:@"ItemValueTable_Std.tmpl"];
        NSString *valueListETextValTemplPath = [templatePath stringByAppendingPathComponent:@"ItemValueTable_EText.tmpl"];
        NSString *valueListImageValTemplPath = [templatePath stringByAppendingPathComponent:@"ItemValueTable_Image.tmpl"];
        NSString *valueListFileValTemplPath = [templatePath stringByAppendingPathComponent:@"ItemValueTable_File.tmpl"];
        
        // the templates strings
        NSString *valStdTableTemplSource = [NSString stringWithContentsOfFile:valueListStdValTemplPath];        
        NSString *valETextTableTemplSource = [NSString stringWithContentsOfFile:valueListETextValTemplPath];        
        NSString *valImageTableTemplSource = [NSString stringWithContentsOfFile:valueListImageValTemplPath];        
        NSString *valFileTableTemplSource = [NSString stringWithContentsOfFile:valueListFileValTemplPath];        
        
        // loop over values
        NSMutableString *tableString = [NSMutableString string];
        NSDictionary *valueDict = nil;
        NSEnumerator *iter = [values objectEnumerator];
        while((valueDict = [iter nextObject])) {
            int identifier = [(NSNumber *)[valueDict objectForKey:HTMLItemIdentifierKey] intValue];
            
            NSString *tableResult = @"";
            if(identifier == ExtendedTextItemValueID) {
                tableResult = [MBTemplate replaceTemplateStringSource:valETextTableTemplSource 
                                                             withDict:valueDict];                
            } else if(identifier == ImageItemValueID) {
                tableResult = [MBTemplate replaceTemplateStringSource:valImageTableTemplSource 
                                                             withDict:valueDict];            
            } else if(identifier == FileItemValueID) {
                tableResult = [MBTemplate replaceTemplateStringSource:valFileTableTemplSource 
                                                             withDict:valueDict];            
            } else {
                tableResult = [MBTemplate replaceTemplateStringSource:valStdTableTemplSource 
                                                             withDict:valueDict];                        
            }
            
            if(tableResult != nil) {
                [tableString appendString:tableResult];
            } else {
                CocoLog(LEVEL_WARN, @"got nil from template table creation!");
            }
        }
        
        // check for error
        if(tableString != nil) {
            ret = [NSString stringWithString:tableString];
        } else {
            CocoLog(LEVEL_WARN, @"got nil from template table creation!");
        }
    }
    
    return ret;    
}

@end

@implementation MBHTMLGenerator

/**
    encode all strings that are entities
 */
+ (NSString *)encodeHTMLEntitiesInString:(NSString *)source {
    NSString *ret = nil;
    
    // loop over all 
    int len = [source length];
    // this will get the output
    NSMutableString *dest = [NSMutableString string];
    for(int i = 0;i < len;i++) {
        unichar str = [source characterAtIndex:i];
        if((str >= 160)) {
            // we need to encode this
            [dest appendFormat:@"&#%d;", str];
        } else {
            [dest appendString:[NSString stringWithCharacters:&str length:1]];
        }
    }
        
    ret = [NSString stringWithString:dest];

    return ret;
}

+ (MBHTMLGenerator *)defaultGenerator {
	static MBHTMLGenerator *singleton;
	
	if(singleton == nil) {
		singleton = [[MBHTMLGenerator alloc] init];
	}
	
	return singleton;
}

/**
 Default options for printing
 do not export files, images or etexts
*/
+ (NSDictionary *)defaultPrintOptions {
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:[NSNumber numberWithBool:NO] forKey:MBHTMLGenLinkItems];
	[dict setObject:[NSNumber numberWithBool:NO] forKey:MBHTMLGenExportData];
	[dict setObject:[NSNumber numberWithBool:NO] forKey:MBHTMLGenCopyLocalExternals];	
	[dict setObject:[NSNumber numberWithBool:NO] forKey:MBHTMLGenCopyRemoteExternals];	
	[dict setObject:[NSNumber numberWithBool:NO] forKey:MBHTMLGenMakeLinkURLs];
	
	return dict;
}

/**
 Default options for HTML export
 export all files, images, etexts to a separate directory and link them
 */
+ (NSDictionary *)defaultExportOptions {
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:[NSNumber numberWithBool:NO] forKey:MBHTMLGenLinkItems];
	[dict setObject:[NSNumber numberWithBool:YES] forKey:MBHTMLGenExportData];
	[dict setObject:[NSNumber numberWithBool:NO] forKey:MBHTMLGenCopyLocalExternals];
	[dict setObject:[NSNumber numberWithBool:NO] forKey:MBHTMLGenCopyRemoteExternals];
	[dict setObject:[NSNumber numberWithBool:YES] forKey:MBHTMLGenMakeLinkURLs];
	
	return dict;	
}

- (id)init {
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"cannot alloc MBHTMLGenerator!");		
	} else {
	}
	
	return self;
}

- (void)dealloc {
	// dealloc object
	[super dealloc];
}

/**
 Options for generating a ItemList are:
 if options are nil, default oiptions are taken from NSUserDefaults
*/
- (NSString *)generateHTMLForItemList:(NSArray *)itemList toOutputDir:(NSString *)path options:(NSDictionary *)options {
	NSString *indexHTML = nil;
	
	// check for options
	NSMutableDictionary *opt = nil;
	if(options != nil) {
		opt = [NSMutableDictionary dictionaryWithDictionary:options];
	} else {
		opt = [NSMutableDictionary dictionaryWithDictionary:[userDefaults objectForKey:MBDefaultsHTMLExportDefaultsOptionsKey]];
	}
	
	// check, if have a path where we should create the stuff
	if(path == nil) {
		// lets use TMPFOLDER for creating
		path = TMPFOLDER;
	}
	
	NSFileManager *fm = [NSFileManager defaultManager];
	// check, if path exists, otherwise create it
	if(![fm fileExistsAtPath:path]) {
		// create it
		if(![fm createDirectoryAtPath:path attributes:nil]) {
			CocoLog(LEVEL_WARN,@"could not create folder at path: %@!",path);
			return nil;
		}	
	}
	
	// set outputpath to options
	[opt setObject:path forKey:MBHTMLGenExportPath];
	
	// thumbimage URL
	NSString *thDir = [NSString pathWithComponents:[NSArray arrayWithObjects:path,ThumbsRelPath,nil]];
	// if it doesn't exist, create it
	if(![fm fileExistsAtPath:thDir]) {
		// create it
		if(![fm createDirectoryAtPath:thDir attributes:nil]) {
			CocoLog(LEVEL_WARN,@"could not create folder for thumbs!");
			return nil;
		}	
	}
	
	// do we export data?
	BOOL exportData = (BOOL)[[opt valueForKey:MBHTMLGenExportData] intValue];

	NSString *fileDir = [NSString pathWithComponents:[NSArray arrayWithObjects:path,FilesRelPath,nil]];
	if(exportData == YES) {
		// create folder for files
		if(![fm fileExistsAtPath:fileDir]) {
			// create it
			if(![fm createDirectoryAtPath:fileDir attributes:nil]) {
				CocoLog(LEVEL_WARN,@"could not create folder for files!");
				return nil;
			}	
		}
		
		// add path to files to options
		[opt setObject:fileDir forKey:MBHTMLGenExportFilesPath];
	}
	
	// images
	NSString *imageDir = [NSString pathWithComponents:[NSArray arrayWithObjects:path,ImagesRelPath,nil]];
	if(exportData == YES) {
		// create folder for images
		if(![fm fileExistsAtPath:imageDir]) {
			// create it
			if(![fm createDirectoryAtPath:imageDir attributes:nil]) {
				CocoLog(LEVEL_WARN,@"could not create folder for image!");
				return nil;
			}	
		}
		
		// add path to images to options
		[opt setObject:imageDir forKey:MBHTMLGenExportImagesPath];
	}
	
	// etexts
	NSString *etextsDir = [NSString pathWithComponents:[NSArray arrayWithObjects:path,ETextsRelPath,nil]];
	if(exportData == YES) {
		// create folder for images
		if(![fm fileExistsAtPath:etextsDir]) {
			// create it
			if(![fm createDirectoryAtPath:etextsDir attributes:nil]) {
				CocoLog(LEVEL_WARN,@"could not create folder for etexts!");
				return nil;
			}	
		}
		
		// add path to images to options
		[opt setObject:etextsDir forKey:MBHTMLGenExportETextsPath];
	}
	
	// do we have to copy externals?
	BOOL copyLocalExternals = (BOOL)[[opt valueForKey:MBHTMLGenCopyLocalExternals] intValue];
	BOOL copyRemoteExternals = (BOOL)[[opt valueForKey:MBHTMLGenCopyRemoteExternals] intValue];
	// do we have to make links out of urls?
	//BOOL makeLinkURLs = (BOOL)[[opt valueForKey:MBHTMLGenMakeLinkURLs] intValue];
	// do we have to produce links for items?
	BOOL linkItems = (BOOL)[[opt valueForKey:MBHTMLGenLinkItems] intValue];
	
	// init itemDictList
	NSMutableArray *itemDictList = [NSMutableArray array];
	NSEnumerator *iter = [itemList objectEnumerator];
	MBCommonItem *commonItem = nil;
	MBItem *item = nil;
	NSMutableArray *valuesArray = nil;
	NSMutableDictionary *itemDict = nil;
	while((commonItem = [iter nextObject])) {
		// check for reference
		if(([commonItem identifier] == ItemRefID) ||
		   ([commonItem identifier] == ItemValueRefID)) {
			commonItem = [(MBRefItem *)commonItem target];
		}
		
		if(NSLocationInRange([commonItem identifier], ITEM_ID_RANGE)) {
			// create new values array, the old is retained by dict, at least it should be
			valuesArray = [NSMutableArray array];
			
			// this is our new item
			item = (MBItem *)commonItem;
			
			// create new item dict
			itemDict = [NSMutableDictionary dictionary];
			// add it to our print array
			[itemDictList addObject:itemDict];
			NSString *itemString = [item name];
			NSString *itemURL = nil;
			if(linkItems) {
				itemURL = [NSString stringWithFormat:@"Item_%d",[item itemID]];
                itemURL = [NSString stringWithFormat:@"<a href=\"%@\">%@</a>", itemURL, itemString];
			} else {
				itemURL = itemString;
			}
            // encode itemURL for html
            itemURL = [MBHTMLGenerator encodeHTMLEntitiesInString:itemURL];
            itemString = [MBHTMLGenerator encodeHTMLEntitiesInString:itemString];
            
            // fill dict
			[itemDict setObject:[NSNumber numberWithInt:[item identifier]] forKey:HTMLItemIdentifierKey];
			[itemDict setObject:itemString forKey:HTMLItemNameStringKey];
			[itemDict setObject:itemURL forKey:HTMLItemNameURLKey];
			// print self?
			[itemDict setObject:[NSNumber numberWithInt:0] forKey:HTMLItemPrintSelfKey];
			[itemDict setObject:valuesArray forKey:HTMLItemValuesKey];
			
			// process all values of this item
			NSEnumerator *iter2 = [[item itemValues] objectEnumerator];
			MBItemValue *itemval = nil;
			while((itemval = [iter2 nextObject])) {
				// check for reference
				if([itemval identifier] == ItemValueRefID) {
					itemval = (MBItemValue *)[(MBRefItem *)itemval target];
				}
				
				// create Dict for itemvalue
				NSMutableDictionary *valueDict = [NSMutableDictionary dictionary];
				// add it to the valuesArray
				[valuesArray addObject:valueDict];
				// fill it
				NSString *itemValString = [itemval name];
				NSString *itemValURL = nil;
				if(linkItems) {
					// create references
					itemValURL = [NSString stringWithFormat:@"ItemValue_%d",[itemval itemID]];
                    itemValURL = [NSString stringWithFormat:@"<a href=\"%@\">%@</a>", itemValURL, itemValString];
				} else {
					// no references
					itemValURL = itemValString;
				}
                // encode itemURL for html
                itemValURL = [MBHTMLGenerator encodeHTMLEntitiesInString:itemValURL];
                
				[valueDict setObject:itemValString forKey:HTMLItemValueNameStringKey];
				[valueDict setObject:itemValURL forKey:HTMLItemValueNameURLKey];
				[valueDict setObject:[NSNumber numberWithInt:[itemval identifier]] forKey:HTMLItemIdentifierKey];
				
				// switch for itemtype
				NSString *valueTypeString = nil;
                NSMutableString *valueData = [NSMutableString string];
				switch([itemval valuetype]) {
					case SimpleTextItemValueType:
					{
						valueTypeString = SIMPLETEXT_ITEMVALUE_TYPE_NAME;
						valueData = [NSMutableString stringWithString:[(MBTextItemValue *)itemval valueDataAsString]];
						break;
					}
					case NumberItemValueType:
					{
						valueTypeString = NUMBER_ITEMVALUE_TYPE_NAME;
						valueData = [NSMutableString stringWithString:[(MBNumberItemValue *)itemval valueDataAsString]];
						break;
					}
					case CurrencyItemValueType:
					{
						valueTypeString = CURRENCY_ITEMVALUE_TYPE_NAME;
						valueData = [NSMutableString stringWithString:[(MBNumberItemValue *)itemval valueDataAsString]];
						break;
					}
					case BoolItemValueType:
					{
						valueTypeString = BOOL_ITEMVALUE_TYPE_NAME;
						valueData = [NSMutableString stringWithString:[(MBBoolItemValue *)itemval valueDataAsString]];
						break;
					}
					case DateItemValueType:
					{
						valueTypeString = DATE_ITEMVALUE_TYPE_NAME;
						valueData = [NSMutableString stringWithString:[(MBDateItemValue *)itemval valueDataAsString]];
						break;
					}
					case URLItemValueType:
					{
						valueTypeString = URL_ITEMVALUE_TYPE_NAME;
						valueData = [NSMutableString stringWithString:[(MBURLItemValue *)itemval valueDataAsString]];
						break;
					}
					case ExtendedTextItemValueType:
					{
						valueTypeString = EXTENDEDTEXT_ITEMVALUE_TYPE_NAME;
						valueData = [NSMutableString string];
						
						// do we have to export the file?
						NSString *abspath = nil;
						NSString *relpath = nil;
						if(exportData) {
							abspath = [self filenameForItem:itemval withPath:etextsDir];
							NSArray *pcomps = [abspath pathComponents];
							relpath = [NSString stringWithFormat:@"%@/%@",ETextsRelPath,[pcomps objectAtIndex:([pcomps count]-1)]];
						}
						
						// internal, external
						BOOL isLink = [(MBExtendedTextItemValue *)itemval isLink];
						BOOL isFileURL = [[(MBExtendedTextItemValue *)itemval linkValueAsURL] isFileURL];
						NSURL *pathURL = [(MBExtendedTextItemValue *)itemval linkValueAsURL];
						if(isLink)  {
							[valueDict setObject:MBLocaleStr(@"External") forKey:HTMLItemValueDataLocationStringKey];
							if(isFileURL) {
								// load valueData from target
								NSData *data = [(MBExtendedTextItemValue *)itemval valueDataByLoadingFromTarget];
								// convert
								valueData = [NSMutableString stringWithString:[MBExtendedTextItemValue convertDataToString:data 
																											  withTextType:[(MBExtendedTextItemValue *)itemval textType]]];
								
								// do we have to copy the data
								if(exportData && copyLocalExternals) {
									// write data to abspath
									[data writeToFile:abspath atomically:YES];
									// create pathURL
									pathURL = [NSURL fileURLWithPath:abspath];
								}
							} else {
								// we do not load the text data from the remote location
								valueData = [NSMutableString stringWithFormat:@"[%@]",MBLocaleStr(@"RemoteTextData")];
								
								// do we have to copy the data
								if(exportData && copyRemoteExternals) {
									// load valueData from target
									NSData *data = [(MBExtendedTextItemValue *)itemval valueDataByLoadingFromTarget];
									// write data to abspath
									[data writeToFile:abspath atomically:YES];
									
									// if we have loaded the data, we also can show it
									// convert
									valueData = [NSMutableString stringWithString:[MBExtendedTextItemValue convertDataToString:data 
																												  withTextType:[(MBExtendedTextItemValue *)itemval textType]]];
									
									// create pathURL
									pathURL = [NSURL fileURLWithPath:abspath];
								}
							}
						} else  {
							[valueDict setObject:MBLocaleStr(@"Internal") forKey:HTMLItemValueDataLocationStringKey];
							// get data
							valueData = [NSMutableString stringWithString:[(MBExtendedTextItemValue *)itemval valueDataAsString]];
							
							// export?
							if(exportData) {
								// export data
								NSString *exportedPath = @"";
								BOOL success;
								success = [[MBExporter defaultExporter] exportAsNative:itemval 
																				toFile:abspath exportedFile:&exportedPath 
																		  exportedData:nil];
								if(!success) {
									CocoLog(LEVEL_WARN,@"exporter could not export native!");
								} else {
									// create URL path
									pathURL = [NSURL fileURLWithPath:exportedPath];
								}
							} else {
								// for th ecase that we do not export data (printing)
								relpath = @"";
							}
						}
						
						// make a link?
						NSString *linkValue = nil;
						if((isLink & isFileURL & copyLocalExternals) ||
						   (isLink & !isFileURL & copyRemoteExternals) ||
						   (!isLink)) {
							linkValue = relpath;
						} else {
							linkValue = [pathURL absoluteString];
						}
						[valueDict setObject:linkValue forKey:HTMLItemValueDataKey];					
						break;
					}
					case FileItemValueType:
                    case PDFItemValueType:
					{
						valueTypeString = FILE_ITEMVALUE_TYPE_NAME;
						
						// do we have to export the file?
						NSString *abspath = nil;
						NSString *relpath = nil;
						if(exportData) {
							abspath = [self filenameForItem:itemval withPath:fileDir];
							NSArray *pcomps = [abspath pathComponents];
							relpath = [NSString stringWithFormat:@"%@/%@",FilesRelPath,[pcomps objectAtIndex:([pcomps count]-1)]];
						}
						
						// internal, external
						BOOL isLink = [(MBFileItemValue *)itemval isLink];
						BOOL isFileURL = [[(MBFileItemValue *)itemval linkValueAsURL] isFileURL];
						NSURL *pathURL = [(MBFileItemValue *)itemval linkValueAsURL];
						if(isLink)  {
							[valueDict setObject:MBLocaleStr(@"External") forKey:HTMLItemValueDataLocationStringKey];
							if((exportData && isFileURL && copyLocalExternals) ||
							   (exportData && !isFileURL && copyRemoteExternals)) {
								// load valueData from target
								NSData *data = [(MBFileItemValue *)itemval valueDataByLoadingFromTarget];
								// write data to abspath
								[data writeToFile:abspath atomically:YES];
								// create pathURL
								pathURL = [NSURL fileURLWithPath:abspath];
							}
						} else  {
							[valueDict setObject:MBLocaleStr(@"Internal") forKey:HTMLItemValueDataLocationStringKey];
							
							// export?
							if(exportData) {
								// export data
								NSString *exportedPath = @"";
								BOOL success;
								success = [[MBExporter defaultExporter] exportAsNative:itemval 
																				toFile:abspath exportedFile:&exportedPath 
																		  exportedData:nil];
								if(!success) {
									CocoLog(LEVEL_WARN,@"exporter could not export native!");
								} else {
									// create URL path
									pathURL = [NSURL fileURLWithPath:exportedPath];
								}
							} else {
								// for th ecase that we do not export data (printing)
								relpath = @"";
							}
						}
						
						// make a link?
						NSString *linkValue = nil;
						if((isLink & isFileURL & copyLocalExternals) ||
						   (isLink & !isFileURL & copyRemoteExternals) ||
						   (!isLink)) {
							linkValue = relpath;
						} else {
							linkValue = [pathURL absoluteString];
						}
						[valueDict setObject:linkValue forKey:HTMLItemValueDataKey];					
						break;
					}
					case ImageItemValueType:
					{
						valueTypeString = IMAGE_ITEMVALUE_TYPE_NAME;
						
						// do we have to export the file?
						NSString *abspath = nil;
						NSString *relpath = nil;
						if(exportData) {
							abspath = [self filenameForItem:itemval withPath:imageDir];
							NSArray *pcomps = [abspath pathComponents];
							relpath = [NSString stringWithFormat:@"%@/%@",ImagesRelPath,[pcomps objectAtIndex:([pcomps count]-1)]];
						}
						
						// internal, external
						NSURL *pathURL = [(MBImageItemValue *)itemval linkValueAsURL];
						BOOL isLink = [(MBExtendedTextItemValue *)itemval isLink];
						BOOL isFileURL = [[(MBExtendedTextItemValue *)itemval linkValueAsURL] isFileURL];
						if(isLink)  {
							[valueDict setObject:MBLocaleStr(@"External") forKey:HTMLItemValueDataLocationStringKey];
							if((exportData && isFileURL && copyLocalExternals) ||
							   (exportData && !isFileURL && copyRemoteExternals)) {
								// load valueData from target
								NSData *data = [(MBImageItemValue *)itemval valueDataByLoadingFromTarget];
								// write data to abspath
								[data writeToFile:abspath atomically:YES];
								// create pathURL
								pathURL = [NSURL fileURLWithPath:abspath];
							}
						} else  {
							[valueDict setObject:MBLocaleStr(@"Internal") forKey:HTMLItemValueDataLocationStringKey];
							
							// export?
							if(exportData) {
								// export data
								NSString *exportedPath = @"";
								BOOL success;
								success = [[MBExporter defaultExporter] exportAsNative:itemval 
																				toFile:abspath exportedFile:&exportedPath 
																		  exportedData:nil];
								if(!success) {
									CocoLog(LEVEL_WARN,@"exporter could not export native!");
								} else {
									// create URL path
									pathURL = [NSURL fileURLWithPath:exportedPath];
								}
							} else {
								// for th ecase that we do not export data (printing)
								relpath = @"";
							}
						}
						
						// make a link?
						NSString *linkValue = nil;
						if((isLink & isFileURL & copyLocalExternals) ||
						   (isLink & !isFileURL & copyRemoteExternals) ||
						   (!isLink)) {
							linkValue = relpath;
						} else {
							linkValue = [pathURL absoluteString];
						}
						[valueDict setObject:linkValue forKey:HTMLItemValueDataKey];					
						break;
					}
				}
				// set type string
				[valueDict setObject:valueTypeString forKey:HTMLItemValueTypeStringKey];
                
                // set data string
                // make necessary conversations to valueData
                // replace all "\n"s with a <br>
                [valueData replaceOccurrencesOfString:@"\n" 
                                           withString:@"<br>" 
                                              options:0 
                                                range:NSMakeRange(0,[valueData length])];
                // set new line after 70 characters
                int div = [valueData length] / 70;
                for(int i = 0;i < div;i++) {
                    int pos = (i+1) * 70;
                    [valueData insertString:@"<br>" atIndex:pos];
                }                
                // and do html encoding
                valueData = [NSMutableString stringWithString:[MBHTMLGenerator encodeHTMLEntitiesInString:valueData]];
                [valueDict setObject:valueData forKey:HTMLItemValueDataKey];
			}
		}
	}
	
	// if we have a more then one item in our itemDictList, print
	if([itemDictList count] > 0) {
		// get the css file and copy it there, save the path to it
		NSString *cssFilename = @"format.css";
		NSString *cssFile = [NSString pathWithComponents:[NSArray arrayWithObjects:path,cssFilename,nil]];
		// copy the iriginal file to there
		if(![fm copyPath:DEFAULT_CSSFILE_PATH toPath:cssFile handler:nil]) {
			CocoLog(LEVEL_WARN,@"could not copy css file!");
			return nil;	
		}

		// add style sheet path and templates path to options
		[opt setObject:cssFilename forKey:MBHTMLGenStyleSheetPath];
		[opt setObject:HTML_TEMPLATE_FOLDER forKey:MBHTMLGenTemplatesPath];
		
		// set path for main html file
		indexHTML = [NSString pathWithComponents:[NSArray arrayWithObjects:path,@"index.html",nil]];
		
		// we need the htmlstring from htmlGenerator
		NSString *htmlString = [self generateHTMLFromItemDictList:itemDictList withOptions:opt];
		
		// check output
		if((htmlString != nil) && ([htmlString length] > 0)) {
			// write file
			[htmlString writeToFile:indexHTML atomically:YES encoding:NSUTF8StringEncoding error:NULL];
		} else {
			CocoLog(LEVEL_WARN,@"could not create html!");
		}
		
		//[htmlGenerator release];
	}
	
	return indexHTML;
}

- (NSString *)generateHTMLForItemValueList:(NSArray *)itemValueList toOutputDir:(NSString *)path options:(NSDictionary *)options {
	NSString *indexHTML = nil;

	// check for options
	NSMutableDictionary *opt = nil;
	if(options != nil) {
		opt = [NSMutableDictionary dictionaryWithDictionary:options];
	} else {
		opt = [NSMutableDictionary dictionaryWithDictionary:[userDefaults objectForKey:MBDefaultsHTMLExportDefaultsOptionsKey]];
	}
	
	// check, if have a path where we should create the stuff
	if(path == nil) {
		// lets use TMPFOLDER for creating
		path = TMPFOLDER;
	}
	
	NSFileManager *fm = [NSFileManager defaultManager];
	// check, if path exists, otherwise create it
	if(![fm fileExistsAtPath:path]) {
		// create it
		if(![fm createDirectoryAtPath:path attributes:nil]) {
			CocoLog(LEVEL_WARN,@"could not create folder at path: %@!",path);
			return nil;
		}	
	}
	
	// set outputpath to options
	[opt setObject:path forKey:MBHTMLGenExportPath];

	// thumbimage URL
	NSString *thDir = [NSString pathWithComponents:[NSArray arrayWithObjects:path,ThumbsRelPath,nil]];
	// if it doesn't exist, create it
	if(![fm fileExistsAtPath:thDir]) {
		// create it
		if(![fm createDirectoryAtPath:thDir attributes:nil]) {
			CocoLog(LEVEL_WARN,@"could not create folder for thumbs!");
			return nil;
		}	
	}

	// do we export data?
	BOOL exportData = (BOOL)[[opt valueForKey:MBHTMLGenExportData] intValue];
	NSString *fileDir = [NSString pathWithComponents:[NSArray arrayWithObjects:path,FilesRelPath,nil]];
	if(exportData == YES) {
		// create folder for files
		if(![fm fileExistsAtPath:fileDir]) {
			// create it
			if(![fm createDirectoryAtPath:fileDir attributes:nil]) {
				CocoLog(LEVEL_WARN,@"could not create folder for files!");
				return nil;
			}	
		}
		
		// add path to files to options
		[opt setObject:fileDir forKey:MBHTMLGenExportFilesPath];
	}

	// images
	NSString *imageDir = [NSString pathWithComponents:[NSArray arrayWithObjects:path,ImagesRelPath,nil]];
	if(exportData == YES) {
		// create folder for images
		if(![fm fileExistsAtPath:imageDir]) {
			// create it
			if(![fm createDirectoryAtPath:imageDir attributes:nil]) {
				CocoLog(LEVEL_WARN,@"could not create folder for image!");
				return nil;
			}	
		}
		
		// add path to images to options
		[opt setObject:imageDir forKey:MBHTMLGenExportImagesPath];
	}

	// etexts
	NSString *etextsDir = [NSString pathWithComponents:[NSArray arrayWithObjects:path,ETextsRelPath,nil]];
	if(exportData == YES) {
		// create folder for images
		if(![fm fileExistsAtPath:etextsDir]) {
			// create it
			if(![fm createDirectoryAtPath:etextsDir attributes:nil]) {
				CocoLog(LEVEL_WARN,@"could not create folder for etexts!");
				return nil;
			}	
		}
		
		// add path to images to options
		[opt setObject:etextsDir forKey:MBHTMLGenExportETextsPath];
	}
	
	// do we have to copy externals?
	BOOL copyLocalExternals = (BOOL)[[opt valueForKey:MBHTMLGenCopyLocalExternals] intValue];
	BOOL copyRemoteExternals = (BOOL)[[opt valueForKey:MBHTMLGenCopyRemoteExternals] intValue];
	// do we have to make links out of urls?
	//BOOL makeLinkURLs = (BOOL)[[opt valueForKey:MBHTMLGenMakeLinkURLs] intValue];
	// do we have to produce links for items?
	BOOL linkItems = (BOOL)[[opt valueForKey:MBHTMLGenLinkItems] intValue];
	
	// init itemDictList
	NSMutableArray *itemDictList = [NSMutableArray array];
	NSEnumerator *iter = [itemValueList objectEnumerator];
	MBCommonItem *commonItem = nil;
	MBItem *item = nil;
	NSMutableArray *valuesArray = nil;
	NSMutableDictionary *itemDict = nil;
	while((commonItem = [iter nextObject])) {
		// check for reference
		if(([commonItem identifier] == ItemRefID) ||
		   ([commonItem identifier] == ItemValueRefID)) {
			commonItem = [(MBRefItem *)commonItem target];
		}
		
		if(NSLocationInRange([commonItem identifier],ITEMVALUE_ID_RANGE)) {
			MBItemValue *itemval = (MBItemValue *)commonItem;
			// this is done only once
			if((item == nil) || (item != [itemval item])) {
				// init values Array
				valuesArray = [NSMutableArray array];
				
				// get the item first
				item = [itemval item];
				
				// create dict for it
				itemDict = [NSMutableDictionary dictionary];
				// add it to our generator array
				[itemDictList addObject:itemDict];
				NSString *itemString = [item name];
				NSString *itemURL = nil;
				if(linkItems) {
					itemURL = [NSString stringWithFormat:@"Item_%d",[item itemID]];
                    itemURL = [NSString stringWithFormat:@"<a href=\"%@\">%@</a>", itemURL, itemString];
				} else {
					itemURL = itemString;
				}
				[itemDict setObject:[NSNumber numberWithInt:[item identifier]] forKey:HTMLItemIdentifierKey];
				[itemDict setObject:itemString forKey:HTMLItemNameStringKey];
				[itemDict setObject:itemURL forKey:HTMLItemNameURLKey];
				// print self?
				[itemDict setObject:[NSNumber numberWithInt:0] forKey:HTMLItemPrintSelfKey];
				[itemDict setObject:valuesArray forKey:HTMLItemValuesKey];
			}
			
			// create Dict for itemvalue
			NSMutableDictionary *valueDict = [NSMutableDictionary dictionary];
			// add it to the valuesArray
			[valuesArray addObject:valueDict];
			// fill it
			NSString *itemValString = [itemval name];
			NSString *parentString = [[itemval item] name];
			NSString *parentURL = nil;
			NSString *itemValURL = nil;
			if(linkItems) {
				// create references
				itemValURL = [NSString stringWithFormat:@"ItemValue_%d",[itemval itemID]];
                itemValURL = [NSString stringWithFormat:@"<a href=\"%@\">%@</a>", itemValURL, itemValString];
				parentURL = [NSString stringWithFormat:@"Item_%d",[[itemval item] itemID]];
                parentURL = [NSString stringWithFormat:@"<a href=\"%@\">%@</a>", parentURL, parentString];
			} else {
				// no references
				itemValURL = itemValString;
				parentURL = parentString;
			}
			[valueDict setObject:itemValString forKey:HTMLItemValueNameStringKey];
			[valueDict setObject:parentString forKey:HTMLItemNameStringKey];
			[valueDict setObject:itemValURL forKey:HTMLItemValueNameURLKey];
			[valueDict setObject:parentURL forKey:HTMLItemNameURLKey];
			[valueDict setObject:[NSNumber numberWithInt:[itemval identifier]] forKey:HTMLItemIdentifierKey];
			[valueDict setObject:[[itemval dateCreated] description] forKey:HTMLItemValueCreationDateStringKey];
			NSMutableString *valComment = [NSMutableString stringWithString:[itemval comment]];
			// replace all "\n"s with a <br>
			/*
			[valComment replaceOccurrencesOfString:@"\n" 
										withString:@"<br>" 
										   options:0 
											 range:NSMakeRange(0,[valComment length])];
			 */
			[valueDict setObject:valComment forKey:HTMLItemValueCommentStringKey];
			// encrypted state
			if([itemval encryptionState] == EncryptedState) {
				[valueDict setObject:MBLocaleStr(@"Yes") forKey:HTMLItemValueEncryptedStringKey]; 
            } else {
				[valueDict setObject:MBLocaleStr(@"No") forKey:HTMLItemValueEncryptedStringKey];			
			}
			
			// switch for itemtype
			NSString *valueTypeString = nil;
			NSString *valueTypeValString = nil;
            NSMutableString *valueData = [NSMutableString string];
			switch([itemval valuetype]) {				
				case SimpleTextItemValueType:
				{
					valueTypeString = SIMPLETEXT_ITEMVALUE_TYPE_NAME;
					valueTypeValString = @"Text";
					valueData = [NSMutableString stringWithString:[(MBTextItemValue *)itemval valueDataAsString]];
					break;
				}
				case NumberItemValueType:
				{
					valueTypeString = NUMBER_ITEMVALUE_TYPE_NAME;
					valueTypeValString = @"Number";
					valueData = [NSMutableString stringWithString:[(MBNumberItemValue *)itemval valueDataAsString]];
					break;
				}
				case CurrencyItemValueType:
				{
					valueTypeString = CURRENCY_ITEMVALUE_TYPE_NAME;
					valueTypeValString = @"Value";
					valueData = [NSMutableString stringWithString:[(MBNumberItemValue *)itemval valueDataAsString]];
					break;
				}
				case BoolItemValueType:
				{
					valueTypeString = BOOL_ITEMVALUE_TYPE_NAME;
					valueTypeValString = @"Value";
					valueData = [NSMutableString stringWithString:[(MBBoolItemValue *)itemval valueDataAsString]];
					break;
				}
				case DateItemValueType:
				{
					valueTypeString = DATE_ITEMVALUE_TYPE_NAME;
					valueTypeValString = @"Date";
					valueData = [NSMutableString stringWithString:[(MBDateItemValue *)itemval valueDataAsString]];
					break;
				}
				case URLItemValueType:
				{
					valueTypeString = URL_ITEMVALUE_TYPE_NAME;
					valueTypeValString = @"URL";
					valueData = [NSMutableString stringWithString:[(MBURLItemValue *)itemval valueDataAsString]];
					break;
				}
				case ExtendedTextItemValueType:
				{
					valueTypeString = EXTENDEDTEXT_ITEMVALUE_TYPE_NAME;
					valueTypeValString = @"Text";
					NSMutableString *textData = [NSMutableString string];
				
					// do we have to export the file?
					NSString *abspath = nil;
					NSString *relpath = nil;
					if(exportData) {
						abspath = [self filenameForItem:itemval withPath:etextsDir];
						NSArray *pcomps = [abspath pathComponents];
						relpath = [NSString stringWithFormat:@"%@/%@",ETextsRelPath,[pcomps objectAtIndex:([pcomps count]-1)]];
					}
					
					// internal, external
					NSURL *pathURL = [(MBExtendedTextItemValue *)itemval linkValueAsURL];
					BOOL isFileURL = [pathURL isFileURL];
					BOOL isLink = [(MBExtendedTextItemValue *)itemval isLink];
					if(isLink)  {
						[valueDict setObject:MBLocaleStr(@"External") forKey:HTMLItemValueDataLocationStringKey];
						if(isFileURL) {
							// load valueData from target
							NSData *data = [(MBExtendedTextItemValue *)itemval valueDataByLoadingFromTarget];
							// convert
							textData = [NSMutableString stringWithString:[MBExtendedTextItemValue convertDataToString:data 
																										  withTextType:[(MBExtendedTextItemValue *)itemval textType]]];
							
							// do we have to copy the data
							if(exportData && copyLocalExternals) {
								// write data to abspath
								[data writeToFile:abspath atomically:YES];
								// create pathURL
								pathURL = [NSURL fileURLWithPath:abspath];
							}
						} else {
							// we do not load the text data from the remote location
							textData = [NSMutableString stringWithFormat:@"[%@]",MBLocaleStr(@"RemoteTextData")];

							// do we have to copy the data
							if(exportData && copyRemoteExternals) {
								// load valueData from target
								NSData *data = [(MBExtendedTextItemValue *)itemval valueDataByLoadingFromTarget];
								// write data to abspath
								[data writeToFile:abspath atomically:YES];

								// if we have loaded the data, we also can show it
								// convert
								textData = [NSMutableString stringWithString:[MBExtendedTextItemValue convertDataToString:data 
                                                                                                             withTextType:[(MBExtendedTextItemValue *)itemval textType]]];

								// create pathURL
								pathURL = [NSURL fileURLWithPath:abspath];
							}
						}
					} else  {
						[valueDict setObject:MBLocaleStr(@"Internal") forKey:HTMLItemValueDataLocationStringKey];
						// get data
						textData = [NSMutableString stringWithString:[(MBExtendedTextItemValue *)itemval valueDataAsString]];
						
						// export?
						if(exportData) {
							// export data
							NSString *exportedPath = @"";
							BOOL success;
							success = [[MBExporter defaultExporter] exportAsNative:itemval 
																			toFile:abspath exportedFile:&exportedPath 
																	  exportedData:nil];
							if(!success) {
								CocoLog(LEVEL_WARN,@"exporter could not export native!");
							} else {
								// create URL path
								pathURL = [NSURL fileURLWithPath:exportedPath];
							}
						} else {
							// for th ecase that we do not export data (printing)
							relpath = @"";
						}
					}
					
					// make a link?
					NSString *linkValue = nil;
					if((isLink & isFileURL & copyLocalExternals) ||
					   (isLink & !isFileURL & copyRemoteExternals) ||
					   (!isLink)) {
						linkValue = relpath;
					} else {
						linkValue = [pathURL absoluteString];						
					}
					[valueDict setObject:linkValue forKey:HTMLItemValueLocationURLStringKey];
					
					NSString *eTextValueTextTypeString = nil;
					switch([(MBExtendedTextItemValue *)itemval textType]) {
						case TextTypeTXT:
						{
							eTextValueTextTypeString = @"TXT";
							break;
						}
						case TextTypeRTF:
						{
							eTextValueTextTypeString = @"RTF";
							break;
						}
						case TextTypeRTFD:
						{
							eTextValueTextTypeString = @"RTFD";
							break;
						}
					}

					// replace all "\n"s with a <br>
					[textData replaceOccurrencesOfString:@"\n" 
                                              withString:@"<br>" 
                                                 options:0 
                                                   range:NSMakeRange(0,[textData length])];
                    // and do html encoding
                    textData = [NSMutableString stringWithString:[MBHTMLGenerator encodeHTMLEntitiesInString:textData]];
					[valueDict setObject:textData forKey:HTMLETextValuePreviewDataKey];
					[valueDict setObject:eTextValueTextTypeString forKey:HTMLETextValueTextTypeStringKey];					
					break;
				}
				case FileItemValueType:
				case PDFItemValueType:
				{
					valueTypeString = FILE_ITEMVALUE_TYPE_NAME;
					valueTypeValString = @"File";
					
                    if([itemval valuetype] == PDFItemValueType) {
                        valueTypeString = PDF_ITEMVALUE_TYPE_NAME;
                        valueTypeValString = @"PDF";                        
                    }
                    
					// do we have to export the file?
					NSString *abspath = nil;
					NSString *relpath = nil;
					if(exportData) {
						abspath = [self filenameForItem:itemval withPath:fileDir];
						NSArray *pcomps = [abspath pathComponents];
						relpath = [NSString stringWithFormat:@"%@/%@",FilesRelPath,[pcomps objectAtIndex:([pcomps count]-1)]];
					}
					
					// internal, external
					NSURL *pathURL = [(MBFileItemValue *)itemval linkValueAsURL];
					BOOL isFileURL = [pathURL isFileURL];
					BOOL isLink = [(MBExtendedTextItemValue *)itemval isLink];
					if(isLink) {
						[valueDict setObject:MBLocaleStr(@"External") forKey:HTMLItemValueDataLocationStringKey];
						if((exportData && isFileURL && copyLocalExternals) ||
						   (exportData && !isFileURL && copyRemoteExternals)) {
							// load valueData from target
							NSData *data = [(MBFileItemValue *)itemval valueDataByLoadingFromTarget];
							// write data to abspath
							[data writeToFile:abspath atomically:YES];
							// create pathURL
							pathURL = [NSURL fileURLWithPath:abspath];
						}
					} else  {
						[valueDict setObject:MBLocaleStr(@"Internal") forKey:HTMLItemValueDataLocationStringKey];
						
						// export?
						if(exportData) {
							// export data
							NSString *exportedPath = @"";
							BOOL success;
							success = [[MBExporter defaultExporter] exportAsNative:itemval 
																			toFile:abspath exportedFile:&exportedPath 
																	  exportedData:nil];
							if(!success) {
								CocoLog(LEVEL_WARN,@"exporter could not export native!");
							} else {
								// create URL path
								pathURL = [NSURL fileURLWithPath:exportedPath];
							}
						} else {
							// for th ecase that we do not export data (printing)
							relpath = @"";
						}
					}
					
					// make a link?
					NSString *linkValue = nil;
					if((isLink & isFileURL & copyLocalExternals) ||
					   (isLink & !isFileURL & copyRemoteExternals) ||
					   (!isLink)) {
						linkValue = relpath;
					} else {
						linkValue = [pathURL absoluteString];						
					}
					[valueDict setObject:linkValue forKey:HTMLItemValueLocationURLStringKey];

					// encode filetype string
					NSString *fileType = [[(MBFileItemValue *)itemval linkValueAsString] pathExtension];
					[valueDict setObject:fileType forKey:HTMLFileValueTypeStringKey];					
					
					// encode filesize, get file attributes
					NSDictionary *fileAttribs = [(MBFileItemValue *)itemval fileAttributesDict];
					// get filesize from attributes
					int kbFileSize = [[fileAttribs valueForKey:NSFileSize] intValue] / 1024;
					[valueDict setObject:[NSString stringWithFormat:@"%d", kbFileSize] forKey:HTMLFileValueSizeStringKey];
					
					// get file type icon
					NSImage *fileTypeImage = [[NSWorkspace sharedWorkspace] iconForFileType:fileType];
					// get Bytes of tiff representation
					NSData *imageBytes = [fileTypeImage TIFFRepresentation];
					if(imageBytes != nil) {
						int idNum = [(MBFileItemValue *)itemval itemID];
						NSString *filenameString = [NSString stringWithFormat:@"%d.tif",idNum];
						// create path
						NSString *thPath = [NSString pathWithComponents:[NSArray arrayWithObjects:thDir,filenameString,nil]];
						// write
						[imageBytes writeToFile:thPath atomically:YES];
						// encode url
						[valueDict setObject:[NSString stringWithFormat:@"%@/%@",ThumbsRelPath,filenameString] 
									  forKey:HTMLFileValueTypeIconURLKey];						
					}
					
					break;
				}
				case ImageItemValueType:
				{
					valueTypeString = IMAGE_ITEMVALUE_TYPE_NAME;
					valueTypeValString = @"Image";
					
					// do we have to export the file?
					NSString *abspath = nil;
					NSString *relpath = nil;
					if(exportData) {
						abspath = [self filenameForItem:itemval withPath:imageDir];
						NSArray *pcomps = [abspath pathComponents];
						relpath = [NSString stringWithFormat:@"%@/%@",ImagesRelPath,[pcomps objectAtIndex:([pcomps count]-1)]];
					}
					
					// internal, external
					NSURL *pathURL = [(MBImageItemValue *)itemval linkValueAsURL];
					BOOL isFileURL = [pathURL isFileURL];
					BOOL isLink = [(MBExtendedTextItemValue *)itemval isLink];
					if(isLink)  {
						[valueDict setObject:MBLocaleStr(@"External") forKey:HTMLItemValueDataLocationStringKey];
						if((exportData && isFileURL && copyLocalExternals) ||
						   (exportData && !isFileURL && copyRemoteExternals)) {
							// load valueData from target
							NSData *data = [(MBImageItemValue *)itemval valueDataByLoadingFromTarget];
							// write data to abspath
							[data writeToFile:abspath atomically:YES];
							// create pathURL
							pathURL = [NSURL fileURLWithPath:abspath];
						}
					} else  {
						[valueDict setObject:MBLocaleStr(@"Internal") forKey:HTMLItemValueDataLocationStringKey];
						
						// export?
						if(exportData) {
							// export data
							NSString *exportedPath = @"";
							BOOL success;
							success = [[MBExporter defaultExporter] exportAsNative:itemval 
																			toFile:abspath exportedFile:&exportedPath 
																	  exportedData:nil];
							if(!success) {
								CocoLog(LEVEL_WARN,@"exporter could not export native!");
							} else {
								// create URL path
								pathURL = [NSURL fileURLWithPath:exportedPath];
							}
						} else {
							// for th ecase that we do not export data (printing)
							relpath = @"";
						}
					}
					
					// make a link?
					NSString *linkValue = nil;
					if((isLink & isFileURL & copyLocalExternals) ||
					   (isLink & !isFileURL & copyRemoteExternals) ||
					   (!isLink)) {
						linkValue = relpath;
					} else {
						linkValue = [pathURL absoluteString];						
					}
					[valueDict setObject:linkValue forKey:HTMLItemValueLocationURLStringKey];
					
					// image type
					[valueDict setObject:[(MBImageItemValue *)itemval imageType] forKey:HTMLImageValueTypeStringKey];			
					// dimensions
					NSSize imgSize = [(MBImageItemValue *)itemval imageSize];
					[valueDict setObject:[NSString stringWithFormat:@"%d x %d",(int)imgSize.width,(int)imgSize.height]
								  forKey:HTMLImageValueDimensionStringKey];
					// image byte size
					unsigned int kbytes = [(MBImageItemValue *)itemval imageByteSize] / 1024;
					[valueDict setObject:[NSString stringWithFormat:@"%d",kbytes] forKey:HTMLImageValueSizeStringKey];			
					
					// do we have encrypted data?
					if([itemval encryptionState] == DecryptedState) {
						// get itemvalue id
						int idNum = [(MBImageItemValue *)itemval itemID];
						NSString *filenameString = [NSString stringWithFormat:@"%d.%@",idNum,[(MBImageItemValue *)itemval imageType]];
						// create path
						NSString *thPath = [NSString pathWithComponents:[NSArray arrayWithObjects:thDir,filenameString,nil]];
						// make url
						NSURL *url = [NSURL fileURLWithPath:thPath];
						// get thumbdata and write
						NSData *thData = [(MBImageItemValue *)itemval thumbData];
						// write
						[thData writeToURL:url atomically:YES];
						// encode url
						[valueDict setObject:[NSString stringWithFormat:@"%@/%@",ThumbsRelPath,filenameString] 
									  forKey:HRMLImagePreviewURLKey];
					}
					
					break;
				}
			}
			
			[valueDict setObject:valueTypeString forKey:HTMLItemValueTypeStringKey];
			[valueDict setObject:valueTypeValString forKey:HTMLItemValueTypeValStringKey];
			
            
            // replace all "\n"s with a <br>
            [valueData replaceOccurrencesOfString:@"\n" 
                                       withString:@"<br>" 
                                          options:0 
                                            range:NSMakeRange(0,[valueData length])];
            // set new line after 70 characters
            int div = [valueData length] / 70;
            for(int i = 0;i < div;i++) {
                int pos = (i+1) * 70;
                [valueData insertString:@"<br>" atIndex:pos];
            }
            // and do html encoding
            valueData = [NSMutableString stringWithString:[MBHTMLGenerator encodeHTMLEntitiesInString:valueData]];
            [valueDict setObject:valueData forKey:HTMLItemValueDataKey];			
            
		} else {
			// create new values array, the old is retained by dict, at least it should be
			valuesArray = [NSMutableArray array];
			
			// this is our new item
			item = (MBItem *)commonItem;
			
			// create new item dict
			itemDict = [NSMutableDictionary dictionary];
			// add it to our print array
			[itemDictList addObject:itemDict];
			NSString *itemString = nil;
			NSString *itemURL = nil;
			if(linkItems) {
				itemURL = [NSString stringWithFormat:@"Item_%d",[item itemID]];
                itemURL = [NSString stringWithFormat:@"<a href=\"%@\">%@</a>", itemURL, itemString];
			} else {
				itemURL = itemString;
			}
			[itemDict setObject:[NSNumber numberWithInt:[item identifier]] forKey:HTMLItemIdentifierKey];
			[itemDict setObject:itemString forKey:HTMLItemNameStringKey];
			[itemDict setObject:itemURL forKey:HTMLItemNameURLKey];
			// print self?
			[itemDict setObject:[NSNumber numberWithInt:0] forKey:HTMLItemPrintSelfKey];
			[itemDict setObject:valuesArray forKey:HTMLItemValuesKey];			
		}
	}
	
	// if we have a more then one item in our itemDictList, print
	if([itemDictList count] > 0) {
		// get the css file and copy it there, save the path to it
		NSString *cssFilename = @"format.css";
		NSString *cssFile = [NSString pathWithComponents:[NSArray arrayWithObjects:path,cssFilename,nil]];
		// copy the iriginal file to there
		if(![fm copyPath:DEFAULT_CSSFILE_PATH toPath:cssFile handler:nil]) {
			CocoLog(LEVEL_WARN,@"could not copy css file!");
			return nil;	
		}
		// add style sheet path and templates path to options
		[opt setObject:cssFilename forKey:MBHTMLGenStyleSheetPath];
		[opt setObject:HTML_TEMPLATE_FOLDER forKey:MBHTMLGenTemplatesPath];
		
		// set path for main html file
		indexHTML = [NSString pathWithComponents:[NSArray arrayWithObjects:path,@"index.html",nil]];
		
		// we need the htmlstring from htmlGenerator
		NSString *htmlString = [self generateHTMLFromItemValueDictList:itemDictList withOptions:opt];
		
		// check output
		if((htmlString != nil) && ([htmlString length] > 0)) {
			// write file
			[htmlString writeToFile:indexHTML atomically:YES encoding:NSUTF8StringEncoding error:NULL];
		} else {
			CocoLog(LEVEL_WARN,@"could not create html!");
		}
	}
	
	return indexHTML;
}

@end
