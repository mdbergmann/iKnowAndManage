//
//  MBDateValueDetailViewController.h
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

#import <Cocoa/Cocoa.h>
#import "MBBaseDetailViewController.h"

@class MBDateItemValue;

@interface MBDateValueDetailViewController : MBBaseDetailViewController {
	IBOutlet NSTextField *dateFromTextField;
	IBOutlet NSTextField *dateToTextField;
	IBOutlet NSButton *useGlobalFormatButton;
	IBOutlet NSButton *setFormatButton;
	IBOutlet NSButton *setFromDateButton;
	IBOutlet NSButton *setToDateButton;
	IBOutlet NSButton *isRangeButton;
    IBOutlet NSButton *alarmActiveButton;
    IBOutlet NSPopUpButton *alarmRefDatePopUpButton;
    IBOutlet NSPopUpButton *alarmRepeatPopUpButton;
    IBOutlet NSPopUpButton *alarmSetPopUpButton;
    IBOutlet NSTextField *alarmSetTextField;
	IBOutlet NSTextField *alarmNextDateLabel;
}

// actions
- (IBAction)acc_ToDateInput:(id)sender;
- (IBAction)acc_FromDateInput:(id)sender;
- (IBAction)acc_UseGlobalFormatSwitch:(id)sender;
- (IBAction)acc_SetFormat:(id)sender;
- (IBAction)acc_SetDate:(id)sender;
- (IBAction)acc_IsRangeSwitch:(id)sender;
- (IBAction)acc_AlarmActiveSwitch:(id)sender;
- (IBAction)acc_AlarmRefDateChange:(id)sender;
- (IBAction)acc_AlarmRepeatChange:(id)sender;
- (IBAction)acc_AlarmSetChange:(id)sender;
- (IBAction)acc_AlarmSetInput:(id)sender;

@end
