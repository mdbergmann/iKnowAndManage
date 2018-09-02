// Copyright (c) 2006 Dave Dribin (http://www.dribin.org/dave/)
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "NSData-Base64Extensions.h"
#import "NSString-Base64Extensions.h"

@implementation NSData (Base64)

- (NSData *)encodeBase64 {
    return [self encodeBase64WithNewlines:YES];
}

- (NSData *)encodeBase64WithNewlines:(BOOL)encodeWithNewlines {
    NSDataBase64EncodingOptions options = 0;
    if(encodeWithNewlines) {
        options = NSDataBase64EncodingEndLineWithLineFeed;
    }
    return [self base64EncodedDataWithOptions:options];
}

- (NSString *)encodeBase64WithNewlinesToString:(BOOL)encodeWithNewlines {
    NSDataBase64EncodingOptions options = 0;
    if(encodeWithNewlines) {
        options = NSDataBase64EncodingEndLineWithLineFeed;
    }
    return [self base64EncodedStringWithOptions:options];
}

- (NSData *)decodeBase64WithNewlines:(BOOL)encodedWithNewlines {
    return [[[NSData alloc] initWithBase64EncodedData:self options:NSDataBase64DecodingIgnoreUnknownCharacters] autorelease];
}

@end
