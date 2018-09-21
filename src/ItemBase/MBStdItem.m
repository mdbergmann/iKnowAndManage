
//  MBStdItem.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 25.08.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import "MBStdItem.h"
#import "MBItemBaseController.h"
#import "MBElementValue.h"
#import "MBElement.h"
#import "globals.h"
#import "MBValueIndexController.h"
#import "ColorRGBAArchiver.h"
#import "MBPreferenceController.h"
#import "MBSystemItem.h"

#define ITEM_COMMENT_IDENTIFIER			@"itemcomment"
#define ITEM_DATECREATED_IDENTIFIER		@"itemdatecreated"
#define ITEM_DATEMODIFIED_IDENTIFIER	@"itemdatemodified"
#define ITEM_FGCOLOR_IDENTIFIER			@"itemfgcolor"
#define ITEM_BGCOLOR_IDENTIFIER			@"itembgcolor"

@interface MBStdItem (privateAPI)

// undo/redo
- (void)setFromUndoElementValue:(MBElementValue *)aElemval withUnRedoOp:(MBItemUnRedoOperations)op;

@end

@implementation MBStdItem (privateAPI)

/**
\brief set attribute op dependant from a given element
 This method is used for undo / redo operations, this means, the given element is a element under "undoElement" and will be deleted.
 */
- (void)setFromUndoElementValue:(MBElementValue *)aElemval withUnRedoOp:(MBItemUnRedoOperations)op
{
	// we can only undo this stuff
	if(op == UnRedoItemComment)
	{
		if(aElemval != nil)
		{
			// set state
			[self setState:UnRedoState];
			
			// make a snapshot for undo
			MBItemBaseController *ibc = [MBItemBaseController standardController];
			// get the undo manager
			NSUndoManager *undoManager = [ibc undoManager];
			
			// check, if we can register undos
			if([undoManager isUndoRegistrationEnabled])
			{
				if(![undoManager isUndoing])
				{
					CocoLog(LEVEL_DEBUG,@"doing undo step!");
					
					// disable further undos steps in here
					[undoManager disableUndoRegistration];					
					
					MBElementValue *undoBuf = nil;
					if(op == UnRedoItemComment)
					{
						undoBuf = [[self elementValueForIdentifier:ITEM_COMMENT_IDENTIFIER] copy];
					}
					MBElement *undoElement = [[ibc undoItem] element];
					// add undoBuf to undoElement
					[undoElement addElementValue:undoBuf];
					// release undoBuf after adding
					[undoBuf release];
					
					// reenable undo registration
					[undoManager enableUndoRegistration];
					
					// prepare for undo manager
					[[undoManager prepareWithInvocationTarget:self] setFromUndoElementValue:undoBuf withUnRedoOp:op];
					
					// set action name for undo
					//[undoManager setActionName:MBLocaleStr(@"UndoChangeElementName")];
				}
				else
				{
					CocoLog(LEVEL_DEBUG,@"doing redo step!");
					
					MBElementValue *redoBuf = nil;
					if(op == UnRedoItemComment)
					{
						redoBuf = [[self elementValueForIdentifier:ITEM_COMMENT_IDENTIFIER] copy];
					}
					MBElement *undoElement = [[ibc undoItem] element];
					// add redoBuf to undoElement
					[undoElement addElementValue:redoBuf];
					// release undoBuf after adding
					[redoBuf release];
					// prepare for undo manager
					[[undoManager prepareWithInvocationTarget:self] setFromUndoElementValue:redoBuf withUnRedoOp:op];
				}
			}
			
			if(op == UnRedoItemComment)
			{
				// set the comment
				[self setComment:[aElemval valueDataAsString]];
			}
			
			// delete the given element
			if([aElemval element] != nil)
			{
				[[aElemval element] removeElementValue:aElemval];
			}
			else
			{
				CocoLog(LEVEL_WARN,@"element is nil!");
			}
			
			// set state
			[self setState:NormalState];
		}
	}
	else
	{
		// try superclass for undo
		[super setFromUndoElementValue:aElemval withUnRedoOp:op];
	}
}

@end

@implementation MBStdItem

