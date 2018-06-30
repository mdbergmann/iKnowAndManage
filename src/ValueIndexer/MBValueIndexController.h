/* MBValueIndexController */

//  Created by Manfred Bergmann on 25.07.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import <globals.h>

@class MBCommonItem;

@interface MBValueIndexController : NSObject
{
	NSMutableDictionary *registeredCommonItems;
}

// singleton
+ (MBValueIndexController *)defaultController;

- (void)startTimer;
- (void)runFirstInitialization;

- (void)registerCommonItem:(MBCommonItem *)cItem;

@end
