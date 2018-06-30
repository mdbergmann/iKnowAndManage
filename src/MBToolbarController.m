// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <CocoLogger/CocoLogger.h>
#import "MBToolbarController.h"
#import "MBImagePopUpButton.h"
#import "globals.h"
#import "MBGeneralPrefsViewController.h"

@implementation MBToolbarController
   
/**
\brief initialize methods gets called in first place on object creation
 */
+ (void)initialize
{
	CocoLog(LEVEL_DEBUG,@"initialize of MBToolbarController");
}

/**
\brief init is called after alloc:. some initialization work can be done here.
 No GUI elements are available here. It additinally calls the init method of superclass
 @returns initialized not nil object
 */
- (id)init
{
	CocoLog(LEVEL_DEBUG,@"init of MBToolbarController");
	
	self = [super init];
	if(self == nil)
	{
		CocoLog(LEVEL_ERR,@"cannot alloc MBToolbarController!");		
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
	CocoLog(LEVEL_DEBUG,@"dealloc of MBToolbarController");
	
	// dealloc object
	[super dealloc];
}

//--------------------------------------------------------------------
//----------- Bundle delegates ---------------------------------------
//--------------------------------------------------------------------
/**
\brief gets called ig the nib file has been loaded. all gfx objacts are available now.
 Also is the MainWindow available to where the toolbar gets added.
 */
- (void)awakeFromNib
{
	CocoLog(LEVEL_DEBUG,@"awakeFromNib of MBToolbarController");
	
	if(self != nil)
	{
		// init toolbar identifiers
		tbIdentifiers = [[NSMutableDictionary alloc] init];
		
		NSToolbarItem *item = nil;
		NSImage *image = nil;
		//MBImagePopUpButton *imagePopUpButton = nil;
		float segmentControlWidth = 0;
		float segmentControlHeight = 32;
		
		// init all element segments into the segmented control
		
		// element navigation segment control
		// ----------------------------------------------------------------------------------------
		// load image for delete button
		/*
		segmentControlWidth = (2*40.0);
		segmentedControl = [[NSSegmentedControl alloc] init];
		[segmentedControl setFrame:NSMakeRect(0.0,0.0,segmentControlWidth,segmentControlHeight)];
		[segmentedControl setSegmentCount:2];
		// set tracking style
		[[segmentedControl cell] setTrackingMode:NSSegmentSwitchTrackingMomentary];
		// insert image for segments
		image = [NSImage imageNamed:@"arrow-left"];
		[segmentedControl setImage:image forSegment:0];
		[[segmentedControl cell] setTag:DirectionBackward forSegment:0];
		image = [NSImage imageNamed:@"arrow-right"];
		[segmentedControl setImage:image forSegment:1];
		[[segmentedControl cell] setTag:DirectionForward forSegment:1];
		[segmentedControl sizeToFit];
		// resize the height to what we have defined
		[segmentedControl setFrameSize:NSMakeSize([segmentedControl frame].size.width,segmentControlHeight)];
		[segmentedControl setTarget:self];
		[segmentedControl setAction:@selector(segmentNavigationAction:)];
		
		// 0 --- Nav
		item = [[NSToolbarItem alloc] initWithItemIdentifier:NAVIGATION_SEGCONTROL_ITEM_KEY];
		[item setLabel:MBLocaleStr(@"NavigationItemLabel")];
		[item setPaletteLabel:MBLocaleStr(@"NavigationItemPalette")];
		[item setToolTip:MBLocaleStr(@"NavigationItemTooltip")];
		[item setMinSize:[segmentedControl frame].size];
		[item setMaxSize:[segmentedControl frame].size];
		// set the segmented control as the view of the toolbar item
		[item setView:segmentedControl];
		[segmentedControl release];
		[tbIdentifiers setObject:item forKey:NAVIGATION_SEGCONTROL_ITEM_KEY];
		[item release];
		 */
				
		// ----------------------------------------------------------------------------------------
		// element add menu (popupbutton)
		// first generate popupbutton
		itemMenuPopUpBotton = [[MBImagePopUpButton alloc] init];
		[itemMenuPopUpBotton setFrame:NSMakeRect(0,0,39,32)];
		[itemMenuPopUpBotton setPullsDown:YES];
		[[itemMenuPopUpBotton cell] setUsesItemFromMenu:NO]; 
		image = [NSImage imageNamed:@"ItemAdd"];
		[image setSize:NSMakeSize(32,32)];
		[itemMenuPopUpBotton setIconImage:image];
		[itemMenuPopUpBotton setShowsMenuWhenIconIsClicked:YES];
				
		// from the first menuitem the PopUpButton gets its Image from if setPullsDown:YES is selected		
		// for through list of menu item and add a copy of them to subMenu
		[self createNewItemMenu];
		
		// item toolbaritem
		item = [[NSToolbarItem alloc] initWithItemIdentifier:ITEM_SUBMENU_ITEM_KEY];
		[item setLabel:MBLocaleStr(@"AddItemLabel")];
		[item setPaletteLabel:MBLocaleStr(@"AddItemPalette")];
		[item setToolTip:MBLocaleStr(@"AddItemTooltip")];
		// use popUpButton as view
		[item setView:itemMenuPopUpBotton];
		[item setMinSize:[itemMenuPopUpBotton frame].size];
		[item setMaxSize:[itemMenuPopUpBotton frame].size];
		// release popUpButton
		[itemMenuPopUpBotton release];
		// add toolbar item to dict
		[tbIdentifiers setObject:item forKey:ITEM_SUBMENU_ITEM_KEY];
		[item release];
		
		// ----------------------------------------------------------------------------------------
		// attribute add menu (popupbutton)
		// first generate popupbutton
		itemValueMenuPopUpButton = [[MBImagePopUpButton alloc] init];
		[itemValueMenuPopUpButton setFrame:NSMakeRect(0,0,39,32)];
		[itemValueMenuPopUpButton setPullsDown:YES];
		[[itemValueMenuPopUpButton cell] setUsesItemFromMenu:NO]; 
		image = [NSImage imageNamed:@"ItemValueAdd"];
		[image setSize:NSMakeSize(32,32)];
		[itemValueMenuPopUpButton setIconImage:image];
		[itemValueMenuPopUpButton setShowsMenuWhenIconIsClicked:YES];

		// from the first menuitem the PopUpButton gets its Image from if setPullsDown:YES is selected		
		// for through list of menu item and add a copy of them to subMenu
		[self createNewItemValueMenu];
				
		// element toolbaritem
		item = [[NSToolbarItem alloc] initWithItemIdentifier:ITEMVAL_SUBMENU_ITEM_KEY];
		[item setLabel:MBLocaleStr(@"AddItemValueItemLabel")];
		[item setPaletteLabel:MBLocaleStr(@"AddItemValueItemPalette")];
		[item setToolTip:MBLocaleStr(@"AddItemValueItemTooltip")];
		// use popUpButton as view
		[item setView:itemValueMenuPopUpButton];
		[item setMinSize:[itemValueMenuPopUpButton frame].size];
		[item setMaxSize:[itemValueMenuPopUpButton frame].size];
		// release popUpButton
		[itemValueMenuPopUpButton release];
		// add toolbar item to dict
		[tbIdentifiers setObject:item forKey:ITEMVAL_SUBMENU_ITEM_KEY];
		[item release];
		 
		// ----------------------------------------------------------------------------------------
		// delete item
		item = [[NSToolbarItem alloc] initWithItemIdentifier:DELETE_ITEM_KEY];
		[item setLabel:MBLocaleStr(@"DeleteItemLabel")];
		[item setPaletteLabel:MBLocaleStr(@"DeleteItemPalette")];
		[item setToolTip:MBLocaleStr(@"DeleteItemTooltip")];
		image = [NSImage imageNamed:@"delete"];
		[item setImage:image];
		[item setTarget:delegate];
		[item setAction:@selector(delete:)];
		[tbIdentifiers setObject:item forKey:DELETE_ITEM_KEY];
		[item release];
		
		// ----------------------------------------------------------------------------------------
		// create segment for views
		segmentControlWidth = (2*64.0);
		segmentedControl = [[NSSegmentedControl alloc] init];
		[segmentedControl setFrame:NSMakeRect(0.0,0.0,segmentControlWidth,segmentControlHeight)];
		[segmentedControl setSegmentCount:2];
		// set tracking style
		[[segmentedControl cell] setTrackingMode:NSSegmentSwitchTrackingSelectOne];
		// insert text only segments
		//[segmentedControl setLabel:@"Detail" forSegment:0];
		[segmentedControl setImage:[NSImage imageNamed:@"list"] forSegment:0];		
		[[segmentedControl cell] setTag:0 forSegment:0];
		[[segmentedControl cell] setEnabled:YES forSegment:0];
		[[segmentedControl cell] setSelected:YES forSegment:0];
		//[segmentedControl setLabel:@"Search" forSegment:1];
		[segmentedControl setImage:[NSImage imageNamed:@"search"] forSegment:1];
		[[segmentedControl cell] setTag:1 forSegment:1];
		[[segmentedControl cell] setEnabled:YES forSegment:1];
		[[segmentedControl cell] setSelected:NO forSegment:1];
		[segmentedControl sizeToFit];
		// resize the height to what we have defined
		[segmentedControl setFrameSize:NSMakeSize([segmentedControl frame].size.width,segmentControlHeight)];
		[segmentedControl setTarget:self];
		[segmentedControl setAction:@selector(segmentChangeDetailViewAction:)];
		
		// add detailview toolbaritem
		item = [[NSToolbarItem alloc] initWithItemIdentifier:DETAILVIEW_SEGCONTROL_ITEM_KEY];
		[item setLabel:MBLocaleStr(@"ViewKindSegmentItemLabel")];
		[item setPaletteLabel:MBLocaleStr(@"ViewKindSegmentItemPalette")];
		[item setPaletteLabel:MBLocaleStr(@"ViewKindSegmentItemTooltip")];
		[item setMinSize:[segmentedControl frame].size];
		[item setMaxSize:[segmentedControl frame].size];
		// set the segmented control as the view of the toolbar item
		[item setView:segmentedControl];
		[segmentedControl release];
		[tbIdentifiers setObject:item forKey:DETAILVIEW_SEGCONTROL_ITEM_KEY];
		[item release];
		
		// prefs icon
		item = [[NSToolbarItem alloc] initWithItemIdentifier:PREFS_ITEM_KEY];
		[item setLabel:MBLocaleStr(@"PrefsItemLabel")];
		[item setPaletteLabel:MBLocaleStr(@"PrefsItemPalette")];
		[item setToolTip:MBLocaleStr(@"PrefsItemTooltip")];
		image = [NSImage imageNamed:@"GeneralPreferences"];
		[item setImage:image];
		[item setTarget:self];
		[item setAction:@selector(openPreferenceSheet:)];
		[tbIdentifiers setObject:item forKey:PREFS_ITEM_KEY];
		[item release];		
		
		// info drawer or panel icon
		item = [[NSToolbarItem alloc] initWithItemIdentifier:INFO_ITEM_KEY];
		[item setLabel:MBLocaleStr(@"InfoItemLabel")];
		[item setPaletteLabel:MBLocaleStr(@"InfoItemPalette")];
		[item setToolTip:MBLocaleStr(@"InfoItemTooltip")];
		image = [NSImage imageNamed:@"info"];
		[item setImage:image];
		[item setTarget:self];
		[item setAction:@selector(toggleInfoView:)];
		[tbIdentifiers setObject:item forKey:INFO_ITEM_KEY];
		[item release];

		// up icon
		item = [[NSToolbarItem alloc] initWithItemIdentifier:UP_ITEM_KEY];
		[item setLabel:MBLocaleStr(@"UpItemLabel")];
		[item setPaletteLabel:MBLocaleStr(@"UpItemPalette")];
		[item setToolTip:MBLocaleStr(@"UpItemTooltip")];
		image = [NSImage imageNamed:@"up"];
		[item setImage:image];
		[item setTarget:self];
		[item setAction:@selector(up:)];
		[tbIdentifiers setObject:item forKey:UP_ITEM_KEY];
		[item release];		
		
		// down icon
		item = [[NSToolbarItem alloc] initWithItemIdentifier:DOWN_ITEM_KEY];
		[item setLabel:MBLocaleStr(@"DownItemLabel")];
		[item setPaletteLabel:MBLocaleStr(@"DownItemPalette")];
		[item setToolTip:MBLocaleStr(@"DownItemTooltip")];
		image = [NSImage imageNamed:@"down"];
		[item setImage:image];
		[item setTarget:self];
		[item setAction:@selector(down:)];
		[tbIdentifiers setObject:item forKey:DOWN_ITEM_KEY];
		[item release];		
		
		/*
		// searchfield
		// create the searchfield
		searchField = [[[NSSearchField alloc] initWithFrame:NSMakeRect(0,0,32,100)] autorelease];
		[searchField sizeToFit];
		[searchField setTarget:self];
		[searchField setAction:@selector(searchInput:)];
		// the item itself
		item = [[NSToolbarItem alloc] initWithItemIdentifier:SEARCH_ITEM_KEY];
		[item setLabel:MBLocaleStr(@"SearchItemLabel")];
		[item setPaletteLabel:MBLocaleStr(@"SearchItemPalette")];
		[item setToolTip:MBLocaleStr(@"SearchItemTooltip")];
		[item setView:searchField];
		[item setMinSize:NSMakeSize(30,NSHeight([searchField frame]))];
		[item setMaxSize:NSMakeSize(200,NSHeight([searchField frame]))];
		[tbIdentifiers setObject:item forKey:SEARCH_ITEM_KEY];
		[item release];
		 */
		
		// progressindicator
		// 
		progressIndicator = [[NSProgressIndicator alloc] init];
		[progressIndicator setIndeterminate:YES];
		[progressIndicator setStyle:NSProgressIndicatorSpinningStyle];
		[progressIndicator setUsesThreadedAnimation:YES];
		[progressIndicator setControlSize:NSSmallControlSize];
		[progressIndicator setDisplayedWhenStopped:YES];
		[progressIndicator setHidden:NO];
		[progressIndicator sizeToFit];
		// the item itself
		item = [[NSToolbarItem alloc] initWithItemIdentifier:PROGRESS_ITEM_KEY];
		[item setPaletteLabel:MBLocaleStr(@"ProgressIndicatorPalette")];
		[item setView:progressIndicator];
		[item setMinSize:[progressIndicator frame].size];
		[item setMaxSize:[progressIndicator frame].size];
		[tbIdentifiers setObject:item forKey:PROGRESS_ITEM_KEY];
		[item release];
		
		// add std items
		[tbIdentifiers setObject:[NSNull null] forKey:NSToolbarFlexibleSpaceItemIdentifier];
		[tbIdentifiers setObject:[NSNull null] forKey:NSToolbarSpaceItemIdentifier];
		[tbIdentifiers setObject:[NSNull null] forKey:NSToolbarSeparatorItemIdentifier];
		[tbIdentifiers setObject:[NSNull null] forKey:NSToolbarPrintItemIdentifier];
		
		[self setupMainWindowToolbar];
		
		// register notification 
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(menuChanged:)
													 name:MBMenuChangedNotification object:nil];				
	}	
}

