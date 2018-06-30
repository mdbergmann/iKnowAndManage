//
//  MBTextItemValue.m
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

#import "MBTextItemValue.h"
#import "MBElementValue.h"
#import "MBElement.h"
#import "globals.h"
#import "MBValueIndexController.h"

#define ITEMVALUE_TEXT_VALUE_IDENTIFIER				@"itemvaluetextvalue"

@interface MBTextItemValue (privateAPI)

- (void)createTextValueAttributeWithValue:(NSString *)string;

@end

@implementation MBTextItemValue (privateAPI)

- (void)createTextValueAttributeWithValue:(NSString *)string;
{
	NSString *key = ITEMVALUE_TEXT_VALUE_IDENTIFIER;
	MBElementValue *elemval = [[[MBElementValue alloc] initWithIdentifier:key andType:StringValueType] autorelease];
	[elemval setValueDataAsString:string];	
	[element addElementValue:elemval];
	[attributeDict setObject:elemval forKey:key];
	
	// connect the value to if the element is connected
	[elemval setIsDbConnected:[element isDbConnected] writeIndex:YES];
}

@end

@implementation MBTextItemValue

// inits
- (id)init
{
	self = [super init];
	if(self == nil)
	{
		CocoLog(LEVEL_ERR,@"cannot init super!");
	}
	else
	{
		// set state
		[self setState:InitState];
		
		// set identifier
		[self setIdentifier:TextItemValueID];
		// set valuetype
		[self setValuetype:SimpleTextItemValueType];		
		// text
		[self setValueData:@""];
		
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
		return [self valueData];
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
	MBTextItemValue *newItemval = [[MBTextItemValue alloc] initWithInitializedElement:[[element copy] autorelease]];
	
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
- (id)initWithCoder:(NSCoder *)decoder
{
	MBTextItemValue *newItemval = nil;
	
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
		newItemval = [[[MBTextItemValue alloc] initWithInitializedElement:elem] autorelease];
	}
	else
	{
		// decode the only encoded object
		MBElement *elem = [decoder decodeObject];
		// create commonitem with that
		newItemval = [[[MBTextItemValue alloc] initWithInitializedElement:elem] autorelease];
	}
	
	return newItemval;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	// use encoding method from super class
	[super encodeWithCoder:encoder];
}

@end

@implementation MBTextItemValue (ElementBase)

// attribute setter
- (void)setValueData:(NSString *)aString
{
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_TEXT_VALUE_IDENTIFIER];
	if(elemval != nil)
	{
		[elemval setValueDataAsString:aString];

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
		[self createTextValueAttributeWithValue:aString];
	}		
}

- (void)setValueDataAsData:(NSData *)aStringData
{
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_TEXT_VALUE_IDENTIFIER];
	if(elemval != nil)
	{
		[elemval setValueDataAsData:aStringData];
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		[self createTextValueAttributeWithValue:
			[[[NSString alloc] initWithData:aStringData encoding:NSUTF8StringEncoding] autorelease]];
	}		
}

// attribute getter
- (NSString *)valueData
{
	NSString *ret = nil;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_TEXT_VALUE_IDENTIFIER];
	if(elemval != nil)
	{
		ret = [elemval valueDataAsString];
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		ret = @"";
		[self createTextValueAttributeWithValue:ret];
	}
	
	return ret;
}

- (NSData *)valueDataAsData
{
	NSData *ret = nil;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_TEXT_VALUE_IDENTIFIER];
	if(elemval != nil)
	{
		ret = [elemval valueDataAsData];
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		ret = [@"" dataUsingEncoding:NSUTF8StringEncoding];
		[self createTextValueAttributeWithValue:@""];
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
	
	// text as string
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_TEXT_VALUE_IDENTIFIER];
	if(flag)
	{
		// create valueindex entry
		[elemval createIndexEntryWithIdentifier:ITEMVALUE_TEXT_VALUE_IDENTIFIER];
	}
	[elemval setIndexValue:[self valueDataAsString]];
}

@end
