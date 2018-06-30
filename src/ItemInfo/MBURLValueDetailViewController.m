//
//  MBURLValueDetailViewController.h
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

#import "MBURLValueDetailViewController.h"
#import "MBURLItemValue.h"
#import "globals.h"
#import "GlobalWindows.h"

extern NSString *SetPathContext;
NSString *OpenURLWithAppContext = @"OpenURLWithAppContext";

@interface MBURLValueDetailViewController (privateAPI)

- (void)displayURLStatusInfo;

@end

@implementation MBURLValueDetailViewController (privateAPI)

/**
 \brief displays URL status info
*/
- (void)displayURLStatusInfo {
	MBURLItemValue *itemval = (MBURLItemValue *)currentItemValue;
	if(itemval != nil) {
		if([itemval encryptionState] != EncryptedState) {
			NSString *urlStr = [[itemval valueData] absoluteString];
			if([urlStr length] > 0) {
				// valid?
				if([MBURLItemValue isValidURL:[itemval valueData]] == YES) {
					[isValidURLTextField setStringValue:MBLocaleStr(@"Yes")];			
				} else {
					[isValidURLTextField setStringValue:MBLocaleStr(@"No")];
				}
				
				// local?
				if([MBURLItemValue isLocalURL:[itemval valueData]] == YES) {
					[isLocalURLTextField setStringValue:MBLocaleStr(@"Yes")];			
				} else {
					[isLocalURLTextField setStringValue:MBLocaleStr(@"No")];
				}
				
				// connectable?
				if([MBURLItemValue isConnectableURL:[itemval valueData]] == YES) {
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

@end

@implementation MBURLValueDetailViewController

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
}

/**
\brief set the element of which information should be shown
 no retains is made.
 */
- (void)displayInfo {
	MBURLItemValue *itemval = (MBURLItemValue *)currentItemValue;		
	if(itemval != nil) {
		// is this itemvalue encrypted?
		if([itemval encryptionState] != EncryptedState) {
			// deactivate all buttons and textfields
			[openWithButton setEnabled:YES];
			[openWithDefaultButton setEnabled:YES];
			[valueTextField setEnabled:YES];
			
			// set text
			// create attributed string dict
			BOOL isConnectable = [MBURLItemValue isConnectableURL:[itemval valueData]];
			NSMutableDictionary *attribDict = [NSMutableDictionary dictionary];
			if(isConnectable == YES) {
				[attribDict setObject:[NSColor blueColor] forKey:NSForegroundColorAttributeName];
				[attribDict setObject:[NSColor blueColor] forKey:NSUnderlineColorAttributeName];
			} else {
				[attribDict setObject:[NSColor redColor] forKey:NSForegroundColorAttributeName];		
				[attribDict setObject:[NSColor redColor] forKey:NSUnderlineColorAttributeName];
			}
			[attribDict setObject:[NSNumber numberWithInt:NSUnderlineStyleSingle] forKey:NSUnderlineStyleAttributeName];
			[attribDict setObject:[NSCursor pointingHandCursor] forKey:NSCursorAttributeName];

			// create attributed string
			NSAttributedString *attribString = nil;
			
			NSURL *url = [itemval valueData];
			if(url != nil) {
				NSString *urlString = [url absoluteString];
				attribString = [[[NSAttributedString alloc] initWithString:urlString
																attributes:attribDict] autorelease];
				// do we realy have a url
				if([urlString length] > 0) {
					// activate show button
					[openWithDefaultButton setEnabled:YES];
					[openWithButton setEnabled:YES];
				} else {
					// deactivate show button
					[openWithDefaultButton setEnabled:NO];				
					[openWithButton setEnabled:NO];
				}
			} else {
				attribString = [[[NSAttributedString alloc] initWithString:@"" 
																attributes:attribDict] autorelease];
				// deactivate show button
				[openWithDefaultButton setEnabled:NO];				
				[openWithButton setEnabled:NO];
			}
			
			// display url status
			[self displayURLStatusInfo];
			
			// set textfield
			[valueTextField setObjectValue:attribString];
		} else {
			// deactivate all buttons and textfields
			[openWithButton setEnabled:NO];
			[openWithDefaultButton setEnabled:NO];
			[valueTextField setEnabled:NO];
			[valueTextField setStringValue:MBLocaleStr(@"Encrypted")];

			// display url status
			[self displayURLStatusInfo];
		}
	}
}

/** overriden from superclass */
- (void)openItemValue {
	if(currentItemValue != nil) {
		NSURL *url = [(MBURLItemValue *)currentItemValue valueData];
		if(url != nil) {
			BOOL success = [[NSWorkspace sharedWorkspace] openURL:url];
			if(success == NO) {
				// bring up alert sheet
				NSBeginAlertSheet(MBLocaleStr(@"Warning"),
								  MBLocaleStr(@"OK"),nil,nil,
								  [GlobalWindows mainAppWindow],nil,nil,nil,nil,
								  MBLocaleStr(@"URL cannot be opened!"));				
			}
		}
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
						   contextInfo:(__bridge void *)(OpenURLWithAppContext)];
	}	
}

//--------------------------------------------------------------------
//----------- OpenPanel didEndSelector -------------------------------
//--------------------------------------------------------------------
- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode contextInfo:(void *)x
{
	// order panel out
	[panel orderOut:nil];
	
	if(currentItemValue != nil)
	{
		if(x == (__bridge void *)(SetPathContext))
		{
			// check panel result
			if(returnCode == NSOKButton) 
			{
				NSString *fileToOpen = [panel filename];
				
				if(fileToOpen != nil)
				{
					// extend link to local URL
					//NSString *urlString = [NSString stringWithFormat:@"file://%@",fileToOpen];
					//[currentItemValue setLinkValueAsString:urlString];
					
					// create fileURL
					NSURL *url = [NSURL fileURLWithPath:fileToOpen];
					
					// set in textfield
					[valueTextField setStringValue:[url absoluteString]];
					
					// call action of linkTextField
					[self acc_URLValueInput:valueTextField];
				}
			}			
		}
		else if(x == (__bridge void *)(OpenURLWithAppContext))
		{
			// check panel result
			if(returnCode == NSOKButton) 
			{
				NSString *fileToOpen = [panel filename];
				
				if(fileToOpen != nil)
				{
					NSURL *url = [(MBURLItemValue *)currentItemValue valueData];
					if(url != nil)
					{
						// open
						[[NSWorkspace sharedWorkspace] openFile:[url relativePath]
												withApplication:fileToOpen 
												  andDeactivate:YES];
					}
					else
					{
						CocoLog(LEVEL_WARN, @"[MBURLValueDateinViewController -openPanelDidEnd:returnCode:contextInfo:] have no UTL!");
					}
				}
			}			
		}
	}
}

#pragma mark - Actions

- (IBAction)acc_SetURLFromPath:(id)sender {
	// set this value
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

- (IBAction)acc_URLValueInput:(id)sender {
	// set text value
	if(currentItemValue != nil) {
		NSURL *url = [NSURL URLWithString:[sender stringValue]];
		if(url == nil) {
			CocoLog(LEVEL_WARN,@"[MBURLValueDetailViewController -acc_URLValueInput:] no URL!");

			// more than one item selected
			// bring up alert sheet
			NSBeginAlertSheet(MBLocaleStr(@"Warning"),
							  MBLocaleStr(@"OK"),nil,nil,
							  [GlobalWindows mainAppWindow],nil,nil,nil,nil,
							  MBLocaleStr(@"NoURL"));
		} else {
			[(MBURLItemValue *)currentItemValue setValueData:url];
		}
		
		// display altered values
		[self displayInfo];
	}
}

- (IBAction)acc_OpenWithDefault:(id)sender {
    [self openItemValue];
}

- (IBAction)acc_OpenWith:(id)sender {
    [self openItemValueWith];
}

@end
