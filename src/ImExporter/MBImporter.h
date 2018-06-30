//
//  MBImporter.h
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
#import "MBExtendedTextItemValue.h"

@class MBItem;

#define IMPORTACCESSORY_CONTROLLER_NIB_NAME @"ImportAccessory"

@interface MBImporter : NSObject  {
	IBOutlet NSButton *importAsLinkButton;
	IBOutlet NSButton *importRecursiveButton;
	IBOutlet NSButton *importWithAutoloadButton;
	IBOutlet NSButtonCell *importAllAsFileValueButtonCell;
	IBOutlet NSButtonCell *importAccordingToFiletypesButtonCell;
	IBOutlet NSMatrix *buttonMatrix;
	// the view
	IBOutlet NSView *accessoryView;
	
	// lock for locking reentrant stuff
	NSLock *importerLock;
	
	BOOL importAsLink;
	BOOL importWithAutoload;
	BOOL importRecursive;
	BOOL importAllAsFileValue;
	
	// buffer
	MBItem *targetItem;
}

+ (MBImporter *)defaultImporter;

// data import methods
- (void)urlValueImport:(NSURL *)url toItem:(MBItem *)item asTransaction:(BOOL)transact;
- (void)pdfValueImport:(NSData *)pdfData toItem:(MBItem *)item asTransaction:(BOOL)transact;
- (void)eTextValueImport:(NSData *)textData toItem:(MBItem *)item forType:(MBTextType)type asTransaction:(BOOL)transact;

// file import methods
- (void)ikamImport:(NSString *)file toItem:(MBItem *)item asTransaction:(BOOL)transact;
- (void)fileImport:(NSString *)file toItem:(MBItem *)item asTransaction:(BOOL)transact;

// this method will bring up file panels and call the batchimport
- (void)fileValueImport:(NSArray *)filenames toItem:(MBItem *)item;

// actions
- (IBAction)importAsLinkSwitch:(id)sender;
- (IBAction)importWithAutoloadSwitch:(id)sender;
- (IBAction)importRecursiveSwitch:(id)sender;
- (IBAction)importAllAsFileValue:(id)sender;
- (IBAction)importAccordingToFiletypes:(id)sender;

@end
