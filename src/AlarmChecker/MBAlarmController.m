//  Created by Manfred Bergmann on 25.07.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$
 
#import "MBAlarmController.h"
#import "MBItemBaseController.h"
#import "MBDateItemValue.h"
#import "globals.h"

#define COL_IDENTIFIER_ALARM_NAME		@"name"
#define COL_IDENTIFIER_ALARM_DATE		@"date"

@interface MBAlarmController (privateAPI)

- (void)timeElapsed;
- (void)updateData;

- (void)setAlarms:(NSArray *)alarmList;
- (NSArray *)alarms;

- (void)setSelectedValue:(MBDateItemValue *)aValue;
- (MBDateItemValue *)selectedValue;

@end

@implementation MBAlarmController (privateAPI)



/**
 \brief update data and reload tableview
*/
- (void)updateData {
	// deselect all
	[alarmsTableView deselectAll:nil];
	
	// remove selectedValue from array
	NSMutableArray *newArray = [NSMutableArray arrayWithArray:alarms];
	[newArray removeObject:selectedValue];
	[self setSelectedValue:nil];
	
	// set new alarms array
	[self setAlarms:newArray];
	// refresh
	[alarmsTableView reloadData];
	
	// if there are still any alarms in array, do not close window
	if([newArray count] == 0) {
		[alarmWindow close];
	}	
}

/**
 \brief every minute/60 seconds, check for alarms that are due
*/
- (void)timeElapsed {
	// get the list of available dates from itembaseController
	NSArray *dateList = [itemController listForIdentifier:DateItemValueID];
	
	// get AppInfoItem for checking the last stop date
	//MBAppInfoItem *appInfo = [itemController appInfoItem];
	//NSDate *lastStopDate = [appInfo dateLastStop];
	NSDate *now = [NSDate date];
	
	// create list of all alarms
	NSMutableArray *newAlarms = [NSMutableArray array];
	NSEnumerator *iter = [dateList objectEnumerator];
	MBDateItemValue *itemval = nil;
	while((itemval = [iter nextObject])) {
		// only alarms
		if([itemval hasAlarm]) {
			NSDate *alarmDate = [itemval alarmDate];
			BOOL isProcessed = [itemval alarmProcessed];
			
			// check for matching dates
			int diff = (int)[alarmDate timeIntervalSinceDate:now];
			// we only need minutes
			diff = diff / 60;
			
			// also show all unprocessed alarm in the past and now
			//int lastStopMin = ((int)[lastStopDate timeIntervalSince1970] / 60);
			int nowMin = ((int)[now timeIntervalSince1970] / 60);
			int alarmMin = ((int)[alarmDate timeIntervalSince1970] / 60);
			
			// to the minute
			//if((diff == 0) && (!isProcessed))
			//{
				// we found one
			//	[newAlarms addObject:itemval];
			//}
				
			// the alarms has to be unprocessed and the alarm date has to be in the past
			if((nowMin >= alarmMin) && (!isProcessed))
			{
				// we found one
				[newAlarms addObject:itemval];		
			}
		}
	}
	
	// first deselect all entries
	[alarmsTableView deselectAll:nil];
	
	// set new array
	[self setAlarms:newAlarms];
	// reload tableview
	[alarmsTableView reloadData];
	
	// if we have more than one alarm, show window
	int len = [newAlarms count];
	if(len > 0) {
		NSString *reminderDescr = nil;
		if(len > 1) {
			reminderDescr = [NSString stringWithFormat:MBLocaleStr(@"AlarmGrowlDescriptionMore"), len];
		} else {
			reminderDescr = MBLocaleStr(@"AlarmGrowlDescriptionOne");
		}
        
		// growl notifications about alarms
        /*
		[growler notifyWithTitle:MBLocaleStr(@"AlarmGrowlTitle") 
					 description:reminderDescr
				notificationName:ALARM_GROWL_KEY 
						iconData:nil 
						priority:0 
						isSticky:NO 
					clickContext:nil];
         */

		// bring the whole application in front
		//[NSApp activateIgnoringOtherApps:YES];
		// bring alarm window to front
		[self show];
		
		// notify user with a jumping dock icon
		[NSApp requestUserAttention:NSInformationalRequest];
	} else {
		// close
		[alarmWindow close];
	}
}

/**
 \brief setter for the alarm array
*/
- (void)setAlarms:(NSArray *)alarmList {
	if(alarmList != alarms) {
		[alarmList retain];
		[alarms release];
		alarms = alarmList;
	}
}

/**
 \brief getter for the alarm array
*/
- (NSArray *)alarms {
	return alarms;
}

/**
 \brief set selected value
*/
- (void)setSelectedValue:(MBDateItemValue *)aValue {
	if(aValue != selectedValue) {
		[aValue retain];
		[selectedValue release];
		selectedValue = aValue;
	}
	
	// if we have a nil value, deactivate all buttons
	if(selectedValue == nil) {
		[snoozeButton setEnabled:NO];
		[dismissButton setEnabled:NO];
		[showButton setEnabled:NO];
	} else {
		[snoozeButton setEnabled:YES];
		[dismissButton setEnabled:YES];
		[showButton setEnabled:YES];		
	}
}

/**
 \brief get the selected value
*/
- (MBDateItemValue *)selectedValue {
	return selectedValue;
}

@end

@implementation MBAlarmController

+ (MBAlarmController *)defaultController {
	static MBAlarmController *singleton;
	if(singleton == nil) {
		singleton = [[MBAlarmController alloc] init];
	}
	
	return singleton;	
}

