// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <CocoLogger/CocoLogger.h>
#import "MBItemBaseController.h"
#import "MBBaseDefinitions.h"
#import "MBGeneralPrefsViewController.h"
#import "MBSystemItem.h"
#import "globals.h"
#import "MBStdItem.h"
#import "MBElement.h"
#import "MBTextItemValue.h"
#import "MBExtendedTextItemValue.h"
#import "MBNumberItemValue.h"
#import "MBCurrencyItemValue.h"
#import "MBBoolItemValue.h"
#import "MBURLItemValue.h"
#import "MBDateItemValue.h"
#import "MBImageItemValue.h"
#import "MBPDFItemValue.h"
#import "MBElementBaseController.h"
#import "MBDBAccess.h"
#import "MBAppInfoItem.h"
#import "MBRefItem.h"

@interface MBItemBaseController (privateAPI)

- (NSDictionary *)commonItemDict;
- (void)setCommonItemDict:(NSMutableDictionary *)aDict;

// item navigation array
- (void)setItemNavigationBuffer:(NSMutableArray *)aArray;
- (NSMutableArray *)itemNavigationBuffer;

@end

@implementation MBItemBaseController

#pragma mark - Initialization

+ (MBItemBaseController *)standardController {
	static MBItemBaseController *sharedSingleton;

	if(sharedSingleton == nil) {
		sharedSingleton = [[MBItemBaseController alloc] init];
	}
	
	return sharedSingleton;
}

/**
 \brief init will create the item base, so this object is ready for use
 */
- (id)init {
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"cannot alloc MBItemBaseController!");		
	} else {
		// set controller state init
		[self setState:InitState];

		// set root item
		[self setRootItem:nil];		// gets set later
		
		// init navigation array
		[self setItemNavigationBuffer:[NSMutableArray array]];
		itemNavigationBufferIndex = -1;
		
		// init dicts
		[self setCommonItemDict:[NSMutableDictionary dictionary]];		
		
		// init current items
		[self setCurrentItemSelection:[NSMutableArray array]];
		// init current itemValue
		[self setCurrentItemValueSelection:[NSMutableArray array]];
		
		// init default sortdescriptors
		[self setItemValueListSortDescriptors:[NSArray array]];
		
		// init the undo manager
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		undoManager = [[NSUndoManager alloc] init];
        [undoManager setLevelsOfUndo:(NSUInteger) [[defaults valueForKey:MBDefaultsUndoStepsKey] intValue]];
		
		// set controller state normal
		[self setState:NormalState];
	}
	
	return self;
}

/**
\brief dealloc of this class is called on closing this document
 */
- (void)dealloc {
	// get rid of undo manager
	[self setUndoManager:nil];

	// get rid of undoItem
	[self setUndoItem:nil];
    
	// init dicts
	[self setCommonItemDict:nil];
	
	// nil itemValueListSortDescriptors
	[self setItemValueListSortDescriptors:nil];
	
	// lists
	[self setCurrentItemSelection:nil];
	[self setCurrentItemValueSelection:nil];
	
	[self setItemNavigationBuffer:nil];
	
	// dealloc object
    [rootItem release];
    [appInfoItem release];
    [super dealloc];
}

//--------------------------------------------------------------------
//----------- bundle delegates ---------------------------------------
//--------------------------------------------------------------------
/**
\brief gets called if the nib file has been loaded. all gfx objacts are available now.
 */
- (void)awakeFromNib {
    // register some NSUserDefaults changes
    [[NSUserDefaults standardUserDefaults] addObserver:self 
                                            forKeyPath:MBDefaultsUndoStepsKey
                                               options:NSKeyValueObservingOptionNew context:nil];
}


#pragma mark - Getter/Setter

- (void)setState:(int)aState {
	state = aState;
}

- (int)state {
	return state;
}

- (void)setUndoItem:(MBSystemItem *)aItem {
	[aItem retain];
	[undoItem release];
	undoItem = aItem;
}

- (MBSystemItem *)undoItem {
	return undoItem;
}

- (void)setTrashcanItem:(MBSystemItem *)aItem {
	trashcanItem = aItem;
}

- (MBSystemItem *)trashcanItem {
	return trashcanItem;
}

- (void)setTemplateItem:(MBSystemItem *)aItem {
	templateItem = aItem;
}

- (MBSystemItem *)templateItem {
	return templateItem;
}

- (void)setImportItem:(MBSystemItem *)aItem {
	importItem = aItem;
}

- (MBSystemItem *)importItem {
	return importItem;
}

- (void)setAppInfoItem:(MBAppInfoItem *)aItem {
	[aItem retain];
	[appInfoItem release];
	appInfoItem = aItem;
}

- (MBAppInfoItem *)appInfoItem {
	return appInfoItem;
}

- (void)setRootItem:(MBItem *)aItem {
	[aItem retain];
	[rootItem release];
	rootItem = aItem;
}

- (MBItem *)rootItem {
	return rootItem;
}

- (NSUndoManager *)undoManager {
	return undoManager;
}

- (void)setUndoManager:(NSUndoManager *)aManager {
	if(aManager != undoManager) {
		[aManager retain];
		[undoManager release];
		undoManager = aManager;
	}
}

/**
 Everytime in ItemValueList the sortdescriptors are changed they are sent here.
 */
- (void)setItemValueListSortDescriptors:(NSArray *)desc {
	[desc retain];
	[itemValueListSortDescriptors release];
	itemValueListSortDescriptors = desc;
}

- (NSArray *)itemValueListSortDescriptors {
	return itemValueListSortDescriptors;
}

/**
 Sets the current selected (in outlineview) items. Can be 0 or more items. we support multiple selection.
 */
- (void)setCurrentItemSelection:(NSMutableArray *)aSelection {
	[aSelection retain];
	[currentItemSelection release];
	currentItemSelection = aSelection;
	
	// everytime new item(s) are selected, sort the itemvalues with the current sort descriptors
	[self sortItemValuesOfItems:currentItemSelection usingSortDescriptors:[self itemValueListSortDescriptors]];
	
	// send notification to start main progressindicator
	MBSendNotifyProgressIndicationActionStarted(nil);
	
	// send notification of changed selected item
	// mainly, this is for all views that display information of the selected item
	MBSendNotifyItemSelectionChanged(currentItemSelection);
    
	// send notification to stop main progressindicator
	MBSendNotifyProgressIndicationActionStopped(nil);
}

/**
 \brief returns the current selection of items
 */
- (NSMutableArray *)currentItemSelection {
	return currentItemSelection;
}

/**
 \brief sets the current selected (in tableview) itemValue. Only a reference is saved here.
 @param aItemValue the itemValue that has been selected
 */
- (void)setCurrentItemValueSelection:(NSMutableArray *)aSelection {
	[aSelection retain];
	[currentItemValueSelection release];
	currentItemValueSelection = aSelection;
	
	// send notification to start main progressindicator
	MBSendNotifyProgressIndicationActionStarted(nil);
    
	// send notification of changed selected item
	MBSendNotifyItemValueSelectionChanged(currentItemValueSelection);
    
	// send notification to stop main progressindicator
	MBSendNotifyProgressIndicationActionStopped(nil);
}

/**
 \brief returns a reference of the current selected itemValue
 @return reference of current selected itemValue
 */
- (NSMutableArray *)currentItemValueSelection {
	return currentItemValueSelection;
}

/**
 \brief tries to figure out the current selection, which is either itemValue or item selection
 */
- (NSMutableArray *)currentSelection {
	if([currentItemValueSelection count] > 0) {
		return currentItemValueSelection;
	} else {
		return currentItemSelection;
	}	
}

