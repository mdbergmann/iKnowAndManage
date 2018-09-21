#import <CoreGraphics/CoreGraphics.h>//
//  MBRefItem.h
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
#import "MBCommonItem.h"
#import "MBItemValue.h"
#import "MBItem.h"

@class MBItem;

@interface MBRefItem : MBCommonItem <NSCopying,NSCoding>
{	
	// item navigation
	MBCommonItem *target;		/** target item */
	MBItem *item;				/** needed for ItemValue compatibility */
	MBItem *parentItem;			/** needed for Item compatibility */

	BOOL isLoadedWithChilds;
	BOOL isLoadedWithValues;
}

// NSCopying protocoll
- (id)copyWithZone:(NSZone *)zone;

// NSCoding stuff
- (id)initWithCoder:(NSCoder *)decoder NS_RETURNS_RETAINED;
- (void)encodeWithCoder:(NSCoder *)encoder;

// inits
- (id)initWithIdentifier:(MBTypeIdentifier)aIdentifier;
- (id)initWithDbAndIdentifier:(MBTypeIdentifier)aIdentifier;
- (id)initWithTarget:(MBCommonItem *)aTarget;
- (id)initWithInitializedElement:(MBElement *)aElem;

// target item
- (void)setTarget:(MBCommonItem *)aTarget;
- (MBCommonItem *)target;

// just for testingpurposes
- (NSData *)valueData;

// abstract method
- (void)writeValueIndexEntryWithCreate:(BOOL)flag;

@end

@interface MBRefItem (ElementBase)

// attribute setter
- (void)setTargetID:(int)aId;
// attribute getter
- (int)targetID;

@end

@interface MBRefItem (ItemValueSorting) <MBItemValueSorting>

- (int)valuetype;
- (NSString *)name;
- (int)sortorder;
- (NSString *)valueDataAsString;
- (NSString *)valueDataForComparison;

- (void)setSortorder:(int)aSortorder;

@end

@interface MBRefItem (ItemValueReferencing) <MBItemValueReferencing>

- (void)setItem:(id)aItem;
- (id)item;
- (unsigned int)dataSize;
- (NSString *)typeAsString;

@end

@interface MBRefItem (ItemReferencing) <MBItemReferencing>

- (void)setParentItem:(id)aItem;
- (id)parentItem;
- (MBItemTypes)itemtype;
- (unsigned int)dataSizeWithDescent:(BOOL)r;
- (NSMutableArray *)children;
- (NSMutableArray *)itemValues;

@end

@interface MBRefItem (CommonItemReferencing) <MBCommonItemReferencing>

- (void)targetObjectHasBeenDeleted;

@end
