//
//  MBRefItem.m
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

#import "MBRefItem.h"
#import "MBItemBaseController.h"
#import "MBElement.h"
#import "MBElementValue.h"
#import "globals.h"

#define REFITEM_TARGETID_IDENTIFIER		@"RefTargetID"

@interface MBRefItem (privateAPI)

@end

@implementation MBRefItem (privateAPI)

@end

@implementation MBRefItem

- (id)init {
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"[MBRefItem -init]: cannot init super!");
	} else {
		// set state
		[self setState:InitState];
		
		// sortorder
		[self setTargetID:-1];
		
		// set target
		target = nil;
		
		// set state
		[self setState:NormalState];
	}
	
	return self;
}

- (id)initWithDb {
	self = [self init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"[MBRefItem -initWithDb]: cannot init!");
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

- (id)initWithIdentifier:(MBTypeIdentifier)aIdentifier {
	self = [self init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"[MBRefItem -initWithIdentifier]: cannot init!");
	} else {
		// set state
		[self setState:InitState];
		
		// set identifier
		[self setIdentifier:aIdentifier];
		
		// set state
		[self setState:NormalState];
	}
	
	return self;
}

- (id)initWithDbAndIdentifier:(MBTypeIdentifier)aIdentifier {
	self = [self init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"[MBRefItem -initWithDbAndIdentifier]: cannot init!");
	} else {
		// set state
		[self setState:InitState];
		
		// set identifier
		[self setIdentifier:aIdentifier];
		
		// connect element
		[self setIsDbConnected:YES];
		
		// set state
		[self setState:NormalState];
	}
	
	return self;
}

- (id)initWithTarget:(MBCommonItem *)aTarget {
	self = [self init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"[MBRefItem -initWithTarget]: cannot init!");
	} else {
		// set state
		[self setState:InitState];
		
		// check type of target
		if(NSLocationInRange([aTarget identifier], ITEM_ID_RANGE)) {
			// set identifier
			[self setIdentifier:ItemRefID];
		} else {
			// set identifier
			[self setIdentifier:ItemValueRefID];		
		}
		
		// set target
		[self setTarget:aTarget];
		
		// connect if target is connected
		[self setIsDbConnected:[target isDbConnected]];
		
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
		CocoLog(LEVEL_ERR,@"[MBRefItem -initWithInitializedElement]: cannot init!");
	} else {
		// set state
		[self setState:InitState];

		// set target to nil
		target = nil;
				
		// set state
		[self setState:NormalState];
	}
	
	return self;	
}

- (void)dealloc {
	CocoLog(LEVEL_DEBUG,@"[MBRefItem -dealloc]");

	// deregister at target
	if(target != nil) {
		[target deregisterAtTarget:self];
	}
	
	// set state
	[self setState:DeallocState];
	
	// nil target
	target = nil;
	
	// release super
	[super dealloc];
}

// target
- (void)setTarget:(MBCommonItem *)aTarget {
	// deregister at old target
	if(target != nil) {
		[target deregisterAtTarget:self];
	}

	int targetID = -1;
	if(aTarget != nil) {
		targetID = [aTarget itemID];
		// register at new target
		[aTarget registerAtTarget:self];
	}
	[self setTargetID:targetID];
	
	target = aTarget;
}

- (MBCommonItem *)target {
	if(target == nil) {
		// try get target from itemController
		target = [itemController commonItemForId:[self targetID]];
		if(target != nil) {
			// register at target
			[target registerAtTarget:self];
		}
	}

	return target;
}

// just for testingpurposes
- (NSData *)valueData {
	return [NSData data];
}

- (void)writeValueIndexEntryWithCreate:(BOOL)flag {
	CocoLog(LEVEL_WARN,@"[MBRefItem -writeValueIndexEntryWithCreate:] not done in RefItem!");
}

//--------------------------------------------------------------------
//------------- NSCopying protocoll ---------------------------------------
//--------------------------------------------------------------------
/**
\brief makes a copy of self commonitem for which the sender is responsible for releasing
 */