#pragma mark - Navigation

/**
 \brief select the last visited item in visited array.
 @returns: number of items that are possible to go backward
*/
- (int)itemNavigationBackward {
	/*
	if((itemNavigationBufferIndex > 0) && (itemNavigationBufferIndex < [itemNavigationBuffer count]))
	{
		// decrement index and grab the item with the index
		--itemNavigationBufferIndex;
		MBItem *item = [itemNavigationBuffer objectAtIndex:itemNavigationBufferIndex];
		if(item == nil)
		{
			CocoLog(LEVEL_WARN,@"[MBItemBaseController -itemNavigationBackward]: item is nil!"); 
		}
		else
		{
			// send notification that item navigatioln controls should select another item
			MBSendNotifyItemSelectionShouldChange(item);
		}
	}
	 */

	return itemNavigationBufferIndex;
}

/**
\brief select the next item in visited items array in forward direction
 @returns: number of items that are possible to go forward
 */
- (int)itemNavigationForward {
	/*
	if((itemNavigationBufferIndex > 0) && (itemNavigationBufferIndex < [itemNavigationBuffer count]))
	{
		// increment index and grab the item with the index
		itemNavigationBufferIndex++;
		MBItem *item = [itemNavigationBuffer objectAtIndex:itemNavigationBufferIndex];
		if(item == nil)
		{
			CocoLog(LEVEL_WARN,@"[MBItemBaseController -itemNavigationBackward]: item is nil!"); 
		}
		else
		{
			// send notification that item navigatioln controls should select another item
			MBSendNotifyItemSelectionShouldChange(item);
		}
	}
	*/
	
	return ([itemNavigationBuffer count] - itemNavigationBufferIndex);
}

#pragma mark - Upper ItemBase methods

/**
 \brief returns the current item list
 @returns NSArray with all items
 */
- (NSArray *)rootItemList {
	return [rootItem children];
}

/**
 \brief get the template item with this id
 */
- (MBItem *)templateItemById:(int)aId {
	NSEnumerator *iter = [[templateItem children] objectEnumerator];
	MBItem *item = nil;
	while((item = [iter nextObject])) {
		if([item itemID] == aId) {
			return item;
		}
	}
	
	return nil;
}

/**
\brief delete the items that currently are selected
 
 if no item is selected, do nothing
 */
- (void)delCurrentItemSelection {
	[self removeObjects:currentItemSelection];
	
	// send notification
	MBSendNotifyItemTreeChanged(nil);
	// clean selection
	[self setCurrentItemSelection:[NSMutableArray array]];
}

- (void)delCurrentItemValueSelection {
	// remove itemValue
	[self removeObjects:currentItemValueSelection];
	
	// send notification
	MBSendNotifyItemValueListChanged(nil);
	// clean selection
	[self setCurrentItemValueSelection:[NSMutableArray array]];
}

/**
 \brief delete the current selection. either this is an item or an itemValue
*/
- (void)delCurrentSelection {
	// first check, if there is a selection
	// if it is not, nothing can be deleted
	if(([currentItemValueSelection count] == 0) && ([currentItemSelection count] == 0)) {
		// no item can be selected
		// bring up alert
        NSAlert *alert = [NSAlert alertWithMessageText:MBLocaleStr(@"Warning") 
                                         defaultButton:MBLocaleStr(@"OK") 
                                       alternateButton:nil 
                                           otherButton:nil 
                             informativeTextWithFormat:MBLocaleStr(@"CannotDelCurrentSelection")];
        [alert runModal];
	} else {
		if([currentItemValueSelection count] > 0) {
			[self delCurrentItemValueSelection];
		} else {
			[self delCurrentItemSelection];
		}
	}
}

- (void)buildItemBase {
	// set controller state
	[self setState:InitState];
	
	// get root Item
	MBItem *root = [[[MBItem alloc] initWithInitializedElement:[elementController rootElement]] autorelease];

	// set
	[self setRootItem:root];

	// sort item list
	// list has already been sorted by each item
	//[self sortChildrenOfItem:root withWritingSortorder:NO recursive:YES];

	// build item list
	//[self buildItemBaseForItem:root];
	
	// set controller state
	[self setState:NormalState];
}

/**
\brief build the item base tree
 the underlying elementtree has been created
 each item will initialize its own subtree, we just start things on root elements
 */
- (void)buildItemBaseForItem:(MBItem *)aItem {
	NSArray *aList = [[aItem element] children];

	// go through list
	NSEnumerator *iter = [aList objectEnumerator];
	MBElement *elem = nil;
	while((elem = [iter nextObject])) {
        int identifier = [[elem identifier] intValue];
        if(NSLocationInRange(identifier,ITEM_ID_RANGE)) {
            if(![aItem isLoadedWithChilds]) {
                switch(identifier) {
                    case StdItemID:
                    {
                        // create item out of element
                        MBStdItem *item = [[[MBStdItem alloc] initWithInitializedElement:elem] autorelease];
                        // add to child list
                        [aItem addChildItem:item];
                        break;
                    }
                    case ItemRefID:
                    {
                        MBRefItem *item = [[[MBRefItem alloc] initWithInitializedElement:elem] autorelease];
                        // add item
                        [aItem addChildItem:item];
                        break;						
                    }
                }                
            }
        } else if(NSLocationInRange(identifier, SYSTEMITEM_ID_RANGE)) {
            if(![aItem isLoadedWithChilds]) {
                id item = nil;
                switch(identifier) {
                    case AppInfoItemID:
                        // app info item must not be added to rootlist
                        item = [[[MBAppInfoItem alloc] initWithInitializedElement:elem] autorelease];
                        [self setAppInfoItem:item];
                        break;
                    case TrashcanItemID:
                        item = [[[MBSystemItem alloc] initWithInitializedElement:elem] autorelease];
                        [self setTrashcanItem:item];
                        // add item
                        [aItem addChildItem:item];
                        break;
                    case ImportItemID:
                        item = [[[MBSystemItem alloc] initWithInitializedElement:elem] autorelease];
                        [self setImportItem:item];
                        // add item
                        [aItem addChildItem:item];
                        break;
                    case RootTemplateItemID:
                        item = [[[MBSystemItem alloc] initWithInitializedElement:elem] autorelease];
                        [self setTemplateItem:item];
                        // add item
                        [aItem addChildItem:item];
                        break;
                    default:
                        item = [[[MBSystemItem alloc] initWithInitializedElement:elem] autorelease];		
                        // add item
                        [aItem addChildItem:item];
                        break;
                }
            }
        } else if(NSLocationInRange(identifier, ITEMVALUE_ID_RANGE)) {
            // not loaded yet?
            if(![aItem isLoadedWithValues]) {
                id itemval = nil;
                switch(identifier) {
                    case TextItemValueID:
                        itemval = [[[MBTextItemValue alloc] initWithInitializedElement:elem] autorelease];
                        break;
                    case ExtendedTextItemValueID:
                        itemval = [[[MBExtendedTextItemValue alloc] initWithInitializedElement:elem] autorelease];
                        break;
                    case NumberItemValueID:
                        itemval = [[[MBNumberItemValue alloc] initWithInitializedElement:elem] autorelease];
                        break;
                    case CurrencyItemValueID:
                        itemval = [[[MBCurrencyItemValue alloc] initWithInitializedElement:elem] autorelease];
                        break;
                    case BoolItemValueID:
                        itemval = [[[MBBoolItemValue alloc] initWithInitializedElement:elem] autorelease];
                        break;
                    case URLItemValueID:
                        itemval = [[[MBURLItemValue alloc] initWithInitializedElement:elem] autorelease];
                        break;
                    case DateItemValueID:
                        itemval = [[[MBDateItemValue alloc] initWithInitializedElement:elem] autorelease];
                        break;
                    case FileItemValueID:
                        itemval = [[[MBFileItemValue alloc] initWithInitializedElement:elem] autorelease];
                        break;
                    case ImageItemValueID:
                        itemval = [[[MBImageItemValue alloc] initWithInitializedElement:elem] autorelease];
                        break;			
                    case PDFItemValueID:
                        itemval = [[[MBPDFItemValue alloc] initWithInitializedElement:elem] autorelease];
                        break;
                    case ItemValueRefID:
                        itemval = [[[MBRefItem alloc] initWithInitializedElement:elem] autorelease];
                        break;
                }
                // add to value list
                [aItem addItemValue:itemval];                
            }
        } else {
            CocoLog(LEVEL_ERR,@"unrecognized item identifier!");
        }
        
        // sort according to sort oder
        [self sortChildrenOfItem:aItem withWritingSortorder:YES recursive:NO];
	}
	
	// sort item list
//	[self sortItemData];
}

