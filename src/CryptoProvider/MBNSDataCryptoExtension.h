//
//  MBNSDataCryptoExtension.h
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

#import <Foundation/Foundation.h>
#import "MBCryptoProvider.h"

/**
 \brief this class is a category which extends NSData in that is is able to deal with hash, encryption and decryption
 for hashing the SHA1 implementation for de/encryption the blowfish algorithm is used
*/
@interface NSData (MBCryptoExtension) 

/**
 \brief this method returns a blowfish encrypted NSData instance of self
*/
- (NSData *)blowfishEncryptedDataForKey:(NSString *)keyString;

/**
 \brief this method returns a blowfish decrypted NSData instance of self
*/
- (NSData *)blowfishDecryptedDataForKey:(NSString *)keyString;

/**
 \brief this method tries to decrypt the self data object and convert it into a NSString with the given encoding
*/
- (NSString *)blowfishDecryptedStringForKey:(NSString *)keyString encoding:(NSStringEncoding)encoding;

/**
 \brief this method returns a SHA1 hashed NSData instance
*/
- (NSString *)sha1Hash;

    /**
    \brief generates a sh1 hash and converts it to hex string
     */
- (NSString *)sha1HashAsHexString;

@end
