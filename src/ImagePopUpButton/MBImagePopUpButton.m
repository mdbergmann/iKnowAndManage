//
//  MBImagePopUpButton.m
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

#import "MBImagePopUpButton.h"


@implementation MBImagePopUpButton

/**
 \brief with this method, we define the cell of out button
*/
+ (Class)cellClass
{
    return [MBImagePopUpButtonCell class];
}

/**
 \brief get state of button cell
*/
- (BOOL) showsMenuWhenIconIsClicked
{
	return [[self cell] showsMenuWhenIconIsClicked];
}

/**
\brief choose if the menu should pop up if the icons is clicked or not
 */
- (void) setShowsMenuWhenIconIsClicked:(BOOL)aSetting
{
	[[self cell] setShowsMenuWhenIconIsClicked:aSetting];
}

/**
 \brief set the icon size of this PopUpButton
*/
- (void)setIconSize:(NSSize)aSize
{
	[[self cell] setIconSize:aSize];
}

/**
 \brief get the icon size of this button
 */
- (NSSize)iconSize
{
	return [[self cell] iconSize];
}

/**
 \brief set the button image that is displayed instead og the normal PopUpButton ComboBox like thing
*/
- (void)setIconImage:(NSImage *)aImage
{
	[[self cell] setIconImage:aImage];
}

/**
 \brief set the arrow image that is used to indicate that this is a menu that can popup
*/
- (void)setArrowImage:(NSImage *)aImage
{
	[[self cell] setArrowImage:aImage];
}

/**
\brief return the iconImage
*/ 
- (NSImage *)iconImage
{
	return [[self cell] iconImage];
}

/**
\brief return the arrowImage
 */ 
- (NSImage *)arrowImage
{
	return [[self cell] arrowImage];
}

@end
