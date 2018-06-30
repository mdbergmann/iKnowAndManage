/* MBElementBaseController */

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import <globals.h>
#import <MBDBSqlite.h>
#import <GlobalWindows.h>
#import <MBElement.h>
#import <MBAttribute.h>
#import <MBValue.h>

enum MBElementBaseActions
{
	ADD_FOR_INIT = 0,
	ADD_FOR_NEW,
	SET_FOR_INIT,
	SET_FOR_NEW
};

// the state this controller can be
enum ElementBaseStates
{
	NormalState = 0,
	InitState,
	DeallocState,
	DecodeState,
	EncodeState,
	CopyState,
	UnRedoState,
	SetterState
};

@interface MBElementBaseController : NSObject
{
	// the undo manager
	NSUndoManager *undoManager;
	
	// holds all elements after loading from db
	NSMutableArray *rootElementList;
	
	// dictionaries for elements, attributes and values
	NSMutableDictionary *elementDict;
	NSMutableDictionary *attributeDict;
	NSMutableDictionary *valueDict;
	
	NSMutableArray *currentElementSelection;
	NSMutableArray *currentAttributeSelection;
	
	// system elements
	MBElement *trashcanElement;
	MBElement *undoElement;
	
	// array for element navigation
	NSMutableArray *elementNavigationBuffer;
	int elementNavigationBufferIndex;
	
	// elementBaseController state
	int controllerState;
}

// singleton for shared instance
+ (MBElementBaseController *)standardController;

// own methods

// controller state
- (int)controllerState;

// undo manger stuff
- (NSUndoManager *)undoManager;
- (void)setUndoManager:(NSUndoManager *)aManager;

// getter and setter
- (void)setTrashcanElement:(MBElement *)aElement;
- (MBElement *)trashcanElement;
- (void)setUndoElement:(MBElement *)aElement;
- (MBElement *)undoElement;

- (void)setCurrentElementSelection:(NSMutableArray *)aSelection;
- (NSMutableArray *)currentElementSelection;
- (void)setCurrentAttributeSelection:(NSMutableArray *)aSelection;
- (NSMutableArray *)currentAttributeSelection;
- (NSMutableArray *)currentSelection;

// uses removeItem
- (void)delCurrentElementSelection;
- (void)delCurrentAttributeSelection;
- (void)delCurrentSelection;

// uses addNewElementOfType
- (void)addNewElement;
	
// list stuff
- (NSMutableArray *)rootElementList;
- (NSMutableArray *)attribListOfElement:(MBElement *)aElement;

// use AddElement:toElement
- (void)addRootElement:(MBElement *)elem;

// dictionary stuff
- (void)registerNewElement:(MBElement *)aElem withId:(int)aId;
- (void)registerNewAttribute:(MBAttribute *)aAttrib withId:(int)aId;
- (void)deregisterElementWithId:(int)aId;
- (void)deregisterAttributeWithId:(int)aId;
- (MBElement *)elementForElementId:(int)aId;
- (MBAttribute *)attributeForAttributeId:(int)aId;

// element navigation stuff
- (int)elementNavigationBackward;
- (int)elementNavigationForward;

// sorting
- (void)sortElementData;

@end

/**
 \brief all methods that open and close a db transaction
*/
@interface MBElementBaseController (transactions)

// adding element
- (void)addNewElementByType:(int)aElementType;
- (void)addElement:(MBElement *)child toElement:(MBElement *)parent isMoveOp:(BOOL)moveOp withTransaction:(BOOL)aSetting;

// adding mixed stuff
- (void)addItems:(NSArray *)items toElement:(MBElement *)aElem isMoveOp:(BOOL)moveOp;

// adding attributes
- (void)addNewAttributeByType:(int)aType;
- (void)addAttribute:(MBAttribute *)attrib toElement:(MBElement *)elem isMoveOp:(BOOL)moveOp withTransaction:(BOOL)aSetting;

// removing item
- (void)removeItem:(id)aItem withTransaction:(BOOL)aSetting;
- (void)removeItems:(NSArray *)items;

// moving items to trash
- (void)moveItemsToTrashcan:(NSArray *)items;

@end
