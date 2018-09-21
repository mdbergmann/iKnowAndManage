#import <CoreGraphics/CoreGraphics.h>//
//  MBItemValue.h
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
#import <ColorRGBAArchiver.h>
#import <MBCommonItem.h>
#import "MBCommonItem.h"
#import "MBItemType.h"

@class MBElement;

#define ITEMVALUE_NAME_IDENTIFIER			@"itemvaluename"
#define ITEMVALUE_COMMENT_IDENTIFIER		@"itemvaluecomment"
#define ITEMVALUE_TYPE_IDENTIFIER			@"itemvaluetype"
#define ITEMVALUE_SORTORDER_IDENTIFIER		@"itemvaluesortorder"
#define ITEMVALUE_DATECREATED_IDENTIFIER	@"itemvaluedatecreated"
#define ITEMVALUE_DATEMODIFIED_IDENTIFIER	@"itemvaluedatemodified"
#define ITEMVALUE_FGCOLOR_IDENTIFIER		@"itemvaluefgcolor"
#define ITEMVALUE_BGCOLOR_IDENTIFIER		@"itemvaluebgcolor"

@interface MBItemValue : MBCommonItem <NSCopying, NSCoding> {
    /** the item this itemvalue belongs */
	id item;
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

// overriding description
- (NSString *)description;

// parent item
- (void)setItem:(id)aItem;
- (id)item;

// number of attributes
- (int)numberOfItemValueAttributes;

- (void)setValueData:(NSData *)aData;	// abstract method does nothing, has to be overriden by subclasses
- (NSData *)valueData;
- (NSString *)valueDataAsString;		// abstract method, should be overriden by subclasses
- (NSString *)valueDataForComparison;	// abstract method, should be overriden by subclasses
- (NSString *)typeAsString;

// getting the size
- (unsigned int)dataSize;

// encryption stuff
- (MBCryptoErrorCode)encryptWithString:(NSString *)aString;
- (MBCryptoErrorCode)decryptWithString:(NSString *)aString;

@end

@interface MBItemValue (ElementBase)

// attribute setter
- (void)setValuetype:(MBItemValueTypes)aType;
- (void)setName:(NSString *)aName;
- (void)setComment:(NSString *)aComment;
- (void)setCommentAsData:(NSData *)aCommentData;
- (void)setDateCreated:(NSDate *)aDate;
- (void)setDateModified:(NSDate *)aDate;
- (void)setFgColor:(NSColor *)aColor;
- (void)setBgColor:(NSColor *)aColor;
// attribute getter
- (MBItemValueTypes)valuetype;
- (NSString *)name;
- (NSString *)comment;
- (NSData *)commentAsData;
- (NSDate *)dateCreated;
- (NSDate *)dateModified;
- (NSColor *)fgColor;
- (NSColor *)bgColor;

- (void)writeValueIndexEntryWithCreate:(BOOL)flag;

@end

@protocol MBItemValueReferencing

- (void)setItem:(id)aItem;
- (id)item;
- (unsigned int)dataSize;
- (NSString *)typeAsString;

@end

@protocol MBItemValueSorting

- (int)valuetype;
- (NSString *)name;
- (int)sortorder;
- (NSString *)valueDataAsString;
- (NSString *)valueDataForComparison;

@end