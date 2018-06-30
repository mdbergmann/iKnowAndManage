/* MBTypeListViewController */

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import <globals.h>
#import <time.h>
#import <MBImporter.h>
#import <MBExporter.h>
#import <MBSearchController.h>
#import <MBPasteboardType.h>

@interface MBTypeListViewController : NSWindowController
{
    IBOutlet NSTableView *listTableView;
	IBOutlet NSView *theView;
	
	// result label
	IBOutlet NSTextField *resultLabel;
	
	// popup button
	IBOutlet NSPopUpButton *typePopUpButton;
	
	// search field
	IBOutlet NSSearchField *searchField;
	
	// show button
	IBOutlet NSButton *showButton;
	
	// formatters
	NSNumberFormatter *numberFormatter;
	NSNumberFormatter *currencyFormatter;
	NSDateFormatter *dateFormatter;
	
	// attributed string for encrypted data
	NSAttributedString *encryptedDataString;
	
	// the current search string
	NSString *searchString;
	
	// the current data
	NSArray *currentData;
	
	NSArray *currentSelection;
	
	// is app terminating?
	BOOL appTerminating;
}

// set and get current data
- (void)setCurrentData:(NSArray *)array;
- (NSArray *)currentData;

- (NSArray *)currentSelection;

// set and get the current search string
- (void)setSearchString:(NSString *)string;
- (NSString *)searchString;

- (NSArray *)currentSortDescriptors;

- (NSView *)theView;
- (NSTableView *)tableView;

- (NSArray *)validDragAndDropPbTypes;

// actions
- (IBAction)searchInput:(id)sender;
- (IBAction)typeChange:(id)sender;
- (IBAction)showButton:(id)sender;

@end
