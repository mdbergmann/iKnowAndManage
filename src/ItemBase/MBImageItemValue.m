
//  MBImageItemValue.m
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

#import "MBImageItemValue.h"
#import "MBValueIndexController.h"
#import "MBElement.h"
#import "MBElementValue.h"

@interface MBImageItemValue (privateAPI)

@end

@implementation MBImageItemValue (privateAPI)

@end

@implementation MBImageItemValue

// inits
- (id)init {
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR, @"cannot init super!");
	} else {
		// set state
		[self setState:InitState];

		// set identifier
		[self setIdentifier:ImageItemValueID];
		// set valuetype
		[self setValuetype:ImageItemValueType];

		// auto handle load save
		[self setAutoHandleLoadSave:NO];
		// image type
		[self setImageType:@""];
		// image size
		[self setImageSize:NSMakeSize(0.0,0.0)];
		// image byte size
		[self setImageByteSize:0];
		// thumb data
		[self setThumbImageData:[NSData data]];

		// set state
		[self setState:NormalState];
	}
	
	return self;
}

- (id)initWithDb {
	self = [self init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"cannot init super!");
	} else {
		// set state
		[self setState:InitState];
		
		// connect element
		[self setIsDbConnected:YES];
		
		// set state
		[self setState:NormalState];
	}
	
	return self;		
}

- (id)initWithInitializedElement:(MBElement *)aElem {
	return [super initWithInitializedElement:aElem];
}

- (void)dealloc {
	[super dealloc];
}

//--------------------------------------------------------------------
//------------- Item De/Encryption ----------------------
//--------------------------------------------------------------------
/**
\brief this method encrypts the number value of this itemvalue
 The super class melthod is called first to do let it do some work.
 @returns MBCryptoErrorCode
 */
- (MBCryptoErrorCode)encryptWithString:(NSString *)aString {
    MBCryptoErrorCode ret = MBCryptoOK;
	
	if((aString != nil) || ([aString length] > 0)) {
		// check the encryption state of this item
		if([self encryptionState] != EncryptedState) {
			// call super first
            MBCryptoErrorCode stat = [super encryptWithString:aString];
			// if we get an error here, do not proceed
			if(stat != MBCryptoOK) {
				ret = stat;
				CocoLog(LEVEL_WARN,@"super class returned with error, we will not proceed!");
			} else {
				NSData *encryptedData = nil;
                // encrypt thumb data
                ret = [self doEncryptionOfData:[self thumbData] 
                                 withKeyString:aString 
                                 encryptedData:&encryptedData];
                if(ret == MBCryptoOK) {
                    // write data
                    [self setThumbImageData:encryptedData];
                
                    // set state
                    [self setEncryptionState:EncryptedState];
                    // register for changing the index
                    [[MBValueIndexController defaultController] registerCommonItem:self];
                } else {
                    CocoLog(LEVEL_ERR,@"could not encrypt imageThumbValue!");
                }					
			}
		}
	} else {
		CocoLog(LEVEL_WARN,@"keyString is nil or empty!");
		ret = MBCryptoUnableToEncrypt;
	}
	
	return ret;
}

/**
\brief this method decrypts the encrypted number and the value that is returned by -valueDataAsData.
 @returns MBCryptoErrorCode
 */
- (MBCryptoErrorCode)decryptWithString:(NSString *)aString {
    MBCryptoErrorCode ret = MBCryptoOK;
	
	if((aString != nil) || ([aString length] > 0)) {
		// check the encryption state of this item
		if([self encryptionState] == EncryptedState) {
			// first call super decrypt
            MBCryptoErrorCode stat = [super decryptWithString:aString];
			// if we get an error here, do not proceed
			if(stat != MBCryptoOK) {
				ret = stat;
				CocoLog(LEVEL_WARN,@"super class returned with error, we will not proceed!");
			} else {
				NSData *decryptedData = nil;
                // decrypt thumb data
                ret = [self doDecryptionOfData:[self thumbData] 
                                 withKeyString:aString 
                                 decryptedData:&decryptedData];
                if(ret == MBCryptoOK) {
                    // write data
                    [self setThumbImageData:decryptedData];
                    // set state
                    [self setEncryptionState:DecryptedState];
                    // register for changing the index
                    [[MBValueIndexController defaultController] registerCommonItem:self];
                } else {
                    CocoLog(LEVEL_ERR,@"could not decrypt imageThumbValue!");
                }
			}
		}
	} else {
		CocoLog(LEVEL_WARN,@"keyString is nil or empty!");
		ret = MBCryptoUnableToDecrypt;
	}
	
	return ret;	
}

