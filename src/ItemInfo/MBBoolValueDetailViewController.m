//
//  MBBoolValueDetailViewController.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 20.07.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <CocoLogger/CocoLogger.h>
#import "MBBoolValueDetailViewController.h"
#import "MBBoolItemValue.h"
#import "globals.h"

@implementation MBBoolValueDetailViewController

/**
\brief init is called after -alloc. some initialization work can be done here.
 No GUI elements are available here. It additinally calls the init method of superclass
 @returns initialized not nil object
 */
- (id)init {
	CocoLog(LEVEL_DEBUG,@"init of MBBoolValueDetailViewController");
	
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"cannot alloc MBBoolValueDetailViewController!");		
	} else {
	}
	
	return self;
}

/**
\brief dealloc of this class is called on closing this document
 */
- (void)dealloc {
	CocoLog(LEVEL_DEBUG,@"dealloc of MBBoolValueDetailViewController");
	
	// dealloc object
	[super dealloc];
}

//--------------------------------------------------------------------
//----------- Bundle delegates ---------------------------------------
//--------------------------------------------------------------------
/**
\brief gets called ig the nib file has been loaded. all gfx objacts are available now.
 */
- (void)awakeFromNib {
	CocoLog(LEVEL_DEBUG,@"awakeFromNib of MBBoolValueDetailViewController");
	
	if(self != nil) {
		// set size of view
		//viewFrame = [infoView frame];
	}	
}

/**
\brief set the element of which information should be shown
 no retains is made.
 */
- (void)displayInfo {
	MBBoolItemValue *itemval = (MBBoolItemValue *)currentItemValue;
	if(itemval != nil) {
		// is this itemval encrypted?
		if([itemval encryptionState] != EncryptedState) {
			// activate button
			[boolButton setEnabled:YES];
			
			[boolButton setState:(int)[itemval valueData]];
			if([itemval valueData] == NO) {
				[boolButton setTitle:MBLocaleStr(@"No")];
			} else {
				[boolButton setTitle:MBLocaleStr(@"Yes")];			
			}
		} else {
			// deactivate button
			[boolButton setEnabled:NO];
			// write Encrypted to button title
			[boolButton setTitle:MBLocaleStr(@"Encrypted")];
		}
	}
	else
	{
		[boolButton setState:0];
		[boolButton setTitle:@"No"];
		[boolButton setEnabled:NO];
	}
}

#pragma mark - Actions

- (IBAction)acc_BoolSwitch:(id)sender {
	// set new name for itemValue
	if(currentItemValue != nil) {
		[(MBBoolItemValue *)currentItemValue setValueData:(BOOL)[(NSButton *)sender state]];
		if([(MBBoolItemValue *)currentItemValue valueData] == NO) {
			[boolButton setTitle:MBLocaleStr(@"No")];
		} else {
			[boolButton setTitle:MBLocaleStr(@"Yes")];			
		}
	}	
}

@end
