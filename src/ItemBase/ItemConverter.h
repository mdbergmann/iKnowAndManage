//
//  ItemConverter.h
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 19.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MBItemType.h"

/**
 in here are methods that can convert from one item type to another like: File->PDF or back
 */
@interface ItemConverter : NSObject {

}

/**
 This method converts a given ItemValue to a destination item value type
 Only File based Items can converted within each other.
 Basic values can not be converted to file based values and vise versa.
 @throws exception on any problem.
 */
+ (void)convert:(MBTypeIdentifier)aSourceType toType:(MBTypeIdentifier)aDestType;

@end