//--------------------------------------------------------------------
//------------- NSCopying protocoll ---------------------------------------
//--------------------------------------------------------------------
/**
\brief makes a copy of self commonitem for which the sender is responsible for releasing
 */
- (id)copyWithZone:(NSZone *)zone {
	// make a new object with alloc and init and return that
	MBImageItemValue *newItemval = [[MBImageItemValue alloc] initWithInitializedElement:[[element copy] autorelease]];
	if(newItemval == nil) {
		CocoLog(LEVEL_ERR,@"cannot alloc new MBItem!");
	} else {
	}
	
	return newItemval;
}

//--------------------------------------------------------------------
//------------- NSCoding protocoll -----------------------------------
//--------------------------------------------------------------------
- (id)initWithCoder:(NSCoder *)decoder NS_RETURNS_RETAINED {
	MBImageItemValue *newItemval = nil;
	
	if([decoder allowsKeyedCoding]) {
		// decode the only encoded object
		MBElement *elem = [decoder decodeObjectForKey:@"ItemValueElement"];
		// create commonitem with that
		newItemval = [[MBImageItemValue alloc] initWithInitializedElement:elem];
	} else {
		// decode the only encoded object
		MBElement *elem = [decoder decodeObject];
		// create commonitem with that
		newItemval = [[MBImageItemValue alloc] initWithInitializedElement:elem];
	}
	
	return newItemval;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
}

/**
\brief generate thumbnail image out of big picture if picture if larger then 128 x 128
 */
- (NSImage *)generateThumbnailOfImageRep:(NSImageRep *)imageRep {
	NSImage *thumbImage = nil;
	
	if(imageRep != nil) {
		// get size
		NSSize imageSize = NSMakeSize([imageRep pixelsWide],[imageRep pixelsHigh]);
		// we need a thumbnail to store, set thumbnail size to max 128 px each side
		NSSize thumbSize;
		if((imageSize.height > 128) || (imageSize.width > 128)) {
			if(imageSize.width > imageSize.height) {
				double factor = imageSize.width / 128;
				thumbSize.width = imageSize.width / factor;
				thumbSize.height = imageSize.height / factor;
			} else {
				double factor = imageSize.height / 128;
				thumbSize.width = imageSize.width / factor;
				thumbSize.height = imageSize.height / factor;						
			}
		} else {
			thumbSize = imageSize;
		}
		
		NSRect newRect, oldRect;						
		oldRect.origin = NSMakePoint(0,0);
		oldRect.size = imageSize;
		
		NSImage *image = [[NSImage alloc] init];
		[image addRepresentation:imageRep];
		
		newRect = NSMakeRect(0,0,thumbSize.width,thumbSize.height);
		//newRect = NSMakeRect(0,0,600,800);
		// create image
		thumbImage = [[[NSImage alloc] initWithSize:newRect.size] autorelease];
		
		[thumbImage lockFocus];
		[image drawInRect:newRect fromRect:oldRect operation:NSCompositeCopy fraction:1.0];
		[thumbImage unlockFocus];
		
		// image is not needed anymore, release it
		[image release];
	}
	
	return thumbImage;
}

/** convenience methods */
- (BOOL)setImage:(NSImage *)image {
	if(image != nil) {
		// save TIFFRepresentation of image
		NSData *tiffData = [image TIFFRepresentation];
		if(tiffData != nil) {
			// save data
			[self setValueDataBySavingToTarget:tiffData];
			return YES;
		}
	}
	
	return NO;
}

/** normally only the getter is used */
- (NSImage *)image {
	NSImage *image = nil;
	
	// create image out of stored data
	NSData *imageData = [self valueDataByLoadingFromTarget];
	if(imageData != nil) {
		image = [[[NSImage alloc] initWithData:imageData] autorelease];
	}
	
	return image;
}

/**
 \brief set thumbnail image. if thumbnail image contains a bitmap image rep, then jpg data is stored to db.
 if not, we take tiff data which costs more memory
*/
- (BOOL)setThumbImage:(NSImage *)thumbImage {
	BOOL ret = YES;
	
	if(thumbImage != nil) {
		NSData *thumbData = nil;
		// use TIFF representation
		thumbData = [thumbImage TIFFRepresentation];
		// if thumbData is still nil, we have an error
		if(thumbData != nil) {
			// save data
			[self setThumbImageData:thumbData];
		} else {
			CocoLog(LEVEL_WARN,@"could not get thumbdata to store to db!");
			ret = NO;
		}
	}
	
	return ret;
}

