//
//  EnDecrypt.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 06.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "EnDecrypt.h"
#import "MBCryptoProvider.h"
#import "MBNSStringCryptoExtension.h"
#import "MBNSDataCryptoExtension.h"
#import "NSData-Base64Extensions.h"
#import "NSString-Base64Extensions.h"

@implementation EnDecrypt

- (void)testLowLevelEnDecryption {
    
    // key
    NSString *keyStr = @"helloworld";
    
    // data
    NSString *inStr = @"test1";
    NSData *inData = [inStr dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertNotNil(inData, @"inData is nil!");
    
    // encrypt
    NSLog(@"encrypting...");
    NSData *encData = [MBCryptoProvider doBlowfishEncryptionOfData:inData withKey:keyStr];
    NSLog(@"encrypting...done");
    XCTAssertNotNil(encData, @"encrypted data is nil!");
    
    // decrypt
    NSLog(@"decrypting...");
    NSData *decData = [MBCryptoProvider doBlowfishDecryptionOfData:encData withKey:keyStr];
    NSLog(@"decData:%s", [decData bytes]);
    XCTAssertNotNil(decData, @"decrypted data is nil!");
    
    // turn into string
    NSString *outStr = [[NSString alloc] initWithData:decData encoding:NSUTF8StringEncoding];
    NSLog(@"outStr:%@", outStr);
    XCTAssertNotNil(outStr, @"data to string conversion didn't work, String is nil!");
    
    // check equal
    XCTAssertEqualObjects(inStr, outStr, @"In and out string do not match!");
}

- (void)testUpperLevelEnDecryption {
    
    // key
    NSString *keyStr = @"helloworld";
    
    // data
    NSString *inStr = @"test1";
    
    // encrypt
    NSData *encStr = [inStr blowfishEncryptedDataForKey:keyStr encoding:NSUTF8StringEncoding];
    XCTAssertNotNil(encStr, @"encrypted string is nil!");
    
    // decrypt
    NSString *decStr = [encStr blowfishDecryptedStringForKey:keyStr encoding:NSUTF8StringEncoding];
    NSLog(@"decStr:%@", decStr);
    XCTAssertNotNil(encStr, @"decrypted string is nil!");
    
    // equal?
    XCTAssertEqualObjects(inStr, decStr, @"In and out string do not match!");
}

- (void)testBase64DataEnDecoding {
    
    // in string
    NSString *inStr = @"test1";
    NSData *inData = [inStr dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertNotNil(inData, @"inData is nil!");
    
    // do base64 encoding
    NSString *base64Str = [[NSString alloc] initWithData:[inData encodeBase64] encoding:NSUTF8StringEncoding];
    XCTAssertNotNil(base64Str, @"encoded base64 data is nil!");
    NSLog(@"base64Str:%@", base64Str);
    
    // do decoding
    NSData *decBase64Data = [base64Str decodeBase64];
    XCTAssertNotNil(decBase64Data, @"decoded base64 data is nil!");
    
    // check equality
    NSString *outStr = [[NSString alloc] initWithData:decBase64Data encoding:NSUTF8StringEncoding];
    NSLog(@"outStr:%@", outStr);
    XCTAssertEqualObjects(inStr, outStr, @"in and out do not match!");
}

/*
- (void)testOldBase64DataEnDecoding {
    
    // in string
    NSString *inStr = @"test1";
    NSData *inData = [inStr dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertNotNil(inData, @"inData is nil!");
    
    // do base64 encoding
    NSData *base64Data = [inData encodeBase64WithNewlines:YES];
    XCTAssertNotNil(base64Data, @"encoded base64 data is nil!");
    NSLog(@"base64Str:%s", [base64Data bytes]);
    
    // do decoding
    NSData *decBase64Data = [NSData decode :base64Data];
    XCTAssertNotNil(decBase64Data, @"decoded base64 data is nil!");
    NSLog(@"decBase64Data:%s", [decBase64Data bytes]);
    
    // check equality
    NSString *outStr = [[NSString alloc] initWithData:decBase64Data encoding:NSUTF8StringEncoding];
    NSLog(@"outStr:%@", outStr);
    XCTAssertEqualObjects(inStr, outStr, @"in and out do not match!");
}
*/

/*
- (void)testOldBase64ToDecNew {
    
    // do base 64 encoding of the old algorithm and try to decode it using the new
    NSString *inStr = @"test1";
    NSData *inData = [inStr dataUsingEncoding:NSUTF8StringEncoding];    
    
    // do base64 encoding
    NSData *base64EncOld = [inData base64EncodedDataWithLineLength:0];
    STAssertNotNil(base64EncOld, @"encoded base64 data is nil!");
    
    // decode using new openSSL algo
    NSString *base64Str = [[[NSString alloc] initWithData:base64EncOld encoding:NSUTF8StringEncoding] autorelease];
    STAssertNotNil(base64Str, @"base64 string is nil!");
    NSLog(@"base64Str:%@", base64Str);
    //NSData *decBase64Data = [base64EncOld decodeBase64];
    NSData *decBase64Data = [base64Str decodeBase64WithNewlines:NO];
    STAssertNotNil(decBase64Data, @"decoded base64 data is nil!");
    NSLog(@"decBase64Data:%s", [decBase64Data bytes]);
    
    // check equality
    NSString *outStr = [[[NSString alloc] initWithData:decBase64Data encoding:NSUTF8StringEncoding] autorelease];
    NSLog(@"outStr:%@", outStr);
    STAssertEqualObjects(inStr, outStr, @"in and out do not match!");    
}
 */



@end
