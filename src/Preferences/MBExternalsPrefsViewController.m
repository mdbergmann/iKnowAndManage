//
//  MBExternalsPrefsViewController.m
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

#import <CocoLogger/CocoLogger.h>
#import "MBExternalsPrefsViewController.h"


@implementation MBExternalsPrefsViewController

- (id)init
{
	CocoLog(LEVEL_DEBUG, @"init of MBExternalsPrefsViewController");
	
	self = [super init];
	if(self == nil)
	{
		CocoLog(LEVEL_ERR, @"cannot alloc MBExternalsPrefsViewController!");
	}
	else
	{

	}
	
	return self;
}

/**
\brief dealloc of this class is called on closing this document
 */
- (void)dealloc
{
	CocoLog(LEVEL_DEBUG, @"dealloc of MBExternalsPrefsViewController");
	
	// dealloc object
	[super dealloc];
}

//--------------------------------------------------------------------
//----------- bundle delegates ---------------------------------------
//--------------------------------------------------------------------
- (void)awakeFromNib
{
	CocoLog(LEVEL_DEBUG, @"awakeFromNib of MBExternalsPrefsViewController");
	
	if(self != nil)
	{
		//NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		// init the viewRect
		viewFrame = [theView frame];
	}
}

/**
 \brief return the view itself
*/
- (NSView *)theView
{
	return theView;
}

- (NSRect)viewFrame
{
	return viewFrame;
}

@end