/**
 \brief check for SystemItems, if this is the first start or System items are missing, create them
*/
- (int)checkAndPrepareSystemItems {
	// check for visible system items like templates, trashcan, imports
	// and invisible like AppInfo, Undo
	
	// set controller state
	[self setState:InitState];

	// first check invisible
	// if this is the first start there exist no element
	// get elementcontroller
	BOOL firstStart = NO;
	NSArray *rootList = [elementController rootElementList];
	if([rootList count] == 0) {
		firstStart = YES;
	}
	
	if(!firstStart) {
		// check existence of tree elements
		
		// trashcan
		if([self trashcanItem] == nil) {
			// create trashcan item
			MBSystemItem *trashcan = [[[MBSystemItem alloc] initWithDb] autorelease];
			// add to tree
			[self addItem:trashcan toItem:rootItem withIndex:-1 withConnectingItem:YES operation:AddOperation withDbTransaction:YES];
			// set some values
			[trashcan setName:TRASHCAN_ITEMTYPE_NAME];
			[trashcan setIdentifier:TrashcanItemID];
			[trashcan setItemtype:TrashcanItemType];
			[trashcan setSortorder:TrashcanItemSortorder];
			[self setTrashcanItem:trashcan];
		}

		// template
		if([self templateItem] == nil) {
			// create template rootitem
			MBSystemItem *template = [[[MBSystemItem alloc] initWithDb] autorelease];
			// add to tree
			[self addItem:template toItem:rootItem withIndex:-1 withConnectingItem:YES operation:AddOperation withDbTransaction:YES];
			// set some values
			[template setName:ROOT_TEMPLATE_ITEMTYPE_NAME];
			[template setIdentifier:RootTemplateItemID];
			[template setItemtype:RootTemplateItemType];
			[template setSortorder:TemplateItemSortorder];
			[self setTemplateItem:template];
		}
		
		// imports
		if([self importItem] == nil) {
			// create imports item
			MBSystemItem *import = [[[MBSystemItem alloc] initWithDb] autorelease];
			// add to tree
			[self addItem:import toItem:rootItem withIndex:-1 withConnectingItem:YES operation:AddOperation withDbTransaction:YES];
			// set some values
			[import setName:IMPORTS_ITEMTYPE_NAME];
			[import setIdentifier:ImportItemID];
			[import setItemtype:ImportItemType];
			[import setSortorder:ImportItemSortorder];
			[self setImportItem:import];			
		}
		
		// appinfo
		if([self appInfoItem] == nil) {
			CocoLog(LEVEL_ERR, @"have no AppInfoItem, critical, starting with default values!");
			MBAppInfoItem *appInfo = [[[MBAppInfoItem alloc] initWithDb] autorelease];
			// add it to the element, tree not to the item tree
			// we don't need item in the root item list
			[elementController addElement:[appInfo element] toElement:[rootItem element] withConnectingChild:NO isMoveOp:NO isTransaction:NO];
			[self setAppInfoItem:appInfo];
		}
	} else {
		MBDBAccess *dbCon = [MBDBAccess sharedConnection];
		// make transaction
		[dbCon sendBeginTransaction];
		
		// create all needed elements new
		MBAppInfoItem *appInfo = [[[MBAppInfoItem alloc] initWithDb] autorelease];
		// add it to the element, tree not to the item tree
		[elementController addElement:[appInfo element] toElement:[rootItem element] withConnectingChild:NO isMoveOp:NO isTransaction:NO];	// we don't need item in the root item list
		[self setAppInfoItem:appInfo];
		
		// create trashcan item
		MBSystemItem *trashcan = [[[MBSystemItem alloc] initWithDb] autorelease];
		// add to tree
		[elementController addElement:[trashcan element] toElement:[rootItem element] withConnectingChild:NO isMoveOp:NO isTransaction:NO];
        [rootItem addChildItem:trashcan];
		//[self addItem:trashcan toItem:rootItem withIndex:-1 withConnectingItem:NO operation:AddOperation withDbTransaction:NO];
		// set some values
		[trashcan setName:TRASHCAN_ITEMTYPE_NAME];
		[trashcan setIdentifier:TrashcanItemID];
		[trashcan setItemtype:TrashcanItemType];
		[trashcan setSortorder:TrashcanItemSortorder];
		[self setTrashcanItem:trashcan];
		
		// create template rootitem
		MBSystemItem *template = [[[MBSystemItem alloc] initWithDb] autorelease];
		// add to element tree
		[elementController addElement:[template element] toElement:[rootItem element] withConnectingChild:NO isMoveOp:NO isTransaction:NO];
		//[self addItem:template toItem:rootItem withIndex:-1 withConnectingItem:NO operation:AddOperation withDbTransaction:NO];
		// set some values
		[template setName:ROOT_TEMPLATE_ITEMTYPE_NAME];
		[template setIdentifier:RootTemplateItemID];
		[template setItemtype:RootTemplateItemType];
		[template setSortorder:TemplateItemSortorder];
		[self setTemplateItem:template];
		
		// create imports item
		MBSystemItem *import = [[[MBSystemItem alloc] initWithDb] autorelease];
		// add to tree
		[elementController addElement:[import element] toElement:[rootItem element] withConnectingChild:NO isMoveOp:NO isTransaction:NO];
		//[self addItem:import toItem:rootItem withIndex:-1 withConnectingItem:NO operation:AddOperation withDbTransaction:NO];
		// set some values
		[import setName:IMPORTS_ITEMTYPE_NAME];
		[import setIdentifier:ImportItemID];
		[import setItemtype:ImportItemType];
		[import setSortorder:ImportItemSortorder];
		[self setImportItem:import];
		
		// send end transaction
		[dbCon sendCommitTransaction];
	}
	
	// add undo element for every start
	MBSystemItem *undo = [[[MBSystemItem alloc] init] autorelease];
	[undo setIdentifier:UndoItemID];
	[self setUndoItem:undo];

	// set controller state
	[self setState:NormalState];

	return 0;
}

- (void)loadChildsForItem:(MBItem *)aItem {
	// load the complete level for this item
	MBElementBaseController *ebc = [MBElementBaseController standardController];
	[ebc loadChildElementsForElement:[aItem element] withIdentifier:@"1__"];
	
	// build item base over that
	[self buildItemBaseForItem:aItem];
	
	// set item loaded
	[aItem setIsLoadedWithChilds:YES];
}

- (void)loadValuesForItem:(MBItem *)aItem; {
	// load the complete level for this item
	MBElementBaseController *ebc = [MBElementBaseController standardController];
	[ebc loadChildElementsForElement:[aItem element] withIdentifier:@"_"];
	
	// build item base over that
	[self buildItemBaseForItem:aItem];

	// set item loaded
	[aItem setIsLoadedWithValues:YES];
}