- (id)init {
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"cannot init super!");
	} else {
		// set state
		[self setState:InitState];
		
		// set element identifier
		[self setIdentifier:StdItemID];
		
		//NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		// add neccesary attributes
		[self setComment:@""];
		[self setDateCreated:[NSDate date]];
		[self setDateModified:[NSDate date]];
		// we do not need this as long as we are not dealing with color
		//[self setFgColor:[NSColor colorFromRGBAArchivedString:[defaults objectForKey:MBDefaultsItemValueFgColorKey]]];
		//[self setBgColor:[NSColor colorFromRGBAArchivedString:[defaults objectForKey:MBDefaultsItemValueBgColorKey]]];
		
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
	CocoLog(LEVEL_DEBUG,@"[MBStdItem -dealloc]");
	
	// set state
	[self setState:DeallocState];
	
	// release super
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
	MBStdItem *newItem = [[MBStdItem alloc] initWithInitializedElement:[[element copy] autorelease]];
	if(newItem == nil) {
		CocoLog(LEVEL_ERR,@"cannot alloc new MBItem!");
	} else {
	}
	
	return newItem;
}

//--------------------------------------------------------------------
//------------- NSCoding protocoll -----------------------------------
//--------------------------------------------------------------------
- (id)initWithCoder:(NSCoder *)decoder NS_RETURNS_RETAINED {
	MBStdItem *newItem = nil;
	
	if([decoder allowsKeyedCoding]) {
		// decode the only encoded object
		MBElement *elem = [decoder decodeObjectForKey:@"ItemElement"];
		// create commonitem with that
		newItem = [[MBStdItem alloc] initWithInitializedElement:elem];
	} else {
		// decode the only encoded object
		MBElement *elem = [decoder decodeObject];
		// create commonitem with that
		newItem = [[MBStdItem alloc] initWithInitializedElement:elem];
	}
	
	return newItem;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	// first call super
	[super encodeWithCoder:encoder];
}

@end

@implementation MBStdItem (ElementBase)

// attribute setter
- (void)setComment:(NSString *)aComment {
	MBElementValue *elemval = [attributeDict valueForKey:ITEM_COMMENT_IDENTIFIER];
	if(elemval != nil) {
		if(![[elemval valueDataAsString] isEqualToString:aComment]) {
			// make a snapshot for undo
			MBItemBaseController *ibc = [MBItemBaseController standardController];
			if([ibc state] == NormalState) {
				// check state
				if([self state] == NormalState) {
					// get the undo manager
					NSUndoManager *undoManager = [ibc undoManager];
					
					// check, if we can register undos
					if([undoManager isUndoRegistrationEnabled]) {
						CocoLog(LEVEL_DEBUG,@"doing undo step!");
						
						// disable further undos steps in here
						[undoManager disableUndoRegistration];					
						
						MBElementValue *undoBuf = [elemval copy];
						MBElement *undoElement = [[ibc undoItem] element];
						// add a child to undoElement
						// each child of undoElement stands for one undo step
						MBElement *undoStep = [[MBElement alloc] init];
						// add to undoElement
						[undoElement addChild:undoStep];
						[undoStep release];
						// add undoBuf to undoStep
						[undoStep addElementValue:undoBuf];
						// release undoBuf after adding
						[undoBuf release];
						
						// reenable undo registration
						[undoManager enableUndoRegistration];
						
						// prepare for undo manager
						[[undoManager prepareWithInvocationTarget:self] setFromUndoElementValue:undoBuf withUnRedoOp:UnRedoItemComment];
						
						// set action name for undo
						[undoManager setActionName:MBLocaleStr(@"UndoChangeItemComment")];
					}
				}
			}
			
			// set comment
			[elemval setValueDataAsString:aComment];
			
			// send Notification
			if(([self state] == NormalState) || ([self state] == UnRedoState)) {
				// register itemvalue to the list of to be processed valueindexes
				[[MBValueIndexController defaultController] registerCommonItem:self];
				
				MBSendNotifyItemAttribsChanged(self);
			}
		}
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
        [self createAttributeForValue:aComment withValueType:StringValueType identifier:ITEM_COMMENT_IDENTIFIER];
	}	
}

- (void)setDateCreated:(NSDate *)aDate {
	MBElementValue *elemval = [attributeDict valueForKey:ITEM_DATECREATED_IDENTIFIER];
	if(elemval != nil) {
		[elemval setValueDataAsNumber:[NSNumber numberWithDouble:[aDate timeIntervalSince1970]]];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
        [self createAttributeForValue:[NSNumber numberWithDouble:[aDate timeIntervalSince1970]] 
                        withValueType:NumberValueType identifier:ITEM_DATECREATED_IDENTIFIER writeIndex:NO];
	}
}

