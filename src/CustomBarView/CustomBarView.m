//
//  CustomBarView.m
//  MacSword2
//
//  Created by Manfred Bergmann on 24.08.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CustomBarView.h"


@implementation CustomBarView

- (void)setBgImage:(NSImage *)anImage {
    [anImage retain];
    [bgImage release];
    bgImage = anImage;
}

- (NSImage *)bgImage {
    return bgImage;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        [self setBgImage:[NSImage imageNamed:@"gray_gradient.tif"]];
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
    // Drawing code here.
    NSRect tmp = [self bounds];
    int repeat = (tmp.size.width / 5) + 1;
    for(int i = 0;i < repeat;i++) {
        [bgImage drawInRect:tmp fromRect:[self bounds] operation:NSCompositeSourceOver fraction:1.0];
        tmp.origin.x += 5;
    }
}

@end
