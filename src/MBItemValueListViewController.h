/* MBAttributeListViewController */

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>
#import "AMToolTipTableView.h"

@class MBInterfaceController;
@class MBItemValueListTableView;

@interface MBItemValueListViewController : NSObject <AMTableViewToolTipDataSource, NSMenuDelegate> {
    IBOutlet MBItemValueListTableView *itemValueTableView;
	IBOutlet NSView *theView;
	
	// menu stuff
	IBOutlet NSMenuItem *newItemValueMenuItem;
	IBOutlet NSMenuItem *copyMenuItem;
	IBOutlet NSMenuItem *cutMenuItem;
	IBOutlet NSMenuItem *pasteMenuItem;
	IBOutlet NSMenuItem *deleteMenuItem;
	IBOutlet NSMenuItem *exportMenuItem;
	IBOutlet NSMenuItem *importMenuItem;
	IBOutlet NSMenuItem *encryptionMenuItem;
	IBOutlet NSMenuItem *createRefMenuItem;
    IBOutlet NSMenuItem *openMenuItem;
    IBOutlet NSMenuItem *openWithMenuItem;
		
    IBOutlet NSTextField *resultLabel;
    
    IBOutlet MBInterfaceController *uiController;

    // images
    NSImage *internalDataImage;
    NSImage *externalDataImage;
    NSImage *encryptedDataImage;
    
	// the context menu
	NSMenu *normalItemMenu;

	// formatters
	NSNumberFormatter *numberFormatter;
	NSNumberFormatter *currencyFormatter;
	NSDateFormatter *dateFormatter;
	
	// attributed string for encrypted data
	NSAttributedString *encryptedDataString;
	
	// event of mouseDown from tableview
	NSEvent *mouseDownEvent;
	
	// the current search string
	NSString *searchString;
	
	// the current data
	NSArray *currentData;
	
	// the current selection
	NSArray *currentSelection;

	// is app terminating?
	BOOL appTerminating;

	// the space between the tableview and the far north
	float collapseHeight;
}

// set and get current data
- (void)setCurrentData:(NSArray *)array;
- (NSArray *)currentData;

- (NSArray *)currentSelection;

- (void)setMouseDownEvent:(NSEvent *)theEvent;
- (NSEvent *)mouseDownEvent;

- (NSArray *)currentSortDescriptors;

- (NSView *)theView;
- (NSTableView *)tableView;
- (float)collapseHeight;

- (NSArray *)validDragAndDropPbTypes;

// searching
- (void)applySearchString:(NSString *)aString;

// menus
- (void)createNormalItemMenu;

// actions from first responder
- (IBAction)menuExport:(id)sender;

@end
