//
//  MBDBElement.h
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 23.06.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>

@protocol MBDBAccessing;
@class MBElement;
@class MBDBAccess;

@interface MBDBElement : NSObject
{
	/**
	\brief the db connection for this DBElement.
	 */
	MBDBAccess<MBDBAccessing> *dbConnection;
	
	// if this element is new created we know the elementId first
	int elementid;
}

@end


@protocol MBDBElementAccessing

// convenient allocators
+ (id<MBDBElementAccessing>)dbElementForElement:(MBElement *)aElem;

// special init methods
- (id)init;
- (id)initWithElement:(MBElement *)aElem;

// getter and setter for db connection
- (void)setDbConnection:(id<MBDBAccessing>)aDbConnection;
- (id<MBDBAccessing>)dbConnection;

// element setter
- (void)setElementid:(int)aElemid;
- (void)setTreeinfo:(NSString *)aTreeinfo;
- (void)setIdentifier:(NSString *)aIdentifier;
- (void)setGpReg:(int)aValue;
- (void)setParentid:(int)aId;
// getter
- (int)elementid;
- (NSString *)treeinfo;
- (NSString *)identifier;
- (int)gpReg;
- (int)parentid;

// getter of number of children and number of elementvalues
- (int)numberOfChildrenWithIdentifier:(NSString *)aIdentifier inWholeSubtree:(BOOL)complete;
- (int)numberOfValuesWithIdentifier:(NSString *)aIdentifier inWholeSubtree:(BOOL)complete;

// delete
- (void)delete;

@end
