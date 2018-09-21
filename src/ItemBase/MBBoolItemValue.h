#import <CoreGraphics/CoreGraphics.h>//
//  MBBoolItemValue.h
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

@interface MBBoolItemValue : MBItemValue <NSCopying,NSCoding>
{

}

// NSCopying protocoll
- (id)copyWithZone:(NSZone *)zone;

// NSCoding stuff
- (id)initWithCoder:(NSCoder *)decoder NS_RETURNS_RETAINED;
- (void)encodeWithCoder:(NSCoder *)encoder;

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

@interface MBBoolItemValue (ElementBase)

// attribute setter
- (void)setValueData:(BOOL)aValue;
- (void)setValueDataAsData:(NSData *)aBoolData;
// attribute getter
- (BOOL)valueData;
- (NSData *)valueDataAsData;

- (void)writeValueIndexEntryWithCreate:(BOOL)flag;

@end