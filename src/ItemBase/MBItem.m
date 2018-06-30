//
//  MBItem.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 26.08.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import "MBItem.h"
#import "MBItemBaseController.h"
#import "MBPDFItemValue.h"
#import "MBElement.h"
#import "MBElementValue.h"
#import "MBStdItem.h"
#import "MBAppInfoItem.h"
#import "MBTextItemValue.h"
#import "MBExtendedTextItemValue.h"
#import "MBNumberItemValue.h"
#import "MBCurrencyItemValue.h"
#import "MBBoolItemValue.h"
#import "MBURLItemValue.h"
#import "MBDateItemValue.h"
#import "MBImageItemValue.h"
#import "globals.h"
#import "MBGeneralPrefsViewController.h"
#import "MBValueIndexController.h"
#import "MBRefItem.h"

@implementation MBItem (unredo)

/**
\brief set attribute op dependant from a given element
 This method is used for undo / redo operations, this means, the given element is a element under "undoElement" and will be deleted.
 */
- (void)setFromUndoElementValue:(MBElementValue *)aElemval withUnRedoOp:(MBItemUnRedoOperations)op {
	// we can only undo this stuff
	if((op == UnRedoItemName) ||
	   (op == UnRedoItemSortorder)) {
		if(aElemval != nil) {
			// set state
			[self setState:UnRedoState];
			
			// make a snapshot for undo
			// get the undo manager
			NSUndoManager *undoManager = [itemController undoManager];
			
			// check, if we can register undos
			if([undoManager isUndoRegistrationEnabled]) {
				if(![undoManager isUndoing]) {
					CocoLog(LEVEL_DEBUG,@"[MBItem -setFromUndoElementValue:withUnRedoOp:] doing undo step!");
					
					// disable further undos steps in here
					[undoManager disableUndoRegistration];					
					
					MBElementValue *undoBuf = nil;
					if(op == UnRedoItemName) {
						undoBuf = [[self elementValueForIdentifier:ITEM_NAME_IDENTIFIER] copy];
					} else if(op == UnRedoItemSortorder) {
						undoBuf = [[self elementValueForIdentifier:ITEM_SORTORDER_IDENTIFIER] copy];
					}
					// get the undoStep element
					MBElement *undoStep = [aElemval element];
					// add undoBuf to undoStep
					[undoStep addElementValue:undoBuf];
					// release undoBuf after adding
					[undoBuf release];
					
					// reenable undo registration
					[undoManager enableUndoRegistration];
					
					// prepare for undo manager
					[[undoManager prepareWithInvocationTarget:self] setFromUndoElementValue:undoBuf withUnRedoOp:op];
					
					// set action name for undo
					//[undoManager setActionName:MBLocaleStr(@"UndoChangeElementName")];
				} else {
					CocoLog(LEVEL_DEBUG,@"[MBItem -setFromUndoElementValue:withUnRedoOp:] doing redo step!");						
					
					MBElementValue *redoBuf = nil;
					if(op == UnRedoItemName) {
						redoBuf = [[self elementValueForIdentifier:ITEM_NAME_IDENTIFIER] copy];
					} else if(op == UnRedoItemSortorder) {
						redoBuf = [[self elementValueForIdentifier:ITEM_SORTORDER_IDENTIFIER] copy];
					}
					// get the undoStep element
					MBElement *undoStep = [aElemval element];
					// add redoBuf to undoElement
					[undoStep addElementValue:redoBuf];
					// release undoBuf after adding
					[redoBuf release];
					// prepare for undo manager
					[[undoManager prepareWithInvocationTarget:self] setFromUndoElementValue:redoBuf withUnRedoOp:op];
				}
			}
			
			if(op == UnRedoItemName) {
				// set the name
				[self setName:[aElemval valueDataAsString]];
			} else if(op == UnRedoItemSortorder) {
				// set the sortorder
				[self setSortorder:[[aElemval valueDataAsNumber] intValue]];
			}
			
			// delete the given element
			if([aElemval element] != nil) {
				[[aElemval element] removeElementValue:aElemval];
			} else {
				CocoLog(LEVEL_WARN,@"[MBItem -setFromUndoElementValue:withUnRedoOp:] element is nil!");
			}
			
			// set state
			[self setState:NormalState];
		}
	}
}

