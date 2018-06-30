//
//  MBETextValueDetailViewController.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 08.07.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import "MBBaseDetailViewController.h"
#import "MBETextValueDetailViewController.h"
#import "MBExtendedTextItemValue.h"
#import "MBTextEditorViewController.h"
#import "globals.h"
#import "GlobalWindows.h"
#import "MBURLItemValue.h"

// NSOpenPanel context infos
extern NSString *ImportFileContext;
extern NSString *SetPathContext;
extern NSString *OpenFileWithAppContext;

@interface MBETextValueDetailViewController (privateAPI)

- (void)saveTextValue;
- (void)loadTextValue;

@end

@implementation MBETextValueDetailViewController (privateAPI)

/**
 \brief this method uses the itemvalues own method the save the data
*/
- (void)saveTextValue {
	MBExtendedTextItemValue *itemval = (MBExtendedTextItemValue *)currentItemValue;
	if(itemval != nil) {
		// get data from editor according to selected texttype
		int texttype = [itemval textType];
		NSData *data = nil;
		switch(texttype) {
			case TextTypeTXT:
				data = [editor textDataAsTXT];
				break;
			case TextTypeRTF:
				data = [editor textDataAsRTF];
				break;
			case TextTypeRTFD:
				data = [editor textDataAsRTFD];
				break;
		}
		
		// do we have data
		if(data != nil) {
			// start progress indicator
			[progressIndicator startAnimation:nil];

			// save data to target
			BOOL success = [itemval setValueDataBySavingToTarget:data];
			if(!success) {
				NSAlert *alert = [NSAlert alertWithMessageText:MBLocaleStr(@"UnableToSaveDataTitle") 
												 defaultButton:MBLocaleStr(@"OK") 
											   alternateButton:nil 
												   otherButton:nil 
									 informativeTextWithFormat:MBLocaleStr(@"UnableToSaveDataMsg")];
				[alert runModal];
			} else {
				// deactivate save button to not save again
				[saveButton setEnabled:NO];
				isSaved = YES;
			}
			
			// stop progress indicator
			[progressIndicator stopAnimation:nil];
		}
	}
}

/**
\brief this method uses the itemvalues own method the load the data
 */
- (void)loadTextValue {
	MBExtendedTextItemValue *itemval = (MBExtendedTextItemValue *)currentItemValue;
	
	// start progress indicator
	[progressIndicator startAnimation:nil];

	// load link data according to selected texttype
	int texttype = [itemval textType];
	
	NSData *data = [itemval valueDataByLoadingFromTarget];
	if(data == nil) {
		// could not load data from source
		CocoLog(LEVEL_WARN,@"[MBETextValueDetailViewController -loadTextValue] cannot load data!");
		// bring up alert sheet
		NSBeginAlertSheet(MBLocaleStr(@"Warning"),
						  MBLocaleStr(@"OK"),nil,nil,
						  [GlobalWindows mainAppWindow],nil,nil,nil,nil,
						  MBLocaleStr(@"CouldNotLoadFromLink"));
	} else {
		// set text
		if(texttype == TextTypeTXT) {
			[editor setTextDataAsTXT:data];
		} else if(texttype == TextTypeRTF) {
			[editor setTextDataAsRTF:data];
		} else if(texttype == TextTypeRTFD) {
			[editor setTextDataAsRTFD:data];
		} else {
			CocoLog(LEVEL_WARN,@"[MBETextValueDetailViewController -loadTextValue] unrecognized text type!");
		}
	}
	
	// stop progress indicator
	[progressIndicator stopAnimation:nil];
}

@end


@implementation MBETextValueDetailViewController

- (id)init {
	self = [super init];
	if(self) {
	}
	
	return self;
}

- (void)dealloc {
	// dealloc object
	[super dealloc];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // init texteditor, it should already be initialized in InterfaceController
    editor = [MBTextEditorViewController standardTextEditorController];
    // set delegate
    [editor setDelegate:self];		
}

#pragma mark - Methods

- (void)redisplayControllsForExtern:(BOOL)flag {
    [super redisplayControllesForExtern:flag];
    
	// load button
	[loadButton setEnabled:flag];
	
	// activate savebutton so that user can save to db from a link or vise versa
	[saveButton setEnabled:flag];
	isSaved = !flag;
}

