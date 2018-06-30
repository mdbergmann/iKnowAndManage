//
//  MBPDFValueDetailViewController.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 08.07.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author: mbergmann $
// $HeadURL: file:///REPOSITORY/private/cocoa/iKnowAndManage/trunk/src/ItemInfo/MBFileValueDetailViewController.m $
// $LastChangedBy: mbergmann $
// $LastChangedDate: 2009-08-12 16:48:03 +0100 (Wed, 12 Aug 2009) $
// $Rev: 646 $

#import "MBPDFValueDetailViewController.h"
#import "MBFileItemValue.h"
#import "globals.h"
#import "MBExtendedViewController.h"


@implementation MBPDFValueDetailViewController

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
}

- (void)displayInfo {
    
    [super displayInfo];
    
	MBFileItemValue *itemval = (MBFileItemValue *)currentItemValue;	
	if(itemval != nil) {
		if([itemval encryptionState] != EncryptedState) {
            // filesize
            [fileSizeLabel setObjectValue:[NSNumber numberWithInt:[[itemval valueData] length]]];		            
		} else {
            [fileSizeLabel setStringValue:MBLocaleStr(@"Unknown")];
		}
	}
}

#pragma mark - Actions

- (IBAction)acc_Load:(id)sender {
	MBFileItemValue *itemval = (MBFileItemValue *)currentItemValue;
	if(itemval != nil) {
		// start progress indicator
		[progressIndicator startAnimation:nil];
		
        [extViewController contentViewForItem:itemval];
        
		// stop progress indicator
		[progressIndicator stopAnimation:nil];
	}
}

@end
