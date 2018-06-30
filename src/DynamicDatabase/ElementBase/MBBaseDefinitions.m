//
//  MBBaseDefinitions.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 05.07.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import "MBBaseDefinitions.h"


@implementation MBBaseDefinitions

/**
\brief singleton to return all available valuetypes with their string name
*/
+ (NSArray *)valueTypes
{
	NSArray *types = [NSArray arrayWithObjects:
		STRING_VALUETYPE_NAME,
		NUMBER_VALUETYPE_NAME,
		BINARY_VALUETYPE_NAME,
		nil];
	
	return types;
}

@end
