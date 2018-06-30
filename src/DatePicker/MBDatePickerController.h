/* MBDatePickerController */

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import <globals.h>
 
#define DATEPICKER_CONTROLLER_NIB_NAME @"DatePicker"

@interface MBDatePickerController : NSWindowController
{
	// global stuff
    IBOutlet NSButton *cancelButton;
	IBOutlet NSButton *okButton;
	IBOutlet NSButton *todayButton;
	
	IBOutlet NSBox *datePickerViewBox;
	IBOutlet NSView *mbDatePickerView;
	NSDatePicker *nsDatePickerView;
    
	// stuff for our own datepicker (pre Tiger)
	IBOutlet NSTextField *yearTextField;
	IBOutlet NSStepper *yearStepper;
	IBOutlet NSTextField *monthTextField;
	IBOutlet NSStepper *monthStepper;
	IBOutlet NSTextField *dayTextField;
	IBOutlet NSStepper *dayStepper;
	IBOutlet NSTextField *timeTextField;	
	
	int dialogResult;
	
	NSDate *currentDate;
}

+ (MBDatePickerController *) sharedDatePickerController;

- (int)dialogResult;
- (void)setCurrentDate:(NSDate *)date;
- (NSDate *)currentDate;

// actions
- (IBAction)cancelButton:(id)sender;
- (IBAction)okButton:(id)sender;
- (IBAction)todayButton:(id)sender;
- (IBAction)acc_TimeInput:(id)sender;
- (IBAction)acc_YearInput:(id)sender;
- (IBAction)acc_YearStepperChange:(id)sender;
- (IBAction)acc_MonthInput:(id)sender;
- (IBAction)acc_MonthStepperChange:(id)sender;
- (IBAction)acc_DayInput:(id)sender;
- (IBAction)acc_DayStepperChange:(id)sender;

@end
