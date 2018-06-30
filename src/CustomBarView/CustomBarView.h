//
//  CustomBarView.h
//  MacSword2
//
//  Created by Manfred Bergmann on 24.08.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CustomBarView : NSView {
    // the image
    NSImage *bgImage;
}

- (void)setBgImage:(NSImage *)anImage;
- (NSImage *)bgImage;

@end
