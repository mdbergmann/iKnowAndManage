//
//  MBCurrencyFormatSetterViewController.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 15.07.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import "MBCurrencyFormatSetterViewController.h"


@implementation MBCurrencyFormatSetterViewController

/**
\brief init is called after alloc:. some initialization work can be done here.
 No GUI elements are available here. It additinally calls the init method of superclass
 @returns initialized not nil object
 */
- (id)init
{
	MBLOG(MBLOG_DEBUG,@"init of MBCurrencyFormatSetterViewController");
	
	self = [super init];
	if(self == nil)
	{
		MBLOG(MBLOG_ERR,@"cannot alloc MBCurrencyFormatSetterViewController!");		
	}
	else
	{
	}
	
	return self;
}

/**
\brief dealloc of this class is called on closing this document
 */
- (void)dealloc
{
	MBLOG(MBLOG_DEBUG,@"dealloc of MBCurrencyFormatSetterViewController");
	
	// dealloc object
	[super dealloc];
}

//--------------------------------------------------------------------
//----------- bundle delegates ---------------------------------------
//--------------------------------------------------------------------
- (void)awakeFromNib
{
	MBLOG(MBLOG_DEBUG,@"awakeFromNib of MBCurrencyFormatSetterViewController");
	
	if(self != nil)
	{
		// set default values
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		// set number format stuff
		[useDecimalDigitsButton setState:[defaults boolForKey:MBDefaultsCurrencyFormatUseDecimalDigitsKey]]; 
		[useRedColorOnNegativesButton setState:[defaults boolForKey:MBDefaultsCurrencyFormatUseRedNegativesKey]];
		[useThousandSeparatorButton setState:[defaults boolForKey:MBDefaultsCurrencyFormatUseThousandSeparatorKey]];
		[numberOfDigitsStepper setIntValue:[defaults integerForKey:MBDefaultsCurrencyFormatNumberOfDecimalDigitsKey]];
		[numberOfDigitsTextField setIntValue:[defaults integerForKey:MBDefaultsCurrencyFormatNumberOfDecimalDigitsKey]];
		[currencySymbolTextField setStringValue:[defaults objectForKey:MBDefaultsCurrencyFormatCurrencySymbolKey]];
		
		// set format and values
		[self createAndSetFormatString];
	}
}

