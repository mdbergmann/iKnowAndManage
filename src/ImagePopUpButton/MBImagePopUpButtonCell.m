//
//  MBImagePopUpButtonCell.m
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

#import "MBImagePopUpButtonCell.h"


@implementation MBImagePopUpButtonCell

/**
 init the imagePopUpButtonCell
*/
- (id) init
{
	self = [super init];
    if(self != nil)
    {
		buttonCell = [[NSButtonCell alloc] initTextCell:@""];
		[buttonCell setBordered:NO];
		[buttonCell setHighlightsBy:NSContentsCellMask];
		[buttonCell setImagePosition:NSImageLeft];
		
		iconSize = NSMakeSize(32,32);
		showsMenuWhenIconIsClicked = NO;
		
		[self setIconImage:nil];	
		[self setArrowImage:[NSImage imageNamed:@"ArrowPointingDown"]];
    }
    
    return self;
}


- (void) dealloc
{
    [buttonCell release];
    [iconImage release];
    [arrowImage release];
    [super dealloc];
}

/**
\brief get state of button cell
 */
- (BOOL) showsMenuWhenIconIsClicked
{
	return showsMenuWhenIconIsClicked;
}

/**
\brief choose if the menu should pop up if the icons is clicked or not
 */
- (void) setShowsMenuWhenIconIsClicked: (BOOL)aSetting
{
	showsMenuWhenIconIsClicked = aSetting;
}

/**
\brief set the icon size of this PopUpButton
 */
- (void)setIconSize:(NSSize)aSize
{
	iconSize = aSize;
}

/**
\brief get the icon size of this button
 */
- (NSSize)iconSize
{
	return iconSize;
}

/**
\brief set the button image that is displayed instead og the normal PopUpButton ComboBox like thing
 */
- (void)setIconImage:(NSImage *)aImage
{
	aImage = [aImage copy];
	[iconImage release];
	iconImage = aImage;
}

/**
\brief set the arrow image that is used to indicate that this is a menu that can popup
 */
- (void)setArrowImage:(NSImage *)aImage
{
	aImage = [aImage copy];
	[arrowImage release];
	arrowImage = aImage;	
}

/**
\brief return the iconImage
 */ 
- (NSImage *)iconImage
{
	return iconImage;
}

/**
\brief return the arrowImage
 */ 
- (NSImage *)arrowImage
{
	return arrowImage;
}

/**
 \brief we want to listen to keyboard ot mouse events
*/
/*
- (BOOL)trackMouse:(NSEvent *)event inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)untilMouseUp
{
    BOOL trackingResult = YES;
    
	// Keyboard event
    if([event type] == NSKeyDown)
    {
		unichar upAndDownArrowCharacters[2];
		upAndDownArrowCharacters[0] = NSUpArrowFunctionKey;
		upAndDownArrowCharacters[1] = NSDownArrowFunctionKey;
		NSString *upAndDownArrowString = [NSString stringWithCharacters:upAndDownArrowCharacters  length:2];
		NSCharacterSet *upAndDownArrowCharacterSet = [NSCharacterSet characterSetWithCharactersInString:upAndDownArrowString];
		
		if ([self showsMenuWhenIconIsClicked] == YES || [[event characters] rangeOfCharacterFromSet:upAndDownArrowCharacterSet].location != NSNotFound)
		{
			NSEvent *newEvent = [NSEvent keyEventWithType: [event type]
												 location: NSMakePoint([controlView frame].origin.x, [controlView frame].origin.y - 4)
											modifierFlags: [event modifierFlags]
												timestamp: [event timestamp]
											 windowNumber: [event windowNumber]
												  context: [event context]
											   characters: [event characters]
							  charactersIgnoringModifiers: [event charactersIgnoringModifiers]
												isARepeat: [event isARepeat]
												  keyCode: [event keyCode]];
			
			[NSMenu popUpContextMenu: [self menu] withEvent:newEvent  forView:controlView];
		}
		else if([[event characters] rangeOfString:@" "].location != NSNotFound)
		{
			[self performClick:controlView];
		}
    }
    else	// Mouse event
    {
		NSPoint mouseLocation = [controlView convertPoint:[event locationInWindow] fromView:nil];
		NSSize iSize = [self iconSize];
		NSSize aSize = [[self arrowImage] size];
		NSRect arrowRect = NSMakeRect(cellFrame.origin.x + iSize.width + 1,
									  cellFrame.origin.y,
									  aSize.width,
									  aSize.height);
		
		if([controlView isFlipped])
		{
			arrowRect.origin.y += iSize.height;
			arrowRect.origin.y -= aSize.height;
		}
		
		if([event type] == (NSLeftMouseDown && 
							([self showsMenuWhenIconIsClicked] == YES || 
							 [controlView mouse:mouseLocation inRect:arrowRect])))
		{
			NSEvent *newEvent = [NSEvent mouseEventWithType: [event type]
												   location: NSMakePoint([controlView frame].origin.x, [controlView frame].origin.y - 4)
											  modifierFlags: [event modifierFlags]
												  timestamp: [event timestamp]
											   windowNumber: [event windowNumber]
													context: [event context]
												eventNumber: [event eventNumber]
												 clickCount: [event clickCount]
												   pressure: [event pressure]];
			
			[NSMenu popUpContextMenu:[self menu] withEvent:newEvent  forView:controlView];
		}
		else
		{
			trackingResult = [buttonCell trackMouse: event
											 inRect: cellFrame
											 ofView: controlView
									   untilMouseUp:[[buttonCell class] prefersTrackingUntilMouseUp]];  // NO for NSButton
			
			if(trackingResult == YES)
			{
				NSMenuItem *selectedItem = [self selectedItem];
				[[NSApplication sharedApplication] sendAction:[selectedItem action]  to:[selectedItem target]  from:selectedItem];
			}
		}
    }
    
    return trackingResult;
}


- (void) performClick:(id)sender
{
    [buttonCell performClick:sender];
    [super performClick:sender];
}
*/

