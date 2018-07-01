//
//  MBNSStringCryptoExtension.h
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
 \brief this class is a category which extends NSString in that is is able to deal with hash, encryption and decryption
 for hashing the SHA1 implementation for de/encryption the blowfish algorithm is used
*/
@interface NSString (MBCryptoExtension)

/**
 \brief this method returns a blowfish encrypted NSData instance of self
*/
- (NSData *)blowfishEncryptedDataForKey:(NSString *)keyString encoding:(NSStringEncoding)encoding;

/**
 \brief this method returns a SHA1 hashed NSString instance
*/
- (NSString *)sha1Hash;

@end