- (id)init {
	CocoLog(LEVEL_DEBUG,@"init of MBAlarmController");
	
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"cannot alloc MBAlarmController!");		
	} else {
		BOOL success = [NSBundle loadNibNamed:@"AlarmChecker" owner:self];
		if(success == YES) {
			// init the alarms array
			[self setAlarms:[NSArray array]];
			// init the selected value with nil
			[self setSelectedValue:nil];
		} else {
			CocoLog(LEVEL_ERR,@"cannot load AlarmChecker.nib!");
		}		
	}
	
	return self;	
}

/**
\brief dealloc of this class is called on closing this document
 */
- (void)dealloc {
	CocoLog(LEVEL_DEBUG,@"dealloc of MBAlarmController");

	// release our alarms
	[self setAlarms:nil];	
	// release any selected value
	[self setSelectedValue:nil];
	
	// dealloc object
	[super dealloc];
}

//--------------------------------------------------------------------
//----------- bundle delegates ---------------------------------------
//--------------------------------------------------------------------
- (void)awakeFromNib {
	CocoLog(LEVEL_DEBUG,@"awakeFromNib of MBAlarmController");
	
	if(self != nil) {
		// disable all buttons
		[self setSelectedValue:nil];
		
		// if everything has been loaded successfully, we can start the timer.		
		// run every 60 seconds / 1 minute
		[NSTimer scheduledTimerWithTimeInterval:60.0 
										 target:self 
									   selector:@selector(timeElapsed) 
									   userInfo:nil 
										repeats:YES];
	}
}

/**
 \brief show the window with all alarms, even if there are none
*/
- (void)show {
    // disable all buttons
    [self setSelectedValue:nil];
	// show the window
	[alarmWindow makeKeyAndOrderFront:self];
}

//--------------------------------------------------------------------
//----------- NSTableView delegates ---------------------------------------
//--------------------------------------------------------------------
/**
\brief return the number of rows to be displayed in this tableview
 */
- (int)numberOfRowsInTableView:(NSTableView *)aTableView {
	return [[self alarms] count];
}

/**
\brief displayable object for tablecolumn and row
 */
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)row {
	MBDateItemValue *itemval = [[self alarms] objectAtIndex:row];
	
	if(itemval == nil) {
		CocoLog(LEVEL_ERR,@"have a nil object!");
	} else {
		// check tableColumn
		if([(NSString *)[aTableColumn identifier] isEqualToString:COL_IDENTIFIER_ALARM_NAME]) {
			// return name of item
			return [itemval name];
		} else if([(NSString *)[aTableColumn identifier] isEqualToString:COL_IDENTIFIER_ALARM_DATE]) {
			return [itemval valueDataAsString];
		}
	}
	
	return @"test";
}

/**
\brief no editings are allowed here
 */
- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(int)row {
	return NO;
}

/**
\brief all rows are allowed to select
 */
- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(int)row {
	return YES;
}

/**
\brief the tableview selection has changed
 If reference itemvalues are selected, they stay as is
 */
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
	// get the object
	NSTableView *tView = [aNotification object];
	MBDateItemValue *itemval = nil;
	if(tView != nil) {
		// get selected row
		int row = [tView selectedRow];
		// get approriate item
		itemval = [[self alarms] objectAtIndex:row];
	} else {
		CocoLog(LEVEL_WARN,@"tv_selectionDidChange: tableview is nil!");
	}
	
	// set choosen item or nil
	[self setSelectedValue:itemval];
}

/**
\brief alter cell display
 */
- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(int)row {
	// set Std Bold font for call
	NSFont *font = MBStdTableViewFont;
	[aCell setFont:font];
	// set row height according to used font
	// get font height
	double pointSize = [font pointSize];
	[aTableView setRowHeight:pointSize+5];
}

/**
\brief this is a method of the datasource for setting tooltips
 */
- (NSString *)tableView:(NSTableView *)aTableView toolTipForTableColumn:(NSTableColumn *)aTableColumn row:(int)row {
	NSString *tooltip = @"";	
	
	return tooltip;
}

//--------------------------------------------------------------------
//----------- actions ---------------------------------------
//--------------------------------------------------------------------
/**
 \brief on dissmiss, the alarm is disabled until is reoccurs e.g. if repeat is specified
*/
- (IBAction)dismissButton:(id)sender {
	// is repeat activated?
	if([selectedValue alarmRepeatType] == AlarmRepeatNone) {
		// just set alarm as processed and do not alter the alarm date
		[selectedValue setAlarmProcessed:YES];
	} else {
		// calculate the new alarm date and write to db
		NSDate *newAlarm = [selectedValue calculateAlarmDate];
		[selectedValue setAlarmDate:newAlarm];
	}

	// update
	[self updateData];
}

- (IBAction)showButton:(id)sender {
	// select item
	MBSendNotifyItemSelectionShouldChangeInOutlineView([NSArray arrayWithObject:[selectedValue item]]);
	
	// select itemvalue
	MBSendNotifyItemValueSelectionShouldChangeInTableView([NSArray arrayWithObject:selectedValue]);
}

- (IBAction)snoozeButton:(id)sender {
	// add 15 Minutes to now
	NSDate *alarmDate = [[NSDate date] addTimeInterval:(15.0 * 60.0)];
	
	// write new alarm date
	[selectedValue setAlarmDate:alarmDate];

	// update
	[self updateData];
}

@end