@end

@implementation MBItem

- (id)init {
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"[MBItem -init]: cannot init super!");
	} else {
		// set state
		[self setState:InitState];
		
		// init lists and dicts
		[self setChildren:[NSMutableArray array]];
		[self setItemValues:[NSMutableArray array]];

		// add neccesary attributes
		[self setName:@""];
		// type
		[self setItemtype:-1];	// default
		// sortorder
		[self setSortorder:-1];
		
		// set parent
		parentItem = nil;
		
		// loaded status
		isLoadedWithChilds = NO;
		isLoadedWithValues = NO;
		
		// set state
		[self setState:NormalState];
	}
	
	return self;
}

- (id)initWithDb {
	self = [self init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"[MBItem -initWithDb]: cannot init!");
	} else {
		// set state
		[self setState:InitState];

		// connect element
		[self setIsDbConnected:YES];
		
		// set state
		[self setState:NormalState];
	}
	
	return self;
}

/**
 \brief this init method can be used to init all subclasses of this class
*/
- (id)initWithInitializedElement:(MBElement *)aElement {
	self = [super initWithInitializedElement:aElement];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"[MBItem -initWithInitializedElement]: cannot init!");
	} else {
		// set state
		[self setState:InitState];
		
		// init lists
		[self setChildren:[NSMutableArray array]];
		[self setItemValues:[NSMutableArray array]];

		// attributelist has already been build in MBCommonItem
		
		// build itemvalue and child list
        //if(!state == LoadingState) {
            [self loadLevelData];
        //}
		
		// set state
		[self setState:NormalState];
	}
	
	return self;	
}

- (void)dealloc {
	CocoLog(LEVEL_DEBUG,@"[MBItem -dealloc]");

	// set state
	[self setState:DeallocState];
	
	// lists
	[self setChildren:nil];
	[self setItemValues:nil];

	// release super
	[super dealloc];
}

/**
 this loads all children and values of an item
 */
