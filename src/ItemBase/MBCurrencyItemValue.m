#import <CoreGraphics/CoreGraphics.h>//
//  MBCurrencyItemValue.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 31.08.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import "MBCurrencyItemValue.h"
#import "MBElementValue.h"
#import "MBElement.h"
#import "MBFormatPrefsViewController.h"
#import "globals.h"
#import "MBValueIndexController.h"

#define ITEMVALUE_CURRENCY_SYMBOL_IDENTIFIER			@"itemvaluecurrencysymbol"

@interface MBCurrencyItemValue (privateAPI)

- (void)createCurrencySymbolStringAttributeWithValue:(NSString *)string;

@end

@implementation MBCurrencyItemValue (privateAPI)

- (void)createCurrencySymbolStringAttributeWithValue:(NSString *)string
{
	NSString *key = ITEMVALUE_CURRENCY_SYMBOL_IDENTIFIER;
	MBElementValue *elemval = [[[MBElementValue alloc] initWithIdentifier:key andType:StringValueType] autorelease];
	[elemval setValueDataAsString:string];
	[element addElementValue:elemval];
	[attributeDict setObject:elemval forKey:key];
	
	// connect the value to if the element is connected
	[elemval setIsDbConnected:[element isDbConnected] writeIndex:YES];
}

@end

@implementation MBCurrencyItemValue

- (id)init
{
	self = [super init];
	if(self == nil)
	{
		CocoLog(LEVEL_ERR,@"[MBCurrencyItemValue -init:]: cannot init super!");
	}
	else
	{
		// set state
		[self setState:InitState];
		
		// set identifier
		[self setIdentifier:CurrencyItemValueID];
		
		// set valuetype
		[self setValuetype:CurrencyItemValueType];
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		// currency symbol
		[self setCurrencySymbol:[defaults valueForKey:MBDefaultsCurrencyFormatCurrencySymbolKey]];
		// set currency format string
		[self setFormatterString:[defaults valueForKey:MBDefaultsCurrencyFormatKey]];
		
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
		CocoLog(LEVEL_ERR,@"[MBCurrencyItemValue -initWithDb]: cannot init super!");
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
	NSString *numberAsString = nil;
	
	if([self encryptionState] == DecryptedState)
	{
		NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
		// set format
		if([self useGlobalFormat])
		{
			[formatter setFormat:[userDefaults valueForKey:MBDefaultsCurrencyFormatKey]];
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
//------------- NSCopying protocoll ---------------------------------------
//--------------------------------------------------------------------
/**
\brief makes a copy of self commonitem for which the sender is responsible for releasing
 */
- (id)copyWithZone:(NSZone *)zone
{
	// make a new object with alloc and init and return that
	MBCurrencyItemValue *newItemval = [[MBCurrencyItemValue alloc] initWithInitializedElement:[[element copy] autorelease]];
	
	if(newItemval == nil)
	{
		CocoLog(LEVEL_ERR,@"[MBCurrencyItemValue -copyWithZone:]: cannot alloc new MBItem!");
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
	MBCurrencyItemValue *newItemval = nil;
	
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
		newItemval = [[MBCurrencyItemValue alloc] initWithInitializedElement:elem];
	}
	else
	{
		// decode the only encoded object
		MBElement *elem = [decoder decodeObject];
		// create commonitem with that
		newItemval = [[MBCurrencyItemValue alloc] initWithInitializedElement:elem];
	}
	
	return newItemval;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	// use encoding method from super class
	[super encodeWithCoder:encoder];
}

@end

@implementation MBCurrencyItemValue (ElementBase)

// setter
- (void)setCurrencySymbol:(NSString *)aSymbol
{
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_CURRENCY_SYMBOL_IDENTIFIER];
	if(elemval != nil)
	{
		[elemval setValueDataAsString:aSymbol];

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
		CocoLog(LEVEL_WARN,@"[MBCurrencyItemValue -setCurrencySymbol:] elementvalue is nil, creating it!");
		[self createCurrencySymbolStringAttributeWithValue:aSymbol];
	}	
}

// getter
- (NSString *)currencySymbol
{
	NSString *ret = nil;

	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_CURRENCY_SYMBOL_IDENTIFIER];
	if(elemval != nil)
	{
		ret = [elemval valueDataAsString];
	}
	else
	{
		CocoLog(LEVEL_WARN,@"[MBCurrencyItemValue -currencySymbol:] elementvalue is nil, creating it!");
		ret = [userDefaults valueForKey:MBDefaultsCurrencyFormatCurrencySymbolKey];
		[self createCurrencySymbolStringAttributeWithValue:ret];
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
	
	// currencysymbol as string
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_CURRENCY_SYMBOL_IDENTIFIER];
	if(flag)
	{
		// create valueindex entry
		[elemval createIndexEntryWithIdentifier:ITEMVALUE_CURRENCY_SYMBOL_IDENTIFIER];
	}
	[elemval setIndexValue:[self currencySymbol]];
}

@end
