//
//  GlobalWindows.h
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

#import <Cocoa/Cocoa.h>

@interface GlobalWindows : NSObject 
{
}

+ (void)setAlertWindow:(NSWindow *)aWindow;
+ (void)setMainAppWindow:(NSWindow *)aWindow;
+ (NSWindow *)alertWindow;
+ (NSWindow *)mainAppWindow;

@end
