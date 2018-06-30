//
//  MBFormatSetterController.m
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

#import "MBFormatSetterController.h"
#import "MBDateFormatSetterViewController.h"
#import "MBNumberFormatSetterViewController.h"


@implementation MBFormatSetterController

/**
 \brief return the numberFormatSetterView for general purpose
*/
- (MBNumberFormatSetterViewController *)numberFormatSetterController
{
	return numberFormatSetterController;
}

/**
\brief return the dateFormatSetterView for general purpose
 */
- (MBDateFormatSetterViewController *)dateFormatSetterController
{
	return dateFormatSetterController;
}

@end
