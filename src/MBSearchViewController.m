// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import "MBSearchViewController.h"
#import "MBItem.h"
#import "globals.h"
#import "MBSearchController.h"
#import "MBPreferenceController.h"
#import "MBSearchResult.h"
#import "MBItemValue.h"
#import "MBSearchOutlineView.h"
#import "MBItemBaseController.h"
#import "CombinedImageTextCell.h"
#import "MBPasteboardType.h"
#import "MBExporter.h"
#import "MBRefItem.h"

#define MAX_SEARCH_FOR_TYPES	11

@interface MBSearchViewController (privateAPI)

- (void)search;
- (void)populateSearchInPopUpButton;
- (void)setSearchForSwitchButtonStatesForTypesDict:(NSDictionary *)dict;
- (void)initSearchForButtonSwitches;

- (void)setSearchInItem:(MBItem *)aItem;
- (MBItem *)searchInItem;

// the search String
- (void)setSearchString:(NSString *)aString;
- (NSString *)searchString;

- (void)setSearchForTypes:(NSMutableDictionary *)dict;
- (NSMutableDictionary *)searchForTypes;

@end

@implementation MBSearchViewController (privateAPI)

/**
 \brief the current search In Item gets set right bevor the search is started
 see -search method
*/
- (void)setSearchInItem:(MBItem *)aItem {
	if(searchInItem != aItem) {
		[aItem retain];
		[searchInItem release];
		searchInItem = aItem;
	}
}

- (MBItem *)searchInItem {
	return searchInItem;
}

- (void)setSearchForTypes:(NSMutableDictionary *)dict {
	if(dict != searchForTypes) {
		[dict retain];
		[searchForTypes release];
		searchForTypes = dict;
	}
}

- (NSMutableDictionary *)searchForTypes {
	return searchForTypes;
}

/**
 \brief this will init all button switches with the right names and tags
*/
- (void)initSearchForButtonSwitches {
	// set names and tags
	[searchForSTextButton setTag:TextItemValueID];
	[searchForSTextButton setTitle:SIMPLETEXT_ITEMVALUE_TYPE_NAME];

	[searchForETextButton setTag:ExtendedTextItemValueID];
	[searchForETextButton setTitle:EXTENDEDTEXT_ITEMVALUE_TYPE_NAME];

	[searchForNumberButton setTag:NumberItemValueID];
	[searchForNumberButton setTitle:NUMBER_ITEMVALUE_TYPE_NAME];

	[searchForCurrencyButton setTag:CurrencyItemValueID];
	[searchForCurrencyButton setTitle:CURRENCY_ITEMVALUE_TYPE_NAME];
	
	[searchForBoolButton setTag:BoolItemValueID];
	[searchForBoolButton setTitle:BOOL_ITEMVALUE_TYPE_NAME];
	
	[searchForDateButton setTag:DateItemValueID];
	[searchForDateButton setTitle:DATE_ITEMVALUE_TYPE_NAME];
	
	[searchForAlarmButton setTag:AlarmItemID];
	[searchForAlarmButton setTitle:ALARM_ITEM_TYPE_NAME];
	
	[searchForURLButton setTag:URLItemValueID];
	[searchForURLButton setTitle:URL_ITEMVALUE_TYPE_NAME];
	
	[searchForImageButton setTag:ImageItemValueID];
	[searchForImageButton setTitle:IMAGE_ITEMVALUE_TYPE_NAME];
	
	[searchForFileButton setTag:FileItemValueID];	
	[searchForFileButton setTitle:FILE_ITEMVALUE_TYPE_NAME];

	[searchForPDFButton setTag:PDFItemValueID];	
	[searchForPDFButton setTitle:PDF_ITEMVALUE_TYPE_NAME];
}

- (void)setSearchForSwitchButtonStatesForTypesDict:(NSDictionary *)dict {
	// we set the states of the buttons according to the dictionary
	[searchForSTextButton setState:(int)[searchController doSearchForItemsInDict:dict withID:TextItemValueID]];
	[searchForETextButton setState:(int)[searchController doSearchForItemsInDict:dict withID:ExtendedTextItemValueID]];
	[searchForNumberButton setState:(int)[searchController doSearchForItemsInDict:dict withID:NumberItemValueID]];
	[searchForCurrencyButton setState:(int)[searchController doSearchForItemsInDict:dict withID:CurrencyItemValueID]];
	[searchForBoolButton setState:(int)[searchController doSearchForItemsInDict:dict withID:BoolItemValueID]];
	[searchForDateButton setState:(int)[searchController doSearchForItemsInDict:dict withID:DateItemValueID]];
	[searchForAlarmButton setState:(int)[searchController doSearchForItemsInDict:dict withID:AlarmItemID]];
	[searchForURLButton setState:(int)[searchController doSearchForItemsInDict:dict withID:URLItemValueID]];
	[searchForImageButton setState:(int)[searchController doSearchForItemsInDict:dict withID:ImageItemValueID]];
	[searchForFileButton setState:(int)[searchController doSearchForItemsInDict:dict withID:FileItemValueID]];	
	[searchForPDFButton setState:(int)[searchController doSearchForItemsInDict:dict withID:PDFItemValueID]];	
}

