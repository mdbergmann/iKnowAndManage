//
//  MBBaseDetailViewController.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 07.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MBBaseDetailViewController.h"
#import "MBItemValue.h"
#import "globals.h"


@implementation MBBaseDetailViewController

- (id)init {
	self = [super init];
	if(self) {
        [self setCurrentItemValue:nil];

		// register notification
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(itemValueAttribsChanged:)
													 name:MBItemValueAttribsChangedNotification object:nil];
	}
	
	return self;
}

#pragma mark - Getter/Setter

- (NSView *)theView {
	return theView;
}

- (void)setDelegate:(id)aDelegate {
    delegate = aDelegate;
}

- (id)delegate {
    return delegate;
}

- (void)setCurrentItemValue:(MBItemValue *)aItemValue {
	currentItemValue = aItemValue;
}

- (MBItemValue *)currentItemValue {
	return currentItemValue;
}

#pragma mark - Methods

/** abstract */
- (void)displayInfo {}

/** abstract */
- (void)openItemValue {}

/** abstract */
- (void)openItemValueWith {}

#pragma mark - Notifications

- (void)itemValueAttribsChanged:(NSNotification *) aNotification {
	if(aNotification != nil) {
		MBItemValue *itemval = [aNotification object];
		// only update if the changed is the selected one
		if(itemval != nil) {
			if(itemval == currentItemValue) {
				// update view
				[self displayInfo];
			}
		}
	}
}

@end
