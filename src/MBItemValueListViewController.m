// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import "MBItemValueListViewController.h"
#import "MBItemBaseController.h"
#import "MBItemValueListTableView.h"
#import "globals.h"
#import "MBItem.h"
#import "MBSearchController.h"
#import "MBSearchResult.h"
#import "MBRefItem.h"
#import "CombinedImageTextCell.h"
#import "MBPasteboardType.h"
#import "MBInterfaceController.h"
#import "MBExporter.h"
#import "MBExtendedTextItemValue.h"
#import "MBURLItemValue.h"
#import "MBImporter.h"
#import "MBImExportPrefsViewController.h"
#import "MBTextItemValue.h"
#import "MBPDFItemValue.h"
#import "MBImageItemValue.h"
#import "MBStdItem.h"
#import "MBNumberItemValue.h"
#import "MBBoolItemValue.h"
#import "MBDateItemValue.h"
#import "MBCurrencyItemValue.h"
#import "MBFormatPrefsViewController.h"

// column identifiers
#define COL_IDENTIFIER_ITEMVALUE_SORTORDER	@"sortorder"
#define COL_IDENTIFIER_ITEMVALUE_NAME		@"name"
#define COL_IDENTIFIER_ITEMVALUE_VALUE		@"valuedata"
#define COL_IDENTIFIER_ITEMVALUE_VALUETYPE	@"valuetype"

@interface MBItemValueListViewController (privateAPI)

- (int)deliverNumberOfItemsOfSelectionData:(NSArray *)selection forSubLevel:(int)aLevel;
- (NSArray *)deliverDisplayData:(NSArray *)itemSelection;
- (void)figureAndDisplayTableData;
- (void)setCurrentSelection:(NSArray *)selection;
- (void)setSearchString:(NSString *)aString;

@end

//--------------------------------------------------------------------
//----------- private API ---------------------
//--------------------------------------------------------------------
@implementation MBItemValueListViewController (privateAPI)

- (void)setCurrentSelection:(NSArray *)selection {
	if(selection != currentSelection) {
		[selection retain];
		[currentSelection release];
		currentSelection = selection;
	}
}

- (void)figureAndDisplayTableData {
	// get selected items from ibc and create new array
	NSArray *selectedItems = [itemController currentItemSelection];
	// generate new data array for displaying including the current search word
	[self setCurrentData:[self deliverDisplayData:selectedItems]];
	
	// reload complete table view
	[itemValueTableView reloadData];
	
	// set result label
	NSString *resultString = [NSString stringWithFormat:MBLocaleStr(@"DisplayingXValuesOutOfY"),
		[currentData count],
		[self deliverNumberOfItemsOfSelectionData:selectedItems forSubLevel:0]];
	[resultLabel setStringValue:resultString];
}

- (int)deliverNumberOfItemsOfSelectionData:(NSArray *)itemSelection forSubLevel:(int)aLevel {
	int ret = 0;
	
	// add number of items in first level
	ret = ret + [itemSelection count];
	if(ret > 0) {
		MBItem *item = nil;
		NSEnumerator *iter = [itemSelection objectEnumerator];
		while((item = [iter nextObject])) {
			// check for reference
			if([item identifier] == ItemRefID) {
				item = (MBItem *)[(MBRefItem *)item target];
			}
			if(item != nil) {
				ret = ret + [[item itemValues] count];
			}
		}
	}
	
	return ret;
}

/**
\brief this method delivers a new NSArray for displaying in the tableview recognizing the current search string
 */
- (NSArray *)deliverDisplayData:(NSArray *)itemSelection {
	// the return array
	NSMutableArray *array = [NSMutableArray array];
	
	// we need a searcher instance
	MBSearchController *sc = [[[MBSearchController alloc] init] autorelease];
	// allow all types
	[sc setSearchForItems:[sc allSearchForItems]];
	
	if([itemSelection count] > 0) {
		NSEnumerator *iter = [itemSelection objectEnumerator];
		MBItem *buf = nil;
		while((buf = [iter nextObject])) {
			// create a special dict for itemvalues
			NSMutableArray *valArr = [NSMutableArray array];
			
			// have a look if we are searching
			if([searchString length] > 0) {
				NSMutableDictionary *valDict = [NSMutableDictionary dictionary];

				[sc searchInCommonItemArray:[buf itemValues] 
								  forString:searchString 
								  recursive:NO 
							 searchExternal:NO 
							  caseSensitive:NO 
							 fileDataSearch:NO 
									 result:&valDict];
				
				NSEnumerator *iter = [[valDict allValues] objectEnumerator];
				MBSearchResult *sr = nil;
				while((sr = [iter nextObject])) {
					[valArr addObject:[sr commonItem]];
				}
			} else {
				// add itemfirst
				[array addObject:buf];
				
				// is a ref?
				if([buf identifier] == ItemRefID) {
					buf = (MBItem *)[(MBRefItem *)buf target];
				}
				
				// target is nil, not allowed
				if(buf != nil) {
					NSEnumerator *valueIter = [[buf itemValues] objectEnumerator];
					MBItemValue *val = nil;
					while((val = [valueIter nextObject])) {
						[valArr addObject:val];				
					}
				}
			}
			
			// add the item itself, if value array it larger than 0
			if([valArr count] > 0) {
				// add values
				[array addObjectsFromArray:valArr];
			}			
		}
	}

	return array;
}

- (void)setSearchString:(NSString *)aString {
    [aString retain];
    [searchString release];
    searchString = aString;
}

@end

@implementation MBItemValueListViewController

- (id)init {
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"cannot alloc MBItemValueListViewController!");		
	} else {
		// nil mouseDownEvent
		mouseDownEvent = nil;
		
		// this is set to YES if app is terminating
		appTerminating = NO;

		// init searchString and array
        [self setSearchString:@""];
		[self setCurrentData:[NSArray array]];
		[self setCurrentSelection:[NSArray array]];

        // load images
        internalDataImage = [[NSImage imageNamed:@"internal_16.png"] retain];
        externalDataImage = [[NSImage imageNamed:@"external_16.png"] retain];
        encryptedDataImage = [[NSImage imageNamed:@"encrypted_16.png"] retain];

		// create Dictionary with attributes
		// we need red color
		NSMutableDictionary *attribDict = [NSMutableDictionary dictionary];
		[attribDict setObject:[NSColor redColor] forKey:NSForegroundColorAttributeName];
		encryptedDataString = [[NSAttributedString alloc] initWithString:MBLocaleStr(@"Encrypted") 
															  attributes:attribDict];
		
		// TODO --- dateFormatters do not have a setFormat method
		// for changing te format, a new dtaeFormatter must be created
		// TODO --- check for Tiger version, there a -setDateFormat: method is available
		// create dateFormatter
		//dateFormatter = [[NSDateFormatter alloc] initWithDateFormat:[defaults objectForKey:MBDefaultsDateFormatKey] 
		//									   allowNaturalLanguage:YES];
	}
	
	return self;
}

/**
\brief dealloc of this class is called on closing this document
 */
- (void)dealloc {
	// release formatters
	[numberFormatter release];
	[currencyFormatter release];
	//[dateFormatter release];
	
	// release currenbt data
    [self setSearchString:nil];
	[self setCurrentData:nil];
	[self setCurrentSelection:nil];
	
    [internalDataImage release];
    [externalDataImage release];
    [encryptedDataImage release];    
        
	// release attribString for encrypted data
	[encryptedDataString release];
	
	// dealloc object
	[super dealloc];
}

