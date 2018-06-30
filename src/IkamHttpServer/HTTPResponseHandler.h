//
//  HTTPResponseHandler.h
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 15.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class HTTPServer;

@interface HTTPResponseHandler : NSObject {
	CFHTTPMessageRef request;
	NSString *requestMethod;
	NSDictionary *headerFields;
	NSFileHandle *fileHandle;
	HTTPServer *server;
	NSURL *url;
}

+ (int)priority;
+ (void)registerHandler:(Class)handlerClass;

+ (HTTPResponseHandler *)handlerForRequest:(CFHTTPMessageRef)aRequest
                                fileHandle:(NSFileHandle *)requestFileHandle
                                    server:(HTTPServer *)aServer;

- (id)initWithRequest:(CFHTTPMessageRef)aRequest
               method:(NSString *)method
                  url:(NSURL *)requestURL
         headerFields:(NSDictionary *)requestHeaderFields
           fileHandle:(NSFileHandle *)requestFileHandle
               server:(HTTPServer *)aServer;
- (void)startResponse;
- (void)endResponse;

@end
