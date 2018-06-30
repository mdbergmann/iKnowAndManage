// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import "MBTypeListViewController.h"
#import <MBItemBaseController.h>

// column identifiers
#define COL_IDENTIFIER_NAME		@"name"
#define COL_IDENTIFIER_VALUE	@"value"

@interface MBTypeListViewController (privateAPI)

- (NSArray *)deliverDisplayData:(NSArray *)itemSelection;
- (void)figureAndDisplayTableData;

- (void)setCurrentSelection:(NSArray *)array;

@end

//--------------------------------------------------------------------
//----------- private API ---------------------
//--------------------------------------------------------------------
@implementation MBTypeListViewController (privateAPI)

/**
 \brief set the current selection
*/
- (void)setCurrentSelection:(NSArray *)array
{
	if(array != currentSelection)
	{
		[array retain];
		[currentSelection release];
		currentSelection = array;
	}
}

- (void)figureAndDisplayTableData
{
	// the type of value we shall display
	int type = [[typePopUpButton selectedItem] tag];

	// get selected items from ibc and create new array
	NSArray *values = [itemController listForIdentifier:type];

	// generate new data array for displaying including the current search word
	[self setCurrentData:[self deliverDisplayData:values]];
	
	// reload complete table view
	[listTableView reloadData];
	
	// set result label
	NSString *resultString = [NSString stringWithFormat:@"Displaying %d values out of %d",
		[currentData count],
		[values count]];
	[resultLabel setStringValue:resultString];
}

/**
\brief this method delivers a new NSArray for displaying in the tableview recognizing the current search string
 */
- (NSArray *)deliverDisplayData:(NSArray *)selection
{
	// the return array
	NSMutableArray *array = [NSMutableArray array];
	
	// we need a searcher instance
	MBSearchController *sc = [MBSearchController defaultSearchController];
	
	if([selection count] > 0)
	{
		NSEnumerator *iter = [selection objectEnumerator];
		MBItemValue *buf = nil;
		while((buf = [iter nextObject]))
		{
			// create a special array for itemvalues
			NSMutableArray *valArr = [NSMutableArray array];

			// have a look if we are searching
			if([searchString length] > 0)
			{
				[sc searchInItem:buf 
					   forString:searchString 
					   recursive:NO 
				  searchExternal:NO 
				   caseSensitive:NO
					  wholeWords:NO 
						  result:&valArr];
			}
			else
			{
				// add itemfirst
				[array addObject:buf];
			}
			
			// add the item itself, if value array it larger than 0
			if([valArr count] > 0)
			{
				// add values
				[array addObjectsFromArray:valArr];
			}			
		}
	}

	return array;
}

@end

@implementation MBTypeListViewController

- (id)init
{
	self = [super initWithWindowNibName:@"TypeList"];
	if(self == nil)
	{
		MBLOG(MBLOG_ERR,@"cannot alloc MBTypeListViewController!");		
	}
	else
	{
		// this is set to YES if app is terminating
		appTerminating = NO;
		
		// init searchString and array
		[self setSearchString:@""];
		[self setCurrentData:[NSArray array]];
		[self setCurrentSelection:[NSArray array]];
		
		// create Dictionary with attributes
		// we need red color
		NSMutableDictionary *attribDict = [NSMutableDictionary dictionary];
		[attribDict setObject:[NSColor redColor] forKey:NSForegroundColorAttributeName];
		encryptedDataString = [[NSAttributedString alloc] initWithString:MBLocaleStr(@"Encrypted") 
															  attributes:attribDict];
		
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
	
	return self;
}

/**
\brief dealloc of this class is called on closing this document
 */
- (void)dealloc
{
	// release formatters
	[numberFormatter release];
	[currencyFormatter release];
	//[dateFormatter release];
	
	[self setSearchString:nil];
	// release currenbt data
	[self setCurrentData:nil];
	[self setCurrentSelection:nil];
	
	// release attribString for encrypted data
	[encryptedDataString release];
	
	// dealloc object
	[super dealloc];
}

//--------------------------------------------------------------------
//----------- bundle delegates ---------------------------------------
//--------------------------------------------------------------------
- (void)windowDidLoad
{
	MBLOG(MBLOG_DEBUG,@"windowDidLoad of MBTypeListViewController");
	
	if(self != nil)
	{
		// deactivate show button
		[showButton setEnabled:NO];
		
		// register for drag and drop
		[listTableView registerForDraggedTypes:[self validDragAndDropPbTypes]];
		
		// register notification
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(appWillTerminate:)
													 name:MBAppWillTerminateNotification object:nil];		
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
												 selector:@selector(itemValueAdded:)
													 name:MBItemValueAddedNotification object:nil];
		
		// start with the default -> Simple text
		[self figureAndDisplayTableData];
	}
}

/**
 \brief return the view, which is the main component
*/
- (NSView *)theView;
{
	return theView;
}

/**
 \brief return the table view itself to compare for first responder
*/
- (NSTableView *)tableView
{
	return listTableView;
}