//--------------------------------------------------------------------
//----------- bundle delegates ---------------------------------------
//--------------------------------------------------------------------
/**
\brief gets called ig the nib file has been loaded. all gfx objacts are available now.
 */
- (void)awakeFromNib {
		
    // insert CombinedImageTextCell for the one tablecolumn
    NSTableColumn *tableColumn = [itemValueTableView tableColumnWithIdentifier:COL_IDENTIFIER_ITEMVALUE_VALUE];
    CombinedImageTextCell *imageTextCell = [[[CombinedImageTextCell alloc] init] autorelease];
    [imageTextCell setEditable:YES];
    if([imageTextCell respondsToSelector:@selector(setTruncatesLastVisibleLine:)]) {
        [imageTextCell setTruncatesLastVisibleLine:YES];
    }
    [tableColumn setDataCell:imageTextCell];
        
    // create menus
    [self createNormalItemMenu];
    // set default menu
    [itemValueTableView setMenu:normalItemMenu];
    
    // calculate the collapse space
    collapseHeight = [theView frame].size.height - [itemValueTableView frame].size.height;
    
    // send the current sortdescriptors to itemController
    [itemController setItemValueListSortDescriptors:[itemValueTableView sortDescriptors]];
    
    // register for drag and drop
    [itemValueTableView registerForDraggedTypes:[self validDragAndDropPbTypes]];
    
    // register notification
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(appWillTerminate:)
                                                 name:MBAppWillTerminateNotification object:nil];		
    // register notification 
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(appInitialized:)
                                                 name:MBAppInitializedNotification object:nil];				
    // register notification
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(itemValueAttribsChanged:)
                                                 name:MBItemValueAttribsChangedNotification object:nil];
    // register notification
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(itemValueListChanged:)
                                                 name:MBItemValueListChangedNotification object:nil];
    // register notification
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(itemValueSelectionChanged:)
                                                 name:MBItemValueSelectionShouldChangeInTableViewNotification object:nil];
    // register notification
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(itemValueAdded:)
                                                 name:MBItemValueAddedNotification object:nil];
    // register notification
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(reloadTableView:)
                                                 name:MBItemSelectionChangedNotification object:nil];
    // register notification
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(menuChanged:)
                                                 name:MBMenuChangedNotification object:nil];
}

/**
 \brief return the view, which is the main component
*/
- (NSView *)theView {
	return theView;
}

/**
 \brief return the table view itself to compare for first responder
*/
- (NSTableView *)tableView {
	return itemValueTableView;
}

/**
 \brief the space in px where the view should collapse
*/
- (float)collapseHeight {
	return collapseHeight;
}

- (NSArray *)validDragAndDropPbTypes {
	return [NSArray arrayWithObjects:
		//IKAM_PB_TYPE_NAME,
        ITEMVALUE_PB_TYPE_NAME,
		COMMON_ITEM_PB_TYPE_NAME,
		NSFilenamesPboardType,
		NSFilesPromisePboardType,
		NSURLPboardType,
		NSStringPboardType,
		NSRTFPboardType,
		NSRTFDPboardType,
		nil];
}

/**
 \brief this method tales the mousedown event from tableview and uses it for providing it with
 dragPromisedFilesOfTypes: method
*/
- (void)setMouseDownEvent:(NSEvent *)theEvent {
	mouseDownEvent = theEvent;
}

- (NSEvent *)mouseDownEvent {
	return mouseDownEvent;
}

/**
 \brief set the data to be displayed in the tableview
 The array can consist of MBItems and MBItemValues
*/
- (void)setCurrentData:(NSArray *)array {
	[array retain];
	[currentData release];
	currentData = array;
}

- (NSArray *)currentData {
	return currentData;
}

- (NSArray *)currentSelection {
	return currentSelection;
}

/**
 \brief return the tableviews current sortdescriptors
*/
- (NSArray *)currentSortDescriptors {
	return [itemValueTableView sortDescriptors];
}

// searching
- (void)applySearchString:(NSString *)aString {
	[self setSearchString:aString];
	[self figureAndDisplayTableData];
}

#pragma mark - NSTableView delegates

/*
- (NSArray *)namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropDestination
{ 
	CocoLog(LEVEL_DEBUG,@"namesOfPromisedFilesDroppedAtDestination...!");
	CocoLog(LEVEL_DEBUG,@"dropDestination: %@",[dropDestination absoluteString]);
	
	NSMutableArray *promisedNames = [NSMutableArray array];
	
	// with drag and promising filenames we try to export native types
	MBExporter *exporter = [MBExporter defaultExporter];
	
	// there must be items in draggingList
	NSArray *valList = [itemController draggingItems];
	NSEnumerator *iter = [valList objectEnumerator];
	MBItemValue *itemval = nil;
	while((itemval = [iter nextObject]))
	{
		// guess filename
		NSString *name = [exporter guessFilenameFor:itemval];
		CocoLog(LEVEL_DEBUG,@"name: %@",name);
		NSString *extension = [exporter guessFileExtensionFor:itemval];
		CocoLog(LEVEL_DEBUG,@"extension: %@",extension);
		NSString *filename = [exporter generateFilenameWithExtension:extension 
														fromFilename:name];
		
		// add filename to array
		[promisedNames addObject:filename];
		
		// get URL, extract relativePath component and add filename, then export
		NSString *exportName = [[dropDestination relativePath] stringByAppendingPathComponent:filename];
		NSURL *url = [NSURL fileURLWithPath:exportName];
		CocoLog(LEVEL_DEBUG,[url absoluteString]);
		CocoLog(LEVEL_DEBUG,@"exporting to %@",exportName);
		[exporter exportAsNative:itemval toFile:exportName];
	}
	
	return promisedNames;
}
*/

