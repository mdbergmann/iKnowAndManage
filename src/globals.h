/*
 *  globals.h
 *  iKnowAndManage
 *
 *  Created by Manfred Bergmann on 03.06.05.
 *  Copyright 2005 mabe. All rights reserved.
 *
 */

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>
#import <CoreFoundation/CoreFoundation.h>

enum ElementNavigationDirection
{
	DirectionForward = 1,
	DirectionBackward
};

// #define kMyBundleVersion1 0x01008000
#define BUNDLEVERSION			CFBundleGetVersionNumber(CFBundleGetMainBundle())
#define BUNDLEVERSIONSTRING		CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(),kCFBundleVersionKey)
#define APPNAME					@"iKnow & Manage"
#define APPCNAME				@"iKnowAndManage"
#define APPDBNAME				@"iKnowAndManageDB"
#define DEFAULT_DB_PATH			[@"~/Library/Application Support/iKnowAndManage/iKnowAndManageDB" stringByExpandingTildeInPath]
#define DEFAULT_DB_BACK_PATH	[@"~/Library/Application Support/iKnowAndManage/iKnowAndManageDB_backup" stringByExpandingTildeInPath]
#define DEFAULT_DOC_STORE_PATH  [@"~/Library/Application Support/iKnowAndManage/DocStorage" stringByExpandingTildeInPath]
#define LOGFILE					[@"~/Library/Logs/iKnowAndManage.log" stringByExpandingTildeInPath]
#define TMPFOLDER				[@"~/Library/Caches/iKnowAndManage" stringByExpandingTildeInPath]
#define HTML_TEMPLATE_FOLDER	[NSString pathWithComponents:[NSArray arrayWithObjects:[[NSBundle mainBundle] resourcePath],@"HTML_Templates",nil]]
#define DEFAULT_CSSFILE_PATH	[NSString pathWithComponents:[NSArray arrayWithObjects:HTML_TEMPLATE_FOLDER,@"css",@"basic.css",nil]]

// OS version
#define OSVERSION				[[NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"] objectForKey:@"ProductVersion"]
#define OSVERSION_PANTHER		@"10.3.9"
#define OSVERSION_TIGER			@"10.4.0"

// distinction between tiger(intel,ppc) and Panther platform
#define INTEL_PLATFORM TARGET_RT_LITTLE_ENDIAN

// table and outlineview fonts
#define MBTinyTableViewFont [NSFont fontWithName: @"Lucida Grande" size:9]
#define MBSmallTableViewFont [NSFont fontWithName: @"Lucida Grande" size:10]
#define MBStdTableViewFont [NSFont fontWithName: @"Lucida Grande" size: 11]
#define MBStdBoldTableViewFont [NSFont fontWithName: @"Lucida Grande Bold" size: 11]
#define MBLargeTableViewFont [NSFont fontWithName: @"Lucida Grande" size: 12]
#define MBLargeBoldTableViewFont [NSFont fontWithName: @"Lucida Grande Bold" size: 12]

// define for userdefaults
#define userDefaults [NSUserDefaults standardUserDefaults]

// locale defines
#define MBLocaleStr(key) NSLocalizedString(key,@"")

// Notification identifiers

/**
\brief this notification is send, when in one of the views the DELETE key has been pressed
 */
#define MBDeleteKeyPressedNotification @"MBDeleteKeyPressedNotification"
#define MBSendNotifyDeleteKeyPressed(X) [[NSNotificationCenter defaultCenter] postNotificationName:MBDeleteKeyPressedNotification object:X];

/**
\brief this notification is send, when the root templates item has been altered, item deleted or added
 */
#define MBTemplatesAlteredNotification @"MBTemplatesAlteredNotification"
#define MBSendNotifyTemplatesAltered(X) [[NSNotificationCenter defaultCenter] postNotificationName:MBTemplatesAlteredNotification object:X];

/**
\brief this notification is send, when a Item is added to the tree
 this is similar to ItemTreeChanged Notification but it can be used to select the currently added item
 */
#define MBItemAddedNotification @"MBItemAddedNotification"
#define MBSendNotifyItemAdded(X) [[NSNotificationCenter defaultCenter] postNotificationName:MBItemAddedNotification object:X];

/**
\brief this notification is send, when a ItemValue is added to the list
 this is similar to ItemValueListChanged Notification but it can be used to select the currently added itemvalue
 */
#define MBItemValueAddedNotification @"MBItemValueAddedNotification"
#define MBSendNotifyItemValueAdded(X) [[NSNotificationCenter defaultCenter] postNotificationName:MBItemValueAddedNotification object:X];

/**
\brief this notification is send, when the root templates item has been altered, item deleted or added
 */
#define MBMenuChangedNotification @"MBMenuChangedNotification"
#define MBSendNotifyMenuChanged(X) [[NSNotificationCenter defaultCenter] postNotificationName:MBMenuChangedNotification object:X];

/**
\brief this notification when an action wants to start the global progress indicator
 */
#define MBProgressIndicationActionStartedNotification @"MBProgressIndicationActionStartedNotification"
#define MBSendNotifyProgressIndicationActionStarted(X) [[NSNotificationCenter defaultCenter] postNotificationName:MBProgressIndicationActionStartedNotification object:X];

/**
\brief this notification when an action wants to stop the global progress indicator
 */
