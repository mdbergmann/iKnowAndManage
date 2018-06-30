/* MBExtendedImageViewController.h */

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import <globals.h>
#import <MBPrintController.h>
#import <MBImageConverter.h>
#import <MBExporter.h>
#import <MBTransformImageView.h>
 
@interface MBExtendedImageViewController : NSObject {
	IBOutlet id delegate;
	IBOutlet MBTransformImageView *imageView;
	IBOutlet NSView *extendedImageView;
	IBOutlet NSPopUpButton *scalePropPopUpButton;
	IBOutlet NSSlider *zoomSlider;
	IBOutlet NSTextField *zoomNumberInputTextField;
	IBOutlet NSButton *saveAsButton;
	
	int currentScaleProp;
	
	// degrees for rotation
	float rotateDegrees;
	
	float collapseHeight;
}

+ (MBExtendedImageViewController *) standardImageViewController;

- (NSView *)extendedImageView;
- (float)collapseHeight;

// setting and getting the image
- (void)setImage:(NSImage *)aImage;
- (NSImage *)image;

- (void)setDelegate:(id)aDelegate;
- (id)delegate;

// printing
- (IBAction)print:(id)sender;
- (IBAction)saveAs:(id)sender;
- (IBAction)zoomSliderChange:(id)sender;
- (IBAction)scalePropChange:(id)sender;
- (IBAction)zoomNumberInput:(id)sender;
- (IBAction)rotate:(id)sender;

@end
