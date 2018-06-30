//
//  MBPrivacyPrefsViewController.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 15.09.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <CocoLogger/CocoLogger.h>
#import "MBPrivacyPrefsViewController.h"
#import "EMKeychainProxy.h"

@interface MBPrivacyPrefsViewController (privateAPI)

- (void)setNewPassword:(NSString *)aString;
- (void)setNewRepeat:(NSString *)aString;
- (void)timeElapsed;

@end

@implementation MBPrivacyPrefsViewController (privateAPI)

- (void)setNewPassword:(NSString *)aString {
	[aString retain];
	[newPassword release];
	newPassword = aString;
}

- (void)setNewRepeat:(NSString *)aString {
	[aString retain];
	[newRepeat release];
	newRepeat = aString;	
}

- (void)timeElapsed {
	// if the time is elapsed, check wether we are visible now
	// if yes, bring alert dialog and reset the password settings
	// if no, only reset the password settings
	
	// reset password settings
	[newPWSField setEnabled:NO];
	[newPWRepeatSField setEnabled:NO];
	// deactivate this button
	[changeButton setEnabled:NO];
    [newPWSequenceButton setEnabled:YES];
	
	[newPWSField setStringValue:@""];
	[newPWRepeatSField setStringValue:@""];	
}

@end


@implementation MBPrivacyPrefsViewController

- (id)init {
	CocoLog(LEVEL_DEBUG, @"init of MBPrivacyPrefsViewController");
	
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR, @"cannot alloc MBPrivacyPrefsViewController!");
	} else {
		[self setNewPassword:@""];
		[self setNewRepeat:@""];
	}
	
	return self;
}

/**
\brief dealloc of this class is called on closing this document
 */
- (void)dealloc {
	CocoLog(LEVEL_DEBUG, @"dealloc of MBPrivacyPrefsViewController");
	
	[self setNewRepeat:nil];
	[self setNewPassword:nil];
	
	// dealloc object
	[super dealloc];
}

//--------------------------------------------------------------------
//----------- bundle delegates ---------------------------------------
//--------------------------------------------------------------------
- (void)awakeFromNib {
	CocoLog(LEVEL_DEBUG, @"awakeFromNib of MBPrivacyPrefsViewController");
	
	if(self != nil) {
		// init the viewRect
		viewFrame = [theView frame];

		// empty oldPWSField
		[newPWSField setStringValue:@""];
		[newPWRepeatSField setStringValue:@""];
        [newPWSField setEnabled:NO];
        [newPWRepeatSField setEnabled:NO];
		
		// deactivate chenge button in every way
		[changeButton setEnabled:NO];
	}
}

- (void)checkPassword {
	if((newPassword != nil) && (newRepeat != nil)) {
		if([newPassword isEqualToString:newRepeat]) {
			// activate changeButton
			[changeButton setEnabled:YES];		
		}
	}
}

/**
 \brief return the view itself
*/
- (NSView *)theView {
	return theView;
}

- (NSRect)viewFrame {
	return viewFrame;
}

- (IBAction)changePassword:(id)sender {
    // store new password in Keychain
    EMGenericKeychainItem *kItem = [[EMKeychainProxy sharedProxy] genericKeychainItemForService:@"iKnowAndManage" withUsername:@"DefaultPassword"];
    if(kItem) {
        [kItem setPassword:newPassword];
    } else {
        [[EMKeychainProxy sharedProxy] addGenericKeychainItemForService:@"iKnowAndManage" withUsername:@"DefaultPassword" password:newPassword];    
    }

	[newPWSField setEnabled:NO];
	[newPWRepeatSField setEnabled:NO];
	// deactivate this button
	[changeButton setEnabled:NO];
    [newPWSequenceButton setEnabled:YES];
	
	[newPWSField setStringValue:@""];
	[newPWRepeatSField setStringValue:@""];
}

- (IBAction)startNewPasswordSequence:(id)sender {
    // activate new
    [newPWSField setEnabled:YES];
    [newPWRepeatSField setEnabled:YES];
    [newPWSequenceButton setEnabled:NO];
    
    // start timer
    [NSTimer scheduledTimerWithTimeInterval:15.0 
                                     target:self 
                                   selector:@selector(timeElapsed) 
                                   userInfo:nil 
                                    repeats:NO];
}

- (IBAction)newPasswordInput:(id)sender {
	[self setNewPassword:[sender stringValue]];
	[self checkPassword];
}

- (IBAction)newRepeatInput:(id)sender {
	[self setNewRepeat:[sender stringValue]];
	[self checkPassword];
}

@end
