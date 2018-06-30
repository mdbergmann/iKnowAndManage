//
//  MBTemplate.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 26.09.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "MBTemplate.h"


@implementation MBTemplate

/**
 Replace the source string which is a template with the dictionary
 entries.
 */
+ (NSString *)replaceTemplateStringSource:(NSString *)source withDict:(NSDictionary *)dict {
    NSString *ret = nil;
    
    if(source != nil) {
        // loop over all keys in the dict
        NSMutableString *work = [NSMutableString stringWithString:source];
        NSEnumerator *iter = [dict keyEnumerator];
        NSString *key = nil;
        while((key = [iter nextObject])) {
            NSString *value = [dict objectForKey:key];
            if(value != nil) {
                int changes = [work replaceOccurrencesOfString:key withString:value options:0 range:NSMakeRange(0, [work length])];
            }
        }
        
        ret = [NSString stringWithString:work];
    }
    
    return ret;
}

@end
