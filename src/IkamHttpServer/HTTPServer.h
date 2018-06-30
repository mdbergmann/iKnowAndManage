//
//  HTTPServer.h
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 14.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
	SERVER_STATE_IDLE,
	SERVER_STATE_STARTING,
	SERVER_STATE_RUNNING,
	SERVER_STATE_STOPPING
}HTTPServerState;

@class HTTPResponseHandler;

@interface HTTPServer : NSObject {
    NSError *lastError;
    int port;
    HTTPServerState state;
	NSFileHandle *listeningHandle;
	CFSocketRef socket;
	CFMutableDictionaryRef incomingRequests;
	NSMutableSet *responseHandlers;
}

+ (HTTPServer *)sharedHTTPServer;

- (id)initWithPort:(int)aPort;

- (void)setPort:(int)aPort;
- (int)port;

- (void)setState:(HTTPServerState)aState;
- (HTTPServerState)state;

- (NSError *)lastError;

- (void)start;
- (void)stop;

- (void)closeHandler:(HTTPResponseHandler *)aHandler;

@end