// -------------------------------------------------------------------
// Menu stuff
// -------------------------------------------------------------------
- (void)createNewItemMenu
{
	NSMenu *subMenu = [[NSMenu alloc] init];
	NSMenuItem *menuItem = [[NSMenuItem alloc] init];
	[menuItem setTitle:@"dummy"];
	[subMenu addItem:menuItem];
	[menuItem release];
	
	NSArray *itemArray = [[newItemMenuItem submenu] itemArray];
	for(int i = 0;i < [itemArray count];i++)
	{
		NSMenuItem *item = [itemArray objectAtIndex:i];
		NSMenuItem *itemCopy = [item copy];
		[subMenu addItem:itemCopy];
		[itemCopy release];
	}
	
	[itemMenuPopUpBotton setMenu:subMenu];
	[subMenu release];
}

- (void)createNewItemValueMenu
{
	NSMenu *subMenu = [[NSMenu alloc] init];
	NSMenuItem *menuItem = [[NSMenuItem alloc] init];
	[menuItem setTitle:@"dummy"];
	[subMenu addItem:menuItem];
	[menuItem release];
	
	NSArray *itemArray = [[newItemValueMenuItem submenu] itemArray];
	for(int i = 0;i < [itemArray count];i++)
	{
		NSMenuItem *item = [itemArray objectAtIndex:i];
		item = [item copy];
		[subMenu addItem:item];
		[item release];
	}
	
	[itemValueMenuPopUpButton setMenu:subMenu];
	[subMenu release];
}

