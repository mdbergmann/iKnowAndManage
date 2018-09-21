#import <CoreGraphics/CoreGraphics.h>//
//  MBImageItemValue.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 16.09.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author: mbergmann $
// $HeadURL: file:///REPOSITORY/private/cocoa/iKnowAndManage/trunk/src/ItemBase/MBImageItemValue.m $
// $LastChangedBy: mbergmann $
// $LastChangedDate: 2006-09-05 09:45:45 +0200 (Tue, 05 Sep 2006) $
// $Rev: 571 $

#import "MBPDFItemValue.h"
#import "MBElement.h"

@implementation MBPDFItemValue

// inits
- (id)init {
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR, @"[MBImageItemValue -init:]: cannot init super!");
	} else {
		// set state
		[self setState:InitState];

		// set identifier
		[self setIdentifier:PDFItemValueID];
		// set valuetype
		[self setValuetype:PDFItemValueType];

		// auto handle load save
		[self setAutoHandleLoadSave:NO];

		// set state
		[self setState:NormalState];
	}
	
	return self;
}

- (id)initWithDb {
	self = [self init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"[MBImageItemValue -initWithDb]: cannot init super!");
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
	return [super initWithInitializedElement:aElem];
}

- (void)dealloc {
	[super dealloc];
}

//--------------------------------------------------------------------
//------------- NSCopying protocoll ---------------------------------------
//--------------------------------------------------------------------
/**
\brief makes a copy of self commonitem for which the sender is responsible for releasing
 */
- (id)copyWithZone:(NSZone *)zone {
	// make a new object with alloc and init and return that
	MBPDFItemValue *newItemval = [[MBPDFItemValue alloc] initWithInitializedElement:[[element copy] autorelease]];
	if(newItemval == nil) {
		CocoLog(LEVEL_ERR,@"[MBImageItemValue -copyWithZone:]: cannot alloc new MBItem!");
	} else {
	}
	
	return newItemval;
}

//--------------------------------------------------------------------
//------------- NSCoding protocoll -----------------------------------
//--------------------------------------------------------------------
- (id)initWithCoder:(NSCoder *)decoder NS_RETURNS_RETAINED {
	MBPDFItemValue *newItemval = nil;
	
	if([decoder allowsKeyedCoding]) {
		// decode the only encoded object
		MBElement *elem = [decoder decodeObjectForKey:@"ItemValueElement"];
		// create commonitem with that
		newItemval = [[MBPDFItemValue alloc] initWithInitializedElement:elem];
	} else {
		// decode the only encoded object
		MBElement *elem = [decoder decodeObject];
		// create commonitem with that
		newItemval = [[MBPDFItemValue alloc] initWithInitializedElement:elem];
	}
	
	return newItemval;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
}

/** convenience methods */
- (BOOL)setPDFDocument:(PDFDocument *)aDoc {
    if(aDoc) {
        [self setValueDataBySavingToTarget:[aDoc dataRepresentation]];
    }
    
    return YES;
}

/** normally only the getter is used */
- (PDFDocument *)pdfDocument {
    return [[[PDFDocument alloc] initWithData:[self valueDataByLoadingFromTarget]] autorelease];
}

@end

@implementation MBPDFItemValue (ElementBase)

/**
\brief write initial valueindex entries to the table
 */
- (void)writeValueIndexEntryWithCreate:(BOOL)flag {
	// first super
	[super writeValueIndexEntryWithCreate:flag];
}

@end