- (NSArray *)validDragAndDropPbTypes
{
	return [NSArray arrayWithObjects:
		//IKAM_PB_TYPE_NAME,
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
 \brief set the data to be displayed in the tableview
 The array can consist of MBItems and MBItemValues
*/
- (void)setCurrentData:(NSArray *)array
{
	if(array != currentData)
	{
		[array retain];
		[currentData release];
		currentData = array;
	}
}

- (NSArray *)currentData
{
	return currentData;
}

- (NSArray *)currentSelection
{
	return currentSelection;
}

/**
 \brief sets the current search string.
*/
- (void)setSearchString:(NSString *)string
{
	if(string != searchString)
	{
		[string retain];
		[searchString release];
		searchString = string;
	}
}

- (NSString *)searchString
{
	return searchString;
}

/**
 \brief return the tableviews current sortdescriptors
*/
- (NSArray *)currentSortDescriptors
{
	return [listTableView sortDescriptors];
}

//--------------------------------------------------------------------
//----------- NSTableViewSource delegates ----------------------------
//--------------------------------------------------------------------
/*
- (NSArray *)namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropDestination
{ 
	MBLOG(MBLOG_DEBUG,@"namesOfPromisedFilesDroppedAtDestination...!");
	MBLOG(MBLOG_DEBUG,@"dropDestination: %@",[dropDestination absoluteString]);
	
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
		MBLOG(MBLOG_DEBUG,@"name: %@",name);
		NSString *extension = [exporter guessFileExtensionFor:itemval];
		MBLOG(MBLOG_DEBUG,@"extension: %@",extension);
		NSString *filename = [exporter generateFilenameWithExtension:extension 
														fromFilename:name];
		
		// add filename to array
		[promisedNames addObject:filename];
		
		// get URL, extract relativePath component and add filename, then export
		NSString *exportName = [[dropDestination relativePath] stringByAppendingPathComponent:filename];
		NSURL *url = [NSURL fileURLWithPath:exportName];
		MBLOG(MBLOG_DEBUG,[url absoluteString]);
		MBLOG(MBLOG_DEBUG,@"exporting to %@",exportName);
		[exporter exportAsNative:itemval toFile:exportName];
	}
	
	return promisedNames;
}
*/

/**
 \brief write dragging items to pasteboard
*/
- (BOOL)tableView:(NSTableView *)tableView writeRows:(NSArray *)rows toPasteboard:(NSPasteboard *)pboard
{
	// copy items
	NSMutableArray *valList = [NSMutableArray arrayWithCapacity:[rows count]];
	NSEnumerator *iter = [rows objectEnumerator];
	NSNumber *row = nil;
	while((row = [iter nextObject]))
	{
		[valList addObject:[[self currentData] objectAtIndex:[row intValue]]];
	}
	
	[itemController setDraggingItems:valList];	// lazy copy
	
	NSMutableDictionary *dragTypes = [NSMutableDictionary dictionary];
	NSMutableDictionary *promisedFileTypes = [NSMutableDictionary dictionary];

	if([valList count] > 0)
	{
		// get a exporter
		MBExporter *exporter = [MBExporter defaultExporter];
		
		// export these types first
		[dragTypes setObject:[NSNull null] forKey:COMMON_ITEM_PB_TYPE_NAME];
		[dragTypes setObject:[NSNull null] forKey:NSFilesPromisePboardType];
		
		NSEnumerator *iter = [valList objectEnumerator];
		MBItemValue *itemval = nil;
		while((itemval = [iter nextObject]))
		{
			// check for reference. references will be dragged as IKAM_PB_TYPE
			if([itemval identifier] == ItemValueRefID)
			{
				MBLOG(MBLOG_DEBUG,@"drag references as ikam only");
				// string pbtype
				[dragTypes setObject:[NSNull null] forKey:IKAM_PB_TYPE_NAME];
				[pboard setString:@"IOU" forType:IKAM_PB_TYPE_NAME];	// lazy
				
				// promised file
				[promisedFileTypes setObject:[NSNull null] forKey:EXPORT_IKAMARCHIVE_TYPESTRING];
			}
			else
			{
				/*
				// get row index
				int rowIndex = [[rows objectAtIndex:0] intValue];
				MBLOG(MBLOG_DEBUG,@"rowindex = %d",rowIndex);
				// get current row rect
				NSRect rowRect = [tableView rectOfRow:rowIndex];
				//MBLOG(MBLOG_DEBUG,@"x = %f",rowRect.origin.x);
				//MBLOG(MBLOG_DEBUG,@"y = %f",rowRect.origin.y);
				//MBLOG(MBLOG_DEBUG,@"w = %f",rowRect.size.width);
				//MBLOG(MBLOG_DEBUG,@"h = %f",rowRect.size.height);				
				 */

				// for these types we can drag other types
				switch([itemval valuetype])
				{
					case NumberItemValueType:
					case CurrencyItemValueType:
					case BoolItemValueType:
					case DateItemValueType:
					case ItemValueRefType:
					{
						MBLOG(MBLOG_DEBUG,@"ikam export type for simple types that cannot be exported natively");
						// string pbtype
						[dragTypes setObject:[NSNull null] forKey:IKAM_PB_TYPE_NAME];
						[pboard setString:@"IOU" forType:IKAM_PB_TYPE_NAME];	// lazy
						//[pboard setData:[exporter exportAsIkam:itemval toFile:nil] forType:IKAM_PB_TYPE_NAME];

						// promised file
						[promisedFileTypes setObject:[NSNull null] forKey:EXPORT_IKAMARCHIVE_TYPESTRING];
						break;				
					}
					case SimpleTextItemValueType:
					{
						MBLOG(MBLOG_DEBUG,@"simpleTextItemValuetype drag");
						//MBTextItemValue *val = itemval;
						// string pbtype
						[dragTypes setObject:[NSNull null] forKey:NSStringPboardType];
						// no lazy copy here
						//[pboard setString:[val valueData] forType:NSStringPboardType];
						// lazy copy here
						[pboard setString:@"IOU" forType:NSStringPboardType];
						
						// promised file
						[promisedFileTypes setObject:[NSNull null] forKey:@"txt"];
						break;
					}
					case ExtendedTextItemValueType:
					{
						MBLOG(MBLOG_DEBUG,@"extendedTextItemValuetype drag");
						MBExtendedTextItemValue *val = (MBExtendedTextItemValue *)itemval;
						NSString *extension = nil;
						switch([val textType])
						{
							case TextTypeTXT:
							{
								// string pbtype
								[dragTypes setObject:[NSNull null] forKey:NSStringPboardType];
								[pboard setString:@"IOU" forType:NSStringPboardType];
								//[pboard setData:[val valueData] forType:NSStringPboardType];
								// set extension
								extension = @"txt";
								break;
							}
							case TextTypeRTF:
							{
								// rtf pbtype
								[dragTypes setObject:[NSNull null] forKey:NSRTFPboardType];
								[pboard setString:@"IOU" forType:NSRTFPboardType];
								//[pboard setData:[val valueData] forType:NSRTFPboardType];
								// set extension
								extension = @"rtf";
								break;
							}
							case TextTypeRTFD:
							{
								// rtfd pbtype
								[dragTypes setObject:[NSNull null] forKey:NSRTFDPboardType];
								[pboard setString:@"IOU" forType:NSRTFDPboardType];
								//[pboard setData:[val valueData] forType:NSRTFDPboardType];
								// set extension
								extension = @"rtfd";
								break;
							}
						}
						
						// if this is a link, we can provide the path as Filename and URL as well
						if([val isLink] == YES)
						{			
							NSURL *url = [val linkValueAsURL];
							if(url != nil)
							{
								// URL
								[dragTypes setObject:[NSNull null] forKey:NSURLPboardType];
								// lazy copy
								[pboard setString:@"IOU" forType:NSURLPboardType];					
								//[url writeToPasteboard:pboard];
								
								// if this is a local url
								if([url isFileURL] == YES)
								{
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
						MBLOG(MBLOG_DEBUG,@"urlTextItemValuetype drag");
						MBURLItemValue *val = (MBURLItemValue *)itemval;
						// url
						[dragTypes setObject:[NSNull null] forKey:NSURLPboardType];
						[pboard setString:@"IOU" forType:NSURLPboardType];
						// no lazy copy here, url values are not that big
						//[pboard setString:[[val exportAsWebloc] description] forType:NSURLPboardType];
						NSURL *url = [val valueData];
						if(url != nil)
						{
							[url writeToPasteboard:pboard];
						}
						else
						{
							MBLOG(MBLOG_DEBUG,@"[MBItemValueListTableViewController -tableView:writeRows:toPasteboard:] have a nil url!");				
						}
						
						// promised file
						if([url isFileURL])
						{
							[promisedFileTypes setObject:[NSNull null] forKey:@"fileloc"];						
						}
						else
						{
							[promisedFileTypes setObject:[NSNull null] forKey:@"webloc"];
						}
						break;
					}
					case ImageItemValueType:
					{
						MBLOG(MBLOG_DEBUG,@"imageItemValuetype drag");
						MBImageItemValue *val = (MBImageItemValue *)itemval;
						// image
						[dragTypes setObject:[NSNull null] forKey:NSTIFFPboardType];
						[pboard setString:@"IOU" forType:NSTIFFPboardType];
						//[pboard setData:[[val image] TIFFRepresentation] forType:NSTIFFPboardType];
						
						// if this is a link, we can provide the path as Filename and URL as well
						if([val isLink] == YES)
						{		
							NSURL *url = [val linkValueAsURL];
							if(url != nil)
							{
								// URL
								[dragTypes setObject:[NSNull null] forKey:NSURLPboardType];
								// lazy copy
								[pboard setString:@"IOU" forType:NSURLPboardType];					
								//[url writeToPasteboard:pboard];
								
								// if this is a local url
								if([url isFileURL] == YES)
								{
									// file
									//[dragTypes addObject:NSFilenamesPboardType];
									//[pboard setPropertyList:[NSArray arrayWithObject:[url relativePath]] forType:NSFilenamesPboardType];
								}
							}					
						}

						// promised file
						[promisedFileTypes setObject:[NSNull null] forKey:[exporter guessFileExtensionFor:itemval]];
						break;
					}
					case FileItemValueType:
					{
						MBLOG(MBLOG_DEBUG,@"fileItemValuetype drag");
						MBFileItemValue *val = (MBFileItemValue *)itemval;
						NSURL *url = [val linkValueAsURL];
						NSString *extension = [exporter guessFileExtensionFor:itemval];
						if([extension isEqualToString:@"pdf"])
						{
							// pdf
							[dragTypes setObject:[NSNull null] forKey:NSPDFPboardType];
							[pboard setString:@"IOU" forType:NSPDFPboardType];					
							//[pboard setData:[val valueData] forType:NSPDFPboardType];					
						}

						if(url != nil)
						{
							// URL
							[dragTypes setObject:[NSNull null] forKey:NSURLPboardType];
							// lazy copy
							[pboard setString:@"IOU" forType:NSURLPboardType];					
							//[url writeToPasteboard:pboard];

							// if this is a local url
							if([url isFileURL] == YES)
							{
								// file
								//[dragTypes addObject:NSFilenamesPboardType];
								//[pboard setPropertyList:[NSArray arrayWithObject:[url relativePath]] forType:NSFilenamesPboardType];
							}
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
		
		// set data, for internal usage this is more than enough
		[pboard setData:[NSData data] forType:COMMON_ITEM_PB_TYPE_NAME];
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
- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)operation
{
	NSPasteboard *pb = [info draggingPasteboard];
	// get pb type
	NSString *type = [pb availableTypeFromArray:[self validDragAndDropPbTypes]];

	// we don't accept unknown types
	if(type == nil)
	{
		return NSDragOperationNone;
	}
	// dropping items or itemvalues here is not allowed
	else if([type isEqualToString:COMMON_ITEM_PB_TYPE_NAME])
	{
		return NSDragOperationNone;
	}		
	// we do not accept drops from the same source
	else if([info draggingSource] == tableView)
	{
		return NSDragOperationNone;
	}
	
	return [info draggingSourceOperationMask];	
}

/**
 \brief accept drop?
 the priority of the import type in determined by the type order in the array that defines the accepted types
 here:[self validDragAndDropPbTypes]
*/
/*
- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)operation
{
	MBLOG(MBLOG_DEBUG,@"tableView:acceptDrop:row:dropOperation:");
	
	MBItem *dest = [itemController creationDestinationWithWarningPanel:YES];
	if(dest == nil)
	{
		return NO;	
	}
	else
	{
		// init importer
		MBImporter *importer = [MBImporter defaultImporter];
		
		NSPasteboard *pb = [info draggingPasteboard];
		// get pb type
		NSString *type = [pb availableTypeFromArray:[self validDragAndDropPbTypes]];
		MBLOG(MBLOG_DEBUG,type);
		MBLOG(MBLOG_DEBUG,[pb stringForType:type]);
		
		if([type isEqualToString:COMMON_ITEM_PB_TYPE_NAME])
		{
			// this is not allowed
		}
		else if([type isEqualToString:NSFilenamesPboardType] == YES)
		{
			// get array of Filenames
			NSArray *filenames = [pb propertyListForType:type];
			NSEnumerator *iter = [filenames objectEnumerator];
			NSString *file = nil;
			while((file = [iter nextObject]))
			{
				MBLOG(MBLOG_DEBUG,file);
			}
			
			// import
			[importer fileValueImport:filenames toItem:dest];
		}
		else if([type isEqualToString:NSFilesPromisePboardType] == YES)
		{
			MBLOG(MBLOG_DEBUG,[pb stringForType:type]);
			
			NSString *tmpFolder = TMPFOLDER;
			
			NSArray *files = [info namesOfPromisedFilesDroppedAtDestination:[NSURL fileURLWithPath:tmpFolder]];
			// build filenames
			NSMutableArray *filenames = [NSMutableArray arrayWithCapacity:[files count]];
			NSEnumerator *iter = [files objectEnumerator];
			NSString *filename = nil;
			while((filename = [iter nextObject]))
			{
				// build complete filename
				NSString *absolute = [NSString pathWithComponents:[NSArray arrayWithObjects:tmpFolder,filename,nil]];
				// add to new array
				[filenames addObject:absolute];
			}
			
			// import
			[importer fileValueImport:filenames toItem:dest];
		}
		else if([type isEqualToString:NSURLPboardType] == YES)
		{
			NSArray *urlList = [pb propertyListForType:type];
			NSURL *url = [NSURL URLWithString:[urlList objectAtIndex:0]];
			MBLOG(MBLOG_DEBUG,[url absoluteString]);
			
			[importer urlValueImport:url toItem:dest asTransaction:YES];
		}
		else if([type isEqualToString:NSStringPboardType] == YES)
		{
			NSString *text = [pb stringForType:type];
			MBLOG(MBLOG_DEBUG,text);
			
			[importer eTextValueImport:[text dataUsingEncoding:NSUTF8StringEncoding] toItem:dest forType:TextTypeTXT asTransaction:YES];
		}
		else if([type isEqualToString:NSRTFPboardType] == YES)
		{
			NSData *textData = [pb dataForType:type];
			
			[importer eTextValueImport:textData toItem:dest forType:TextTypeRTF asTransaction:YES];			
		}
		else if([type isEqualToString:NSRTFDPboardType] == YES)
		{
			NSData *textData = [pb dataForType:type];
			
			[importer eTextValueImport:textData toItem:dest forType:TextTypeRTFD asTransaction:YES];			
		}

		return YES;	
	}
	
	return NO;
}
*/

/**
 \brief providing promised file names
 This method is only available on tiger and above systems
 \todo --- use threaded progressindicator sheet for this action
*/
- (NSArray *)tableView:(NSTableView *)tv namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropDestination 
forDraggedRowsWithIndexes:(NSIndexSet *)indexSet
{
	MBLOG(MBLOG_DEBUG,@"tableView:namesOfPromisedFilesDroppedAtDestination:forDraggedRowsWithIndexes:");
	MBLOGV(MBLOG_DEBUG,@"dropDestination: %@",[dropDestination absoluteString]);
	
	NSMutableArray *promisedNames = [NSMutableArray array];

	// start global progress indicator
	MBSendNotifyProgressIndicationActionStarted(nil);
	
	// get exporter
	MBExporter *exporter = [MBExporter defaultExporter];

	// get instance of IBC
	MBItemBaseController *ibc = itemController;
	// get draggingItems
	NSArray *draggingItems = [ibc draggingItems];

	MBLOG(MBLOG_DEBUG,[dropDestination relativePath]);

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
	NSEnumerator *iter = [draggingItems objectEnumerator];
	MBItemValue *itemval = nil;
	while((itemval = [iter nextObject]))
	{
		// guess filename
		name = [exporter guessFilenameFor:itemval];
		extension = nil;
		// get URL, extract relativePath component and add filename, then export
		exportName = [[dropDestination relativePath] stringByAppendingPathComponent:name];
		// exportedFilename
		exportedFilename = @"";
		if(exportType == Export_Native)
		{
			extension = [exporter guessFileExtensionFor:itemval];
			filename = [exporter generateFilenameWithExtension:extension 
												  fromFilename:exportName];
			// export
			BOOL success = [exporter exportAsNative:itemval toFile:filename exportedFile:&exportedFilename exportedData:nil];
			if(!success)
			{
				NSString *str = [NSString stringWithFormat:@"[MBTypeListViewController -tableView:namesOfPromisedFilesDroppedAtDestination:] cannot export item: %@",name];
				MBLOG(MBLOG_ERR,str);
			}
		}
		else
		{
			extension = EXPORT_IKAMARCHIVE_TYPESTRING;
			filename = [exporter generateFilenameWithExtension:extension 
												  fromFilename:exportName];
			// export
			BOOL stat = [exporter exportAsIkam:itemval toFile:filename exportedFile:&exportedFilename exportedData:nil];
			if(stat == NO)
			{
				NSString *str = [NSString stringWithFormat:@"[MBTypeListViewController -tableView:namesOfPromisedFilesDroppedAtDestination:] cannot export item: %@",name];
				MBLOG(MBLOG_ERR,str);
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
 NSPDFPboardType,		PDF with FileItemValue
 NSTIFFPboardType		TIFF with ImageItemValue
*/
- (void)pasteboard:(NSPasteboard *)pboard provideDataForType:(NSString *)type
{
	MBLOG(MBLOG_DEBUG,@"[MBTypeListViewController -pasteboard:provideDataForType:]!");
	
	// do this only if the app is not terminating
	if(appTerminating == YES)
	{	
		MBLOG(MBLOG_WARN,@"[MBTypeListViewController -pasteboard:provideDataForType:] app is terminating, we will not provide any data!");		
	}
	else
	{
		NSArray *draggedItems = [itemController draggingItems];
		NSEnumerator *iter = [draggedItems objectEnumerator];
		MBCommonItem *item = nil;
		while((item = [iter nextObject]))
		{
			// use special ARP here
			NSAutoreleasePool *myArp = [[NSAutoreleasePool alloc] init];

			// these are our lazy copy pasteboard types
			if([type isEqualToString:IKAM_PB_TYPE_NAME] == YES)
			{
				MBLOG(MBLOG_DEBUG,@"[MBTypeListViewController -pasteboard:provideDataForType:] IKAM");
				
				// copy real data to pb
				MBExporter *exporter = [MBExporter defaultExporter];
				NSData *exportData = [NSData data];
				if(([exporter exportAsIkam:item toFile:nil exportedFile:nil exportedData:&exportData] == YES) && (exportData != nil))
				{
					[pboard setData:exportData forType:type];
				}
			}
			else if(([type isEqualToString:NSStringPboardType] == YES) ||
					([type isEqualToString:NSRTFPboardType] == YES) ||
					([type isEqualToString:NSRTFDPboardType] == YES))
			{
				MBLOG(MBLOG_DEBUG,@"[MBTypeListViewController -pasteboard:provideDataForType:] ExtendedText");

				if([item isKindOfClass:[MBTextItemValue class]] == YES)
				{
					MBTextItemValue *textVal = (MBTextItemValue *)item;
					[pboard setString:[textVal valueData] forType:type];
				}
				else
				{
					MBExtendedTextItemValue *val = (MBExtendedTextItemValue *)item;
					// export read string data
					[pboard setData:[val valueData] forType:type];
				}
			}
			else if([type isEqualToString:NSURLPboardType] == YES)
			{
				MBLOG(MBLOG_DEBUG,@"[MBTypeListViewController -pasteboard:provideDataForType:] url");
				
				MBItemValue *val = (MBItemValue *)item;
				// write url data to pasteboard
				if([val isKindOfClass:[MBURLItemValue class]] == YES)
				{
					MBURLItemValue *urlVal = (MBURLItemValue *)val;
					[[urlVal valueData] writeToPasteboard:pboard];
				}
				else
				{
					// take filevalue for getting url
					[[(MBFileItemValue *)val linkValueAsURL] writeToPasteboard:pboard];
				}
			}
			else if([type isEqualToString:NSPDFPboardType] == YES)
			{
				MBLOG(MBLOG_DEBUG,@"[MBTypeListViewController -pasteboard:provideDataForType:] pdf");

				MBFileItemValue *val = (MBFileItemValue *)item;
				// export pdf data
				[pboard setData:[val valueData] forType:type];			
			}
			else if([type isEqualToString:NSTIFFPboardType] == YES)
			{
				MBLOG(MBLOG_DEBUG,@"[MBTypeListViewController -pasteboard:provideDataForType:] tiff");

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
	//MBLOG(MBLOG_DEBUG,@"[MBTypeListViewController numberOfRowsInTableView:]!");

	return [[self currentData] count];
}

/**
\brief displayable object for tablecolumn and row
*/
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)row
{
	MBCommonItem *item = nil;
	item = [[self currentData] objectAtIndex:row];

	if(item == nil)
	{
		MBLOG(MBLOG_WARN,@"[MBTypeListViewController -objectValueForTableColumn:] have a nil item!");
	}
	else
	{
		BOOL isRef = NO;
		// check for reference
		if((([item identifier] == ItemRefID) ||
			([item identifier] == ItemValueRefID)) &&
		   ([(MBRefItem *)item target] != nil))
		{
			isRef = YES;
			item = [(MBRefItem *)item target];
		}
		
		// check tableColumn
		if([(NSString *)[aTableColumn identifier] isEqualToString:COL_IDENTIFIER_NAME] == YES)
		{
			if(NSLocationInRange([item identifier],ITEMVALUE_ID_RANGE) == NO)
			{
				MBStdItem *buf = (MBStdItem *)item;
				return [NSString stringWithFormat:@"%@: %@",MBLocaleStr(@"PrefixForCombinedItemAndItemValueList"),[buf name]];
			}
			else
			{
				MBItemValue *itemval = (MBItemValue *)item;
				return [itemval name];
			}
		}
		else if([(NSString *)[aTableColumn identifier] isEqualToString:COL_IDENTIFIER_VALUE] == YES)
		{
			if(NSLocationInRange([item identifier],ITEMVALUE_ID_RANGE) == NO)
			{
				return @"";
			}
			else
			{
				MBItemValue *itemval = (MBItemValue *)item;
				
				// is this itemval encrypted?
				if([itemval encryptionState] == EncryptedState)
				{
					return encryptedDataString;
				}
				else
				{
					if([itemval valuetype] == SimpleTextItemValueType)
					{
						MBTextItemValue *textval = (MBTextItemValue *)item;
						// return the normal text value
						return [textval valueData];
					}
					else if([itemval valuetype] == ExtendedTextItemValueType)
					{
						MBExtendedTextItemValue *etextval = (MBExtendedTextItemValue *)item;
						
						NSString *linkval = [etextval linkValueAsString];
						if([linkval length] > 0)
						{
							// if it is no link then it has been imported
							if([etextval isLink])
							{
								// display the link
								return [NSString stringWithFormat:@"%@: %@",MBLocaleStr(@"Link"),linkval];
							}
							else
							{
								// display as imported
								return [NSString stringWithFormat:@"%@: %@",MBLocaleStr(@"Imported"),linkval];
							}
						}
						else
						{
							switch([etextval textType])
							{
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
					else if([itemval valuetype] == NumberItemValueType)
					{
						MBNumberItemValue *numval = (MBNumberItemValue *)item;
						return [numval valueData];				
					}
					else if([itemval valuetype] == BoolItemValueType)
					{
						MBBoolItemValue *boolval = (MBBoolItemValue *)item;
						if([boolval valueData] == NO)
						{
							return MBLocaleStr(@"No");
						}
						else
						{
							return MBLocaleStr(@"Yes");			
						}
					}
					else if([itemval valuetype] == URLItemValueType)
					{
						MBURLItemValue *urlval = (MBURLItemValue *)item;
						return [[urlval valueData] absoluteString];
					}
					else if([itemval valuetype] == DateItemValueType)
					{
						MBDateItemValue *dateval = (MBDateItemValue *)item;
						return [dateval valueDataAsString];
					}
					else if([itemval valuetype] == CurrencyItemValueType)
					{
						MBCurrencyItemValue *numval = (MBCurrencyItemValue *)item;
						return [numval valueData];
					}
					else if([itemval valuetype] == FileItemValueType)
					{
						MBFileItemValue *fileval = (MBFileItemValue *)itemval;
						NSString *linkval = [fileval linkValueAsString];
						// if it is no link then it has been imported
						if([fileval isLink])
						{
							// display the link
							return [NSString stringWithFormat:@"%@: %@",MBLocaleStr(@"Link"),linkval];
						}
						else
						{
							// display as imported
							return [NSString stringWithFormat:@"%@: %@",MBLocaleStr(@"Imported"),linkval];
						}
					}
					else if([itemval valuetype] == ImageItemValueType)
					{
						MBImageItemValue *imgval = (MBImageItemValue *)item;
						NSString *linkval = [imgval linkValueAsString];
						// if it is no link then it has been imported
						if([imgval isLink])
						{
							// display the link
							return [NSString stringWithFormat:@"%@: %@",MBLocaleStr(@"Link"),linkval];
						}
						else
						{
							// display as imported
							return [NSString stringWithFormat:@"%@: %@",MBLocaleStr(@"Imported"),linkval];
						}
					}
					else
					{
						MBLOG(MBLOG_WARN,@"[MBTypeListViewController -objectValueForTableColumn]: unregognized valuetype!");
						return @"";					
					}
				}
			}
		}
	}
	
	return @"test";
}

/**
\brief is it allowed to edit this cell?
*/
- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(int)row
{
	MBCommonItem *item = nil;
	item = [[self currentData] objectAtIndex:row];
	
	if(item == nil)
	{
		MBLOG(MBLOG_WARN,@"[MBTypeListViewController -shouldEditTableColumn:] have a nil item!");
	}
	else
	{
		// check for reference
		if((([item identifier] == ItemRefID) ||
			([item identifier] == ItemValueRefID)) &&
		   ([(MBRefItem *)item target] != nil))
		{
			
			item = [(MBRefItem *)item target];
		}
		
		if(NSLocationInRange([item identifier],ITEMVALUE_ID_RANGE) == NO)
		{
			return NO;
		}
		else
		{
			if([[aTableColumn identifier] isEqualToString:COL_IDENTIFIER_VALUE] == YES)
			{
				MBItemValue *itemval = (MBItemValue *)item;
				
				// do not allow editing if this itemval is encrypted
				if([itemval encryptionState] == EncryptedState)
				{
					return NO;
				}
				else
				{
					// editing this coloumn for BoolItemValueType is forbidden
					if(([itemval valuetype] == BoolItemValueType) ||
					   ([itemval valuetype] == ExtendedTextItemValueType) ||
					   ([itemval valuetype] == DateItemValueType))
					{
						return NO;
					}
					else
					{
						return YES;
					}
				}
			}
			else
			{
				return YES;
			}
		}		
	}
	
	return NO;
}

/**
\brief NSTableViewDataSource delegate for changing a itemval of the tableview
*/
- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)row
{
	MBCommonItem *item = nil;
	item = [[self currentData] objectAtIndex:row];
	
	if(item == nil)
	{
		MBLOG(MBLOG_WARN,@"[MBTypeListViewController -shouldEditTableColumn:] have a nil item!");
	}
	else
	{
		// check for reference
		if(([item identifier] == ItemRefID) ||
			([item identifier] == ItemValueRefID))
		{
			
			item = [(MBRefItem *)item target];
		}

		// ref items that do not have a target are not allowed here
		if(item != nil)
		{
			// check for class
			if(NSLocationInRange([item identifier],ITEMVALUE_ID_RANGE))
			{
				MBItemValue *itemval = (MBItemValue *)item;

				if(itemval != nil)
				{
					if([(NSString *)[aTableColumn identifier] isEqualToString:COL_IDENTIFIER_NAME] == YES)
					{
						// set itemval name
						[itemval setName:anObject];
					}
					else if([(NSString *)[aTableColumn identifier] isEqualToString:COL_IDENTIFIER_VALUE] == YES)
					{
						// get datacell
						NSCell *cell = [aTableColumn dataCellForRow:row];
						if(cell == nil)
						{
							MBLOG(MBLOG_WARN,@"[MBTypeListViewController -setObjectValue]: cannot get dataCell!");
						}
						
						// get values according to valuetype
						if([itemval valuetype] == SimpleTextItemValueType)
						{
							MBTextItemValue *textval = (MBTextItemValue *)itemval;
							// formatter for text cells is nil
							[textval setValueData:anObject];
						}
						// get values according to valuetype
						else if([itemval valuetype] == ExtendedTextItemValueType)
						{
							//MBTextValue *textval = item;
							// this is not allowed
							// formatter for text cells is nil
							//[itemval setValueData:anObject];
						}
						else if([itemval valuetype] == NumberItemValueType)
						{
							MBNumberItemValue *numval = (MBNumberItemValue *)itemval;
							// set itemval in model
							[numval setValueData:anObject];
						}
						// Bool setting is forbidden
						else if([itemval valuetype] == BoolItemValueType)
						{
							MBBoolItemValue *boolval = (MBBoolItemValue *)itemval;
							// set itemval in model
							[boolval setValueData:[anObject boolValue]];
						}
						else if([itemval valuetype] == URLItemValueType)
						{
							MBURLItemValue *urlval = (MBURLItemValue *)itemval;
							[urlval setValueData:[NSURL URLWithString:anObject]];
						}
						else if([itemval valuetype] == DateItemValueType)
						{
							//MBDateItemValue *dateval = (MBDateItemValue *)itemval;
							// set itemval in model
							//[dateval setValueData:anObject];
						}
						else if([itemval valuetype] == CurrencyItemValueType)
						{
							MBNumberItemValue *numval = (MBNumberItemValue *)itemval;
							// set itemval in model
							[numval setValueData:anObject];
						}
						else if([itemval valuetype] == FileItemValueType)
						{
						}
						else if([itemval valuetype] == ImageItemValueType)
						{
						}
						else
						{
							MBLOG(MBLOG_WARN,@"[MBTypeListViewController -setObjectValue]: unregognized valuetype!");
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
- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(int)row
{
	MBCommonItem *item = nil;
	item = [[self currentData] objectAtIndex:row];
		
	if(item == nil)
	{
		MBLOG(MBLOG_WARN,@"[MBTypeListViewController -shouldSelectRow:] have a nil item!");
	}
	else
	{
		// check for reference
		if((([item identifier] == ItemRefID) ||
			([item identifier] == ItemValueRefID)) &&
		   ([(MBRefItem *)item target] != nil))
		{
			
			item = [(MBRefItem *)item target];
		}
		
		if(NSLocationInRange([item identifier],ITEMVALUE_ID_RANGE) == NO)
		{
			return NO;
		}
		else
		{
			return YES;
		}
	}
	
	return NO;
}

/**
\brief the tableview selection has changed
 If reference itemvalues are selected, they stay as is
*/
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	// get the object
	NSTableView *tView = [aNotification object];
	
	// get the selected row
	if(tView != nil)
	{
		NSIndexSet *selectedRows = [tView selectedRowIndexes];
		int len = [selectedRows count];
		NSMutableArray *selection = [NSMutableArray arrayWithCapacity:len];		
		id itemval = nil;
		if(len > 0)
		{
			unsigned int indexes[len];
			[selectedRows getIndexes:indexes maxCount:len inIndexRange:nil];
			
			for(int i = 0;i < len;i++)
			{
				itemval = [[self currentData] objectAtIndex:indexes[i]];
				if(itemval != nil)
				{
					[selection addObject:itemval];
				}
				else
				{
					MBLOG(MBLOG_WARN,@"[MBTypeListViewController -tableViewSelectionDidChange:] problem at getting selected item, it is nil!");
				}
			}
			
			// activate show button
			[showButton setEnabled:YES];
		}
		
		// set it
		[self setCurrentSelection:selection];
	}
	else
	{
		MBLOG(MBLOG_WARN,@"tv_selectionDidChange: tableview is nil!");
	}
}

/**
\brief alter cell display of tableview according to content
*/
- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(int)row
{
	MBCommonItem *item = nil;
	item = [[self currentData] objectAtIndex:row];
	
	if(item == nil)
	{
		MBLOG(MBLOG_WARN,@"[MBTypeListViewController -willDisplayCell:] have a nil item!");
	}
	else
	{
		// check for reference
		if((([item identifier] == ItemRefID) ||
		   ([item identifier] == ItemValueRefID)) &&
		   ([(MBRefItem *)item target] != nil))
		{
			
			item = [(MBRefItem *)item target];
		}
		
		if(NSLocationInRange([item identifier],ITEMVALUE_ID_RANGE) == NO)
		{
			// set Std Bold font for call
			NSFont *font = MBStdBoldTableViewFont;
			[aCell setFont:font];
			// set row height according to used font
			// get font height
			float pointSize = [font pointSize];
			[aTableView setRowHeight:pointSize+5];
		}
		else
		{
			// set Std Bold font for call
			NSFont *font = MBStdTableViewFont;
			[aCell setFont:font];
			// set row height according to used font
			// get font height
			float pointSize = [font pointSize];
			[aTableView setRowHeight:pointSize+5];
			
			// check tableColumn
			if([(NSString *)[aTableColumn identifier] isEqualToString:COL_IDENTIFIER_NAME] == YES)
			{
				// do nothing
			}
			else if([(NSString *)[aTableColumn identifier] isEqualToString:COL_IDENTIFIER_VALUE] == YES)
			{
				MBItemValue *itemval = (MBItemValue *)item;
				
				// if encrypted set a nil cell
				if([itemval encryptionState] == EncryptedState)
				{
					[aCell setFormatter:nil];
				}
				else
				{
					if(([itemval valuetype] == ExtendedTextItemValueType) || ([itemval valuetype] == SimpleTextItemValueType))
					{
						// reset formatter to nil
						[aCell setFormatter:nil];
					}
					else if([itemval valuetype] == NumberItemValueType)
					{
						// set format
						NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
						[numberFormatter setFormat:[defaults objectForKey:MBDefaultsNumberFormatKey]];
						 // supply cell with number formatter
						 [aCell setFormatter:numberFormatter];
					}
					else if([itemval valuetype] == BoolItemValueType)
					{
						// reset formatter to nil
						[aCell setFormatter:nil];
					}
					else if([itemval valuetype] == URLItemValueType)
					{
						[aCell setFormatter:nil];
					}
					else if([itemval valuetype] == DateItemValueType)
					{
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
					}
					else if([itemval valuetype] == CurrencyItemValueType)
					{
						// set format
						NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
						[currencyFormatter setFormat:[defaults objectForKey:MBDefaultsCurrencyFormatKey]];
						// supply cell with currency formatter
						[aCell setFormatter:currencyFormatter];
					}
					else if([itemval valuetype] == FileItemValueType)
					{
						[aCell setFormatter:nil];
					}
					else if([itemval valuetype] == ImageItemValueType)
					{
						[aCell setFormatter:nil];
					}
					else
					{
						[aCell setFormatter:nil];
					}
				}
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
- (NSString *)tableView:(NSTableView *)aTableView toolTipForTableColumn:(NSTableColumn *)aTableColumn row:(int)row
{
	MBLOG(MBLOG_DEBUG,@"[MBTypeListViewController -tableView:toolTipForCell:toolTipForTableColumn:row:]");

	NSString *tooltip = nil;
	
	MBCommonItem *item = nil;
	item = [[self currentData] objectAtIndex:row];
	
	if(item != nil)
	{
		// check for reference
		if(([item identifier] == ItemRefID) ||
		   ([item identifier] == ItemValueRefID))
		{
			item = [(MBRefItem *)item target];
		}
		
		// check type
		if(NSLocationInRange([item identifier],ITEMVALUE_ID_RANGE))
		{
			MBItemValue *itemval = (MBItemValue *)item;

			// check tableColumn
			if([(NSString *)[aTableColumn identifier] isEqualToString:COL_IDENTIFIER_NAME] == YES)
			{
				// if encrypted set a nil cell
				if([itemval encryptionState] == EncryptedState)
				{
					tooltip = MBLocaleStr(@"Encrypted");
				}
				else
				{
					tooltip = [itemval comment];
				}
			}
			else if([(NSString *)[aTableColumn identifier] isEqualToString:COL_IDENTIFIER_VALUE] == YES)
			{
				// if encrypted set a nil cell
				if([itemval encryptionState] == EncryptedState)
				{
					tooltip = MBLocaleStr(@"Encrypted");
				}
				else
				{
					if(([itemval valuetype] == SimpleTextItemValueType) ||
					   ([itemval valuetype] == NumberItemValueType) ||
					   ([itemval valuetype] == CurrencyItemValueType) ||
					   ([itemval valuetype] == BoolItemValueType) ||
					   ([itemval valuetype] == DateItemValueType))
					{
						tooltip = [itemval comment];
					}
					else if([itemval valuetype] == URLItemValueType)
					{
						tooltip = [[(MBURLItemValue *)itemval valueData] absoluteString];
					}
					else if([itemval valuetype] == ExtendedTextItemValueType)
					{
						tooltip = [(MBExtendedTextItemValue *)itemval linkValueAsString];
					}
					else if([itemval valuetype] == FileItemValueType)
					{
						tooltip = [(MBFileItemValue *)itemval linkValueAsString];
					}
					else if([itemval valuetype] == ImageItemValueType)
					{
						tooltip = [(MBImageItemValue *)itemval linkValueAsString];
					}
				}
			}
			else
			{
				// if encrypted set a nil cell
				if([itemval encryptionState] == EncryptedState)
				{
					tooltip = MBLocaleStr(@"Encrypted");
				}
				else
				{
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
- (void)tableView:(NSTableView *)aTableView sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
	MBLOG(MBLOG_DEBUG,@"[MBTypeListViewController -tableView:sortDescriptorsDidChange:]");

	// and display
	[self figureAndDisplayTableData];
}

// -------------------------------------------------------------------
// Notifications
// -------------------------------------------------------------------
/**
\brief after adding a new created ItemValue to an item this Notification is send
 */
- (void)itemValueAdded:(NSNotification *)aNotification
{
	// get notification object
	MBItemValue *addedItemVal = [aNotification object];
	
	if(addedItemVal != nil)
	{
		// get row of item
		int rowNumber = [currentData indexOfObject:addedItemVal];
		// select item
		[listTableView selectRow:rowNumber byExtendingSelection:NO];
	}
	else
	{
		MBLOG(MBLOG_WARN,@"[MBItemOutlineViewController -itemValueAdded:] added ItemValue is nil!");
	}
}

- (void)appWillTerminate:(NSNotification *)aNotification
{
	MBLOG(MBLOG_DEBUG,@"[MBTypeListViewController appWillTerminate:]!");

	appTerminating = YES;
}

// callback for tableview changes
- (void)itemValueAttribsChanged:(NSNotification *)aNotification
{
	MBLOG(MBLOG_DEBUG,@"[MBTypeListViewController itemValueAttribsChangedNotification:]!");

	if(aNotification != nil)
	{
		[self figureAndDisplayTableData];
	}
}

/**
\brief this notification is send if the selected element has changed
 */
- (void)reloadTableView:(NSNotification *)aNotification
{
	MBLOG(MBLOG_DEBUG,@"[MBTypeListViewController reloadTableView:]");
	
	if(aNotification != nil)
	{
		// deselect all and redisplay
		[listTableView deselectAll:nil];
		[self figureAndDisplayTableData];
	}
}

/**
\brief this notification is send if an itemValue has been added or removed
*/
- (void)itemValueListChanged:(NSNotification *)aNotification
{
	MBLOG(MBLOG_DEBUG,@"[MBTypeListViewController itemValueListChanged:]");

	if(aNotification != nil)
	{
		// deselect all and redisplay
		[listTableView deselectAll:nil];
		[self figureAndDisplayTableData];
	}
}

// -------------------------------------------------------------------
// Actions
// -------------------------------------------------------------------
- (IBAction)searchInput:(id)sender
{
	MBLOG(MBLOG_DEBUG,@"[MBTypeListViewController -searchInput:]");
	
	[self setSearchString:[sender stringValue]];
	
	[self figureAndDisplayTableData];
}

- (IBAction)typeChange:(id)sender
{
	[self figureAndDisplayTableData];
}

- (IBAction)showButton:(id)sender
{
	// get the first value and take the item of it
	MBItemValue *itemval = [currentSelection objectAtIndex:0];
	
	// select item on outline view
	MBSendNotifyItemSelectionShouldChangeInOutlineView([NSArray arrayWithObject:[itemval item]]);
	
	// select itemval in tableview
	MBSendNotifyItemValueSelectionShouldChangeInTableView([NSArray arrayWithObject:itemval]);
}

@end