- (NSString *)saveAsTempFile {
	// open with default application for this file type
	// get path to temp folder
	NSString *tempF = TMPFOLDER;
	
	// do we have a filename?
	NSString *extension = nil;
	NSString *filename = nil;
	NSURL *url = [(MBExtendedTextItemValue *)currentItemValue linkValueAsURL];
	if(url != nil) {
		filename = [MBURLItemValue pathComponentOfURL:url];
	} else {
		CocoLog(LEVEL_WARN,@"[MBETextValueDetailViewController -saveAsTempFile] have a nil url!");
	}
    
	if(filename != nil) {
		if([filename length] > 0) {
			// get pathextension
			extension = [filename pathExtension];
		}
	}
    
	// get data
	NSData *textData = nil;
	// we define extension ourself
	switch([(MBExtendedTextItemValue *)currentItemValue textType]) {
		case TextTypeTXT:
			textData = [editor textDataAsTXT];
			if((extension == nil) || ([extension length] == 0)) {
				extension = @"txt";
			}
            break;
		case TextTypeRTF:
			textData = [editor textDataAsRTF];
			if((extension == nil) || ([extension length] == 0)) {
				extension = @"rtf";
			}
            break;
		case TextTypeRTFD:
			textData = [editor textDataAsRTFD];
			if((extension == nil) || ([extension length] == 0)) {
				extension = @"rtfd";
			}
            break;				
	}
	
	// define filename 
	filename = [[NSNumber numberWithInt:[currentItemValue itemID]] stringValue];
	// generate absolute path
	NSString *absolutePath = [NSString stringWithFormat:@"%@/%@.%@",tempF,filename,extension];
	
	// save to here and open
	if(textData != nil) {
		// TODO --- use NSTask to open file, check filestate after NSTasks ends for import changed file
		[textData writeToFile:absolutePath atomically:YES];
	}
	
	return absolutePath;
}

/**
 \brief this method should be used to reread all information except the text value itself
 mainly use it if the same itemvalue should be displayed
*/
- (void)displayInfoWithPreservingTextValue {
	MBExtendedTextItemValue *itemval = (MBExtendedTextItemValue *)currentItemValue;	
	
	if(itemval != nil) {
		if([itemval encryptionState] != EncryptedState) {
			// activate them first
			[internButtonCell setEnabled:YES];
			[externButtonCell setEnabled:YES];
			[textTypePopUpButton setEnabled:YES];
			[openWithButton setEnabled:YES];
			[openWithDefaultButton setEnabled:YES];
			// disable link textfield
			[linkTextField setEnabled:YES];
			
			// handle link
			BOOL isLink = [itemval isLink];
            BOOL autoHandle = [itemval autoHandleLoadSave];
			// then activate linktextfield and link button and display the linked file instead
			[internButtonCell setState:(int)!isLink];
			[externButtonCell setState:(int)isLink];
			[linkTextField setEnabled:isLink];
			[setFromPathButton setEnabled:isLink];
			[setFromURLValuePopUpButton setEnabled:isLink];
			[autoHandleButton setEnabled:isLink];
			[autoHandleButton setState:(int)autoHandle];
			// set URL status
			[isValidURLTextField setEnabled:isLink];
			[isLocalURLTextField setEnabled:isLink];
			[isConnectableURLTextField setEnabled:isLink];
			
			// set typebutton according to type
			[textTypePopUpButton selectItemAtIndex:[itemval textType]];
			
			// populate URLs PopUpButton
			[self populateURLPopUpButton];

			// handleload save and load buttons. load if autoload is true
			if(isLink == YES) {
				// deactivate import button
				[importButton setEnabled:NO];
				
				// autload if autohandle is true
				if(autoHandle == YES) {
					[loadButton setEnabled:NO];
				} else {
					[loadButton setEnabled:YES];
				}
			} else {
				// activate import button
				[importButton setEnabled:YES];				
				[loadButton setEnabled:NO];
			}
			
			// print link
			[linkTextField setStringValue:[itemval linkValueAsString]];			
		} else {
			// deactivate all buttons
			[loadButton setEnabled:NO];
			[saveButton setEnabled:NO];
			[importButton setEnabled:NO];
			[autoHandleButton setEnabled:NO];
			[setFromPathButton setEnabled:NO];
			[setFromURLValuePopUpButton setEnabled:NO];
			[internButtonCell setEnabled:NO];
			[externButtonCell setEnabled:NO];
			[textTypePopUpButton setEnabled:NO];
			[openWithButton setEnabled:NO];
			[openWithDefaultButton setEnabled:NO];
			
			// disable link textfield
			[linkTextField setEnabled:NO];
			
			// print link
			[linkTextField setStringValue:MBLocaleStr(@"Encrypted")];			
		}
		
		[self displayURLStatusInfo];
	}	
}

/**
\brief set the element of which information should be shown
 no retains is made.
 */
