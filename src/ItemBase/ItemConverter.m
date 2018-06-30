//
//  ItemConverter.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 19.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ItemConverter.h"
#import "MBItemBaseController.h"
#import "MBCommonItem.h"


@implementation ItemConverter

+ (void)convert:(MBTypeIdentifier)aSourceType toType:(MBTypeIdentifier)aDestType {
    if((aSourceType == FileItemValueID ||
        aSourceType == PDFItemValueID ||
        aSourceType == ImageItemValueID ||
        aSourceType == ExtendedTextItemValueID) &&
        (aDestType == FileItemValueID ||
         aDestType == PDFItemValueID ||
         aDestType == ImageItemValueID ||
         aDestType == ExtendedTextItemValueID)) {

        // get list of all itemvalues with this type
        NSArray *list = [itemController listForIdentifier:aSourceType];
        NSEnumerator *iter = [list objectEnumerator];
        MBCommonItem *item = nil;
        while((item = [iter nextObject])) {
            [item setIdentifier:aDestType];
        }
        // that should be it
        
    } else {
        // throw exception
        [[NSException exceptionWithName:@"ConversionException" reason:@"Invalid conversion types" userInfo:nil] raise];
    }
}

@end
