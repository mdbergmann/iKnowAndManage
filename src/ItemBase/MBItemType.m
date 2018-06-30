//
//  MBItemType.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 20.07.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import "MBItemType.h"
#import "globals.h"

@implementation MBItemType

/**
\brief singleton to return all available elementtypes with their string name
 */
+ (NSArray *)itemTypes {
	NSArray *types = [NSArray arrayWithObjects:
		STD_ITEMTYPE_NAME,
		TABLE_ITEMTYPE_NAME,
		TEMPLATE_ITEMTYPE_NAME,
		//CONTACT_ITEMTYPE_NAME,
		TRASHCAN_ITEMTYPE_NAME,
		UNDO_ITEMTYPE_NAME,
		nil];
	
	return types;
}

+ (NSArray *)systemItemTypes {
	NSArray *types = [NSArray arrayWithObjects:
		TEMPLATE_ITEMTYPE_NAME,
		//CONTACT_ITEMTYPE_NAME,
		TRASHCAN_ITEMTYPE_NAME,
		nil];
	
	return types;	
}

+ (NSArray *)itemValueTypes {
	NSArray *types = [NSArray arrayWithObjects:
		SIMPLETEXT_ITEMVALUE_TYPE_NAME,
        @"Unset",
		NUMBER_ITEMVALUE_TYPE_NAME,
		CURRENCY_ITEMVALUE_TYPE_NAME,
		BOOL_ITEMVALUE_TYPE_NAME,
		DATE_ITEMVALUE_TYPE_NAME,
		URL_ITEMVALUE_TYPE_NAME,
        @"Unset",
        @"Unset",
        @"Unset",
        @"Unset",
        @"Unset",
        @"Unset",
        @"Unset",
        @"Unset",
        @"Unset",
        @"Unset",
        @"Unset",
        @"Unset",
        @"Unset",
		FILE_ITEMVALUE_TYPE_NAME,
		IMAGE_ITEMVALUE_TYPE_NAME,
        PDF_ITEMVALUE_TYPE_NAME,
        EXTENDEDTEXT_ITEMVALUE_TYPE_NAME,
		nil];
	
	return types;
}

/**
 \brief this sets te default filetype itemvalue assignments
 @returns an NSDictionary with fileextensions as keys and Itemvaluetypes as values
 for text itemtypes we use the extended texttypes which define TXT,RTF,RTFD types.
*/
+ (NSDictionary *)defaultFileValueTypeSpec; {
	// the main dictionary
	NSMutableDictionary *typeSpec = [NSMutableDictionary dictionary];
	
	// Extended texts is another dictionary where for every filetype (key)
	// a texttype is specified
	[typeSpec setObject:[NSNumber numberWithInt:ExtendedTextTXTValueType] forKey:@"txt"];		// txt
	[typeSpec setObject:[NSNumber numberWithInt:ExtendedTextRTFValueType] forKey:@"rtf"];		// rtf
	[typeSpec setObject:[NSNumber numberWithInt:ExtendedTextRTFDValueType] forKey:@"rtfd"];	// rtfd
	[typeSpec setObject:[NSNumber numberWithInt:ExtendedTextTXTValueType] forKey:@"html"];		// html
	[typeSpec setObject:[NSNumber numberWithInt:ExtendedTextTXTValueType] forKey:@"pl"];		// perl source
	[typeSpec setObject:[NSNumber numberWithInt:ExtendedTextTXTValueType] forKey:@"java"];		// java source
	[typeSpec setObject:[NSNumber numberWithInt:ExtendedTextTXTValueType] forKey:@"c"];		// c source
	[typeSpec setObject:[NSNumber numberWithInt:ExtendedTextTXTValueType] forKey:@"cpp"];		// cpp source
	[typeSpec setObject:[NSNumber numberWithInt:ExtendedTextTXTValueType] forKey:@"c++"];		// cpp source
	[typeSpec setObject:[NSNumber numberWithInt:ExtendedTextTXTValueType] forKey:@"m"];		// objc source
	[typeSpec setObject:[NSNumber numberWithInt:ExtendedTextTXTValueType] forKey:@"mm"];		// objc++ source
	[typeSpec setObject:[NSNumber numberWithInt:ExtendedTextTXTValueType] forKey:@"h"];		// header source
	[typeSpec setObject:[NSNumber numberWithInt:ExtendedTextTXTValueType] forKey:@"php"];		// php source	

    // pdf spec
	[typeSpec setObject:[NSNumber numberWithInt:PDFItemValueType] forKey:@"pdf"];		// pdf    
    
	// take all images that Cocoa is aware of
	// image types
	NSEnumerator *iter = [[NSImage imageFileTypes] objectEnumerator];
	NSString *str = nil;
	while((str = [iter nextObject])) {
		// if there a trailing "'"?
		// get first character
		unichar c = [str characterAtIndex:0];
		if(c == '\'') {
			// leave this out
		} else if([[str lowercaseString] isEqualToString:@"pdf"]) {
			// we don't want pdf in here
			// if the user wants to treat pdf as image, he should specify it in prefs
		} else {
			// makelowercase
			NSString *lowerStr = [str lowercaseString];
			// add to dict
			// some filetypes exists more thsan once, in lower and upper case
			// with adding them to a dict, only one will survive and we can return all keys as array
			[typeSpec setObject:[NSNumber numberWithInt:ImageItemValueType] forKey:lowerStr];
		}
	}
		
	// return main spec dict
	return typeSpec;
}

@end
