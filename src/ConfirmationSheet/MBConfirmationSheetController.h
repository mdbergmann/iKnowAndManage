/* MBConfirmationSheetController */

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import <globals.h>
#import <MBPreferenceController.h>

enum SheetReturnCode
{
	SheetDefaultButtonCode = 0,
	SheetAlternateButtonCode,
	SheetOtherButtonCode
};

// Infotrmation Kind
typedef enum
{
	InfoDialogKind = 0,
	WarningDialogKind,
	AlertDialogKind
}MBConfirmationDialogKind;

// name of the nib
#define CONFIRMATION_SHEET_NIB_NAME @"ConfirmationSheet"

@interface MBConfirmationSheetController : NSObject
{
    IBOutlet NSTextField *confirmationTitle;
    IBOutlet NSTextField *confirmationText;
    IBOutlet NSButton *askAgainButton;
    IBOutlet NSButton *defaultButton;
    IBOutlet NSButton *alternateButton;
    IBOutlet NSButton *otherButton;
	IBOutlet NSImageView *imageView;
	IBOutlet NSWindow *sheet;
	
	// delegate
	id delegate;
	// the window the sheet will be brought up
	NSWindow *sheetWindow;
	// return code of sheet
	int sheetReturnCode;
	// the dialog kind
	int dialogKind;
	
	// contextInfo
	void *contextInfo;
}

+ (MBConfirmationSheetController *) standardConfirmationSheetController;

// delegate
- (void)setDelegate:(id)anObject;
- (id)delegate;
// window title
- (void)setSheetTitle:(NSString *)aTitle;
- (NSString *)sheetTitle;
// sheet Window
- (void)setSheetWindow:(NSWindow *)aWindow;
- (NSWindow *)sheetWindow;
// sheet return code
- (int)sheetReturnCode;
// confirmation message
- (void)setConfirmationMessage:(NSString *)aMessage;
// confirmation title
- (void)setConfirmationTitle:(NSString *)aMessage;

// context info
- (void)setContextInfo:(void *)contextInfo;
- (void *)contextInfo;

// get ask again state
- (BOOL)askAgainState;

// set dialog kind
- (void)setDialogKind:(MBConfirmationDialogKind)aKind;
- (MBConfirmationDialogKind)dialogKind;

// yes/no/cancel - ok/cancel - ok
- (void)setButtonTypeYesNoCancel;
- (void)setButtonTypeOkCancel;
- (void)setButtonTypeOk;

// ask again needed?
- (void)setAskAgainEnabled:(BOOL)enabled;
- (void)setAskAgainHidden:(BOOL)hidden;

// begin sheet
- (void)beginSheetWithTitle:(NSString *)aTitle 
					message:(NSString *)msg 
			  defaultButton:(NSString *)defaultTxt
			alternateButton:(NSString *)alternateTxt
				otherButton:(NSString *)otherTxt
			 askAgainButton:(NSString *)askAgainTxt
				contextInfo:(void *)contextInfo
				  docWindow:(NSWindow *)aWindow;
- (void)beginSheet;
- (void)endSheet;

// run modal for window usage
- (int)runModal;

// actions
- (IBAction)otherButton:(id)sender;
- (IBAction)alternateButton:(id)sender;
- (IBAction)defaultButton:(id)sender;
- (IBAction)switchNotAskAgain:(id)sender;

@end
