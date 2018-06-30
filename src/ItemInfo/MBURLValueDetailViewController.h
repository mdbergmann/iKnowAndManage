//
//  MBURLValueDetailViewController.h
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
#import "MBBaseDetailViewController.h"

@interface MBURLValueDetailViewController : MBBaseDetailViewController {
	IBOutlet NSTextField *valueTextField;
	IBOutlet NSTextField *isLocalURLTextField;
	IBOutlet NSTextField *isValidURLTextField;
	IBOutlet NSTextField *isConnectableURLTextField;
	IBOutlet NSButton *openWithDefaultButton;
	IBOutlet NSButton *openWithButton;
}

// actions
- (IBAction)acc_SetURLFromPath:(id)sender;
- (IBAction)acc_URLValueInput:(id)sender;
- (IBAction)acc_OpenWithDefault:(id)sender;
- (IBAction)acc_OpenWith:(id)sender;

@end
