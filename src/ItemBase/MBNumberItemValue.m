#import <CoreGraphics/CoreGraphics.h>//
//  MBNumberItemValue.m
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

#import "MBNumberItemValue.h"
#import "MBElementValue.h"
#import "MBElement.h"
#import "globals.h"
#import "MBFormatPrefsViewController.h"
#import "MBValueIndexController.h"

#define ITEMVALUE_NUMBER_VALUE_IDENTIFIER				@"itemvaluenumbervalue"
#define ITEMVALUE_NUMBER_USE_GLOBAL_FORMAT_IDENTIFIER	@"itemvaluenumberuseglobalformat"
#define ITEMVALUE_NUMBER_FORMATTERSTRING_IDENTIFIER		@"itemvaluenumberformatterstring"

@interface MBNumberItemValue (privateAPI)

- (void)createNumberValueAttributeWithValue:(NSNumber *)number;
- (void)createNumberUseGlobalFormatAttributeWithValue:(BOOL)flag;
- (void)createNumberFormatterStringAttributeWithValue:(NSString *)string;

@end

@implementation MBNumberItemValue (privateAPI)

- (void)createNumberValueAttributeWithValue:(NSNumber *)number
{
	NSString *key = ITEMVALUE_NUMBER_VALUE_IDENTIFIER;
	MBElementValue *elemval = [[[MBElementValue alloc] initWithIdentifier:key andType:NumberValueType] autorelease];
	[elemval setValueDataAsNumber:number];
	[element addElementValue:elemval];
	[attributeDict setObject:elemval forKey:key];
	
	// connect the value to if the element is connected
	[elemval setIsDbConnected:[element isDbConnected] writeIndex:YES];
}

- (void)createNumberUseGlobalFormatAttributeWithValue:(BOOL)flag
{
	NSString *key = ITEMVALUE_NUMBER_USE_GLOBAL_FORMAT_IDENTIFIER;
	MBElementValue *elemval = [[[MBElementValue alloc] initWithIdentifier:key andType:NumberValueType] autorelease];
	[elemval setValueDataAsNumber:[NSNumber numberWithBool:flag]];
	[element addElementValue:elemval];
	[attributeDict setObject:elemval forKey:key];	
	
	// connect the value to if the element is connected
	[elemval setIsDbConnected:[element isDbConnected] writeIndex:NO];
}

- (void)createNumberFormatterStringAttributeWithValue:(NSString *)string
{
	NSString *key = ITEMVALUE_NUMBER_FORMATTERSTRING_IDENTIFIER;
	MBElementValue *elemval = [[[MBElementValue alloc] initWithIdentifier:key andType:StringValueType] autorelease];
	[elemval setValueDataAsString:string];
	[element addElementValue:elemval];
	[attributeDict setObject:elemval forKey:key];
	
	// connect the value to if the element is connected
	[elemval setIsDbConnected:[element isDbConnected] writeIndex:NO];
}

@end

@implementation MBNumberItemValue

