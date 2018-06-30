//
//  MBDateValueDetailViewController.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 08.07.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <CocoLogger/CocoLogger.h>
#import "MBDateValueDetailViewController.h"
#import "MBCommonItem.h"
#import "MBFormatPrefsViewController.h"
#import "globals.h"
#import "MBDateItemValue.h"
#import "MBDatePickerController.h"

#define FROMDATE	0
#define TODATE		1

@implementation MBDateValueDetailViewController

- (id)init {
	CocoLog(LEVEL_DEBUG,@"init of MBDateValueDetailViewController");
	
	self = [super init];
	if(self) {
	}
	
	return self;
}

/**
\brief dealloc of this class is called on closing this document
 */
- (void)dealloc {
	// dealloc object
	[super dealloc];
}

//--------------------------------------------------------------------
//----------- Bundle delegates ---------------------------------------
//--------------------------------------------------------------------
/**
\brief gets called ig the nib file has been loaded. all gfx objacts are available now.
 */
- (void)awakeFromNib {
}

/**
\brief set the element of which information should be shown
 no retains is made.
 */
- (void)displayInfo {
	MBDateItemValue *itemval = (MBDateItemValue *)currentItemValue;
	
	if(itemval != nil) {
		// if this itemval encrypted?
		if([itemval encryptionState] != EncryptedState) {
			// is range?
			BOOL isRange = [itemval isDateRange];
			// has alarm?
			BOOL hasAlarm = [itemval hasAlarm];
			
			// activate all buttons first
			[dateFromTextField setEnabled:YES];
			[useGlobalFormatButton setEnabled:YES];
			[setFormatButton setEnabled:YES];
			[setFromDateButton setEnabled:YES];

			// range stuff
			[isRangeButton setState:(int)isRange];
			[dateToTextField setEnabled:isRange];
			[setToDateButton setEnabled:isRange];
			
			// alarm stuff
			[alarmActiveButton setState:(int)hasAlarm];
			[alarmRefDatePopUpButton setEnabled:(isRange && hasAlarm)];
			[alarmRepeatPopUpButton setEnabled:hasAlarm];
			[alarmSetPopUpButton setEnabled:hasAlarm];
			[alarmSetTextField setEnabled:hasAlarm];
			
			// set dateformat
			NSDateFormatter *dateFormatter = nil;
			if([itemval useGlobalFormat] == NO) {
				// make os 10.3 compatible
				dateFormatter = [[NSDateFormatter alloc] initWithDateFormat:[itemval formatterString] 
																		allowNaturalLanguage:YES];
				// set new formatter
				[dateFromTextField setFormatter:dateFormatter];
				[dateFormatter release];
			} else {
				NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
				// make os 10.3 compatible
				dateFormatter = [[NSDateFormatter alloc] initWithDateFormat:[defaults objectForKey:MBDefaultsDateFormatKey] 
																		allowNaturalLanguage:(int)[defaults integerForKey:MBDefaultsDateFormatAllowNaturalLanguageKey]];
				// set new formatter
				[dateFromTextField setFormatter:dateFormatter];
				[dateFormatter release];
			}

			// format
			BOOL globalFormat = [itemval useGlobalFormat];
			[useGlobalFormatButton setState:(int)globalFormat];
			if(globalFormat == YES) {
				[setFormatButton setEnabled:NO];
			} else {
				[setFormatButton setEnabled:YES];
			}
			
			// show from date
			[dateFromTextField setObjectValue:[itemval fromDate]];
			
			// is this date a range?
			if([itemval isDateRange]) {
				// set date formatter, take the one from above
				[dateToTextField setFormatter:dateFormatter];
				// show to date
				[dateToTextField setObjectValue:[itemval toDate]];
			} else {
				// set empty string to textfield
				[dateToTextField setStringValue:@""];
			}
			
			// has alarm?
			if(hasAlarm) {
				[alarmRefDatePopUpButton selectItemAtIndex:[alarmRefDatePopUpButton indexOfItemWithTag:[itemval alarmRefType]]];
				[alarmSetPopUpButton selectItemAtIndex:[alarmSetPopUpButton indexOfItemWithTag:[itemval alarmOffsetType]]];
				[alarmSetTextField setObjectValue:[NSNumber numberWithInt:[itemval alarmOffsetValue]]];
				[alarmRepeatPopUpButton selectItemAtIndex:[alarmRepeatPopUpButton indexOfItemWithTag:[itemval alarmRepeatType]]];
				// set formatter for next alarm
				[alarmNextDateLabel setFormatter:dateFormatter];
				[alarmNextDateLabel setObjectValue:[itemval alarmDate]];
			} else {
				[alarmRefDatePopUpButton selectItemAtIndex:0];
				[alarmSetPopUpButton selectItemAtIndex:0];
				[alarmSetTextField setObjectValue:[NSNumber numberWithInt:0]];
				[alarmRepeatPopUpButton selectItemAtIndex:0];
				[alarmNextDateLabel setStringValue:@""];
			}
		} else {
			// deactivate buttons, textfields and write Encrypted in textfield
			[dateFromTextField setEnabled:NO];
			[dateToTextField setEnabled:NO];
			[useGlobalFormatButton setEnabled:NO];
			[setFormatButton setEnabled:NO];
			[setFromDateButton setEnabled:NO];
			[setToDateButton setEnabled:NO];
			[dateFromTextField setStringValue:MBLocaleStr(@"Encrypted")];
			[dateToTextField setStringValue:MBLocaleStr(@"Encrypted")];
		}
	} else {
		[dateToTextField setStringValue:@""];
		[dateFromTextField setStringValue:@""];
	}
}

