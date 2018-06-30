/* MBAlarmController */

//  Created by Manfred Bergmann on 25.07.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>

@class MBDateItemValue;

@interface MBAlarmController : NSObject
{
    IBOutlet NSTableView *alarmsTableView;
    IBOutlet NSWindow *alarmWindow;
    IBOutlet NSButton *dismissButton;
    IBOutlet NSButton *showButton;
    IBOutlet NSButton *snoozeButton;
	
	// alarms
	NSArray *alarms;
	MBDateItemValue *selectedValue;
}

// singleton
+ (MBAlarmController *)defaultController;

// show window
- (void)show;

// actions
- (IBAction)dismissButton:(id)sender;
- (IBAction)showButton:(id)sender;
- (IBAction)snoozeButton:(id)sender;

@end
