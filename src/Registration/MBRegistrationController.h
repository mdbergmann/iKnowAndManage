/* MBRegistrationController */

//  Created by Manfred Bergmann on 25.07.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>

// registration
#define MBDefaultsRegNameKey							@"MBDefaultsRegNameKey"
#define MBDefaultsSerNumKey								@"MBDefaultsSerNumKey"
#define MBDefaultsAppModeKey							@"MBDefaultsAppModeKey"
#define MBDefaultsFLDKey								@"MBDefaultsFLDKey"

// the path to the hidden reginfo file
#define PATH_TO_HIDDEN_REGFILE	[@"~/.ikam_appinfo" stringByExpandingTildeInPath]

typedef enum
{
	DemoAppMode = 0,
	BetaAppMode = 100,
	RegisteredAppMode = 4989
}MBAppMode;

enum MBRegDialogResult
{
	RegCancel = 0,
	RegOk
};

@interface MBRegistrationController : NSWindowController
{
    IBOutlet NSImageView *imageView;
    IBOutlet NSTextField *regNameLabel;
    IBOutlet NSTextField *sernumTextField;
    IBOutlet NSTextField *nameTextField;
    IBOutlet NSTextField *infoLabel;
	IBOutlet NSButton *tryButton;
	IBOutlet NSButton *registerButton;
	IBOutlet NSButton *cancelButton;
	
	NSString *serNum;
	NSString *regName;
	
	NSString *pathToRegFile;
	NSMutableDictionary *regDict;
	
	int retVal;
	
	BOOL runsModal;
	NSModalSession session;
	
	NSDate *firstLaunchDate;
	
	NSTimer *timer;
	int maxTimerSecs;
	int timerSecs;
}

+ (MBRegistrationController *)sharedRegistration;

- (void)resetControlsForModal:(BOOL)flag;
- (MBAppMode)appMode;

// create sha1 hashed appmode for saving into userdefaults
+ (NSData *)generateAppModeDataForMode:(MBAppMode)aMode;

- (int)runModal:(BOOL)flag;

- (IBAction)registerButton:(id)sender;
- (IBAction)tryButton:(id)sender;
- (IBAction)cancelButton:(id)sender;

- (IBAction)serNumInput:(id)sender;
- (IBAction)nameInput:(id)sender;

- (void)tryButtonTimer;

@end
