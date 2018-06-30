//
//  ThreeCellsCell.h
//  ThreeCellsCell
//
//  Created by Manfred Bergmann on 16.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ThreeCellsCell : NSCell {
    NSImage *image;
    NSImage *rightImage;
    NSColor *textColor;
    NSFont *countFont;
    int rightCounter;
    int leftCounter;
}

- (void)setImage:(NSImage *)anImage;
- (NSImage *)image;
- (void)setRightImage:(NSImage *)anImage;
- (NSImage *)rightImage;
- (void)setRightCounter:(int)aNumber;
- (int)rightCounter;
- (void)setLeftCounter:(int)aNumber;
- (int)leftCounter;
- (void)setTextColor:(NSColor *)aColor;
- (NSColor *)textColor;

@end
