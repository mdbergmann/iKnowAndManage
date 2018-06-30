//
//  MBImageConverter.m
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

#import <CocoLogger/CocoLogger.h>
#import "MBImageConverter.h"

@interface MBImageConverter (privateAPI)

@end

@implementation MBImageConverter (privateAPI)

@end

@implementation MBImageConverter

+ (MBImageConverter *)defaultConverter
{
	static MBImageConverter *singleton;
	
	if(singleton == nil)
	{
		singleton = [[MBImageConverter alloc] init];
	}
	
	return singleton;
}

- (id)init
{
	self = [super init];
	if(self == nil)
	{
		CocoLog(LEVEL_ERR,@"cannot alloc MBImageConverter!");		
	}
	else
	{
		BOOL success = [NSBundle loadNibNamed:ACCESSORY_CONTROLLER_NIB_NAME owner:self];
		if(success)
		{
		}
		else
		{
			CocoLog(LEVEL_ERR,@"cannot load ImageSaveAccessory.nib!");
		}		
	}
	
	return self;
}

/**
\brief dealloc of this class is called on closing this document
 */
- (void)dealloc
{
	// dealloc object
	[super dealloc];
}

/**
 \brief nib has been loaded
*/
- (void)awakeFromNib
{
	// create popupButton Menu for Image types
	NSMenu *subMenu = [[NSMenu alloc] init];
	NSMenuItem *mItem = [[NSMenuItem alloc] init];
	[mItem setTitle:@"JPEG"];
	[mItem setTag:NSJPEGFileType];
	[mItem setAction:@selector(imageFileTypeSelected:)];
	[mItem setTarget:self];
	// activate this state
	[mItem setState:NSOnState];
	[subMenu addItem:mItem];
	[mItem release];
	//
	// use JPEG2000 only in Tiger and above
	if(floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_3_5)
	{
		// we have tiger
		mItem = [[NSMenuItem alloc] init];
		[mItem setTitle:@"JPEG2000"];
		[mItem setTag:NSJPEG2000FileType];
		[mItem setAction:@selector(imageFileTypeSelected:)];
		[mItem setTarget:self];
		// deactivate this state
		[mItem setState:NSOffState];
		[subMenu addItem:mItem];
		[mItem release];
	}
	// 
	mItem = [[NSMenuItem alloc] init];
	[mItem setTitle:@"PNG"];
	[mItem setTag:NSPNGFileType];
	[mItem setAction:@selector(imageFileTypeSelected:)];
	[mItem setTarget:self];
	// deactivate this state
	[mItem setState:NSOffState];
	[subMenu addItem:mItem];
	[mItem release];
	// 
	mItem = [[NSMenuItem alloc] init];
	[mItem setTitle:@"GIF"];
	[mItem setTag:NSGIFFileType];
	[mItem setAction:@selector(imageFileTypeSelected:)];
	[mItem setTarget:self];
	// deactivate this state
	[mItem setState:NSOffState];
	[subMenu addItem:mItem];
	[mItem release];
	// 
	mItem = [[NSMenuItem alloc] init];
	[mItem setTitle:@"BMP"];
	[mItem setTag:NSBMPFileType];
	[mItem setAction:@selector(imageFileTypeSelected:)];
	[mItem setTarget:self];
	// deactivate this state
	[mItem setState:NSOffState];
	[subMenu addItem:mItem];
	[mItem release];
	// 
	mItem = [[NSMenuItem alloc] init];
	[mItem setTitle:@"TIFF"];
	[mItem setTag:NSTIFFFileType];
	[mItem setAction:@selector(imageFileTypeSelected:)];
	[mItem setTarget:self];
	// deactivate this state
	[mItem setState:NSOffState];
	[subMenu addItem:mItem];
	[mItem release];
	
	[imageTypePopUpButton setMenu:subMenu];
	[subMenu release];
}

/**
 \brief the image converter
*/
+ (NSData *)convertImageData:(NSData *)tiffData toImageType:(NSBitmapImageFileType)imageType
{
	NSData *convertedImageData = nil;
	
	if((tiffData == nil) || ([tiffData length] == 0))
	{
		CocoLog(LEVEL_WARN,@"tiffData is nil or empty!");
	}
	else
	{
		// make BitmapImagerep out of tiff data
		NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:tiffData];
		if(imageRep == nil)
		{
			CocoLog(LEVEL_WARN,@"could not create imagerep of tiff data!");
		}
		else
		{
			convertedImageData = [imageRep representationUsingType:imageType 
														properties:nil];
			if(convertedImageData == nil)
			{
				CocoLog(LEVEL_WARN,@"could not convert image data!");
			}
		}
	}
	
	return convertedImageData;
}

/**
 \brief delivers the appropriate file extension for the given filetype
*/
+ (NSString *)fileExtensionForImageType:(NSBitmapImageFileType)imageType
{
	NSString *ext = nil;
	
	switch(imageType)
	{
		case NSJPEGFileType:
			ext = @"jpg";
			break;
		case NSJPEG2000FileType:
			ext = @"jp2";
			break;
		case NSGIFFileType:
			ext = @"gif";
			break;
		case NSPNGFileType:
			ext = @"png";
			break;
		case NSBMPFileType:
			ext = @"bmp";
			break;
		case NSTIFFFileType:
			ext = @"tif";
			break;
	}
	
	return ext;
}

- (void)setConversionImageType:(NSBitmapImageFileType)imageType
{
	conversionImageType = imageType;
}

- (NSBitmapImageFileType)conversionImageType
{
	return conversionImageType;
}

- (NSView *)accessoryView
{
	return accessoryView;
}

// -------------------------------------------------------------
// actions for menuitems
// -------------------------------------------------------------
- (IBAction)imageFileTypeSelected:(id)sender
{
    [self setConversionImageType:(NSBitmapImageFileType) [sender tag]];
}

@end
