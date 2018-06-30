#import <CocoLogger/CocoLogger.h>
#import "MBNumberFormatSetterViewController.h"
#import "MBFormatPrefsViewController.h"


// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$


@implementation MBNumberFormatSetterViewController

/**
\brief init is called after alloc:. some initialization work can be done here.
 No GUI elements are available here. It additinally calls the init method of superclass
 @returns initialized not nil object
 */
- (id)init
{
	CocoLog(LEVEL_DEBUG,@"init of MBNumberFormatSetterViewController");
	
	self = [super init];
	if(self == nil)
	{
		CocoLog(LEVEL_ERR,@"cannot alloc MBNumberFormatSetterViewController!");		
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
	CocoLog(LEVEL_DEBUG,@"dealloc of MBNumberFormatSetterViewController");
	
	// dealloc object
	[super dealloc];
}

//--------------------------------------------------------------------
//----------- bundle delegates ---------------------------------------
//--------------------------------------------------------------------
- (void)awakeFromNib
{
	CocoLog(LEVEL_DEBUG,@"awakeFromNib of MBNumberFormatSetterViewController");
	
	if(self != nil)
	{
	}
}

- (NSView *)theView
{
	return theView;
}

- (void)setValuesForType:(int)aType
{
	// set type
	currentType = aType;
	
	// set default values
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	// set number format stuff
	if(aType == NumberFormatType)
	{
		[useDecimalDigitsButton setState:[defaults boolForKey:MBDefaultsNumberFormatUseDecimalDigitsKey]]; 
		[useRedColorOnNegativesButton setState:[defaults boolForKey:MBDefaultsNumberFormatUseRedNegativesKey]];
		[useThousandSeparatorButton setState:[defaults boolForKey:MBDefaultsNumberFormatUseThousandSeparatorKey]];
		[numberOfDigitsStepper setIntValue:[defaults integerForKey:MBDefaultsNumberFormatNumberOfDecimalDigitsKey]];
		[numberOfDigitsTextField setIntValue:[defaults integerForKey:MBDefaultsNumberFormatNumberOfDecimalDigitsKey]];
		[currencySymbolTextField setStringValue:@""];
		// deactivate currency symbolfield
		[currencySymbolTextField setEnabled:NO];
		[currencySymbolLabel setEnabled:NO];
		[currencySymbolTextField setHidden:YES];
		[currencySymbolLabel setHidden:YES];
	}
	else
	{
		[useDecimalDigitsButton setState:[defaults boolForKey:MBDefaultsCurrencyFormatUseDecimalDigitsKey]]; 
		[useRedColorOnNegativesButton setState:[defaults boolForKey:MBDefaultsCurrencyFormatUseRedNegativesKey]];
		[useThousandSeparatorButton setState:[defaults boolForKey:MBDefaultsCurrencyFormatUseThousandSeparatorKey]];
		[numberOfDigitsStepper setIntValue:[defaults integerForKey:MBDefaultsCurrencyFormatNumberOfDecimalDigitsKey]];
		[numberOfDigitsTextField setIntValue:[defaults integerForKey:MBDefaultsCurrencyFormatNumberOfDecimalDigitsKey]];
		[currencySymbolTextField setStringValue:[defaults objectForKey:MBDefaultsCurrencyFormatCurrencySymbolKey]];		
		// activate currency symbolfield
		[currencySymbolTextField setEnabled:YES];
		[currencySymbolLabel setEnabled:YES];
		[currencySymbolTextField setHidden:NO];
		[currencySymbolLabel setHidden:NO];
	}
	
	// set format and values
	[self createAndSetFormatStringForType:aType];	
}

// create new format string
- (NSString *)createAndSetFormatStringForType:(int)aType
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
	
	if(aType == CurrencyFormatType)
	{
		[defaults setObject:format forKey:MBDefaultsCurrencyFormatKey];
	}
	else
	{
		[defaults setObject:format forKey:MBDefaultsNumberFormatKey];
	}
	
	// set decimal and thousand separators
	[[negativeExampleTextField formatter] setDecimalSeparator:decSep];
	[[positiveExampleTextField formatter] setThousandSeparator:thSep];
	// set to example textfields
	[[negativeExampleTextField formatter] setFormat:format];
	[[positiveExampleTextField formatter] setFormat:format];
	// set values to example textfields
	[positiveExampleTextField setObjectValue:[NSNumber numberWithInt:123456]];
	[negativeExampleTextField setObjectValue:[NSNumber numberWithInt:-123456]];
	
	return format;
}

