//
//  MBTextValueDetailViewController.h
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

@interface MBTextValueDetailViewController : MBBaseDetailViewController {
	IBOutlet NSTextField *valueTextField;
}

// actions
- (IBAction)acc_TextValueInput:(id)sender;

@end
