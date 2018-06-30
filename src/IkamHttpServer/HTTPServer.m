//
//  HTTPServer.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 14.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HTTPServer.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import "HTTPResponseHandler.h"
#import "SingletonSyntesizer.h"

const NSString *HTTPServerNotificationStateChanged = @"ServerNotificationStateChanged";

@interface HTTPServer (privateAPI)

- (void)setLastError:(NSError *)anError;
- (void)errorWithName:(NSString *)errorName;
- (void)stopReceivingForFileHandle:(NSFileHandle *)incomingFileHandle close:(BOOL)closeFileHandle;

@end

@implementation HTTPServer (privateAPI)

- (void)setLastError:(NSError *)anError {
    [anError retain];
    [lastError release];
    lastError = anError;
    
    if(anError != nil) {
        // stop server
        [self stop];
        state = SERVER_STATE_IDLE;
        NSLog(@"HTTPServer error: %@", anError);    
    }    
}

- (void)errorWithName:(NSString *)errorName {
    NSString *errorString = NSLocalizedStringFromTable(errorName, @"", @"HTTPServerErrors");
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorString forKey:NSLocalizedDescriptionKey];
    NSError *err = [NSError errorWithDomain:@"HTTPServerError"
                                       code:0
                                   userInfo:userInfo];
    [self setLastError:err];
}

/**
 Closes the file handle and stops listening for for incoming data on this handle.
 */
- (void)stopReceivingForFileHandle:(NSFileHandle *)incomingFileHandle close:(BOOL)closeFileHandle {
	if (closeFileHandle) {
		[incomingFileHandle closeFile];
	}
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSFileHandleDataAvailableNotification
                                                  object:incomingFileHandle];
	CFDictionaryRemoveValue(incomingRequests, incomingFileHandle);
}

@end

@implementation HTTPServer

#pragma mark - Initialization

SYNTHESIZE_SINGLETON_FOR_CLASS(HTTPServer)

- (id)init {
    return [self initWithPort:8080];
}

- (id)initWithPort:(int)aPort {
    if(self) {
        // default port
        port = aPort;

        state = SERVER_STATE_IDLE;
		responseHandlers = [[NSMutableSet alloc] init];
		incomingRequests =
        CFDictionaryCreateMutable(
                                  kCFAllocatorDefault,
                                  0,
                                  &kCFTypeDictionaryKeyCallBacks,
                                  &kCFTypeDictionaryValueCallBacks);
    }
    
    return self;    
}

#pragma mark - Getter/Setter

- (void)setPort:(int)aPort {
    port = aPort;
}

- (int)port {
    return port;
}

- (void)setState:(HTTPServerState)aState {
    if(state != aState) {
        state = aState;        
        [[NSNotificationCenter defaultCenter] postNotificationName:HTTPServerNotificationStateChanged object:self];            
    }
}

- (HTTPServerState)state {
    return state;
}

- (NSError *)lastError {
    return lastError;
}

#pragma mark - Methods

- (void)start {
    
	[self setLastError:nil];
	[self setState:SERVER_STATE_STARTING];
    
    socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, 0, NULL, NULL);
    if (!socket) {
        [self errorWithName:@"Unable to create socket."];
        return;
    }
    
    int reuse = true;
    int fileDescriptor = CFSocketGetNative(socket);
    if (setsockopt(fileDescriptor, SOL_SOCKET, SO_REUSEADDR, (void *)&reuse, sizeof(int)) != 0) {
        [self errorWithName:@"Unable to set socket options."];
        return;
    }
    
    struct sockaddr_in address;
    memset(&address, 0, sizeof(address));
    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = htonl(INADDR_ANY);
    address.sin_port = htons(port);
    CFDataRef addressData = CFDataCreate(NULL, (const UInt8 *)&address, sizeof(address));
    [(id)addressData autorelease];
    
    if(CFSocketSetAddress(socket, addressData) != kCFSocketSuccess) {
        [self errorWithName:@"Unable to bind socket to address."];
        return;
    }
    
    listeningHandle = [[NSFileHandle alloc] initWithFileDescriptor:fileDescriptor closeOnDealloc:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveIncomingConnectionNotification:)
                                                 name:NSFileHandleConnectionAcceptedNotification
                                               object:nil];
    [listeningHandle acceptConnectionInBackgroundAndNotify];
    
    [self setState:SERVER_STATE_RUNNING];
}

- (void)stop {
	[self setState:SERVER_STATE_STOPPING];
    
    // remove observing incoming handles
	[[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSFileHandleConnectionAcceptedNotification
                                                  object:nil];
    
	[responseHandlers removeAllObjects];
    
	[listeningHandle closeFile];
	[listeningHandle release];
	listeningHandle = nil;
	
    NSEnumerator *iter = [[(NSDictionary *)incomingRequests allValues] objectEnumerator];
    NSFileHandle *incomingFileHandle = nil;
	while((incomingFileHandle = [iter nextObject])) {
		[self stopReceivingForFileHandle:incomingFileHandle close:YES];
	}
	
	if(socket) {
		CFSocketInvalidate(socket);
		CFRelease(socket);
		socket = nil;
	}
    
	[self setState:SERVER_STATE_IDLE];
}

- (void)closeHandler:(HTTPResponseHandler *)aHandler {
	[aHandler endResponse];
	[responseHandlers removeObject:aHandler];
}

#pragma mark - Notifications

- (void)receiveIncomingConnectionNotification:(NSNotification *)aNotification {

	NSDictionary *userInfo = [aNotification userInfo];
	NSFileHandle *incomingFileHandle = [userInfo objectForKey:NSFileHandleNotificationFileHandleItem];
    if(incomingFileHandle) {
		CFDictionaryAddValue(incomingRequests, 
                             incomingFileHandle, 
                             [(id)CFHTTPMessageCreateEmpty(kCFAllocatorDefault, TRUE) autorelease]);
		
		[[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveIncomingDataNotification:)
                                                     name:NSFileHandleDataAvailableNotification
                                                   object:incomingFileHandle];
		
        [incomingFileHandle waitForDataInBackgroundAndNotify];
    }
    
	[listeningHandle acceptConnectionInBackgroundAndNotify];
}

- (void)receiveIncomingDataNotification:(NSNotification *)notification {
	NSFileHandle *incomingFileHandle = [notification object];
	NSData *data = [incomingFileHandle availableData];	
	if([data length] == 0) {
		[self stopReceivingForFileHandle:incomingFileHandle close:NO];
		return;
	}
    
	CFHTTPMessageRef incomingRequest = (CFHTTPMessageRef)CFDictionaryGetValue(incomingRequests, incomingFileHandle);
	if(!incomingRequest) {
        // invalid request
		[self stopReceivingForFileHandle:incomingFileHandle close:YES];
		return;
	}
	
	if(!CFHTTPMessageAppendBytes(incomingRequest, [data bytes], [data length])) {
        // unable to append bytes
		[self stopReceivingForFileHandle:incomingFileHandle close:YES];
		return;
	}
    
	if(CFHTTPMessageIsHeaderComplete(incomingRequest)) {
		HTTPResponseHandler *handler = [HTTPResponseHandler handlerForRequest:incomingRequest
                                                                   fileHandle:incomingFileHandle
                                                                       server:self];
		
		[responseHandlers addObject:handler];
		[self stopReceivingForFileHandle:incomingFileHandle close:NO];
        
		[handler startResponse];	
		return;
	}
    
	[incomingFileHandle readInBackgroundAndNotify];
}

@end
