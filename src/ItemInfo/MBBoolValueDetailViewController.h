//
//  MBBoolValueDetailViewController.h
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 20.07.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>
#import "MBBaseDetailViewController.h"

@interface MBBoolValueDetailViewController : MBBaseDetailViewController {
	IBOutlet NSButton *boolButton;
}

// actions
- (IBAction)acc_BoolSwitch:(id)sender;

@end
