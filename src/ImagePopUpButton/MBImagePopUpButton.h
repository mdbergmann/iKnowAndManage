//
//  MBImagePopUpButton.h
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 25.07.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>
#import <MBImagePopUpButtonCell.h>

@interface MBImagePopUpButton : NSPopUpButton 
{
}

// getter and setter
- (void)setIconSize:(NSSize)aSize;
- (void)setIconImage:(NSImage *)aImage;
- (void)setArrowImage:(NSImage *)aImage;
- (NSSize)iconSize;
- (NSImage *)iconImage;
- (NSImage *)arrowImage;
// --- Getting and setting whether the menu is shown when the icon is clicked ---
- (BOOL)showsMenuWhenIconIsClicked;
- (void)setShowsMenuWhenIconIsClicked:(BOOL)aSetting;

@end
