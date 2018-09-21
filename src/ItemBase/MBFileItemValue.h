#import <CoreGraphics/CoreGraphics.h>//
//  MBFileItemValue.h
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 31.08.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>
#import "MBItemValue.h"

@class MBElement;

#define ITEMVALUE_FILE_ISLINK_IDENTIFIER			@"itemvaluefileislink"
#define ITEMVALUE_FILE_LINKVALUE_IDENTIFIER			@"itemvaluefilelinkvalue"
#define ITEMVALUE_FILE_DATAVALUE_IDENTIFIER			@"itemvaluefiledatavalue"
#define ITEMVALUE_FILE_AUTOHANDLE_IDENTIFIER		@"itemvaluefileautohandleloadsave"
#define ITEMVALUE_FILE_ATTRIBUTES_IDENTIFIER		@"itemvaluefileattributesvalue"

@interface MBFileItemValue : MBItemValue <NSCopying, NSCoding> {
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

// encryption stuff
- (MBCryptoErrorCode)encryptWithString:(NSString *)aString;
- (MBCryptoErrorCode)decryptWithString:(NSString *)aString;

- (NSData *)valueDataByLoadingFromTarget;
- (BOOL)setValueDataBySavingToTarget:(NSData *)aData;

// Resource Fork stuff
+ (OSErr)getResourceDataForResType:(int)resType atPath:(NSString *)path data:(NSData **)data;

// needed for sorting
- (NSString *)valueDataAsString;
- (NSString *)valueDataForComparison;

@end

@interface MBFileItemValue (ElementBase)

// attribute setter
- (void)setAutoHandleLoadSave:(BOOL)aValue;
- (void)setValueData:(NSData *)fileData;
- (void)setIsLink:(BOOL)aValue;
- (void)setLinkValueAsString:(NSString *)aStringLinkValue;
- (void)setLinkValueAsURL:(NSURL *)aURLLinkValue;
- (void)setLinkValueAsData:(NSData *)aLinkValueData;
- (void)setFileAttributesDict:(NSDictionary *)fileAttribs;
// attribute getter
- (BOOL)autoHandleLoadSave;
- (NSData *)valueData;
- (BOOL)isLink;
- (NSString *)linkValueAsString;
- (NSURL *)linkValueAsURL;
- (NSData *)linkValueAsData;
- (NSDictionary *)fileAttributesDict;

- (void)writeValueIndexEntryWithCreate:(BOOL)flag;

@end
