//
//  MBImageValueDetailViewController.h
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 08.07.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import "MBImageValueDetailViewController.h"
#import "MBImageItemValue.h"
#import "globals.h"
#import "GlobalWindows.h"
#import "MBExtendedImageViewController.h"

// NSOpenPanel context infos
extern NSString *ImportFileContext;
extern NSString *SetPathContext;
extern NSString *OpenFileWithAppContext;

@interface MBImageValueDetailViewController (privateAPI)

@end

@implementation MBImageValueDetailViewController (privateAPI)

@end


@implementation MBImageValueDetailViewController

- (id)init {
	self = [super init];
	if(self) {
		// set imageViewer
		imageViewer = [MBExtendedImageViewController standardImageViewController];
	}
	
	return self;
}

- (void)dealloc {
	// dealloc object
	[super dealloc];
}

- (void)awakeFromNib {
}

- (void)displayInfo {
    [super displayInfo];
	MBImageItemValue *itemval = (MBImageItemValue *)currentItemValue;	
	if(itemval != nil) {
		if([itemval encryptionState] != EncryptedState) {
			// display image type
			[imageTypeLabel setStringValue:[itemval imageType]];

			// empty preview field
			[imagePreview setImage:nil];
            
			// empty extended image viewer
            if(![itemval isLink]) {
                [imageViewer setImage:[itemval image]];
            }
				 
			// display preview
			[imagePreview setImage:[itemval thumbImage]];
			
			// display image info
			[imageInfoPixelWidth setStringValue:[[NSNumber numberWithFloat:[itemval imageSize].width] stringValue]];
			[imageInfoPixelHeight setStringValue:[[NSNumber numberWithFloat:[itemval imageSize].height] stringValue]];
			[imageInfoSize setStringValue:[[NSNumber numberWithInt:([itemval imageByteSize] / 1024)] stringValue]];
			[imageInfoBpp setStringValue:[[NSNumber numberWithInt:[[NSBitmapImageRep imageRepWithData:[itemval thumbData]] bitsPerPixel]] stringValue]];
		} else {
			// imagetype
			[imageTypeLabel setStringValue:MBLocaleStr(@"Unknown")];

			// preview
			[imagePreview setImage:nil];
		}	
	}
}

- (IBAction)acc_LinkValueInput:(id)sender {
	if(currentItemValue != nil) {
		if([[sender stringValue] length] > 0) {
			[(MBImageItemValue *)currentItemValue setLinkValueAsString:[sender stringValue]];

			// do load automatically
			if([(MBImageItemValue *)currentItemValue autoHandleLoadSave]) {
				[self acc_Load:nil];
			}
			
			// if there is a thumbnail, load it
			[imagePreview setImage:[(MBImageItemValue *)currentItemValue thumbImage]];
			
			// display URL status
			[self displayURLStatusInfo];
		}
	}		
}

/**
 \brief loadButton action selector
*/
- (IBAction)acc_Load:(id)sender {
	MBImageItemValue *itemval = (MBImageItemValue *)currentItemValue;
	if(itemval != nil) {
		// start progress indicator
		[progressIndicator startAnimation:nil];
		
		NSData *data = nil;
		if([itemval isLink]) {
			// load image data
			data = [itemval valueDataByLoadingFromTarget];
			if(data == nil) {
				CocoLog(LEVEL_WARN,@"[MBImageValueDetailViewController -acc_Load] cannot display data!");
				// bring up alert sheet
				NSBeginAlertSheet(MBLocaleStr(@"Warning"),
								  MBLocaleStr(@"OK"),nil,nil,
								  [GlobalWindows mainAppWindow],nil,nil,nil,nil,
								  MBLocaleStr(@"CouldNotLoadFromLink"));
			} else {
				// set imageByteSize
				[itemval setImageByteSize:[data length]];
				// load image
				NSImage *image = [[[NSImage alloc] initWithData:data] autorelease];
				// display big picture
				[imageViewer setImage:image];

				// create NSBitmapImageRep for creating thumbnail
				NSBitmapImageRep *bitmapRep = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]];
				// and create thumbnail from this
				NSImage *thumb = [itemval generateThumbnailOfImageRep:bitmapRep];
				[imagePreview setImage:thumb];
				// save
				[itemval setThumbImage:thumb];
			}
		} else {
			// set image
			[imageViewer setImage:[itemval image]];
		}

		// stop progress indicator
		[progressIndicator stopAnimation:nil];
	}
}

@end
