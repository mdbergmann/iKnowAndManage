//
//  MBTextValueDetailViewController.m
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

#import "MBTextValueDetailViewController.h"
#import "MBTextItemValue.h"
#import "globals.h"

@implementation MBTextValueDetailViewController

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
}

/**
\brief set the element of which information should be shown
 no retains is made.
 */
- (void)displayInfo {
	MBTextItemValue *itemval = (MBTextItemValue *)currentItemValue;		
	if(itemval != nil) {
		// is this itemval encrypted?
		if([itemval encryptionState] != EncryptedState) {
			// set text
			[valueTextField setEnabled:YES];
			[valueTextField setStringValue:[itemval valueData]];
		} else {
			// deactivate textfield and write encrypted
			[valueTextField setEnabled:NO];
			[valueTextField setStringValue:MBLocaleStr(@"Encrypted")];
		}
	}
}

#pragma mark - NSTextField

- (void)controlTextDidChange:(NSNotification *)aNotification {
	if(currentItemValue != nil) {
		[(MBTextItemValue *)currentItemValue setValueData:[valueTextField stringValue]];        
    }
}

#pragma mark - Actions

- (IBAction)acc_TextValueInput:(id)sender {
	if(currentItemValue != nil) {
		[(MBTextItemValue *)currentItemValue setValueData:[sender stringValue]];
	}
}

@end