- (void)loadLevelData {
    
    // preserve state
    //int statebuf = [self state];
    
    // set to load state
    //[self setState:LoadingState];
    
    NSEnumerator *iter = nil;
    iter = [[element children] objectEnumerator];
    MBElement *elem = nil;
    while((elem = [iter nextObject])) {
        int identifier = [[elem identifier] intValue];
        if(NSLocationInRange(identifier, ITEM_ID_RANGE)) {
            if(!isLoadedWithChilds) {
                switch(identifier) {
                    case StdItemID:
                    {
                        // create item out of element
                        MBStdItem *item = [[[MBStdItem alloc] initWithInitializedElement:elem] autorelease];
                        // add to child list
                        [self addChildItem:item];
                        break;
                    }
                    case ItemRefID:
                    {
                        MBRefItem *item = [[[MBRefItem alloc] initWithInitializedElement:elem] autorelease];
                        // add item
                        [self addChildItem:item];
                        break;						
                    }
                }                
            }
        } else if(NSLocationInRange(identifier, SYSTEMITEM_ID_RANGE)) {
            if(!isLoadedWithChilds) {
                id item = nil;
                switch(identifier) {
                    case AppInfoItemID:
                        // app info item must not be added to rootlist
                        item = [[[MBAppInfoItem alloc] initWithInitializedElement:elem] autorelease];
                        [itemController setAppInfoItem:item];
                        break;
                    case TrashcanItemID:
                        item = [[[MBSystemItem alloc] initWithInitializedElement:elem] autorelease];
                        [itemController setTrashcanItem:item];
                        // add item
                        [self addChildItem:item];
                        break;
                    case ImportItemID:
                        item = [[[MBSystemItem alloc] initWithInitializedElement:elem] autorelease];
                        [itemController setImportItem:item];
                        // add item
                        //[self addChildItem:item];
                        break;
                    case RootTemplateItemID:
                        item = [[[MBSystemItem alloc] initWithInitializedElement:elem] autorelease];
                        [itemController setTemplateItem:item];
                        // add item
                        //[self addChildItem:item];
                        break;
                    default:
                        item = [[[MBSystemItem alloc] initWithInitializedElement:elem] autorelease];		
                        // add item
                        [self addChildItem:item];
                        break;
                }                
            }
        } else if(NSLocationInRange(identifier, ITEMVALUE_ID_RANGE)) {
            if(!isLoadedWithValues) {
                id itemval = nil;
                switch(identifier) {
                    case TextItemValueID:
                        // create itemvalue out of element
                        itemval = [[[MBTextItemValue alloc] initWithInitializedElement:elem] autorelease];
                        break;
                    case ExtendedTextItemValueID:
                        // create itemvalue out of element
                        itemval = [[[MBExtendedTextItemValue alloc] initWithInitializedElement:elem] autorelease];
                        break;
                    case NumberItemValueID:
                        // create itemvalue out of element
                        itemval = [[[MBNumberItemValue alloc] initWithInitializedElement:elem] autorelease];
                        break;
                    case CurrencyItemValueID:
                        // create itemvalue out of element
                        itemval = [[[MBCurrencyItemValue alloc] initWithInitializedElement:elem] autorelease];
                        break;
                    case BoolItemValueID:
                        // create itemvalue out of element
                        itemval = [[[MBBoolItemValue alloc] initWithInitializedElement:elem] autorelease];
                        break;
                    case URLItemValueID:
                        // create itemvalue out of element
                        itemval = [[[MBURLItemValue alloc] initWithInitializedElement:elem] autorelease];
                        break;
                    case DateItemValueID:
                        // create itemvalue out of element
                        itemval = [[[MBDateItemValue alloc] initWithInitializedElement:elem] autorelease];
                        break;
                    case FileItemValueID:
                        // create itemvalue out of element
                        itemval = [[[MBFileItemValue alloc] initWithInitializedElement:elem] autorelease];
                        break;
                    case ImageItemValueID:
                        // create itemvalue out of element
                        itemval = [[[MBImageItemValue alloc] initWithInitializedElement:elem] autorelease];
                        break;			
                    case PDFItemValueID:
                        // create itemvalue out of element
                        itemval = [[[MBPDFItemValue alloc] initWithInitializedElement:elem] autorelease];
                        break;
                    case ItemValueRefID:
                        itemval = [[[MBRefItem alloc] initWithInitializedElement:elem] autorelease];
                        break;
                }
                // add to value list
                [self addItemValue:itemval];                
            }
        } else {
            CocoLog(LEVEL_ERR,@"[MBItem -initWithInitializedElement]: unrecognized item identifier!");
        }
        
        // sort children according to their sortorder once after loading
        [itemController sortChildrenOfItem:self withWritingSortorder:NO recursive:NO];
    }
    
    // set loaded
    //[self setIsLoadedWithChilds:YES];
    //[self setIsLoadedWithValues:YES];
    
    // restore state
    //[self setState:statebuf];
}

// parent item
- (void)setParentItem:(id)aParent {
	parentItem = aParent;
	
	// in lazy mode?
	//if(lazy == NO)
	if(state == NormalState) {
		if(element != nil) {
			[element setParent:[aParent element]];
		} else {
			CocoLog(LEVEL_WARN,@"[MBItem -setParentItem:] element is nil!");
		}
	}
}

- (id)parentItem {
	return parentItem;
}

// lists
- (NSMutableArray *)children {
    /*
    if(!isLoadedWithChilds) {
        [self loadLevelData];
    }
     */
	return children;
}

- (NSMutableArray *)itemValues {
    /*
    if(!isLoadedWithValues) {
        // load first
        [self loadLevelData];
    }
     */
	return itemValues;
}

// adding values and children
- (void)addItemValue:(id)aItemval {
	if(aItemval != nil) {
		// add to out array
		[itemValues addObject:aItemval];
		if(state == NormalState) {
			// add to elements child list
			[element addChild:[aItemval element]];
		}
		// set item of itemvalue
		[aItemval setItem:self];
	} else {
		CocoLog(LEVEL_WARN,@"[MBItem -addItemValue:] itemvalue is nil!");
	}
}

- (void)addChildItem:(id)aChild {
	[self insertObject:aChild inChildrenAtIndex:[children count]];
}

