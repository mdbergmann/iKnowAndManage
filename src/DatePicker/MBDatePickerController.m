#import "MBDatePickerController.h"

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

@interface MBDatePickerController (privateAPI)

- (void)updateControllsWithDate:(NSDate *)aDate;

@end

@implementation MBDatePickerController (privateAPI)

- (void)updateControllsWithDate:(NSDate *)aDate
{
	// if we are starting with tiger, create a NSDatePicker
    if((floor(NSAppKitVersionNumber)) > NSAppKitVersionNumber10_3_5)
    {
        // tiger
        [(NSDatePicker *)nsDatePickerView setDateValue:aDate];
    }
    else
    {
        // set textfields
        [yearTextField setObjectValue:aDate];
        [monthTextField setObjectValue:aDate];
        [dayTextField setObjectValue:aDate];
        [timeTextField setObjectValue:aDate];

        // set stepper values
        NSCalendarDate *calDate = [aDate dateWithCalendarFormat:nil timeZone:nil];
        [yearStepper setIntValue:[calDate yearOfCommonEra]];
        [monthStepper setIntValue:[calDate monthOfYear]];
        [dayStepper setIntValue:[calDate dayOfMonth]];	
    }
}

@end

@implementation MBDatePickerController

+ (MBDatePickerController *) sharedDatePickerController;
{
	static MBDatePickerController *singleton;
	
	if(singleton == nil)
	{
		singleton = [[MBDatePickerController alloc] init];
	}
	
	return singleton;
}

/**
\brief init is called after alloc:. some initialization work can be done here.
 No GUI elements are available here. It additinally calls the init method of superclass
 @returns initialized not nil object
 */
- (id)init
{
	CocoLog(LEVEL_DEBUG,@"init of MBDatePickerController");
	
	self = [super initWithWindowNibName:DATEPICKER_CONTROLLER_NIB_NAME];
	if(self == nil)
	{
		CocoLog(LEVEL_ERR,@"cannot alloc MBDatePickerController!");		
	}
	else
	{
		// set initial current date
		[self setCurrentDate:[NSDate date]];
	}
	
	return self;
}

/**
\brief dealloc of this class is called on closing this document
 */
- (void)dealloc
{
	CocoLog(LEVEL_DEBUG,@"dealloc of MBDatePickerController");

	// nil current Date
	[self setCurrentDate:nil];
	
	// dealloc object
	[super dealloc];
}

- (int)dialogResult
{
	return dialogResult;
}

- (void)setCurrentDate:(NSDate *)date
{
	[date retain];
	[currentDate release];
	currentDate = date;
	
	if(date != nil)
	{
		// update controlls
		[self updateControllsWithDate:date];
	}
}

- (NSDate *)currentDate
{
	return currentDate;
}

//--------------------------------------------------------------------
//----------- bundle delegates ---------------------------------------
//--------------------------------------------------------------------
- (void)windowDidLoad
{
	CocoLog(LEVEL_DEBUG,@"windowDidLoad of MBDatePickerController");
	
	if(self != nil)
	{
		// set either our own DatePicker View or the NSDatePicker View		
        nsDatePickerView = [[NSDatePicker alloc] init];
        [(NSDatePicker *)nsDatePickerView setDatePickerStyle:NSClockAndCalendarDatePickerStyle];
        [(NSDatePicker *)nsDatePickerView setDatePickerElements:(NSHourMinuteDatePickerElementFlag |
                                                 NSYearMonthDayDatePickerElementFlag)];
        
        // set date
        [nsDatePickerView setDateValue:currentDate];
        // set delegate
        [nsDatePickerView setDelegate:self];
        
        // set view as box contentView
        [datePickerViewBox setContentView:nsDatePickerView];
	}
}

//--------------------------------------------------------------------
//----------- NSDatePicker delegate ----------------------------------
//--------------------------------------------------------------------
- (void)datePickerCell:(NSDatePickerCell *)aDatePickerCell 
validateProposedDateValue:(NSDate **)proposedDateValue 
		  timeInterval:(NSTimeInterval *)proposedTimeInterval
{
	CocoLog(LEVEL_DEBUG,@"[MBDatePickerController -datePickerCell:aDatePickerCell:validateProposedDateValue:timeInterval:]");
	
	// set currentDate
	NSDate *date = [NSDate dateWithString:[*proposedDateValue description]];
	[date addTimeInterval:*proposedTimeInterval];
	[date retain];
	[currentDate release];
	currentDate = date;
}

//--------------------------------------------------------------------
//----------- Actions ---------------------------------------
//--------------------------------------------------------------------
- (IBAction)okButton:(id)sender
{
	dialogResult = 0;
	[self close];
	
	// stop modality
	[NSApp stopModal];
}