// change main view in segmentedview
- (void)setMainViewTo:(int)viewId
{
	[segmentedControl setSelected:YES forSegment:viewId];
}

// ============================================================
// NSToolbar Related Methods
// ============================================================
/**
 \brief create a toolbar and add it to the mainwindow. Set the delegate to this object.
*/
- (void)setupMainWindowToolbar
{
    // Create a new toolbar instance, and attach it to our document window 
    NSToolbar *toolbar = [[[NSToolbar alloc] initWithIdentifier: @"mainWindowToolbar"] autorelease];
    
    // Set up toolbar properties: Allow customization, give a default display mode, and remember state in user defaults 
    [toolbar setAllowsUserCustomization: YES];
    [toolbar setAutosavesConfiguration: YES];
	//[toolbar setSizeMode:NSToolbarSizeModeRegular];
    [toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
    
    // We are the delegate
    [toolbar setDelegate:self];
    
    // Attach the toolbar to the document window 
    [mainWindow setToolbar:toolbar];
}

/**
\brief returns array with allowed toolbar item identifiers
*/
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar 
{
	return [tbIdentifiers allKeys];
}

/**
\brief returns array with all default toolbar item identifiers
 */
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar 
{
	/*
	NSArray *defaultItemArray = [NSArray arrayWithObjects:
		NAVIGATION_SEGCONTROL_ITEM_KEY,
		NSToolbarSeparatorItemIdentifier,
		DELETE_ITEM_KEY,
		ITEM_SUBMENU_ITEM_KEY,
		ITEMVAL_SUBMENU_ITEM_KEY,
		NSToolbarSeparatorItemIdentifier,
		DETAILVIEW_SEGCONTROL_ITEM_KEY,
		NSToolbarSeparatorItemIdentifier,
		PREFS_ITEM_KEY,
		INFO_ITEM_KEY,
		NSToolbarFlexibleSpaceItemIdentifier,
		PROGRESS_ITEM_KEY,
		nil];
	 */
	NSArray *defaultItemArray = [NSArray arrayWithObjects:
		ITEM_SUBMENU_ITEM_KEY,
		ITEMVAL_SUBMENU_ITEM_KEY,
		NSToolbarSeparatorItemIdentifier,
		DELETE_ITEM_KEY,
		NSToolbarSeparatorItemIdentifier,
		DETAILVIEW_SEGCONTROL_ITEM_KEY,
		NSToolbarSeparatorItemIdentifier,
		PREFS_ITEM_KEY,
		INFO_ITEM_KEY,
		NSToolbarSeparatorItemIdentifier,
		UP_ITEM_KEY,
		DOWN_ITEM_KEY,
		NSToolbarFlexibleSpaceItemIdentifier,
		PROGRESS_ITEM_KEY,
		nil];
	
	return defaultItemArray;
}

- (NSToolbarItem *) toolbar:(NSToolbar *)toolbar 
	  itemForItemIdentifier:(NSString *)itemIdentifier
  willBeInsertedIntoToolbar:(BOOL)flag
{
    NSToolbarItem *item = nil;

	item = [tbIdentifiers valueForKey:itemIdentifier];
	
    return item;
}

// ============================================================
// notifications
// ============================================================
/**
\brief the root template element has been changed reparse templates
 */
- (void)menuChanged:(NSNotification *)aNotification
{
	// recreate item menu
	[self createNewItemMenu];
	[self createNewItemValueMenu];
}

// ============================================================
// selector methods
// ============================================================
- (void)segmentNavigationAction:(id)sender
{
	// no element can be selected
	// bring up alert sheet
	NSBeginAlertSheet(MBLocaleStr(@"Not implemanted"),
					  MBLocaleStr(@"OK"),nil,nil,
					  mainWindow,nil,nil,nil,nil,
					  MBLocaleStr(@"Item Navigation is not yet implemented!"));
	
	/*
	// check, which segment has been clicked
	int selectedSegment = [sender selectedSegment];
	int selectedSegmentTag = [[sender cell] tagForSegment:selectedSegment];

	if(selectedSegmentTag == DirectionForward)
	{
		[elementBaseController elementNavigationForward];
	}
	else
	{
		[elementBaseController elementNavigationForward];	
	}
	*/
}

- (void)up:(id)sender
{
	if([delegate respondsToSelector:@selector(viewUp)])
	{
		[delegate performSelector:@selector(viewUp)];
	}
	else
	{
		CocoLog(LEVEL_DEBUG,@"[MBToolbarController -up]: delegate doesn't respond to selector!");	
	}	
}

- (void)down:(id)sender
{
	if([delegate respondsToSelector:@selector(viewDown)])
	{
		[delegate performSelector:@selector(viewDown)];
	}
	else
	{
		CocoLog(LEVEL_DEBUG,@"[MBToolbarController -down]: delegate doesn't respond to selector!");	
	}	
}

- (void)segmentChangeDetailViewAction:(id)sender
{
	CocoLog(LEVEL_DEBUG,@"change View");

	// inform the delegate that the view has to be changed
	if([delegate respondsToSelector:@selector(changeMainViewTo:)] == YES)
	{
		[delegate performSelector:@selector(changeMainViewTo:) withObject:[NSNumber numberWithInt:[sender selectedSegment]]];
	}
	else
	{
		CocoLog(LEVEL_DEBUG,@"[MBToolbarController -openPreferenceSheet]: delegate doesn't respond to selector!");	
	}		
}

- (void)openPreferenceSheet:(id)sender
{
	CocoLog(LEVEL_DEBUG,@"Prefs Menuitem");

	// inform the delegate that prefs window is to be opened
	// check, if the delegate responds to the selector
	if([delegate respondsToSelector:@selector(openPreferenceSheet)] == YES) {
		[delegate performSelector:@selector(openPreferenceSheet)];
	} else {
		CocoLog(LEVEL_DEBUG,@"[MBToolbarController -openPreferenceSheet]: delegate doesn't respond to selector!");	
	}	
}

- (void)toggleInfoView:(id)sender {
	CocoLog(LEVEL_DEBUG,@"infoview Menuitem");

	// toggle info view
	NSUserDefaults *defaults = userDefaults;
	if((BOOL)[defaults integerForKey:MBDefaultsShowInfoKey] == YES) {
		// deactivate
		[defaults setInteger:0 forKey:MBDefaultsShowInfoKey];
	} else {
		// activate
		[defaults setInteger:1 forKey:MBDefaultsShowInfoKey];	
	}
}

// progress methods
- (void)startProgressAnimation
{
	[progressIndicator startAnimation:nil];
}

- (void)stopProgressAnimation
{
	[progressIndicator stopAnimation:nil];
}

@end