/**
 This is the KVC compliant method for inserting a new MBItem into the list of children
 On inserting or adding a new child, the parent of the child IS set here. this invokes altering the treeinfo of the child
 */
- (void)insertObject:(MBItem *)aChild inChildrenAtIndex:(int)index {
	if(aChild != nil) {
		// add to out array
		[children insertObject:aChild atIndex:index];
		if(state == NormalState) {
			// add underlying element
			[element addChild:[aChild element]];
		}
		// set parentItem
		[aChild setParentItem:self];	// set parent in lazy mode
	} else {
		CocoLog(LEVEL_WARN,@"[MBItem -addItemValue:] itemvalue is nil!");
	}	
}

// removing values and children
- (void)removeItemValue:(id)aItemval {
	if(aItemval != nil) {
		// remove from out value list
		[itemValues removeObject:aItemval];
		// remove underlying element
		[element removeChild:[aItemval element]];
	} else {
		CocoLog(LEVEL_WARN,@"[MBItem -removeItemValue:] itemvalue is nil!");
	}	
}

- (void)removeChildItem:(id)aChild {
	[self removeObjectFromChildrenAtIndex:[children indexOfObject:aChild]];
}

/**
 \brief KVC compliant methof for removing a child from the array
*/
- (void)removeObjectFromChildrenAtIndex:(int)index {
	MBItem *item = [children objectAtIndex:index];
	
	// remove from out child list
	[children removeObjectAtIndex:index];
	// remove underlying element
	[element removeChild:[item element]];
}

- (void)setChildren:(NSMutableArray *)aList {
	[aList retain];
	[children release];
	children = aList;
}

- (void)setItemValues:(NSMutableArray *)aList {
	[aList retain];
	[itemValues release];
	itemValues = aList;	
}

- (int)numberOfChildren {
	return [self numberOfChildrenInSubtree:NO];
}

- (int)numberOfValues {
	return [self numberOfItemValuesInSubtree:NO];
}

- (int)numberOfItemValuesInSubtree:(BOOL)complete {
	int count = 0;
	
    if(!complete) {
        count = [[self itemValues] count];
    } else {
        // return number of itemValues in complete subtree
        if(element != nil) {
            count = [element numberOfChildrenWithIdentifier:@"1__" inWholeSubtree:complete];
        } else {
            CocoLog(LEVEL_WARN,@"element is nil!");
        }        
    }
	
	return count;
}

- (int)numberOfChildrenInSubtree:(BOOL)complete {
	int count = 0;

    if(!complete) {
        count = [[self children] count];
    } else {
        // return number of itemValues in complete subtree
        if(element != nil) {
            count = [element numberOfChildrenWithIdentifier:@"2__" inWholeSubtree:complete];
        } else {
            CocoLog(LEVEL_WARN,@"element is nil!");
        }        
    }
	
	return count;
}

// loaded
- (void)setIsLoadedWithChilds:(BOOL)aValue {
	isLoadedWithChilds = aValue;
	if(aValue && isLoadedWithValues) {
		// set element loaded
		[element setIsLoaded:YES];
	}	
}

- (BOOL)isLoadedWithChilds {
	return isLoadedWithChilds;
}

- (void)setIsLoadedWithValues:(BOOL)aValue {
	isLoadedWithValues = aValue;
	if(aValue && isLoadedWithChilds) {
		// set element loaded
		[element setIsLoaded:YES];
	}
}

- (BOOL)isLoadedWithValues {
	return isLoadedWithValues;
}

/**
\brief getting the data size in bytes of all element values
 */
- (unsigned int)dataSizeWithDescent:(BOOL)r {
    unsigned int ret = 0;
	
	if(r) {
		NSEnumerator *iter = [[self children] objectEnumerator];
		MBItem *item = nil;
		while((item = [iter nextObject])) {
			ret += [item dataSizeWithDescent:r];
		}
	}
	
	NSEnumerator *iter = [[self itemValues] objectEnumerator];
	MBItemValue *val = nil;
	while((val = [iter nextObject])) {
		ret += [val dataSize];
	}
	
	return ret;
}