/**
 \brief write dragging items to pasteboard
*/
- (BOOL)tableView:(NSTableView *)tableView writeRows:(NSArray *)rows toPasteboard:(NSPasteboard *)pboard {

	// copy items
	NSMutableArray *valList = [NSMutableArray arrayWithCapacity:[rows count]];
	NSEnumerator *iter = [rows objectEnumerator];
	NSNumber *row = nil;
	while((row = [iter nextObject])) {
		[valList addObject:[[self currentData] objectAtIndex:[row intValue]]];
	}
	
	[uiController setDraggingItems:valList];	// lazy copy
	
    // init drag types and promised files
	NSMutableDictionary *dragTypes = [NSMutableDictionary dictionary];
	NSMutableDictionary *promisedFileTypes = [NSMutableDictionary dictionary];

	if([valList count] > 0) {
		// get a exporter
		MBExporter *exporter = [MBExporter defaultExporter];
		
		// export these types first
		[dragTypes setObject:[NSNull null] forKey:COMMON_ITEM_PB_TYPE_NAME];
		[dragTypes setObject:[NSNull null] forKey:ITEMVALUE_PB_TYPE_NAME];
		[dragTypes setObject:[NSNull null] forKey:NSFilesPromisePboardType];
		
		NSEnumerator *iter = [valList objectEnumerator];
		MBItemValue *itemval = nil;
		while((itemval = [iter nextObject])) {
			// check for reference. references will be dragged as IKAM_PB_TYPE
			if([itemval identifier] == ItemValueRefID) {
				CocoLog(LEVEL_DEBUG,@"drag references as ikam only");
				// string pbtype
				[dragTypes setObject:@"IOU" forKey:IKAM_PB_TYPE_NAME];
				// promised file
				[promisedFileTypes setObject:[NSNull null] forKey:EXPORT_IKAMARCHIVE_TYPESTRING];
			} else {
				// for these types we can drag other types
				switch([itemval valuetype]) {
					case NumberItemValueType:
					case CurrencyItemValueType:
					case BoolItemValueType:
					case DateItemValueType:
					case ItemValueRefType:
					{
						CocoLog(LEVEL_DEBUG,@"ikam export type for simple types that cannot be exported natively");

						// string pbtype
						[dragTypes setObject:@"IOU" forKey:IKAM_PB_TYPE_NAME];
						// promised file
						[promisedFileTypes setObject:[NSNull null] forKey:EXPORT_IKAMARCHIVE_TYPESTRING];
                        break;
					}
					case SimpleTextItemValueType:
					{
						CocoLog(LEVEL_DEBUG,@"simpleTextItemValuetype drag");

						// string pbtype
						[dragTypes setObject:@"IOU" forKey:NSStringPboardType];
						// promised file
						[promisedFileTypes setObject:[NSNull null] forKey:@"txt"];						
                        break;
					}
					case ExtendedTextItemValueType:
					{
						CocoLog(LEVEL_DEBUG,@"extendedTextItemValuetype drag");
						MBExtendedTextItemValue *val = (MBExtendedTextItemValue *)itemval;
						NSString *extension = nil;
						switch([val textType]) {
							case TextTypeTXT:
							{
								// string pbtype
								[dragTypes setObject:@"IOU" forKey:NSStringPboardType];
								// set extension
								extension = @"txt";
								break;
							}
							case TextTypeRTF:
							{
								// rtf pbtype
								[dragTypes setObject:@"IOU" forKey:NSRTFPboardType];
								// set extension
								extension = @"rtf";
								break;
							}
							case TextTypeRTFD:
							{
								// rtfd pbtype
								[dragTypes setObject:@"IOU" forKey:NSRTFDPboardType];
								// set extension
								extension = @"rtfd";
								break;
							}
						}
						
						// if this is a link, we can provide the path as Filename and URL as well
						if([val isLink]) {
							NSURL *url = [val linkValueAsURL];
							if(url != nil) {
								// URL
								[dragTypes setObject:@"IOU" forKey:NSURLPboardType];								
								// if this is a local url
								if([url isFileURL]) {
									// file
									//[dragTypes addObject:NSFilenamesPboardType];
									//[pboard setPropertyList:[NSArray arrayWithObject:[url relativePath]] forType:NSFilenamesPboardType];
								}
							}					
						}				
						
						// promised file
						[promisedFileTypes setObject:[NSNull null] forKey:extension];
						break;
					}
					case URLItemValueType:
					{
						CocoLog(LEVEL_DEBUG,@"urlTextItemValuetype drag");
						MBURLItemValue *val = (MBURLItemValue *)itemval;
						// url
						[dragTypes setObject:@"IOU" forKey:NSURLPboardType];
						NSURL *url = [val valueData];
						if(url != nil) {
							[url writeToPasteboard:pboard];
						} else {
							CocoLog(LEVEL_DEBUG,@"[MBItemValueListTableViewController -tableView:writeRows:toPasteboard:] have a nil url!");				
						}
						
						// promised file
						if([url isFileURL]) {
							[promisedFileTypes setObject:[NSNull null] forKey:@"fileloc"];						
						} else {
							[promisedFileTypes setObject:[NSNull null] forKey:@"webloc"];
						}
						break;
					}
					case FileItemValueType:
					case ImageItemValueType:
                    case PDFItemValueType:
					{
						CocoLog(LEVEL_DEBUG,@"File base ItemValuetype drag");
						MBFileItemValue *val = (MBFileItemValue *)itemval;
						
						// if this is a link, we can provide the path as Filename and URL as well
						if([val isLink]) {
							NSURL *url = [val linkValueAsURL];
							if(url != nil) {
								// URL
								[dragTypes setObject:@"IOU" forKey:NSURLPboardType];								
								// if this is a local url
								if([url isFileURL]) {
									// file
									//[dragTypes addObject:NSFilenamesPboardType];
									//[pboard setPropertyList:[NSArray arrayWithObject:[url relativePath]] forType:NSFilenamesPboardType];
								}
							}					
						}
                        
                        // additional stuff
                        NSString *extension = [exporter guessFileExtensionFor:itemval];
                        if([itemval valuetype] == ImageItemValueType) {
                            [dragTypes setObject:@"IOU" forKey:NSTIFFPboardType];                        
                        } else if([itemval valuetype] == FileItemValueType) {
                            if([extension isEqualToString:@"pdf"]) {
                                // pdf
                                [dragTypes setObject:@"IOU" forKey:NSPDFPboardType];
                            }                            
                        } else if([itemval valuetype] == PDFItemValueType) {
                            [dragTypes setObject:@"IOU" forKey:NSPDFPboardType];                        
                        }
                        
						// promised file
						[promisedFileTypes setObject:[NSNull null] forKey:extension];
						break;
					}
					default:
						// do nothing
						break;
				}
			}
		}
        
        // declare types
        [pboard declareTypes:[dragTypes allKeys] owner:self];
        [pboard setPropertyList:[promisedFileTypes allKeys] forType:NSFilesPromisePboardType];
        
        // set pasteboard values
        iter = [[dragTypes allKeys] objectEnumerator];
        id key = nil;
        while((key = [iter nextObject])) {
            id val = [dragTypes objectForKey:key];
            if([val isKindOfClass:[NSString class]]) {
                [pboard setString:val forType:key];
            } else if([val isKindOfClass:[NSData class]]) {
                [pboard setData:val forType:key];
            }
        }

        // set data, for internal usage this is more than enough
		[pboard setData:[NSData data] forType:COMMON_ITEM_PB_TYPE_NAME];
		[pboard setData:[NSData data] forType:ITEMVALUE_PB_TYPE_NAME];
	}
	
	return YES;	
}

/* To be used under Tiger and above
- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard
{

}
*/
/**
 \brief validate dragging items on destination
*/
- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)operation {
	NSPasteboard *pb = [info draggingPasteboard];
	// get pb type
	NSString *type = [pb availableTypeFromArray:[self validDragAndDropPbTypes]];

	// we don't accept unknown types
	if(type == nil) {
		return NSDragOperationNone;
	} else if([type isEqualToString:ITEMVALUE_PB_TYPE_NAME] && ([info draggingSource] == tableView)) {
        return NSDragOperationMove;
    } else if([type isEqualToString:COMMON_ITEM_PB_TYPE_NAME]) {
        // dropping items here is not allowed
		return NSDragOperationNone;
	} else if([info draggingSource] == tableView) {
        // we do not accept drops from the same source
		return NSDragOperationNone;
	}
	
	return [info draggingSourceOperationMask];	
}

