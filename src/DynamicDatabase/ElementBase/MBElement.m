//
//  MBElement.m
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

#import "MBElement.h"
#import "MBDBSqliteElement.h"
#import "MBElementValue.h"
#import "MBBaseDefinitions.h"
#import "MBElementBaseController.h"
#import <SifSqlite/SifSqlite.h>
#import <CocoLogger/CocoLogger.h>

@implementation MBElement

#pragma mark - Initialization

/**
 \brief the normal init does not register this element in elementBase.
 here a element that is not connected to db is created. \n
 set isDbConnected to YES to have it connected.
 @returns initialized not nil object
 */
- (id)init {
	self = [self initWithIdentifier:@""];
	if(self == nil) {
		CocoLog(LEVEL_ERR, @"cannot alloc MBElement!");
	}
	
	return self;
}

- (id)initWithIdentifier:(NSString *)aIdentifier {
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR, @"cannot alloc MBElement!");
	} else {
		// this element has currently no dbElement
		dbElement = nil;
		elementid = -1;
		treeinfo = [[NSString alloc] initWithString:@""];
		identifier = [aIdentifier copy];
		gpReg = 0;
		// reference to parent element
		parent = nil;
		parentid = -1;
		
		// the elementValue list of this element
		elementValues = [[NSMutableArray alloc] init];
		children = [[NSMutableArray alloc] init];
		
		// set treelevel
		treelevel = 0;
		
		// is loaded
		isLoaded = NO;

		// number of children
		numberOfChildrenInSubtree = -1;
	}
	
	return self;
}

/**
 Init this element and create it on db. if this element is altered, all data will be written to db.
 Also this init will create an elementid, see below.
*/
- (id)initWithDb {
	self = [self initWithDbAndIdentifier:@""];
	if(self == nil) {
		CocoLog(LEVEL_ERR, @"cannot alloc MBElement!");
	}
	
	return self;
}

/**
 \brief init this element with a specified identifier.
*/
- (id)initWithDbAndIdentifier:(NSString *)aIdentifier {
	self = [self initWithIdentifier:aIdentifier];
	if(self == nil) {
		CocoLog(LEVEL_ERR, @"cannot alloc MBElement!");
	} else {
		dbElement = [[MBDBSqliteElement alloc] initWithElement:self];
		// set values from dbElement
		elementid = [dbElement elementid];
	}
	
	return self;		
}

/**
 Init this already existing element by reading the data from a initialized dictionary.
 This is used if the data is read in a large bunch from the database. The dictionary represents a row in the database.
 @param aDict to be read from
 */
- (id)initWithReadingFromRow:(ResultRow *)aRow {
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR, @"cannot alloc MBElement!");
	} else {
		elementid = [[[aRow findColumnForName:@"id"] value] intValue];
		treeinfo = [[[aRow findColumnForName:@"treeinfo"] value] retain];
		parentid = [[[aRow findColumnForName:@"parentid"] value] intValue];
		identifier = [[[aRow findColumnForName:@"identifier"] value] retain];
		gpReg = [[[aRow findColumnForName:@"gpreg"] value] intValue];
		// reference to parent element
		parent = nil;
		
		// the elementValue list of this element
		elementValues = [[NSMutableArray alloc] init];
		children = [[NSMutableArray alloc] init];
		
		// set treelevel
		treelevel = 0;

		// set dbElement
		dbElement = [[MBDBSqliteElement alloc] init];
		// set elementid to dbElement
		[dbElement setElementid:elementid];	
		
		// is loaded
		isLoaded = NO;
		
		// number of children
		numberOfChildrenInSubtree = -1;		
	}
	
	return self;	
}

/**
\brief dealloc of this class is called on closing this document
 */
- (void)dealloc {
	CocoLog(LEVEL_DEBUG, @"");

	// this will remove all list items and deactivate observing
	[self setElementValues:nil];
	[self setChildren:nil];

	// switch to not dbConnected
	[self setDbElement:nil];
	
	[self setTreeinfo:nil];
	[self setIdentifier:nil];

	// dealloc object
	[super dealloc];
}

#pragma mark - Getter/Setter

- (NSMutableArray *)children {
	return children;
}

