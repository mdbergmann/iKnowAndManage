//
//  MBPasswordInputController.h
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

#import <Cocoa/Cocoa.h>

enum MBPasswordDialogResult
{
	PasswordOK = 0,
	PasswordCancel
};

enum MBPasswordDialogInputWindowType
{
	SingleInput = 0,
	DoubleInput
};

@interface MBPasswordInputController : NSObject 
{
	IBOutlet NSButton *cancelButton;
	IBOutlet NSButton *okButtonSingle;
	IBOutlet NSButton *okButtonDouble;
	// for double field
	IBOutlet NSSecureTextField *passwordSField;
	IBOutlet NSSecureTextField *repeatSField;
	// for single field
	IBOutlet NSSecureTextField *passwordField;
	
	// the two windows
	IBOutlet NSWindow *singleInputWindow;
	IBOutlet NSWindow *doubleInputWindow;
	NSWindow *currentWindow;
	
	NSString *password;
	NSString *repeat;
	
	int dialogResult;
	
	int inputWindowType;
}

+ (MBPasswordInputController *)sharedController;

- (NSString *)password;
- (NSString *)repeat;

- (int)dialogResult;

// the two windows
- (void)runSingleInputWindow;
- (void)runDoubleInputWindow;

- (IBAction)okButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)passwordInput:(id)sender;
- (IBAction)repeatInput:(id)sender;

@end