- (id)copyWithZone:(NSZone *)zone {
	// make a new object with alloc and init and return that
	MBRefItem *newItem = [[MBRefItem alloc] initWithInitializedElement:[[element copy] autorelease]];
	if(newItem == nil) {
		CocoLog(LEVEL_ERR,@"[MBRefItem -copyWithZone:]: cannot alloc new MBRefItem!");
	} else {
		// set new items target
		[newItem setTarget:[self target]];
	}
	
	return newItem;
}

//--------------------------------------------------------------------
//------------- NSCoding protocoll -----------------------------------
//--------------------------------------------------------------------
- (id)initWithCoder:(NSCoder *)decoder {
	MBRefItem *newItem = nil;
	
	if([decoder allowsKeyedCoding]) {
		// decode the only encoded object
		MBElement *elem = [decoder decodeObjectForKey:@"ItemElement"];
		// create commonitem with that
		newItem = [[[MBRefItem alloc] initWithInitializedElement:elem] autorelease];
	} else {
		// decode the only encoded object
		MBElement *elem = [decoder decodeObject];
		// create commonitem with that
		newItem = [[[MBRefItem alloc] initWithInitializedElement:elem] autorelease];
	}
	
	return newItem;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	// first call super
	[super encodeWithCoder:encoder];
}

@end

@implementation MBRefItem (ElementBase)

// attribute setter
/**
\brief itemid is the same as elementid
 */
- (void)setItemID:(int)aId {
	// set id of element
	if(element != nil) {
		[element setElementid:aId];
	} else {
		CocoLog(LEVEL_ERR,@"[MBRefItem -setItemID:] underlying element is nil!");	
	}
}

// attribute getter
- (int)itemID {
	// get id of element
	if(element != nil) {
		return [element elementid];
	} else {
		CocoLog(LEVEL_ERR,@"[MBRefItem -itemID:] underlying element is nil!");	
	}
	
	return -1;
}

/**
\brief target ID
 */
- (void)setTargetID:(int)aId {
	MBElementValue *elemval = [attributeDict valueForKey:REFITEM_TARGETID_IDENTIFIER];
	if(elemval != nil) {
		[elemval setValueDataAsNumber:[NSNumber numberWithInt:aId]];
		// send Notification
		if(([self state] == NormalState) || ([self state] == UnRedoState)) {
			MBSendNotifyItemValueAttribsChanged(self);
			MBSendNotifyItemTreeChanged(nil);
		}		
	} else {
		CocoLog(LEVEL_WARN,@"[MBRefItem -setTargetID] elementvalue is nil, creating it!");
        [self createAttributeForValue:[[NSNumber numberWithInt:aId] stringValue] 
                        withValueType:StringValueType 
                           identifier:REFITEM_TARGETID_IDENTIFIER 
                         memFootprint:FullCacheMemFootprintType 
                          dbConnected:[self isDbConnected] 
                           writeIndex:NO];
	}		
}

- (int)targetID {
	MBElementValue *elemval = [attributeDict valueForKey:REFITEM_TARGETID_IDENTIFIER];
	if(elemval != nil) {
		return [[elemval valueDataAsNumber] intValue];
	} else {
		CocoLog(LEVEL_WARN,@"[MBRefItem -targetID] elementvalue is nil, creating it!");
        [self createAttributeForValue:[[NSNumber numberWithInt:-1] stringValue] 
                        withValueType:StringValueType 
                           identifier:REFITEM_TARGETID_IDENTIFIER 
                         memFootprint:FullCacheMemFootprintType 
                          dbConnected:[self isDbConnected] 
                           writeIndex:NO];
	}		
	
	return -1;
}

@end

/**
 \brief this protosol is needed for soirting in NSTableView
*/
@implementation MBRefItem (ItemValueSorting)

