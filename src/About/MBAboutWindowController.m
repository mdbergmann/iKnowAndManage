//  Created by Manfred Bergmann on 25.07.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import "MBAboutWindowController.h"

@implementation MBAboutWindowController

/**
\brief init is called after alloc:. some initialization work can be done here.
 No GUI elements are available here. It additinally calls the init method of superclass
 @returns initialized not nil object
 */
- (id)init
{
	CocoLog(LEVEL_DEBUG,@"init of MBAboutWindowController");
	
	self = [super initWithWindowNibName:@"About"];
	if(self == nil)
	{
		CocoLog(LEVEL_ERR,@"cannot alloc MBAboutWindowController!");		
	}
	else
	{
	}
	
	return self;
}

/**
\brief dealloc of this class is called on closing this document
 */
- (void)dealloc
{
	CocoLog(LEVEL_DEBUG, @"dealloc of MBAboutWindowController");
	
	// dealloc object
	[super dealloc];
}

//--------------------------------------------------------------------
//----------- bundle delegates ---------------------------------------
//--------------------------------------------------------------------
- (void)windowDidLoad
{
	CocoLog(LEVEL_DEBUG, @"windowDidLoad of MBAboutWindowController");
	
	if(self != nil) {
		// get BundlePath
		NSString *infoPlistPath = [[NSBundle mainBundle] bundlePath];
		infoPlistPath = [infoPlistPath stringByAppendingPathComponent:@"Contents"];
		infoPlistPath = [infoPlistPath stringByAppendingPathComponent:@"Info.plist"];
		// get build number
		NSDictionary *infoPlist = [NSDictionary dictionaryWithContentsOfFile:infoPlistPath];
		NSString *buildNumber = [infoPlist objectForKey:@"CFBundleShortVersionString"];
		
		// set version
		[versionLabel setStringValue:[NSString stringWithFormat:@"Version: %@", buildNumber]];
		// set credit rtf text
		NSMutableString *resourcePath = [NSMutableString stringWithString:[[NSBundle mainBundle] resourcePath]];
		CocoLog(LEVEL_DEBUG, @"%@", resourcePath);
		NSString *creditPath = [resourcePath stringByAppendingPathComponent:@"English.lproj/Credits.rtf"];
		CocoLog(LEVEL_DEBUG, @"%@", creditPath);
		
		NSData *rtfData = [NSData dataWithContentsOfFile:creditPath];
		NSAttributedString *credits = [[[NSAttributedString alloc] initWithRTF:rtfData documentAttributes:nil] autorelease];
		// insert the text into the textview
		[creditsTextView insertText:credits];
        
        // make textview none editable
        [creditsTextView setEditable:NO];
	}
}

@end
