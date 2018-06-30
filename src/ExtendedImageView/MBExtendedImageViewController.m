// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import "MBExtendedImageViewController.h"

enum MBImageScaleType {
	NoScaling = 0,
	ScaleToFit
};

@interface MBExtendedImageViewController (privateAPI)

- (void)setZoomControlsOfCurrentImageSize;
- (void)generateTransform;

@end

@implementation MBExtendedImageViewController (privateAPI)

- (void)setZoomControlsOfCurrentImageSize; {
	// only set controls if we are in ScaleToFit mode
	if(currentScaleProp == ScaleToFit) {
		if([imageView image] != nil) {
			// get size of visible part of scrollview
			NSRect visibleRect = [[imageView superview] visibleRect];
			// set imageView to that size
			[imageView setFrameSize:visibleRect.size];
		}
		
		// now change scale behaviour of imageView
		[imageView setImageScaling:NSScaleProportionally];

		// is height > width?
		float zoom = 0.0;
		NSImage *img = [imageView image];
		
        // compare height to width ratio
        float hR = [imageView frame].size.height / [img size].height;
        float wR = [imageView frame].size.width / [img size].width;
        
		// is more high than wide?
//		if([img size].height > [img size].width) {
        if(fabs(hR) < fabs(wR)) {
			// compare size to size of original
			zoom = hR;
		} else {
			// compare size to size of original
			zoom = wR;
		}

		// set text in NumberInputTextField
		[zoomNumberInputTextField setObjectValue:[NSNumber numberWithFloat:(zoom * 100)]];
		[zoomSlider setFloatValue:zoom];
	}
}

/**
 \brief generate transformation of the set values
*/
- (void)generateTransform {
	NSAffineTransform *transform = [NSAffineTransform transform];
	[transform rotateByDegrees:rotateDegrees];
	[transform scaleBy:[zoomSlider floatValue]];
	
	[imageView setAffineTransform:transform];
}

@end

@implementation MBExtendedImageViewController

+ (MBExtendedImageViewController *) standardImageViewController {
	static MBExtendedImageViewController *singleton;
	
	if(singleton == nil) {
		singleton = [[MBExtendedImageViewController alloc] init];
	}
	
	return singleton;	
}

- (id)init {
	CocoLog(LEVEL_DEBUG,@"[MBExtendedImageViewController -init]");

	self = [super init];
	if(self != nil) {
		BOOL success = [NSBundle loadNibNamed:@"ExtendedImageView" owner:self];
		if(success == YES) {
			rotateDegrees = 0.0;
		} else {
			CocoLog(LEVEL_ERR,@"[MBExtendedImageViewController]: cannot load ExtendedImageViewNib!");
		}
	}
	
	return self;
}

/**
\brief dealloc of this class is called on closing this document
 */
- (void)dealloc {
	CocoLog(LEVEL_DEBUG,@"[MBExtendedImageViewController -dealloc]");
	
	// nil images
	[self setImage:nil];
	
	// dealloc object
	[super dealloc];
}

//--------------------------------------------------------------------
//----------- Bundle delegates ---------------------------------------
//--------------------------------------------------------------------
/**
\brief gets called ig the nib file has been loaded. all gfx objacts are available now.
 */
- (void)awakeFromNib {
	CocoLog(LEVEL_DEBUG,@"[MBExtendedImageViewController -awakeFromNib]");
	
	if(self != nil) {
		// calculate collapse height
		collapseHeight = [extendedImageView frame].size.height - [[imageView superview] frame].size.height;

		// init ImageConverter
		[MBImageConverter defaultConverter];
		
		// register NSViewFrameDidChangeNotification
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(viewFrameDidChange:) 
													 name:NSViewFrameDidChangeNotification 
												   object:extendedImageView];
		
		// set nil image
		//[self setImage:nil];
		
		// set menu for scaleProp
		NSMenu *subMenu = [[NSMenu alloc] init];
		NSMenuItem *mItem = [[NSMenuItem alloc] init];
		[mItem setTitle:MBLocaleStr(@"ManualScale")];
		[mItem setTag:NoScaling];
		[mItem setAction:@selector(scalePropChange:)];
		[mItem setTarget:self];
		// deactivate this state
		[mItem setState:NSOffState];
		[subMenu addItem:mItem];
		[mItem release];
		//
		mItem = [[NSMenuItem alloc] init];
		[mItem setTitle:MBLocaleStr(@"ScaleToFit")];
		[mItem setTag:ScaleToFit];
		[mItem setAction:@selector(scalePropChange:)];
		[mItem setTarget:self];
		// activate this state
		[mItem setState:NSOnState];
		[subMenu addItem:mItem];
		[mItem release];
		// 
		[scalePropPopUpButton setMenu:subMenu];
		[subMenu release];
		
		// set initial affine tzransformation
		[imageView setAffineTransform:[NSAffineTransform transform]];
		
		// preselect scaletofit
		[scalePropPopUpButton selectItemWithTitle:MBLocaleStr(@"ScaleToFit")];
		
		// set imageview to size to fit
		[self scalePropChange:mItem];
	}
}

