//
//  MBFileBaseDetailViewController.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 12.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MBFileBaseDetailViewController.h"
#import "MBFileItemValue.h"
#import "globals.h"
#import "MBURLItemValue.h"
#import "MBItemBaseController.h"
#import "GlobalWindows.h"
#import "MBImageItemValue.h"

// NSOpenPanel context infos
NSString *ImportFileContext = @"ImportFileContext";
NSString *SetPathContext = @"SetPathContext";
NSString *OpenFileWithAppContext = @"OpenFileWithAppContext";

@implementation MBFileBaseDetailViewController

- (id)init {
    self = [super init];
    if(self) {
    
    }
    
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)awakeFromNib {
    [progressIndicator setUsesThreadedAnimation:YES];
}

#pragma mark - Methods

- (void)displayInfo {
	MBFileItemValue *itemval = (MBFileItemValue *)currentItemValue;	
	if(itemval != nil) {
		if([itemval encryptionState] != EncryptedState) {
			[internButtonCell setEnabled:YES];
			[externButtonCell setEnabled:YES];
			[openWithButton setEnabled:YES];
			[openWithDefaultButton setEnabled:YES];
			[linkTextField setEnabled:YES];
            
			// check for link
			BOOL isLink = [itemval isLink];
            // then activate linktextfield and link button and display the linked file instead
			[self redisplayControllesForExtern:isLink];			
			// create url value menu
			[self populateURLPopUpButton];
            
			// print link
			NSString *linkValue = [itemval linkValueAsString];
			[linkTextField setStringValue:linkValue];
			
			if([linkValue length] > 0) {
				if(!isLink) {
					[importButton setEnabled:YES];
				}
			}            
		} else {
			// deactivate all buttons
			[importButton setEnabled:NO];
			[setFromPathButton setEnabled:NO];
			[setFromURLValuePopUpButton setEnabled:NO];
			[internButtonCell setEnabled:NO];
			[externButtonCell setEnabled:NO];
			[openWithButton setEnabled:NO];
			[openWithDefaultButton setEnabled:NO];
			[linkTextField setEnabled:NO];
			[linkTextField setStringValue:MBLocaleStr(@"Encrypted")];			
		}
		
		// display URL status
		[self displayURLStatusInfo];		
	}
}

- (NSString *)pathToFileData {
	// only save to tempdir if we are internal
	NSString *absolutePath = nil;
	
	BOOL isLink = [(MBFileItemValue *)currentItemValue isLink];
	if(isLink == NO) {
		// save tempfile to tmpdir
		absolutePath = [self saveAsTempFile];
	} else {
		NSURL *url = [(MBFileItemValue *)currentItemValue linkValueAsURL];
		if([url isFileURL]) {
			// get absolutePath from link
			absolutePath = [MBURLItemValue pathComponentOfURL:url];
		} else {
			absolutePath = [self saveAsTempFile];
		}
	}
	
	return absolutePath;
}

- (NSString *)saveAsTempFile {
	// open with default application for this file type
	// get path to temp folder
	NSString *tempF = TMPFOLDER;	
	NSString *extension = nil;
	NSString *filename = nil;
	NSURL *url = [(MBFileItemValue *)currentItemValue linkValueAsURL];
	if(url != nil) {
		filename = [MBURLItemValue pathComponentOfURL:url];
	} else {
		CocoLog(LEVEL_WARN, @"[MBFileBaseValueDetailViewController -saveAsTempFile] have a nil url!");
	}
	
	if(filename != nil) {
		if([filename length] > 0) {
			// get pathextension
			extension = [filename pathExtension];
		}
	}
	
	// get data
	NSData *data = [(MBFileItemValue *)currentItemValue valueDataByLoadingFromTarget];
	// define filename 
	filename = [[NSNumber numberWithInt:[currentItemValue itemID]] stringValue];
	NSString *absolutePath = nil;
	if(extension != nil) {
		// generate absolute path
		absolutePath = [NSString stringWithFormat:@"%@/%@.%@",tempF,filename,extension];
	} else {
		// generate absolute path
		absolutePath = [NSString stringWithFormat:@"%@/%@",tempF,filename];	
	}
	
	// save to here and open
	if(data != nil) {
		// TODO --- use NSTask to open file, check filestate after NSTasks ends for import changed file
		[data writeToFile:absolutePath atomically:YES];
	}
	
	return absolutePath;
}

/**
 \brief redisplay or displays, enables or disables all controlls that are addicted to internal/external stuff
 */