/**
 \brief start the search
*/
- (void)search {
	// only search if the search string is longer than 0
	NSString *sString = [self searchString];
	if([sString length] > 0) {
		[searchProgress startAnimation:nil];
	
		NSUserDefaults *defaults = userDefaults;
		
		// set it
		[searchController setSearchForItems:searchForTypes];

		// search
		NSMutableDictionary *sResult = [[NSMutableDictionary alloc] init];
//		unsigned int time = [sc searchInCommonItemArray:[NSArray arrayWithObject:[self searchInItem]] 
//											  forString:sString 
//											  recursive:(BOOL)[defaults integerForKey:MBDefaultsSearchRecursiveKey]
//										 searchExternal:(BOOL)[defaults integerForKey:MBDefaultsSearchIncludeExternalKey] 
//										  caseSensitive:(BOOL)[defaults integerForKey:MBDefaultsSearchCaseSensitiveKey] 
//										 fileDataSearch:(BOOL)[defaults integerForKey:MBDefaultsSearchInFiledataKey] 
//												 result:sResult];
		NSString *error = @"";
		long time = [searchController searchDbWithinItem:[self searchInItem] 
                                               forString:sString 
                                                 doRegex:(BOOL)[[defaults objectForKey:MBDefaultsDoRegexSearchKey] intValue]
                                           caseSensitive:(BOOL)[[defaults objectForKey:MBDefaultsSearchCaseSensitiveKey] intValue]			
                                                  result:sResult
                                                   error:&error];

		// check for error
		if(time == -1) {
			// print error message in status
			NSString *resultString = [NSString stringWithFormat:@"Error on search: %@",error];
			[resultLabel setStringValue:resultString];
			// set noResultView to box
			[resultViewBox setContentView:noResultView];
		} else {
			// process the result. there should only be itemvalues
			NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
			NSEnumerator *iter = [[sResult allKeys] objectEnumerator];	// itemID
			NSNumber *key = nil;
			while((key = [iter nextObject])) {
				// get SearchResult which is assosiated with an ItemValue
				MBSearchResult *result = [sResult objectForKey:key];
				MBItemValue *itemval = (MBItemValue *)[result commonItem];
				
				// do we have an item in resultDict where we can add the value?
				MBItem *parent = [itemval item];
				NSNumber *parentId = [NSNumber numberWithInt:[parent itemID]];
				MBItem *item = [resultDict objectForKey:parentId];
				// if item is nil here, we have to make a flatcopy and add it to the resultDict
				if(item == nil) {
					// make copy and add
					item = [parent copyFlat];
					// set itemId
					[item setItemID:[parent itemID]];
					// add to dict
					[resultDict setObject:item forKey:parentId];
					// release
					[item release];
				}
				
				// copy itemval and add it to the copied item
				MBItemValue *valCopy = [itemval copy];
				// set the id
				[valCopy setItemID:[itemval itemID]];
				// add it to the item copy
				[item addItemValue:valCopy];
				// release
				[valCopy release];
			}
					
			// when we return, set the result dict and reload outlineview
			[self setSearchResult:[resultDict allValues]];
			
			if([resultDict count] > 0) {
				// set searchResultView to box
				[resultViewBox setContentView:searchResultView];
			} else {
				// set noResultView to box
				[resultViewBox setContentView:noResultView];
			}
			
			// reload data
			[resultOutlineView reloadData];

			// expand all
			iter = [searchResult objectEnumerator];
			id item = nil;
			while((item = [iter nextObject])) {
				[resultOutlineView expandItem:item];
			}		

			NSString *resultString = [NSString stringWithFormat:@"Found %d results in %ds:%dms",[sResult count],(time/1000),(time%1000)];
			[resultLabel setStringValue:resultString];
		}
		[sResult release];

		[searchProgress stopAnimation:nil];	
	} else {
		// set noResultView to box
		[resultViewBox setContentView:noResultView];
	}
}

- (void)populateSearchInPopUpButton
{
	// and tis menu
	NSMenu *menu = [[NSMenu alloc] init];

	NSMenuItem *mItem = [[NSMenuItem alloc] init];

	MBItemBaseController *ibc = itemController;
	
	if((searchInItem == nil) || (searchInItem == [ibc rootItem]))
	{
		// the first item should be all
		mItem = [[NSMenuItem alloc] init];
		[mItem setTitle:@"All"];
		[mItem setTag:[[ibc rootItem] itemID]];
		[mItem setTarget:self];
		[mItem setAction:@selector(searchInItemChange:)];
		[menu addItem:mItem];
		[mItem release];
	}
	else
	{
		// the first item should be all
		mItem = [[NSMenuItem alloc] init];
		[mItem setTitle:[searchInItem name]];
		[mItem setTag:[searchInItem itemID]];
		[mItem setTarget:self];
		[mItem setAction:@selector(searchInItemChange:)];
		[menu addItem:mItem];
		[mItem release];		
	}
	
	// the first item should be all
	mItem = [[NSMenuItem alloc] init];
	[mItem setTitle:@"All"];
	[mItem setTag:[[ibc rootItem] itemID]];
	[mItem setTarget:self];
	[mItem setAction:@selector(searchInItemChange:)];
	[menu addItem:mItem];
	[mItem release];
	// separator
	mItem = [NSMenuItem separatorItem];
	[menu addItem:mItem];	
	
	// itemController can build us a menu
	[itemController generateItemMenu:&menu 
						 forItemtype:-1 
							  ofItem:[ibc rootItem] 
					  withMenuTarget:self withMenuAction:@selector(searchInItemChange:)];
	
	// set menu in PopUpButton
	[searchInPopUpButton setMenu:menu];
	[menu release];
}

// the search String
- (void)setSearchString:(NSString *)aString {
	if(aString != searchString) {
		[aString retain];
		[searchString release];
		searchString = aString;
	}
}

- (NSString *)searchString {
	return searchString;
}

@end

@implementation MBSearchViewController

