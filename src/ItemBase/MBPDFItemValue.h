#import <CoreGraphics/CoreGraphics.h>//
//  MBPDFItemValue.h
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 16.09.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author: mbergmann $
// $HeadURL: file:///REPOSITORY/private/cocoa/iKnowAndManage/trunk/src/ItemBase/MBImageItemValue.h $
// $LastChangedBy: mbergmann $
// $LastChangedDate: 2006-09-05 09:45:45 +0200 (Tue, 05 Sep 2006) $
// $Rev: 571 $

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import <MBFileItemValue.h>
#import "MBFileItemValue.h"

@class MBElement;

@interface MBPDFItemValue : MBFileItemValue <NSCopying, NSCoding> {
}

// NSCopying protocoll
- (id)copyWithZone:(NSZone *)zone;

// NSCoding stuff
- (id)initWithCoder:(NSCoder *)decoder NS_RETURNS_RETAINED;
- (void)encodeWithCoder:(NSCoder *)encoder;

// inits
- (id)init;
- (id)initWithDb;
- (id)initWithInitializedElement:(MBElement *)aElem;

// pdf getter and setter
- (BOOL)setPDFDocument:(PDFDocument *)aDoc;
- (PDFDocument *)pdfDocument;

@end

@interface MBPDFItemValue (ElementBase)

- (void)writeValueIndexEntryWithCreate:(BOOL)flag;

@end
