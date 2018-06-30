//
//  MBCryptoProvider.h
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 21.09.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>

/**
 \brief taking sha1 and blowfish as cryptographic methods from openssl
 implementation is done as categories which expand NSString and NSData
*/

@interface MBCryptoProvider : NSObject {

}

// SHA1 hashing
+ (NSString *)doSHA1HashOfData:(NSData *)inputData;
+ (NSString *)doSHA1HashOfString:(NSString *)inputString;

// blowfish encrypting
+ (NSData *)doBlowfishEncryptionOfData:(NSData *)inputData withKey:(NSString *)key;
+ (NSData *)doBlowfishDecryptionOfData:(NSData *)inputData withKey:(NSString *)key;
/*
+ (NSData *)doBlowfishEncryption2OfData:(NSData *)inputData withKey:(NSString *)key;
+ (NSData *)doBlowfishDecryption2OfData:(NSData *)inputData withKey:(NSString *)key;
 */
/*
+ (NSString *)doBlowfishEncryptionOfString:(NSString *)inputString withKey:(NSString *)key;
+ (NSString *)doBlowfishDecryptionOfString:(NSString *)inputString withKey:(NSString *)key;
*/

@end