- (id)init {
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"cannot alloc MBSearchViewController!");		
	} else {
		// this is set to YES if app is terminating
		appTerminating = NO;
        
        searchController = [[MBSearchController alloc] init];
        
		// init search result array
		[self setSearchResult:[NSArray array]];
		[self setSearchForTypes:[NSMutableDictionary dictionaryWithDictionary:[searchController allSearchForItems]]];
		[self setSearchString:@""];
	}
	
	return self;
}

/**
\brief dealloc of this class is called on closing this document
 */
- (void)dealloc {
	// release saech string and search array
	[self setSearchResult:nil];
	[self setSearchString:nil];
	[self setSearchInItem:nil];
	[self setSearchForTypes:nil];
    [searchController release];

	[stdItemImage release];
	[tableItemImage release];
	[templateItemImage release];
	[trashcanEmptyItemImage release];
	[trashcanFullItemImage release];
	[rootTemplateItemImage release];
	[importItemImage release];
	
	// dealloc object
	[super dealloc];
}

- (void)awakeFromNib {
    // create menus
    //[self createNormalItemMenu];
    // set default menu
    //[itemValueTableView setMenu:normalItemMenu];
    
    // send the current sortdescriptors to itemController
    //[itemController setItemValueListSortDescriptors:[itemValueTableView sortDescriptors]];
    
    // store this value
    searchOptionsBoxRect = [searchOptionsBox frame];
    
    // insert CombinedImageTextCell for the one tablecolumn
    NSTableColumn *tableColumn = [resultOutlineView tableColumnWithIdentifier:RESULT_COL_IDENTIFIER_NAME];
    CombinedImageTextCell *imageTextCell = [[[CombinedImageTextCell alloc] init] autorelease];
    [imageTextCell setEditable:YES];
    [tableColumn setDataCell:imageTextCell];
    
    // load images
    stdItemImage = [[NSImage imageNamed:@"Folder_16"] retain];
    // tableItemImage
    tableItemImage = stdItemImage;
    // template
    templateItemImage = stdItemImage;
    
    // Ref Image
    itemRefImage = [[NSImage imageNamed:@"FolderRef_16"] retain];
    
    // system items
    rootTemplateItemImage = [[NSImage imageNamed:@"FolderSystem_16"] retain];
    importItemImage = [[NSImage imageNamed:@"FolderImports_16"] retain];
    
    // contact
    
    // trashcan empty
    trashcanEmptyItemImage = [[NSImage imageNamed:@"trashcan_empty"] retain];		
    // trashcan full
    trashcanFullItemImage = [[NSImage imageNamed:@"trashcan_full"] retain];		
    
    // init switch buttons, all
    [self initSearchForButtonSwitches];
    [self setSearchForSwitchButtonStatesForTypesDict:[self searchForTypes]];
    // activate all button
    [searchForAllTypesButton setState:1];
    
    // populate popupButton
    [self populateSearchInPopUpButton];
    
    // close the options
    //[optionsOnOffButton setState:1];
    //[self optionsOnOffSwitch:optionsOnOffButton];
    
    // make progress indicator threaded
    [searchProgress setUsesThreadedAnimation:YES];
    
    // set noResultView into resultViewBox
    [resultViewBox setContentView:noResultView];
    
    // register for drag and drop
    [resultOutlineView registerForDraggedTypes:[self validDragAndDropPbTypes]];
    
    // register notification 
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(appInitialized:)
                                                 name:MBAppInitializedNotification object:nil];				
    // register notification
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(appWillTerminate:)
                                                 name:MBAppWillTerminateNotification object:nil];
    // register notification
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(itemTreeChanged:)
                                                 name:MBItemTreeChangedNotification object:nil];
    // register notification
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(itemValueListChanged:)
                                                 name:MBItemValueListChangedNotification object:nil];
}

// the view itself
- (NSView *)theView {
	return theView;
}

// the tableView
- (NSOutlineView *)resultOutlineView {
	return resultOutlineView;
}

// the search result
- (void)setSearchResult:(NSArray *)aResult {
	if(aResult != searchResult) {
		[aResult retain];
		[searchResult release];
		searchResult = aResult;
	}
}

- (NSArray *)searchResult {
	return searchResult;
}

/**
 \brief types that this tableview can drag
*/
- (NSArray *)validDragAndDropPbTypes {
	return [NSArray arrayWithObjects:
		//IKAM_PB_TYPE_NAME,
		COMMON_ITEM_PB_TYPE_NAME,
		EXPORT_IKAMARCHIVE_TYPESTRING,
		NSFilenamesPboardType,
		NSFilesPromisePboardType,
		NSURLPboardType,
		NSStringPboardType,
		NSRTFPboardType,
		NSRTFDPboardType,
		nil];
}

- (void)applySearchString:(NSString *)aString {
    [self setSearchString:aString];
    [self search];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
}

#pragma mark - OutlineView datasource

/**
\brief give back number of childs of a specific item. if item == nil, we are at root
 */
- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
	int count = 0;
	
	if(item == nil) {
		// return first level items
		count = [searchResult count];
	} else {
		// check for reference
		if([(MBRefItem *)item identifier] == ItemRefID) {
			item = [(MBRefItem *)item target];
		}
		
		// nil references it not allowed
		if(item != nil) {
			if(NSLocationInRange([(MBCommonItem *)item identifier], ITEMVALUE_ID_RANGE)) {
				count = 0;
			} else {
				// we do need the children but the itemvalues
				count = [[(MBItem *)item itemValues] count];				
			}
		}
	}
	
	return count;
}

/**
\brief give back item that has been asked for
 */
- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item {
	MBItem *ret = nil;
	
	// is item is nil, we check root level
	if(item == nil) {
		// get first level search results
		ret = [searchResult objectAtIndex:index];
	} else {
		// check for reference
		if([(MBRefItem *)item identifier] == ItemRefID) {
			item = [(MBRefItem *)item target];
		}
		
		if(item != nil) {
			if(NSLocationInRange([(MBCommonItem *)item identifier],ITEMVALUE_ID_RANGE)) {
				ret = nil;
			} else {
				ret = [[(MBItem *)item itemValues] objectAtIndex:index];
			}
		}
	}	
	
	return ret;
}

/**
\brief if the item expandable?
 */
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item  {
	BOOL ret = NO;
	
	if(item != nil) {
		// check for reference
		if([(MBRefItem *)item identifier] == ItemRefID) {
			item = [(MBRefItem *)item target];
		}
		
		if(item != nil) {
			if(NSLocationInRange([(MBCommonItem *)item identifier],ITEMVALUE_ID_RANGE)) {
				ret = NO;
			} else {
				if([[(MBItem *)item itemValues] count] > 0) {
					ret = YES;
				}
			}
		}
	}
	
	return ret;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldExpandItem:(id)item {
	return YES;
}

/**
\brief give back value for column of item
 */
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
	id retVal = nil;
	
	if(item != nil) {
		// check for reference
		if(([(MBRefItem *)item identifier] == ItemRefID) &&
		   ([(MBRefItem *)item target] != nil)) {
			item = [(MBRefItem *)item target];
		}
		
		if([[tableColumn identifier] isEqualToString:RESULT_COL_IDENTIFIER_NAME] == YES) {
			// alter baseline of text
			//NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:10.0] forKey:NSBaselineOffsetAttributeName];
			//NSAttributedString *nameString = [[[NSAttributedString alloc] initWithString:[buf name] attributes:dict] autorelease];
			//retVal = nameString;			
			
			// both items and itemvalues provide -name
			retVal = [item name];
		} else if([[tableColumn identifier] isEqualToString:RESULT_COL_IDENTIFIER_TYPE] == YES) {
			retVal = [item typeAsString];
		}
	}
	
	return retVal;
}

/**
\brief outlineview item value should be changed. object holds the new information.
 */
/*
- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	// object should be a NSString
	if(object != nil)
	{
		// item is the item to be altered
		if(item != nil)
		{
			// check for reference
			if([(MBRefItem *)item identifier] == ItemRefID)
			{
				item = [(MBRefItem *)item target];
			}
			
			if(item != nil)
			{
				[item setValue:object forKey:[tableColumn identifier]];
			}
			
			// send notification that the atribvalues of item have changed
			//MBSendNotifyItemAttribsChanged(buf);
		}	
	}
}
*/

//--------------------------------------------------------------------
//----------- drag and drop methods for outlineview ------------------
//--------------------------------------------------------------------
/**
\brief method for lazy copy drag & drop types.
 types are:
 IKAM_PB_TYPE_NAME,		PList as string
 NSFilesPromisePboardType
 */
/*
- (void)pasteboard:(NSPasteboard *)pboard provideDataForType:(NSString *)type
{
	CocoLog(LEVEL_DEBUG,@"[MBItemOutlineViewController -pasteboard:provideDataForType:]!");
	
	// do this only if the app is not terminating
	if(appTerminating == YES)
	{	
		CocoLog(LEVEL_WARN,@"[MBItemOutlineViewController -pasteboard:provideDataForType:] app is terminating, we will not provide any data!");		
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
				CocoLog(LEVEL_DEBUG,@"[MBItemOutlineViewController -pasteboard:provideDataForType:] IKAM");
				
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
				CocoLog(LEVEL_DEBUG,@"[MBItemValueListViewController -pasteboard:provideDataForType:] ExtendedText");
				
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
				CocoLog(LEVEL_DEBUG,@"[MBItemValueListViewController -pasteboard:provideDataForType:] url");
				
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
				CocoLog(LEVEL_DEBUG,@"[MBItemValueListViewController -pasteboard:provideDataForType:] pdf");
				
				MBFileItemValue *val = (MBFileItemValue *)item;
				// export pdf data
				[pboard setData:[val valueData] forType:type];			
			}
			else if([type isEqualToString:NSTIFFPboardType] == YES)
			{
				CocoLog(LEVEL_DEBUG,@"[MBItemValueListViewController -pasteboard:provideDataForType:] tiff");
				
				MBImageItemValue *val = (MBImageItemValue *)item;
				// export image data
				[pboard setData:[val valueData] forType:type];			
			}
			
			// release pool
			[myArp release];
		}
	}
}
*/

/**
\brief this method is invoked if we call -dragdragPromisedFilesOfTypes:fromRect:source:slideBack:event:
 in outlineView:writeItems:toPasteboard:
 But if using this method, no internal drag and drop is possible
 */
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
\brief these items are selected and are dragged
 check, if there are items that may not be dragged, e.g. SystemItems
 */
