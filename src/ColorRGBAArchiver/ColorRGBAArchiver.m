//
//  ColorRGBAArchiver.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 28.07.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import "ColorRGBAArchiver.h"

@implementation NSColor (ColorRGBAArchiver)

/**
 \brief archive the RGBA components of this color object. NSData object is autoreleased
*/
- (NSData *)archiveRGBAComponentsAsData
{
	// init the NSData object we are writing to
	NSMutableData *colorData = [NSMutableData data];
	// the archiver we want to use
	NSKeyedArchiver *archiver = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:colorData] autorelease];
	// choose output format
	//[archiver setOutputFormat:NSPropertyListBinaryFormat_v1_0];
	[archiver setOutputFormat:NSPropertyListXMLFormat_v1_0];
	// check, if we are operating in RGB colorspace
	NSColor *rgbCol = nil;
	if([[self colorSpaceName] isEqualToString:NSCalibratedRGBColorSpace] == NO)
	{
		rgbCol = (NSColor *)[self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	}
	else
	{
		rgbCol = self;
	}
	
	// archive components
	[archiver encodeFloat:[rgbCol redComponent] forKey:@"RedComponent"];
	[archiver encodeFloat:[rgbCol greenComponent] forKey:@"GreenComponent"];
	[archiver encodeFloat:[rgbCol blueComponent] forKey:@"BlueComponent"];
	[archiver encodeFloat:[rgbCol alphaComponent] forKey:@"AlphaComponent"];
	[archiver finishEncoding];
	
	return colorData;
}

/**
 \brief creates a color object with reading RGBA values from encoded NSData object
*/
+ (NSColor *)colorFromRGBAArchivedData:(NSData *)aData
{
	NSColor *newCol = nil;
	
	if(aData != nil)
	{
		// create unarchiver
		NSKeyedUnarchiver *unarchiver = [[[NSKeyedUnarchiver alloc] initForReadingWithData:aData] autorelease];
		// decode data
		float red = [unarchiver decodeFloatForKey:@"RedComponent"];
		float green = [unarchiver decodeFloatForKey:@"GreenComponent"];
		float blue = [unarchiver decodeFloatForKey:@"BlueComponent"];
		float alpha = [unarchiver decodeFloatForKey:@"AlphaComponent"];
		
		// create NSColor object
		newCol = [NSColor colorWithDeviceRed:red green:green blue:blue alpha:alpha];		
	}
	else
	{
		CocoLog(LEVEL_WARN,@"[ColorRGBAArchiver colorFromRGBAArchivedData:]: given NSData object is nil!");
	}

	return newCol;
}

/**
 \brief archive the RGBA components of this color object to a string
*/
- (NSString *)archiveRGBAComponentsAsString
{
	// check, if we are operating in RGB colorspace
	NSColor *rgbCol = nil;
	if([[self colorSpaceName] isEqualToString:NSCalibratedRGBColorSpace] == NO)
	{
		rgbCol = (NSColor *)[self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	}
	else
	{
		rgbCol = self;
	}
	
	return [NSString stringWithFormat:@"%f:%f:%f:%f",
		[rgbCol redComponent],
		[rgbCol greenComponent],
		[rgbCol blueComponent],
		[rgbCol alphaComponent]];
}

/**
 \brief unarchive the archived RGBA components with -archiveRGBAComponentsAsDataAsString to a NSColor object.
*/
+ (NSColor *)colorFromRGBAArchivedString:(NSString *)aString
{
	// scan the archived rgba color components
	float red = 0;
	float green = 0;
	float blue = 0;
	float alpha = 0;
	
	// parse string
	NSString *comp = nil;
	int oldIndex = 0;
	int numberOfDelimiters = 0;
	for(int i = 0;i < [aString length];i++)
	{
		if([aString characterAtIndex:i] == ':')
		{
			// found delimiter
			// make float out of substring
			comp = [aString substringWithRange:NSMakeRange(oldIndex,(i-oldIndex))];
			// use the right component
			if(numberOfDelimiters == 0)
			{
				// this is red
				red = [comp floatValue];
			}
			else if(numberOfDelimiters == 1)
			{
				// this is green
				green = [comp floatValue];
			}
			else if(numberOfDelimiters == 2)
			{
				// this is blue
				blue = [comp floatValue];
			}
			numberOfDelimiters++;

			// increment oldIndex
			oldIndex = i+1;
		}
	}
	// if we have 3 delimiters, we have 4 components (beginning at 0)
	// get the last component
	// make float out of substring
	comp = [aString substringWithRange:NSMakeRange(oldIndex,([aString length]-oldIndex))];
	alpha = [comp floatValue];
	
	// make color out of components
	NSColor *newCol = [NSColor colorWithDeviceRed:red green:green blue:blue alpha:alpha];		

	return newCol;
}

@end
