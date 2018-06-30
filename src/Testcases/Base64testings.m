/*
 *  Base64testings.c
 *  iKnowAndManage
 *
 *  Created by Manfred Bergmann on 20.09.07.
 *  Copyright 2007 __MyCompanyName__. All rights reserved.
 *
 */

#import "Base64testings.h"
#import <NSData-Base64Extensions.h>
#import <NSString-Base64Extensions.h>
#import <MBNSStringCryptoExtension.h>
#import <MBNSDataCryptoExtension.h>


#import <Foundation/Foundation.h>

void toHex(const char *inData, char *outData, int len)
{
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

NSString* encodeHTMLEntitiesInString(NSString *source)
{
    NSString *ret = nil;
    
    // loop over all 
    int len = [source length];
    // this will get the output
    NSMutableString *dest = [NSMutableString string];
    for(int i = 0;i < len;i++)
    {
        unichar str = [source characterAtIndex:i];
        if((str >= 160) && (str <= 255))
        {
            // we need to encode this
            [dest appendFormat:@"&#%d;", str];
        }
        else
        {
            [dest appendString:[NSString stringWithCharacters:&str length:1]];
        }
    }
    
    ret = [NSString stringWithString:dest];
    
    return ret;
}


int main (int argc, const char * argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    unichar chars[5];
    chars[0] = 196;
    chars[1] = 214;
    chars[2] = '\0';
    
    NSString *testStr = [NSString stringWithCharacters:chars length:5];
    //NSString *isoStr = [testStr 
    
    NSString *resultStr = encodeHTMLEntitiesInString(testStr);
    
    
    /*
    // load data from some file
    NSString *buffer = @"";
    NSData *data = [NSData dataWithContentsOfFile:@"/Users/mbergmann/Desktop/trunk.zip"];
    // make sha1 hash
    NSData *docHash = [data sha1Hash];
    const char *charData = (const char *)[docHash bytes];
    char *hexString = (char *)calloc(([docHash length] * 2) + 1, 1);
    toHex(charData, hexString, [docHash length] + 1);
    NSString *hexNSString = [NSString stringWithCString:hexString];

    NSString *docISOL1Hash = [[[NSString alloc] initWithData:docHash encoding:NSISOLatin1StringEncoding] autorelease];
    NSString *base64Hash = [docHash encodeBase64WithNewlines:NO];
    NSString *escape = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                        (CFStringRef)base64Hash,
                                                                        NULL,
                                                                        CFSTR("'"),
                                                                        kCFStringEncodingISOLatin1);
    [escape autorelease];
    NSString *base64PercentEscape = [base64Hash stringByAddingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding];
     */


    [pool release];

    return 0;
}