/**
 \brief when resetting references, reset references of all subitems
*/
- (void)resetReferences {
	NSEnumerator *iter = [children objectEnumerator];
	MBItem *item = nil;
	while((item = [iter nextObject])) {
		[item resetReferences];
	}
	
	[super resetReferences];
}

- (NSString *)typeAsString {
	NSString *typeStr;
	
	switch([self itemtype]) {
		// currently we only have this
		case StdItemType:
			typeStr = STD_ITEMTYPE_NAME;
			break;
		case TrashcanItemType:
			typeStr = TRASHCAN_ITEMTYPE_NAME;
			break;
		case RootTemplateItemType:
			typeStr = ROOT_TEMPLATE_ITEMTYPE_NAME;
			break;
		case TemplateItemType:
			typeStr = TEMPLATE_ITEMTYPE_NAME;
			break;
		case ItemRefType:
			typeStr = ITEMREF_ITEMTYPE_NAME;
			break;
		case ImportItemType:
			typeStr = IMPORTS_ITEMTYPE_NAME;
			break;
		default:
			typeStr = STD_ITEMTYPE_NAME;
			break;
	}
	
	return typeStr;
}

//--------------------------------------------------------------------
//------------- NSCopying protocoll ---------------------------------------
//--------------------------------------------------------------------
/**
\brief makes a copy of self commonitem for which the sender is responsible for releasing
 */
- (id)copyWithZone:(NSZone *)zone {
	// make a new object with alloc and init and return that
	MBItem *newItem = [[MBItem alloc] initWithInitializedElement:[[element copy] autorelease]];
	
	if(newItem == nil) {
		CocoLog(LEVEL_ERR,@"[MBItem -copyWithZone:]: cannot alloc new MBItem!");
	}
	
	return newItem;
}

// make flat copy without any values and children
- (id)copyFlat {
	// make a new object with alloc and init and return that
	MBItem *newItem = [[MBItem alloc] initWithInitializedElement:[[element copyWithValues:YES andChildren:NO] autorelease]];
	if(newItem == nil) {
		CocoLog(LEVEL_ERR,@"[MBItem -copyWithZone:]: cannot alloc new MBItem!");
	}
	
	return newItem;	
}

//--------------------------------------------------------------------
//------------- NSCoding protocoll -----------------------------------
//--------------------------------------------------------------------
- (id)initWithCoder:(NSCoder *)decoder {
	MBItem *newItem = nil;
	
	if([decoder allowsKeyedCoding]) {
		// decode the only encoded object
		MBElement *elem = [decoder decodeObjectForKey:@"ItemElement"];
		// create commonitem with that
		newItem = [[[MBItem alloc] initWithInitializedElement:elem] autorelease];
	} else {
		// decode the only encoded object
		MBElement *elem = [decoder decodeObject];
		// create commonitem with that
		newItem = [[[MBItem alloc] initWithInitializedElement:elem] autorelease];
	}
	
	return newItem;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	// first call super
	[super encodeWithCoder:encoder];
}

@end

@implementation MBItem (ElementBase)

// attribute setter
- (void)setItemtype:(MBItemTypes)aType {
	MBElementValue *elemval = [attributeDict valueForKey:ITEM_TYPE_IDENTIFIER];
	if(elemval != nil) {
		[elemval setValueDataAsNumber:[NSNumber numberWithInt:aType]];
	} else {
		CocoLog(LEVEL_WARN,@"[MBItem -itemtype] elementvalue is nil, creating it!");
        [self createAttributeForValue:[NSNumber numberWithInt:aType] 
                        withValueType:NumberValueType 
                           identifier:ITEM_TYPE_IDENTIFIER 
                         memFootprint:FullCacheMemFootprintType 
                          dbConnected:[self isDbConnected] 
                           writeIndex:NO];
	}
}

