//
//  MBPasswordInputController.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 21.11.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <CocoLogger/CocoLogger.h>
#import "MBPasswordInputController.h"
#import "MBNSStringCryptoExtension.h"

@interface MBPasswordInputController (privateAPI)

- (void)setPassword:(NSString *)aString;
- (void)setRepeat:(NSString *)aString;

@end

@implementation MBPasswordInputController (privateAPI)

- (void)setPassword:(NSString *)aString
{
	[aString retain];
	[password release];
	password = aString;
}

- (void)setRepeat:(NSString *)aString
{
	[aString retain];
	[repeat release];
	repeat = aString;	
}

@end

@implementation MBPasswordInputController

/**
\brief this is a singleton
 */
+ (MBPasswordInputController *)sharedController
{
	static MBPasswordInputController *singleton;
	
	if(singleton == nil)
	{
		singleton = [[MBPasswordInputController alloc] init];
	}
	
	return singleton;	
}

- (id)init
{
	self = [super init];
	if(self != nil)
	{
		BOOL success = [NSBundle loadNibNamed:@"PasswordInput" owner:self];
		if(success)
		{
			[self setPassword:@""];
			[self setRepeat:@""];
		}
		else
		{
			CocoLog(LEVEL_ERR,@"[MBPasswordInputController]: cannot load PasswordInput.nib!");
		}
	}
	
	return self;
}

- (void)awakeFromNib
{
	// deactivate ok button as long as there is a password and the repeated password matches
	[okButtonDouble setEnabled:NO];
}

- (void)dealloc
{
	[self setPassword:nil];
	[self setRepeat:nil];

	[super dealloc];
}

// the two windows
- (void)runSingleInputWindow
{
	inputWindowType = SingleInput;
	currentWindow = singleInputWindow;
	[currentWindow setDefaultButtonCell:[okButtonSingle cell]];
	
	// reset settings
	[self setPassword:@""];
	[passwordField setStringValue:@""];
	
	// run window modal
	[NSApp runModalForWindow:singleInputWindow];
}

- (void)runDoubleInputWindow
{
	inputWindowType = DoubleInput;
	currentWindow = doubleInputWindow;

	// reset settings
	[self setPassword:@""];
	[self setRepeat:@""];
	[passwordSField setStringValue:@""];
	[repeatSField setStringValue:@""];
	
	// run window modal
	[NSApp runModalForWindow:doubleInputWindow];
}

- (BOOL)checkPassword
{
	if((password != nil) && (repeat != nil))
	{
		return [password isEqualToString:repeat];
	}
	else
	{
		return NO;
	}	
}

- (int)dialogResult
{
	return dialogResult;
}

- (NSString *)password
{
	return password;
}

- (NSString *)repeat
{
	return repeat;
}

- (IBAction)okButtonPressed:(id)sender
{
	[currentWindow close];
	
	dialogResult = PasswordOK;

	// break modality
	[NSApp stopModal];
}

- (IBAction)cancelButtonPressed:(id)sender
{
	[currentWindow close];
	
	dialogResult = PasswordCancel;
	
	// break modality
	[NSApp stopModal];
}

- (IBAction)passwordInput:(id)sender
{
	[self setPassword:[[sender stringValue] sha1Hash]];
	
	if(inputWindowType == DoubleInput)
	{
		if([self checkPassword] == YES)
		{
			[okButtonDouble setEnabled:YES];
			[currentWindow setDefaultButtonCell:[okButtonDouble cell]];
		}
	}
}

- (IBAction)repeatInput:(id)sender
{
	[self setRepeat:[[sender stringValue] sha1Hash]];

	if([self checkPassword] == YES)
	{
		[okButtonDouble setEnabled:YES];
		[currentWindow setDefaultButtonCell:[okButtonDouble cell]];
	}
}

@end