- (IBAction)numberOfDecimalsChange:(id)sender
{
	CocoLog(LEVEL_DEBUG,@"numberOfDecimalsChanged...");
	
	// set default values
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if(currentType == NumberFormatType)
	{
		[defaults setInteger:[sender intValue] forKey:MBDefaultsNumberFormatNumberOfDecimalDigitsKey];
	}
	else
	{
		[defaults setInteger:[sender intValue] forKey:MBDefaultsCurrencyFormatNumberOfDecimalDigitsKey];
	}
	// set textfield
	[numberOfDigitsTextField setIntValue:[sender intValue]];
	
	// create new format string
	[self createAndSetFormatStringForType:currentType];
}

- (IBAction)switchDecimalsDigits:(id)sender
{
	CocoLog(LEVEL_DEBUG,@"switchDecimalsDigits...");
	
	// set default values
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if(currentType == NumberFormatType)
	{
		[defaults setBool:(BOOL)[sender state] forKey:MBDefaultsNumberFormatUseDecimalDigitsKey];
	}
	else
	{
		[defaults setBool:(BOOL)[sender state] forKey:MBDefaultsCurrencyFormatUseDecimalDigitsKey];
	}
	
	// create new format string
	[self createAndSetFormatStringForType:currentType];
}

- (IBAction)switchThoudsandSeparator:(id)sender
{
	CocoLog(LEVEL_DEBUG,@"switchThoudsandSeparator...");
	
	// set default values
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if(currentType == NumberFormatType)
	{
		[defaults setBool:(BOOL)[sender state] forKey:MBDefaultsNumberFormatUseThousandSeparatorKey];
	}
	else
	{
		[defaults setBool:(BOOL)[sender state] forKey:MBDefaultsCurrencyFormatUseThousandSeparatorKey];
	}
	
	// create new format string
	[self createAndSetFormatStringForType:currentType];
}

- (IBAction)switchUseRedColorForNegatives:(id)sender
{
	CocoLog(LEVEL_DEBUG,@"switchUseRedColorForNegatives...");
	
	// set default values
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if(currentType == NumberFormatType)
	{
		[defaults setBool:(BOOL)[sender state] forKey:MBDefaultsNumberFormatUseRedNegativesKey];
	}
	else
	{
		[defaults setBool:(BOOL)[sender state] forKey:MBDefaultsCurrencyFormatUseRedNegativesKey];
	}
	
	// create new format string
	[self createAndSetFormatStringForType:currentType];
}

- (IBAction)currencySymbolInput:(id)sender
{
	CocoLog(LEVEL_DEBUG,@"currencySymbolInput...");
	
	// set default values
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if(currentType == CurrencyFormatType)
	{
		[defaults setObject:[sender stringValue] forKey:MBDefaultsCurrencyFormatCurrencySymbolKey];
	}
	
	// create new format string
	[self createAndSetFormatStringForType:currentType];
}

- (IBAction)switchNumberType:(id)sender
{
	CocoLog(LEVEL_DEBUG,@"number type switch");
	[self setValuesForType:NumberFormatType];
}

- (IBAction)switchCurrencyType:(id)sender
{
	CocoLog(LEVEL_DEBUG,@"currency type switch");
	[self setValuesForType:CurrencyFormatType];
}

@end
