/* MBInfoViewController */

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>

@class MBRefItem, MBCommonItem;
@class MBDateValueDetailViewController;
@class MBNumberValueDetailViewController;
@class MBBoolValueDetailViewController;
@class MBTextValueDetailViewController;
@class MBETextValueDetailViewController;
@class MBURLValueDetailViewController;
@class MBImageValueDetailViewController;
@class MBFileValueDetailViewController;
@class MBPDFValueDetailViewController;
@class MBImagePopUpButton;

@interface MBInfoViewController : NSObject {
    IBOutlet NSView *infoViewFrame;
	IBOutlet NSView *infoView;
	IBOutlet NSTabView *tabView;
	IBOutlet NSTabViewItem *infoTab;
	IBOutlet NSTabViewItem *detailsTab;
	// info stuff
    IBOutlet NSTextField *typeLabel;
    IBOutlet NSTextField *nameTextField;
	IBOutlet NSTextView *commentTextView;
	IBOutlet NSTextField *creationDateTextField;
	IBOutlet NSTextField *numberOfChildrenTextField;
	IBOutlet NSTextField *numberOfChildrenInSubtreeTextField;
	IBOutlet NSTextField *numberOfValuesTextField;
	IBOutlet NSTextField *numberOfValuesInSubtreeTextField;
	IBOutlet NSTextField *sortorderTextField;
	IBOutlet NSStepper *sortorderStepper;
	IBOutlet NSButton *exportButton;
	IBOutlet NSButton *encryptionButton;
	IBOutlet NSPopUpButton *targetPopUpButton;
	MBImagePopUpButton *encryptionPopUpButton;

	// image stuff
	NSImage *lockedImage;
	NSImage *unlockedImage;
	
	// info views of values controller
    IBOutlet MBDateValueDetailViewController *dateValueViewController;
    IBOutlet MBNumberValueDetailViewController *numberValueViewController;
	IBOutlet MBBoolValueDetailViewController *boolValueViewController;
    IBOutlet MBTextValueDetailViewController *textValueViewController;
    IBOutlet MBETextValueDetailViewController *eTextValueViewController;
	IBOutlet MBURLValueDetailViewController *urlValueViewController;
	IBOutlet MBImageValueDetailViewController *imageValueViewController;
	IBOutlet MBFileValueDetailViewController *fileValueViewController;
	IBOutlet MBPDFValueDetailViewController *pdfValueViewController;
	
	// no details view
	IBOutlet NSView *noDetailsAvailableView;
	IBOutlet NSView *noInfoAvailableView;
	IBOutlet NSView *encryptedDataView;
	
	// main menu items
	IBOutlet NSMenuItem *encryptionMenuItem;
	
    // the delegate
    IBOutlet id delegate;

	// min size of View
	NSRect viewFrame;
	
	// needed for Comment textview
	BOOL initOfTextViews;
	// the undoManager for the textviews
	NSUndoManager *textViewUndoManager;

	// the current commonitem
	BOOL isRefItem;
	MBRefItem *refItem;
	MBCommonItem *currentItem;
    	
	// current DetailViewController
	id currentDetailViewController;
}

// delegate normally is MBInterfaceController
- (void)setDelegate:(id)aDelegate;
- (id)delegate;

- (NSView *)infoView;

// display information
- (void)displayInfo;

// the frame after init
- (NSRect)viewFrame;

// TextView delegate method for undo manager
- (NSUndoManager *)undoManagerForTextView:(NSTextView *)aTextView;

// getter and setter for undoManager
- (void)setTextViewUndoManager:(NSUndoManager *)aUndoManager;
- (NSUndoManager *)textViewUndoManager;

// getter and setter
- (void)setCurrentItem:(MBCommonItem *)aItem;
- (MBCommonItem *)currentItem;

// get the current detail view controller
- (id)currentDetailViewController;

// encryption menu creation
- (void)recreateEncryptionMenu;

// for setting the ref target of a reference item
- (void)setRefTarget:(id)sender;

// actions
- (IBAction)acc_NameInput:(id)sender;
- (IBAction)acc_SortorderInput:(id)sender;
- (IBAction)acc_SortorderStepperChange:(id)sender;
- (IBAction)acc_ExportButton:(id)sender;
- (IBAction)acc_EncryptionButton:(id)sender;

@end
