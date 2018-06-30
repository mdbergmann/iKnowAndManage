//
//  MBImageConverter.h
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 27.09.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>

#define ACCESSORY_CONTROLLER_NIB_NAME		@"ImageSaveAccessory"

@interface MBImageConverter : NSObject 
{
	IBOutlet NSView *accessoryView;
	IBOutlet NSPopUpButton *imageTypePopUpButton;
	
	NSBitmapImageFileType conversionImageType;
}

+ (MBImageConverter *)defaultConverter;

+ (NSData *)convertImageData:(NSData *)tiffData toImageType:(NSBitmapImageFileType)imageType;
+ (NSString *)fileExtensionForImageType:(NSBitmapImageFileType)imageType;

- (NSView *)accessoryView;

- (void)setConversionImageType:(NSBitmapImageFileType)imageType;
- (NSBitmapImageFileType)conversionImageType;

- (IBAction)imageFileTypeSelected:(id)sender;

@end
