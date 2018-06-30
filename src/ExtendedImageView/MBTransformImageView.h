/* MBTransformImageView */

// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>

@interface MBTransformImageView : NSImageView
{
	NSAffineTransform *affineTransform;
}

- (void)setAffineTransform:(NSAffineTransform *)aTransform;
- (NSAffineTransform *)affineTransform;

@end

@interface NSView (GeometryExtensions)

- (void) centerOriginInBounds;
- (void) centerOriginInFrame;
- (void) centerOriginInRect:(NSRect) aRect;
- (NSRect)centerRect:(NSRect) aRect onPoint:(NSPoint) aPoint;

@end
