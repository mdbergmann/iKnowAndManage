//
//  ThreeCellsCell.m
//  ThreeCellsCell
//
//  Created by Manfred Bergmann on 16.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ThreeCellsCell.h"
#import "CTGradient.h"

#define RADIUS 7.0
#define WIDTH_MIN 20
#define MARGIN_X 7
#define MARGIN_Y 1

@implementation ThreeCellsCell

- (void)setImage:(NSImage *)anImage {
    [anImage retain];
    [image release];
    image = anImage;
}

- (NSImage *)image {
    return image;
}

- (void)setRightImage:(NSImage *)anImage {
    [anImage retain];
    [rightImage release];
    rightImage = anImage;    
}

- (NSImage *)rightImage {
    return rightImage;
}

- (void)setRightCounter:(int)aNumber {
    rightCounter = aNumber;
}

- (int)rightCounter {
    return rightCounter;
}

- (void)setLeftCounter:(int)aNumber {
    leftCounter = aNumber;
}

- (int)leftCounter {
    return leftCounter;
}

- (void)setTextColor:(NSColor *)aColor {
    [aColor retain];
    [textColor release];
    textColor = aColor;
}

- (NSColor *)textColor {
    return textColor;
}

- (id)init {
    self = [super init];
    if(self) {
        [self setRightCounter:0];
        [self setLeftCounter:0];
        [self setImage:nil];
        [self setRightImage:nil];
        countFont = [[NSFontManager sharedFontManager] convertFont:[NSFont fontWithName:@"Helvetica" size:11.0] toHaveTrait:NSBoldFontMask];
    }
    
    return self;
}

- (void)dealloc {
    [self setImage:nil];
    [self setRightImage:nil];
    //[countFont release];
    [self setTextColor:nil];
    
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
	ThreeCellsCell *cell = (ThreeCellsCell *)[super copyWithZone:zone];
	return cell;
}

- (NSAttributedString *)attributedObjectLeftCountValue {
    NSString *contents = [NSString stringWithFormat:@"%i", leftCounter];
    // hightlighted?
    NSDictionary *attr = nil;
    if(![self isHighlighted]) {
        attr = [[[NSDictionary alloc] initWithObjectsAndKeys:countFont, NSFontAttributeName,
                 [[NSColor whiteColor] colorWithAlphaComponent:0.85], NSForegroundColorAttributeName,
                 nil, nil] autorelease];        
    } else {
        attr = [[[NSDictionary alloc] initWithObjectsAndKeys:countFont, NSFontAttributeName,
                 [[NSColor darkGrayColor] colorWithAlphaComponent:0.85], NSForegroundColorAttributeName,
                 nil, nil] autorelease];
    }
    
    return [[[NSAttributedString alloc] initWithString:contents attributes:attr] autorelease];
}

- (NSAttributedString *)attributedObjectRightCountValue {
    NSString *contents = [NSString stringWithFormat:@"%i", rightCounter];
    // hightlighted?
    NSDictionary *attr = nil;
    if(![self isHighlighted]) {
        attr = [[[NSDictionary alloc] initWithObjectsAndKeys:countFont, NSFontAttributeName,
                 [[NSColor whiteColor] colorWithAlphaComponent:0.85], NSForegroundColorAttributeName,
                 nil, nil] autorelease];        
    } else {
        attr = [[[NSDictionary alloc] initWithObjectsAndKeys:countFont, NSFontAttributeName,
                 [[NSColor darkGrayColor] colorWithAlphaComponent:0.85], NSForegroundColorAttributeName,
                 nil, nil] autorelease];
    }
    
    return [[[NSAttributedString alloc] initWithString:contents attributes:attr] autorelease];
}

