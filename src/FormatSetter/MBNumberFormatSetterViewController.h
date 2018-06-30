/* MBNumberFormatSetterViewController */

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>

enum MBFormatSetterNumberType
{
	NumberFormatType = 0,
	CurrencyFormatType
};

@interface MBNumberFormatSetterViewController : NSObject
{
    IBOutlet NSTextField *negativeExampleTextField;
    IBOutlet NSStepper *numberOfDigitsStepper;
    IBOutlet NSTextField *numberOfDigitsTextField;
    IBOutlet NSTextField *positiveExampleTextField;
    IBOutlet NSButton *useDecimalDigitsButton;
    IBOutlet NSButton *useRedColorOnNegativesButton;
    IBOutlet NSButton *useThousandSeparatorButton;
	IBOutlet NSTextField *currencySymbolTextField;
	IBOutlet NSTextField *currencySymbolLabel;
	IBOutlet NSButtonCell *numberRadioButtonCell;
	IBOutlet NSButtonCell *currencyRadioButtonCell;
	
	IBOutlet NSView *theView;

	int currentType;
}

- (NSView *)theView;

- (void)setValuesForType:(int)aType;
- (NSString *)createAndSetFormatStringForType:(int)aType;

- (IBAction)numberOfDecimalsChange:(id)sender;
- (IBAction)switchDecimalsDigits:(id)sender;
- (IBAction)switchThoudsandSeparator:(id)sender;
- (IBAction)switchUseRedColorForNegatives:(id)sender;
- (IBAction)currencySymbolInput:(id)sender;
- (IBAction)switchNumberType:(id)sender;
- (IBAction)switchCurrencyType:(id)sender;

@end