/**
 \brief accept drop?
 the priority of the import type in determined by the type order in the array that defines the accepted types
 here:[self validDragAndDropPbTypes]
*/
- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)operation {
	CocoLog(LEVEL_DEBUG,@"tableView:acceptDrop:row:dropOperation:");
	
	MBItem *dest = [itemController creationDestinationWithWarningPanel:YES];
	if(dest == nil) {
		return NO;	
	} else {
		// init importer
		MBImporter *importer = [MBImporter defaultImporter];
		
		NSPasteboard *pb = [info draggingPasteboard];
		// get pb type
		NSString *type = [pb availableTypeFromArray:[self validDragAndDropPbTypes]];
		CocoLog(LEVEL_DEBUG, @"%@", type);
		CocoLog(LEVEL_DEBUG, @"%@", [pb stringForType:type]);
		
		if([type isEqualToString:COMMON_ITEM_PB_TYPE_NAME]) {
			// this is not allowed
		} else if([type isEqualToString:ITEMVALUE_PB_TYPE_NAME]) {
			// TODO: implement
		} else if([type isEqualToString:NSFilenamesPboardType]) {
			// get array of Filenames
			NSArray *filenames = [pb propertyListForType:type];
			NSEnumerator *iter = [filenames objectEnumerator];
			NSString *file = nil;
			while((file = [iter nextObject])) {
				CocoLog(LEVEL_DEBUG, @"%@", file);
			}
			
			// import
			[importer fileValueImport:filenames toItem:dest];
		} else if([type isEqualToString:NSFilesPromisePboardType]) {
			CocoLog(LEVEL_DEBUG, @"%@", [pb stringForType:type]);
			
			NSString *tmpFolder = TMPFOLDER;
			
			NSArray *files = [info namesOfPromisedFilesDroppedAtDestination:[NSURL fileURLWithPath:tmpFolder]];
			// build filenames
			NSMutableArray *filenames = [NSMutableArray arrayWithCapacity:[files count]];
			NSEnumerator *iter = [files objectEnumerator];
			NSString *filename = nil;
			while((filename = [iter nextObject])) {
				// build complete filename
				NSString *absolute = [NSString pathWithComponents:[NSArray arrayWithObjects:tmpFolder,filename,nil]];
				// add to new array
				[filenames addObject:absolute];
			}
			
			// import
			[importer fileValueImport:filenames toItem:dest];
		} else if([type isEqualToString:NSURLPboardType]) {
			NSArray *urlList = [pb propertyListForType:type];
			NSURL *url = [NSURL URLWithString:[urlList objectAtIndex:0]];
			CocoLog(LEVEL_DEBUG, @"%@", [url absoluteString]);
			[importer urlValueImport:url toItem:dest asTransaction:YES];
		} else if([type isEqualToString:NSStringPboardType]) {
			NSString *text = [pb stringForType:type];
			CocoLog(LEVEL_DEBUG, @"%@", text);
			[importer eTextValueImport:[text dataUsingEncoding:NSUTF8StringEncoding] toItem:dest forType:TextTypeTXT asTransaction:YES];
		} else if([type isEqualToString:NSRTFPboardType]) {
			NSData *textData = [pb dataForType:type];
			[importer eTextValueImport:textData toItem:dest forType:TextTypeRTF asTransaction:YES];			
		} else if([type isEqualToString:NSRTFDPboardType]) {
			NSData *textData = [pb dataForType:type];			
			[importer eTextValueImport:textData toItem:dest forType:TextTypeRTFD asTransaction:YES];			
        } else if([type isEqualToString:NSPDFPboardType]) {
            NSData *pdfData = [pb dataForType:type];
            [importer pdfValueImport:pdfData toItem:dest asTransaction:YES];			
        }
        
		return YES;	
	}
	
	return NO;
}

/**
 \brief providing promised file names
 This method is only available on tiger and above systems
 \todo --- use threaded progressindicator sheet for this action
*/
- (NSArray *)tableView:(NSTableView *)tv namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropDestination forDraggedRowsWithIndexes:(NSIndexSet *)indexSet {
	NSMutableArray *promisedNames = [NSMutableArray array];

	// start global progress indicator
	MBSendNotifyProgressIndicationActionStarted(nil);
	
	// get exporter
	MBExporter *exporter = [MBExporter defaultExporter];

	CocoLog(LEVEL_DEBUG, @"%@", [dropDestination relativePath]);

	/*
	// get defaults flags
	[exporter setExportLinksAsLink:(BOOL)[defaults integerForKey:MBDefaultsDragDropExportLinksAsLinkKey]];
	int exportType = [defaults integerForKey:MBDefaultsDragDropExportTypeKey];

	// simulate export to get filenames
	[exporter simulateExport:draggingItems 
				exportFolder:[dropDestination relativePath] 
				  exportType:exportType exportedFilenames:&promisedNames];

	// call exporter
	[exporter export:draggingItems exportFolder:[dropDestination relativePath] exportType:exportType];
	 */
	
	// default export type
	int exportType = [userDefaults integerForKey:MBDefaultsExportTypeKey];
	
	// get int array out of index set
	NSString *name = nil;
	NSString *extension = nil;
	NSString *filename = nil;
	NSString *exportName = nil;
	NSString *exportedFilename = nil;
    
	NSEnumerator *iter = [[uiController draggingItems] objectEnumerator];
	MBItemValue *itemval = nil;
	while((itemval = [iter nextObject])) {
		// guess filename
		name = [exporter guessFilenameFor:itemval];
		// get URL, extract relativePath component and add filename, then export
		exportName = [[dropDestination relativePath] stringByAppendingPathComponent:name];
		// exportedFilename
		exportedFilename = @"";
		if(exportType == Export_Native) {
			extension = [exporter guessFileExtensionFor:itemval];
			filename = [exporter generateFilenameWithExtension:extension 
												  fromFilename:exportName];
			// export
			BOOL success = [exporter exportAsNative:itemval toFile:filename exportedFile:&exportedFilename exportedData:nil];
			if(!success) {
				CocoLog(LEVEL_ERR, @"cannot export item: %@",name);
			}
		} else {
			extension = EXPORT_IKAMARCHIVE_TYPESTRING;
			filename = [exporter generateFilenameWithExtension:extension 
												  fromFilename:exportName];
			// export
			BOOL stat = [exporter exportAsIkam:itemval toFile:filename exportedFile:&exportedFilename exportedData:nil];
			if(!stat) {
				CocoLog(LEVEL_ERR, @"cannot export item: %@",name);
			}
		}
		
		// add filename to array
		[promisedNames addObject:exportedFilename];	
	}
	
	// start global progress indicator
	MBSendNotifyProgressIndicationActionStopped(nil);
	
	return promisedNames;	
}

