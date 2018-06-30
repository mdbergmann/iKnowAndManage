/* MBItemBaseController */

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>
#import "MBItemType.h"

@class MBItem;
@class MBSystemItem;
@class MBAppInfoItem;
@class MBCommonItem;
@class MBItemValue;

// define for simpler access to ItemBaseController
#define itemController	[MBItemBaseController standardController]

//@class MBCommonItem, MBItem, MBSystemItem, MBAppInfoItem, MBItemValue;

/**
 \brief enum item operations
*/
typedef enum {
	AddOperation = 0,
	CopyOperation,
	MoveOperation
}MBItemBaseOperation;

@interface MBItemBaseController : NSObject {
	// the undo manager
	NSUndoManager *undoManager;
	
	// dictionaries for all kinds of items
	NSMutableDictionary *commonItemDict;
	//NSMutableDictionary *itemValueDict;
	
	NSMutableArray *currentItemSelection;
	NSMutableArray *currentItemValueSelection;
		
	NSArray *itemValueListSortDescriptors;
	
	// system items
	MBItem *rootItem;
	MBSystemItem *importItem;
	MBSystemItem *trashcanItem;
	MBSystemItem *templateItem;
	MBSystemItem *undoItem;
	MBAppInfoItem *appInfoItem;
	
	// array for item navigation
	NSMutableArray *itemNavigationBuffer;
	int itemNavigationBufferIndex;
	
	// itemBaseController state
	int state;
}

// singleton for shared instance
+ (MBItemBaseController *)standardController;

// own methods
- (void)buildItemBase;
- (void)buildItemBaseForItem:(MBItem *)aItem;
- (int)checkAndPrepareSystemItems;
- (void)loadChildsForItem:(MBItem *)aItem;
- (void)loadValuesForItem:(MBItem *)aItem;

// controller state
- (void)setState:(int)aState;
- (int)state;

// undo manger stuff
- (NSUndoManager *)undoManager;
- (void)setUndoManager:(NSUndoManager *)aManager;

// getter and setter
- (void)setTrashcanItem:(MBSystemItem *)aItem;
- (MBSystemItem *)trashcanItem;
- (void)setImportItem:(MBSystemItem *)aItem;
- (MBSystemItem *)importItem;
- (void)setTemplateItem:(MBSystemItem *)aItem;
- (MBSystemItem *)templateItem;
- (void)setUndoItem:(MBSystemItem *)aItem;
- (MBSystemItem *)undoItem;
- (void)setAppInfoItem:(MBAppInfoItem *)aItem;
- (MBAppInfoItem *)appInfoItem;
- (void)setRootItem:(MBItem *)aItem;
- (MBItem *)rootItem;

- (void)setCurrentItemSelection:(NSMutableArray *)aSelection;
- (NSMutableArray *)currentItemSelection;
- (void)setCurrentItemValueSelection:(NSMutableArray *)aSelection;
- (NSMutableArray *)currentItemValueSelection;
- (NSMutableArray *)currentSelection;
- (void)setItemValueListSortDescriptors:(NSArray *)items;
- (NSArray *)itemValueListSortDescriptors;

// uses removeItem
- (void)delCurrentItemSelection;
- (void)delCurrentItemValueSelection;
- (void)delCurrentSelection;

// list stuff
- (NSArray *)rootItemList;

// dictionary stuff
- (void)registerCommonItem:(MBCommonItem *)aItem withId:(int)aId;
- (void)deregisterCommonItemWithId:(int)aId;
- (MBCommonItem *)commonItemForId:(int)aId;
- (NSArray *)allRegisteredCommonItems;

// item navigation stuff
- (int)itemNavigationBackward;
- (int)itemNavigationForward;

// getting lists of specific types of items/itemvalues with specifying their identifier
- (NSArray *)listForIdentifier:(MBTypeIdentifier)identifier;
- (NSArray *)listForIdentifierRange:(NSRange)range;

// sorting
- (void)sortChildrenOfItem:(MBItem *)item withWritingSortorder:(BOOL)writeSortorder recursive:(BOOL)r;
- (void)sortChildrenOfItem:(MBItem *)parent usingSortDescriptors:(NSArray *)newDescriptors;
- (void)sortItemValuesOfItems:(NSArray *)items usingSortDescriptors:(NSArray *)newDescriptors;

// parent child tree identification
- (BOOL)isChild:(MBItem *)child inSubtreeOfParent:(MBItem *)parent;

// get itemfrom template item
- (MBItem *)templateItemById:(int)aId;

// generate menu for value type
- (NSMenu *)generateTemplateMenuWithTarget:(id)aTarget withMenuAction:(SEL)aSelector;

- (void)generateItemMenu:(NSMenu **)itemMenu 
			 forItemtype:(MBItemTypes)type 
				  ofItem:(MBItem *)item 
		  withMenuTarget:(id)aTarget 
		  withMenuAction:(SEL)aSelector;

- (void)generateValueMenu:(NSMenu **)itemMenu 
			 forValuetype:(MBItemValueTypes)type 
				   ofItem:(MBItem *)item 
		   withMenuTarget:(id)aTarget 
		   withMenuAction:(SEL)aSelector;

// methods using transactions category
- (void)addItem:(MBItem *)aItem operation:(MBItemBaseOperation)op;

// creationsource
- (MBItem *)creationDestinationWithWarningPanel:(BOOL)warningPanel;

@end

/**
 \brief all methods that open and close a db transaction
*/
@interface MBItemBaseController (transactions)
 
// adding item
- (MBCommonItem *)addNewItemByType:(int)aItemType toRoot:(BOOL)toRoot;
- (void)addItem:(id)child toItem:(id)parent withIndex:(int)index withConnectingItem:(BOOL)dbConnected operation:(MBItemBaseOperation)op withDbTransaction:(BOOL)transaction;
- (void)addObjects:(NSArray *)objects toItem:(id)aItem withIndex:(int)index withConnectingObjects:(BOOL)dbConnected operation:(MBItemBaseOperation)op;

// adding itemValues
- (MBItemValue *)addNewItemValueByType:(int)aType;
- (void)addItemValue:(id)itemval toItem:(id)aItem withConnectingValue:(BOOL)dbConnected operation:(MBItemBaseOperation)op withDbTransaction:(BOOL)transaction;

// removing item
- (void)removeObject:(MBCommonItem *)aObject withDbTransaction:(BOOL)transaction;
- (void)removeObjects:(NSArray *)objects;

// moving items to trash
- (void)moveObjectsToTrashcan:(NSArray *)objects;

@end