/*
- (BOOL)outlineView:(NSOutlineView *)oView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pboard
{
	CocoLog(LEVEL_DEBUG,@"outlineView:writeItems:toPasteboard:");
	// we make a lazy copy here
	
	// copy items
	[itemController setDraggingItems:items];	// lazy copy
	[pboard declareTypes:[NSArray arrayWithObjects:COMMON_ITEM_PB_TYPE_NAME,NSFilesPromisePboardType,nil] owner:self];
	
	// type ITEM
	[pboard setData:[NSData data] forType:COMMON_ITEM_PB_TYPE_NAME];
	
	// IKAM archive
	//[pboard setData:[NSData data] forType:IKAM_PB_TYPE_NAME];
	
	// promised file
	[pboard setPropertyList:[NSArray arrayWithObjects:EXPORT_IKAMARCHIVE_TYPESTRING,nil] forType:NSFilesPromisePboardType];
	 int rowIndex = [oView rowForItem:[items objectAtIndex:0]];
	 // get current row rect
//	 NSRect rowRect = [oView rectOfRow:rowIndex];	
//	 [oView dragPromisedFilesOfTypes:[NSArray arrayWithObject:EXPORT_IKAMARCHIVE_TYPESTRING] 
//							fromRect:rowRect
//							  source:self 
//						   slideBack:YES 
//							   event:mouseDownEvent];
	
	return YES;
}
*/

/**
\brief this method is called to validate the target of the drag operation
 */
/*
- (NSDragOperation)outlineView:(NSOutlineView *)oView 
				  validateDrop:(id<NSDraggingInfo>)info 
				  proposedItem:(id)item 
			proposedChildIndex:(int)index
{
	//CocoLog(LEVEL_DEBUG,@"outlineView:validateDrop:proposeditem:proposedchildIndex");
	
	NSPasteboard *pb = [info draggingPasteboard];
	
	//CocoLog(LEVEL_DEBUG,@"drag mask bevor: %d",[info draggingSourceOperationMask]);
	
	// set std operation
	int stdOp = NSDragOperationNone;
	if([info draggingSourceOperationMask] == NSDragOperationCopy)
	{
		stdOp = NSDragOperationCopy;
	}
	else if(([info draggingSourceOperationMask] & NSDragOperationMove) == NSDragOperationMove)
	{
		stdOp = NSDragOperationMove;
	}
	
	// check for reference
	if([(MBRefItem *)item identifier] == ItemRefID)
	{
		item = [(MBRefItem *)item target];
		// dragging to a ref value is not allowed if the target is nil
		if(item == nil)
		{
			return NSDragOperationNone;
		}
	}
	
	// check for type
	NSString *type = [pb availableTypeFromArray:[self validDragAndDropPbTypes]];
	if(type == nil)
	{
		// seems we do not support this type
		return NSDragOperationNone;		
	}
	else
	{
		// we have a type
		if([type isEqualToString:COMMON_ITEM_PB_TYPE_NAME] == YES)
		{
			// has values?
			BOOL hasValues = NO;
			// check for SystemItems
			NSEnumerator *iter = [[itemController draggingItems] objectEnumerator];
			MBCommonItem *mbItem = nil;
			while((mbItem = [iter nextObject]))
			{
				// dragging SYStem Items is not allowed
				if(NSLocationInRange([mbItem identifier],SYSTEMITEM_ID_RANGE))
				{
					return NSDragOperationNone;
				}
				//else if(NSLocationInRange([mbItem identifier],ITEM_ID_RANGE))
				//{
				//}
					else if(NSLocationInRange([mbItem identifier],ITEMVALUE_ID_RANGE))
					{
						hasValues = YES;
					}
			}		
			
			// if we have values, we may not drop to root
			if(item == nil)
			{
				// for item = nil we are dragging to root
				// root template, trashcan and import are the last three items - ever
				if(index >= ([oView numberOfRows] - 3))
				{
					return NSDragOperationNone;		
				}
				
				if(hasValues)
				{
					return NSDragOperationNone;
				}				
			}
			else if(item == [itemController trashcanItem])
			{
				// to trashcan we move
				return NSDragOperationMove;
			}
			else if(item == [itemController templateItem])
			{
				// to templates itemvalues cannot be dragged
				// items are copied
				if(hasValues)
				{
					return NSDragOperationNone;
				}
				
				return NSDragOperationCopy;
			}
			else if(item == [itemController importItem])
			{
				// to imports we cannot drag
				return NSDragOperationNone;
			}
		}
		else
		{
			// all other are treated as itemvalues
			// additionally they may not be dropped to trashcan
			// dropping to root is not allowed
			if(item == nil)
			{
				return NSDragOperationNone;			
			}
			else
			{
				// dropping not allowed in RootTemplate Item
				if((item == [itemController templateItem]) ||
				   (item == [itemController trashcanItem]))
				{
					return NSDragOperationNone;
				}
			}
		}
	}
	
	return stdOp;
}
*/

/**
\brief this method is called if the mouse button has been released and data is dropped at a target
 */