/**
 \brief checks if a destination item exists where new values or items can be added ot dropped
*/
- (MBItem *)creationDestinationWithWarningPanel:(BOOL)warningPanel {
	MBItem *dest = nil;

	// check for number of selected items
	int selectionCount = [currentItemSelection count];
	if(selectionCount == 0) {
		// no item can be selected
		if(warningPanel) {
            NSAlert *alert = [NSAlert alertWithMessageText:MBLocaleStr(@"Warning") 
                                             defaultButton:MBLocaleStr(@"OK") 
                                           alternateButton:nil 
                                               otherButton:nil 
                                 informativeTextWithFormat:MBLocaleStr(@"CannotAddItemValueNoSelectedItem")];
            [alert runModal];
		} else {
            CocoLog(LEVEL_WARN, @"[MBItemBaseController -createDestinationWithWarningPanel:] no selection!");
        }
	} else if(selectionCount > 1) {
		// more than one item selected
		if(warningPanel) {
            NSAlert *alert = [NSAlert alertWithMessageText:MBLocaleStr(@"Warning") 
                                             defaultButton:MBLocaleStr(@"OK") 
                                           alternateButton:nil 
                                               otherButton:nil 
                                 informativeTextWithFormat:MBLocaleStr(@"Please select ONE Item!")];
            [alert runModal];
		} else {
            CocoLog(LEVEL_WARN, @"[MBItemBaseController -createDestinationWithWarningPanel:] Only one selected target is allowed!");        
        }
	} else {
		dest = [currentItemSelection objectAtIndex:0];
	}
	
	return dest;
}

#pragma mark - Registration

/**
 \brief every new item has to register here
*/
- (void)registerCommonItem:(MBCommonItem *)aItem withId:(int)aId {
	NSString *idAsString = [[NSNumber numberWithInt:aId] stringValue];	
	if([commonItemDict valueForKey:idAsString] == nil) {
		//CocoLog(LEVEL_DEBUG,@"[MBItemBaseController -registerCommonItem:] item with id: %@",idAsString);
		[commonItemDict setObject:aItem forKey:idAsString];
	} else {
		CocoLog(LEVEL_WARN,@"[MBItemBaseController -registerCommonItem:withId:] item already exists!");
	}
}

/**
\brief on deleting an item, every item and children have to deregister here
 */
- (void)deregisterCommonItemWithId:(int)aId {
	NSString *idAsString = [[NSNumber numberWithInt:aId] stringValue];
	[commonItemDict removeObjectForKey:idAsString];
}

/**
\brief get an item instance for an id
 */
- (MBCommonItem *)commonItemForId:(int)aId {
	NSString *idAsString = [[NSNumber numberWithInt:aId] stringValue];
	MBCommonItem *item = [commonItemDict valueForKey:idAsString];
	if(item == nil) {
		CocoLog(LEVEL_DEBUG, @"[MBItemBaseController -commonItemForId:] could not find item with id: %@",idAsString);
	}
	
	return item;
}

/**
 \brief get all registered common items as a flat array
*/
- (NSArray *)allRegisteredCommonItems {
	return [commonItemDict allValues];
}

#pragma mark - Lists for identifiers

/**
 Get list of items/itemvalues for the specified identifier
*/
- (NSArray *)listForIdentifier:(MBTypeIdentifier)identifier {
	CocoLog(LEVEL_DEBUG,@"[MBItemBaseController -listForIdentifier:] start collecting...");
	
	// the return
	NSMutableArray *ret = [NSMutableArray array];
	
	// get list of all registered commonItems
	NSArray *list = [commonItemDict allValues];
	
	// go through list and collect items with the specifier identifier
	NSEnumerator *iter = [list objectEnumerator];
	MBCommonItem *buf = nil;
	while((buf = [iter nextObject])) {
		// check identifier
		if([buf identifier] == identifier) {
			// collect
			[ret addObject:buf];
		}
	}

	CocoLog(LEVEL_DEBUG,@"[MBItemBaseController -listForIdentifier:] finished collecting");
	
	return ret;
}

/**
 \brief get list for identifier range
*/
- (NSArray *)listForIdentifierRange:(NSRange)range {
	CocoLog(LEVEL_DEBUG,@"[MBItemBaseController -listForIdentifierRange:] start collecting...");
	
	// the return
	NSMutableArray *ret = [NSMutableArray array];
	
	// get list of all registered commonItems
	NSArray *list = [commonItemDict allValues];
	
	// go through list and collect items with the specifier identifier
	NSEnumerator *iter = [list objectEnumerator];
	MBCommonItem *buf = nil;
	while((buf = [iter nextObject])) {
		// check identifier
		if(NSLocationInRange([buf identifier],range)) {
			// collect
			[ret addObject:buf];
		}
	}
	
	CocoLog(LEVEL_DEBUG,@"[MBItemBaseController -listForIdentifierRange:] finished collecting");
	
	return ret;	
}

#pragma mark - Sorting

/**
 \brief this will sort the item data to the only sort key = sortorder
*/
- (void)sortChildrenOfItem:(MBItem *)item withWritingSortorder:(BOOL)writeSortorder recursive:(BOOL)r {
	// make sort descriptor
	NSSortDescriptor *sd = [[[NSSortDescriptor alloc] initWithKey:@"sortorder" ascending:YES] autorelease];
	NSArray *mySDs = [NSArray arrayWithObject:sd];

	if(item == nil) {
		// set item as root item
		item = rootItem;
	}
	
	if(writeSortorder) {
		// set sortorder according to arrayindex
		int len = [[item children] count];
		for(int i = 0;i < len;i++) {
			MBItem *buf = [[item children] objectAtIndex:i];
			if([buf sortorder] < SYSTEMITEM_SORTORDER_START) {
				// before writing new sortorders, set state of item to not normal
				// otherwise for each sortorder change a undo step will be made
				// TODO --- rethink this
				[buf setState:InitState];
				[buf setSortorder:i];
				[buf setState:NormalState];
			}
		}
	}

	/*
    NSEnumerator *iter = [[item children] objectEnumerator];
    MBItem *it = nil;
    while((it = [iter nextObject])) {
        CocoLog(LEVEL_DEBUG, @"itemname: %@, sortorder: %d", [it name], [it sortorder]);
    }
     */
    
	// sort root list
	[[item children] sortUsingDescriptors:mySDs];

    /*
    iter = [[item children] objectEnumerator];
    while((it = [iter nextObject])) {
        CocoLog(LEVEL_DEBUG, @"itemname: %@, sortorder: %d", [it name], [it sortorder]);
    }
     */
    
	if(r == YES) {
		// we must sort recursive
		NSEnumerator *iter = [[self rootItemList] objectEnumerator];
		MBItem *item = nil;
		while((item = [iter nextObject])) {
			[self sortChildrenOfItem:item usingSortDescriptors:mySDs];
		}
	}
}

/**
\brief this method is used to recursive sort the all items
 */
- (void)sortChildrenOfItem:(MBItem *)parent usingSortDescriptors:(NSArray *)newDescriptors {
	if(parent != nil) {
		NSMutableArray *children = [parent children];
		// sort at once
		[children sortUsingDescriptors:newDescriptors];
		// descent
		NSEnumerator *iter = [children objectEnumerator];
		id child = nil;
		while((child = [iter nextObject])) {
			[self sortChildrenOfItem:child usingSortDescriptors:newDescriptors];
		}
	} else {
		CocoLog(LEVEL_ERR,@"got a nil parent!");
	}
}