- (IBAction)cancelButton:(id)sender
{
	dialogResult = -1;
	[self close];

	// stop modality
	[NSApp stopModal];
}

- (IBAction)todayButton:(id)sender
{
	// get current date and set it
	[self setCurrentDate:[NSDate date]];
}

- (IBAction)acc_TimeInput:(id)sender
{
	// get new time
	NSDate *time = [sender objectValue];
	NSCalendarDate *calDate = [time dateWithCalendarFormat:nil timeZone:nil];
	// get time of calendar date
	int hours = [calDate hourOfDay];
	int minutes = [calDate minuteOfHour];
	
	// generate new date
	NSCalendarDate *newCal = [NSCalendarDate dateWithYear:[[yearTextField stringValue] intValue] 
													month:[[monthTextField stringValue] intValue] 
													  day:[[dayTextField stringValue] intValue] 
													 hour:hours 
												   minute:minutes
												   second:0 
												 timeZone:nil];
	// create NSDate out of calendar date
	NSDate *newDate = [NSDate dateWithString:[newCal description]];
	
	// set new calculated date
	[self setCurrentDate:newDate];
}

- (IBAction)acc_YearInput:(id)sender
{
	// get new time
	NSDate *time = [sender objectValue];
	NSCalendarDate *calDate = [time dateWithCalendarFormat:nil timeZone:nil];
	// get time of calendar date
	int hours = [calDate hourOfDay];
	int minutes = [calDate minuteOfHour];
	
	// generate new date
	NSCalendarDate *newCal = [NSCalendarDate dateWithYear:[[yearTextField stringValue] intValue]
													month:[[monthTextField stringValue] intValue] 
													  day:[[dayTextField stringValue] intValue] 
													 hour:hours 
												   minute:minutes
												   second:0 
												 timeZone:nil];
	// create NSDate out of calendar date
	NSDate *newDate = [NSDate dateWithString:[newCal description]];
	
	// set new calculated date
	[self setCurrentDate:newDate];
}

- (IBAction)acc_YearStepperChange:(id)sender
{
	// set stepper to textfield
	int val = [sender intValue];
	
	[yearTextField setStringValue:[[NSNumber numberWithInt:val] stringValue]];
	
	// call accessor to translate to date
	[self acc_YearInput:yearTextField];
}

- (IBAction)acc_MonthInput:(id)sender
{
	// get new time
	NSDate *time = [sender objectValue];
	NSCalendarDate *calDate = [time dateWithCalendarFormat:nil timeZone:nil];
	// get time of calendar date
	int hours = [calDate hourOfDay];
	int minutes = [calDate minuteOfHour];
	
	// generate new date
	NSCalendarDate *newCal = [NSCalendarDate dateWithYear:[[yearTextField stringValue] intValue]
													month:[[monthTextField stringValue] intValue] 
													  day:[[dayTextField stringValue] intValue] 
													 hour:hours 
												   minute:minutes
												   second:0 
												 timeZone:nil];
	// create NSDate out of calendar date
	NSDate *newDate = [NSDate dateWithString:[newCal description]];
	
	// set new calculated date
	[self setCurrentDate:newDate];
}

- (IBAction)acc_MonthStepperChange:(id)sender
{
	// set stepper to textfield
	int val = [sender intValue];
	
	[monthTextField setStringValue:[[NSNumber numberWithInt:val] stringValue]];
	
	// call accessor to translate to date
	[self acc_MonthInput:yearTextField];	
}

- (IBAction)acc_DayInput:(id)sender
{
	// get new time
	NSDate *time = [sender objectValue];
	NSCalendarDate *calDate = [time dateWithCalendarFormat:nil timeZone:nil];
	// get time of calendar date
	int hours = [calDate hourOfDay];
	int minutes = [calDate minuteOfHour];
	
	// generate new date
	NSCalendarDate *newCal = [NSCalendarDate dateWithYear:[[yearTextField stringValue] intValue]
													month:[[monthTextField stringValue] intValue] 
													  day:[[dayTextField stringValue] intValue] 
													 hour:hours 
												   minute:minutes
												   second:0 
												 timeZone:nil];
	// create NSDate out of calendar date
	NSDate *newDate = [NSDate dateWithString:[newCal description]];
	
	// set new calculated date
	[self setCurrentDate:newDate];
}

- (IBAction)acc_DayStepperChange:(id)sender
{
	// set stepper to textfield
	int val = [sender intValue];
	
	[dayTextField setStringValue:[[NSNumber numberWithInt:val] stringValue]];
	
	// call accessor to translate to date
	[self acc_DayInput:yearTextField];	
}

@end