- (void)redisplayControllesForExtern:(BOOL)flag {
	// radiobuttons
	[internButtonCell setState:(int)!flag];
	[externButtonCell setState:(int)flag];
	// handle intern/extern addicted stuff
	[importButton setEnabled:!flag];
	[setFromPathButton setEnabled:flag];
	[setFromURLValuePopUpButton setEnabled:flag];
	[linkTextField setEnabled:flag];
	// set URL status
	[isValidURLTextField setEnabled:flag];
	[isLocalURLTextField setEnabled:flag];
	[isConnectableURLTextField setEnabled:flag];
	// autohandlebutton
	[autoHandleButton setEnabled:flag];
	[autoHandleButton setState:(int)[(MBFileItemValue *)currentItemValue autoHandleLoadSave]];
	[self acc_AutoHandleSwitch:autoHandleButton];
	// load button
	[loadButton setEnabled:flag];
}

/**
 \brief populates the URL PopUpButton
 */
- (void)populateURLPopUpButton {
	// build URL Value structure
	NSMenu *menu = [[NSMenu alloc] init];
	NSMenuItem *menuItem = [[NSMenuItem alloc] init];
	[menuItem setTitle:@"URLs"];
	[menu addItem:menuItem];
	[menuItem release];
	
	// give our menu
	MBItemBaseController *ibc = itemController;
	[ibc generateValueMenu:&menu 
			  forValuetype:URLItemValueType 
					ofItem:[ibc rootItem] 
			withMenuTarget:self 
			withMenuAction:@selector(urlItemValueSelect:)];
	// set menu in PopUpButton
	[setFromURLValuePopUpButton setMenu:menu];
	[menu release];
}

/**
 \brief displays URL status info
 */
- (void)displayURLStatusInfo {
	MBFileItemValue *itemval = (MBFileItemValue *)currentItemValue;
	if(itemval != nil) {
		if([itemval encryptionState] != EncryptedState) {
			NSString *urlStr = [[itemval linkValueAsURL] absoluteString];
			if([urlStr length] > 0) {
				// valid?
				if([MBURLItemValue isValidURL:[itemval linkValueAsURL]]) {
					[isValidURLTextField setStringValue:MBLocaleStr(@"Yes")];			
				} else {
					[isValidURLTextField setStringValue:MBLocaleStr(@"No")];
				}
				
				// local?
				if([MBURLItemValue isLocalURL:[itemval linkValueAsURL]]) {
					[isLocalURLTextField setStringValue:MBLocaleStr(@"Yes")];			
				} else {
					[isLocalURLTextField setStringValue:MBLocaleStr(@"No")];
				}
				
				// connectable?
				if([MBURLItemValue isConnectableURL:[itemval linkValueAsURL]]) {
					[isConnectableURLTextField setStringValue:MBLocaleStr(@"Yes")];			
				} else {
					[isConnectableURLTextField setStringValue:MBLocaleStr(@"No")];
				}
			}
		} else {
			// set values to unknown
			[isValidURLTextField setStringValue:MBLocaleStr(@"Unknown")];
			[isLocalURLTextField setStringValue:MBLocaleStr(@"Unknown")];
			[isConnectableURLTextField setStringValue:MBLocaleStr(@"Unknown")];
		}
	}
}

/**
 \brief import fiel with url
 @return YES on success, NO on failure
 */
- (BOOL)importFile:(NSURL *)url {
	BOOL ret = NO;
	BOOL isRegularFile = YES;
	
	// get fileattributes
	NSFileManager *fm = [NSFileManager defaultManager];
	// check, if this is a local url
	if([url isFileURL]) {
		NSString *path = [MBURLItemValue pathComponentOfURL:url];
		NSDictionary *fileAttribs = [fm fileAttributesAtPath:path traverseLink:YES];
		if(fileAttribs != nil) {
			// check for filetype
			NSString *type = [fileAttribs valueForKey:NSFileType];
			if([type isEqualToString:NSFileTypeRegular] == YES) {
				isRegularFile = YES;
				[(MBFileItemValue *)currentItemValue setFileAttributesDict:fileAttribs];
			} else {
				isRegularFile = NO;
			}
		} else {
			CocoLog(LEVEL_WARN, @"[MBFileBaseValueInfoController -importFile:] cannot get file attributes of file: %@!",path);
		}
	} else {
		CocoLog(LEVEL_WARN, @"[MBFileBaseValueInfoController -importFile:] file is external url, cannot collect file attributes!");
	}
    
	
	// if this is a link, do not import filedata
	// otherwise import filedata to db immidiately
	if([(MBFileItemValue *)currentItemValue isLink] == NO) {
		// check, if file a regular file
		if(isRegularFile == YES) {
			NSData *fileData = [NSData dataWithContentsOfURL:[(MBFileItemValue *)currentItemValue linkValueAsURL]];
			if(fileData != nil) {
				// write do db
				[(MBFileItemValue *)currentItemValue setValueData:fileData];
				ret = YES;
			} else {
				CocoLog(LEVEL_WARN,@"[MBFileBaseValueDetailViewController -importFile:] filedata is nil!");
				ret = NO;
			}
		} else {
			CocoLog(LEVEL_WARN,@"[MBFileBaseValueDetailViewController -importFile:] no regular file!");		
			// bring up alert
            NSAlert *alert = [NSAlert alertWithMessageText:MBLocaleStr(@"Warning") 
                                             defaultButton:MBLocaleStr(@"OK") 
                                           alternateButton:nil 
                                               otherButton:nil 
                                 informativeTextWithFormat:MBLocaleStr(@"NoRegularFile")];
            [alert runModal];
		}
	}
	
	return isRegularFile;
}

