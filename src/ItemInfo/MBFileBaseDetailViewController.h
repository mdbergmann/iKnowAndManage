//
//  MBFileBaseDetailViewController.h
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 12.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MBBaseDetailViewController.h"


@interface MBFileBaseDetailViewController : MBBaseDetailViewController {
	IBOutlet NSTextField *linkTextField;
	IBOutlet NSTextField *isLocalURLTextField;
	IBOutlet NSTextField *isValidURLTextField;
	IBOutlet NSTextField *isConnectableURLTextField;
	IBOutlet NSButton *importButton;
	IBOutlet NSButton *openWithDefaultButton;
	IBOutlet NSButton *openWithButton;
	IBOutlet NSButtonCell *externButtonCell;
	IBOutlet NSButtonCell *internButtonCell;
	IBOutlet NSButton *setFromPathButton;
	IBOutlet NSPopUpButton *setFromURLValuePopUpButton;
	IBOutlet NSProgressIndicator *progressIndicator;
	IBOutlet NSButton *autoHandleButton;
	IBOutlet NSButton *loadButton;
    
}

// methods
- (NSString *)pathToFileData;
- (NSString *)saveAsTempFile;
- (void)redisplayControllesForExtern:(BOOL)flag;
- (void)populateURLPopUpButton;
- (void)displayURLStatusInfo;
- (BOOL)importFile:(NSURL *)url;

// actions
- (IBAction)acc_ExternButton:(id)sender;
- (IBAction)acc_InternButton:(id)sender;
- (IBAction)acc_LinkValueInput:(id)sender;
- (IBAction)acc_SetFromPath:(id)sender;
- (IBAction)acc_Import:(id)sender;
- (IBAction)acc_AutoHandleSwitch:(id)sender;
- (IBAction)acc_Load:(id)sender;
- (IBAction)acc_OpenWithDefault:(id)sender;
- (IBAction)acc_OpenWith:(id)sender;

@end
