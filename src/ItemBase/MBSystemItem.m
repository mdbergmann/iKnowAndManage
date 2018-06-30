//
//  MBSystemItem.m
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

#import "MBCommonItem.h"
#import "MBSystemItem.h"
#import "MBElement.h"

@implementation MBSystemItem

- (id)init {
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"cannot init super!");
	} else {
		// set state
		[self setState:InitState];
		
		// set element identifier
		[self setIdentifier:SystemItemID];
		
		// set state
		[self setState:NormalState];
	}
	
	return self;		
}

- (id)initWithDb {
	self = [self init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"cannot init super!");
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

- (id)initWithInitializedElement:(MBElement *)aElem {
	self = [super initWithInitializedElement:aElem];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"cannot init super!");
	}
	
	return self;
}

- (void)dealloc {
	CocoLog(LEVEL_DEBUG,@"");
	
	// set state
	[self setState:DeallocState];
	
	// release super
	[super dealloc];
}

@end
