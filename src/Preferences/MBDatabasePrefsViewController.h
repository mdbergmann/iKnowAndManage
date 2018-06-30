//
//  MBDatabasePrefsViewController.h
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

// backup defaults
#define MBDefaultsBackupActiveKey						@"MBDefaultsBackupActiveKey"
#define MBDefaultsBackupPathKey							@"MBDefaultsBackupPathKey"
#define MBDefaultsBackupIntervalKey						@"MBDefaultsBackupIntervalKey"
#define MBDefaultsDatabasePathKey						@"MBDefaultsDatabasePathKey"
#define MBDefaultsBackupCompressionActiveKey			@"MBDefaultsBackupCompressionActiveKey"

@interface MBDatabasePrefsViewController : NSObject {
	// backup stuff
    IBOutlet NSButton *backupActivateButton;
    IBOutlet NSTextField *backupPathLabel;
    IBOutlet NSButton *backupPathSetButton;
    IBOutlet NSTextField *backupPathTextField;
	IBOutlet NSButton *dbPathSetButton;
	IBOutlet NSTextField *dbPathTextField;
    IBOutlet NSProgressIndicator *progressIndicator;
    
	// the view
	IBOutlet NSView *theView;
	
	// initial rect
	NSRect viewFrame;
}

- (NSView *)theView;
- (NSRect)viewFrame;

- (NSNumber *)numberOfSimpleTextItemValues;
- (NSNumber *)numberOfExtendedTextItemValues;
- (NSNumber *)numberOfNumberItemValues;
- (NSNumber *)numberOfURLItemValues;
- (NSNumber *)numberOfBoolItemValues;
- (NSNumber *)numberOfCurrencyItemValues;
- (NSNumber *)numberOfFileItemValues;
- (NSNumber *)numberOfImageItemValues;
- (NSNumber *)numberOfPDFItemValues;
- (NSNumber *)sumOfItems;

- (IBAction)backupSetPath:(id)sender;
- (IBAction)dbPathSet:(id)sender;
- (IBAction)vacuumDatabase:(id)sender;

@end