- (void)displayInfo {
	// first call method that preserved text data
	[self displayInfoWithPreservingTextValue];
	
	MBExtendedTextItemValue *itemval = (MBExtendedTextItemValue *)currentItemValue;	
	if(itemval != nil) {
		isSaved = YES;
		
		if([itemval encryptionState] != EncryptedState) {
			// on loading save button is deactivated
			[saveButton setEnabled:NO];
			// set savedstatus
			[statusLabel setStringValue:MBLocaleStr(@"unchanged")];
			// empty editor textview
			[editor setTextDataAsTXT:[@"" dataUsingEncoding:NSUTF8StringEncoding]];

			// handleload save and load buttons. load if autoload is true
			BOOL isLink = [itemval isLink];
			BOOL autoHandle = [itemval autoHandleLoadSave];
			if(((isLink == YES) && (autoHandle == YES)) || (isLink == NO)) {
				// load
				[self acc_Load:nil];
			}
		}
	}
}

- (void)setCurrentItemValue:(MBExtendedTextItemValue *)aItemValue {
	// bevor switching to another itemvalue, check status of data
	if(currentItemValue != nil) {
		if(aItemValue != currentItemValue) {
			if([self hasChangedData] == YES) {
				// bring up alert panel
				NSAlert *alert = [NSAlert alertWithMessageText:MBLocaleStr(@"UnsavedTextDataTitle")
												 defaultButton:MBLocaleStr(@"Yes")
											   alternateButton:MBLocaleStr(@"No")
												   otherButton:nil 
									 informativeTextWithFormat:MBLocaleStr(@"UnsavedTextDataMsg")];
				// run modally
				int result = [alert runModal];
				if(result == NSAlertDefaultReturn) {
					// send notification to start main progressindicator
					MBSendNotifyProgressIndicationActionStarted(nil);
					
					// save extendedtext value
					[self saveWithRequester:NO];
					
					// send notification to stop main progressindicator
					MBSendNotifyProgressIndicationActionStopped(nil);
				}
			}
		}
	}
	
	// set new reference
	currentItemValue = aItemValue;
}

/**
 \brief getter for isSaved instance variable
*/
- (BOOL)isSaved {
	return isSaved;
}

/**
 \brief gets the text from the editor and checks isSaved variable
 if isSaved is NO and there is text in the view then YES is returned
*/
- (BOOL)hasChangedData {
	BOOL ret = NO;
	
	if((!isSaved) && ([[editor textDataAsRTF] length] > 0)) {
		ret = YES;
	}
	
	return ret;
}

- (void)saveWithRequester:(BOOL)withRequester {
	MBExtendedTextItemValue *itemval = (MBExtendedTextItemValue *)currentItemValue;
	
	if(itemval != nil) {
		if(withRequester == YES) {
			NSAlert *alert = [NSAlert alertWithMessageText:MBLocaleStr(@"OverwriteDataTitle")
											 defaultButton:MBLocaleStr(@"Yes")
										   alternateButton:MBLocaleStr(@"No")
											   otherButton:nil 
								 informativeTextWithFormat:MBLocaleStr(@"OverwriteDataConfirm")];
			// run modally
			if([alert runModal] == NSAlertDefaultReturn) {
				[self saveTextValue];
				// status label
				[statusLabel setStringValue:MBLocaleStr(@"unchanged")];				
			}
		} else {
			[self saveTextValue];
		}
	}	
}

#pragma mark - Actions

- (IBAction)acc_Load:(id)sender {
	if(currentItemValue != nil) {
		// check, if the text has been loaded and has been changed, then we have to bring up an requester
		if([self hasChangedData]) {
			// this conversion will cause loss of data, warn the user
			NSAlert *alert = [NSAlert alertWithMessageText:MBLocaleStr(@"SwitchToAutoLoadTitle")
											 defaultButton:MBLocaleStr(@"Yes")
										   alternateButton:MBLocaleStr(@"No")
											   otherButton:MBLocaleStr(@"Cancel") 
								 informativeTextWithFormat:MBLocaleStr(@"SwitchToAutoLoadConfirm")];
			// run modally
			int result = [alert runModal];
			if(result == NSAlertDefaultReturn) {
				// keep text, do nothing
			} else if(result == NSAlertAlternateReturn) {
				// NO, do not keep the text
				[self loadTextValue];				
			} else {
				// Cancel, set autoload back to no
				[autoHandleButton setState:0];
				// activate action
				[self acc_AutoHandleSwitch:autoHandleButton];
				
			}			
		} else {
			[self loadTextValue];
		}
	}
}

- (IBAction)acc_Save:(id)sender {
	if(currentItemValue != nil) {
		// only save with requester, if this is a external value
		if([(MBExtendedTextItemValue *)currentItemValue isLink]) {
			[self saveWithRequester:YES];
		} else {
			[self saveWithRequester:NO];
		}
	}
}

