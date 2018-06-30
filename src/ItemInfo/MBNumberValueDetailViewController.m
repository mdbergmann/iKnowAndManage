//
//  MBNumberValueDetailViewController.m
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

#import "MBNumberValueDetailViewController.h"
#import "MBNumberItemValue.h"
#import "MBFormatPrefsViewController.h"
#import "globals.h"

@implementation MBNumberValueDetailViewController

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
    // set format string for number value textfield
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [[numberTextField formatter] setDecimalSeparator:[defaults objectForKey:NSDecimalSeparator]];
    [[numberTextField formatter] setThousandSeparator:[defaults objectForKey:NSThousandsSeparator]];
}

/**
\brief set the element of which information should be shown
 no retains is made.
 */
- (void)displayInfo {
	MBNumberItemValue *itemval = (MBNumberItemValue *)currentItemValue;
	if(itemval != nil) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		// is this itemval encrypted?
		if([itemval encryptionState] != EncryptedState) {
			// first activate all stuff
			[numberTextField setEnabled:YES];
			[useGlobalFormatButton setEnabled:YES];
			[setFormatButton setEnabled:YES];
			
			if([itemval valuetype] == CurrencyItemValueType) {
				[[numberTextField formatter] setFormat:[defaults objectForKey:MBDefaultsCurrencyFormatKey]];
			} else {
				[[numberTextField formatter] setFormat:[defaults objectForKey:MBDefaultsNumberFormatKey]];
			}
			
			[useGlobalFormatButton setState:(int)[itemval useGlobalFormat]];
			// set numnber value
			[numberTextField setObjectValue:[itemval valueData]];			
		} else {
			// deactivate buttons and textfields, write encrypted to textfield
			[numberTextField setEnabled:NO];
			[useGlobalFormatButton setEnabled:NO];
			[setFormatButton setEnabled:NO];
			[numberTextField setStringValue:MBLocaleStr(@"Encrypted")];
		}
	} else {
		[useGlobalFormatButton setState:0];
		[numberTextField setStringValue:@""];
	}
}

#pragma mark - Actions

- (IBAction)acc_ValueInput:(id)sender {
	if(currentItemValue != nil) {
		[currentItemValue setValueData:[sender objectValue]];
	}	
}

/**
 \brief switch using format
*/
- (IBAction)acc_UseGlobalFormatSwitch:(id)sender {
	if(currentItemValue != nil) {
		[(MBNumberItemValue *)currentItemValue setUseGlobalFormat:[(NSButton *)sender state]];
	}	
}

- (IBAction)acc_SetFormat:(id)sender {
	// TODO
}

@end
