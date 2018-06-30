/* MBInterfaceController */

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>

@class MBMainMenuController;
@class MBToolbarController;
@class MBItemOutlineViewController;
@class MBMainViewController;
@class MBSearchViewController;
@class MBInfoViewController;

enum PasteboardAction {
	PB_COPY_ACTION = 1,
	PB_CUT_ACTION
};

@interface MBInterfaceController : NSObject {
    IBOutlet NSWindow *mainWindow;
    IBOutlet NSTextField *statusTextField;
	
	// main controllers
    IBOutlet MBMainMenuController *mainMenuController;
    IBOutlet MBToolbarController *toolbarController;

	// main itemview controller
	IBOutlet MBItemOutlineViewController *itemOutlineViewController;
	IBOutlet MBMainViewController *mainViewController;
	IBOutlet MBSearchViewController *searchViewController;
	IBOutlet MBInfoViewController *infoViewController;
	
	// main view boxes
	IBOutlet NSBox *mainRightSideBox;
	IBOutlet NSBox *itemOutlineViewBox;
	
	// menu stuff
	IBOutlet NSMenuItem *menuItemNewItem;
	IBOutlet NSMenuItem *menuItemNewItemValue;
	IBOutlet NSMenuItem *menuItemFromTemplate;
	IBOutlet NSMenuItem *menuItemEnDecryption;
    IBOutlet NSMenuItem *menuItemValueOpen;
    IBOutlet NSMenuItem *menuItemValueOpenWith;
	
	// split views
	IBOutlet NSSplitView *mainVertSplitView;
		
	IBOutlet id delegate;	// should be MBAppController
	
    // dragged items
    NSArray *draggingItems;
    
    /** the current selected main view controller */
    id currentContentViewController;

	// stack for global progress indicator
	int startedProgressTrackingActions;
}

// take undoManager from 
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window;

// MBToolbarController delegate methods
- (void)openPreferenceSheet;
- (void)changeMainViewTo:(NSNumber *)viewId;
- (void)viewUp;
- (void)viewDown;

- (void)setDelegate:(id)aClass;
- (id)delegate;

- (void)setDraggingItems:(NSArray *)items;
- (NSArray *)draggingItems;

// pasteboard methods
- (void)writeDataToPasteboard:(NSPasteboard *)pb forAction:(int)aAction;
- (void)readDataFromPasteboard:(NSPasteboard *)pb;

// KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

// notification actions
- (void)templatesAltered:(NSNotification *)aNotification;

// actions
- (IBAction)searchInput:(id)sender;

@end

/**
 \brief menu actions performed by interface controller
*/
@interface MBInterfaceController (menuactions)

// saveDocument:
- (IBAction)saveDocument:(id)sender;
// help menu
- (IBAction)showHelp:(id)sender;
// print actions
- (IBAction)print:(id)sender;
// pasteboard actions
- (IBAction)cut:(id)sender;
- (IBAction)copy:(id)sender;
- (IBAction)paste:(id)sender;
- (IBAction)delete:(id)sender;
// menu Actions
- (IBAction)menuActivateDetailView:(id)sender;
- (IBAction)menuActivateSearchView:(id)sender;
- (IBAction)menuEmptyTrashcan:(id)sender;
// new Item / ItemValue menu
- (IBAction)menuNewItem:(id)sender;
- (IBAction)menuNewItemValue:(id)sender;
- (IBAction)menuNewFromTemplate:(id)sender;
// template
- (IBAction)menuDefineAsTemplate:(id)sender;
// Reference
- (IBAction)menuCreateRef:(id)sender;
// info view
- (IBAction)menuToggleInfoView:(id)sender;
// import export
- (IBAction)menuExport:(id)sender;
- (IBAction)menuImport:(id)sender;
// open and open with
- (IBAction)menuOpenItem:(id)sender;
- (IBAction)menuOpenItemWith:(id)sender;
// encryption menu
- (IBAction)menuEncryptWithDefaultPassword:(id)sender;
- (IBAction)menuEncryptWithCustomPassword:(id)sender;
- (IBAction)menuDecrypt:(id)sender;
// buy online menu
- (IBAction)menuBuyOnline:(id)sender;
// give feedback
- (IBAction)menuGiveFeedback:(id)sender;

@end
