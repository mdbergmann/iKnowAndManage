//
//  MBNumberValueDetailViewController.h
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

@class MBBaseDetailViewController;

@interface MBNumberValueDetailViewController : MBBaseDetailViewController {
	IBOutlet NSTextField *numberTextField;
	IBOutlet NSButton *useGlobalFormatButton;
	IBOutlet NSButton *setFormatButton;
}

// actions
- (IBAction)acc_ValueInput:(id)sender;
- (IBAction)acc_UseGlobalFormatSwitch:(id)sender;
- (IBAction)acc_SetFormat:(id)sender;

@end