- (void)setChildren:(NSMutableArray *)aList {
	// deactivate observing on old childen
	NSEnumerator *iter = [children objectEnumerator];
	MBElement *elem = nil;
	while((elem = [iter nextObject])) {
		[elem stopObserveParent:self];
	}
	
	// activate observing for the new list
	// and set parent element for all new children
	if(aList != nil) {
		iter = [aList objectEnumerator];
		elem = nil;
		while((elem = [iter nextObject])) {
			[elem setParent:self];
			[elem startObserveParent:self];
		}
	}
	
	[aList retain];
	[children release];
	children = aList;
	
	// reset numberOfChildren
	numberOfChildrenInSubtree = -1;
}

/**
 Returns the elementValue list of this element
 @returns NSMutableArray with current elementValue list
 */
- (NSMutableArray *)elementValues {
	return elementValues;
}

- (void)setElementValues:(NSMutableArray *)aList {
	// deactivate observing on old elementvalues
	NSEnumerator *iter = [elementValues objectEnumerator];
	MBElementValue *elemval = nil;
	while((elemval = [iter nextObject])) {
		[elemval stopObserveElement:self];
	}
	
	// activate observing for the new list
	// and set element for each entry in the new list
	if(aList != nil) {
		iter = [aList objectEnumerator];
		elemval = nil;
		while((elemval = [iter nextObject])) {
			[elemval setElement:self];
			[elemval startObserveElement:self];
		}
	}
	
	[aList retain];
	[elementValues release];
	elementValues = aList;
}

// state
- (void)setState:(int)aState {
	state = aState;
}

- (int)state {
	return state;
}

/**
 Set the underlying dbElement for this element
 @param aDbElement set this if you want to have this element connected to db
*/
- (void)setDbElement:(id)aDbElement {
	[aDbElement retain];
	[dbElement release];
	dbElement = aDbElement;
}

- (id)dbElement {
	return dbElement;
}

/**
 Connect this element, create a dbElement
*/
- (void)setIsDbConnected:(BOOL)aBool {
    // only if state is changed
	if(![self isDbConnected] && aBool) {
		[self setDbElement:[MBDBSqliteElement dbElementForElement:self]];
		// take elementid and dates from dbElement
		[self setElementid:[dbElement elementid]];
	}
}

- (BOOL)isDbConnected {
	if([self dbElement] == nil) {
		return NO;
	}
    
    return YES;
}

/**
 Set the elementid, mainly this method is used if an element has been db connected and received an elementid.
 The treeinfo of the element is altered in here according to the new elementid
*/
- (void)setElementid:(int)aId {
	elementid = aId;

	// element id has changed. this element maybe has been connected and it has received a new elementid.
	// change treeinfo accordingly
	// if this element has no parent, the treeinfo is set for a root element
	if([elementController state] == NormalState) {
		if(parent == nil) {
			// we have no parent
			[self setTreeinfo:[NSString stringWithFormat:@".%d", elementid]];
		} else {
			// we still have a parent
			[self setTreeinfo:[NSString stringWithFormat:@"%@.%d", [parent treeinfo], elementid]];
		}
	}	
}

- (int)elementid {
	return elementid;
}

/**
 Set the tree info.
 If this element is db connected this call will go though to db.
 */
- (void)setTreeinfo:(NSString *)aTreeinfo {
	// do this only, if we have another treeinfo
	if(![aTreeinfo isEqualToString:treeinfo]) {
		aTreeinfo = [aTreeinfo retain];
		[treeinfo release];
		treeinfo = aTreeinfo;
		
		if(treeinfo != nil) {
			// we have to recalculate treelevel
			treelevel = 0;
			
			// write treeinfo only if we are in normalmode
			if([elementController state] == NormalState) {
				// set treeinfo in dbElement
				if(dbElement != nil) {
					[dbElement setTreeinfo:treeinfo];
				}
			}
		}
	}
}

- (NSString *)treeinfo {
	return treeinfo;
}

/**
 Set the treelevel.
 */
- (void)setTreelevel:(int)aTreelevel {
	treelevel = aTreelevel;
}

