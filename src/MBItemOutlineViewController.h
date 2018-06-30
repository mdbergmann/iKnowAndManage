/* MBItemOutlineViewController */

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>

// column identifiers
#define COL_IDENTIFIER_ITEM_NAME	@"name"

@class MBInterfaceController;
@class MBItemOutlineView;

@interface MBItemOutlineViewController : NSObject <NSMenuDelegate, NSOutlineViewDelegate, NSOutlineViewDataSource> {
    IBOutlet id delegate;
    IBOutlet NSView *itemOutlineView;
    IBOutlet MBItemOutlineView *outlineView;

	// menu stuff
	IBOutlet NSMenuItem *newItemMenuItem;
	IBOutlet NSMenuItem *newItemValueMenuItem;
	IBOutlet NSMenuItem *templateMenuItem;
	IBOutlet NSMenuItem *copyMenuItem;
	IBOutlet NSMenuItem *cutMenuItem;
	IBOutlet NSMenuItem *pasteMenuItem;
	IBOutlet NSMenuItem *deleteMenuItem;
	IBOutlet NSMenuItem *emptyTrashMenuItem;
	IBOutlet NSMenuItem *defineAsTemplateMenuItem;
	IBOutlet NSMenuItem *createRefMenuItem;
	IBOutlet NSMenuItem *exportMenuItem;
	IBOutlet NSMenuItem *importMenuItem;

    IBOutlet MBInterfaceController *uiController;
    
	// the context menu
	NSMenu *normalItemMenu;
	NSMenu *trashcanItemMenu;
	NSMenu *templateItemMenu;
	NSMenu *importItemMenu;
	 
	// images
	NSImage *stdItemImage;
	NSImage *itemRefImage;
	NSImage *tableItemImage;
	NSImage *rootTemplateItemImage;
	NSImage *templateItemImage;
	NSImage *rootContactItemImage;
	NSImage *importItemImage;
	NSImage *contactItemImage;
	NSImage *trashcanFullItemImage;
	NSImage *trashcanEmptyItemImage;

	// event of mouseDown from tableview
	NSEvent *mouseDownEvent;
	
	// the current selection
	NSArray *currentSelection;

	// is app terminating?
	BOOL appTerminating;
}

- (void)setMouseDownEvent:(NSEvent *)theEvent;
- (NSEvent *)mouseDownEvent;

- (NSView *)itemOutlineView;
- (NSOutlineView *)outlineView;

- (NSArray *)currentSelection;

- (NSArray *)validDragAndDropPbTypes;

// menus
- (void)createNormalItemMenu;
- (void)createTrashcanItemMenu;
- (void)createTemplateItemMenu;
- (void)createImportItemMenu;

// actions from first responder
- (IBAction)menuExport:(id)sender;

@end
