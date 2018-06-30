
#import <CocoLogger/CocoLogger.h>
#import "MBPreferenceController.h"
#import "MBGeneralPrefsViewController.h"
#import "MBDatabasePrefsViewController.h"
#import "MBFormatPrefsViewController.h"
#import "MBImExportPrefsViewController.h"
#import "MBPrivacyPrefsViewController.h"

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

@implementation MBPreferenceController

/**
\brief init is called after alloc:. some initialization work can be done here.
 No GUI elements are available here. It additinally calls the init method of superclass
 @returns initialized not nil object
 */
- (id)init
{
	CocoLog(LEVEL_DEBUG, @"init of MBPreferenceController");
	
	self = [super init];
	if(self == nil)
	{
		CocoLog(LEVEL_ERR, @"cannot alloc MBPreferenceController!");
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
	CocoLog(LEVEL_DEBUG, @"dealloc of MBPreferenceController");

	// dealloc object
	[super dealloc];
}

/**
 \brief the sheet is linked to a window, this sets the window, the sheet should come up
*/
- (void)setSheetWindow:(NSWindow *)aWindow
{
	sheetWindow = aWindow;
}

- (NSWindow *)sheetWindow
{
	return sheetWindow;
}

//--------------------------------------------------------------------
//----------- bundle delegates ---------------------------------------
//--------------------------------------------------------------------
- (void)awakeFromNib
{
	CocoLog(LEVEL_DEBUG, @"awakeFromNib of MBPreferenceController");
	
	if(self != nil)
	{
		// calculate margins
		northMargin = (int) ([sheet frame].size.height - southMargin - [prefsTabView frame].size.height);
		southMargin = (int) [prefsTabView frame].origin.y;
		sideMargin = (int) (([sheet frame].size.width - [prefsTabView frame].size.width) / 2);
		//sideMargin = 0;
		
		// topTabViewmargin
		topTabViewMargin = (int) ([prefsTabView frame].size.height - [prefsTabView contentRect].size.height);
		
		// init tabview
		//preselect tabitem general
		NSTabViewItem *tvi = [prefsTabView tabViewItemAtIndex:0];
		[prefsTabView selectTabViewItem:tvi];
		// call delegate directly
		[self tabView:prefsTabView didSelectTabViewItem:tvi];
	}
}

//--------------------------------------------------------------------
// NSTabView delegates
//--------------------------------------------------------------------
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	// alter the size of the sheet to display the tab
	NSRect viewframe;
	NSView *prefsView = nil;
	
	// set nil contentview
	//[tabViewItem setView:prefsView];
	
	if([[tabViewItem identifier] isEqualToString:@"general"])
	{
		// set view
		viewframe = [generalViewController viewFrame];
		prefsView = [generalViewController theView];
	}
	else if([[tabViewItem identifier] isEqualToString:@"database"])
	{
		// set view
		viewframe = [databaseViewController viewFrame];
		prefsView = [databaseViewController theView];
	}
	else if([[tabViewItem identifier] isEqualToString:@"formats"])
	{
		// set view
		viewframe = [formatViewController viewFrame];
		prefsView = [formatViewController theView];
	}
	else if([[tabViewItem identifier] isEqualToString:@"imexport"])
	{ 
		// set view
		viewframe = [imExportViewController viewFrame];
		prefsView = [imExportViewController theView];
	}
	else if([[tabViewItem identifier] isEqualToString:@"privacy"])
	{
		// set view
		viewframe = [privacyViewController viewFrame];
		prefsView = [privacyViewController theView];
	}
	/*
	 else if([[item itemIdentifier] isEqualToString:EXTERNALS_ITEM_KEY] == YES)
	 {
		 // set view
		 viewframe = [externalsViewController viewFrame];
		 prefsView = [externalsViewController theView];
	 }
	 */
	
	// calculate the difference in size
	//NSRect contentFrame = [[sheet contentView] frame];
	NSRect newFrame = [sheet frame];
	newFrame.size.height = viewframe.size.height + southMargin + northMargin;
	newFrame.size.width = viewframe.size.width + (2 * sideMargin) + 20;
	
	// set new origin
	newFrame.origin.x = [sheet frame].origin.x - ((newFrame.size.width - [sheet frame].size.width) / 2);
	newFrame.origin.y = [sheet frame].origin.y - (newFrame.size.height - [sheet frame].size.height);
	
	// set new frame
	[sheet setFrame:newFrame display:YES animate:YES];
	
	// set frame of box
	//NSRect boxFrame = [prefsViewBox frame];
	[prefsTabView setFrameSize:NSMakeSize((viewframe.size.width + 20),(viewframe.size.height + topTabViewMargin))];
	[prefsTabView setNeedsDisplay:YES];
	
	// set new view
	[tabViewItem setView:prefsView];	
	
	// display complete sheet again
	[sheet display];
}

//--------------------------------------------------------------------
//----------- getter and setter --------------------------------------
//--------------------------------------------------------------------
- (void)setDelegate:(id)anObject
{
	delegate = anObject;
}

- (id)delegate
{
	return delegate;
}

//--------------------------------------------------------------------
//----------- sheet stuff --------------------------------------
//--------------------------------------------------------------------
/**
 \brief the sheet return code
*/
- (int)sheetReturnCode
{
	return sheetReturnCode;
}

/**
 \brief bring up this sheet. if docWindow is nil this will be an Window
*/
- (void)beginSheetForWindow:(NSWindow *)docWindow
{
	[self setSheetWindow:docWindow];
	
	[NSApp beginSheet:sheet 
	   modalForWindow:docWindow
		modalDelegate:self 
	   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) 
		  contextInfo:nil];
}

/**
 \brief end this sheet
*/
- (void)endSheet
{
	[NSApp endSheet:sheet returnCode:0];
}

// end sheet callback
- (void)sheetDidEnd:(NSWindow *)sSheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	// hide sheet
	[sSheet orderOut:nil];
	
	sheetReturnCode = returnCode;
}

//--------------------------------------------------------------------
//----------- Actions ---------------------------------------
//--------------------------------------------------------------------
- (IBAction)okButton:(id)sender
{
	[self endSheet];
}

- (IBAction)restoreFactorySettings:(id)sender
{
}

@end
