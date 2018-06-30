//
//  MBImageValueDetailViewController.h
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 16.09.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>
#import "MBFileBaseDetailViewController.h"

@class MBExtendedImageViewController;

@interface MBImageValueDetailViewController : MBFileBaseDetailViewController {
	IBOutlet NSImageView *imagePreview;
	IBOutlet NSTextField *imageTypeLabel;
	IBOutlet NSTextField *imageInfoPixelWidth;
	IBOutlet NSTextField *imageInfoPixelHeight;
	IBOutlet NSTextField *imageInfoBpp;
	IBOutlet NSTextField *imageInfoSize;
	
	// the image viewer
	MBExtendedImageViewController *imageViewer;
}

@end