- (NSRect)counterRectForCellFrame:(NSRect)cellFrame {
    if(leftCounter == 0 && rightCounter == 0) {
        return NSZeroRect;
    }
    
    float counterWidth = 0;
    if(leftCounter != 0) {
        NSAttributedString *attrString = [self attributedObjectLeftCountValue];
        NSSize size = [attrString size];
        counterWidth += size.width;            
    }
    if(rightCounter != 0) {
        counterWidth += [[self attributedObjectRightCountValue] size].width;        
    }
    
    if(leftCounter != 0 && rightCounter != 0) {
        counterWidth += (2 * RADIUS + 10.0);
    } else {
        counterWidth += (2 * RADIUS - 5.0);    
    }
    if(counterWidth < WIDTH_MIN) {
        counterWidth = WIDTH_MIN;
    }
    
    NSRect result;
    result.size = NSMakeSize(counterWidth, 2 * RADIUS); // temp
    result.origin.x = cellFrame.origin.x + cellFrame.size.width - MARGIN_X - result.size.width;
    result.origin.y = cellFrame.origin.y + MARGIN_Y + 1.0;
    
    return result;
}

/*
- (void)editWithFrame:(NSRect)aRect 
			   inView:(NSView *)controlView 
			   editor:(NSText *)textObj 
			 delegate:(id)anObject 
				event:(NSEvent *)theEvent  {
    [super editWithFrame:textRect inView:controlView editor:textObj delegate:anObject event:theEvent];
}

- (void)selectWithFrame:(NSRect)aRect 
				 inView:(NSView *)controlView 
				 editor:(NSText *)textObj 
			   delegate:(id)anObject 
				  start:(int)selStart 
				 length:(int)selLength  {
    [super selectWithFrame:textRect inView:controlView editor:textObj delegate:anObject start:selStart length:selLength];
}
 */

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	[controlView lockFocus];

    NSRect drawRect = NSMakeRect(0.0, cellFrame.origin.y - 0.5, cellFrame.size.width + cellFrame.origin.x + 3, cellFrame.size.height + 1.0);
	if ([self isHighlighted]) {
		if ([[controlView window] isMainWindow] &&
            [[controlView window] isKeyWindow]) {
			[[CTGradient mailActiveGradient] fillRect:drawRect angle:270];
            [self setTextColor:[NSColor whiteColor]];
		} else {
			[[CTGradient mailInactiveGradient] fillRect:drawRect angle:270];
            [self setTextColor:[NSColor blackColor]];
		}
	}
    
	[controlView unlockFocus];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {

	// backup title
	NSString *title = [self stringValue];
	
	// paint background without text
	[self setStringValue:@""];
	// now paint background
	[super drawWithFrame:cellFrame inView:controlView];

    // left image frame
    NSRect imageFrame;
    imageFrame = cellFrame;
    imageFrame.size.width = cellFrame.size.height + 6;  // we set the width of the image to height of cell
    // image cell
    NSImageCell *imageCell = nil;
    if(image == nil) {
        imageFrame.size.width = 0;    
    } else {
        imageCell = [[NSImageCell alloc] initImageCell:[self image]];
        [imageCell setImageAlignment:NSImageAlignCenter];
        // leave some pixels between the arrow and the image
        imageFrame.origin.x += 3;
    }
    
    // numberValue frame
    NSRect counterRect = [self counterRectForCellFrame:cellFrame];
    // right frame
    NSRect rightFrame;
    rightFrame = counterRect;
    if(leftCounter == 0 && rightCounter == 0 && rightImage == nil) {
        rightFrame.size.width = 0;
    }
    if(rightImage != nil) {
        rightFrame.size.width = [rightImage size].width;
    }
    // right cell
    NSCell *rightCell = nil;
    // counter part drawing
    if(rightCounter > 0 && leftCounter > 0) {
        NSBezierPath *path = [NSBezierPath bezierPath];
        // set color for drawing
        if(![self isHighlighted]) {
            [[NSColor colorWithCalibratedWhite:0.3 alpha:0.6] set];
        } else {
            [[NSColor whiteColor] set];            
        }
        // we start on the right side
        NSPoint point = NSMakePoint(counterRect.origin.x + counterRect.size.width/2.0, counterRect.origin.y);
        [path moveToPoint:point];
        // draw line to begin of right arc
        point = NSMakePoint(counterRect.origin.x + counterRect.size.width - RADIUS, counterRect.origin.y);
        [path lineToPoint:point];
        // position of center for arc
        point = NSMakePoint(counterRect.origin.x + counterRect.size.width - RADIUS, counterRect.origin.y + RADIUS);
        // draw right half arc
        [path appendBezierPathWithArcWithCenter:point radius:RADIUS startAngle:270.0 endAngle:90.0 clockwise:NO];
        // draw top line until mid
        point = NSMakePoint(counterRect.origin.x + counterRect.size.width/2, counterRect.origin.y + counterRect.size.height);
        [path lineToPoint:point];
        // draw line to buttom
        point = NSMakePoint(counterRect.origin.x + counterRect.size.width/2, counterRect.origin.y);
        [path lineToPoint:point];
        // fill this bezier
        [path fill];
        [path setLineWidth:0.5];
        [[NSColor blackColor] set];
        [path stroke];
        
        // draw attributed string centered in right area
        NSRect counterStringRect;
        NSAttributedString *counterString = [self attributedObjectRightCountValue];
        counterStringRect.size = [counterString size];
        counterStringRect.origin.x = counterRect.origin.x + counterRect.size.width/2.0 + ((counterRect.size.width/2.0 - counterStringRect.size.width) / 2.0) + 0.25;
        counterStringRect.origin.y = counterRect.origin.y + ((counterRect.size.height - counterStringRect.size.height) / 2.0) + 0.5;
        [counterString drawInRect:counterStringRect];
        
        // now draw left side
        if(![self isHighlighted]) {
            [[NSColor colorWithDeviceRed:0.3 green:0.2 blue:0.1 alpha:1.0] set];
        } else {
            [[NSColor whiteColor] set];            
        }
        path = [NSBezierPath bezierPath];
        point = NSMakePoint(counterRect.origin.x + counterRect.size.width/2, counterRect.origin.y);
        [path moveToPoint:point];
        // draw line to begin of arc on left side
        point = NSMakePoint(counterRect.origin.x + RADIUS, counterRect.origin.y);
        [path lineToPoint:point];
        // draw half arc on left
        point = NSMakePoint(counterRect.origin.x + RADIUS, counterRect.origin.y + RADIUS);
        [path appendBezierPathWithArcWithCenter:point radius:RADIUS startAngle:270.0 endAngle:90.0 clockwise:YES];
        // move point to top of arc
        //point = NSMakePoint(counterRect.origin.x + RADIUS, counterRect.origin.y + counterRect.size.height);
        //[path moveToPoint:point];
        // draw to mid
        point = NSMakePoint(counterRect.origin.x + counterRect.size.width/2, counterRect.origin.y + counterRect.size.height);    
        [path lineToPoint:point];
        // draw line to buttom
        point = NSMakePoint(counterRect.origin.x + counterRect.size.width/2, counterRect.origin.y);
        [path lineToPoint:point];
        // fill this bezier
        [path fill];
        [path setLineWidth:0.5];
        [[NSColor blackColor] set];
        [path stroke];
        
        // draw attributed string centered in left area
        counterString = [self attributedObjectLeftCountValue];
        counterStringRect.size = [counterString size];
        counterStringRect.origin.x = counterRect.origin.x + ((counterRect.size.width/2.0 - counterStringRect.size.width) / 2.0) + 0.25;
        counterStringRect.origin.y = counterRect.origin.y + ((counterRect.size.height - counterStringRect.size.height) / 2.0) + 0.5;
        [counterString drawInRect:counterStringRect];
    } else if(leftCounter > 0 && rightCounter == 0) {
        // set color for drawing
        if(![self isHighlighted]) {
            [[NSColor colorWithCalibratedWhite:0.3 alpha:0.6] set];
        } else {
            [[NSColor whiteColor] set];            
        }
        NSBezierPath *path = [NSBezierPath bezierPath];
        counterRect.origin.y -= 1.0;
        [path moveToPoint:NSMakePoint(counterRect.origin.x + RADIUS, counterRect.origin.y)];
        [path lineToPoint:NSMakePoint(counterRect.origin.x + counterRect.size.width - RADIUS, counterRect.origin.y)];
        [path appendBezierPathWithArcWithCenter:NSMakePoint(counterRect.origin.x + counterRect.size.width - RADIUS, counterRect.origin.y + RADIUS) radius:RADIUS startAngle:270.0 endAngle:90.0];
        [path lineToPoint:NSMakePoint(counterRect.origin.x + RADIUS, counterRect.origin.y + counterRect.size.height)];
        [path appendBezierPathWithArcWithCenter:NSMakePoint(counterRect.origin.x + RADIUS, counterRect.origin.y + RADIUS) radius:RADIUS startAngle:90.0 endAngle:270.0];
        [path fill];
        [path setLineWidth:0.5];
        [[NSColor blackColor] set];
        [path stroke];
        
        // draw attributed string centered in area
        NSRect counterStringRect;
        NSAttributedString *counterString = [self attributedObjectLeftCountValue];
        counterStringRect.size = [counterString size];
        counterStringRect.origin.x = counterRect.origin.x + ((counterRect.size.width - counterStringRect.size.width) / 2.0) + 0.25;
        counterStringRect.origin.y = counterRect.origin.y + ((counterRect.size.height - counterStringRect.size.height) / 2.0) + 0.5;
        [counterString drawInRect:counterStringRect];        
    } else if(leftCounter == 0 && rightCounter > 0) {
        // set color for drawing
        if(![self isHighlighted]) {
            [[NSColor colorWithDeviceRed:0.3 green:0.2 blue:0.1 alpha:1.0] set];
        } else {
            [[NSColor whiteColor] set];            
        }
        NSBezierPath *path = [NSBezierPath bezierPath];
        counterRect.origin.y -= 1.0;
        [path moveToPoint:NSMakePoint(counterRect.origin.x + RADIUS, counterRect.origin.y)];
        [path lineToPoint:NSMakePoint(counterRect.origin.x + counterRect.size.width - RADIUS, counterRect.origin.y)];
        [path appendBezierPathWithArcWithCenter:NSMakePoint(counterRect.origin.x + counterRect.size.width - RADIUS, counterRect.origin.y + RADIUS) radius:RADIUS startAngle:270.0 endAngle:90.0];
        [path lineToPoint:NSMakePoint(counterRect.origin.x + RADIUS, counterRect.origin.y + counterRect.size.height)];
        [path appendBezierPathWithArcWithCenter:NSMakePoint(counterRect.origin.x + RADIUS, counterRect.origin.y + RADIUS) radius:RADIUS startAngle:90.0 endAngle:270.0];
        [path fill];
        [path setLineWidth:0.5];
        [[NSColor blackColor] set];
        [path stroke];
        
        // draw attributed string centered in area
        NSRect counterStringRect;
        NSAttributedString *counterString = [self attributedObjectRightCountValue];
        counterStringRect.size = [counterString size];
        counterStringRect.origin.x = counterRect.origin.x + ((counterRect.size.width - counterStringRect.size.width) / 2.0) + 0.25;
        counterStringRect.origin.y = counterRect.origin.y + ((counterRect.size.height - counterStringRect.size.height) / 2.0) + 0.5;
        [counterString drawInRect:counterStringRect];        
    } else if(rightImage != nil) {
        rightCell = [[NSImageCell alloc] initImageCell:rightImage];
        [(NSImageCell *)rightCell setImageAlignment:NSImageAlignCenter];
    }

    // text frame
	NSRect textFrame;
	textFrame = cellFrame;
	textFrame.origin.x += imageFrame.size.width + 2.0;
    textFrame.origin.y += 2.0;
    textFrame.size.height -= 2.0;
	textFrame.size.width -= (imageFrame.size.width + rightFrame.size.width + 8.0);
	// text cell
	NSTextFieldCell *textCell = [[NSTextFieldCell alloc] initTextCell:title];
    [textCell setEditable:YES];
    [textCell setFocusRingType:NSFocusRingTypeDefault];
    [textCell setWraps:[self wraps]];
    if([textCell respondsToSelector:@selector(setTruncatesLastVisibleLine:)]) {
        [textCell setTruncatesLastVisibleLine:[self truncatesLastVisibleLine]];
    }
    [textCell setLineBreakMode:[self lineBreakMode]];
	[textCell setTextColor:[self textColor]];
    [textCell setFont:[self font]];
        
    // draw cells
    if(imageCell) {
        [imageCell drawWithFrame:imageFrame inView:controlView];
    }
    // draw text cell
	[textCell drawWithFrame:textFrame inView:controlView];
    // draw right cell
    if(rightCell) {
        [rightCell drawWithFrame:rightFrame inView:controlView];    
    }
	
	// und titel wieder setzen
	[self setStringValue:title];
}

@end