/**
 \brief method for lazy copy drag & drop types.
 types are:
 IKAM_PB_TYPE_NAME,		PList as string
 NSStringPboardType,	NSString with ExtendedTextItemValue
 NSRTFPboardType,		RTF with ExtendedTextItemValue
 NSRTFDPboardType,		RTFD with ExtendedTextItemValue
 NSPDFPboardType,		PDF with PDFItemValue
 NSTIFFPboardType		TIFF with ImageItemValue
*/
- (void)pasteboard:(NSPasteboard *)pboard provideDataForType:(NSString *)type {
	CocoLog(LEVEL_DEBUG,@"");
	
	// do this only if the app is not terminating
	if(appTerminating) {
		CocoLog(LEVEL_WARN,@"app is terminating, we will not provide any data!");
	} else {
		NSArray *draggedItems = [uiController draggingItems];
		NSEnumerator *iter = [draggedItems objectEnumerator];
		MBCommonItem *item = nil;
		while((item = [iter nextObject])) {
			// use special ARP here
			NSAutoreleasePool *myArp = [[NSAutoreleasePool alloc] init];

			// these are our lazy copy pasteboard types
			if([type isEqualToString:IKAM_PB_TYPE_NAME]) {
				CocoLog(LEVEL_DEBUG,@"IKAM");
				
				// copy real data to pb
				MBExporter *exporter = [MBExporter defaultExporter];
				NSData *exportData = [NSData data];
				if(([exporter exportAsIkam:item toFile:nil exportedFile:nil exportedData:&exportData]) && (exportData != nil)) {
					[pboard setData:exportData forType:type];
				}
			} else if(([type isEqualToString:NSStringPboardType]) ||
					([type isEqualToString:NSRTFPboardType]) ||
					([type isEqualToString:NSRTFDPboardType])) {
				CocoLog(LEVEL_DEBUG,@"ExtendedText");

				if([item isKindOfClass:[MBTextItemValue class]]) {
					MBTextItemValue *textVal = (MBTextItemValue *)item;
					[pboard setString:[textVal valueData] forType:type];
				} else {
					MBExtendedTextItemValue *val = (MBExtendedTextItemValue *)item;
					// export read string data
					[pboard setData:[val valueData] forType:type];
				}
			} else if([type isEqualToString:NSURLPboardType]) {
				CocoLog(LEVEL_DEBUG,@"url");
				
				MBItemValue *val = (MBItemValue *)item;
				// write url data to pasteboard
				if([val isKindOfClass:[MBURLItemValue class]]) {
					MBURLItemValue *urlVal = (MBURLItemValue *)val;
					[[urlVal valueData] writeToPasteboard:pboard];
				} else {
					// take filevalue for getting url
					[[(MBFileItemValue *)val linkValueAsURL] writeToPasteboard:pboard];
				}
			} else if([type isEqualToString:NSPDFPboardType]) {
				CocoLog(LEVEL_DEBUG,@"pdf");

				MBPDFItemValue *val = (MBPDFItemValue *)item;
				// export pdf data
				[pboard setData:[val valueData] forType:type];			
			} else if([type isEqualToString:NSTIFFPboardType]) {
				CocoLog(LEVEL_DEBUG,@"tiff");

				MBImageItemValue *val = (MBImageItemValue *)item;
				// export image data
				[pboard setData:[val valueData] forType:type];			
			}
			
			// release pool
			[myArp release];
		}
	}
}

//--------------------------------------------------------------------
//----------- NSTableView delegates ---------------------------------------
//--------------------------------------------------------------------
/**
\brief return the number of rows to be displayed in this tableview
*/
- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	//CocoLog(LEVEL_DEBUG,@"[MBItemValueListViewController numberOfRowsInTableView:]!");

	return [[self currentData] count];
}

/**
\brief displayable object for tablecolumn and row
*/
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)row {
	MBCommonItem *item = nil;
	item = [[self currentData] objectAtIndex:row];

	if(item == nil) {
		CocoLog(LEVEL_WARN,@"have a nil item!");
	} else {
		BOOL isRef = NO;
		// check for reference
		if((([item identifier] == ItemRefID) ||
			([item identifier] == ItemValueRefID)) &&
		   ([(MBRefItem *)item target] != nil)) {
			isRef = YES;
			item = [(MBRefItem *)item target];
		}
		
		// check tableColumn
		if([(NSString *)[aTableColumn identifier] isEqualToString:COL_IDENTIFIER_ITEMVALUE_SORTORDER]) {
			if(!NSLocationInRange([item identifier],ITEMVALUE_ID_RANGE)) {
				return @"";
			} else {
				return [NSNumber numberWithInt:[item sortorder]];
			}
		}
		if([(NSString *)[aTableColumn identifier] isEqualToString:COL_IDENTIFIER_ITEMVALUE_NAME]) {
			if(!NSLocationInRange([item identifier], ITEMVALUE_ID_RANGE)) {
				MBStdItem *buf = (MBStdItem *)item;
				return [NSString stringWithFormat:@"%@: %@",MBLocaleStr(@"PrefixForCombinedItemAndItemValueList"), [buf name]];
			} else {
				MBItemValue *itemval = (MBItemValue *)item;
				return [itemval name];
			}
		} else if([(NSString *)[aTableColumn identifier] isEqualToString:COL_IDENTIFIER_ITEMVALUE_VALUE]) {
			if(!NSLocationInRange([item identifier], ITEMVALUE_ID_RANGE)) {
				return @"";
			} else {
				MBItemValue *itemval = (MBItemValue *)item;
				
				// is this itemval encrypted?
				if([itemval encryptionState] == EncryptedState) {
                    // we have an image now indicating encrypted
					return @"";
				} else {
					if([itemval valuetype] == SimpleTextItemValueType) {
						MBTextItemValue *textval = (MBTextItemValue *)item;
						// return the normal text value
						return [textval valueData];
					} else if([itemval valuetype] == NumberItemValueType) {
						MBNumberItemValue *numval = (MBNumberItemValue *)item;
						return [numval valueData];				
					} else if([itemval valuetype] == BoolItemValueType) {
						MBBoolItemValue *boolval = (MBBoolItemValue *)item;
						if([boolval valueData] == NO) {
							return MBLocaleStr(@"No");
						} else {
							return MBLocaleStr(@"Yes");			
						}
					} else if([itemval valuetype] == URLItemValueType) {
						MBURLItemValue *urlval = (MBURLItemValue *)item;
						return [[urlval valueData] absoluteString];
					} else if([itemval valuetype] == DateItemValueType) {
						MBDateItemValue *dateval = (MBDateItemValue *)item;
						return [dateval valueDataAsString];
					} else if([itemval valuetype] == CurrencyItemValueType) {
						MBCurrencyItemValue *numval = (MBCurrencyItemValue *)item;
						return [numval valueData];
					} else if(([itemval valuetype] == FileItemValueType) || 
                              ([itemval valuetype] == ImageItemValueType) ||
                              ([itemval valuetype] == ExtendedTextItemValueType) ||
                              ([itemval valuetype] == PDFItemValueType)) {
						MBFileItemValue *fileval = (MBFileItemValue *)itemval;
						NSString *linkval = [fileval linkValueAsString];
                        if([itemval valuetype] == ExtendedTextItemValueType) {
                            if([linkval length] == 0) {
                                switch([(MBExtendedTextItemValue *)itemval textType]) {
                                    case TextTypeTXT:
                                        return @"TXT Data";
                                        break;
                                    case TextTypeRTF:
                                        return @"RTF Data";
                                        break;
                                    case TextTypeRTFD:
                                        return @"RTFD Data";
                                        break;
                                }
                            }
                        }
                        
                        return linkval;
                        /*
						// if it is no link then it has been imported
						if([fileval isLink]) {
							// display the link
							return [NSString stringWithFormat:@"%@: %@", MBLocaleStr(@"Link"), linkval];
						} else {
							// display as imported
							return [NSString stringWithFormat:@"%@: %@", MBLocaleStr(@"Imported"), linkval];
						}
                         */
                    } else {
						CocoLog(LEVEL_WARN,@"[MBItemValueListViewController -objectValueForTableColumn]: unregognized valuetype!");
						return @"";					
					}
				}
			}
		} else if([(NSString *)[aTableColumn identifier] isEqualToString:COL_IDENTIFIER_ITEMVALUE_VALUETYPE]) {
			NSMutableString *typeString = [NSMutableString string];

			// check for reference
			if(isRef) {
				// add to type string
				[typeString appendString:@"@"];
			}
			
			if(NSLocationInRange([item identifier],ITEMVALUE_ID_RANGE)) {
				MBItemValue *itemval = (MBItemValue *)item;
				switch([itemval valuetype]) {
					case SimpleTextItemValueType:
						[typeString appendString:SIMPLETEXT_ITEMVALUE_TYPE_NAME];
						break;
					case ExtendedTextItemValueType:
						[typeString appendString:EXTENDEDTEXT_ITEMVALUE_TYPE_NAME];
						break;
					case URLItemValueType:
						[typeString appendString:URL_ITEMVALUE_TYPE_NAME];
						break;
					case NumberItemValueType:
						[typeString appendString:NUMBER_ITEMVALUE_TYPE_NAME];
						break;
					case BoolItemValueType:
						[typeString appendString:BOOL_ITEMVALUE_TYPE_NAME];
						break;
					case DateItemValueType:
						[typeString appendString:DATE_ITEMVALUE_TYPE_NAME];
						break;
					case CurrencyItemValueType:
						[typeString appendString:CURRENCY_ITEMVALUE_TYPE_NAME];
						break;
					case FileItemValueType:
						[typeString appendString:FILE_ITEMVALUE_TYPE_NAME];
						break;
					case ImageItemValueType:
						[typeString appendString:IMAGE_ITEMVALUE_TYPE_NAME];
						break;
					case PDFItemValueType:
						[typeString appendString:PDF_ITEMVALUE_TYPE_NAME];
						break;
					case ItemValueRefType:
						[typeString appendString:ITEMVALUEREF_ITEMTYPE_NAME];
						break;
					default:
						[typeString appendString:@"unknown"];
						break;
				}
			} else if(NSLocationInRange([item identifier],ITEM_ID_RANGE)) {
				[typeString appendString:@"Item"];
			}
			
			return typeString;
		}
	}
	
	return @"test";
}