- (NSImage *)thumbImage {
	NSImage *image = nil;
	
	// create image out of stored data
	NSData *imageData = [self thumbData];
	if(imageData != nil) {
		image = [[[NSImage alloc] initWithData:imageData] autorelease];
	}
	
	return image;
}

@end

@implementation MBImageItemValue (ElementBase)

// attribute setter
- (void)setImageType:(NSString *)aType {
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_IMAGE_IMAGETYPE_IDENTIFIER];
	if(elemval != nil) {
		[elemval setValueDataAsString:aType];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
        [self createAttributeForValue:aType withValueType:StringValueType identifier:ITEMVALUE_IMAGE_IMAGETYPE_IDENTIFIER writeIndex:NO];
	}		
}

- (void)setImageSize:(NSSize)imageSize {
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_IMAGE_SIZE_IDENTIFIER];
	if(elemval != nil) {
		[elemval setValueDataAsString:[NSString stringWithFormat:@"%f:%f",imageSize.width,imageSize.height]];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
        [self createAttributeForValue:[NSString stringWithFormat:@"%f:%f",imageSize.width,imageSize.height] 
                        withValueType:StringValueType identifier:ITEMVALUE_IMAGE_SIZE_IDENTIFIER writeIndex:NO];
	}	
}

- (void)setImageByteSize:(unsigned int)size {
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_IMAGE_BYTE_SIZE_IDENTIFIER];
	if(elemval != nil) {
		[elemval setValueDataAsNumber:[NSNumber numberWithUnsignedInt:size]];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
        [self createAttributeForValue:[NSNumber numberWithUnsignedInt:size] withValueType:NumberValueType identifier:ITEMVALUE_IMAGE_BYTE_SIZE_IDENTIFIER writeIndex:NO];
	}
}

- (void)setThumbImageData:(NSData *)thumbData {
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_IMAGE_THUMBDATA_IDENTIFIER];
	if(elemval != nil) {
		[elemval setValueDataAsData:thumbData];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
        [self createAttributeForValue:thumbData withValueType:BinaryValueType identifier:ITEMVALUE_IMAGE_THUMBDATA_IDENTIFIER writeIndex:NO];
	}	
}

// attribute getter
- (NSString *)imageType {
	NSString *ret = nil;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_IMAGE_IMAGETYPE_IDENTIFIER];
	if(elemval != nil) {
		ret = [elemval valueDataAsString];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		ret = @"";
        [self createAttributeForValue:ret withValueType:StringValueType identifier:ITEMVALUE_IMAGE_IMAGETYPE_IDENTIFIER writeIndex:NO];
	}
	
	return ret;
}

- (NSSize)imageSize {
	NSSize imageSize;
	imageSize.width = 0.0;
	imageSize.height = 0.0;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_IMAGE_SIZE_IDENTIFIER];
	if(elemval != nil) {
		NSString *imageSizeString = [elemval valueDataAsString];
		// get size components
		NSArray *array = [imageSizeString componentsSeparatedByString:@":"];
		imageSize.width = [[array objectAtIndex:0] floatValue];
		imageSize.height = [[array objectAtIndex:1] floatValue];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
        [self createAttributeForValue:[NSString stringWithFormat:@"%f:%f",imageSize.width,imageSize.height] 
                        withValueType:StringValueType identifier:ITEMVALUE_IMAGE_SIZE_IDENTIFIER writeIndex:NO];
	}
	
	return imageSize;
}

- (unsigned int)imageByteSize {
	unsigned int size = 0;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_IMAGE_BYTE_SIZE_IDENTIFIER];
	if(elemval != nil) {
		size = [[elemval valueDataAsNumber] unsignedIntValue];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
        [self createAttributeForValue:[NSNumber numberWithUnsignedInt:size] withValueType:NumberValueType identifier:ITEMVALUE_IMAGE_BYTE_SIZE_IDENTIFIER writeIndex:NO];
	}
	
	return size;
}

- (NSData *)thumbData {
	NSData *ret = nil;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_IMAGE_THUMBDATA_IDENTIFIER];
	if(elemval != nil) {
		ret = [elemval valueDataAsData];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		ret = [NSData data];
        [self createAttributeForValue:ret withValueType:BinaryValueType identifier:ITEMVALUE_IMAGE_THUMBDATA_IDENTIFIER writeIndex:NO];
	}
	
	return ret;	
}

/**
\brief write initial valueindex entries to the table
 */
- (void)writeValueIndexEntryWithCreate:(BOOL)flag {
	// first super
	[super writeValueIndexEntryWithCreate:flag];
}

@end

