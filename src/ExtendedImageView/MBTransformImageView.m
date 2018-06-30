// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$
 
#import "MBTransformImageView.h"

@interface MBTransformImageView (privateAPI)

- (void) drawImage;	// only call this if there is a locked focus

@end

@implementation MBTransformImageView (privateAPI)

- (void) drawImage {
	NSImage *myImage = [super image];
	NSRect sourceRect, destinationRect;
	
	//[self setUpClipping];
	[self centerOriginInBounds];  // see NSViewExtensions
    
	sourceRect.origin = NSZeroPoint; 
	sourceRect.size = [myImage size];
	// The result of this, is that destinationRect ends up centered in the view.
	destinationRect = [self centerRect:sourceRect onPoint:NSZeroPoint];  
	
	[affineTransform concat];
	[myImage drawInRect:destinationRect fromRect:sourceRect operation:NSCompositeSourceOver fraction:1.0];
}

@end


@implementation MBTransformImageView

- (id)initWithFrame:(NSRect)frameRect {
	if((self = [super initWithFrame:frameRect])) {
		[self setAffineTransform:[NSAffineTransform transform]];
		
		// set default image alignment behavior
		[self setImageAlignment:(NSImageAlignLeft | NSImageAlignTop)];
	}
	
	return self;
}

- (void)awakeFromNib {
	// and load image
	[super setImage:nil];
}

- (void)dealloc {
	[self setAffineTransform:nil];
	[super dealloc];
}

- (void)setAffineTransform:(NSAffineTransform *)aTransform {
	[aTransform retain];
	[affineTransform release];
	affineTransform = aTransform;
	
	[self setNeedsDisplay:YES];
}

- (NSAffineTransform *)affineTransform {
	return affineTransform;
}

// we have to override -drawRect:
- (void)drawRect:(NSRect)rect {
	NSCell *cell = [self cell];
    
	NSImage *myImage = [super image];  // Need to stash this for a moment..
	
	[cell setImage:nil];
	[super drawRect:rect];  // This gets us an empty bezel.
    
	[cell setImage:myImage];  // put the image back in the cell
	[self drawImage];		// and then this fills in the transformed image
}

@end


@implementation NSView (GeometryExtensions)

- (NSRect) centerRect:(NSRect) aRect onPoint:(NSPoint) aPoint {
	float 
    height = NSHeight(aRect),
    width = NSWidth(aRect);
	
	return NSMakeRect(aPoint.x-(width/2.0), aPoint.y - (height/2.0), width, height);
}

- (void) centerOriginInBounds { [self centerOriginInRect:[self bounds]];  }
- (void) centerOriginInFrame { [self centerOriginInRect:[self convertRect:[self frame] fromView:[self superview]]];  }
- (void) centerOriginInRect:(NSRect) aRect  { [self translateOriginToPoint:NSMakePoint(NSMidX(aRect), NSMidY(aRect))]; }

@end
