//
//  MBGeneralPrefsViewController.m
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

#import <CocoLogger/CocoLogger.h>
#import "MBGeneralPrefsViewController.h"


@implementation MBGeneralPrefsViewController

- (id)init
{
	CocoLog(LEVEL_DEBUG, @"init of MBGeneralPrefsViewController");
	
	self = [super init];
	if(self == nil)
	{
		CocoLog(LEVEL_ERR, @"cannot alloc MBGeneralPrefsViewController!");
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
	CocoLog(LEVEL_DEBUG, @"dealloc of MBGeneralPrefsViewController");
	
	// dealloc object
	[super dealloc];
}

//--------------------------------------------------------------------
//----------- bundle delegates ---------------------------------------
//--------------------------------------------------------------------
- (void)awakeFromNib
{
	CocoLog(LEVEL_DEBUG, @"awakeFromNib of MBGeneralPrefsViewController");
	
	if(self != nil)
	{
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		// set display settings
		[useMetalLookButton setState:[defaults integerForKey:MBDefaultsMetalDisplayKey]];
		
		// set number of undos
		int undoSteps = [defaults integerForKey:MBDefaultsUndoStepsKey];
		if(undoSteps == -1)
		{
			[undoStepUnlimitedButton setState:1];
			[undoStepTextField setEnabled:NO];
			[undoStepTextField setObjectValue:[NSNumber numberWithInt:10]];
			[undoStepStepper setEnabled:NO];
		}
		else
		{
			[undoStepUnlimitedButton setState:0];
			[undoStepTextField setObjectValue:[NSNumber numberWithInt:undoSteps]];
			[undoStepStepper setIntValue:undoSteps];
			[undoStepTextField setEnabled:YES];
			[undoStepStepper setEnabled:YES];
		}
		
		// init the viewRect
		viewFrame = [theView frame];
	}
}

/**
 \brief return the view itself
*/
- (NSView *)theView
{
	return theView;
}

- (NSRect)viewFrame
{
	return viewFrame;
}

- (IBAction)switchMetalLook:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	// set state of button
	[defaults setInteger:[sender state] forKey:MBDefaultsMetalDisplayKey];

	// send notification that display mode has changed
	//MBSendNotifySwitchToMetalLookAndFeel([NSNumber numberWithInt:[sender state]]);
}

- (void)setUndoStepChange:(int)undoSteps
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	if(undoSteps == 0)
	{
		// deactivate all controlls
		[undoStepStepper setEnabled:NO];
		[undoStepTextField setEnabled:NO];
	}
	else
	{
		// activate all controlls
		[undoStepStepper setEnabled:YES];
		[undoStepTextField setEnabled:YES];
		// display in textfield
		[undoStepTextField setObjectValue:[NSNumber numberWithInt:undoSteps]];
		// set state of stepper
		[undoStepStepper setIntValue:undoSteps];
	}
	
	// set in defaults
	[defaults setInteger:undoSteps forKey:MBDefaultsUndoStepsKey];

	// send notification to set the changes at once
	//MBSendNotifyChangedUndoSteps([NSNumber numberWithInt:undoSteps]);
}

- (IBAction)undoStepStepperChange:(id)sender
{
	[self setUndoStepChange:[sender intValue]];
}

- (IBAction)undoStepInput:(id)sender
{
	[self setUndoStepChange:[sender intValue]];
}

- (IBAction)undoStepUnlimitedSwitch:(id)sender
{
	if([sender state] == 1)
	{
		[self setUndoStepChange:0];
	}
	else
	{
		[self setUndoStepChange:1];
	}
}

@end
