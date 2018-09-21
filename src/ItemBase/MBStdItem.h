#import <CoreGraphics/CoreGraphics.h>//
//  MBStdItem.h
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 25.08.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>
#import "MBItem.h"

@interface MBStdItem : MBItem <NSCopying, NSCoding> {
}

// NSCopying protocoll
- (id)copyWithZone:(NSZone *)zone;

// NSCoding stuff
- (id)initWithCoder:(NSCoder *)decoder NS_RETURNS_RETAINED;
- (void)encodeWithCoder:(NSCoder *)encoder;

- (id)init;
- (id)initWithDb;
- (id)initWithInitializedElement:(MBElement *)aElem;

@end

@interface MBStdItem (ElementBase)

// attribute setter
- (void)setComment:(NSString *)aComment;
- (void)setDateCreated:(NSDate *)aDate;
- (void)setDateModified:(NSDate *)aDate;
- (void)setFgColor:(NSColor *)aColor;
- (void)setBgColor:(NSColor *)aColor;
// attribute getter
- (NSString *)comment;
- (NSDate *)dateCreated;
- (NSDate *)dateModified;
- (NSColor *)fgColor;
- (NSColor *)bgColor;

- (void)writeValueIndexEntryWithCreate:(BOOL)flag;

@end