/**
 Get tree level, counting the dots in treeinfo
 @return number of dots indicating level in tree on treeinfo
*/
- (int)treelevel {
	int count = 0;

	// check, if we just calculated it
	if(treelevel > 0) {
		count = treelevel;
	} else {
		if(parent != nil) {
			count = [parent treelevel] + 1;
		} else {
			if(treeinfo != nil) {
				// we have a better way of doing this
				count = [[treeinfo componentsSeparatedByString:@"."] count] - 1;
			}
		}
	}
    // update
	treelevel = count;
	
	return treelevel;
}

/**
 Sets the identifier of this element.
 This call will go through to db if this element is db connected.
 */
- (void)setIdentifier:(NSString *)aIdentifier {
	// not setting same values
	if(![aIdentifier isEqualToString:identifier]) {
		if(aIdentifier != nil) {
			// write identifier only if we are in normalmode
			if([elementController state] == NormalState) {
				// set identifier in dbElement
				if(dbElement != nil) {
					[dbElement setIdentifier:aIdentifier];
				}
			}
		}

		aIdentifier = [aIdentifier retain];
		[identifier release];
		identifier = aIdentifier;
	}
}

- (NSString *)identifier {
	return identifier;
}

/**
 Sets the General Purpose register
 This call will go through to db if this element is db connected.
 */
- (void)setGpReg:(int)aValue {
	// do not set same vcalues
	if(aValue != gpReg) {
		gpReg = aValue;
		
		// check element base controller for state
		// if we are in normal operation state, we have to deal with parentid
		if([elementController state] == NormalState) {
			// set gpreg in dbElement
			if(dbElement != nil) {
				[dbElement setGpReg:aValue];
			}
		}
	}	
}

- (int)gpReg {
	return gpReg;
}

/**
 On setting the parent, -setParentid: is called and a new treeinfo is created and -setTreeinfo: is called with that.
*/
- (void)setParent:(MBElement *)aParent {
	// set parent
	parent = aParent;

	// determine parentid
	int pid = -1;
	if(parent != nil) {
		pid = [parent elementid];
	} else {
        // we assume we are root
		treelevel = 1;
	}
	
	// parent has changed, we have to change the treeinfo accordingly
	// set treeinfo from parent
	if([elementController state] == NormalState) {
		if(parent == nil) {
			// we have no parent, assume root
			[self setTreeinfo:[NSString stringWithFormat:@".%d", elementid]];
		} else {
			// we have a parent
			[self setTreeinfo:[NSString stringWithFormat:@"%@.%d", [parent treeinfo], elementid]];
		}
	}
	
	// reset numberOfChildren
	numberOfChildrenInSubtree = -1;
	
	// parent id must be set
	[self setParentid:pid];
}

- (MBElement *)parent {
	return parent;
}

/**
 Sets the parent id.
 This call will go through to db if this element is db connected.
 */
- (void)setParentid:(int)aParentid {
	// do not set same vcalues
	if(aParentid != parentid) {
		parentid = aParentid;

		// check element base controller for state
		// if we are in normal operation state, we have to deal with parentid
		if([elementController state] == NormalState) {
			// set parentid in dbElement
			if(dbElement != nil) {
				[dbElement setParentid:parentid];
			}
		}
	}
}

- (int)parentid {
	return parentid;
}

/**
 Sets a flag that indcatde whether this element has been fully loaded, includingchildren and element values.
 */
- (void)setIsLoaded:(BOOL)aValue {
	isLoaded = aValue;
}

- (BOOL)isLoaded {
	return isLoaded;
}

#pragma mark - Adding/Removing values

/**
 This is the KVC compliant method for inserting a new MBElementValue into the list.
*/
- (void)insertObject:(MBElementValue *)elemval inElementValuesAtIndex:(int)index {
	if(elemval != nil) {
		// tell value to start observing it's new element (me)
		[elemval startObserveElement:self];
		
		// set element to element value
		[elemval setElement:self];
		
		// connect it if it isn't
		// index is not written here, has to be done explicitly
		[elemval setIsDbConnected:[self isDbConnected] writeIndex:NO];
		
		// add the elementValue
		[elementValues insertObject:elemval atIndex:index];
	} else {
		CocoLog(LEVEL_WARN, @"not adding nil elementValue!");
	}	
}

