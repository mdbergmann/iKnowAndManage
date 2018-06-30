//
//  MBPasteboardType.h
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

#import <Cocoa/Cocoa.h>

// copy and paste type
#define COMMON_ITEM_PB_TYPE_NAME	@"MBCommonItemObject"
#define ITEMVALUE_PB_TYPE_NAME      @"MBItemValueObject"
#define IKAM_PB_TYPE_NAME           @"MBIkamExportFileType"

@interface MBPasteboardType : NSObject 
{
}

+ (NSArray *)pasteboardTypes;

@end
