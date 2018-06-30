//
//  MBPrivacyPrefsViewController.h
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

#import <Cocoa/Cocoa.h>

// default password
#define MBDefaultsDefaultEncryptionPasswordKey			@"MBDefaultsDefaultEncryptionPasswordKey"

@interface MBPrivacyPrefsViewController : NSObject  {
	// the view
	IBOutlet NSView *theView;
	IBOutlet NSButton *changeButton;
    IBOutlet NSButton *newPWSequenceButton;
	IBOutlet NSSecureTextField *newPWSField;
	IBOutlet NSSecureTextField *newPWRepeatSField;
	
	NSString *newPassword;
	NSString *newRepeat;
	
	// initial rect
	NSRect viewFrame;
}

- (NSView *)theView;
- (NSRect)viewFrame;

- (void)checkPassword;

- (IBAction)changePassword:(id)sender;
- (IBAction)startNewPasswordSequence:(id)sender;
- (IBAction)newPasswordInput:(id)sender;
- (IBAction)newRepeatInput:(id)sender;

@end