/**
 Adds a new ElementValue to the list, calls -insertObjuect:inElementValuesAtIndex: for KVC compliance
*/
- (void)addElementValue:(MBElementValue *)elemval {
	[self insertObject:elemval inElementValuesAtIndex:[elementValues count]];
}

/**
 KVC compliant method for removing a listitem from elementvalues list
*/
- (void)removeObjectFromElementValuesAtIndex:(int)index {
	MBElementValue *elemval = [elementValues objectAtIndex:index];
	if(elemval != nil) {
		// elementvalue, stop observing me
		[elemval stopObserveElement:self];
		
		// remove from list
		[elementValues removeObjectAtIndex:index];
	} else {
		CocoLog(LEVEL_WARN, @"elementValue is nil!");
	}	
}

/**
 Removing an elementValue means, removing it from the element elementValue list. 
 It will not be deleted in db here. call -delete on elementValue for deleting it on db.
 But do this before removing it from this list, because by removing it from this list it will be released and the onject instance may be gone.
*/
- (void)removeElementValue:(MBElementValue *)aElementValue {
	[self removeObjectFromElementValuesAtIndex:[elementValues indexOfObject:aElementValue]];
}

#pragma mark - Adding/Removing children

/**
 This is the KVC compliant method for inserting a new MBElement into the list of children.
 On inserting or adding a new child, the parent of the child IS set here. this invokes altering the treeinfo of the child.
 */
- (void)insertObject:(MBElement *)elem inChildrenAtIndex:(int)index {
	if(elem != nil) {
		// tell element to start observing it's new parent (me)
		[elem startObserveParent:self];
		
		// set parent
		[elem setParent:self];
		
		// add the child
		[children insertObject:elem atIndex:index];
		numberOfChildrenInSubtree++;
	} else {
		CocoLog(LEVEL_WARN, @"not adding nil child!");
	}	
}

/**
 This method adds a new child, calls insertObject:inChildrenAtIndex:
*/
- (void)addChild:(MBElement *)aElement {
	[self insertObject:aElement inChildrenAtIndex:[children count]];
}

/**
 KVC compliant method for removing an item from children list
 */
- (void)removeObjectFromChildrenAtIndex:(int)index {
	MBElement *elem = [children objectAtIndex:index];
	if(elem != nil) {
		// child, stop observing me
		[elem stopObserveParent:self];
		
		// remove from list
		[children removeObjectAtIndex:index];
	} else {
		CocoLog(LEVEL_WARN, @"child is nil!");
	}	
}

/**
 Removes a child from children list, calls -removeObjectFromChildrenAtIndex: for KVC compliance
 */
- (void)removeChild:(MBElement *)elem {
	[self removeObjectFromChildrenAtIndex:[children indexOfObject:elem]];
}

/**
 Delete this element from db. It is automatically released, if it is removed from any array that holds this element.
 All subelements and elementValues will be deleted, too.
*/
- (void)delete {
	CocoLog(LEVEL_DEBUG, @"");
	
	// stop observing out parent
	[self stopObserveParent:parent];
	
	// simply call delete method of dbElement
	if(dbElement != nil) {
		[dbElement delete];
	}
	
	// delete all sub elements
	NSEnumerator *iter = [children objectEnumerator];
	MBElement *elem = nil;
	while((elem = [iter nextObject])) {
		[elem delete];
	}
	
	// delete all elementValues that belong to this element
	iter = [elementValues objectEnumerator];
	MBElementValue *attrib = nil;
	while((attrib = [iter nextObject])) {
		[attrib delete];
	}
}

#pragma mark - Data retrieval

/**
 Returns the number of children of this element.
 @param[in] aIdentifier return the number of children that have this identifier, nil for no identifier comparison - all children.
 @param[in] complete (YES/NO) returns the number of children in the complete subtree.
 */