#define MBProgressIndicationActionStoppedNotification @"MBProgressIndicationActionStoppedNotification"
#define MBSendNotifyProgressIndicationActionStopped(X) [[NSNotificationCenter defaultCenter] postNotificationName:MBProgressIndicationActionStoppedNotification object:X];

/**
\brief this notification is posted if the app is going to terminate
 */
#define MBAppWillTerminateNotification @"MBAppWillTerminateNotification"
#define MBSendNotifyAppWillTerminate(X) [[NSNotificationCenter defaultCenter] postNotificationName:MBAppWillTerminateNotification object:X];

/**
\brief this notification is posted if the db has been initialized
*/
#define MBDbInitializedNotification @"MBDbInitializedNotification"
#define MBSendNotifyDbInitialized(X) [[NSNotificationCenter defaultCenter] postNotificationName:MBDbInitializedNotification object:X];

/**
\brief this notification is posted if tha app has been initialized, all data has been loaded.
 All views can now display data.
*/
#define MBAppInitializedNotification @"MBAppInitializedNotification"
#define MBSendNotifyAppInitialized(X) [[NSNotificationCenter defaultCenter] postNotificationName:MBAppInitializedNotification object:X];

/**
\brief whenever a status message is to be shown in status bar, this notification should be posted
*/
#define MBDisplayStatusTextNotification @"MBDisplayStatusTextNotification"
#define MBSendNotifyDisplayStatusText(X) [[NSNotificationCenter defaultCenter] postNotificationName:MBDisplayStatusTextNotification object:X];

/**
\brief OutlineView (MainItemListView) has changed selected element
*/
#define MBItemSelectionChangedNotification @"MBItemSelectionChangedNotification"
#define MBSendNotifyItemSelectionChanged(X) [[NSNotificationCenter defaultCenter] postNotificationName:MBItemSelectionChangedNotification object:X];

/**
\brief TableView in ItemValueListView has changed the selected itemvalue
*/
#define MBItemValueSelectionChangedNotification @"MBItemValueSelectionChangedNotification"
#define MBSendNotifyItemValueSelectionChanged(X) [[NSNotificationCenter defaultCenter] postNotificationName:MBItemValueSelectionChangedNotification object:X];

/**
\brief this notification is posted if attributes of an item have been changed. \n
 Any View displaying details of this item should update.
*/
#define MBItemAttribsChangedNotification @"MBItemAttribsChangedNotification"
#define MBSendNotifyItemAttribsChanged(X) [[NSNotificationCenter defaultCenter] postNotificationName:MBItemAttribsChangedNotification object:X];

/**
\brief this notification is posted if attributes of an attribute have been changed. \n
 Any View displaying this Attribute should update.
 */
#define MBItemValueAttribsChangedNotification @"MBItemValueAttribsChangedNotification"
#define MBSendNotifyItemValueAttribsChanged(X) [[NSNotificationCenter defaultCenter] postNotificationName:MBItemValueAttribsChangedNotification object:X];

/**
\brief this notification is posted if the item tree has been changed. \n
 This means, an item has been added or removed and the OutlineView displaying the ItemList should update.
*/
#define MBItemTreeChangedNotification @"MBItemTreeChangedNotification"
#define MBSendNotifyItemTreeChanged(X) [[NSNotificationCenter defaultCenter] postNotificationName:MBItemTreeChangedNotification object:X];

/**
\brief this notification is posted if the itemvalue list of an item has been changed. \n
 Any View displaying this item should update the itemvalue list.
*/
#define MBItemValueListChangedNotification @"MBItemValueListChangedNotification"
#define MBSendNotifyItemValueListChanged(X) [[NSNotificationCenter defaultCenter] postNotificationName:MBItemValueListChangedNotification object:X];

/**
 \brief this notification is send if an item has been selected elsewhere and it should be selected in NSBrowser
*/
#define MBItemSelectionShouldChangeInBrowserNotification @"MBItemSelectionShouldChangeInBrowserNotification"
#define MBSendNotifyItemSelectionShouldChangeInBrowser(X) [[NSNotificationCenter defaultCenter] postNotificationName:MBItemSelectionShouldChangeInBrowserNotification object:X];

/**
\brief this notification is send if an element has been selected elsewhere and it should be selected in NSTableView
 */
#define MBItemValueSelectionShouldChangeInTableViewNotification @"MBItemValueSelectionShouldChangeInTableViewNotification"
#define MBSendNotifyItemValueSelectionShouldChangeInTableView(X) [[NSNotificationCenter defaultCenter] postNotificationName:MBItemValueSelectionShouldChangeInTableViewNotification object:X];

/**
\brief this notification is send if an element has been selected elsewhere and it should be selected in NSOutlineView
 */
#define MBItemSelectionShouldChangeInOutlineViewNotification @"MBItemSelectionShouldChangeInOutlineViewNotification"
#define MBSendNotifyItemSelectionShouldChangeInOutlineView(X) [[NSNotificationCenter defaultCenter] postNotificationName:MBItemSelectionShouldChangeInOutlineViewNotification object:X];

/**
\brief this notification is send if item NSOutlineView is sorted. Normally pthe NSBrowser should reload its data
 */
#define MBItemListHasBeenSortedNotification @"MBItemListHasBeenSortedNotification"
#define MBSendNotifyItemListHasBeenSorted(X) [[NSNotificationCenter defaultCenter] postNotificationName:MBItemListHasBeenSortedNotification object:X];