/**
 \setting the control size of this Cell. This method overrides the method of NSCell
*/
- (void)setControlSize:(int)size
{
	// regularsize is 32x32
	if(size == NSRegularControlSize)
	{
		[self setIconSize:NSMakeSize(32,32)];
	}
	else if(size == NSSmallControlSize)
	{
		[self setIconSize:NSMakeSize(24,24)];
	}
	else
	{
		[self setIconSize:NSMakeSize(32,32)];
	}
	
	[self setNeedsDisplay:YES];
}

/**
 \brief overriden drawWithFrame method
*/
- (void)drawWithFrame:(NSRect)cellFrame  inView:(NSView *)controlView
{
    NSImage *iImage;
    
	// check which icon we have to use
    if([self usesItemFromMenu] == NO)
    {
		iImage = [self iconImage];
    }
    else
    {
		iImage = [[[[self selectedItem] image] copy] autorelease];
    }
    
	// set iconsize
    [iImage setSize: [self iconSize]];
    NSImage *aImage = [self arrowImage];
    NSSize iSize = [iImage size];
    NSSize aSize = [aImage size];
	// make the actual image for the popup button, size big enough to show th arrowimage, too.
    NSImage *popUpImage = [[NSImage alloc] initWithSize:NSMakeSize((iSize.width + aSize.width),iSize.height)];
    
	// make rects
    NSRect iconRect = NSMakeRect(0, 0, iSize.width, iSize.height);
    NSRect arrowRect = NSMakeRect(0, 0, aSize.width, aSize.height);
    NSRect iconDrawRect = NSMakeRect(0, 0, iSize.width, iSize.height);
    NSRect arrowDrawRect = NSMakeRect(iSize.width, 1, aSize.width, aSize.height);
    
    [popUpImage lockFocus];		// prepare the image for drawing
    [iImage drawInRect: iconDrawRect  fromRect: iconRect  operation: NSCompositeSourceOver  fraction: 1.0];
    [aImage drawInRect: arrowDrawRect  fromRect: arrowRect  operation: NSCompositeSourceOver  fraction: 1.0];
    [popUpImage unlockFocus];
    
	// set the image to the buttonCell
    [buttonCell setImage: popUpImage];
	// image can be released now
    [popUpImage release];
    
	// don't know what this is for
    if ([[controlView window] firstResponder] == controlView &&
		[controlView respondsToSelector: @selector(selectedCell)] &&
		[controlView performSelector: @selector(selectedCell)] == self)
    {
		[buttonCell setShowsFirstResponder: YES];
    }
    else
    {
		[buttonCell setShowsFirstResponder: NO];
    }
    
	// draw the button
    [buttonCell drawWithFrame:cellFrame  inView:controlView];
}

/**
 \brief overriden highlight method
*/
- (void)highlight:(BOOL)flag  withFrame:(NSRect)cellFrame  inView:(NSView *)controlView
{
    [buttonCell highlight:flag  withFrame:cellFrame  inView:controlView];
    [super highlight:flag  withFrame:cellFrame  inView:controlView];
}

/**
 \brief we are conform to the NSCoding protocol
*/
- (void)encodeWithCoder:(NSCoder *)coder 
{
	[super encodeWithCoder:coder];
	
	if([coder allowsKeyedCoding] == YES)
	{
		[coder encodeObject:[self iconImage] forKey:@"MBImagePopUpButtonIconImage"];
		[coder encodeSize:[self iconSize] forKey:@"MBImagePopUpButtonIconSize"];
		[coder encodeObject:[self arrowImage] forKey:@"MBImagePopUpButtonArrowImage"];
		[coder encodeBool:[self showsMenuWhenIconIsClicked] forKey:@"MBImagePopUpButtonShowsMenu"];
	}
	else
	{
		CocoLog(LEVEL_WARN,@"[MBImagePopUpButtonCell -encodeWithCoder:]: encoder does not allow keyedCoding!");
	}
}

/**
 \brief we are conform to NSCoding protocol
*/
- (id)initWithCoder:(NSCoder *)coder 
{
	self = [super initWithCoder:coder];
	if(self != nil)
	{
		if([coder allowsKeyedCoding] == YES)
		{
			[self setIconImage:[coder decodeObjectForKey:@"MBImagePopUpButtonIconImage"]];
			[self setIconSize:[coder decodeSizeForKey:@"MBImagePopUpButtonIconSize"]];
			[self setArrowImage:[coder decodeObjectForKey:@"MBImagePopUpButtonArrowImage"]];
			[self setShowsMenuWhenIconIsClicked:[coder decodeBoolForKey:@"MBImagePopUpButtonShowsMenu"]];
	
			buttonCell = [[NSButtonCell alloc] initTextCell: @""];	
			[buttonCell setBordered: NO];
		}
		else
		{
			CocoLog(LEVEL_WARN,@"[MBImagePopUpButtonCell -initWithCoder:]: coder does not allow keyedCoding!");
		}
	}
	else
	{
		CocoLog(LEVEL_WARN,@"[MBImagePopUpButtonCell -initWithCoder:]: self is nil!");
	}

	return self;
}

@end
