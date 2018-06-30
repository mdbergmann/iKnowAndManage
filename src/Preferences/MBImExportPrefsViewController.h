//
//  MBImExportPrefsViewController.h
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

#import <Cocoa/Cocoa.h>

// filetypes
#define MBDefaultsFileValueTypeSpecKey					@"MBDefaultsFileValueTypeSpecKey"
// im/export stuff
#define MBDefaultsExportLinksAsLinkKey					@"MBDefaultsExportLinksAsLinkKey"
#define MBDefaultsExportTypeKey							@"MBDefaultsExportTypeKey"
#define MBDefaultsImportAsLinkKey						@"MBDefaultsImportAsLinkKey"
#define MBDefaultsImportRecursiveKey					@"MBDefaultsImportRecursiveKey"
#define MBDefaultsImportAllAsFilesKey					@"MBDefaultsImportAllAsFilesKey"
#define MBDefaultsImportWithAutoloadKey					@"MBDefaultsImportWithAutoloadKey"
// html export
#define MBDefaultsHTMLExportDefaultsOptionsKey			@"MBDefaultsHTMLExportDefaultsOptionsKey"

@interface MBImExportPrefsViewController : NSObject 
{
	// outlets
	IBOutlet NSButton *exportAsIkamArchivButton;
	IBOutlet NSButton *exportLinksAsLinkButton;
	IBOutlet NSButton *importAsLinkButton;
	IBOutlet NSButton *importRecursiveButton;
	IBOutlet NSButton *importAsFilevalueButton;
	IBOutlet NSButton *importWithAutoloadButton;
	IBOutlet NSButton *plusButton;
	IBOutlet NSButton *minusButton;
	IBOutlet NSTextField *importFiletypeTextField;
	IBOutlet NSMatrix *importValuetypeMatrix;
	IBOutlet NSTableView *importFiletypesTableView;
	// the view
	IBOutlet NSView *theView;

	// the current selected filetypes
	NSArray *selectedTypes;
	NSString *importFiletype;
	
	BOOL canAdd;
	BOOL canDelete;
	
	// initial rect
	NSRect viewFrame;
}

// getter and setter
- (void)setSelectedTypes:(NSArray *)array;
- (NSArray *)selectedTypes;
- (void)setImportFiletype:(NSString *)string;
- (NSString *)importFiletype;
- (void)setCanDelete:(BOOL)flag;
- (BOOL)canDelete;
- (void)setCanAdd:(BOOL)flag;
- (BOOL)canAdd;

- (NSView *)theView;
- (NSRect)viewFrame;

// Actions
- (IBAction)addFiletype:(id)sender;
- (IBAction)deleteFiletype:(id)sender;
- (IBAction)changeValuetype:(id)sender;
- (IBAction)importFiletypeInput:(id)sender;

@end