/**
\brief is it allowed to edit this cell?
*/
- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(int)row {
	MBCommonItem *item = nil;
	item = [[self currentData] objectAtIndex:row];
	
	if(item == nil) {
		CocoLog(LEVEL_WARN,@"have a nil item!");
	} else {
		// check for reference
		if((([item identifier] == ItemRefID) ||
			([item identifier] == ItemValueRefID)) &&
		   ([(MBRefItem *)item target] != nil)) {
			
			item = [(MBRefItem *)item target];
		}
		
		if(NSLocationInRange([item identifier],ITEMVALUE_ID_RANGE) == NO) {
			return NO;
		} else {
			// check table column
			if([[aTableColumn identifier] isEqualToString:COL_IDENTIFIER_ITEMVALUE_VALUETYPE]) {
				// this column may not be edited
				return NO;
			} else if([[aTableColumn identifier] isEqualToString:COL_IDENTIFIER_ITEMVALUE_VALUE]) {
				MBItemValue *itemval = (MBItemValue *)item;
				
				// do not allow editing if this itemval is encrypted
				if([itemval encryptionState] == EncryptedState) {
					return NO;
				} else {
					// editing this coloumn for BoolItemValueType is forbidden
					if(([itemval valuetype] == BoolItemValueType) ||
					   ([itemval valuetype] == ExtendedTextItemValueType) ||
					   ([itemval valuetype] == FileItemValueType) ||
					   ([itemval valuetype] == ImageItemValueType) ||
					   ([itemval valuetype] == PDFItemValueType) ||
					   ([itemval valuetype] == DateItemValueType)) {
						return NO;
					} else {
						return YES;
					}
				}
			} else {
				return YES;
			}
		}		
	}
	
	return NO;
}

/**
\brief NSTableViewDataSource delegate for changing a itemval of the tableview
*/
- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)row {
	MBCommonItem *item = nil;
	item = [[self currentData] objectAtIndex:row];
	
	if(item == nil) {
		CocoLog(LEVEL_WARN,@"[MBItemValueListViewController -shouldEditTableColumn:] have a nil item!");
	} else {
		// check for reference
		if(([item identifier] == ItemRefID) ||
			([item identifier] == ItemValueRefID)) {
			item = [(MBRefItem *)item target];
		}

		// ref items that do not have a target are not allowed here
		if(item != nil) {
			// check for class
			if(NSLocationInRange([item identifier],ITEMVALUE_ID_RANGE)) {
				MBItemValue *itemval = (MBItemValue *)item;

				if(itemval != nil) {
					// check tableColumn
					if([(NSString *)[aTableColumn identifier] isEqualToString:COL_IDENTIFIER_ITEMVALUE_SORTORDER]) {
						// due to number formatter, we get a NSNumber here
						[itemval setSortorder:[anObject intValue]];
					} else if([(NSString *)[aTableColumn identifier] isEqualToString:COL_IDENTIFIER_ITEMVALUE_NAME]) {
						// set itemval name
						[itemval setName:anObject];
					} else if([(NSString *)[aTableColumn identifier] isEqualToString:COL_IDENTIFIER_ITEMVALUE_VALUE]) {
						// get datacell
						NSCell *cell = [aTableColumn dataCellForRow:row];
						if(cell == nil) {
							CocoLog(LEVEL_WARN,@"[MBItemValueListViewController -setObjectValue]: cannot get dataCell!");
						}
						
						if([itemval valuetype] == SimpleTextItemValueType) {
							MBTextItemValue *textval = (MBTextItemValue *)itemval;
							// formatter for text cells is nil
							[textval setValueData:anObject];
						} else if([itemval valuetype] == NumberItemValueType) {
							MBNumberItemValue *numval = (MBNumberItemValue *)itemval;
							// set itemval in model
							[numval setValueData:anObject];
						} else if([itemval valuetype] == URLItemValueType) {
							MBURLItemValue *urlval = (MBURLItemValue *)itemval;
							[urlval setValueData:[NSURL URLWithString:anObject]];
						} else if([itemval valuetype] == CurrencyItemValueType) {
							MBNumberItemValue *numval = (MBNumberItemValue *)itemval;
							// set itemval in model
							[numval setValueData:anObject];
						} else {
							CocoLog(LEVEL_WARN,@"[MBItemValueListViewController -setObjectValue]: unregognized valuetype!");
						}
					}
				}
			}
		}
	}
}

/**
\brief is it allowed to select this row?
*/
- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(int)row {
	MBCommonItem *item = nil;
	item = [[self currentData] objectAtIndex:row];
		
	if(item == nil) {
		CocoLog(LEVEL_WARN,@"have a nil item!");
	} else {
		// check for reference
		if((([item identifier] == ItemRefID) ||
			([item identifier] == ItemValueRefID)) &&
		   ([(MBRefItem *)item target] != nil)) { 
			item = [(MBRefItem *)item target];
		}
		
		if(NSLocationInRange([item identifier],ITEMVALUE_ID_RANGE) == NO) {
			return NO;
		} else {
			return YES;
		}
	}
	
	return NO;
}

