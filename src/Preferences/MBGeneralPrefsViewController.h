//
//  MBGeneralPrefsViewController.h
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

// display
#define MBDefaultsMetalDisplayKey						@"MBDefaultsMetalDisplayKey"
#define MBDefaultsUsePanelInfoKey						@"MBDefaultsUsePanelInfoKey"
#define MBDefaultsShowInfoKey							@"MBDefaultsShowInfoKey"
// Undo steps
#define MBDefaultsUndoStepsKey							@"MBDefaultsUndoStepsKey"
// update check
#define MBDefaultsCheckUpdateEveryStartKey				@"MBDefaultsCheckUpdatesAutomaticallyKey"
// Memory
#define MBDefaultsMemoryFootprintKey					@"MBDefaultsMemoryFootprintKey"

@interface MBGeneralPrefsViewController : NSObject 
{
	// general stuff
	IBOutlet NSButton *useMetalLookButton;
	IBOutlet NSStepper *undoStepStepper;
	IBOutlet NSButton *undoStepUnlimitedButton;
	IBOutlet NSTextField *undoStepTextField;
	
	// the view
	IBOutlet NSView *theView;
	
	// initial rect
	NSRect viewFrame;
}

- (NSView *)theView;
- (NSRect)viewFrame;

// view
- (IBAction)switchMetalLook:(id)sender;

// general
- (void)setUndoStepChange:(int)undoSteps;
- (IBAction)undoStepStepperChange:(id)sender;
- (IBAction)undoStepInput:(id)sender;
- (IBAction)undoStepUnlimitedSwitch:(id)sender;

@end
