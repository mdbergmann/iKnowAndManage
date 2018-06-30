/* MBToolbarController */

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>

@class MBImagePopUpButton;

// segmented control identifiers for toolbaritems
#define NAVIGATION_SEGCONTROL_ITEM_KEY				@"NavItem"
#define DELETE_ITEM_KEY								@"DeleteItem"
#define ITEM_SUBMENU_ITEM_KEY						@"ItemItem"
#define ITEMVAL_SUBMENU_ITEM_KEY					@"ItemValueItem"
#define DETAILVIEW_SEGCONTROL_ITEM_KEY				@"ViewItem"
#define PREFS_ITEM_KEY								@"PrefsItem"
#define INFO_ITEM_KEY								@"InfoViewItem"
#define UP_ITEM_KEY									@"UpItem"
#define DOWN_ITEM_KEY								@"DownItem"
#define PROGRESS_ITEM_KEY							@"ProgressIndicatorItem"

@interface MBToolbarController : NSObject <NSToolbarDelegate>
{
    IBOutlet NSWindow *mainWindow;	
	// out delegate
	IBOutlet id delegate;

	// main menu items
	IBOutlet NSMenuItem *newItemMenuItem;
	IBOutlet NSMenuItem *newItemValueMenuItem;
	
	// we need a dictionary for all our toolbar identifiers
	NSMutableDictionary *tbIdentifiers;

	// popupButtons
	MBImagePopUpButton *itemMenuPopUpBotton;
	MBImagePopUpButton *itemValueMenuPopUpButton;
	
	// segmented control
	NSSegmentedControl *segmentedControl;

	// our progress indiocator
	NSProgressIndicator *progressIndicator;
}

- (void)toggleInfoView:(id)sender;

- (void)createNewItemMenu;
- (void)createNewItemValueMenu;

// progress methods
- (void)startProgressAnimation;
- (void)stopProgressAnimation;

// change main view in segmentedview
- (void)setMainViewTo:(int)viewId;

// methods
- (void)setupMainWindowToolbar;

@end

