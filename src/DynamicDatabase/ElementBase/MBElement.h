#import <CoreGraphics/CoreGraphics.h>//
//  MBElement.h
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 26.05.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>

@class MBElementValue;
@class ResultRow;
@protocol MBDBElementAccessing;

@interface MBElement : NSObject <NSCopying,NSCoding> {
	// instance vars
	int elementid;
	NSString *treeinfo;
	NSString *identifier;
	int gpReg;
	int parentid;
	// the elementValue list of this element
	NSMutableArray *elementValues;
	NSMutableArray *children;
	// reference to parent element
	MBElement *parent;

	// treelevel
	int treelevel;
	
	// number of children
	int numberOfChildrenInSubtree;
	
	// loaded?
	BOOL isLoaded;
	
	// observing state
	BOOL observingActive;

	// the underlying MBDBElement for db access
	id<MBDBElementAccessing> dbElement;
	
	// state of element
	int state;
}

// own copy
- (id)copyWithValues:(BOOL)withValues andChildren:(BOOL)withChildren;

// NSCopying protocoll
- (id)copyWithZone:(NSZone *)zone;

// NSCoding stuff
- (id)initWithCoder:(NSCoder *)decoder NS_RETURNS_RETAINED;
- (void)encodeWithCoder:(NSCoder *)encoder;

// inits
- (id)init;
- (id)initWithIdentifier:(NSString *)aIdentifier;
- (id)initWithDb;
- (id)initWithDbAndIdentifier:(NSString *)identifier;
- (id)initWithReadingFromRow:(ResultRow *)aRow;

// state
- (void)setState:(int)aState;
- (int)state;

// getter and setter
- (void)setDbElement:(id<MBDBElementAccessing>)aDbElement;
- (id<MBDBElementAccessing>)dbElement;
- (void)setIsDbConnected:(BOOL)aBool;
- (BOOL)isDbConnected;

// loading
- (void)setIsLoaded:(BOOL)aValue;
- (BOOL)isLoaded;

// ID
- (void)setElementid:(int)aId;
- (int)elementid;
// treeinfo
- (void)setTreeinfo:(NSString *)aTreeinfo;
- (NSString *)treeinfo;
// identifier
- (void)setIdentifier:(NSString *)aIdentifier;
- (NSString *)identifier;
// gpreg
- (void)setGpReg:(int)aValue;
- (int)gpReg;
// parent element
- (void)setParent:(MBElement *)aParent;
- (MBElement *)parent;
- (void)setParentid:(int)aParentid;
- (int)parentid;

// tree level
- (void)setTreelevel:(int)aTreelevel;
- (int)treelevel;
// elements and elementvalues in subtree
- (int)numberOfChildrenWithIdentifier:(NSString *)aIdentifier inWholeSubtree:(BOOL)complete;
- (int)numberOfValuesWithIdentifier:(NSString *)aIdentifier inWholeSubtree:(BOOL)complete;

// adding and removing from lists
- (void)addElementValue:(MBElementValue *)aElementValue;
- (void)insertObject:(MBElementValue *)elemval inElementValuesAtIndex:(int)index;
- (void)removeElementValue:(MBElementValue *)aElementValue;
- (void)removeObjectFromElementValuesAtIndex:(int)index;
- (void)addChild:(MBElement *)aElement;
- (void)insertObject:(MBElement *)elem inChildrenAtIndex:(int)index;
- (void)removeChild:(MBElement *)child;
- (void)removeObjectFromChildrenAtIndex:(int)index;

- (void)delete;

// lists
- (NSMutableArray *)elementValues;
- (void)setElementValues:(NSMutableArray *)aList;
- (NSMutableArray *)children;
- (void)setChildren:(NSMutableArray *)aList;

// observing parent
- (void)startObserveParent:(MBElement *)aParent;
- (void)stopObserveParent:(MBElement *)aParent;
// callback for changes of observing
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

@end
