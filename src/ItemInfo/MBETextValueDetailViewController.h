//
//  MBETextValueDetailViewController.h
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
#import "MBFileBaseDetailViewController.h"

@class MBTextEditorViewController;

@interface MBETextValueDetailViewController : MBFileBaseDetailViewController {
	IBOutlet NSTextField *statusLabel;
	IBOutlet NSButton *saveButton;
	IBOutlet NSPopUpButton *textTypePopUpButton;

	// the editor
	MBTextEditorViewController *editor;

	// flag if altered data has been saved
	BOOL isSaved;
}

- (void)displayInfoWithPreservingTextValue;

// getter for isSaved
- (BOOL)isSaved;
- (BOOL)hasChangedData;

// MBTextEditorWindowController delegate method
- (void)textChangedNotify;

// save method
- (void)saveWithRequester:(BOOL)withRequester;

// actions
- (IBAction)acc_Load:(id)sender;
- (IBAction)acc_Save:(id)sender;
- (IBAction)acc_SetTextType:(id)sender;

@end
