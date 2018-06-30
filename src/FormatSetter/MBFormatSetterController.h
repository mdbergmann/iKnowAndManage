//
//  MBFormatSetterController.h
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

@class MBDateFormatSetterViewController;
@class MBNumberFormatSetterViewController;

// name of the nib
#define FORMAT_SETTER_NIB_NAME @"FormatSetter"

@interface MBFormatSetterController : NSObject 
{
	IBOutlet MBDateFormatSetterViewController *dateFormatSetterController;
	IBOutlet MBNumberFormatSetterViewController *numberFormatSetterController;
}

- (MBNumberFormatSetterViewController *)numberFormatSetterController;
- (MBDateFormatSetterViewController *)dateFormatSetterController;

@end
