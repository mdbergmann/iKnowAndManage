#import <CoreGraphics/CoreGraphics.h>//
//  MBImageItemValue.h
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 16.09.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>
#import "MBFileItemValue.h"

#define ITEMVALUE_IMAGE_VALUE_IDENTIFIER			@"itemvalueimagevalue"
#define ITEMVALUE_IMAGE_ISLINK_IDENTIFIER			@"itemvalueimageislink"
#define ITEMVALUE_IMAGE_LINKVALUE_IDENTIFIER		@"itemvalueimagelinkvalue"
#define ITEMVALUE_IMAGE_AUTOHANDLE_IDENTIFIER		@"itemvalueimageautohandleloadsave"
#define ITEMVALUE_IMAGE_IMAGETYPE_IDENTIFIER		@"itemvalueimagetexttype"
#define ITEMVALUE_IMAGE_SIZE_IDENTIFIER				@"itemvalueimagesize"
#define ITEMVALUE_IMAGE_BYTE_SIZE_IDENTIFIER		@"itemvalueimagebytesize"
#define ITEMVALUE_IMAGE_THUMBDATA_IDENTIFIER		@"itemvalueimagethumbdata"

@interface MBImageItemValue : MBFileItemValue <NSCopying, NSCoding> {

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

// generating a thumb image
- (NSImage *)generateThumbnailOfImageRep:(NSImageRep *)imageRep;
// image getter and setter
- (BOOL)setImage:(NSImage *)image;
- (NSImage *)image;
- (BOOL)setThumbImage:(NSImage *)thumbImage;
- (NSImage *)thumbImage;

// encryption stuff
- (MBCryptoErrorCode)encryptWithString:(NSString *)aString;
- (MBCryptoErrorCode)decryptWithString:(NSString *)aString;

@end

@interface MBImageItemValue (ElementBase)

// attribute setter
- (void)setImageType:(NSString *)aType;
- (void)setImageSize:(NSSize)imageSize;
- (void)setImageByteSize:(unsigned int)size;
- (void)setThumbImageData:(NSData *)thumbData;
// attribute getter
- (NSString *)imageType;
- (NSSize)imageSize;
- (unsigned int)imageByteSize;
- (NSData *)thumbData;

- (void)writeValueIndexEntryWithCreate:(BOOL)flag;

@end
