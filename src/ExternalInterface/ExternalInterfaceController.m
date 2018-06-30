//
//  ExternalInterfaceController.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 12.05.06.
//  Copyright 2006 mabe. All rights reserved.
//

// $Author: asrael $
// $HeadURL: file:///REPOSITORY/private/cocoa/iKnowAndManage/trunk/src/GrowlSupport/MBGrowlSupport.m $
// $LastChangedBy: asrael $
// $LastChangedDate: 2006-05-03 15:22:51 +0200 (Wed, 03 May 2006) $
// $Rev: 525 $

#import "ExternalInterfaceController.h"

@implementation ExternalInterfaceController

- (id)init
{
	self = [super init];
	if(self)
	{
		// get a static reference to ItemBaseController
		itemBaseController = [itemController retain];
	}
	
	return self;
}

- (void)dealloc
{
	// release our itemBaseController reference
	[itemBaseController release];
	
	// release super
	[super dealloc];
}

@end

/**
\brief interface to ItemBaseController
 */
@implementation ExternalInterfaceController (ItemBase)

// state
- (void)setState:(int)aState
{
	[itemBaseController setState:aState];
}
- (int)state
{
	return [itemBaseController state];
}

// special items
- (MBSystemItem *)trashcanItem
{
	return [itemBaseController trashcanItem];
}

- (MBSystemItem *)importItem
{
	return [itemBaseController importItem];
}

- (MBSystemItem *)templateItem
{
	return [itemBaseController templateItem];
}

- (MBAppInfoItem *)appInfoItem
{
	return [itemBaseController appInfoItem];
}

- (MBItem *)rootItem
{
	return [itemBaseController rootItem];
}

// registration and deregistration of items
- (void)registerCommonItem:(MBCommonItem *)aItem withId:(int)aId
{
	[itemBaseController registerCommonItem:aItem withId:aId];
}

- (void)deregisterCommonItemWithId:(int)aId
{
	[itemBaseController deregisterCommonItemWithId:aId];
}

- (MBCommonItem *)commonItemForId:(int)aId
{
	return [itemBaseController commonItemForId:aId];
}

// list for special identifier
- (NSArray *)listForIdentifier:(MBTypeIdentifier)identifier
{
	return [itemBaseController listForIdentifier:identifier];
}

// checking of childs and parents
- (BOOL)isChild:(MBItem *)child inSubtreeOfParent:(MBItem *)parent
{
	return [itemBaseController isChild:child inSubtreeOfParent:parent];
}

// template items
- (MBItem *)templateItemById:(int)aId
{
	return [itemBaseController templateItemById:aId];
}

// item transactions
- (MBCommonItem *)addNewItemByType:(int)aItemType toRoot:(BOOL)toRoot
{
	return [itemBaseController addNewItemByType:aItemType toRoot:toRoot];
}

- (MBItemValue *)addNewItemValueByType:(int)aType
{
	return [itemBaseController addNewItemValueByType:aType];
}

- (void)addItem:(id)child 
		 toItem:(id)parent 
	  withIndex:(int)index
withConnectingItem:(BOOL)dbConnected 
	  operation:(MBItemBaseOperation)op 
withDbTransaction:(BOOL)transaction
{
	[itemBaseController addItem:child 
						 toItem:parent 
					  withIndex:index 
			 withConnectingItem:dbConnected 
					  operation:op 
			  withDbTransaction:transaction];
}

- (void)addObjects:(NSArray *)objects 
			toItem:(id)aItem
		 withIndex:(int)index
withConnectingObjects:(BOOL)dbConnected 
		 operation:(MBItemBaseOperation)op
{
	[itemBaseController addObjects:objects 
							toItem:aItem 
						 withIndex:index 
			 withConnectingObjects:dbConnected 
						 operation:op];
}

- (void)addItemValue:(id)itemval 
			  toItem:(id)aItem
 withConnectingValue:(BOOL)dbConnected 
		   operation:(MBItemBaseOperation)op 
   withDbTransaction:(BOOL)transaction
{
	[itemBaseController addItemValue:itemval 
							  toItem:aItem 
				 withConnectingValue:dbConnected 
						   operation:op 
				   withDbTransaction:transaction];
}

- (void)removeObject:(MBCommonItem *)aObject withDbTransaction:(BOOL)transaction
{
	[itemBaseController removeObject:aObject 
				   withDbTransaction:transaction];
}

- (void)removeObjects:(NSArray *)objects
{
	[itemBaseController removeObjects:objects];
}

- (void)moveObjectsToTrashcan:(NSArray *)objects
{
	[itemBaseController moveObjectsToTrashcan:objects];
}

@end

