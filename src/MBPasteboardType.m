//
//  MBPasteboardType.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 29.07.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import "MBPasteboardType.h"

@implementation MBPasteboardType

/**
\brief returning all pasteboard types that we support
 */
+ (NSArray *)pasteboardTypes
{
	NSArray *types = [NSArray arrayWithObjects:
		COMMON_ITEM_PB_TYPE_NAME,
        ITEMVALUE_PB_TYPE_NAME,
		IKAM_PB_TYPE_NAME,
		nil];
	
	return types;
}

@end
