//
//  MBExporter.h
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 27.09.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>

@class MBCommonItem;

#define EXPORTACCESSORY_CONTROLLER_NIB_NAME		@"ExportAccessory"
#define EXPORT_IKAMARCHIVE_TYPESTRING			@"ikam"

typedef enum {
	Export_IKAM,
	Export_Native,
	Export_HTML
}MBExportFileType;

@interface MBExporter : NSObject  {
	IBOutlet NSView *accessoryView;
	IBOutlet NSBox *accessoryOptionsBox;
	IBOutlet NSView *ikamExportOptionsView;
	IBOutlet NSView *htmlExportOptionsView;
	IBOutlet NSPopUpButton *exportTypePopUpButton;
	IBOutlet NSButtonCell *exportAsLinkButtonCell;
	IBOutlet NSButtonCell *exportWithLoadingDataButtonCell;
	
	// HTML view options
	IBOutlet NSButton *htmlOptionCopyLocalExternalsButton;
	IBOutlet NSButton *htmlOptionCopyRemoteExternalsButton;
	
	int exportItemTypeIdentifier;
	int exportFileType;
	NSString *exportFileTypeString;
	NSArray *exportItems;

	NSMutableArray *exportedFilenames;

	// our mutex
	NSLock *exporterLock;
	
	// is export in progress?
	volatile BOOL exportInProgress;
	
	// flags for export
	BOOL exportLinksAsLink;
	BOOL exportIKAMArchivByDefault;
}
 
+ (MBExporter *)defaultExporter;

- (void)setExportItems:(NSArray *)items;
- (NSArray *)exportItems;

- (NSArray *)exportedFilenames;

- (BOOL)exportInProgress;

- (void)setExportLinksAsLink:(BOOL)flag;
- (BOOL)exportLinksAsLink;

- (NSString *)findNextFilenameFor:(NSString *)path;
- (NSString *)generateFilenameWithExtension:(NSString *)extension fromFilename:(NSString *)aFilename;
- (NSString *)guessFilenameFor:(MBCommonItem *)commonItem;
- (NSString *)guessFileExtensionFor:(MBCommonItem *)commonItem;
- (BOOL)exportAsIkam:(MBCommonItem *)aItem toFile:(NSString *)filename exportedFile:(NSString **)exportFilename exportedData:(NSData **)exportData;
- (BOOL)exportAsNative:(MBCommonItem *)aItem toFile:(NSString *)filename exportedFile:(NSString **)exportFilename exportedData:(NSData **)exportedData;
- (BOOL)exportAsHTML:(NSArray *)array toFile:(NSString *)filename exportedFile:(NSString **)exportFilename;
- (void)simulateExport:(NSArray *)items exportFolder:(NSString *)folderPath exportType:(int)exportType exportedFilenames:(NSArray **)filenames;
- (void)export:(NSArray *)items exportFolder:(NSString *)folderPath exportType:(int)exportType;

// normal actions
- (IBAction)exportTypeChange:(id)sender;
- (IBAction)exportAsLinkButton:(id)sender;
- (IBAction)exportWithLoadingDataButton:(id)sender;

// html export actions
- (IBAction)htmlExportOptionChange:(id)sender;

@end