- (void)setDateModified:(NSDate *)aDate {
	MBElementValue *elemval = [attributeDict valueForKey:ITEM_DATEMODIFIED_IDENTIFIER];
	if(elemval != nil) {
		[elemval setValueDataAsNumber:[NSNumber numberWithDouble:[aDate timeIntervalSince1970]]];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
        [self createAttributeForValue:[NSNumber numberWithDouble:[aDate timeIntervalSince1970]] 
                        withValueType:NumberValueType identifier:ITEM_DATEMODIFIED_IDENTIFIER writeIndex:NO];
	}	
}

- (void)setFgColor:(NSColor *)aColor {
	MBElementValue *elemval = [attributeDict valueForKey:ITEM_FGCOLOR_IDENTIFIER];
	if(elemval != nil) {
		[elemval setValueDataAsString:[aColor archiveRGBAComponentsAsString]];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
        [self createAttributeForValue:[aColor archiveRGBAComponentsAsString] withValueType:StringValueType identifier:ITEM_FGCOLOR_IDENTIFIER writeIndex:NO];
	}		
}

- (void)setBgColor:(NSColor *)aColor {
	MBElementValue *elemval = [attributeDict valueForKey:ITEM_BGCOLOR_IDENTIFIER];
	if(elemval != nil) {
		[elemval setValueDataAsString:[aColor archiveRGBAComponentsAsString]];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
        [self createAttributeForValue:[aColor archiveRGBAComponentsAsString] withValueType:StringValueType identifier:ITEM_BGCOLOR_IDENTIFIER writeIndex:NO];
	}	
}

// attribute getter
- (NSString *)comment {
	NSString *ret = nil;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEM_COMMENT_IDENTIFIER];
	if(elemval != nil) {
		ret = [elemval valueDataAsString];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		ret = @"";
        [self createAttributeForValue:ret withValueType:StringValueType identifier:ITEM_COMMENT_IDENTIFIER];
	}	
	
	return ret;
}

- (NSDate *)dateCreated {
	NSDate *ret = nil;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEM_DATECREATED_IDENTIFIER];
	if(elemval != nil) {
		ret = [NSDate dateWithTimeIntervalSince1970:[[elemval valueDataAsNumber] doubleValue]];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		ret = [NSDate date];
        [self createAttributeForValue:[NSNumber numberWithDouble:[ret timeIntervalSince1970]] 
                        withValueType:NumberValueType identifier:ITEM_DATECREATED_IDENTIFIER writeIndex:NO];
	}	
	
	return ret;
}

- (NSDate *)dateModified {
	NSDate *ret = nil;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEM_DATEMODIFIED_IDENTIFIER];
	if(elemval != nil) {
		ret = [NSDate dateWithTimeIntervalSince1970:[[elemval valueDataAsNumber] doubleValue]];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		ret = [NSDate date];
        [self createAttributeForValue:[NSNumber numberWithDouble:[ret timeIntervalSince1970]] 
                        withValueType:NumberValueType identifier:ITEM_DATEMODIFIED_IDENTIFIER writeIndex:NO];
	}	
	
	return ret;
}

- (NSColor *)fgColor {
	NSColor *ret = nil;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEM_FGCOLOR_IDENTIFIER];
	if(elemval != nil) {
		ret = [NSColor colorFromRGBAArchivedString:[elemval valueDataAsString]];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		ret = [NSColor colorFromRGBAArchivedString:[userDefaults valueForKey:MBDefaultsItemValueFgColorKey]];
        [self createAttributeForValue:[ret archiveRGBAComponentsAsString] withValueType:StringValueType identifier:ITEM_FGCOLOR_IDENTIFIER writeIndex:NO];
	}	
	
	return ret;
}

- (NSColor *)bgColor {
	NSColor *ret = nil;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEM_BGCOLOR_IDENTIFIER];
	if(elemval != nil) {
		ret = [NSColor colorFromRGBAArchivedString:[elemval valueDataAsString]];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		ret = [NSColor colorFromRGBAArchivedString:[userDefaults valueForKey:MBDefaultsItemValueBgColorKey]];
        [self createAttributeForValue:[ret archiveRGBAComponentsAsString] withValueType:StringValueType identifier:ITEM_BGCOLOR_IDENTIFIER writeIndex:NO];
	}	
	
	return ret;
}

/**
\brief write initial valueindex entries to the table
 */
- (void)writeValueIndexEntryWithCreate:(BOOL)flag {
	// here comment
	
	// comment
	MBElementValue *elemval = [attributeDict valueForKey:ITEM_COMMENT_IDENTIFIER];
	if(flag) {
		// create valueindex entry
		[elemval createIndexEntryWithIdentifier:ITEM_COMMENT_IDENTIFIER];
	}
	[elemval setIndexValue:[self comment]];
}

@end