/**
\brief this method is used to sort all firstlevel itemvalues of the given item array
 */
- (void)sortItemValuesOfItems:(NSArray *)items usingSortDescriptors:(NSArray *)newDescriptors {
	NSEnumerator *iter = [items objectEnumerator];
	MBItem *item = nil;
	while((item = [iter nextObject])) {
		if([item identifier] == ItemRefID) {
			item = (MBItem *)[(MBRefItem *)item target];
		}

		// sorting the children of a reference item is now allowed if it has no target. because it simply has no children to sort
		if(item != nil) {
			if(!NSLocationInRange([item identifier],ITEMVALUE_ID_RANGE)) {
				NSMutableArray *itemValues = [item itemValues];
				// sort at once
				[itemValues sortUsingDescriptors:newDescriptors];
			}
		}
	}
}

/**
 \brief is this child somewhere in the subtree of this parent?
 Or is the parent parent of the child?
*/
- (BOOL)isChild:(MBItem *)child inSubtreeOfParent:(MBItem *)parent {
	// define return value
	BOOL ret = NO;

	// if parent = nil set to root
	if(parent == nil) {
		parent = [self rootItem];
	}
	
	MBItem *item = nil;
	// define startpoint
	item = child;
	while((item != parent) && (item != rootItem)) {
		item = [item parentItem];
	}
	
	// check
	if(item == parent) {
		ret = YES;
	}
	
	return ret;
}

//------------------------------------------------------------------
//------------------ generating menu stuff ---------------------
//------------------------------------------------------------------
/**
 \brief this method will generate a menu from the first level children of the root template item
*/
- (NSMenu *)generateTemplateMenuWithTarget:(id)aTarget withMenuAction:(SEL)aSelector {
	NSMenu *menu = [[[NSMenu alloc] init] autorelease];
	
	NSEnumerator *iter = [[templateItem children] objectEnumerator];
	MBItem *item = nil;
	while((item = [iter nextObject])) {
		NSMenuItem *mItem = [[NSMenuItem alloc] init];
		[mItem setTarget:aTarget];
		[mItem setAction:aSelector];
		[mItem setTitle:[item name]];
		[mItem setTag:[item itemID]];	// use id as tag, to identify later
		// add to menu
		[menu addItem:mItem];
		[mItem release];
	}
	
	return menu;
}

/**
\generate a menu structure with all found values of valuetype
 
 @params[in|out] subMenuItem is the start of the menustructure.
 @params[in] type valuetype to build menu for, -1 for all
 @params[in] item the main root item to start searching
 @params[in] aTarget the target object of the created menuitem
 @params[in] aSelector the selector of the target that should be called
 */
- (void)generateValueMenu:(NSMenu **)itemMenu 
			 forValuetype:(MBItemValueTypes)type 
			   ofItem:(MBItem *)item 
		   withMenuTarget:(id)aTarget 
		   withMenuAction:(SEL)aSelector {
	// is reference?
	BOOL isRef = NO;
	if([item identifier] == ItemRefID) {
		item = (MBItem *)[(MBRefItem *)item target];
		isRef = YES;
	}
	
	if(item != nil) {
		// go recursive through all items and search for URLItemValues
		NSEnumerator *i = [[item children] objectEnumerator];
		MBItem *child = nil;
		while((child = [i nextObject])) {
			// do this only, if we have a stdItem
			if(NSLocationInRange([child identifier],ITEM_ID_RANGE)) {
				// the menu for the values
				NSMenu *subMenu = nil;
				// first go deeper (Depth First Search)
				[self generateValueMenu:&subMenu 
						   forValuetype:type 
								 ofItem:child 
						 withMenuTarget:aTarget 
						 withMenuAction:aSelector];
				
				// is still nil ?
				if(subMenu != nil) {
					NSMenuItem *menuItem = [[NSMenuItem alloc] init];
					[menuItem setTitle:[child name]];
					// set submenu
					[menuItem setSubmenu:subMenu];
					[subMenu release];
					
					// check if parentMenu is nil
					if(*itemMenu == nil){
						*itemMenu = [[NSMenu alloc] init];
					}
					// add menuitem to given menu
					[*itemMenu addItem:menuItem];
					[menuItem release];
				}			
			}	
		}	
		
		if(!isRef) {
			// do this only, if we have a stdItem
			if(NSLocationInRange([item identifier],ITEM_ID_RANGE)) {
				// check all values
				NSEnumerator *i2 = [[item itemValues] objectEnumerator];
				MBItemValue *itemval = nil;
				while((itemval = [i2 nextObject])) {
					// we do not process references
					if([itemval identifier] != ItemValueRefID) {
						// we are looking for valuetype type
						if(([itemval valuetype] == type) || (type == -1)) {
							if(*itemMenu == nil) {
								*itemMenu = [[NSMenu alloc] init];
							}
							
							// take this itemvalue as menuitem
							NSMenuItem *menuItem = nil;
							
							menuItem = [[NSMenuItem alloc] init];
							[menuItem setTitle:[itemval name]];
							//[menuItem setToolTip:[[urlval valueData] absoluteString]];			
							//image = [NSImage imageNamed:@"ItemAdd"];
							//[image setSize:NSMakeSize(32,32)];
							//[menuItem setImage:image];
							[menuItem setTag:[itemval itemID]];		// set ID as tag
							[menuItem setTarget:aTarget];
							[menuItem setAction:aSelector];
							[*itemMenu addItem:menuItem];
							[menuItem release];
						}
					}
				}
			}
		}
	}
}

/**
\generate a menu structure with all found items of itemtype
 
 @params[in|out] subMenuItem is the start of the menustructure.
 @params[in] type itemtype to build menu for, -1 for all
 @params[in] item the main root item to start searching
 @params[in] aTarget the target object of the created menuitem
 @params[in] aSelector the selector of the target that should be called
 */
- (void)generateItemMenu:(NSMenu **)itemMenu 
			 forItemtype:(MBItemTypes)type 
			   ofItem:(MBItem *)item 
		   withMenuTarget:(id)aTarget 
		   withMenuAction:(SEL)aSelector {
	// is reference?
	BOOL isRef = NO;
	if([item identifier] == ItemRefID) {
		item = (MBItem *)[(MBRefItem *)item target];
		isRef = YES;
	}
	
	if(item != nil) {
		// go recursive through all items and search for URLItemValues
		NSEnumerator *i = [[item children] objectEnumerator];
		MBItem *child = nil;
		while((child = [i nextObject])) {
			if(isRef == NO) {
				// do this only, if we have a stdItem
				if(NSLocationInRange([child identifier],ITEM_ID_RANGE)) {
					// the menu for the values
					NSMenu *subMenu = nil;
					// first go deeper (Depth First Search)
					[self generateItemMenu:&subMenu 
							   forItemtype:type 
									ofItem:child
							 withMenuTarget:aTarget
							 withMenuAction:aSelector];
					
					// is still nil ?
					if(subMenu != nil) {
						NSMenuItem *menuItem = [[NSMenuItem alloc] init];
						[menuItem setTitle:[child name]];
						[menuItem setTag:[child itemID]];
						// set submenu
						[menuItem setSubmenu:subMenu];
						[subMenu release];
						
						// check if parentMenu is nil
						if(*itemMenu == nil) {
							*itemMenu = [[NSMenu alloc] init];
						}
						// add menuitem to given menu
						[*itemMenu addItem:menuItem];
						[menuItem release];
					}			
				}
			}
		}
		
		// do this only, if we have a stdItem
		if(NSLocationInRange([item identifier],ITEM_ID_RANGE)) {
			// we do not process references
			if(isRef == NO) {
				// we are looking for itemtype type
				if(([item itemtype] == type) || (type == -1)) {
					if(*itemMenu == nil) {
						*itemMenu = [[NSMenu alloc] init];
					}
					
					// take this itemvalue as menuitem
					NSMenuItem *menuItem = nil;			
					menuItem = [[NSMenuItem alloc] init];
					[menuItem setTitle:[item name]];
					[menuItem setTag:[item itemID]];		// set ID as tag
					//[menuItem setToolTip:[[urlval valueData] absoluteString]];					
					//image = [NSImage imageNamed:@"ItemAdd"];
					//[image setSize:NSMakeSize(32,32)];
					//[menuItem setImage:image];
					[menuItem setTarget:aTarget];
					[menuItem setAction:aSelector];
					[*itemMenu addItem:menuItem];
					[menuItem release];
				}
			}
		}
	}
}

