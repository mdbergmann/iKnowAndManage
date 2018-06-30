/* MBSearchViewController */

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>

@class MBSearchOutlineView;
@class MBItem;
@class MBSearchController;

// column identifiers
#define RESULT_COL_IDENTIFIER_NAME		@"name"
#define RESULT_COL_IDENTIFIER_TYPE		@"type"
//#define RESULT_COL_IDENTIFIER_VALUETYPE	@"valuetype"
//#define TYPES_COL_IDENTIFIER			@"types"

@interface MBSearchViewController : NSObject {

    IBOutlet NSButton *optionsOnOffButton;
    IBOutlet MBSearchOutlineView *resultOutlineView;
    IBOutlet NSBox *resultViewBox;
    IBOutlet NSButton *searchButton;
    IBOutlet NSButton *searchForAlarmButton;
    IBOutlet NSButton *searchForAllTypesButton;
    IBOutlet NSButton *searchForBoolButton;
    IBOutlet NSButton *searchForCurrencyButton;
    IBOutlet NSButton *searchForDateButton;
    IBOutlet NSButton *searchForETextButton;
    IBOutlet NSButton *searchForFileButton;
    IBOutlet NSButton *searchForImageButton;
    IBOutlet NSButton *searchForPDFButton;
    IBOutlet NSButton *searchForNumberButton;
    IBOutlet NSButton *searchForSTextButton;
    IBOutlet NSButton *searchForURLButton;
    IBOutlet NSPopUpButton *searchInPopUpButton;
    IBOutlet NSBox *searchOptionsBox;
    IBOutlet NSProgressIndicator *searchProgress;
    IBOutlet NSView *searchResultView;
    IBOutlet NSView *noResultView;
    IBOutlet NSView *theView;
    IBOutlet NSTextField *resultLabel;
	
	// search string
	NSString *searchString;
	
	// the current Search Item
	MBItem *searchInItem;
	
	// out searchFor Types
	NSMutableDictionary *searchForTypes;
	
	// search result
	NSArray *searchResult;

    /** store this value */
    NSRect searchOptionsBoxRect;
    
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
	
    MBSearchController *searchController;
    
	// is app terminating?
	BOOL appTerminating;
}

// the view itself
- (NSView *)theView;

// the tableView
- (NSOutlineView *)resultOutlineView;

// drag and drop
- (NSArray *)validDragAndDropPbTypes;

// the search result
- (void)setSearchResult:(NSArray *)aResult;
- (NSArray *)searchResult;

// searching
- (void)applySearchString:(NSString *)aString;

- (IBAction)allTypesSwitch:(id)sender;
- (IBAction)optionsOnOffSwitch:(id)sender;
- (IBAction)searchInItemChange:(id)sender;
- (IBAction)startSearch:(id)sender;
- (IBAction)singleTypeSwitch:(id)sender;
- (IBAction)matchTypeChange:(id)sender;

@end
