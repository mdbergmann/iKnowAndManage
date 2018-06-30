//
//  ExternalInterfaceController.h
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 12.05.06.
//  Copyright 2006 mabe. All rights reserved.
//

// $Author: asrael $
// $HeadURL: file:///REPOSITORY/private/cocoa/iKnowAndManage/trunk/src/GrowlSupport/MBGrowlSupport.h $
// $LastChangedBy: asrael $
// $LastChangedDate: 2006-05-03 15:22:51 +0200 (Wed, 03 May 2006) $
// $Rev: 525 $

#import <Cocoa/Cocoa.h>
#import "MBItemType.h"
#import "MBItemBaseController.h"

@class MBItemBaseController;
@class MBSystemItem;
@class MBAppInfoItem;
@class MBItem;
@class MBCommonItem;


@interface ExternalInterfaceController : NSObject {
	MBItemBaseController *itemBaseController;
}

@end

/**
 Interface to ItemBaseController
*/
@interface ExternalInterfaceController (ItemBase)

// state
- (void)setState:(int)aState;
- (int)state;

// special items
- (MBSystemItem *)trashcanItem;
- (MBSystemItem *)importItem;
- (MBSystemItem *)templateItem;
- (MBAppInfoItem *)appInfoItem;
- (MBItem *)rootItem;

// registration and deregistration of items
- (void)registerCommonItem:(MBCommonItem *)aItem withId:(int)aId;
- (void)deregisterCommonItemWithId:(int)aId;
- (MBCommonItem *)commonItemForId:(int)aId;

// list for special identifier
- (NSArray *)listForIdentifier:(MBTypeIdentifier)identifier;

// checking of childs and parents
- (BOOL)isChild:(MBItem *)child inSubtreeOfParent:(MBItem *)parent;

// template items
- (MBItem *)templateItemById:(int)aId;

// item transactions
- (MBCommonItem *)addNewItemByType:(int)aItemType toRoot:(BOOL)toRoot;
- (void)addItem:(id)child 
		 toItem:(id)parent 
	  withIndex:(int)index
withConnectingItem:(BOOL)dbConnected 
	  operation:(MBItemBaseOperation)op 
withDbTransaction:(BOOL)transaction;
// adding mixed stuff
- (void)addObjects:(NSArray *)objects 
			toItem:(id)aItem
		 withIndex:(int)index
withConnectingObjects:(BOOL)dbConnected 
		 operation:(MBItemBaseOperation)op;
// adding itemValues
- (MBItemValue *)addNewItemValueByType:(int)aType;
- (void)addItemValue:(id)itemval 
			  toItem:(id)aItem
 withConnectingValue:(BOOL)dbConnected 
		   operation:(MBItemBaseOperation)op 
   withDbTransaction:(BOOL)transaction;

// removing item
- (void)removeObject:(MBCommonItem *)aObject withDbTransaction:(BOOL)transaction;
- (void)removeObjects:(NSArray *)objects;
// moving items to trash
- (void)moveObjectsToTrashcan:(NSArray *)objects;

@end
