//
//  MBItemValueListTableView.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 20.09.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <CocoLogger/CocoLogger.h>
#import "MBItemValueListTableView.h"
#import "globals.h"


@implementation MBItemValueListTableView

- (id)init
{
	self = [super init];
	if(self != nil)
	{
		delegateRespondsToMouseDown = NO;
	}
		
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

/**
\brief fetch this notification to end editing after a return
 */
- (void)textDidEndEditing:(NSNotification *)notification 
{	
	int movement = [[[notification userInfo] objectForKey:@"NSTextMovement"] intValue];
	int row = [self selectedRow];
    
    [super textDidEndEditing: notification];
	[[self window] endEditingFor:nil];
	
	if(movement == NSReturnTextMovement)
	{	
		[self abortEditing];
		[[self window] makeFirstResponder:self];
	}
	
	[self deselectRow:row];
	[self selectRow:row byExtendingSelection: NO];
}

// -------------------------------------------------------------------
// Key events
// -------------------------------------------------------------------
/*
- (BOOL)performKeyEquivalent:(NSEvent *)theEvent
{
	CocoLog(LEVEL_DEBUG,@"[MBItemValueListTableView -performKeyEquivalent:] keycode: %d!",[theEvent keyCode]);
	
	// check for delete key code
	if([theEvent keyCode] == NSDeleteFunctionKey)
	{
		CocoLog(LEVEL_DEBUG,@"[MBItemValueListTableView -performKeyEquivalent:] DELETE key pressed!");

		// send notification that the delete key has been pressed
		MBSendNotifyDeleteKeyPressed(nil);
		
		return YES;
	}
	else
	{
		return NO;
	}
}
*/

- (void)keyDown:(NSEvent *)theEvent
{
	CocoLog(LEVEL_DEBUG,@"[MBItemValueListTableView -keyDown:] keycode: %d!",[theEvent keyCode]);

	// check for delete key code
	if([theEvent keyCode] == 51)
	{
		CocoLog(LEVEL_DEBUG,@"[MBItemValueListTableView -keyDown:] DELETE key pressed!");
		
		// send notification that the delete key has been pressed
		MBSendNotifyDeleteKeyPressed(nil);
	}
	
	[super keyDown:theEvent];
}

// -------------------------------------------------------------------
// Mouse events
// -------------------------------------------------------------------
- (void)rightMouseDown:(NSEvent *)theEvent
{
	int row = [super rowAtPoint:[super convertPoint:[theEvent locationInWindow] fromView:nil]];
	if(row == -1)
	{
		[self deselectAll:nil];
	}
	else
	{
		if([self numberOfSelectedRows] <= 1) 
		{
			[self selectRow:row byExtendingSelection:NO];
		}
		else if([self numberOfSelectedRows] > 1)
		{
			// do not expand selection, but do not select row , too
		}
	}
	
	[super rightMouseDown:theEvent];
}

- (void)mouseDown:(NSEvent *)theEvent
{
	CocoLog(LEVEL_DEBUG,@"[MBItemValueListTableView -mouseDown:]");
	
	// send the event to tableViewController
	if(delegateRespondsToMouseDown == NO)
	{
		if([[super delegate] respondsToSelector:@selector(setMouseDownEvent:)] == YES)
		{
			delegateRespondsToMouseDown = YES;
		}
	}
	
	// still no?
	if(delegateRespondsToMouseDown == NO)
	{
		CocoLog(LEVEL_DEBUG,@"[MBItemValueListTableView -mouseDown:] delegate does not respond to setMouseDownEvent:");
	}
	else
	{
		[[super delegate] performSelector:@selector(setMouseDownEvent:) withObject:theEvent];
	}
	
	[super mouseDown:theEvent];
}

// -------------------------------------------------------------------
// actions
// -------------------------------------------------------------------
- (IBAction)menuExport:(id)sender
{
	if([[super delegate] respondsToSelector:@selector(menuExport:)] == YES)
	{
		[[super delegate] performSelector:@selector(menuExport:) withObject:sender];
	}
	else
	{
		CocoLog(LEVEL_WARN,@"[MBItemValueListTableView -menuExport:] delegate does not repsond to selector!");
	}
}

// -------------------------------------------------------------------
// Drag & Drop
// -------------------------------------------------------------------
- (unsigned int)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
	if(isLocal == YES)
	{
		// for local drag & drop within the table itself we only allow copy
		return NSDragOperationCopy | NSDragOperationMove | NSDragOperationNone;
	}
	else
	{
		return NSDragOperationMove | NSDragOperationCopy | NSDragOperationNone;	
	}
}
/**
\brief never ignore modifier keys
 */
- (BOOL)ignoreModifierKeysWhileDragging
{
	return NO;
}

/*
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
	NSLog(@"draggingEntered!");
	
	if([sender draggingSource] != self)
	{
		NSPasteboard *pb = [sender draggingPasteboard];
		NSString *type = [pb availableTypeFromArray:[NSArray arrayWithObjects:ITEMVALUE_PB_TYPE_NAME,nil]];
		if(type != nil)
		{
			return NSDragOperationCopy;
		}
	}
	
	return NSDragOperationNone;
}

- (void)draggingEnded:(id <NSDraggingInfo>)sender
{
	NSLog(@"draggingEnded!");
	
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
	NSLog(@"draggingExited!");
	
}
*/

/*
 - (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
 {
	 NSLog(@"draggingUpdated!");
	 
	 if([sender draggingSource] != self)
	 {
		 NSPasteboard *pb = [sender draggingPasteboard];
		 NSString *type = [pb availableTypeFromArray:[NSArray arrayWithObjects:ITEM_PB_TYPE_NAME,ITEMVALUE_PB_TYPE_NAME,nil]];
		 if(type != nil)
		 {
			 // check row, index and item
			 int row = [super rowAtPoint:[super convertPoint:[sender draggingLocation] fromView:nil]];
			 if(row >= -1)
			 {
				 // are we on first level?
				 if([self levelForRow:row] == 0)
				 {
					 // get the first level array
					 NSArray *items = [itemController rootItemList];
					 int index = [items indexOfObject:[itemController templateItem]];
					 if(row > index)
					 {
						 return NSDragOperationNone;				
					 }
				 }
			 }
		 }
	 }
	 
	 return NSDragOperationNone;
 }
 */

/*
- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
	NSLog(@"prepareForDragOperation!");
	
	return YES;
}
*/

/*
 - (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
 {
	 NSLog(@"performDragOperation!");
	 
	 return YES;
 }
 */

@end
