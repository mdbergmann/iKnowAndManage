#import <CoreGraphics/CoreGraphics.h>//
//  MBBoolItemValue.m
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

#import "MBBoolItemValue.h"
#import "MBElementValue.h"
#import "MBElement.h"
#import "globals.h"
#import "MBValueIndexController.h"

#define ITEMVALUE_BOOL_VALUE_IDENTIFIER				@"itemvalueboolvalue"

@interface MBBoolItemValue (privateAPI)

- (void)createBoolValueAttributeWithValue:(BOOL)flag;

@end

@implementation MBBoolItemValue (privateAPI)

- (void)createBoolValueAttributeWithValue:(BOOL)flag
{
	NSString *key = ITEMVALUE_BOOL_VALUE_IDENTIFIER;
	MBElementValue *elemval = [[[MBElementValue alloc] initWithIdentifier:key andType:NumberValueType] autorelease];
	[elemval setValueDataAsNumber:[NSNumber numberWithBool:flag]];
	[element addElementValue:elemval];
	[attributeDict setObject:elemval forKey:key];
	
	// connect the value to if the element is connected
	[elemval setIsDbConnected:[element isDbConnected] writeIndex:YES];
}

@end

@implementation MBBoolItemValue

// inits
- (id)init
{
	self = [super init];
	if(self == nil)
	{
		CocoLog(LEVEL_ERR,@"[MBBoolItemValue -init]: cannot init super!");
	}
	else
	{
		// set state
		[self setState:InitState];
		
		// set identifier
		[self setIdentifier:BoolItemValueID];
		// set valuetype
		[self setValuetype:BoolItemValueType];
		// bool value
		[self setValueData:NO];
		
		// set state
		[self setState:NormalState];
	}
	
	return self;
}

- (id)initWithDb
{
	self = [self init];
	if(self == nil)
	{
		CocoLog(LEVEL_ERR,@"[MBBoolItemValue -initWithDb]: cannot init super!");
	}
	else
	{
		// set state
		[self setState:InitState];

		// connect element
		[self setIsDbConnected:YES];
		
		// set state
		[self setState:NormalState];
	}
	
	return self;
}