#pragma mark - KVO observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	// check for keyPath
	if([keyPath isEqualToString:MBDefaultsUndoStepsKey]) {
		// get new value
		id newValue = [change valueForKey:NSKeyValueChangeNewKey];
		if(newValue != nil) {
			int undoSteps = [newValue intValue];
			[undoManager setLevelsOfUndo:undoSteps];
		}
	}
}

#pragma mark - Item adding

/**
 \brief adds a item. the methods checks current selection and takes care of this
*/
- (void)addItem:(MBItem *)aItem operation:(MBItemBaseOperation)op {
	MBItem *destItem = nil;
	
	// check for multiple selection
	int selectionCount = [currentItemSelection count];
	if(selectionCount > 1) {
        NSAlert *alert = [NSAlert alertWithMessageText:MBLocaleStr(@"Warning") 
                                         defaultButton:MBLocaleStr(@"OK") 
                                       alternateButton:nil 
                                           otherButton:nil 
                             informativeTextWithFormat:MBLocaleStr(@"Please select ONE Item!")];
        [alert runModal];
		
		return;
	} else if(selectionCount == 1) {
		// get the selected item
		destItem = [currentItemSelection objectAtIndex:0];
	}
	
	// check for trashcan as selected destination type
	if(destItem != nil) {
		if([destItem identifier] == TrashcanItemID) {
            NSAlert *alert = [NSAlert alertWithMessageText:MBLocaleStr(@"Warning") 
                                             defaultButton:MBLocaleStr(@"OK") 
                                           alternateButton:nil 
                                               otherButton:nil 
                                 informativeTextWithFormat:MBLocaleStr(@"Adding new items to the Trashcan is not possible!")];
            [alert runModal];
			
			return;
		}
	} else {
		// destitem = nil, so set rootItem
		destItem = rootItem;
	}

	// add the item
	[self addItem:aItem toItem:destItem withIndex:0 withConnectingItem:YES operation:op withDbTransaction:YES];
}

@end

//------------------------------------------------------------------
//------------------ privateAPI implementation ---------------------
//------------------------------------------------------------------
@implementation MBItemBaseController (privateAPI)

- (void)setItemNavigationBuffer:(NSMutableArray *)aArray {
	[aArray retain];
	[itemNavigationBuffer release];
	itemNavigationBuffer = aArray;
}

- (NSMutableArray *)itemNavigationBuffer {
	return itemNavigationBuffer;
}

- (NSDictionary *)commonItemDict {
	return commonItemDict;
}

- (void)setCommonItemDict:(NSMutableDictionary *)aDict {
	[aDict retain];
	[commonItemDict release];
	commonItemDict = aDict;
}

/*
- (NSDictionary *)itemValueDict
{
	return itemValueDict;
}

- (void)setItemValueDict:(NSMutableDictionary *)aDict
{
	[aDict retain];
	[itemValueDict release];
	itemValueDict = aDict;
}
*/

@end

@implementation MBItemBaseController (transactions)

/**
 \brief moves all items to the trashcan
*/
- (void)moveObjectsToTrashcan:(NSArray *)objects {
	// send notification to start main progressindicator
	MBSendNotifyProgressIndicationActionStarted(nil);

	// make the move operation
	[self addObjects:objects toItem:[self trashcanItem] withIndex:0 withConnectingObjects:YES operation:MoveOperation];
	
	// send notification to stop main progressindicator
	MBSendNotifyProgressIndicationActionStopped(nil);
}

/**
 \brief deletes all items that are in the array
*/
- (void)removeObjects:(NSArray *)objects {
	if([objects count] > 0) {
		// get dbConnection and begin transaction
		MBDBAccess *dbAccess = [MBDBAccess sharedConnection];
		[dbAccess sendBeginTransaction];

		NSEnumerator *iter = [objects objectEnumerator];
		MBCommonItem *item = nil;
		while((item = [iter nextObject])) {
			// make retain
			[item retain];
			
			if(NSLocationInRange([item identifier], ITEM_ID_RANGE)) {
				// this is a normal item and can be deleted
				MBItem *buf = (MBItem *)item;
				
				// delete the item
				[buf delete];
				
				// chec, if this is a root item
				MBItem *parent = [buf parentItem];
				// get the parent and tell him to remove its child
				[parent removeChildItem:buf];
			} else if(NSLocationInRange([item identifier],ITEMVALUE_ID_RANGE)) {
				// this is a itemvalue
				MBItemValue *buf = (MBItemValue *)item;
				
				// delete the itemValue
				[buf delete];
				// now get the item and tel the item to delete its itemValue
				[[buf item] removeItemValue:buf];
			} else if(NSLocationInRange([item identifier],SYSTEMITEM_ID_RANGE)) {
				// items of this id won't be deleted
			} else {
				CocoLog(LEVEL_WARN,@"unrecognized item id!");
			}
			
			// release
			[item release];
		}

		// sort item list
		[self sortChildrenOfItem:nil withWritingSortorder:YES recursive:YES];
				
		// end transaction
		[dbAccess sendCommitTransaction];
		
		MBSendNotifyItemValueListChanged(nil);
		MBSendNotifyItemTreeChanged(nil);
	}
}

/**
\brief remove the given item
 it can be item or itemValue. 
 */
- (void)removeObject:(MBCommonItem *)aObject withDbTransaction:(BOOL)transaction {
	if(aObject != nil) {
		// get dbConnection and begin transaction
		MBDBAccess *dbAccess = nil;

		if(transaction) {
			dbAccess = [MBDBAccess sharedConnection];
			[dbAccess sendBeginTransaction];
		}
		
		if(NSLocationInRange([aObject identifier],ITEM_ID_RANGE)) {
			// this is a normal item
			MBItem *buf = (MBItem *)aObject;

			// delete the item
			[buf delete];
			
			// chec, if this is a root item
			MBItem *parent = [buf parentItem];
			// get the parent and tell him ti remove its child
			[parent removeChildItem:buf];
			
			// sort item list
			[self sortChildrenOfItem:parent withWritingSortorder:YES recursive:NO];
			
			if(transaction) {
				// update list
				MBSendNotifyItemTreeChanged(nil);
			}
		} else if(NSLocationInRange([aObject identifier],ITEMVALUE_ID_RANGE)) {
			// this is a itemvalue
			MBItemValue *buf = (MBItemValue *)aObject;
			
			// delete the itemValue
			[buf delete];
			
			// now get the item and tel the item to delete its itemValue
			[[buf item] removeItemValue:buf];

			if(transaction) {
				MBSendNotifyItemValueListChanged([buf item]);
			}
		} else if(NSLocationInRange([aObject identifier],SYSTEMITEM_ID_RANGE)) {
			// items of this id won't be deleted
		} else {
			CocoLog(LEVEL_WARN,@"unrecognized item id!");
		}
		
		if(transaction) {
			[dbAccess sendCommitTransaction];
		}
	} else {
		CocoLog(LEVEL_WARN,@"item is nil!");
	}
}