/**
 \brief return the view itself
*/
- (NSView *)extendedImageView {
	return extendedImageView;
}

- (float)collapseHeight {
	return collapseHeight;
}

- (void)setDelegate:(id)aDelegate {
	delegate = aDelegate;
}

- (id)delegate {
	return delegate;
}

// setting and getting the image
- (void)setImage:(NSImage *)aImage {
	// set image to imageViewer
	[imageView setImage:aImage];
	
	// set affine transformation
	[imageView setAffineTransform:[NSAffineTransform transform]];
	
	// force display
	if(aImage != nil) {
		//[imageView display];
		[extendedImageView display];
	}
	
	// call scalePropChange to display the image
	[self scalePropChange:[[scalePropPopUpButton menu] itemWithTag:currentScaleProp]];
	
	[self setZoomControlsOfCurrentImageSize];
}

- (NSImage *)image {
	return [imageView image];
}

/**
\brief figure what should be printed, prepare views and show print dialog
 */
- (IBAction)print:(id)sender {
	CocoLog(LEVEL_DEBUG,@"[MBExtendedImageViewController -print:]");
	
	// use MBPrintController
	MBPrintController *pC = [MBPrintController defaultPrintController];
	[pC printView:imageView];
}

/**
 \brief save image as
*/
- (IBAction)saveAs:(id)sender {
	// get ImageConverter
	MBImageConverter *ic = [MBImageConverter defaultConverter];
	
	// open Save Panel
	NSSavePanel *sp = [NSSavePanel savePanel];
	[sp setAccessoryView:[ic accessoryView]];
	[sp setCanCreateDirectories:YES];
	[sp setCanSelectHiddenExtension:YES];

	/* display the NSSavePanel */
	int runResult = [sp runModalForDirectory:NSHomeDirectory() file:@""];
	/* if successful, save file under designated name */
	if(runResult == NSOKButton) {
		MBExporter *exporter = [MBExporter defaultExporter];
		// get extension for selected imagetype
		NSString *ext = [MBImageConverter fileExtensionForImageType:[ic conversionImageType]];
		// build filename with extension
		NSString *filename = [exporter generateFilenameWithExtension:ext 
														fromFilename:[sp filename]];
		
		// convert image data
		NSData *imageData = [MBImageConverter convertImageData:[[self image] TIFFRepresentation] 
												   toImageType:[ic conversionImageType]];
		// save data
		[imageData writeToFile:filename atomically:YES];
	}
}

- (IBAction)scalePropChange:(id)sender {
	if([sender tag] == NoScaling) {
		CocoLog(LEVEL_DEBUG,@"[MBExtendedImageViewController -scalePropChange:] no scaling");
		
		[imageView setImageScaling:NSScaleNone];
		if([imageView image] != nil) {
			// set imageView to that size
			[imageView setFrameSize:[[imageView image] size]];
		}
		
		// activate scaling and setting the orig size
		[zoomNumberInputTextField setEnabled:YES];
		[zoomSlider setEnabled:YES];
		
		// set to 100%
		[zoomNumberInputTextField setObjectValue:[NSNumber numberWithFloat:100.0]];
		[self zoomNumberInput:zoomNumberInputTextField];
		
		// generate matrix
		[self generateTransform];
		
		// set current scale prop
		currentScaleProp = NoScaling;
	} else if([sender tag] == ScaleToFit) {
		CocoLog(LEVEL_DEBUG,@"[MBExtendedImageViewController -scalePropChange:] scale to fit");

		if([imageView image] != nil) {
			// get size of visible part of scrollview
			NSRect visibleRect = [[imageView superview] visibleRect];
			// set imageView to that size
			[imageView setFrameSize:visibleRect.size];
		}
		
		// now change scale behaviour of imageView
		[imageView setImageScaling:NSScaleProportionally];
		
		// deactivate scaling and setting the orig size
		[zoomNumberInputTextField setEnabled:NO];
		[zoomSlider setEnabled:NO];
		
		// set current scale prop
		currentScaleProp = ScaleToFit;

		// set zoom values
		[self setZoomControlsOfCurrentImageSize];
		
		// generate new transformation
		[self generateTransform];
	}
}