- (id)init
{
	self = [super init];
	if(self == nil)
	{
		CocoLog(LEVEL_ERR, @"cannot init super!");
	}
	else
	{
		// set state
		[self setState:InitState];

		// set identifier
		[self setIdentifier:NumberItemValueID];
		
		// set valuetype
		[self setValuetype:NumberItemValueType];
		
		// number
		[self setValueData:[NSNumber numberWithInt:0]];
		// formatter string
		[self setFormatterString:[userDefaults objectForKey:MBDefaultsNumberFormatKey]];
		// use global format
		[self setUseGlobalFormat:YES];
		
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
		CocoLog(LEVEL_ERR,@"cannot init super!");
	}
	else
	{
		// set state
		[self setState:InitState];
		
		// connect the itemvalue
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
	NSString *numberAsString = nil;
	
	if([self encryptionState] == DecryptedState)
	{
		NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
		// set format
		if([self useGlobalFormat])
		{
			[formatter setFormat:[userDefaults valueForKey:MBDefaultsNumberFormatKey]];
		}
		else
		{
			[formatter setFormat:[self formatterString]];
		}
		
		numberAsString = [formatter stringForObjectValue:[self valueData]];		
	}
	else
	{
		numberAsString = MBLocaleStr(@"Encrypted");
	}
	
	return numberAsString;
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
				NSData *data = [self valueDataAsData];
				NSData *encryptedData = nil;
				ret = [self doEncryptionOfData:data
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
				NSData *data = [self valueDataAsData];
				NSData *decryptedData = nil;
				ret = [self doDecryptionOfData:data 
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
	MBNumberItemValue *newItemval = [[MBNumberItemValue alloc] initWithInitializedElement:[[element copy] autorelease]];
	
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
	MBNumberItemValue *newItemval = nil;
	
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
		newItemval = [[MBNumberItemValue alloc] initWithInitializedElement:elem];
	}
	else
	{
		// decode the only encoded object
		MBElement *elem = [decoder decodeObject];
		// create commonitem with that
		newItemval = [[MBNumberItemValue alloc] initWithInitializedElement:elem];
	}
	
	return newItemval;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	// use encoding method from super class
	[super encodeWithCoder:encoder];
}

@end

@implementation MBNumberItemValue (ElementBase)

// attribute setter
- (void)setValueData:(NSNumber *)aNumber
{
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_NUMBER_VALUE_IDENTIFIER];
	if(elemval != nil)
	{
		[elemval setValueDataAsNumber:aNumber];

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
		[self createNumberValueAttributeWithValue:aNumber];
	}			
}

- (void)setValueDataAsData:(NSData *)aNumberData
{
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_NUMBER_VALUE_IDENTIFIER];
	if(elemval != nil)
	{
		[elemval setValueDataAsData:aNumberData];
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, cannot set valueData!");
		//[self createNumberValueAttributeWithValue:aNumber];
	}	
}

- (void)setUseGlobalFormat:(BOOL)aSetting
{
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_NUMBER_USE_GLOBAL_FORMAT_IDENTIFIER];
	if(elemval != nil)
	{
		[elemval setValueDataAsNumber:[NSNumber numberWithBool:aSetting]];

		// send Notification
		if(([self state] == NormalState) || ([self state] == UnRedoState))
		{
			MBSendNotifyItemValueAttribsChanged(self);
		}
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		[self createNumberUseGlobalFormatAttributeWithValue:aSetting];
	}	
}

- (void)setFormatterString:(NSString *)aFormat
{
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_NUMBER_FORMATTERSTRING_IDENTIFIER];
	if(elemval != nil)
	{
		[elemval setValueDataAsString:aFormat];

		// send Notification
		if(([self state] == NormalState) || ([self state] == UnRedoState))
		{
			MBSendNotifyItemValueAttribsChanged(self);
		}
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		[self createNumberFormatterStringAttributeWithValue:aFormat];
	}	
}

// attribute getter
- (NSNumber *)valueData
{
	NSNumber *ret = nil;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_NUMBER_VALUE_IDENTIFIER];
	if(elemval != nil)
	{
		ret = [elemval valueDataAsNumber];
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		ret = [NSNumber numberWithInt:0];
		[self createNumberValueAttributeWithValue:ret];
	}
	
	return ret;
}

- (NSData *)valueDataAsData
{
	NSData *ret = nil;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_NUMBER_VALUE_IDENTIFIER];
	if(elemval != nil)
	{
		ret = [elemval valueDataAsData];
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		ret = [NSData data];
		[self createNumberValueAttributeWithValue:[NSNumber numberWithInt:0]];
	}
	
	return ret;
}

- (NSString *)formatterString
{
	NSString *ret = nil;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_NUMBER_FORMATTERSTRING_IDENTIFIER];
	if(elemval != nil)
	{
		ret = [elemval valueDataAsString];
	}
	else
	{
		CocoLog(LEVEL_WARN,@"[elementvalue is nil, creating it!");
		ret = [userDefaults valueForKey:MBDefaultsNumberFormatKey];
		[self createNumberFormatterStringAttributeWithValue:ret];
	}
	
	return ret;	
}

- (BOOL)useGlobalFormat
{
	BOOL ret = YES;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_NUMBER_USE_GLOBAL_FORMAT_IDENTIFIER];
	if(elemval != nil)
	{
		ret = [[elemval valueDataAsNumber] boolValue];
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		[self createNumberUseGlobalFormatAttributeWithValue:ret];
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
	
	// number as string
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_NUMBER_VALUE_IDENTIFIER];
	if(flag)
	{
		// create valueindex entry
		[elemval createIndexEntryWithIdentifier:ITEMVALUE_NUMBER_VALUE_IDENTIFIER];
	}
	[elemval setIndexValue:[self valueDataAsString]];
}

@end