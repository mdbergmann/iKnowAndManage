/* MBPreferenceController */

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>

@class MBDatabasePrefsViewController;
@class MBGeneralPrefsViewController;
@class MBFormatPrefsViewController;
@class MBImExportPrefsViewController;
@class MBPrivacyPrefsViewController;


#define PREFERENCE_CONTROLLER_NIB_NAME @"Preferences"

// UserDefault defines
// element and attribute std colors
#define MBDefaultsItemFgColorKey						@"MBDefaultsItemFgColorKey"
#define MBDefaultsItemBgColorKey						@"MBDefaultsItemBgColorKey"
#define MBDefaultsItemValueFgColorKey					@"MBDefaultsItemValueFgColorKey"
#define MBDefaultsItemValueBgColorKey					@"MBDefaultsItemValueBgColorKey"
// outlineview and tableview default colors
#define MBDefaultsOutlineViewBgColorKey					@"MBDefaultsOutlineViewBgColorKey"
#define MBDefaultsOutlineViewFgColorKey					@"MBDefaultsOutlineViewFgColorKey"
#define MBDefaultsTableViewBgColorKey					@"MBDefaultsTableViewBgColorKey"
#define MBDefaultsTableViewFgColorKey					@"MBDefaultsTableViewFgColorKey"
// confirmations
#define MBDefaultsDeleteConfirmationKey					@"MBDefaultsDeleteConfirmationKey"
#define MBDefaultsTrashcanDeleteConfirmationKey			@"MBDefaultsTrashcanDeleteConfirmationKey"
// search
#define MBDefaultsDoRegexSearchKey						@"MBDefaultsDoRegexSearchKey"
#define MBDefaultsSearchCaseSensitiveKey				@"MBDefaultsSearchCaseSensitiveKey"
#define MBDefaultsSearchInFiledataKey					@"MBDefaultsSearchInFiledataKey"
#define MBDefaultsSearchIncludeExternalKey				@"MBDefaultsSearchIncludeExternalKey"
//#define MBDefaultsSearchRecursiveKey					@"MBDefaultsSearchRecursiveKey"
// number of starts
#define MBDefaultsNumberOfStartsKey						@"MBDefaultsNumberOfStartsKey"

@interface MBPreferenceController : NSObject
{
	// global stuff
    IBOutlet NSButton *restoreFactorySettingsButton;
	IBOutlet NSButton *okButton;
	
	IBOutlet NSTabView *prefsTabView;
	
	// the sheet itself
	IBOutlet NSWindow *sheet;
	
	// the controllers
	IBOutlet MBDatabasePrefsViewController *databaseViewController;
	IBOutlet MBGeneralPrefsViewController *generalViewController;
	IBOutlet MBFormatPrefsViewController *formatViewController;
	IBOutlet MBImExportPrefsViewController *imExportViewController;
	IBOutlet MBPrivacyPrefsViewController *privacyViewController;
	//IBOutlet MBExternalsPrefsViewController *externalsViewController;
	
	// the window the sheet shall come up
	NSWindow *sheetWindow;
		
	// set delegate
	id delegate;
	
	// return code of sheet
	int sheetReturnCode;
	
	// margins
	int northMargin;
	int southMargin;
	int sideMargin;
	int topTabViewMargin;
}

// getter and setter
- (void)setDelegate:(id)anObject;
- (id)delegate;

// sheet Window
- (void)setSheetWindow:(NSWindow *)aWindow;
- (NSWindow *)sheetWindow;

// begin sheet
- (void)beginSheetForWindow:(NSWindow *)docWindow;
- (void)endSheet;

// sheet return code
- (int)sheetReturnCode;

// end sheet callback
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

// recalculate frame rect
//- (NSRect)frameRectForTabViewItem:(NSTabViewItem *)item;

// actions
- (IBAction)restoreFactorySettings:(id)sender;
- (IBAction)okButton:(id)sender;

@end