- (int)valuetype {
	int type = ItemValueRefType;
	
	if(([self target] != self) && ([self target] != nil)) {
		type = [(MBItemValue *)target valuetype];
	}
	
	return type;
}

- (NSString *)name {
	NSString *name;
	
	if(([self target] != self) && ([self target] != nil)) {
		name = [(MBItemValue *)target name];
	} else {
		if([self identifier] == ItemRefID) {
			name = ITEMREF_ITEMTYPE_NAME;
		} else {
			name = ITEMVALUEREF_ITEMTYPE_NAME;
		}
	}
	
	return name;
}

- (int)sortorder {
	int sortorder = 0;
	
	if(([self target] != self) && ([self target] != nil)) {
		sortorder = [(MBItemValue *)target sortorder];
	}
	
	return sortorder;
}

- (NSString *)valueDataAsString {
	NSString *strVal = @"";
	
	if(([self target] != self) && ([self target] != nil)) {
		strVal = [(MBItemValue *)target valueDataAsString];
	}
	
	return strVal;
}

- (NSString *)valueDataForComparison {
	NSString *strVal = @"";
	
	if(([self target] != self) && ([self target] != nil)) {
		strVal = [(MBItemValue *)target valueDataForComparison];
	}
	
	return strVal;	
}

- (void)setSortorder:(int)aSortorder {
	if(([self target] != self) && ([self target] != nil)) {
		[(MBItemValue *)target setSortorder:aSortorder];
	}
}

@end

@implementation MBRefItem (ItemValueReferencing)

- (void)setItem:(id)aItem {
	item = aItem;
	
	if(state == NormalState) {
		if(element != nil) {
			// for items we can element base controller set the subtree, because there are no children for itemvalues
			[element setParent:[aItem element]];
		} else {
			CocoLog(LEVEL_ERR,@"[MBRefItem -setItem:]: element is nil!");	
		}
	}	
}

- (id)item {
	return item;
}

/**
 \brief the datasize of a ref value is 0
*/
- (unsigned int)dataSize {
	return 0;
}

- (NSString *)typeAsString {
	NSString *typeStr = @"";

	if([self target] != nil) {
		typeStr = [(MBItemValue *)target typeAsString];
	}

	return typeStr;
}

@end

@implementation MBRefItem (ItemReferencing)

- (void)setParentItem:(id)aParent {
	parentItem = aParent;
	
	if(state == NormalState) {
		if(element != nil) {
			[element setParent:[aParent element]];
		} else {
			CocoLog(LEVEL_WARN,@"[MBRefItem -setParentItem:] element is nil!");
		}
	}
}

- (id)parentItem {
	return parentItem;
}

/**
 \brief for compatibility with MBItem
*/
- (MBItemTypes)itemtype {
    MBItemTypes type = ItemRefType;
	
	if(([self target] != self) && ([self target] != nil)) {
		type = [(MBItem *)target itemtype];
	}
	
	return type;
}

/**
 \brief the datasize of a ref item is 0
*/
- (unsigned int)dataSizeWithDescent:(BOOL)r {
	return 0;
}

/**
 \brief just for compatibility, return an empty array
*/
- (NSMutableArray *)children {
	if([self target] != nil) {
		return [(MBItem *)target children];
	} else {
		// trying to access children even, if there is no target
		CocoLog(LEVEL_WARN,@"[MBRefItem -children] no target!");
	}
	
	return [NSMutableArray array];
}

/**
\brief just for compatibility, return an empty array
 */
- (NSMutableArray *)itemValues {
	
	if([self target] != nil) {
		return [(MBItem *)target itemValues];
	} else {
		// trying to access itemValues even, if there is no target
		CocoLog(LEVEL_WARN,@"[MBRefItem -itemValues] no target!");
	}

	return [NSMutableArray array];
}

@end

@implementation MBRefItem (CommonItemReferencing)

- (void)targetObjectHasBeenDeleted {
	// remove target reference
	[self setTarget:nil];
}

@end

