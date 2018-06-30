/* MBMainViewController */

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>

@class MBItemValueListViewController;
@class MBExtendedViewController;

@interface MBMainViewController : NSObject {
    IBOutlet NSWindow *mainWindow;

	// subviewcontroller
	IBOutlet MBItemValueListViewController *itemValueListViewController;
	IBOutlet MBExtendedViewController *extendedViewController;
    
    IBOutlet NSButton *openInWinBtn;
    IBOutlet NSWindow *extendedViewWindow;
    BOOL viewInWindow;
	
	// main view boxes
	IBOutlet NSBox *aboveViewBox;
	IBOutlet NSBox *extendedViewBox;
	
	// split views
	IBOutlet NSSplitView *splitView;
	// the view itself
	IBOutlet NSView *theView;
    
	IBOutlet id delegate;	// is InterfaceController

    float upperViewHeight;
	int viewState;
	float belowViewCollapseHeight;	
}

- (void)setDelegate:(id)aClass;
- (id)delegate;

// the view
- (NSView *)theView;

// view up/down methods
- (void)viewUp;
- (void)viewDown;

// the tableview from itemValueListViewController
- (NSTableView *)itemValueListView;

// searching
- (void)applySearchString:(NSString *)aString;

// KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

// actions
- (IBAction)openInWindow:(id)sender;

@end
