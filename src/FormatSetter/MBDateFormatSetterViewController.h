/* MBDateFormatSetterViewController */

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>

@interface MBDateFormatSetterViewController : NSObject
{
    IBOutlet NSButton *allowNaturalLanguageButton;
    IBOutlet NSTextField *exampleTextField;
    IBOutlet NSTableView *formatTableView;
    IBOutlet NSTextField *formatTextField;
	IBOutlet NSTextView *explanationTextView;
	
	IBOutlet NSView *theView;
	
	NSString *dateFormatString;
	NSArray *dateFormats;
	BOOL allowNatLanguage;
	NSDate *displayDate;
	
	id delegate;
}

- (void)setDelegate:(id)aDelegate;
- (id)delegate;

- (NSView *)theView;

+ (NSArray *)availableDateFormats;
- (void)setDateFormats:(NSArray *)formats;
- (NSArray *)dateFormats;
- (void)setDateFormatString:(NSString *)formatString;
- (NSString *)dateFormatString;
- (void)setAllowNatLanguage:(BOOL)flag;
- (BOOL)allowNatLanguage;
- (void)setDisplayDate:(NSDate *)date;
- (NSDate *)displayDate;

- (IBAction)allowNaturalLanguageSwitch:(id)sender;
- (IBAction)formatInput:(id)sender;

@end
