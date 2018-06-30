//
//  MBFormatPrefsViewController.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 15.09.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <CocoLogger/CocoLogger.h>
#import "MBFormatPrefsViewController.h"
#import "MBFormatSetterController.h"
#import "MBDateFormatSetterViewController.h"
#import "MBNumberFormatSetterViewController.h"
#import "globals.h"


@implementation MBFormatPrefsViewController

- (id)init
{
	CocoLog(LEVEL_DEBUG, @"init of MBFormatPrefsViewController");
	
	self = [super init];
	if(self == nil)
	{
		CocoLog(LEVEL_ERR, @"cannot alloc MBFormatPrefsViewController!");
	}
	else
	{
		// init formatSetterController
		formatSetterController = [[MBFormatSetterController alloc] init];		
	}
	
	return self;
}

/**
\brief dealloc of this class is called on closing this document
 */
- (void)dealloc
{
	CocoLog(LEVEL_DEBUG, @"dealloc of MBFormatPrefsViewController");
	
	// release formatSetterController
	[formatSetterController release];
	
	// dealloc object
	[super dealloc];
}

//--------------------------------------------------------------------
//----------- bundle delegates ---------------------------------------
//--------------------------------------------------------------------
- (void)awakeFromNib
{
	CocoLog(LEVEL_DEBUG, @"awakeFromNib of MBFormatPrefsViewController");
	
	if(self != nil)
	{
		// load FormatSetterNib, so we have the views we need
		BOOL success = [NSBundle loadNibNamed:FORMAT_SETTER_NIB_NAME owner:formatSetterController];
		if(success == YES)
		{
			// set delegate
			[[formatSetterController dateFormatSetterController] setDelegate:self];

			// set views to TabViewItems
			for(int i = 0;i < [[tabView tabViewItems] count];i++)
			{
				NSTabViewItem *item = [tabView tabViewItemAtIndex:i];
				if([[item identifier] isEqualToString:@"numberformat"])
				{
					// set contentview
					MBNumberFormatSetterViewController *numberFormatSetterController = [formatSetterController numberFormatSetterController];
					[item setView:[numberFormatSetterController theView]];
					// set begin type
					[numberFormatSetterController setValuesForType:NumberFormatType];
				}
				else if([[item identifier] isEqualToString:@"dateformat"])
				{
					// set contentview
					MBDateFormatSetterViewController *dateFormatSetterController = [formatSetterController dateFormatSetterController];
					[item setView:[dateFormatSetterController theView]];
					
					// set some defaults
					[dateFormatSetterController setAllowNatLanguage:(BOOL)[[userDefaults valueForKey:MBDefaultsDateFormatAllowNaturalLanguageKey] intValue]];
					[dateFormatSetterController setDateFormatString:[userDefaults valueForKey:MBDefaultsDateFormatKey]];
				}
			}
		}
		else
		{
			CocoLog(LEVEL_ERR,@"[MBPreferenceController]: cannot load FormatSetterNib!");
		}
		
		// init the viewRect
		viewFrame = [theView frame];
	}
}

/**
 \brief return the view itself
*/
- (NSView *)theView
{
	return theView;
}

- (NSRect)viewFrame
{
	return viewFrame;
}

// -------------------------------------------------
// MBDateFormatSetterViewController delegate methods
// -------------------------------------------------
- (void)formatStringSettingOfDateSetterControllerChanged:(id)sender
{
	// write setting to defaults
	[userDefaults setObject:[sender dateFormatString] forKey:MBDefaultsDateFormatKey];	
}

- (void)allowNatLanguageSettingOfDateSetterControllerChanged:(id)sender
{
	// write setting to defaults
	[userDefaults setObject:[NSNumber numberWithBool:[sender allowNatLanguage]] forKey:MBDefaultsDateFormatAllowNaturalLanguageKey];
}

@end