- (IBAction)zoomSliderChange:(id)sender {
	CocoLog(LEVEL_DEBUG,@"[MBExtendedImageViewController -zoomChange:] zoom changed to value:%f",[sender floatValue]);
	
	if(currentScaleProp == NoScaling) {
		// the float value here is the percentage we zoom
		float zoom = [sender floatValue];
		
		// calculate the new size
		NSSize newSize;
		newSize.height = [[imageView image] size].height * zoom;
		newSize.width = [[imageView image] size].width * zoom;

		// we a affine transformation only with the rotation, not the scaling
		NSAffineTransform *affine = [NSAffineTransform transform];
		[affine rotateByDegrees:rotateDegrees];
		
		// get the new image size
		newSize = [affine transformSize:newSize];
		// we need abs of that
		newSize.height = fabsf(newSize.height);
		newSize.width = fabsf(newSize.width);

		// scale the imageviewitself
		[imageView setFrameSize:newSize];

		// generate new transform
		[self generateTransform];

		// set zoom number input field to that value
		[zoomNumberInputTextField setObjectValue:[NSNumber numberWithFloat:(zoom * 100.0)]];
	}
}

- (IBAction)zoomNumberInput:(id)sender {
	// the float value here is the percentage we zoom
	float zoom = [[sender objectValue] floatValue];
	
	if(zoom > 0.0) {
		// calculate the new size
		NSSize newSize;
		newSize.height = [[imageView image] size].height * (zoom / 100.0);
		newSize.width = [[imageView image] size].width * (zoom / 100.0);

		// we a affine transformation only with the rotation, not the scaling
		NSAffineTransform *affine = [NSAffineTransform transform];
		[affine rotateByDegrees:rotateDegrees];
		
		// get the new image size
		newSize = [affine transformSize:newSize];
		// we need abs of that
		newSize.height = fabsf(newSize.height);
		newSize.width = fabsf(newSize.width);

		// scale the imageviewitself
		[imageView setFrameSize:newSize];

		// generate new transform
		[self generateTransform];
		
		// set slider to that value
		[zoomSlider setFloatValue:(zoom / 100.0)];
	}
}

/**
 \brief rotate
 tag 0: left, tag 1: right
*/
- (IBAction)rotate:(id)sender {
	int tag = [sender tag];
	if(tag == 0) {
		// left
		rotateDegrees += 90.0;
	} else {
		// right
		rotateDegrees -= 90.0;
	}
	
	if(currentScaleProp == NoScaling) {
		// generate new matrix
		[self generateTransform];

		// get the new image size
		NSSize newSize = [[imageView affineTransform] transformSize:[[imageView image] size]];
		// we need abs of that
		newSize.height = fabsf(newSize.height);
		newSize.width = fabsf(newSize.width);

		CocoLog(LEVEL_DEBUG,@"[MBExtendedImageViewController -rotate:] newSize.height = %f, newSize.width = %f",newSize.height,newSize.width);
		
		// set imageView to that size
		[imageView setFrameSize:newSize];
	} else {
		[self setZoomControlsOfCurrentImageSize];
		// generate new matrix
		[self generateTransform];
	}
}

// ----------------------------------------------------------
// MBSlider delegate methods
// ----------------------------------------------------------
- (void)viewFrameDidChange:(NSNotification *)aNotification {
	CocoLog(LEVEL_DEBUG,@"[MBExtendedImageViewController -viewFrameDidChange:]!");

	[self setZoomControlsOfCurrentImageSize];
	// generate new matrix
	[self generateTransform];
}

@end
