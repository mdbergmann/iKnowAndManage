#import <CoreGraphics/CoreGraphics.h>//
//  MBNumberItemValue.h
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
#import "MBItemValue.h"

@interface MBNumberItemValue : MBItemValue <NSCopying,NSCoding>
{

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

// needed for sorting
- (NSString *)valueDataAsString;
- (NSString *)valueDataForComparison;

@end

@interface MBNumberItemValue (ElementBase)

// attribute setter
- (void)setValueData:(NSNumber *)aNumber;
- (void)setValueDataAsData:(NSData *)aNumberData;
- (void)setUseGlobalFormat:(BOOL)aSetting;
- (void)setFormatterString:(NSString *)aFormat;
// attribute getter
- (NSNumber *)valueData;
- (NSData *)valueDataAsData;
- (NSString *)formatterString;
- (BOOL)useGlobalFormat;

- (void)writeValueIndexEntryWithCreate:(BOOL)flag;

@end