//--------------------------------------------------------------------
//----------- actions ---------------------------------------
//--------------------------------------------------------------------
- (IBAction)acc_ToDateInput:(id)sender {
	// set new name for itemValue
	if(currentItemValue != nil) {
		[(MBDateItemValue *)currentItemValue setToDate:[sender objectValue]];
	}
}

- (IBAction)acc_FromDateInput:(id)sender {
	// set new name for itemValue
	if(currentItemValue != nil) {
		[(MBDateItemValue *)currentItemValue setFromDate:[sender objectValue]];
	}		
}

/**
\brief switch using format
 */
- (IBAction)acc_UseGlobalFormatSwitch:(id)sender {
	if(currentItemValue != nil) {
		MBDateItemValue *itemval = (MBDateItemValue *)currentItemValue;
		[itemval setUseGlobalFormat:[(NSButton *)sender state]];
	}	
}

- (IBAction)acc_SetDate:(id)sender {
	// get tag
	int tag = [sender tag];
	
	NSDate *date = nil;
	if(tag == FROMDATE) {
		date = [(MBDateItemValue *)currentItemValue fromDate];
	} else {
		date = [(MBDateItemValue *)currentItemValue toDate];
	}
	
	// get DatePicker controller and let user choose date
	MBDatePickerController *dpc = [MBDatePickerController sharedDatePickerController];
	[dpc setCurrentDate:date];
	[dpc showWindow:self];
	
	// run modal for this window
	[NSApp runModalForWindow:[dpc window]];
	
	// wait for closing the window, then check dialogResult
	if([dpc dialogResult] == 0) {
		if(tag == FROMDATE) {
			// take the choosen date
			[(MBDateItemValue *)currentItemValue setFromDate:[dpc currentDate]];
		} else {
			// take the choosen date
			[(MBDateItemValue *)currentItemValue setToDate:[dpc currentDate]];		
		}
		// display
		[self displayInfo];
	}
}

- (IBAction)acc_SetFormat:(id)sender {
	// TODO
}

- (IBAction)acc_IsRangeSwitch:(id)sender {
	[(MBDateItemValue *)currentItemValue setIsDateRange:(BOOL)[(NSButton *)sender state]];
}

- (IBAction)acc_AlarmActiveSwitch:(id)sender {
	[(MBDateItemValue *)currentItemValue setHasAlarm:(BOOL)[(NSButton *)sender state]];
}

- (IBAction)acc_AlarmRefDateChange:(id)sender {
	[(MBDateItemValue *)currentItemValue setAlarmRefType:[sender tag]];
}

- (IBAction)acc_AlarmRepeatChange:(id)sender {
	[(MBDateItemValue *)currentItemValue setAlarmRepeatType:[sender tag]];
}

// offset
- (IBAction)acc_AlarmSetChange:(id)sender {
	[(MBDateItemValue *)currentItemValue setAlarmOffsetType:[sender tag]];
}

// offset
- (IBAction)acc_AlarmSetInput:(id)sender {
	NSNumber *val = [sender objectValue];	
	[(MBDateItemValue *)currentItemValue setAlarmOffsetValue:[val intValue]];
}

@end
