//
//  MBCryptoProvider.m
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

#import "MBCryptoProvider.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>


@implementation MBCryptoProvider

/**
 \brief hashes the input data with SHA1 and returns the result
*/
+ (NSString *)doSHA1HashOfData:(NSData *)inputData {
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(inputData.bytes, (CC_LONG) inputData.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

/**
 \brief this method hashes the input string and returns a hashed one
 this method just uses -doSHA1HashOfData: 
 therefore it converts the string into a NSData object
*/
+ (NSString *)doSHA1HashOfString:(NSString *)inputString {
    return [MBCryptoProvider doSHA1HashOfData:[inputString dataUsingEncoding:NSUTF8StringEncoding]];
}

/**
 \brief encryptes the data at inputData with key which normally is a password given by the user somewhere in the application
 and returns the encrypted data
 The client is responsible for hashing the keyString bevor passing it here
*/
+ (NSData *)doBlowfishEncryptionOfData:(NSData *)inputData withKey:(NSString *)keyString {
    return [MBCryptoProvider doBlowfishDeOrEncryptionofData:inputData withKey:keyString mode:kCCEncrypt];
}

/**
 \brief decryptes the data at inputData with key which normally is a password given by the user somewhere in the application
 and returns the decrypted data
 The client is responsible for hashing the keyString bevor passing it here
 */
+ (NSData *)doBlowfishDecryptionOfData:(NSData *)inputData withKey:(NSString *)keyString {
    return [MBCryptoProvider doBlowfishDeOrEncryptionofData:inputData withKey:keyString mode:kCCDecrypt];
}

+ (NSData *)doBlowfishDeOrEncryptionofData:(NSData *)inputData withKey:(NSString *)keyString mode:(CCOperation)operation {
    // we need a constant vector (8 bytes long) for encryption
    unsigned char ivec[8] = "22091973";
    
    // we need the password as bytes, so first make a NSData object out of it
    NSData *keyData = [keyString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *dataOut = [NSMutableData dataWithLength:inputData.length + kCCBlockSizeBlowfish];
    size_t encryptedBytes = 0;
    
    CCCryptorStatus ccStatus = CCCrypt(
            operation,
            kCCAlgorithmBlowfish,
            kCCOptionPKCS7Padding | kCCOptionECBMode,
            keyData.bytes,
            keyData.length,
            ivec,
            inputData.bytes,
            inputData.length,
            dataOut.mutableBytes,
            dataOut.length,
            &encryptedBytes);
    
    if(ccStatus == kCCSuccess) {
        dataOut.length = encryptedBytes;
        return dataOut;
    }
    else {
        return nil;
    }
}

/**
 \brief encryptes the data at inputData with key which normally is a password given by the user somewhere in the application
 and returns the encrypted data
 The client is responsible for hashing the keyString bevor passing it here
 */
/*
+ (NSData *)doBlowfishEncryption2OfData:(NSData *)inputData withKey:(NSString *)keyString {
	// we need a constant vector (8 bytes long) for encryption
	unsigned char ivec[8] = "22091973";
    
	// we need the password as bytes, so first make a NSData object out of it
	//NSData *keyData = [MBCryptoProvider doSHA1HashOfData:[keyString dataUsingEncoding:NSUTF8StringEncoding]];
	NSData *keyData = [keyString dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char *keyBytes = (unsigned char *)[keyData bytes];
    
	// the data
    int inLength = [inputData length];
    unsigned char *inDataBytes = (unsigned char *)[inputData bytes];
    
    // the output
	unsigned char *outbuf = (unsigned char *)malloc([inputData length] + EVP_MAX_BLOCK_LENGTH);
	// make clear
	memset(outbuf,'\0',[inputData length] + EVP_MAX_BLOCK_LENGTH);
    int outlen = 0;
    int tmplen = 0;
    // the encryption
    EVP_CIPHER_CTX ctx;
    EVP_CIPHER_CTX_init(&ctx);
    EVP_EncryptInit_ex(&ctx, EVP_bf_cfb(), NULL, keyBytes, ivec);
    if(!EVP_EncryptUpdate(&ctx, outbuf, &outlen, inDataBytes, inLength)) {
        // error
        return nil;
    }
    // Buffer passed to EVP_EncryptFinal() must be after data just
    //encrypted to avoid overwriting it.
    //
    if(!EVP_EncryptFinal_ex(&ctx, outbuf + outlen, &tmplen)) {
        // error
        return 0;
    }
    outlen += tmplen;
    EVP_CIPHER_CTX_cleanup(&ctx);    
	
	// generate output NSData instance
	NSData *ret = nil;
	ret = [NSData dataWithBytes:outbuf length:outlen];
    free(outbuf);
	
	return ret;
}
 */

/**
 \brief decryptes the data at inputData with key which normally is a password given by the user somewhere in the application
 and returns the decrypted data
 The client is responsible for hashing the keyString bevor passing it here
 */
/*
+ (NSData *)doBlowfishDecryption2OfData:(NSData *)inputData withKey:(NSString *)keyString {
	// we need a constant vector (8 bytes long) for encryption
	unsigned char ivec[8] = "22091973";
    
	// we need the password as bytes, so first make a NSData object out of it
	//NSData *keyData = [MBCryptoProvider doSHA1HashOfData:[keyString dataUsingEncoding:NSUTF8StringEncoding]];
	NSData *keyData = [keyString dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char *keyBytes = (unsigned char *)[keyData bytes];
    
	// the data
    int inLength = [inputData length];
    unsigned char *inDataBytes = (unsigned char *)[inputData bytes];
    
    // the output
	unsigned char *outbuf = (unsigned char *)malloc([inputData length] + EVP_MAX_BLOCK_LENGTH);
	// make clear
	memset(outbuf,'\0',[inputData length] + EVP_MAX_BLOCK_LENGTH);
    int outlen = 0;
    int tmplen = 0;
    // the encryption
    EVP_CIPHER_CTX ctx;
    EVP_CIPHER_CTX_init(&ctx);
    EVP_DecryptInit_ex(&ctx, EVP_bf_cfb(), NULL, keyBytes, ivec);
    if(!EVP_DecryptUpdate(&ctx, outbuf, &outlen, inDataBytes, inLength)) {
        // error
        return nil;
    }
    // Buffer passed to EVP_EncryptFinal() must be after data just
    //encrypted to avoid overwriting it.
    //
    if(!EVP_DecryptFinal_ex(&ctx, outbuf + outlen, &tmplen)) {
        // error
        return 0;
    }
    outlen += tmplen;
    EVP_CIPHER_CTX_cleanup(&ctx);    
	
	// generate output NSData instance
	NSData *ret = nil;
	ret = [NSData dataWithBytes:outbuf length:outlen];
    free(outbuf);
	
	return ret;
}
*/

/*
+ (NSString *)doBlowfishEncryptionOfString:(NSString *)inputString withKey:(NSString *)key
{
	// replace some characters through escape sequences
	//NSString *escape = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
	//																	   (CFStringRef)inputString,
	//																	   NULL,
	//																	   CFSTR(""),
	//																	   kCFStringEncodingUTF8);
	// do blowfish encryption
	NSData *encryptedData = [MBCryptoProvider doBlowfishEncryptionOfData:[inputString dataUsingEncoding:NSUTF8StringEncoding] 
																 withKey:key];	

	const char *utf8String = [inputString UTF8String];
	NSData *stringData = [NSData dataWithBytes:utf8String length:strlen(utf8String)];
	NSData *encryptedData = [MBCryptoProvider doBlowfishEncryptionOfData:stringData withKey:key];		
	// convert encrypted data back to string
	NSString *encryptedString = [[NSString alloc] initWithData:encryptedData
													   encoding:NSUTF8StringEncoding];
	// release escape
	//[escape release];

	return [encryptedString autorelease];
}

+ (NSString *)doBlowfishDecryptionOfString:(NSString *)inputString withKey:(NSString *)key
{
	// decrypt encrypted string to NSData object
	//NSData *decryptedData = [MBCryptoProvider doBlowfishDecryptionOfData:[inputString dataUsingEncoding:NSUTF8StringEncoding] 
	//															 withKey:key];
	const char *utf8String = [inputString UTF8String];
	NSData *stringData = [NSData dataWithBytes:utf8String length:strlen(utf8String)];
	NSData *decryptedData = [MBCryptoProvider doBlowfishDecryptionOfData:stringData withKey:key];
	// convert to NSString
	NSString *decryptedString = [[[NSString alloc] initWithData:decryptedData
													   encoding:NSUTF8StringEncoding] autorelease];
	// remove added escape sequences
	//NSString *escape = (NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
	//																					   (CFStringRef)decryptedString,
	//																					   CFSTR(""),
	//																					   kCFStringEncodingUTF8);
	//return [escape autorelease];
	return decryptedString;
}
*/

@end