/**
\brief the tableview selection has changed
 If reference itemvalues are selected, they stay as is
*/
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
	// get the object
	NSTableView *tView = [aNotification object];
	
	MBItemBaseController *ibc = itemController;
	// get the selected row
	if(tView != nil) {
		NSIndexSet *selectedRows = [tView selectedRowIndexes];
		int len = [selectedRows count];
		NSMutableArray *itemValueSelection = [NSMutableArray arrayWithCapacity:len];		
		id itemval = nil;
		if(len > 0) {
			unsigned long indexes[len];
			[selectedRows getIndexes:indexes maxCount:len inIndexRange:nil];
			
			for(int i = 0;i < len;i++) {
				itemval = [[self currentData] objectAtIndex:indexes[i]];
				if(itemval != nil) {
					[itemValueSelection addObject:itemval];
				} else {
					CocoLog(LEVEL_WARN,@"problem at getting selected item, it is nil!");
				}
			}
		}

		// set selection
		[self setCurrentSelection:itemValueSelection];
		
		// set selection in itemController
		[ibc setCurrentItemValueSelection:itemValueSelection];
	} else {
		CocoLog(LEVEL_WARN,@"tv_selectionDidChange: tableview is nil!");
	}
}

/**
\brief alter cell display of tableview according to content
*/
- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(int)row {
    
    CombinedImageTextCell *cell = (CombinedImageTextCell *)aCell;
    [cell setImage:nil];
    
	MBCommonItem *item = nil;
	item = [[self currentData] objectAtIndex:row];
	if(item == nil) {
		CocoLog(LEVEL_WARN,@"have a nil item!");
	} else {
		// check for reference
		if((([item identifier] == ItemRefID) ||
		   ([item identifier] == ItemValueRefID)) &&
		   ([(MBRefItem *)item target] != nil)) {
			item = [(MBRefItem *)item target];
		}
		
		if(NSLocationInRange([item identifier], ITEMVALUE_ID_RANGE) == NO) {
			// set Std Bold font for call
			NSFont *font = MBStdBoldTableViewFont;
			[aCell setFont:font];
			// set row height according to used font
			// get font height
			double pointSize = [font pointSize];
			[aTableView setRowHeight:pointSize+5];
		} else {
			// set Std Bold font for call
			NSFont *font = MBStdTableViewFont;
			[aCell setFont:font];
			// set row height according to used font
			// get font height
			double pointSize = [font pointSize];
			[aTableView setRowHeight:pointSize+5];
			
			// check tableColumn
			if([(NSString *)[aTableColumn identifier] isEqualToString:COL_IDENTIFIER_ITEMVALUE_SORTORDER]) {
				// do nothing
			} else if([(NSString *)[aTableColumn identifier] isEqualToString:COL_IDENTIFIER_ITEMVALUE_NAME]) {
				// do nothing
			} else if([(NSString *)[aTableColumn identifier] isEqualToString:COL_IDENTIFIER_ITEMVALUE_VALUE]) {
				MBItemValue *itemval = (MBItemValue *)item;
				
				// if encrypted set a nil cell
				if([itemval encryptionState] == EncryptedState) {
					[aCell setFormatter:nil];
                    [cell setImage:encryptedDataImage];
				} else {
					if([itemval valuetype] == SimpleTextItemValueType) {
						// reset formatter to nil
						[aCell setFormatter:nil];
					} else if([itemval valuetype] == NumberItemValueType) {
						// set format
						NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
						[numberFormatter setFormat:[defaults objectForKey:MBDefaultsNumberFormatKey]];
						 // supply cell with number formatter
						 [aCell setFormatter:numberFormatter];
					} else if([itemval valuetype] == BoolItemValueType) {
						// reset formatter to nil
						[aCell setFormatter:nil];
					} else if([itemval valuetype] == URLItemValueType) {
						[aCell setFormatter:nil];
					} else if([itemval valuetype] == DateItemValueType) {
						// we no more need a formatter for DateItemValues
						[aCell setFormatter:nil];
						
						// release old dateFormatter
						//[dateFormatter release];
						// set format
						//NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
						// create dateFormatter
						//dateFormatter = [[[NSDateFormatter alloc] initWithDateFormat:[defaults objectForKey:MBDefaultsDateFormatKey] 
						//										allowNaturalLanguage:YES] autorelease];
						// supply cell with date formatter
						//[aCell setFormatter:dateFormatter];
					} else if([itemval valuetype] == CurrencyItemValueType) {
						// set format
						NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
						[currencyFormatter setFormat:[defaults objectForKey:MBDefaultsCurrencyFormatKey]];
						// supply cell with currency formatter
						[aCell setFormatter:currencyFormatter];
                    } else {
						[aCell setFormatter:nil];
                        if([itemval isKindOfClass:[MBFileItemValue class]]) {
                            if([(MBFileItemValue *)itemval isLink]) {
                                [cell setImage:externalDataImage];
                            } else {
                                [cell setImage:internalDataImage];
                            }
                        }
					}
				}
			} else if([(NSString *)[aTableColumn identifier] isEqualToString:COL_IDENTIFIER_ITEMVALUE_VALUETYPE]) {
				// do nothing
			}
		}
	}
}

/*
- (NSString *)tableView:(NSTableView *)aTableView 
		 toolTipForCell:(NSCell *)aCell 
				   rect:(NSRectPointer)rect 
			tableColumn:(NSTableColumn *)aTableColumn 
					row:(int)row 
		  mouseLocation:(NSPoint)mouseLocation
*/
/**
 \brief this is a method of the datasource for setting tooltips
*/
- (NSString *)tableView:(NSTableView *)aTableView toolTipForTableColumn:(NSTableColumn *)aTableColumn row:(int)row {
	CocoLog(LEVEL_DEBUG,@"[MBItemValueListViewController -tableView:toolTipForCell:toolTipForTableColumn:row:]");

	NSString *tooltip = nil;
	
	MBCommonItem *item = nil;
	item = [[self currentData] objectAtIndex:row];
	
	if(item != nil) {
		// check for reference
		if(([item identifier] == ItemRefID) ||
		   ([item identifier] == ItemValueRefID)) {
			item = [(MBRefItem *)item target];
		}
		
		// check type
		if(NSLocationInRange([item identifier],ITEMVALUE_ID_RANGE)) {
			MBItemValue *itemval = (MBItemValue *)item;

			// check tableColumn
			if([(NSString *)[aTableColumn identifier] isEqualToString:COL_IDENTIFIER_ITEMVALUE_NAME]) {
				// if encrypted set a nil cell
				if([itemval encryptionState] == EncryptedState) {
					tooltip = MBLocaleStr(@"Encrypted");
				} else {
					tooltip = [itemval comment];
				}
			} else if([(NSString *)[aTableColumn identifier] isEqualToString:COL_IDENTIFIER_ITEMVALUE_VALUE]) {
				// if encrypted set a nil cell
				if([itemval encryptionState] == EncryptedState) {
					tooltip = MBLocaleStr(@"Encrypted");
				} else {
					if(([itemval valuetype] == SimpleTextItemValueType) ||
					   ([itemval valuetype] == NumberItemValueType) ||
					   ([itemval valuetype] == CurrencyItemValueType) ||
					   ([itemval valuetype] == BoolItemValueType) ||
					   ([itemval valuetype] == DateItemValueType)) {
						tooltip = [itemval comment];
					} else if([itemval valuetype] == URLItemValueType) {
						tooltip = [[(MBURLItemValue *)itemval valueData] absoluteString];
					} else {
						tooltip = [(MBExtendedTextItemValue *)itemval linkValueAsString];
					}
				}
			} else {
				// if encrypted set a nil cell
				if([itemval encryptionState] == EncryptedState) {
					tooltip = MBLocaleStr(@"Encrypted");
				} else {
					tooltip = [itemval comment];
				}
			}
		}
	}
	
	return tooltip;
}

