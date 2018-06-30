//
//  MBNSStringCryptoExtension.m
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

#import "MBNSStringCryptoExtension.h"


@implementation NSString (MBCryptoExtension)

/**
\brief this method returns a blowfish encrypted NSData instance of self
 */
- (NSData *)blowfishEncryptedDataForKey:(NSString *)keyString encoding:(NSStringEncoding)encoding {
	return [MBCryptoProvider doBlowfishEncryptionOfData:[self dataUsingEncoding:encoding] withKey:keyString];
}

/**
\brief this method returns a SHA1 hashed NSString instance
 */
- (NSString *)sha1Hash {
	return [MBCryptoProvider doSHA1HashOfString:self];
}

@end