/**
 \brief add an itemvalue to an item
 @param itemval the itemvalue to be added
 @param dbConnected bool that indicated wether this itemvalue should be connected to db
 @param op itembase operation (look for enum)
 @param transaction indicated if this should be done as a complete transaction on db
*/
- (void)addItemValue:(id)itemval 
			  toItem:(id)item 
 withConnectingValue:(BOOL)dbConnected 
		   operation:(MBItemBaseOperation)op 
   withDbTransaction:(BOOL)transaction {

	if(itemval != nil) {
		if(item != nil) {
			MBDBAccess *dbAccess = nil;
			
			if(transaction) {
				// get dbConnection and begin transaction
				dbAccess = [MBDBAccess sharedConnection];
				[dbAccess sendBeginTransaction];
			}
			
			// is this a move operation?
			if(op == MoveOperation) {
				// if destination is trashcan, reset all references to this item
				if(item == trashcanItem) {
					[itemval resetReferences];
				}
				
				// remove the itemValue from the old item
				if([itemval item] != nil) {
					// retain itemval, because if we remove it from its current item it will be released
					[itemval retain];
					// remove from old
					[[itemval item] removeItemValue:itemval];
					// add to item
					[item addItemValue:itemval];
					// release it
					[itemval release];
				} else {
					// if the itemValue has no item this is an error
					CocoLog(LEVEL_ERR,@"itemValue has no item!");
				}
			} else if(op == CopyOperation) {
				// make a copy of the object
				itemval = [[itemval copy] autorelease];
				// add to item
				[item addItemValue:itemval];
			} else {
				// simply adds
				[item addItemValue:itemval];
			}
			
			// should the child be connected?
			// do it here to speed things up
			if(dbConnected) {
				[itemval setIsDbConnected:YES];
			}

			if(transaction) {
				[dbAccess sendCommitTransaction];
			
				// send notification
				MBSendNotifyItemValueListChanged(item);
			}
		} else {
			CocoLog(LEVEL_WARN,@"item is nil!");
		}
	} else {
		CocoLog(LEVEL_WARN,@"itemval is nil!");
	}	
}

/**
\brief add an item to another item
 @param child the item to be added
 @param dbConnected bool that indicated wether this item should be connected to db
 @param op itembase operation (look for enum)
 @param transaction indicated if this should be done as a complete transaction on db
 */
- (void)addItem:(id)child 
		 toItem:(id)target
	  withIndex:(int)index
withConnectingItem:(BOOL)dbConnected 
	  operation:(MBItemBaseOperation)op 
withDbTransaction:(BOOL)transaction {

	if(child != nil) {
		// get dbConnection and begin transaction
		MBDBAccess *dbAccess = nil;
		
		// begin db transaction
		if(transaction) {
			dbAccess = [MBDBAccess sharedConnection];
			[dbAccess sendBeginTransaction];
		}
		
		int count = index;
		// if index > 0, decrement it minus 1
		//if(count > 0) {
			//count--;
		//}
		// if parent = nil then take rootItem as target
		if(target == nil) {
			target = rootItem;
			if(index == -1) {
				count = ([[target children] count] - 2);
			}
		} else {
			if(index == -1) {
				count = [[target children] count];
			}
		}

		// is this a move operation?
		if(op == MoveOperation) {
			// if destination is trashcan, reset all references to this item
			if(target == trashcanItem) {
				[child resetReferences];
			}
			
			// first retain otherwise it would be released if we remove it from it's current parent
			[child retain];
			// remove from  old
			[(MBItem *)[child parentItem] removeChildItem:child];
			// add to new target
			[(MBItem *)target insertObject:child inChildrenAtIndex:count];
			// release again
			[child release];
		} else if(op == CopyOperation) {
			// make a copy of the object
			child = [[child copy] autorelease];
			// add item to item
			[(MBItem *)target insertObject:child inChildrenAtIndex:count];
		} else {
			// simply add
			[(MBItem *)target insertObject:child inChildrenAtIndex:count];
		}		
		
		// connect in the end to speed things up
		if(dbConnected == YES) {
			[child setIsDbConnected:YES];
		}

		// if target = roottemplate item set itemtype of child to template
		if([target itemtype] == RootTemplateItemType) {
			// redefine itemtype to template item
			[child setItemtype:TemplateItemType];
			// rescan template items
			MBSendNotifyTemplatesAltered(nil);
		} else if(([child itemtype] == TemplateItemType) && (([target itemtype] == StdItemType) || (target == rootItem))) {
            // if we move an item out of the root template folder

			// redefine itemtype to normal
			[child setItemtype:StdItemType];

			// if we have a move operation, rescan templates
			if(op == MoveOperation) {
				MBSendNotifyTemplatesAltered(nil);
			}
		} else if(([child itemtype] == TemplateItemType) && (target == trashcanItem)) {
            // if source is template item and destiation is trashcan

			// if we have a move operation and the item to be moved is a template, rescan templates
			if(op == MoveOperation) {
				// rescan template items
				MBSendNotifyTemplatesAltered(nil);
			}
		}
		
		// sort item list
		[self sortChildrenOfItem:target withWritingSortorder:YES recursive:NO];
		
		if(transaction) {
			[dbAccess sendCommitTransaction];
			// send notification
			MBSendNotifyItemTreeChanged(target);
		}
	} else {
		CocoLog(LEVEL_WARN,@"child is nil!");
	}
}

/**
\brief adds objects to an item. objects can bei either an item or an itemvalue
 @param objects the array containing the objects to be added
 @param dbConnected bool that indicated wether this item should be connected to db
 @param op itembase operation (look for enum)
 
 This method is executed as a complete transaction without explicitly saying so
 */
- (void)addObjects:(NSArray *)objects 
			toItem:(id)aItem 
		 withIndex:(int)index
withConnectingObjects:(BOOL)dbConnected 
		 operation:(MBItemBaseOperation)op {

	if([objects count] <= 0) {
		// we don't have anything to add
		CocoLog(LEVEL_WARN,@"[MBItemBaseController -addObjects:toItem:]: items array is empty!");			
	} else {
		// get dbConnection and begin transaction
		MBDBAccess *dbAccess = [MBDBAccess sharedConnection];
		[dbAccess sendBeginTransaction];
		
		int count = index;
		NSEnumerator *iter = [objects objectEnumerator];
		MBCommonItem *object = nil;
		while((object = [iter nextObject])) {
			// check class
			if((NSLocationInRange([object identifier], ITEM_ID_RANGE)) ||
			   (NSLocationInRange([object identifier], SYSTEMITEM_ID_RANGE))) {
				MBItem *item = (MBItem *)object;
				
				// use other method
				[self addItem:item 
					   toItem:aItem 
					withIndex:count 
		   withConnectingItem:dbConnected
					operation:op 
			withDbTransaction:NO];
				
				// increment count
				count++;
			} else if(NSLocationInRange([object identifier], ITEMVALUE_ID_RANGE)) {
				MBItemValue *itemval = (MBItemValue *)object;
				
				[self addItemValue:itemval 
							toItem:aItem 
			   withConnectingValue:dbConnected 
						 operation:op 
				 withDbTransaction:NO];
			} else {
				CocoLog(LEVEL_WARN,@"[MBItemBaseController -addObjects:toItem:]: unrecognized class in items array!");			
			}
		}

		// sort item list
		//[self sortChildrenOfItem:aItem withWritingSortorder:YES recursive:NO];
		
		// commit
		[dbAccess sendCommitTransaction];
		
		// send notification
		MBSendNotifyItemTreeChanged(nil);
		MBSendNotifyItemValueListChanged(nil);
	}
}