/**
 \brief switching the texttype
 
 1. if this is a link value, then switching the texttype will cause the link to be loaded again in an other value interpretation
 2. if this is no link, then switching the texttype will cause the text to be converted.
	if switching to a mightier format this is no problem and can be done without problems
	if switching to a less mighty format like txt this is a problem because not all formats are known to txt
	so in this case we will ask the user if he will really do this and we can show a preview of the resulting text
*/
- (IBAction)acc_SetTextType:(id)sender {
	// currentitemval should not be nil
	if(currentItemValue != nil) {
		// get old texttype
		int oldtype = [(MBExtendedTextItemValue *)currentItemValue textType];
		// get new texttype
		int newtype = [sender tag];
		
		if([(MBExtendedTextItemValue *)currentItemValue isLink] == NO) {
			// this is no link, so we have to do a real conversion
			// just switch and reload
			
			// for equal types we do nothing
			if(oldtype == newtype) {
				// do nothing
			} else if(newtype < oldtype) {
				BOOL doSwitch = NO;

				if([[editor textDataAsRTF] length] > 0) {
					// this conversion will cause loss of data, warn the user
					NSAlert *alert = [NSAlert alertWithMessageText:MBLocaleStr(@"ReduceETextValueTypeTitle")
													 defaultButton:MBLocaleStr(@"OK") 
												   alternateButton:MBLocaleStr(@"Cancel") 
													   otherButton:nil 
										 informativeTextWithFormat:MBLocaleStr(@"ReduceETextValueTypeConfirm")];
					// run modally
					int result = [alert runModal];
					if(result == NSAlertDefaultReturn) {
						doSwitch = YES;
					}
				}
				
				if(doSwitch) {
					// send notification to start main progressindicator
					MBSendNotifyProgressIndicationActionStarted(nil);
					
					// do convert
					if((newtype == TextTypeTXT) && ((oldtype == TextTypeRTF) || (oldtype == TextTypeRTFD))) {
						// get string representation from editor
						NSData *textData = [editor textDataAsTXT];
						
						// change texttype in value
						[(MBExtendedTextItemValue *)currentItemValue setTextType:newtype];
						// set converted textvalue
						//[(MBExtendedTextItemValue *)currentItemValue setValueData:textData];
						
						// reset text data in editor
						[editor setTextDataAsTXT:textData];
					} else if((newtype == TextTypeRTF) && (oldtype == TextTypeRTFD)) {
						// get rtf representation from editor
						NSData *rtfData = [editor textDataAsRTF];
						
						// change texttype in value
						[(MBExtendedTextItemValue *)currentItemValue setTextType:newtype];
						// set converted textvalue
						//[(MBExtendedTextItemValue *)currentItemValue setValueData:rtfData];
						
						// reset text data in editor
						[editor setTextDataAsRTF:rtfData];
					}
					
					// activate save button to not save again, user should save the text
					[saveButton setEnabled:YES];
					isSaved = NO;			
					
					// send notification to stop main progressindicator
					MBSendNotifyProgressIndicationActionStopped(nil);					
				} else {
					// nothing is converted, set popupbutton to old value
					[textTypePopUpButton selectItemAtIndex:[(MBExtendedTextItemValue *)currentItemValue textType]];
				}
			} else if(newtype == TextTypeRTF) {
				// convert txt to rtf
				// get rtf representation from editor
				NSData *rtfData = [editor textDataAsRTF];
				
				// change texttype in value
				[(MBExtendedTextItemValue *)currentItemValue setTextType:newtype];
				// set converted textvalue
				//[(MBExtendedTextItemValue *)currentItemValue setValueData:rtfData];
				
				// reset text data in editor
				[editor setTextDataAsRTF:rtfData];

				// activate save button to not save again, user should save the text
				[self textChangedNotify];
			} else if(newtype == TextTypeRTFD) {
				// convert whatever to rtf
				// get rtfd representation from editor
				NSData *rtfdData = [editor textDataAsRTFD];
				
				// change texttype in value
				[(MBExtendedTextItemValue *)currentItemValue setTextType:newtype];
				// set converted textvalue
				//[(MBExtendedTextItemValue *)currentItemValue setValueData:rtfdData];
				
				// reset text data in editor
				[editor setTextDataAsRTFD:rtfdData];

				// activate save button to not save again, user should save the text
				[self textChangedNotify];
			}
		} else {
			// set type
			[(MBExtendedTextItemValue *)currentItemValue setTextType:newtype];
			
			// this is a link, the link destination will be loaded again with another representation
			if([(MBExtendedTextItemValue *)currentItemValue autoHandleLoadSave] == YES) {
				// deactivate load button and reload
				[loadButton setEnabled:NO];
				// reload
				[self acc_Load:nil];
			} else {
				// activate load button, let user reload
				[loadButton setEnabled:YES];				
			}
		}
	}
}

#pragma mark - Notifications

- (void)textChangedNotify {
	// activate save button
	[saveButton setEnabled:YES];
	isSaved = NO;
	// status label
	[statusLabel setStringValue:MBLocaleStr(@"changed")];
}

@end
