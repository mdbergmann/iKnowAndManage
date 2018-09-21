#import <CoreGraphics/CoreGraphics.h>//
//  MBItem.h
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

#import <Cocoa/Cocoa.h>
#import <MBCommonItem.h>
#import <MBThreadedProgressSheetController.h>
#import "MBCommonItem.h"
#import "MBItemType.h"

@class MBElement;
@class MBElementValue;

#define ITEM_NAME_IDENTIFIER			@"itemname"
#define ITEM_TYPE_IDENTIFIER			@"itemtype"
#define ITEM_SORTORDER_IDENTIFIER		@"itemsortorder"

typedef enum {
	UnRedoItemName = 0,
	UnRedoItemComment,
	UnRedoItemSortorder
}MBItemUnRedoOperations;

@interface MBItem : MBCommonItem <NSCopying, NSCoding> {	
    /** the parent item */
	id parentItem;

	// children
	NSMutableArray *children;		/** the array with all children */
	// values
	NSMutableArray *itemValues;		/** the values to this item */
	
	BOOL isLoadedWithChilds;
	BOOL isLoadedWithValues;
}

// NSCopying protocoll
- (id)copyWithZone:(NSZone *)zone;

- (id)copyFlat;

// NSCoding stuff
- (id)initWithCoder:(NSCoder *)decoder NS_RETURNS_RETAINED;
- (void)encodeWithCoder:(NSCoder *)encoder;

// inits
- (id)init;
- (id)initWithDb;
- (id)initWithInitializedElement:(MBElement *)aElem;

// item loading
- (void)loadLevelData;

// parent item
- (void)setParentItem:(id)aParent;
- (id)parentItem;

// setting lists and dicts
- (void)setChildren:(NSMutableArray *)aList;
- (void)setItemValues:(NSMutableArray *)aList;

// loaded
- (void)setIsLoadedWithChilds:(BOOL)aValue;
- (BOOL)isLoadedWithChilds;
- (void)setIsLoadedWithValues:(BOOL)aValue;
- (BOOL)isLoadedWithValues;

// lists
- (NSMutableArray *)children;
- (NSMutableArray *)itemValues;
// adding values and children
- (void)addItemValue:(id)aItemval;
- (void)addChildItem:(id)aChild;
- (void)insertObject:(MBItem *)aChild inChildrenAtIndex:(int)index;
// removing values and children
- (void)removeItemValue:(id)aItemval;
- (void)removeChildItem:(id)aChild;
- (void)removeObjectFromChildrenAtIndex:(int)index;

// reference stuff / overriding method from commonItem
- (void)resetReferences;

// number of stuff
- (int)numberOfChildren;
- (int)numberOfValues;
- (int)numberOfItemValuesInSubtree:(BOOL)complete;
- (int)numberOfChildrenInSubtree:(BOOL)complete;

// data size
- (unsigned int)dataSizeWithDescent:(BOOL)r;

// type as string
- (NSString *)typeAsString;

@end

@interface MBItem (ElementBase)

// attribute setter
- (void)setItemtype:(MBItemTypes)aType;
- (void)setName:(NSString *)aName;
// attribute getter
- (MBItemTypes)itemtype;
- (NSString *)name;

- (void)writeValueIndexEntryWithCreate:(BOOL)flag;

@end

@interface MBItem (unredo)
// undo/redo
- (void)setFromUndoElementValue:(MBElementValue *)aElemval withUnRedoOp:(MBItemUnRedoOperations)op;

@end

@protocol MBItemReferencing

- (void)setParentItem:(id)aParent;
- (id)parentItem;
- (MBItemTypes)itemtype;
- (unsigned int)dataSizeWithDescent:(BOOL)r;
- (NSMutableArray *)children;
- (NSMutableArray *)itemValues;

@end
