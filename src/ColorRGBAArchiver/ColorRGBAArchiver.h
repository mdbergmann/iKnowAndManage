//
//  ColorRGBAArchiver.h
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 28.07.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Foundation/Foundation.h>
#import <CocoLogger/CocoLogger.h>

@interface NSColor (ColorRGBAArchiver)

- (NSData *)archiveRGBAComponentsAsData;
- (NSString *)archiveRGBAComponentsAsString;
+ (NSColor *)colorFromRGBAArchivedData:(NSData *)aData;
+ (NSColor *)colorFromRGBAArchivedString:(NSString *)aString;

@end
