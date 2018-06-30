//
//  MBNSDataCryptoExtension.m
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

#import "MBNSDataCryptoExtension.h"

@implementation NSData (MBCryptoExtension)

void toHex(const char *inData, char *outData, NSUInteger len) {
    char val = 0;
    //char cVal = 0;
    for(int i = 0;i < len;i++)
    {
        val = (char)inData[i];
        val = abs(val);
        sprintf(&outData[i*2], "%02X", val);
        //outData[i] = cVal;
        if(i == (len - 1))
        {
            outData[i*2+1] = '\0';
        }
    }
}

/**
\brief this method returns a blowfish encrypted NSData instance of self
 */
- (NSData *)blowfishEncryptedDataForKey:(NSString *)keyString {
	return [MBCryptoProvider doBlowfishEncryptionOfData:self withKey:keyString];
}

/**
 \brief this method returns a blowfish decrypted NSData instance of self
*/
- (NSData *)blowfishDecryptedDataForKey:(NSString *)keyString {
	return [MBCryptoProvider doBlowfishDecryptionOfData:self withKey:keyString];
}

/**
\brief this method tries to decrypt the self data object and convert it into a NSString with the given encoding
 */
- (NSString *)blowfishDecryptedStringForKey:(NSString *)keyString encoding:(NSStringEncoding)encoding {
	NSString *ret = nil;
	
	NSData *decryptedData = [MBCryptoProvider doBlowfishDecryptionOfData:self withKey:keyString];
	if(decryptedData != nil) {
		ret = [[[NSString alloc] initWithData:decryptedData encoding:encoding] autorelease];
	} else {
		NSLog(@"[MBNSDataCryptoExtension -blowfishDecryptedStringForKey:encoding:] cannot convert NSData to NSString!");
	}
	
	return ret;
}

/**
\brief this method returns a SHA1 hashed NSData instance
 */
- (NSData *)sha1Hash {
	return [MBCryptoProvider doSHA1HashOfData:self];
}

/**
 \brief generates a sh1 hash and converts it to hex string
 */
- (NSString *)sha1HashAsHexString {
    NSString *ret = nil;
    
    NSData *data = [self sha1Hash];
    
    NSUInteger len = [data length];
    // get bytes
    const char *charData = (const char *)[data bytes];
    // alloc memory for the result string
    char *hexString = (char *)calloc((len * 2) + 1, 1);
    // convert
    toHex(charData, hexString, len + 1);
    
    ret = [NSString stringWithUTF8String:hexString];
    
    return ret;    
}

@end
