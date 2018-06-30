/* MBPreferenceController */

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import <MBFormatSetterController.h>

#define PREFERENCE_SHEET_CONTROLLER_NIB_NAME @"PreferenceSheet"

// UserDefault defines
// element and attribute std colors
#define MBDefaultsElementFgColorKey						@"MBElementFgColor"
#define MBDefaultsElementBgColorKey						@"MBElementBgColor"
#define MBDefaultsAttributeFgColorKey					@"MBAttributeFgColor"
#define MBDefaultsAttributeBgColorKey					@"MBAttributeBgColor"
// outlineview and tableview default colors
#define MBDefaultsOutlineViewBgColorKey					@"MBOutlineViewBgColor"
#define MBDefaultsOutlineViewFgColorKey					@"MBOutlineViewFgColor"
#define MBDefaultsTableViewBgColorKey					@"MBTableViewBgColor"
#define MBDefaultsTableViewFgColorKey					@"MBTableViewFgColor"
// backup defaults
#define MBDefaultsBackupPathKey							@"MBBackupPath"
#define MBDefaultsBackupIntervalKey						@"MBBackupInterval"
// display
#define MBDefaultsMetalDisplayKey						@"MBMetalDisplay"
#define MBDefaultsUsePanelInfoKey						@"MBUsePanelInfo"
#define MBDefaultsMainViewAlignmentKey					@"MBMainViewAlignment"
#define MBDefaultsMaxColsForElementBrowserKey			@"MBMaxColsForElementBrowser"
#define MBDefaultsShowInfoKey							@"MBShowInfo"
// confirmations
#define MBDefaultsDeleteConfirmationKey					@"MBDeleteConfirmation"
#define MBDefaultsTrashcanDeleteConfirmationKey			@"MBTrashcanDeleteConfirmation"

@interface MBPreferenceSheetController : NSObject
{
	// global stuff
    IBOutlet NSButton *backupRestoreFactorySettingsButton;
	IBOutlet NSButton *okButton;

	// backup stuff
    IBOutlet NSButton *backupActivateButton;
    IBOutlet NSTextField *backupPathLabel;
    IBOutlet NSButton *backupPathSetButton;
    IBOutlet NSTextField *backupPathTextField;
	
	// display stuff
	IBOutlet NSButton *useMetalLookButton;
	IBOutlet NSButton *usePanelInfoButton;
	
	// boxes
	IBOutlet NSBox *numberFormatSetterBox;
	IBOutlet NSBox *currencyFormatSetterBox;
	IBOutlet NSBox *dateFormatSetterBox;

	// the sheet itself
	IBOutlet NSWindow *sheet;
	
	// the window the sheet shall come up
	NSWindow *sheetWindow;
	
	// FormatSetterController
	MBFormatSetterController *formatSetterController;
	
	// set delegate
	id delegate;
	
	// return code of sheet
	int sheetReturnCode;
}

// getter and setter
- (void)setDelegate:(id)anObject;
- (id)delegate;

// sheet Window
- (void)setSheetWindow:(NSWindow *)aWindow;
- (NSWindow *)sheetWindow;

// begin sheet
- (void)beginSheet;
- (void)endSheet;

// sheet return code
- (int)sheetReturnCode;

// end sheet callback
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

// actions
- (IBAction)backupRestoreFactorySettings:(id)sender;
- (IBAction)okButton:(id)sender;

- (IBAction)backupActivate:(id)sender;
- (IBAction)backupSetPath:(id)sender;
- (IBAction)switchMetalLook:(id)sender;
- (IBAction)switchUsePanelInfo:(id)sender;

@end
