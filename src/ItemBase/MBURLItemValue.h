#import <CoreGraphics/CoreGraphics.h>//
//  MBURLItemValue.h
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

@interface MBURLItemValue : MBItemValue <NSCopying,NSCoding>
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

- (BOOL)isFile;

+ (int)isConnectableURL:(NSURL *)url;
+ (int)isLocalURL:(NSURL *)url;
+ (int)isValidURL:(NSURL *)url;

+ (NSString *)pathComponentOfURL:(NSURL *)url;
+ (NSString *)protocolComponentOfURL:(NSURL *)url;

// needed for sorting
- (NSString *)valueDataAsString;
- (NSString *)valueDataForComparison;

@end

@interface MBURLItemValue (ElementBase)

// attribute setter
- (void)setValueData:(NSURL *)aURL;
- (void)setValueDataAsData:(NSData *)aURLData;
// attribute getter
- (NSURL*)valueData;
- (NSData *)valueDataAsData;

- (void)writeValueIndexEntryWithCreate:(BOOL)flag;

@end

@interface MBURLItemValue (export)

// for exporting as .webloc
- (NSDictionary *)exportAsWebloc;

@end