- (id)initWithInitializedElement:(MBElement *)aElem
{
	self = [super initWithInitializedElement:aElem];
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

/**
\brief overriding super classes abstract method
 */
- (NSString *)valueDataAsString
{
	if([self encryptionState] == DecryptedState)
	{
		BOOL val = [self valueData];
		if(val)
		{
			return MBLocaleStr(@"Yes");
		}
		else
		{
			return MBLocaleStr(@"No");		
		}
	}
	else
	{
		return MBLocaleStr(@"Encrypted");
	}
}

/**
\ here is is just a wrapper for valueDataAsString
 */
- (NSString *)valueDataForComparison
{
	return [self valueDataAsString];
}

//--------------------------------------------------------------------
//------------- Item De/Encryption ----------------------
//--------------------------------------------------------------------
/**
\brief this method encrypts the number value of this itemvalue
 The super class melthod is called first to do let it do some work.
 @returns MBCryptoErrorCode
 */
- (MBCryptoErrorCode)encryptWithString:(NSString *)aString
{
    MBCryptoErrorCode ret = MBCryptoOK;
	
	if((aString != nil) || ([aString length] > 0))
	{
		// check the encryption state of this item
		if([self encryptionState] != EncryptedState)
		{
			// call super first
            MBCryptoErrorCode stat = [super encryptWithString:aString];
			// if we get an error here, do not proceed
			if(stat != MBCryptoOK)
			{
				ret = stat;
				CocoLog(LEVEL_WARN,@"super class returned with error, we will not proceed!");
			}
			else
			{
				NSData *encryptedData = nil;
				ret = [self doEncryptionOfData:[self valueDataAsData] 
								 withKeyString:aString 
								 encryptedData:&encryptedData];
				if(ret == MBCryptoOK)
				{
					// set state
					[self setEncryptionState:EncryptedState];
					// write data
					[self setValueDataAsData:encryptedData];
					// register for changing the index
					[[MBValueIndexController defaultController] registerCommonItem:self];
				}
			}
		}
	}
	else
	{
		CocoLog(LEVEL_WARN,@"keyString is nil or empty!");
		ret = MBCryptoUnableToEncrypt;
	}
	
	return ret;
}

/**
\brief this method decrypts the encrypted number and the value that is returned by -valueDataAsData.
 @returns MBCryptoErrorCode
 */
- (MBCryptoErrorCode)decryptWithString:(NSString *)aString
{
    MBCryptoErrorCode ret = MBCryptoOK;
	
	if((aString != nil) || ([aString length] > 0))
	{
		// check the encryption state of this item
		if([self encryptionState] == EncryptedState)
		{
			// first call super decrypt
            MBCryptoErrorCode stat = [super decryptWithString:aString];
			// if we get an error here, do not proceed
			if(stat != MBCryptoOK)
			{
				ret = stat;
				CocoLog(LEVEL_WARN,@"super class returned with error, we will not proceed!");
			}
			else
			{
				NSData *decryptedData = nil;
				ret = [self doDecryptionOfData:[self valueDataAsData] 
								 withKeyString:aString 
								 decryptedData:&decryptedData];
				if(ret == MBCryptoOK)
				{
					// set state
					[self setEncryptionState:DecryptedState];
					// write data
					[self setValueDataAsData:decryptedData];
					// register for changing the index
					[[MBValueIndexController defaultController] registerCommonItem:self];
				}	
			}
		}
	}
	else
	{
		CocoLog(LEVEL_WARN,@"keyString is nil or empty!");
		ret = MBCryptoUnableToDecrypt;
	}
	
	return ret;	
}

//--------------------------------------------------------------------
//------------- NSCopying protocoll ---------------------------------------
//--------------------------------------------------------------------
/**
\brief makes a copy of self commonitem for which the sender is responsible for releasing
 */
- (id)copyWithZone:(NSZone *)zone
{
	// make a new object with alloc and init and return that
	MBBoolItemValue *newItemval = [[MBBoolItemValue alloc] initWithInitializedElement:[[element copy] autorelease]];
	
	if(newItemval == nil)
	{
		CocoLog(LEVEL_ERR,@"cannot alloc new MBItem!");
	}
	else
	{
	}
	
	return newItemval;
}

//--------------------------------------------------------------------
//------------- NSCoding protocoll -----------------------------------
//--------------------------------------------------------------------
- (id)initWithCoder:(NSCoder *)decoder NS_RETURNS_RETAINED {
	MBBoolItemValue *newItemval = nil;
	
	/*
	// get instance of threaded progress indicator
	MBThreadedProgressSheetController *pSheet = [MBThreadedProgressSheetController standardProgressSheetController];
	
	if([pSheet shouldKeepTrackOfProgress] == YES)
	{
		// is there a progress indication going on?
		if([pSheet progressAction] == PASTE_PROGRESS_ACTION)
		{
			// increment indicator
			[pSheet performSelectorOnMainThread:@selector(incrementProgressBy:) 
									 withObject:[NSNumber numberWithDouble:1.0]
								  waitUntilDone:YES];
		}
	}
	 */

	if([decoder allowsKeyedCoding])
	{
		// decode the only encoded object
		MBElement *elem = [decoder decodeObjectForKey:@"ItemValueElement"];
		// create commonitem with that
		newItemval = [[MBBoolItemValue alloc] initWithInitializedElement:elem];
	}
	else
	{
		// decode the only encoded object
		MBElement *elem = [decoder decodeObject];
		// create commonitem with that
		newItemval = [[MBBoolItemValue alloc] initWithInitializedElement:elem];
	}
	
	return newItemval;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	// use encoding method from super class
	[super encodeWithCoder:encoder];
}

@end

@implementation MBBoolItemValue (ElementBase)

// attribute setter
- (void)setValueData:(BOOL)aValue
{
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_BOOL_VALUE_IDENTIFIER];
	if(elemval != nil)
	{
		[elemval setValueDataAsNumber:[NSNumber numberWithInt:(int)aValue]];

		// send Notification
		if(([self state] == NormalState) || ([self state] == UnRedoState))
		{
			// register itemvalue to the list of to be processed valueindexes
			[[MBValueIndexController defaultController] registerCommonItem:self];

			MBSendNotifyItemValueAttribsChanged(self);
		}
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		[self createBoolValueAttributeWithValue:NO];
	}			
}

- (void)setValueDataAsData:(NSData *)aBoolData
{
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_BOOL_VALUE_IDENTIFIER];
	if(elemval != nil)
	{
		[elemval setValueDataAsData:aBoolData];
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		[self createBoolValueAttributeWithValue:NO];
	}			
}

// attribute getter
- (BOOL)valueData
{
	BOOL ret = NO;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_BOOL_VALUE_IDENTIFIER];
	if(elemval != nil)
	{
		ret = (BOOL)[[elemval valueDataAsNumber] intValue];
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		[self createBoolValueAttributeWithValue:ret];
	}
	
	return ret;
}

- (NSData *)valueDataAsData
{
	NSData *ret = nil;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_BOOL_VALUE_IDENTIFIER];
	if(elemval != nil)
	{
		ret = [elemval valueDataAsData];
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		ret = [@"0" dataUsingEncoding:NSUTF8StringEncoding];
		[self createBoolValueAttributeWithValue:NO];
	}
	
	return ret;
}

/**
\brief write initial valueindex entries to the table
 */
- (void)writeValueIndexEntryWithCreate:(BOOL)flag
{
	// first super
	[super writeValueIndexEntryWithCreate:flag];
	
	// bool as string
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_BOOL_VALUE_IDENTIFIER];
	if(flag)
	{
		// create valueindex entry
		[elemval createIndexEntryWithIdentifier:ITEMVALUE_BOOL_VALUE_IDENTIFIER];
	}
	[elemval setIndexValue:[self valueDataAsString]];
}

@end