/** overriden from superclass */
- (void)openItemValue {
	NSString *absolutePath = [self pathToFileData];	
	if(absolutePath != nil) {
		// open with default application and remove tempfile after that
		[[NSWorkspace sharedWorkspace] openTempFile:absolutePath];
	} else {
		CocoLog(LEVEL_WARN,@"[MBFileValueDetailViewController -acc_OpenWithDefault:] absolutePath is nil!");
	}	
}

/** overriden from superclass */
- (void)openItemValueWith {
	// set this value
	if(currentItemValue != nil) {
		NSOpenPanel *oPanel = [NSOpenPanel openPanel];
		// run openpanel as a sheet
		[oPanel beginSheetForDirectory:nil 
								  file:nil 
								 types:nil 
						modalForWindow:[GlobalWindows mainAppWindow] 
						 modalDelegate:self
						didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:)
						   contextInfo:(__bridge void *)(OpenFileWithAppContext)];
	}		
}

#pragma mark - Actions

/**
 \brief action for URLMenuItems
 */
- (void)urlItemValueSelect:(id)sender {
	// get URL value
	MBURLItemValue *urlVal = (MBURLItemValue *)[itemController commonItemForId:[sender tag]];
	if(urlVal != nil) {
		[linkTextField setStringValue:[urlVal valueDataAsString]];
		// do set action
		[self acc_LinkValueInput:linkTextField];
	}
}

- (IBAction)acc_ExternButton:(id)sender {
	if(currentItemValue != nil) {
		[(MBFileItemValue *)currentItemValue setIsLink:YES];
		
		// TODO --- ask user to import the former external file
		// if we have a link value delete it
		[(MBFileItemValue *)currentItemValue setLinkValueAsString:@""];
		[linkTextField setStringValue:@""];
		
		// empty fileattributes
		[(MBFileItemValue *)currentItemValue setFileAttributesDict:[NSDictionary dictionary]];
		
		[self redisplayControllesForExtern:YES];
		[self displayURLStatusInfo];
	}
}

- (IBAction)acc_InternButton:(id)sender {
	if(currentItemValue != nil) {
		[(MBFileItemValue *)currentItemValue setIsLink:NO];
		
		// TODO --- ask user to import the former external file
		// if we have a link value delete it
		[(MBFileItemValue *)currentItemValue setLinkValueAsString:@""];
		[linkTextField setStringValue:@""];
		
		// empty fileattributes
		[(MBFileItemValue *)currentItemValue setFileAttributesDict:[NSDictionary dictionary]];
        
		[self redisplayControllesForExtern:NO];
		[self displayURLStatusInfo];
	}
}

- (IBAction)acc_SetFromPath:(id)sender {
	if(currentItemValue != nil) {
		NSOpenPanel *oPanel = [NSOpenPanel openPanel];
		[oPanel beginSheetForDirectory:nil 
								  file:nil 
								 types:nil 
						modalForWindow:[GlobalWindows mainAppWindow] 
						 modalDelegate:self
						didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:)
						   contextInfo:(__bridge void *)(SetPathContext)];
	}	
}

- (IBAction)acc_Import:(id)sender {
	if(currentItemValue != nil) {
		NSOpenPanel *oPanel = [NSOpenPanel openPanel];
		[oPanel beginSheetForDirectory:nil 
								  file:nil 
								 types:nil 
						modalForWindow:[GlobalWindows mainAppWindow] 
						 modalDelegate:self
						didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:)
						   contextInfo:(__bridge void *)(ImportFileContext)];
	}	
}

- (IBAction)acc_AutoHandleSwitch:(id)sender {
	// set this value
	if(currentItemValue != nil) {
		BOOL autoHandle = (BOOL)[(NSButton *)sender state];
		[(MBFileItemValue *)currentItemValue setAutoHandleLoadSave:autoHandle];
		
		if(autoHandle) {
			// load data imidiately
			[self acc_Load:nil];
		}
		
		// de- or activate load and save buttons
		[loadButton setEnabled:!autoHandle];
		//[saveButton setEnabled:autoHandle];
	}
}

