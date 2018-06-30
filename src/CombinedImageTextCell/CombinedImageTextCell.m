/*
 Manfred Bergmann, 2005
 
 Taken from:
 CombinedImageTextCell.m
 Author: Chuck Pisula
 */

#import "CombinedImageTextCell.h"

@implementation CombinedImageTextCell

- (id)init {
	self = [super init];
	if(self != nil) {
		// set wrap mode
		[self setWraps:YES];
        if([self respondsToSelector:@selector(setTruncatesLastVisibleLine:)]) {
            [self setTruncatesLastVisibleLine:YES];
        }
	}
	
	return self;
}

- (void)dealloc  {
	[self setImage:nil];
    [super dealloc];
}

/**
 \brief implementing NSCopying protocol
 */
- copyWithZone:(NSZone *)zone  {
    CombinedImageTextCell *cell = (CombinedImageTextCell *)[super copyWithZone:zone];
    cell->image = [image retain];
	//[cell setImage:[self image]];
    return cell;
}

- (void)setImage:(NSImage *)anImage  {
    if(anImage != image)  {
		[anImage retain];
        [image release];
        image = anImage;
    }
}

- (NSImage *)image  {
    return image;
}

- (NSRect)imageFrameForCellFrame:(NSRect)cellFrame  {
    if (image != nil)  {
        NSRect imageFrame;
        imageFrame.size = [image size];
        imageFrame.origin = cellFrame.origin;
        imageFrame.origin.x += 3;
        imageFrame.origin.y += ceil((cellFrame.size.height - imageFrame.size.height) / 2);
        return imageFrame;
    } else {
        return NSZeroRect;
	}
}

- (void)editWithFrame:(NSRect)aRect 
			   inView:(NSView *)controlView 
			   editor:(NSText *)textObj 
			 delegate:(id)anObject 
				event:(NSEvent *)theEvent  {
    NSRect textFrame, imageFrame;
    NSDivideRect (aRect, &imageFrame, &textFrame, 3 + [image size].width, NSMinXEdge);
    [super editWithFrame: textFrame inView: controlView editor:textObj delegate:anObject event: theEvent];
}

- (void)selectWithFrame:(NSRect)aRect 
				 inView:(NSView *)controlView 
				 editor:(NSText *)textObj 
			   delegate:(id)anObject 
				  start:(int)selStart 
				 length:(int)selLength  {
    NSRect textFrame, imageFrame;
    NSDivideRect (aRect, &imageFrame, &textFrame, 3 + [image size].width, NSMinXEdge);
    [super selectWithFrame: textFrame inView: controlView editor:textObj delegate:anObject start:selStart length:selLength];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView  {
    if (image != nil)  {
        NSSize	imageSize;
        NSRect	imageFrame;
        
        imageSize = [image size];
        NSDivideRect(cellFrame, &imageFrame, &cellFrame, 3 + imageSize.width, NSMinXEdge);
        if ([self drawsBackground])  {
            [[self backgroundColor] set];
            NSRectFill(imageFrame);
        }
        imageFrame.origin.x += 3;
        imageFrame.size = imageSize;
        
        if ([controlView isFlipped])
            imageFrame.origin.y += ceil((cellFrame.size.height + imageFrame.size.height) / 2);
        else
            imageFrame.origin.y += ceil((cellFrame.size.height - imageFrame.size.height) / 2);
        
        [image compositeToPoint:imageFrame.origin operation:NSCompositeSourceOver];
    }
    [super drawWithFrame:cellFrame inView:controlView];
}

- (NSSize)cellSize  {
    NSSize cellSize = [super cellSize];
    cellSize.width += (image ? [image size].width : 0) + 3;
    return cellSize;
}

@end

