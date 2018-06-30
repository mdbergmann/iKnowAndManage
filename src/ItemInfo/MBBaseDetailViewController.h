//
//  MBBaseDetailViewController.h
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 07.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MBItemValue;
@class MBExtendedViewController;

@interface MBBaseDetailViewController : NSObject {
	// the view itself
	IBOutlet NSView *theView;

    /** the extended view controller */
    IBOutlet MBExtendedViewController *extViewController;
    
    /** the delegate */
    IBOutlet id delegate;
    
    /** the current item value */
    MBItemValue *currentItemValue;
}

- (NSView *)theView;

- (void)displayInfo;

- (void)setDelegate:(id)aDelegate;
- (id)delegate;

// getter and setter
- (void)setCurrentItemValue:(MBItemValue *)aItemValue;
- (MBItemValue *)currentItemValue;

// should be implemented by subclasses
- (void)openItemValue;
- (void)openItemValueWith;

@end
