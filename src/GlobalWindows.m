//
//  GlobalWindows.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 05.07.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import "GlobalWindows.h"

NSWindow *currentAlertWindow;
NSWindow *mainAppWindow;

@implementation GlobalWindows

+ (void)setAlertWindow:(NSWindow *)aWindow
{
	currentAlertWindow = aWindow;
}

+ (void)setMainAppWindow:(NSWindow *)aWindow
{
	mainAppWindow = aWindow;
}

+ (NSWindow *)alertWindow
{
	return currentAlertWindow;
}

+ (NSWindow *)mainAppWindow
{
	return mainAppWindow;
}

@end
