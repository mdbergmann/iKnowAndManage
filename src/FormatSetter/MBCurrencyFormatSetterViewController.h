//
//  MBCurrencyFormatSetterViewController.h
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 15.07.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import <MBFormatSetterController.h>
#import <MBNumberFormatSetterViewController.h>

@interface MBCurrencyFormatSetterViewController : MBNumberFormatSetterViewController 
{
	IBOutlet NSTextField *currencySymbolTextField;
}

- (IBAction)currencySymbolInput:(id)sender;

@end