/**
\brief add new itemValue. if there is no currentselection inform user
 this method makes a new db transaction and must use no method of this class that opens another transaction
 @param aType add itemValue of this type
 */
- (MBItemValue *)addNewItemValueByType:(int)aType {
	// the item value
	id itemval = nil;

	// add itemValue to current selected item
	MBItem *item = [self creationDestinationWithWarningPanel:YES];

	if(item != nil) {
		// if item is a reference, dereference it
		if([item identifier] == ItemRefID) {
			item = (MBItem *)[(MBRefItem *)item target];
		}
		
		// adding a item to a item ref with out target is not allowed
		if(item == nil) {
			NSAlert *alert = [NSAlert alertWithMessageText:MBLocaleStr(@"CannotAddToItemRefWithoutTargetTitle") 
											 defaultButton:MBLocaleStr(@"OK") 
										   alternateButton:nil 
											   otherButton:nil 
								 informativeTextWithFormat:MBLocaleStr(@"CannotAddToItemRefWithoutTargetMsg")];
			[alert runModal];
		} else {
			// send notification to start main progressindicator
			MBSendNotifyProgressIndicationActionStarted(nil);

			// get dbConnection and begin transaction
			MBDBAccess *dbAccess = [MBDBAccess sharedConnection];
			[dbAccess sendBeginTransaction];
			
			// create itemValue
			switch(aType) {
				case SimpleTextItemValueType:
					itemval = [[[MBTextItemValue alloc] init] autorelease];
					break;
				case ExtendedTextItemValueType:
					itemval = [[[MBExtendedTextItemValue alloc] init] autorelease];
					break;
				case NumberItemValueType:
					itemval = [[[MBNumberItemValue alloc] init] autorelease];
					break;
				case CurrencyItemValueType:
					itemval = [[[MBCurrencyItemValue alloc] init] autorelease];
					break;
				case BoolItemValueType:
					itemval = [[[MBBoolItemValue alloc] init] autorelease];
					break;
				case URLItemValueType:
					itemval = [[[MBURLItemValue alloc] init] autorelease];
					break;
				case DateItemValueType:
					itemval = [[[MBDateItemValue alloc] init] autorelease];
					break;
				case FileItemValueType:
					itemval = [[[MBFileItemValue alloc] init] autorelease];
					break;
				case ImageItemValueType:
					itemval = [[[MBImageItemValue alloc] init] autorelease];
					break;			
				case PDFItemValueType:
					itemval = [[[MBPDFItemValue alloc] init] autorelease];
					break;
				case ItemValueRefType:
					itemval = [[(MBRefItem *)[MBRefItem alloc] initWithIdentifier:ItemValueRefID] autorelease];
					break;
                default:break;
            }
			
			[self addItemValue:itemval toItem:item withConnectingValue:YES operation:AddOperation withDbTransaction:NO];
			
			// end transaction
			[dbAccess sendCommitTransaction];
			
			// sort
			[self sortItemValuesOfItems:[NSArray arrayWithObject:item] usingSortDescriptors:itemValueListSortDescriptors];

			/*
			// prepare for undo manager
			[[undoManager prepareWithInvocationTarget:self] removeObject:itemval withDbTransaction:YES];
			if(![undoManager isUndoing])
			{
				[undoManager setActionName:MBLocaleStr(@"UndoAddItemValue")];
			}
			 */

			// send notification to update the itemValue tableview
			MBSendNotifyItemValueListChanged(nil);
			
			// send notification that a new itemvalue has been added and append it
			MBSendNotifyItemValueAdded(itemval);
			
			// send notification to stop main progressindicator
			MBSendNotifyProgressIndicationActionStopped(nil);
		}
	}
	
	return itemval;
}

/**
\brief add a new item by specified type
 */
- (MBCommonItem *)addNewItemByType:(int)aItemType toRoot:(BOOL)toRoot {
	MBItem *destItem = nil;
	// create new Stditem
	MBCommonItem *newItem = nil;

	if(!toRoot) {
		// get item for adding
		destItem = [self creationDestinationWithWarningPanel:NO];
	}
		
	// check for trashcan as selected destination type
	if(destItem != nil) {
		if([destItem identifier] == TrashcanItemID) {
            NSAlert *alert = [NSAlert alertWithMessageText:MBLocaleStr(@"Warning") 
                                             defaultButton:MBLocaleStr(@"OK") 
                                           alternateButton:nil 
                                               otherButton:nil 
                                 informativeTextWithFormat:MBLocaleStr(@"Adding new items to the Trashcan is not possible")];
            [alert runModal];
			
			return nil;
		}
	} else {
		// destitem = nil, so set rootItem
		destItem = rootItem;
	}

	// if item is a reference, dereference it
	if([destItem identifier] == ItemRefID) {
		destItem = (MBItem *)[(MBRefItem *)destItem target];
	}
	
	// adding a item to a item ref with out target is not allowed
	if(destItem == nil) {
		NSAlert *alert = [NSAlert alertWithMessageText:MBLocaleStr(@"CannotAddToItemRefWithoutTargetTitle") 
										 defaultButton:MBLocaleStr(@"OK") 
									   alternateButton:nil 
										   otherButton:nil 
							 informativeTextWithFormat:MBLocaleStr(@"CannotAddToItemRefWithoutTargetMsg")];
		[alert runModal];
	} else {
		// send notification to start main progressindicator
		MBSendNotifyProgressIndicationActionStarted(nil);

		// get dbConnection and begin transaction
		MBDBAccess *dbAccess = [MBDBAccess sharedConnection];
		[dbAccess sendBeginTransaction];
		
		// set name according to type
		switch(aItemType)
		{
			case StdItemType:
				newItem = (MBStdItem *)[[[MBStdItem alloc] init] autorelease];
				[(MBStdItem *)newItem setName:STD_ITEMTYPE_NAME];
				[(MBStdItem *)newItem setItemtype:aItemType];
				break;
			case TableItemType:
				newItem = (MBStdItem *)[[[MBStdItem alloc] init] autorelease];
				[(MBStdItem *)newItem setName:TABLE_ITEMTYPE_NAME];
				[(MBStdItem *)newItem setItemtype:aItemType];
				break;
			case ItemRefType:
				newItem = (MBRefItem *)[[(MBRefItem *)[MBRefItem alloc] initWithIdentifier:ItemRefID] autorelease];
				break;
		}
		
		// set state to init, so no undo steps are done
		[newItem setState:InitState];
		
		// add itemto tree
		[self addItem:newItem toItem:destItem withIndex:-1 withConnectingItem:YES operation:AddOperation withDbTransaction:NO];
		
		// set state to normal so undo steps could be done
		[newItem setState:NormalState];

		// sort item tree
		[self sortChildrenOfItem:destItem withWritingSortorder:YES recursive:NO];
		
		// write to db
		[dbAccess sendCommitTransaction];

		/*
		// prepare for undo manager
		[[undoManager prepareWithInvocationTarget:self] removeObject:newItem withDbTransaction:YES];
		if(![undoManager isUndoing])
		{
			[undoManager setActionName:MBLocaleStr(@"UndoAddItem")];
		}
		 */
		
		// send notification
		MBSendNotifyItemTreeChanged(nil);	
		
		// Send notification and append the added item
		MBSendNotifyItemAdded(newItem);
		
		// send notification to stop main progressindicator
		MBSendNotifyProgressIndicationActionStopped(nil);
	}
	
	return newItem;
}

@end