/**
 \brief sort descriptors have changed, that means that the user has clicked on table header
*/
- (void)tableView:(NSTableView *)aTableView sortDescriptorsDidChange:(NSArray *)oldDescriptors {
	CocoLog(LEVEL_DEBUG,@"[MBItemValueListViewController -tableView:sortDescriptorsDidChange:]");

	NSArray *newDescriptors = [aTableView sortDescriptors];

	// sort
	[itemController sortItemValuesOfItems:[itemController currentItemSelection] usingSortDescriptors:newDescriptors];
	// and display
	[self figureAndDisplayTableData];
	
	// send the new sortdescriptors to itemBaseController
	[itemController setItemValueListSortDescriptors:newDescriptors];
}

// -------------------------------------------------------------------
// Menu stuff
// -------------------------------------------------------------------
- (void)createNormalItemMenu {
	// build context menu
	normalItemMenu = [[NSMenu alloc] init];
	[normalItemMenu setDelegate:self];
	// set menu items
	// new itemvalue
	[normalItemMenu addItem:[[newItemValueMenuItem copy] autorelease]];
	// separater
	[normalItemMenu addItem:(NSMenuItem *)[NSMenuItem separatorItem]];
	// cut
	[normalItemMenu addItem:[[cutMenuItem copy] autorelease]];
	// copy
	[normalItemMenu addItem:[[copyMenuItem copy] autorelease]];
	// paste
	[normalItemMenu addItem:[[pasteMenuItem copy] autorelease]];
	// delete
	[normalItemMenu addItem:[[deleteMenuItem copy] autorelease]];
	// separater
	[normalItemMenu addItem:(NSMenuItem *)[NSMenuItem separatorItem]];
	// import
	[normalItemMenu addItem:[[importMenuItem copy] autorelease]];
	// export
	[normalItemMenu addItem:[[exportMenuItem copy] autorelease]];
	// separater
	[normalItemMenu addItem:(NSMenuItem *)[NSMenuItem separatorItem]];
	// create ref
	[normalItemMenu addItem:[[createRefMenuItem copy] autorelease]];
	// separater
	[normalItemMenu addItem:(NSMenuItem *)[NSMenuItem separatorItem]];
	// encryption menu
	[normalItemMenu addItem:[[encryptionMenuItem copy] autorelease]];
    // open/open with
	[normalItemMenu addItem:(NSMenuItem *)[NSMenuItem separatorItem]];
	[normalItemMenu addItem:[[openMenuItem copy] autorelease]];
	[normalItemMenu addItem:[[openWithMenuItem copy] autorelease]];
}

// -------------------------------------------------------------------
// Notifications
// -------------------------------------------------------------------
/**
\brief the menu has been changed create manu new
 */
- (void)menuChanged:(NSNotification *)aNotification {
	// create template menu new
	[self createNormalItemMenu];
}

/**
\brief after adding a new created ItemValue to an item this Notification is send
 */
- (void)itemValueAdded:(NSNotification *)aNotification {
	// get notification object
	MBItemValue *addedItemVal = [aNotification object];
	if(addedItemVal != nil) {
		// get row of item
		int rowNumber = [currentData indexOfObject:addedItemVal];
		// select item
		[itemValueTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:rowNumber] byExtendingSelection:NO];
	} else {
		CocoLog(LEVEL_WARN,@"added ItemValue is nil!");
	}
}

/** 
\brief notification that the application has finished with initialization

Now the item outlineview can be reread
*/
- (void)appInitialized:(NSNotification *)aNotification {
	// use user defaults for format
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	// create number formatter
	numberFormatter = [[NSNumberFormatter alloc] init];
	// set format
	[numberFormatter setFormat:[defaults objectForKey:MBDefaultsNumberFormatKey]];
	[numberFormatter setDecimalSeparator:[defaults objectForKey:NSDecimalSeparator]];
	[numberFormatter setThousandSeparator:[defaults objectForKey:NSThousandsSeparator]];
	
	// create number currency
	currencyFormatter = [[NSNumberFormatter alloc] init];
	// set format
	[currencyFormatter setFormat:[defaults objectForKey:MBDefaultsCurrencyFormatKey]];
	[currencyFormatter setDecimalSeparator:[defaults objectForKey:NSDecimalSeparator]];
	[currencyFormatter setThousandSeparator:[defaults objectForKey:NSThousandsSeparator]];
}

- (void)appWillTerminate:(NSNotification *)aNotification {
	CocoLog(LEVEL_DEBUG,@"");
	appTerminating = YES;
}

// callback for tableview changes
- (void)itemValueAttribsChanged:(NSNotification *)aNotification {
	CocoLog(LEVEL_DEBUG,@"");

	if(aNotification != nil) {
		[self figureAndDisplayTableData];
	}
}

/**
\brief this notification is send if the selected element has changed
 */
- (void)reloadTableView:(NSNotification *)aNotification {
	CocoLog(LEVEL_DEBUG,@"");
	
	if(aNotification != nil) {
		// deselect all and redisplay
		[itemValueTableView deselectAll:nil];
		[self figureAndDisplayTableData];
	}
}

/**
\brief this notification is send if an itemValue has been added or removed
*/
- (void)itemValueListChanged:(NSNotification *)aNotification {
	CocoLog(LEVEL_DEBUG,@"");

	if(aNotification != nil) {
		// deselect all and redisplay
		[itemValueTableView deselectAll:nil];
		[self figureAndDisplayTableData];
	}
}

/**
 \brief this notification is called when a selection to the current list should be made
*/
- (void)itemValueSelectionChanged:(NSNotification *)aNotification {
	CocoLog(LEVEL_DEBUG,@"");
	
	if(aNotification != nil) {
		// get Array of itemvalues
		NSArray *list = [aNotification object];
		
		if((list != nil) && ([list count] > 0)) {
			// deselect all and redisplay
			[itemValueTableView deselectAll:nil];
			
			// create index set
			NSMutableIndexSet *iSet = [NSMutableIndexSet indexSet];
			
			NSEnumerator *iter = [list objectEnumerator];
			MBItemValue *val = nil;
			int index = -1;
			while((val = [iter nextObject])) {
				// search val in current display list
				index = [currentData indexOfObject:val];
				if(index > -1) {
					[iSet addIndex:index];
				}
			}
			
			// select these values if there are any
			if([iSet count] > 0) {
				[itemValueTableView selectRowIndexes:iSet byExtendingSelection:NO];
			}
		} else {
			CocoLog(LEVEL_WARN,@"list of values nil or empty!");
		}
	}	
}

// -------------------------------------------------------------------
// Actions
// -------------------------------------------------------------------
/**
 \brief this action is for use with first responder
*/
- (IBAction)menuExport:(id)sender {
	CocoLog(LEVEL_DEBUG,@"");
	
	NSArray *copySelection = [self currentSelection];
	if([copySelection count] > 0) {
		MBExporter *exporter = [MBExporter defaultExporter];
		[exporter export:copySelection exportFolder:nil exportType:-1];
	}
}

@end