- (int)numberOfChildrenWithIdentifier:(NSString *)aIdentifier inWholeSubtree:(BOOL)complete {
	int ret = -1;
	
	if(dbElement != nil) {
		// get result with db
		ret = [dbElement numberOfChildrenWithIdentifier:aIdentifier inWholeSubtree:complete];
	} else {
		// calculate result
		ret = [children count];
		
		if(complete) {
			// calculate it
			NSEnumerator *iter = [children objectEnumerator];
			MBElement *elem = nil;
			while((elem = [iter nextObject])) {
				if(aIdentifier != nil) {
					if([[elem identifier] isEqualToString:aIdentifier]) {
						ret = ret + [elem numberOfChildrenWithIdentifier:aIdentifier inWholeSubtree:complete];
					}
				} else {
					ret = ret + [elem numberOfChildrenWithIdentifier:aIdentifier inWholeSubtree:complete];
				}
			}
		}
	}
	
	return ret;
}

/**
 Returns the number of values that are attached to this element.
 If complete is YES the while subtree if calculated.
 */
- (int)numberOfValuesWithIdentifier:(NSString *)aIdentifier inWholeSubtree:(BOOL)complete {
	int ret = -1;
	
	if(dbElement != nil) {
		return [dbElement numberOfValuesWithIdentifier:aIdentifier inWholeSubtree:complete];
	}
	
	return ret;
}

#pragma mark - Key Value Observing

/**
 Child observes parent's treeinfo and dbConnection, that's what changes if the parent gets moved.
*/
- (void)startObserveParent:(MBElement *)aParent {
	if(!observingActive) {
		// we want to have the new value
		[aParent addObserver:self forKeyPath:@"treeinfo" options:NSKeyValueObservingOptionNew context:nil];
		[aParent addObserver:self forKeyPath:@"elementid" options:NSKeyValueObservingOptionNew context:nil];
		[aParent addObserver:self forKeyPath:@"dbElement" options:NSKeyValueObservingOptionNew context:nil];

        // element values start observing this element when they are added 
        
		/*
		// for all elementvalues, they have to start observing me
		NSEnumerator *iter = [elementValues objectEnumerator];
		MBElementValue *elemval = nil;
		while((elemval = [iter nextObject]))
		{
			[elemval startObserveElement:self];
		}
		 */
	}
	
	// observing active
	observingActive = YES;
}

/**
 Stop observing the parent
*/
- (void)stopObserveParent:(MBElement *)aParent {
	if(observingActive) {
		[aParent removeObserver:self forKeyPath:@"treeinfo"];
		[aParent removeObserver:self forKeyPath:@"elementid"];
		[aParent removeObserver:self forKeyPath:@"dbElement"];
		
		// for all elementvalues, they have to stop observing me
		NSEnumerator *iter = [elementValues objectEnumerator];
		MBElementValue *elemval = nil;
		while((elemval = [iter nextObject])) {
			[elemval stopObserveElement:self];
		}
	}
	// observing active
	observingActive = NO;
}

/**
 This method is called if one of the observed values change.
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	// check for keyPath
	if([keyPath isEqualToString:@"treeinfo"]) {
		// treeinfo of parent has changed, so we need to adapt to those changes.
		MBElement *par = object;
		if(par == nil) {
			// we have no parent
			[self setTreeinfo:[NSString stringWithFormat:@".%d",[self elementid]]];
		} else {
			// we still have a parent
			[self setTreeinfo:[NSString stringWithFormat:@"%@.%d",[par treeinfo],[self elementid]]];
		}
	} else if([keyPath isEqualToString:@"elementid"]) {
		// elementid of parent has changed
		MBElement *elem = object;
		[self setParentid:[elem elementid]];
	} else if([keyPath isEqualToString:@"dbElement"]) {
		// if new value is not nil, connect this
		id newValue = [change valueForKey:NSKeyValueChangeNewKey];
		if(newValue != nil) {
			[self setIsDbConnected:YES];
		}
	}
}

#pragma mark - Copying

/**
 Makes a flat copy of self element for which the sender is responsible for releasing.
 If self has a dbElement it will not be copied. The dbElement should be copied seperately and set with -setDbElement:
 to have this element connected to db.
 No ElementValues or child Elements are copied.
 */
