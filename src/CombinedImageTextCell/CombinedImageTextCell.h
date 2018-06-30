/*
	Manfred Bergmann, 2005
 
	Taken from:
	CombinedImageTextCell.m
	Author: Chuck Pisula
 */

#import <Cocoa/Cocoa.h>

@interface CombinedImageTextCell : NSTextFieldCell {
	@private
    NSImage	*image;
}

- (void)setImage:(NSImage *)anImage;
- (NSImage *)image;

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
- (NSSize)cellSize;

@end