/*
-(BOOL)outlineView:(NSOutlineView *)oView acceptDrop:(id <NSDraggingInfo>)info item:(id)item childIndex:(int)index
{
	CocoLog(LEVEL_DEBUG,@"outlineView:acceptDrop:item:childIndex");
	
	// check for reference
	if([(MBRefItem *)item identifier] == ItemRefID)
	{
		item = [(MBRefItem *)item target];
	}
	
	// init importer
	MBImporter *importer = [MBImporter defaultImporter];
	
	NSPasteboard *pb = [info draggingPasteboard];
	// get pb type
	NSString *type = [pb availableTypeFromArray:[self validDragAndDropPbTypes]];
	
	if(type != nil)
	{
		CocoLog(LEVEL_DEBUG,type);
		CocoLog(LEVEL_DEBUG,[pb stringForType:type]);
		
		unsigned int sourceMask = [info draggingSourceOperationMask];
		CocoLog(LEVEL_DEBUG,@"operationMask: %d",sourceMask);
		
		// identify drag operation
		int operation = MoveOperation;
		if(sourceMask == NSDragOperationCopy)
		{
			operation = CopyOperation;
		}
		else if((sourceMask & NSDragOperationMove) == NSDragOperationMove)
		{
			operation = MoveOperation;
		}
		else
		{
			operation = CopyOperation;
		}
		
		if([type isEqualToString:COMMON_ITEM_PB_TYPE_NAME] == YES)
		{
			// draggedItems has the dragged data, now move it
			// item is the target
			[itemController addObjects:[itemController draggingItems] 
								toItem:item 
							 withIndex:index 
				 withConnectingObjects:YES
							 operation:operation];
			
			// update views
			MBSendNotifyItemTreeChanged(nil);
			MBSendNotifyItemValueListChanged(nil);
		}
		// external
		else if([type isEqualToString:NSFilenamesPboardType] == YES)
		{
			// get array of Filenames
			NSArray *filenames = [pb propertyListForType:type];
			NSEnumerator *iter = [filenames objectEnumerator];
			NSString *file = nil;
			while((file = [iter nextObject]))
			{
				CocoLog(LEVEL_DEBUG,file);
			}
			
			// import
			[importer fileValueImport:filenames toItem:item];
		}
		else if([type isEqualToString:NSFilesPromisePboardType] == YES)
		{
			CocoLog(LEVEL_DEBUG,[pb stringForType:type]);
			
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
			[importer fileValueImport:filenames toItem:item];
		}
		else if([type isEqualToString:NSURLPboardType] == YES)
		{
			NSArray *urlList = [pb propertyListForType:type];
			NSURL *url = [NSURL URLWithString:[urlList objectAtIndex:0]];
			CocoLog(LEVEL_DEBUG,[url absoluteString]);
			
			[importer urlValueImport:url toItem:item asTransaction:YES];
		}
		else if([type isEqualToString:NSStringPboardType] == YES)
		{
			NSString *text = [pb stringForType:type];
			CocoLog(LEVEL_DEBUG,text);
			
			[importer eTextValueImport:[text dataUsingEncoding:NSUTF8StringEncoding] toItem:item forType:TextTypeTXT asTransaction:YES];
		}
		else if([type isEqualToString:NSRTFPboardType] == YES)
		{
			NSData *textData = [pb dataForType:type];
			
			[importer eTextValueImport:textData toItem:item forType:TextTypeRTF asTransaction:YES];			
		}
		else if([type isEqualToString:NSRTFDPboardType] == YES)
		{
			NSData *textData = [pb dataForType:type];
			
			[importer eTextValueImport:textData toItem:item forType:TextTypeRTFD asTransaction:YES];			
		}
	}
	else
	{
		return NO;
	}
	
	return YES;
}
*/

/**
\brief delegate method for promised files
 This method if only available on Tiger and above systems
 \todo --- use threaded progressindicator sheet for this action
 */
/*
- (NSArray *)outlineView:(NSOutlineView *)outlineView namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropDestination 
		 forDraggedItems:(NSArray *)items
{
	CocoLog(LEVEL_DEBUG,@"outlineView:namesOfPromisedFilesDroppedAtDestination:forDraggedItems:");
	CocoLog(LEVEL_DEBUG,@"dropDestination: %@",[dropDestination absoluteString]);
	
	NSMutableArray *promisedNames = [NSMutableArray array];
	
	// start global progress indicator
	MBSendNotifyProgressIndicationActionStarted(nil);
	
	// with drag and promising filenames we try to export native types
	MBExporter *exporter = [MBExporter defaultExporter];
	
	// there must be items in draggingList
	//NSArray *valList = [itemController draggingItems];
	//NSEnumerator *iter = [valList objectEnumerator];
	NSEnumerator *iter = [items objectEnumerator];
	MBItem *item = nil;
	while((item = [iter nextObject]))
	{
		// guess filename
		NSString *name = [exporter guessFilenameFor:item];
		NSString *extension = [exporter guessFileExtensionFor:item];
		NSString *filename = [exporter generateFilenameWithExtension:extension 
														fromFilename:name];
		
		// get URL, extract relativePath component and add filename, then export
		NSString *exportName = [[dropDestination relativePath] stringByAppendingPathComponent:filename];
		NSString *exportedFilename = @"";
		[exporter exportAsNative:item toFile:exportName exportedFile:&exportedFilename exportedData:nil];
		
		// add filename to array
		[promisedNames addObject:exportedFilename];
	}
	
	// start global progress indicator
	MBSendNotifyProgressIndicationActionStopped(nil);
	
	return promisedNames;	
}
*/

#pragma mark - NSTableView delegates