// create new format string
- (void)createAndSetFormatStringForType:(int)aType
{
	// set default values
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	BOOL thousands;
	BOOL decimals;
	BOOL red;
	int decDigits;
	NSString *cSymbol;
	NSString *decSep;
	NSString *thSep;

	if(aType == CurrencyFormatType)
	{
		thousands = [defaults boolForKey:MBDefaultsCurrencyFormatUseThousandSeparatorKey];
		decimals = [defaults boolForKey:MBDefaultsCurrencyFormatUseDecimalDigitsKey];
		red = [defaults boolForKey:MBDefaultsCurrencyFormatUseRedNegativesKey];
		decDigits = [defaults integerForKey:MBDefaultsCurrencyFormatNumberOfDecimalDigitsKey];
		cSymbol = [defaults objectForKey:MBDefaultsCurrencyFormatCurrencySymbolKey];
		decSep = [defaults objectForKey:NSDecimalSeparator];
		thSep = [defaults objectForKey:NSThousandsSeparator];
	}
	else
	{
		thousands = [defaults boolForKey:MBDefaultsNumberFormatUseThousandSeparatorKey];
		decimals = [defaults boolForKey:MBDefaultsNumberFormatUseDecimalDigitsKey];
		red = [defaults boolForKey:MBDefaultsNumberFormatUseRedNegativesKey];
		decDigits = [defaults integerForKey:MBDefaultsNumberFormatNumberOfDecimalDigitsKey];
		decSep = [defaults objectForKey:NSDecimalSeparator];
		thSep = [defaults objectForKey:NSThousandsSeparator];
		cSymbol = @"";
	}
	
	NSString *posBase = @"";
	NSString *negBase = @"";
	NSString *redNegBase = @"";
	NSMutableString *format = [NSMutableString stringWithString:@""];
	
	// define base
	if(thousands == YES)
	{
		posBase = [NSString stringWithFormat:@"%@ #,##0",cSymbol];
		negBase = [NSString stringWithFormat:@"%@ -#,##0",cSymbol];
		redNegBase = [NSString stringWithFormat:@"[Red]%@ -#,##0",cSymbol];
	}
	else
	{
		posBase = [NSString stringWithFormat:@"%@ 0",cSymbol];
		negBase = [NSString stringWithFormat:@"%@ -0",cSymbol];
		redNegBase = [NSString stringWithFormat:@"[Red]%@ -0",cSymbol];
	}
	[format appendString:posBase];
	
	if((decimals == YES) && (decDigits > 0))
	{
		[format appendString:@"."];
		
		for(int i = 0;i < decDigits;i++)
		{
			[format appendString:@"0"];
		}
	}
	[format appendString:@";"];
	
	// null
	[format appendString:@"0"];
	if((decimals == YES) && (decDigits > 0))
	{
		[format appendString:@"."];
		
		for(int i = 0;i < decDigits;i++)
		{
			[format appendString:@"0"];
		}
	}
	[format appendString:@";"];
	
	// negative
	if(red == YES)
	{
		[format appendString:redNegBase];			
	}
	else
	{
		[format appendString:negBase];		
	}
	if((decimals == YES) && (decDigits > 0))
	{
		[format appendString:@"."];
		
		for(int i = 0;i < decDigits;i++)
		{
			[format appendString:@"0"];
		}
	}
	
	[defaults setObject:format forKey:MBDefaultsCurrencyFormatKey];
	
	// set decimal and thousand separators
	[[negativeExampleTextField formatter] setDecimalSeparator:decSep];
	[[positiveExampleTextField formatter] setThousandSeparator:thSep];
	// set to example textfields
	[[negativeExampleTextField formatter] setFormat:format];
	[[positiveExampleTextField formatter] setFormat:format];
	// set values to example textfields
	[positiveExampleTextField setObjectValue:[NSNumber numberWithInt:123456]];
	[negativeExampleTextField setObjectValue:[NSNumber numberWithInt:-123456]];
}

- (IBAction)numberOfDecimalsChange:(id)sender
{
	MBLOG(MBLOG_DEBUG,@"numberOfDecimalsChanged...");
	
	// set default values
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setInteger:[sender intValue] forKey:MBDefaultsCurrencyFormatNumberOfDecimalDigitsKey];
	// set textfield
	[numberOfDigitsTextField setIntValue:[sender intValue]];
	
	// create new format string
	[self createAndSetFormatString];
}

- (IBAction)switchDecimalsDigits:(id)sender
{
	MBLOG(MBLOG_DEBUG,@"switchDecimalsDigits...");
	
	// set default values
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:(BOOL)[sender state] forKey:MBDefaultsCurrencyFormatUseDecimalDigitsKey];
	
	// create new format string
	[self createAndSetFormatString];
}

- (IBAction)switchThoudsandSeparator:(id)sender
{
	MBLOG(MBLOG_DEBUG,@"switchThoudsandSeparator...");
	
	// set default values
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:(BOOL)[sender state] forKey:MBDefaultsCurrencyFormatUseThousandSeparatorKey];
	
	// create new format string
	[self createAndSetFormatString];
}

- (IBAction)switchUseRedColorForNegatives:(id)sender
{
	MBLOG(MBLOG_DEBUG,@"switchUseRedColorForNegatives...");
	
	// set default values
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:(BOOL)[sender state] forKey:MBDefaultsCurrencyFormatUseRedNegativesKey];
	
	// create new format string
	[self createAndSetFormatString];
}

- (IBAction)currencySymbolInput:(id)sender
{
	MBLOG(MBLOG_DEBUG,@"currencySymbolInput...");
	
	// set default values
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:[sender stringValue] forKey:MBDefaultsCurrencyFormatCurrencySymbolKey];
	
	// create new format string
	[self createAndSetFormatString];	
}

@end
