//
//  MBFormatPrefsViewController.h
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 15.09.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>

@class MBFormatSetterController;

// currency
#define MBDefaultsCurrencyFormatKey							@"MBDefaultsCurrencyFormatKey"
#define MBDefaultsCurrencyFormatUseThousandSeparatorKey		@"MBDefaultsCurrencyFormatUseThousandSeparatorKey"
#define MBDefaultsCurrencyFormatUseDecimalDigitsKey			@"MBDefaultsCurrencyFormatUseDecimalDigitsKey"
#define MBDefaultsCurrencyFormatNumberOfDecimalDigitsKey	@"MBDefaultsCurrencyFormatNumberOfDecimalDigitsKey"
#define MBDefaultsCurrencyFormatUseRedNegativesKey			@"MBDefaultsCurrencyFormatUseRedNegativesKey"
#define MBDefaultsCurrencyFormatCurrencySymbolKey			@"MBDefaultsCurrencyFormatCurrencySymbolKey"
// number
#define MBDefaultsNumberFormatKey							@"MBDefaultsNumberFormatKey"
#define MBDefaultsNumberFormatUseThousandSeparatorKey		@"MBDefaultsNumberFormatUseThousandSeparatorKey"
#define MBDefaultsNumberFormatUseDecimalDigitsKey			@"MBDefaultsNumberFormatUseDecimalDigitsKey"
#define MBDefaultsNumberFormatNumberOfDecimalDigitsKey		@"MBDefaultsNumberFormatNumberOfDecimalDigitsKey"
#define MBDefaultsNumberFormatUseRedNegativesKey			@"MBDefaultsNumberFormatUseRedNegativesKey"
// date
#define MBDefaultsDateFormatKey								@"MBDefaultsDateFormatKey"
#define MBDefaultsDateFormatAllowNaturalLanguageKey			@"MBDefaultsDateFormatAllowNaturalLanguageKey"

@interface MBFormatPrefsViewController : NSObject 
{
	// boxes
	IBOutlet NSTabView *tabView;
	// the view
	IBOutlet NSView *theView;

	// FormatSetterController
	MBFormatSetterController *formatSetterController;
	
	// initial rect
	NSRect viewFrame;
}

- (NSView *)theView;
- (NSRect)viewFrame;

// MBDateFormatSetterViewController delegates
- (void)formatStringSettingOfDateSetterControllerChanged:(id)sender;
- (void)allowNatLanguageSettingOfDateSetterControllerChanged:(id)sender;

@end