- (void)setName:(NSString *)aName {
	MBElementValue *elemval = [attributeDict valueForKey:ITEM_NAME_IDENTIFIER];
	if(elemval != nil) {
		if(![[elemval valueDataAsString] isEqualToString:aName]) {
			// make a snapshot for undo
			if([itemController state] == NormalState) {
				// check state
				if([self state] == NormalState) {
					// get the undo manager
					NSUndoManager *undoManager = [itemController undoManager];
					
					// check, if we can register undos
					if([undoManager isUndoRegistrationEnabled]) {
						CocoLog(LEVEL_DEBUG,@"[MBItem -setName:] doing undo step!");
						
						// disable further undos steps in here
						[undoManager disableUndoRegistration];					
						
						MBElementValue *undoBuf = [elemval copy];
						MBElement *undoElement = [[itemController undoItem] element];
						// add a child to undoElement
						// each child of undoElement stands for one undo step
						MBElement *undoStep = [[MBElement alloc] init];
						// add to undoElement
						[undoElement addChild:undoStep];
						[undoStep release];
						// add undoBuf to undoStep
						[undoStep addElementValue:undoBuf];
						// release undoBuf after adding
						[undoBuf release];
						
						// reenable undo registration
						[undoManager enableUndoRegistration];
						
						// prepare for undo manager
						[[undoManager prepareWithInvocationTarget:self] setFromUndoElementValue:undoBuf withUnRedoOp:UnRedoItemName];
						
						// set action name for undo
						[undoManager setActionName:MBLocaleStr(@"UndoChangeItemName")];
						
						
						// check for to be deleted undoStep elements
						NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
						// get undo steps
						int undoSteps = [defaults integerForKey:MBDefaultsUndoStepsKey];
						// -1 is unlimited
						if(undoSteps > -1) {
							// delete all undoStep elements from undoElement that are to much
							//MBElement *undoElement = [[itemController undoItem] element];
							int len = [[undoElement children] count];
							int diff = len - undoSteps;
							if(diff > 0) {
								CocoLog(LEVEL_DEBUG,@"[MBItem -setFromUndoElementValue:withUnRedoOp:] deleting unused undo steps!");
								for(int i = 0;i < diff;i++) {
									// delete all indecies
									[undoElement removeObjectFromChildrenAtIndex:0];
								}
							}
						}
					}
				}
			}

			// set name
			[elemval setValueDataAsString:aName];
					
			// send Notification
			if(([self state] == NormalState) || ([self state] == UnRedoState)) {
				// register itemvalue to the list of to be processed valueindexes
				[[MBValueIndexController defaultController] registerCommonItem:self];
				
				MBSendNotifyItemAttribsChanged(self);
			}
		}
	} else {
		CocoLog(LEVEL_WARN,@"[MBItem -name] elementvalue is nil, creating it!");        
        [self createAttributeForValue:aName withValueType:StringValueType identifier:ITEM_NAME_IDENTIFIER];    
	}
}

// attribute getter
- (MBItemTypes)itemtype {
	MBElementValue *elemval = [attributeDict valueForKey:ITEM_TYPE_IDENTIFIER];
	if(elemval != nil) {
		return (MBItemTypes) [[elemval valueDataAsNumber] intValue];
	} else {
		CocoLog(LEVEL_WARN,@"[MBItem -itemtype] elementvalue is nil, creating it!");
        [self createAttributeForValue:[NSNumber numberWithInt:-1] 
                        withValueType:NumberValueType 
                           identifier:ITEM_TYPE_IDENTIFIER 
                         memFootprint:FullCacheMemFootprintType 
                          dbConnected:[self isDbConnected] 
                           writeIndex:NO];
	}	
	
	return -1;
}

- (NSString *)name {
	NSString *ret = nil;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEM_NAME_IDENTIFIER];
	if(elemval != nil) {
		ret = [elemval valueDataAsString];
	} else {
		CocoLog(LEVEL_WARN,@"[MBItem -name] elementvalue is nil, creating it!");
		ret = @"Item";
        [self createAttributeForValue:ret withValueType:StringValueType identifier:ITEM_NAME_IDENTIFIER];    
	}	
	
	return ret;
}

/**
\brief write initial valueindex entries to the table
 */
- (void)writeValueIndexEntryWithCreate:(BOOL)flag {
	// name
	MBElementValue *elemval = [attributeDict valueForKey:ITEM_NAME_IDENTIFIER];
	if(flag) {
		// create valueindex entry
		[elemval createIndexEntryWithIdentifier:ITEM_NAME_IDENTIFIER];
	}
	[elemval setIndexValue:[self name]];
}

@end