- (void)outlineView:(NSOutlineView *)aOutlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	// display call with std font
	NSFont *font = MBStdTableViewFont;
	[cell setFont:font];
	// set row height according to used font
	// get font height
	//float imageHeight = [[(CombinedImageTextCell *)cell image] size].height; 
	float pointSize = [font pointSize];
	[aOutlineView setRowHeight:pointSize+6];
	//[aOutlineView setRowHeight:imageHeight];
	
	// check for reference
	BOOL isItemRef = NO;
	BOOL isValueRef = NO;
	int identifier = [(MBRefItem *)item identifier];
	
	if(([(MBRefItem *)item identifier] == ItemRefID) &&
	   ([(MBRefItem *)item target] != nil)) {
		isItemRef = YES;
		item = [(MBRefItem *)item target];
	} else if(([(MBRefItem *)item identifier] == ItemValueRefID) &&
			([(MBRefItem *)item target] != nil)) {
		isValueRef = YES;
		item = [(MBRefItem *)item target];
	}

	// get identifier again
	identifier = [(MBCommonItem *)item identifier];
    
	if([[tableColumn identifier] isEqualToString:RESULT_COL_IDENTIFIER_NAME] == YES) {
		CombinedImageTextCell *imageCell = cell;

		// is item?
		if(NSLocationInRange(identifier, ITEM_ID_RANGE)) {
			MBItem *buf = item;
			if(isItemRef) {
				[imageCell setImage:itemRefImage];		
			} else {
				switch([buf itemtype]) {
					case StdItemType:
					case TableItemType:
						[imageCell setImage:stdItemImage];
						break;
					case ItemRefType:
						[imageCell setImage:itemRefImage];
						break;
					case RootContactItemType:
						[imageCell setImage:stdItemImage];
						break;
					case RootTemplateItemType:
						[imageCell setImage:rootTemplateItemImage];
						break;					
					case ImportItemType:
						[imageCell setImage:importItemImage];
						break;					
					case TrashcanItemType:
						[imageCell setImage:trashcanFullItemImage];
						break;
					default:
						[imageCell setImage:stdItemImage];
				}
			}
		} else {
			// is itemvalue
			[imageCell setImage:nil];
		}
	}
}

/**
\brief should this outlineview item be selected?
 */
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
    return YES;
}

/**
\brief should this outlineview item be editable?
 */
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	// check for reference
	if((([(MBRefItem *)item identifier] == ItemRefID) || ([(MBRefItem *)item identifier] == ItemValueRefID)) &&
	   ([(MBRefItem *)item target] != nil)) {
		item = [(MBRefItem *)item target];
	}
	
	// changing name of system item si not allowed
	if(NSLocationInRange([(MBCommonItem *)item identifier],SYSTEMITEM_ID_RANGE) == YES) {
		return NO;
	}
	
	return YES;
}

/**
\brief may outlineview change to another item?
 */
- (BOOL)selectionShouldChangeInOutlineView:(NSOutlineView *)outlineView {
	return YES;
}

/**
 Notification is called when the selection has changed
 
 After determining the item which has been selected it is set in ItemBaseController.
 ItemBasEcontroller is responsible for sending Notifications to all Views that should update their views.
 */
- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
	//CocoLog(LEVEL_DEBUG,@"[MBItemListViewController outlineViewSelectionDidChange:]");
	
	if(notification != nil) {
		NSOutlineView *oview = [notification object];
		if(oview != nil) {
			BOOL itemSelected = NO;
			// set CurrentSelItem in ItemBaseController
			NSIndexSet *selectedRows = [oview selectedRowIndexes];
			MBCommonItem *item = nil;
			int len = [selectedRows count];
			NSMutableArray *itemSelection = [NSMutableArray array];
			NSMutableArray *itemValueSelection = [NSMutableArray array];		
			if(len > 0) {
				unsigned int indexes[len];
				[selectedRows getIndexes:indexes maxCount:len inIndexRange:nil];
				
				for(int i = 0;i < len;i++) {
					item = [oview itemAtRow:indexes[i]];

					// get real item
					item = [itemController commonItemForId:[item itemID]];
					
					if(NSLocationInRange([item identifier],ITEMVALUE_ID_RANGE)) {
						[itemValueSelection addObject:item];
						itemSelected = NO;
					} else {
						[itemSelection addObject:item];					
						itemSelected = YES;
					}
				}
			}
			
			// set selection
			if(itemSelected == NO) {
				// send notification
				// first select the item to the itemvalue
				NSArray *items = nil;
				if([itemValueSelection count] > 0) {
					items = [NSArray arrayWithObject:[[itemValueSelection objectAtIndex:0] item]];
				}
				MBSendNotifyItemSelectionShouldChangeInOutlineView(items);
				[itemController setCurrentItemValueSelection:itemValueSelection];
				MBSendNotifyItemValueSelectionShouldChangeInTableView(itemValueSelection);
			} else {
				[itemController setCurrentItemSelection:itemSelection];
				// send notification
				MBSendNotifyItemSelectionShouldChangeInOutlineView(itemSelection);
			}
			
			/*
			 // check selection for changing the outlineView menu
			 if(len == 1)
			 {
				 // check for reference
				 if((([(MBRefItem *)item identifier] == ItemRefID) || ([(MBRefItem *)item identifier] == ItemValueRefID)) &&
					([(MBRefItem *)item target] != nil))
				 {
					 item = (MBItem *)[(MBRefItem *)item target];
				 }
				 
				 if([(MBItem *)item itemtype] == TrashcanItemType)
				 {
					 // set trashcan menu
					 [oview setMenu:trashcanItemMenu];
				 }
				 else if([(MBItem *)item itemtype] == RootTemplateItemType)
				 {
					 // set template menu
					 [oview setMenu:templateItemMenu];
				 }
				 else if([(MBItem *)item itemtype] == ImportItemType)
				 {
					 // set import menu
					 [oview setMenu:importItemMenu];
				 }
				 else
				 {
					 // set normal menu
					 [oview setMenu:normalItemMenu];
				 }
			 }
			 else	// len > 1
			 {
				 // set normal menu
				 [oview setMenu:normalItemMenu];
			 }
			 */
		//}
		//else	// len <= 0
		//{
			// set normal menu
			//[oview setMenu:normalItemMenu];
		//}
		
		// set selection
		//[self setCurrentSelection:selection];
		// set the selection in itemController
		//[ibc setCurrentItemSelection:selection];
		
		
		} else {
			CocoLog(LEVEL_WARN,@"[MBItemOutlineViewController outlineViewSelectionDidChange:] have a nil notification object!");
		}
	} else {
		CocoLog(LEVEL_WARN,@"[MBItemOutlineViewController outlineViewSelectionDidChange:] have a nil notification!");
	}
}