- (IBAction)acc_LinkValueInput:(id)sender {
	if(currentItemValue != nil) {
		if([[sender stringValue] length] > 0) {
			NSString *value = [sender stringValue];
			[(MBFileItemValue *)currentItemValue setLinkValueAsString:value];				
			
			// display URL status
			[self displayURLStatusInfo];
			
			// do load automatically
			if(([(MBFileItemValue *)currentItemValue autoHandleLoadSave] == YES) || ([(MBFileItemValue *)currentItemValue isLink] == NO)) {
				[self acc_Load:nil];
			}
		}
	}		
}

- (IBAction)acc_Load:(id)sender {}

- (IBAction)acc_Save:(id)sender {}

- (IBAction)acc_OpenWithDefault:(id)sender {
    [self openItemValue];
}

- (IBAction)acc_OpenWith:(id)sender {
    [self openItemValueWith];
}

#pragma mark - OpenPanel delegate

- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode contextInfo:(void *)x {
	// order panel out
	[panel orderOut:nil];
	if(currentItemValue != nil) {
		if(x == (__bridge void *)(ImportFileContext)) {
			// check panel result
			if(returnCode == NSOKButton)  {
				NSString *fileToOpen = [panel filename];
				if(fileToOpen != nil) {
					// file type
                    NSString *type = [fileToOpen pathExtension];
                    
                    NSData *data = [NSData dataWithContentsOfFile:fileToOpen];
                    if(data != nil) {
                        [(MBFileItemValue *)currentItemValue setValueData:data];
                    }
                    
                    if([currentItemValue isKindOfClass:[MBImageItemValue class]]) {
                        [(MBImageItemValue *)currentItemValue setImageType:type];
                        if(data != nil) {
                            // create NSBitmapImageRep
                            NSBitmapImageRep *bitmapRep = [NSBitmapImageRep imageRepWithData:data];
                            // save size
                            [(MBImageItemValue *)currentItemValue setImageSize:NSMakeSize([bitmapRep pixelsWide],[bitmapRep pixelsHigh])];
                            // create a thumbnail image
                            NSImage *thumb = [(MBImageItemValue *)currentItemValue generateThumbnailOfImageRep:bitmapRep];
                            if(thumb != nil) {
                                // save thumbimage to db
                                [(MBImageItemValue *)currentItemValue setThumbImage:thumb];
                            }
                        }
                    }                    
                    
					// create fileURL
					NSURL *url = [NSURL fileURLWithPath:fileToOpen];
                    
					// try to import stuff
					BOOL import = [self importFile:url];
					if(import == YES) {
						// set in textfield
						[linkTextField setStringValue:[url absoluteString]];
						// call action of linkTextField
						[self acc_LinkValueInput:linkTextField];
					}
				}
			}
		} else if(x == (__bridge void *)(SetPathContext)) {
			// check panel result
			if(returnCode == NSOKButton)  {
				NSString *fileToOpen = [panel filename];
				if(fileToOpen != nil) {
					// file type
                    NSString *type = [fileToOpen pathExtension];
                    
                    // Image?
                    if([currentItemValue isKindOfClass:[MBImageItemValue class]]) {
                        [(MBImageItemValue *)currentItemValue setImageType:type];
                        NSData *data = [NSData dataWithContentsOfFile:fileToOpen];
                        if(data != nil) {
                            [(MBFileItemValue *)currentItemValue setValueData:data];
                        }
                    
                        // set in db
                        [(MBImageItemValue *)currentItemValue setImageType:type];
                        if(data != nil) {
                            // create NSBitmapImageRep
                            NSBitmapImageRep *bitmapRep = [NSBitmapImageRep imageRepWithData:data];
                            // save size
                            [(MBImageItemValue *)currentItemValue setImageSize:NSMakeSize([bitmapRep pixelsWide],[bitmapRep pixelsHigh])];
                            // create a thumbnail image
                            NSImage *thumb = [(MBImageItemValue *)currentItemValue generateThumbnailOfImageRep:bitmapRep];
                            if(thumb != nil) {
                                // save thumbimage to db
                                [(MBImageItemValue *)currentItemValue setThumbImage:thumb];
                            }
                        }
                    }                    
                    
					// create fileURL
					NSURL *url = [NSURL fileURLWithPath:fileToOpen];
					
					// set in textfield
					[linkTextField setStringValue:[url absoluteString]];
					
					// call action of linkTextField
					[self acc_LinkValueInput:linkTextField];
				}
			}			
		} else if(x == (__bridge void *)(OpenFileWithAppContext)) {
			// check panel result
			if(returnCode == NSOKButton)  {
				NSString *fileToOpen = [panel filename];
				if(fileToOpen != nil) {
					NSString *absolutePath = [self pathToFileData];
					if(absolutePath != nil) {
						// open
						[[NSWorkspace sharedWorkspace] openFile:absolutePath 
												withApplication:fileToOpen 
												  andDeactivate:YES];
					}
				}
			}			
		}
        
        [self displayInfo];
	}
}

@end