- (id)copyWithValues:(BOOL)withValues andChildren:(BOOL)withChildren {
	// make a new object with alloc and init and return that
	MBElement *newElem = [[MBElement alloc] init];	
	if(newElem != nil) {
		// now copy all element elementValues of this element
		//[newElem setElementid:elementid];
		//[newElem setTreeinfo:treeinfo];
		[newElem setIdentifier:identifier];
		[newElem setGpReg:gpReg];
		//[newElem setTreelevel:treelevel];
		// set reference to parent element and parentid if we paste this element elsewhere
		//[newElem setParent:parent];
		//[newElem setParentid:parentid];
		// set the underlying dbElement when we paste this element elsewhere to create a elementid
		//[newElem setDbElement:nil];
		
		if(withValues) {
			// copy the elementValue list of this element
			NSEnumerator *iter = [elementValues objectEnumerator];
			MBElementValue *attrib = nil;
			while((attrib = [iter nextObject])) {
                MBElementValue *copy = [attrib copy];
				[newElem addElementValue:copy];
                [copy release];
			}
		}
		
		if(withChildren) {
			// copy children of element
			NSEnumerator *iter = [children objectEnumerator];
			MBElement *elem = nil;
			while((elem = [iter nextObject])) {
                MBElement *copy = [elem copy];
				[newElem addChild:copy];
                [copy release];
			}
		}
	} else {
		CocoLog(LEVEL_ERR, @"cannot alloc new element!");
	}
	
	return newElem;
}

#pragma mark - NSCopying

/**
 Makes a copy of self element for which the sender is responsible for releasing.
 If self has a dbElement it will not be copied. The dbElement should be copied seperately and set with -setDbElement:
 to have this element connected to db.
 */
- (id)copyWithZone:(NSZone *)zone {
	return [self copyWithValues:YES andChildren:YES];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
	// first create a new MBElement
	MBElement *newElem = [[[MBElement alloc] init] autorelease];

	if([decoder allowsKeyedCoding]) {
		// decode the data and create a MBElement with it
		//[newElem setElementid:[decoder decodeIntForKey:@"ElementIdKey"]];
		//[newElem setTreeinfo:(NSString *)[decoder decodeObjectForKey:@"ElementTreeinfoKey"]];
		[newElem setIdentifier:(NSString *)[decoder decodeObjectForKey:@"ElementIdentifierKey"]];
		[newElem setGpReg:[decoder decodeIntForKey:@"ElementGpRegKey"]];
		//[newElem setParentid:[decoder decodeIntForKey:@"ElementParentIdKey"]];
		[newElem setElementValues:[decoder decodeObjectForKey:@"ElementElementValuesKey"]];
		[newElem setChildren:[decoder decodeObjectForKey:@"ElementChildrenListKey"]];
	} else {
		// decode the data and create a MBElement with it
		//[newElem setElementid:[[decoder decodeObject] intValue]];
		//[newElem setTreeinfo:(NSString *)[decoder decodeObject]];
		[newElem setIdentifier:(NSString *)[decoder decodeObject]];
		[newElem setGpReg:[[decoder decodeObject] intValue]];
		//[newElem setParentid:[[decoder decodeObject] intValue]];
		[newElem setElementValues:[decoder decodeObject]];
		[newElem setChildren:[decoder decodeObject]];
	}
	
	return newElem;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	if([encoder allowsKeyedCoding]) {
		// encode data of element
		//[encoder encodeInt:elementid forKey:@"ElementIdKey"];
		//[encoder encodeObject:treeinfo forKey:@"ElementTreeinfoKey"];
		[encoder encodeObject:identifier forKey:@"ElementIdentifierKey"];
		[encoder encodeInt:gpReg forKey:@"ElementGpRegKey"];
		//[encoder encodeInt:parentid forKey:@"ElementParentIdKey"];
		[encoder encodeObject:elementValues forKey:@"ElementElementValuesKey"];
		[encoder encodeObject:children forKey:@"ElementChildrenListKey"];
	} else {
		// items must be encoded in the same order
		//[encoder encodeObject:[NSNumber numberWithInt:elementid]];
		//[encoder encodeObject:treeinfo];
		[encoder encodeObject:identifier];
		[encoder encodeObject:[NSNumber numberWithInt:gpReg]];
		//[encoder encodeObject:[NSNumber numberWithInt:parentid]];
		[encoder encodeObject:elementValues];
		[encoder encodeObject:children];
	}	
}

@end