/**
 \brief for sorting
*/
- (void)outlineView:(NSOutlineView *)outlineView sortDescriptorsDidChange:(NSArray *)oldDescriptors {
	NSArray *newArray = [searchResult sortedArrayUsingDescriptors:[outlineView sortDescriptors]];
	// set sorted array
	[self setSearchResult:newArray];
	// reload
	[resultOutlineView reloadData];
}

#pragma mark - Notifications

/**
 Notification that the application has finished with initialization
 Now the item outlineview can be reread
*/
- (void)appInitialized:(NSNotification *)aNotification {
	// search in Root item by default
	[self setSearchInItem:[itemController rootItem]];
}

- (void)appWillTerminate:(NSNotification *)aNotification {
	CocoLog(LEVEL_DEBUG,@"[MBSearchViewController -appWillTerminate:]!");
	appTerminating = YES;
}

- (void)itemTreeChanged:(NSNotification *)aNotification {
	// check, if our current searchInItem still exists
	if(searchInItem != nil) {
		[self setSearchInItem:(MBItem *)[itemController commonItemForId:[searchInItem itemID]]];
	}
	// repopulate popupbutton
	[self populateSearchInPopUpButton];
	
	// delete current search
	[self setSearchResult:[NSArray array]];
	// reload outlineview
	[resultOutlineView reloadData];
}

- (void)itemValueListChanged:(NSNotification *)aNotification {
	// delete current search
	[self setSearchResult:[NSArray array]];
	// reload outlineview
	[resultOutlineView reloadData];	
}

#pragma mark - Actions

- (IBAction)startSearch:(id)sender {
	CocoLog(LEVEL_DEBUG,@"[MBSearchViewController -startSearch:]");
    [self search];
}

- (IBAction)allTypesSwitch:(id)sender {
	// check state
	if([(NSButton *)sender state] == NSOffState) {
		// create empty dict and set the buttons
		[self setSearchForTypes:[NSMutableDictionary dictionary]];
		[self setSearchForSwitchButtonStatesForTypesDict:[self searchForTypes]];
	} else if([(NSButton *)sender state] == NSOnState) {
		// activate all
		// get all dictionary
		[self setSearchForTypes:[NSMutableDictionary dictionaryWithDictionary:[searchController allSearchForItems]]];
		[self setSearchForSwitchButtonStatesForTypesDict:[self searchForTypes]];
	} else if([(NSButton *)sender state] == NSMixedState) {
		// we have no mixed state by clicking
		// set NSOnState
		[(NSButton *)sender setState:NSOnState];
		[self allTypesSwitch:sender];
	}
}

- (IBAction)singleTypeSwitch:(id)sender {
	NSNumber *ident = [NSNumber numberWithInt:[sender tag]];
	
	BOOL active = (BOOL)[(NSButton *)sender state];
	if(active) {
		// add
		// get name
		NSString *name = [[searchController allSearchForItems] objectForKey:ident];
		
		[searchForTypes setObject:name forKey:ident];
		if([searchForTypes count] == MAX_SEARCH_FOR_TYPES) {
			// set all button to On
			[searchForAllTypesButton setState:NSOnState];
		} else if([searchForAllTypesButton state] == NSOffState) {
            // if all button is in Off state, set it to mixed state
			[searchForAllTypesButton setState:NSMixedState];
		}
	} else {
		// remove
		[searchForTypes removeObjectForKey:ident];
		if([searchForTypes count] == 0) {
			// set all button to Off
			[searchForAllTypesButton setState:NSOffState];
		} else if([searchForAllTypesButton state] == NSOnState) {
            // if all button is in On state, set it to mixed state
			[searchForAllTypesButton setState:NSMixedState];
		}
	}
}

- (IBAction)optionsOnOffSwitch:(id)sender {
	// change sizes of views
	NSRect newOptionsBoxRect = [searchOptionsBox frame];
	NSRect newResultBoxRect = [resultViewBox frame];
	if([(NSButton *)sender state]) {
        // show options
		// upper
		newOptionsBoxRect.origin.y = newOptionsBoxRect.origin.y - searchOptionsBoxRect.size.height;
		newOptionsBoxRect.size.height = searchOptionsBoxRect.size.height;
		// lower
		newResultBoxRect.size.height = newResultBoxRect.size.height - searchOptionsBoxRect.size.height;
	} else {
        // hide options
		// upper
		newOptionsBoxRect.origin.y = newOptionsBoxRect.origin.y + searchOptionsBoxRect.size.height;
		newOptionsBoxRect.size.height = 0.0;
		// lower
		newResultBoxRect.size.height = newResultBoxRect.size.height + searchOptionsBoxRect.size.height;
	}
	
	// set new sizes
    [searchOptionsBox setFrame:newOptionsBoxRect];
	[resultViewBox setFrame:newResultBoxRect];
	
	// redisplay the whole view
	[theView setNeedsDisplay:YES];
}

- (IBAction)searchInItemChange:(id)sender {
	// set the new searchInItem
	[self setSearchInItem:(MBItem *)[itemController commonItemForId:[sender tag]]];
	
	// repopulate popupbutton
	[self populateSearchInPopUpButton];
}

- (IBAction)matchTypeChange:(id)sender {
	// match type changed
	// get searchcontroller and set it
	[searchController setMatchType:(MBMatchType)[sender tag]];
}


@end
