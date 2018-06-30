//
//  MBExternalsPrefsViewController.h
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 15.09.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>

@interface MBExternalsPrefsViewController : NSObject 
{
	// the view
	IBOutlet NSView *theView;
	
	// initial rect
	NSRect viewFrame;
}

- (NSView *)theView;
- (NSRect)viewFrame;

@end
