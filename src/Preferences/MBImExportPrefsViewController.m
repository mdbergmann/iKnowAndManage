//
//  MBImExportPrefsViewController.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 15.09.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <CocoLogger/CocoLogger.h>
#import "MBImExportPrefsViewController.h"
#import "MBItemType.h"
#import "globals.h"


@implementation MBImExportPrefsViewController

- (id)init {
	CocoLog(LEVEL_DEBUG, @"init of MBImExportPrefsViewController");
	
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR, @"cannot alloc MBImExportPrefsViewController!");
	} else {
		// init selected array
		[self setSelectedTypes:[NSArray array]];
		[self setImportFiletype:@""];
		
		// initial values
		canAdd = NO;
		canDelete = NO;
	}
	
	return self;
}

/**
\brief dealloc of this class is called on closing this document
 */
- (void)dealloc {
	CocoLog(LEVEL_DEBUG, @"dealloc of MBImExportPrefsViewController");
	
	// release selectedArray
	[self setSelectedTypes:nil];
	[self setImportFiletype:nil];
	
	// dealloc object
	[super dealloc];
}

//--------------------------------------------------------------------
//----------- bundle delegates ---------------------------------------
//--------------------------------------------------------------------
- (void)awakeFromNib {
	CocoLog(LEVEL_DEBUG, @"awakeFromNib of MBImExportPrefsViewController");
	
	if(self != nil) {
		//NSUserDefaults *defaults = userDefaults;
		
		// init the viewRect
		viewFrame = [theView frame];
	}
}

/**
 \brief return the view itself
*/
- (NSView *)theView {
	return theView;
}

- (NSRect)viewFrame {
	return viewFrame;
}

// getter and setter
- (void)setSelectedTypes:(NSArray *)array {
	[array retain];
	[selectedTypes release];
	selectedTypes = array;
}

- (NSArray *)selectedTypes {
	return selectedTypes;
}

- (void)setImportFiletype:(NSString *)string {
	[string retain];
	[importFiletype release];
	importFiletype = string;
}

- (NSString *)importFiletype {
	return importFiletype;
}

/**
 \brief if the selected array has more than 0 entries the selected button can be enabled
*/
- (BOOL)canDelete {
	return canDelete;
}

- (void)setCanDelete:(BOOL)flag {
	canDelete = flag;
}

/**
 \brief if a filetype in importFiletypeTextField has been entered, it can be added to filetypes
*/
- (BOOL)canAdd {
	return canAdd;
}

- (void)setCanAdd:(BOOL)flag {
	canAdd = flag;
}

//--------------------------------------------------------------------
//----------- NSTableView delegates ---------------------------------------
//--------------------------------------------------------------------
/**
\brief return the number of rows to be displayed in this tableview
 */
- (int)numberOfRowsInTableView:(NSTableView *)aTableView {
	NSDictionary *typesDict = [userDefaults objectForKey:MBDefaultsFileValueTypeSpecKey];
	return [[typesDict allKeys] count];
}

/**
\brief displayable object for tablecolumn and row
 */
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)row {
	NSDictionary *typesDict = [userDefaults objectForKey:MBDefaultsFileValueTypeSpecKey];

	if([[aTableColumn identifier] isEqualToString:@"filetype"]) {
		return [[typesDict allKeys] objectAtIndex:row];
	} else {
		NSString *key = [[typesDict allKeys] objectAtIndex:row];
		int type = [[typesDict objectForKey:key] intValue];
		switch(type) {
			case ExtendedTextTXTValueType:
				return @"TXT";
			case ExtendedTextRTFValueType:
				return @"RTF";
			case ExtendedTextRTFDValueType:
				return @"RTFD";
			case ImageItemValueType:
				return MBLocaleStr(@"Image");
			case FileItemValueType:
				return MBLocaleStr(@"File");
			case PDFItemValueType:
				return @"PDF";
            default:break;
        }
	}
	
	return @"test";
}

/**
\brief is it allowed to edit this cell?
 */
- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(int)row {
    return [[aTableColumn identifier] isEqualToString:@"filetype"];
}

/**
\brief NSTableViewDataSource delegate for changing a itemval of the tableview
 */
- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)row {
	if([[aTableColumn identifier] isEqualToString:@"filetype"]) {
		NSMutableDictionary *typesDict = [NSMutableDictionary dictionaryWithDictionary:[userDefaults objectForKey:MBDefaultsFileValueTypeSpecKey]];
		
		// get old value
		NSString *key = [[typesDict allKeys] objectAtIndex:(NSUInteger)row];
		id oldval = [typesDict objectForKey:key];
		
		if(![key isEqualToString:(NSString *)anObject]) {
			// insert new val
			[typesDict setObject:oldval forKey:anObject];
			// remove old key
			[typesDict removeObjectForKey:key];
		
			// replace old dict
			[userDefaults setObject:typesDict forKey:MBDefaultsFileValueTypeSpecKey];
		
			// reload tybleview
			[importFiletypesTableView reloadData];
		}
	}
}

/**
\brief is it allowed to select this row?
 */
- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(int)row {
	return YES;
}

/**
\brief the tableview selection has changed
 */
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
	// get the object
	NSTableView *tView = [aNotification object];
	
	// get the selected row
	if(tView != nil) {
		NSDictionary *typesDict = [userDefaults objectForKey:MBDefaultsFileValueTypeSpecKey];

		NSIndexSet *selectedRows = [tView selectedRowIndexes];
		NSUInteger len = [selectedRows count];
		NSMutableArray *selection = [NSMutableArray arrayWithCapacity:len];		
		if(len > 0) {
			unsigned int indexes[len];
			[selectedRows getIndexes:indexes maxCount:len inIndexRange:nil];
			
			int typebuf = 0;
			for(int i = 0;i < len;i++) {
				// get selected key
				NSString *key = [[typesDict allKeys] objectAtIndex:indexes[i]];
				typebuf = [[typesDict objectForKey:key] intValue];
				[selection addObject:key];
			}
			
			// set canDelete
			[self setCanDelete:YES];
			
			if(len == 1) {
				[importValuetypeMatrix selectCellWithTag:typebuf];
			} else {
				[importValuetypeMatrix deselectAllCells];			
			}
			
			// reload tableview
			[importFiletypesTableView reloadData];
		} else {
			[self setCanDelete:NO];
		}
		
		// set selection
		[self setSelectedTypes:selection];
	}
}

/**
\brief alter cell display of tableview according to content
 */
- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(int)row {
	// set Std Bold font for call
	NSFont *font = MBStdTableViewFont;
	[aCell setFont:font];
	// set row height according to used font
	// get font height
	double pointSize = [font pointSize];
	[aTableView setRowHeight:pointSize+5];
}

/**
 \brief sort the keys of typesDict
*/
- (void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray *)oldDescriptors {
	
}

// Actions
- (IBAction)addFiletype:(id)sender {
	// add the given filetype, no matter if it existed before
	NSMutableDictionary *typesDict = [NSMutableDictionary dictionaryWithDictionary:[userDefaults valueForKey:MBDefaultsFileValueTypeSpecKey]];
	[typesDict setObject:[NSNumber numberWithInt:FileItemValueType] forKey:importFiletype];
	
	// replace old dict
	[userDefaults setObject:typesDict forKey:MBDefaultsFileValueTypeSpecKey];
	
	// reload
	[importFiletypesTableView reloadData];
	
	// select new added row
	int row = [[typesDict allKeys] indexOfObject:importFiletype];
	[importFiletypesTableView selectRow:row byExtendingSelection:NO];
}

- (IBAction)deleteFiletype:(id)sender {
	NSMutableDictionary *typesDict = [NSMutableDictionary dictionaryWithDictionary:[userDefaults valueForKey:MBDefaultsFileValueTypeSpecKey]];
	[typesDict removeObjectsForKeys:selectedTypes];
	
	// replace old dict
	[userDefaults setObject:typesDict forKey:MBDefaultsFileValueTypeSpecKey];

	[importFiletypesTableView reloadData];
	
	// deselect all
	[importFiletypesTableView deselectAll:nil];
}

- (IBAction)changeValuetype:(id)sender {
	NSMutableDictionary *typesDict = [NSMutableDictionary dictionaryWithDictionary:[userDefaults valueForKey:MBDefaultsFileValueTypeSpecKey]];
	
	// set new value
	NSEnumerator *iter = [selectedTypes objectEnumerator];
	NSString *key = nil;
	while((key = [iter nextObject])) {
		[typesDict setObject:[NSNumber numberWithInt:[[sender selectedCell] tag]] forKey:key];
	}
	
	// replace old dict
	[userDefaults setObject:typesDict forKey:MBDefaultsFileValueTypeSpecKey];

	[importFiletypesTableView reloadData];
}

- (IBAction)importFiletypeInput:(id)sender {
	[self setImportFiletype:[sender stringValue]];
    [self setCanAdd:[importFiletype length] > 0];
}

@end
