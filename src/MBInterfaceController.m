// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import "MBInterfaceController.h"
#import "MBItemValue.h"
#import "MBFileItemValue.h"
#import "MBRefItem.h"
#import "globals.h"
#import "MBItemBaseController.h"
#import "GlobalWindows.h"
#import "MBThreadedProgressSheetController.h"
#import "MBGeneralPrefsViewController.h"
#import "MBMainViewController.h"
#import "MBToolbarController.h"
#import "MBInfoViewController.h"
#import "MBSearchViewController.h"
#import "MBItemOutlineViewController.h"
#import "MBPasteboardType.h"
#import "MBElementBaseController.h"
#import "MBPrintController.h"
#import "MBSystemItem.h"
#import "MBDBAccess.h"
#import "MBExporter.h"
#import "MBImporter.h"
#import "MBNSStringCryptoExtension.h"
#import "EMKeychainProxy.h"
#import "MBPasswordInputController.h"
#import "MBBaseDetailViewController.h"

@interface NSWindow (privateAPI)

- (void)_setTexturedBackground:(BOOL)fp8;

@end

@interface MBInterfaceController (privateAPI)

- (BOOL)encryptItemValues:(NSArray *)values withPassword:(NSString *)pw;
- (void)closeInfo;
- (void)openInfo;

@end

@implementation MBInterfaceController (privateAPI)

- (BOOL)encryptItemValues:(NSArray *)values withPassword:(NSString *)pw {
	// encrypt all current ItemValues
	NSEnumerator *iter = [values objectEnumerator];
	MBItemValue *itemval = nil;
	BOOL error = NO;
	while((itemval = [iter nextObject])) {
		// is reference?
		if(([itemval identifier] == ItemRefID) ||
		   ([itemval identifier] == ItemValueRefID)) {
			itemval = (MBItemValue *)[(MBRefItem *)itemval target];
		}
		
		// reference target may not be nil
		if(itemval != nil) {
			BOOL encrypt = YES;

			// check, if this itemval has external data
			if([itemval isKindOfClass:[MBFileItemValue class]]) {
				if([(MBFileItemValue *)itemval isLink]) {
					// ask if we realy should encrypt this data
					int result = NSRunAlertPanel(MBLocaleStr(@"ExternalDataReallyEncryptTitel"),
												 MBLocaleStr(@"ExternalDataReallyEncryptMsg"),
												 MBLocaleStr(@"Yes"),
												 MBLocaleStr(@"No"),
												 nil);
					if(result == NSAlertAlternateReturn) {
						encrypt = NO;
					}
				}
			}
			
			// still encrypt?
			if(encrypt) {
				int stat = [itemval encryptWithString:pw];
				if(stat == MBCryptoOK) {
					// refresh infoview
					MBSendNotifyItemValueAttribsChanged(itemval);			
				} else {
					error = YES;
				}	
			}
		}
	}
	
	return error;
}

- (void)closeInfo {
    if([[mainVertSplitView subviews] containsObject:[infoViewController infoView]]) {
        [[infoViewController infoView] removeFromSuperview];
    }
}

- (void)openInfo {
    if(![[mainVertSplitView subviews] containsObject:[infoViewController infoView]]) {
        [mainVertSplitView addSubview:[infoViewController infoView]];
        [[infoViewController infoView] setFrameSize:[infoViewController viewFrame].size];
    }
}

@end


@implementation MBInterfaceController

/**
\brief init is called after -alloc. some initialization work can be done here.
 No GUI items are available here. It additinally calls the init method of superclass
 @returns initialized not nil object
 */
- (id)init {
	CocoLog(LEVEL_DEBUG,@"init of MBInterfaceController");
	
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"cannot alloc MBInterfaceController!");
	} else {
		// set stack for progress indicator
		startedProgressTrackingActions = 0;
        [self setDraggingItems:[NSArray array]];
	}
	
	return self;
}

/**
\brief dealloc of this class is called on closing this document
 */
- (void)dealloc {
	CocoLog(LEVEL_DEBUG,@"dealloc of MBInterfaceController");
	
    [self setDraggingItems:nil];
    
	// dealloc object
	[super dealloc];
}

/**
 \brief with implementing this method, the undo manager for the window is provided by ItemBaseController
*/
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
	CocoLog(LEVEL_DEBUG,@"");
	return [itemController undoManager];
}

- (void)setDelegate:(id)aClass {
	delegate = aClass;
}

- (id)delegate {
	return delegate;
}

- (void)setDraggingItems:(NSArray *)items {
	[items retain];
	[draggingItems release];
	draggingItems = items;
}

- (NSArray *)draggingItems {
	return draggingItems;
}

- (void)awakeFromNib {
    // init GlobalWindows
    [GlobalWindows setMainAppWindow:mainWindow];
    [GlobalWindows setAlertWindow:mainWindow];

    // init standard progress sheet controller
    MBThreadedProgressSheetController *pc = [MBThreadedProgressSheetController standardProgressSheetController];
    [pc setSheetWindow:mainWindow];
    [pc setIsThreaded:[NSNumber numberWithBool:YES]];		
    
    // register notification 
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(appInitialized:)
                                                 name:MBAppInitializedNotification object:nil];
    // register notification
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(displayStatusText:)
                                                 name:MBDisplayStatusTextNotification object:nil];		
    // register notification 
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(selectedItemChanged:)
                                                 name:MBItemSelectionChangedNotification object:nil];				
    // register notification
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(itemValueSelectionChanged:)
                                                 name:MBItemValueSelectionChangedNotification object:nil];			
    // register notification
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(deleteKeyPressed:)
                                                 name:MBDeleteKeyPressedNotification object:nil];			
    // register notification for checking templates 
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(templatesAltered:)
                                                 name:MBTemplatesAlteredNotification object:nil];						

    // register notification for global progress tracking
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(progressIndicationActionStarted:)
                                                 name:MBProgressIndicationActionStartedNotification object:nil];				

    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(progressIndicationActionStopped:)
                                                 name:MBProgressIndicationActionStoppedNotification object:nil];

    // register some NSUserDefaults changes
    [[NSUserDefaults standardUserDefaults] addObserver:self 
                                            forKeyPath:MBDefaultsShowInfoKey
                                               options:NSKeyValueObservingOptionNew context:nil];
    
    // buoild templates menu
    [self templatesAltered:nil];
    
    // set mainview as currentview
    [mainRightSideBox setContentView:[mainViewController theView]];
    currentContentViewController = mainViewController;
        
    // switch mainwindow to Metal, if it is choosen
    // get use metal
    BOOL useMetal = (BOOL)[userDefaults integerForKey:MBDefaultsMetalDisplayKey];
    if(useMetal) {
        // before setting the setting, set the toolbar to invisible
        [[mainWindow toolbar] setVisible:NO];
        // when switching to metal or back, the toolbar disapears
        [mainWindow _setTexturedBackground:useMetal];	
        // reset the toolbar to visible
        [[mainWindow toolbar] setVisible:YES];			
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	// check for keyPath
	if([keyPath isEqualToString:MBDefaultsMetalDisplayKey]) {
		/*
		// get new value
		id newValue = [change valueForKey:NSKeyValueChangeNewKey];
		if(newValue != nil)
		{
			BOOL showMetal = (BOOL)[newValue intValue];
			
			// before setting the setting, set the toolbar to invisible
			[[mainWindow toolbar] setVisible:NO];
			// when switching to metal or back, the toolbar disapears
			[mainWindow _setTexturedBackground:showMetal];	
			// reset the toolbar to visible
			[[mainWindow toolbar] setVisible:YES];
		}
		 */
	} else if([keyPath isEqualToString:MBDefaultsShowInfoKey]) {
		// get new value
		id newValue = [change valueForKey:NSKeyValueChangeNewKey];
		if(newValue != nil) {
            // check new value
            int val = [newValue intValue];
            if(val == 0) {
                // we have to close
                [self closeInfo];
            } else {
                // we have to open
                [self openInfo];
            }
		}		
	}
}

#pragma mark - Actions

- (IBAction)searchInput:(id)sender {
	CocoLog(LEVEL_DEBUG,@"[MBMainViewController -searchInput:]");
	
    if(currentContentViewController) {
        [currentContentViewController performSelector:@selector(applySearchString:) withObject:[sender stringValue]];    
    }
}

#pragma mark - Toolbar delegates

/**
 \brief call delegate method to show up the preferences panel
*/
- (void)openPreferenceSheet {
	CocoLog(LEVEL_DEBUG,@"[MBInterfaceController -openPreferenceSheet:]");

	// check, if delegate responds to selector
	if([delegate respondsToSelector:@selector(showPreferenceSheet:)]) {
		[delegate performSelector:@selector(showPreferenceSheet:) withObject:nil];
	} else {
		CocoLog(LEVEL_WARN,@"[MBInterfaceController -openPreferenceSheet]: delegate doesnot respond to selector!");
	}
}

/**
 \brief change main view
 0 = mainView
 1 = search view
*/
- (void)changeMainViewTo:(NSNumber *)viewId {
	switch([viewId intValue]) {
		case 0:
			CocoLog(LEVEL_DEBUG,@"[MBInterfaceController -changeMainViewTo:] mainView");
			[mainRightSideBox setContentView:[mainViewController theView]];
            currentContentViewController = mainViewController;
			break;
		case 1:
			CocoLog(LEVEL_DEBUG,@"[MBInterfaceController -changeMainViewTo:] searchView");
			[mainRightSideBox setContentView:[searchViewController theView]];
            currentContentViewController = searchViewController;
			break;
	}
	
	// change in segmented view in toolbar
	[toolbarController setMainViewTo:[viewId intValue]];
}

/**
 \brief up toolbaritem has been pressed
*/
- (void)viewUp {
	// forward to main view
	[mainViewController viewUp];
}

/**
\brief down toolbaritem has been pressed
 */
- (void)viewDown {
	// forward to main view
	[mainViewController viewDown];
}

//--------------------------------------------------------------------
//----------- window notifications ---------------------------------------
//--------------------------------------------------------------------
- (void)windowDidResize:(NSNotification *)aNotification {
}

// called when the window has been moved
- (void)windowDidMove:(NSNotification *)aNotification {
}

- (void)windowDidBecomeMain:(NSNotification *)aNotification {
}

//--------------------------------------------------------------------
//----------- notifications ---------------------------------------
//--------------------------------------------------------------------
/** 
\brief notification that the application has finished with initialization

Now, the contentview of the detailView can be set and the info drawer can be opened
*/
- (void)appInitialized:(NSNotification *)aNotification {
	if(aNotification != nil) {
		// set itemOutlineView
		[itemOutlineViewBox setContentView:[itemOutlineViewController itemOutlineView]];
		
		// lets start with a nil selection
		MBSendNotifyItemSelectionChanged(nil);
		
		// make mein window visible
		[mainWindow setIsVisible:YES];
		
        // show info view
        if([userDefaults integerForKey:MBDefaultsShowInfoKey]) {
            [self openInfo];
        }

		// let all that use the templates menu update theirs
		// send notification that templates menu has changed
		MBSendNotifyMenuChanged(nil);
	}
}

/**
 \brief the root template element has been changed reparse templates
*/
- (void)templatesAltered:(NSNotification *)aNotification {
	// set new submenu for templateMenuItem
	NSMenu *submenu = [itemController generateTemplateMenuWithTarget:self withMenuAction:@selector(menuNewFromTemplate:)];
	[menuItemFromTemplate setSubmenu:submenu];
	
	// send notification that templates menu has changed
	MBSendNotifyMenuChanged(nil);
}

/** 
\brief callback for status text changes
The inner object is a NSString wich is to be displayed in the status TextField
*/
- (void)displayStatusText:(NSNotification *)aNotification
{
	if(aNotification != nil)
	{
		NSString *statusStr = [aNotification object];
		
		if(statusStr != nil)
		{
			// display it
			[statusTextField setStringValue:statusStr];
		}
		else
		{
			CocoLog(LEVEL_WARN,@"object is nil!");
		}
	}
}

/** 
 \brief the delete key has been pressed in one of the subviews
*/
- (void)deleteKeyPressed:(NSNotification *)aNotification
{
	// call move to trash method
	[self delete:self];
}

/** 
\brief notification that the selected item has changed
Notification object is the selected MBItem. Now the contentView of MBInfoDrawer is changed to MBItemInfoView
and information of the selected Item is shown.
*/
- (void)selectedItemChanged:(NSNotification *)aNotification
{
	if(aNotification != nil)
	{
	}
}

/** 
\brief notification that the selected itemValue

Notification object is the selected MBItemValue. Now the contentView of MBInfoDrawer is changed to MBItemValueInfoView
and information of the selected ItemValue is shown.
*/
- (void)itemValueSelectionChanged:(NSNotification *)aNotification
{
	if(aNotification != nil)
	{
	}
}

- (void)progressIndicationActionStarted:(NSNotification *)aNotification
{
	if(startedProgressTrackingActions == 0)
	{
		// start the progress indicator
		[toolbarController startProgressAnimation];
	}

	// increment stack
	startedProgressTrackingActions++;
}

- (void)progressIndicationActionStopped:(NSNotification *)aNotification
{
	// decrement stack
	startedProgressTrackingActions--;
	
	// do we need to stop?
	if(startedProgressTrackingActions == 0)
	{
		[toolbarController stopProgressAnimation];
	}
}

//--------------------------------------------------------------------
//----------- pasteboard methods -------------------------------------
//--------------------------------------------------------------------
/**
 \brief write data to the pasteboard (copy action)
*/
- (void)writeDataToPasteboard:(NSPasteboard *)pb forAction:(int)aAction
{
	CocoLog(LEVEL_DEBUG,@"[MBInterfaceController -writeDataToPasteboard:]");

	// encode the current selected object and write that data to the pasteboard
	MBItemBaseController *ibc = [MBItemBaseController standardController];

	NSMutableArray *copySelection = nil;
	NSMutableArray *types = [NSMutableArray array];
	NSString *type = nil;
	
	// check, which view is the first responder
	if([mainWindow firstResponder] == [itemOutlineViewController outlineView])
	{
		copySelection = [ibc currentItemSelection];
	}
	else if([mainWindow firstResponder] == [mainViewController itemValueListView])
	{
		copySelection = [ibc currentItemValueSelection];
	}
	else if([mainWindow firstResponder] == [searchViewController resultOutlineView])
	{
		copySelection = [NSMutableArray arrayWithArray:[searchViewController searchResult]];
	}	
	else
	{
		// do nothing here
		CocoLog(LEVEL_WARN,@"[MBInterfaceController -writeDataToPasteboard:forAction:] unknown first responder!");
	}

	if((copySelection != nil) && ([copySelection count] > 0))
	{
		unsigned int dataSize = 0;

		// sort out any system items, they cannot be copied, cut or paste
		NSEnumerator *iter = [copySelection objectEnumerator];
		MBCommonItem *item = nil;
		while((item = [iter nextObject]))
		{
			if(NSLocationInRange([item identifier],SYSTEMITEM_ID_RANGE))
			{
				[copySelection removeObject:item];
			}
			else if(NSLocationInRange([item identifier],ITEM_ID_RANGE))
			{
				dataSize += [(MBItem *)item dataSizeWithDescent:YES];
			}
			else if(NSLocationInRange([item identifier],ITEMVALUE_ID_RANGE))
			{
				dataSize += [(MBItemValue *)item dataSize];			
			}
		}
		
		// add pb type
		type = COMMON_ITEM_PB_TYPE_NAME;
		[types addObject:type];
		// declare type
		[pb declareTypes:types owner:self];

		// we need the data of this object
		//NSData *selectionAsData = [NSArchiver archivedDataWithRootObject:copySelection];
		// set export dir for oversize data
		[elementController setOversizeDataExportPath:TMPFOLDER];
		NSData *selectionAsData = [NSKeyedArchiver archivedDataWithRootObject:copySelection];
		// release the copied object at once
		if(selectionAsData != nil)
		{
			[pb setData:selectionAsData forType:type];
		}
		else
		{
			CocoLog(LEVEL_DEBUG,@"[MBInterfaceController -writeDataToPasteboard:]: cannot convert selection to data!");					
		}
		
		// do we copy or cut
		if(aAction == PB_CUT_ACTION)
		{
			// remove this object from item array
			[ibc moveObjectsToTrashcan:copySelection];
		}
	}
	else
	{
		CocoLog(LEVEL_DEBUG,@"[MBInterfaceController -writeDataToPasteboard:]: copyObject is nil!");
	}
}

/**
 \brief read data from pasteboard and paste it to the right item
*/ 
- (void)readDataFromPasteboard:(NSPasteboard *)pb
{
	// if this method runs in a thread, we need a seperate ARP
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	// start
	MBSendNotifyProgressIndicationActionStarted(nil);

	CocoLog(LEVEL_DEBUG,@"[MBInterfaceController -readDataFromPasteboard:]");

	// encode the current selected object and write that data to the pasteboard
	// all copied data can only be pasted to items
	NSArray *selection = [itemController currentItemSelection];
	if([selection count] > 1) {
		NSBeginAlertSheet(MBLocaleStr(@"Alert!"),
						  MBLocaleStr(@"OK"),nil,nil,
						  mainWindow,nil,nil,nil,nil,
						  @"Pasting to multiple selections is not allowed!");		
	} else {
		MBItem *item = nil;

		// only to ONE item can be pasted
		if([selection count] == 0) {
			// on nil, paste to root
			item = [itemController rootItem];
		} else {
			item = [selection objectAtIndex:0];
		}
		
		// if item is a reference, dereference it
		if([item identifier] == ItemRefID) {
			item = (MBItem *)[(MBRefItem *)item target];
		}
		// adding a item to a item ref with out target is not allowed
		if(item == nil) {
			NSAlert *alert = [NSAlert alertWithMessageText:MBLocaleStr(@"CannotPasteToItemRefWithoutTargetTitle") 
											 defaultButton:MBLocaleStr(@"OK") 
										   alternateButton:nil 
											   otherButton:nil 
								 informativeTextWithFormat:MBLocaleStr(@"CannotPasteToItemRefWithoutTargetMsg")];
			[alert runModal];
		} else {
			// lets see, what is in pasteboard
			NSString *type = [pb availableTypeFromArray:[MBPasteboardType pasteboardTypes]];
			if(type == nil) {
				CocoLog(LEVEL_WARN,@"[MBInterfaceController -readDataFromPasteboard:] unrecongized type in pasteboard!");
			} else {
				// get the data
				NSData *pbData = [pb dataForType:type];
				if(pbData == nil) {
					CocoLog(LEVEL_WARN,@"[MBInterfaceController -readDataFromPasteboard:] pb data is nil!");
				} else {
					// get the sheet
					MBThreadedProgressSheetController *pSheet = nil;
					pSheet = [MBThreadedProgressSheetController standardProgressSheetController];
					
					// progressAction
					BOOL progressAction = NO;				
					if([pbData length] > (1024 * 512))
					{
						// set to indeterminate
						[pSheet performSelectorOnMainThread:@selector(setIsIndeterminateProgress:) 
												 withObject:[NSNumber numberWithBool:YES]
											  waitUntilDone:YES];
						// begin sheet
						[pSheet performSelectorOnMainThread:@selector(beginSheet) 
												 withObject:nil 
											  waitUntilDone:YES];
						// start
						[pSheet performSelectorOnMainThread:@selector(startProgressAnimation) 
												 withObject:nil 
											  waitUntilDone:YES];
						// set progress action yes
						progressAction = YES;
					}
					
					[elementController setOversizeDataImportPath:TMPFOLDER];
                    NSArray *pdDataArray = [NSKeyedUnarchiver unarchiveObjectWithData:pbData];

                    double count = 0;
					// input that stuff
					if([type isEqualToString:COMMON_ITEM_PB_TYPE_NAME]) {
						if([pdDataArray count] > 0) {
							// do we have to keep track of progress?
							// check, if there are enough items or itemValues to do tracking
							if([pSheet shouldKeepTrackOfProgress]) {
								count = [pdDataArray count];
								MBCommonItem *buf = nil;
								NSEnumerator *iter = [pdDataArray objectEnumerator];
								while((buf = [iter nextObject])) {
									// if we have some items in out array, count all children and itemvalues
									if(NSLocationInRange([buf identifier], ITEM_ID_RANGE)) {
										MBItem *item = (MBItem *)buf;
										count += [item numberOfChildrenInSubtree:YES];
										count += [item numberOfItemValuesInSubtree:YES];
									}
								}
							
								// check count
								if(count > 20) {
									// switch to determinate and stop animation
									[pSheet performSelectorOnMainThread:@selector(stopProgressAnimation) 
															 withObject:nil 
														  waitUntilDone:YES];
									
									[pSheet performSelectorOnMainThread:@selector(setIsIndeterminateProgress:) 
															 withObject:[NSNumber numberWithBool:NO]
														  waitUntilDone:YES];
								} else {
									// do we have the progress sheet up?
									if(!progressAction) {
										// deactivate progress sheet
										[pSheet performSelectorOnMainThread:@selector(setShouldKeepTrackOfProgress:) 
																 withObject:[NSNumber numberWithBool:NO]
															  waitUntilDone:YES];
									}
								}
								
								// do we keep track of progress ???
								if([pSheet shouldKeepTrackOfProgress]) {
									// is sheet up?
									if(!progressAction) {
										// begin sheet
										[pSheet performSelectorOnMainThread:@selector(beginSheet) 
																 withObject:nil 
															  waitUntilDone:YES];
									}
									// set maximum value
									[pSheet performSelectorOnMainThread:@selector(setMaxProgressValue:)
															 withObject:[NSNumber numberWithDouble:count] 
														  waitUntilDone:YES];
								}
							}
							
							// add item to selected item
							[itemController addObjects:pdDataArray toItem:item withIndex:-1 withConnectingObjects:YES operation:AddOperation];
						}
					} else {
						CocoLog(LEVEL_WARN,@"[MBInterfaceController -readDataFromPasteboard:] unrecognized type for pasting!");				
					}
					
					// this is only needed with indeterminate progressindicators
					if([pSheet isIndeterminateProgress]) {
						[pSheet performSelectorOnMainThread:@selector(stopProgressAnimation) 
												 withObject:nil 
											  waitUntilDone:YES];
					} else {
						// set value to max
						[pSheet performSelectorOnMainThread:@selector(setProgressValue:)
												 withObject:[NSNumber numberWithDouble:count] 
											  waitUntilDone:YES];									
					}
					// end sheet
					[pSheet performSelectorOnMainThread:@selector(endSheet) 
											 withObject:nil 
										  waitUntilDone:YES];
					// set end itemValues to sheet
					[pSheet setShouldKeepTrackOfProgress:[NSNumber numberWithBool:NO]];
					[pSheet setProgressAction:[NSNumber numberWithInt:NONE_PROGRESS_ACTION]];
					[pSheet resetProgressValue];
				}
			}	
		}
	}
	
	// release pool
	[pool release];
	
	// start
	MBSendNotifyProgressIndicationActionStopped(nil);
}

/**
 \brief used for lazy copy to the pasteboard, we use this for the cut operation
*/
- (void)pasteboard:(NSPasteboard *)sender provideDataForType:(NSString *)type
{
	CocoLog(LEVEL_DEBUG,@"[MBInterfaceController -pasteboard:provideDataForType:]");
	
}

@end
//--------------------------------------------------------------------
//----------- menu action ---------------------------------------
//--------------------------------------------------------------------
/**
\brief menu actions performed by interface controller
 */
@implementation MBInterfaceController (menuactions)

/**
 \brief we use this method to update the "From Template" submenu
*/
/*
- (void)menuNeedsUpdate:(NSMenu *)menu
{
	CocoLog(LEVEL_DEBUG,@"[MBInterfaceController -menuNeedsUpdate:]!");

	// set all menuitems enabled
	[menuItemNewItem setEnabled:YES];
	[menuItemNewItemValue setEnabled:YES];
	[menuItemFromTemplate setEnabled:YES];
	[menuItemEnDecryption setEnabled:YES];

	// validate menu
	// check selection, if we have trashcan ot template item selected then we have to change menu
	NSArray *selectedItems = [itemController currentItemSelection];
	//NSArray *selectedItemValues = [itemController currentItemValueSelection];
	
	// is selection only one item?
	if([selectedItems count] == 1)
	{
		MBItem *item = [selectedItems objectAtIndex:0];
		
		// if this is a Item or SystemItem, deactivate Encryption
		if((NSLocationInRange([item identifier],ITEM_ID_RANGE)) ||
		   (NSLocationInRange([item identifier],SYSTEMITEM_ID_RANGE)))
		{
			[menuItemEnDecryption setEnabled:NO];		
		}
		
		// Trashcan?
		if([item itemtype] == TrashcanItemType)
		{
			// disable encryption, new item and new item value menues
			[menuItemNewItem setEnabled:NO];
			[menuItemNewItemValue setEnabled:NO];			
		}
		// RootTemplate?
		else if([item itemtype] == RootTemplateItemType)
		{
			// disable encryption, new item and new item value menues
			[menuItemNewItemValue setEnabled:NO];
		}
		// Import?
		else if([item itemtype] == ImportItemType)
		{
		}
	}
	
	// send notification about menu change
	MBSendNotifyMenuChanged(nil);
}
*/

/**
\brief validate menu
 */
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
	CocoLog(LEVEL_DEBUG,@"[MBInterfaceController -validateMenuItem:");
	
	int firstResponder = -1;
	// check first responder
	if([mainWindow firstResponder] == [itemOutlineViewController outlineView]) {
		firstResponder = (int)StdItemType;		
	} else if([mainWindow firstResponder] == [mainViewController itemValueListView]) {
		firstResponder = (int)SimpleTextItemValueType;		
	} else if([mainWindow firstResponder] == [searchViewController resultOutlineView]) {
	} else {
		// do nothing here
		CocoLog(LEVEL_WARN,@"[MBInterfaceController -validateMenuItem:] unknown first responder!");
	}
	
	// check selection, if we have trashcan ot template item selected then we have to change menu
	NSArray *selectedItems = [itemController currentItemSelection];
	int itemCount = [selectedItems count];
	NSArray *selectedItemValues = [itemController currentItemValueSelection];
	int itemValueCount = [selectedItemValues count];
	
	// check action of menuitem
	if(([menuItem action] == @selector(menuEncryptWithDefaultPassword:)) ||
	   ([menuItem action] == @selector(menuEncryptWithCustomPassword:)) ||
	   ([menuItem action] == @selector(menuDecrypt:))) {
		if(firstResponder == StdItemType) {
			if(itemCount == 0) {
				return NO;
			} else if(itemCount == 1) {
                // is selection only one item?
				MBCommonItem *item = [selectedItems objectAtIndex:0];
				// check for system item
				if((NSLocationInRange([item identifier],SYSTEMITEM_ID_RANGE)) ||
				   (NSLocationInRange([item identifier],ITEM_ID_RANGE))) {
					return NO;
				}				
			} else {
				// encryption of more items or itemvalues is not allowed
				return NO;
			}
		} else {
			if((itemCount > 1) ||
			   (itemValueCount > 1)) {
				return NO;
			} else {
				MBItemValue *itemval = [selectedItemValues objectAtIndex:0];

				if([menuItem action] != @selector(menuDecrypt:)) {
					// if this itemvalue is encrypted already, do not encrypt it again
					if([itemval encryptionState] == EncryptedState) {
						return NO;
					}
				} else {
					// if this itemvalue is encrypted already, do not encrypt it again
					if([itemval encryptionState] == DecryptedState) {
						return NO;
					}
				}
			}			
		}
	} else if([menuItem action] == @selector(menuNewItem:)) {
		if(itemCount == 0) {
			// activate here
		} else if(itemCount == 1) {
            // is selection only one item?
			MBItem *item = [selectedItems objectAtIndex:0];
			
			// adding items to the trashcan is not allowed
			if([item itemtype] == TrashcanItemType) {
				return NO;
			}
		} else {
			// adding items to more items is not allowed
			return NO;
		}		
	} else if([menuItem action] == @selector(menuNewItemValue:)) {
		if(itemCount == 0) {
			return NO;
		} else if(itemCount == 1) {
            // is selection only one item?
			MBItem *item = [selectedItems objectAtIndex:0];
			
			// adding items to the trashcan or to root template is not allowed
			if(([item itemtype] == TrashcanItemType) ||
			   ([item itemtype] == RootTemplateItemType))
			{
				return NO;
			}
		}		
		else
		{
			// adding items to more items is not allowed
			return NO;
		}		
	}
	else if([menuItem action] == @selector(menuNewFromTemplate:))
	{
		if(itemCount == 0)
		{
			//return NO;
		}
		// is selection only one item?
		else if(itemCount == 1)
		{
			MBItem *item = [selectedItems objectAtIndex:0];
			
			// creating items from template to the trashcan or to root template is not allowed
			if(([item itemtype] == TrashcanItemType) ||
			   ([item itemtype] == RootTemplateItemType))
			{
				return NO;
			}
		}		
		else
		{
			// creating from template to more items is not allowed
			return NO;
		}		
	}
	else if([menuItem action] == @selector(copy:))
	{
		if(itemCount == 0)
		{
			return NO;
		}
		// is selection only one item?
		else if(itemCount == 1)
		{
			MBItem *item = [selectedItems objectAtIndex:0];
			
			if(([item itemtype] == TrashcanItemType) ||
			   ([item itemtype] == RootTemplateItemType) ||
			   ([item itemtype] == ImportItemType))
			{
				return NO;
			}
		}		
	}
	else if([menuItem action] == @selector(cut:))
	{
		if(itemCount == 0)
		{
			return NO;
		}
		// is selection only one item?
		else if(itemCount == 1)
		{
			MBItem *item = [selectedItems objectAtIndex:0];
			
			if(([item itemtype] == TrashcanItemType) ||
			   ([item itemtype] == RootTemplateItemType) ||
			   ([item itemtype] == ImportItemType))
			{
				return NO;
			}
		}		
	}
	else if([menuItem action] == @selector(paste:))
	{
		// if nothing is on the pasteboard, there is nothing to paste
		NSPasteboard *pb = [NSPasteboard generalPasteboard];
		NSString *type = [pb availableTypeFromArray:[MBPasteboardType pasteboardTypes]];
		if(type == nil || ![type isEqualToString:COMMON_ITEM_PB_TYPE_NAME])
		{
			return NO;
		}

		if(itemCount == 0)
		{
			return NO;
		}
		// is selection only one item?
		else if(itemCount == 1)
		{
			MBItem *item = [selectedItems objectAtIndex:0];
			
			if(([item itemtype] == TrashcanItemType))
			{
				return NO;
			}
		}
		else
		{
			// pasting to more items os not allowed
			return NO;
		}
	}
	else if([menuItem action] == @selector(delete:))
	{
		if(itemCount == 0)
		{
			return NO;
		}
		// is selection only one item?
		else if(itemCount == 1)
		{
			MBItem *item = [selectedItems objectAtIndex:0];
			
			if(([item itemtype] == TrashcanItemType) ||
			   ([item itemtype] == RootTemplateItemType) ||
			   ([item itemtype] == ImportItemType))
			{
				return NO;
			}
		}		
	}
	else if([menuItem action] == @selector(menuDefineAsTemplate:))
	{
		if(itemCount == 0)
		{
			return NO;
		}
		// is selection only one item?
		else if(itemCount == 1)
		{
			MBItem *item = [selectedItems objectAtIndex:0];
			
			if(([item itemtype] == TrashcanItemType) ||
			   ([item itemtype] == RootTemplateItemType) ||
			   ([item itemtype] == ImportItemType))
			{
				return NO;
			}
		}		
	}
	else if([menuItem action] == @selector(menuExport:))
	{
		if(itemCount == 0)
		{
			return NO;
		}
		// is selection only one item?
		else if(itemCount == 1)
		{
			MBItem *item = [selectedItems objectAtIndex:0];
			
			if([item itemtype] == TrashcanItemType)
			{
				return NO;
			}
		}		
	}
	else if([menuItem action] == @selector(menuImport:))
	{
		if(itemCount == 0)
		{
			return NO;
		}
		// is selection only one item?
		else if(itemCount == 1)
		{
			MBItem *item = [selectedItems objectAtIndex:0];
			
			if([item itemtype] == TrashcanItemType)
			{
				return NO;
			}
		}		
	}
	else if([menuItem action] == @selector(menuCreateRef:))
	{
		if(itemCount == 0)
		{
			return NO;
		}
		// is selection only one item?
		else if(itemCount == 1)
		{
			MBItem *item = [selectedItems objectAtIndex:0];
			
			// check for system item
			if(NSLocationInRange([item identifier],SYSTEMITEM_ID_RANGE))
			{
				return NO;
			}
		}
	} else if([menuItem action] == @selector(saveDocument:)) {
    } else if([menuItem action] == @selector(menuEmptyTrashcan:)) {
		MBItem *trashcan = [itemController trashcanItem];
		if(([[trashcan children] count] == 0) && ([[trashcan itemValues] count] == 0))
		{
			return NO;
		}
	} else if([menuItem action] == @selector(menuOpenItem:)) {
        if(itemValueCount == 0) {
            return NO;
        } else {
            int ident = [(MBItemValue *)[selectedItemValues objectAtIndex:0] identifier];
            if(ident != ExtendedTextItemValueID &&
               ident != FileItemValueID &&
               ident != URLItemValueID &&
               ident != ImageItemValueID) {
                return NO;
            }
        }
	} else if([menuItem action] == @selector(menuOpenItemWith:)) {        
        if(itemValueCount == 0) {
            return NO;
        } else {
            int ident = [(MBItemValue *)[selectedItemValues objectAtIndex:0] identifier];
            if(ident != ExtendedTextItemValueID &&
               ident != FileItemValueID &&
               ident != URLItemValueID &&
               ident != ImageItemValueID) {
                return NO;
            }
        }
    }
	
	return YES;
}

/**
 \brief this is only for ExtendedText Values, they are saved here to theit target
*/
- (IBAction)saveDocument:(id)sender
{
	/*
	// get extended text value
	NSArray *selectedValues = [itemController currentItemValueSelection];
	if([selectedValues count] == 1)
	{
		MBItemValue *val = [selectedValues objectAtIndex:0];
		if([val valuetype] == ExtendedTextItemValueType)
		{
			// save
			
		}
	}
	 */
}

/**
 \brief implementing the help menu to call myown method here
*/
- (IBAction)showHelp:(id)sender
{
	// open this: "iKnow&Manage_Userguide.pdf" in resource folder
	NSString *absolutePath = [NSString pathWithComponents:[NSArray arrayWithObjects:[[NSBundle mainBundle] resourcePath],@"iKnowAndManage_UserGuide_en.pdf",nil]];
	CocoLog(LEVEL_DEBUG,@"open pdf document at: %@",absolutePath);
	[[NSWorkspace sharedWorkspace] openFile:absolutePath];
}

/**
 \brief call the internet site of iKnow & Manage
*/
- (IBAction)menuBuyOnline:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.software-by-mabe.com/software/ikam.html#buy"]];
}

/**
 \brief menuitem that will open the default eMail application and lets the user send an email to me
*/
- (IBAction)menuGiveFeedback:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"mailto:manfred.bergmann@software-by-mabe.com"]];
}

/**
\brief figure what should be printed, prepare views and show print dialog
 */
- (IBAction)print:(id)sender
{
	CocoLog(LEVEL_DEBUG,@"[MBInterfaceController -print:]");
	
	// encode the current selected object and write that data to the pasteboard
	MBItemBaseController *ibc = [MBItemBaseController standardController];
	
	NSMutableArray *printSelection = nil;
	
	// check, which view is the first responder
	if([mainWindow firstResponder] == [itemOutlineViewController outlineView])
	{
		printSelection = [ibc currentItemSelection];

		if((printSelection != nil) && ([printSelection count] > 0))
		{
			// get printController
			MBPrintController *pC = [MBPrintController defaultPrintController];
			// print
			[pC printItemList:printSelection];
		}
		else
		{
			CocoLog(LEVEL_WARN,@"[MBInterfaceController -print:] no data selected for printing!");
			NSBeginAlertSheet(MBLocaleStr(@"No Data for printing selected!"),
							  MBLocaleStr(@"OK"),nil,nil,
							  [GlobalWindows mainAppWindow],nil,nil,nil,nil,
							  MBLocaleStr(@"No Data for printing selected!"));		
		}
	}
	else if([mainWindow firstResponder] == [mainViewController itemValueListView])
	{
		printSelection = [ibc currentItemValueSelection];

		
		if((printSelection != nil) && ([printSelection count] > 0))
		{
			// get printController
			MBPrintController *pC = [MBPrintController defaultPrintController];
			// print
			[pC printItemValueList:printSelection];
		}
		else
		{
			CocoLog(LEVEL_WARN,@"[MBInterfaceController -print:] no data selected for printing!");
			NSBeginAlertSheet(MBLocaleStr(@"No Data for printing selected!"),
							  MBLocaleStr(@"OK"),nil,nil,
							  [GlobalWindows mainAppWindow],nil,nil,nil,nil,
							  MBLocaleStr(@"No Data for printing selected!"));		
		}
	}
	else if([mainWindow firstResponder] == [searchViewController resultOutlineView])
	{
		printSelection = [NSMutableArray arrayWithArray:[searchViewController searchResult]];
	}	
	else
	{
		// do nothing here
		CocoLog(LEVEL_WARN,@"[MBInterfaceController -print:] unknown first responder!");
	}	
}

/**
 \brief on cut, we do not copy and paste the object, we alter the parent ot the item of the item
*/
- (IBAction)cut:(id)sender {
	// start
	MBSendNotifyProgressIndicationActionStarted(nil);
	
	NSPasteboard *pb = [NSPasteboard generalPasteboard];
	[self writeDataToPasteboard:pb forAction:PB_CUT_ACTION];
	
	// stop
	MBSendNotifyProgressIndicationActionStopped(nil);
}

/**
 \brief on copy we make a snapshot (copy) of the selected item and paste the copy
*/
- (IBAction)copy:(id)sender {
	// start
	MBSendNotifyProgressIndicationActionStarted(nil);

	NSPasteboard *pb = [NSPasteboard generalPasteboard];
	[self writeDataToPasteboard:pb forAction:PB_COPY_ACTION];

	// stop
	MBSendNotifyProgressIndicationActionStopped(nil);
}

- (IBAction)paste:(id)sender {
	// bring up progress sheet
	MBThreadedProgressSheetController *pSheet = [MBThreadedProgressSheetController standardProgressSheetController];
	[pSheet setMinProgressValue:[NSNumber numberWithDouble:0.0]];
	[pSheet setIsThreaded:[NSNumber numberWithBool:YES]];
	[pSheet setIsIndeterminateProgress:[NSNumber numberWithBool:NO]];
	[pSheet setShouldKeepTrackOfProgress:[NSNumber numberWithBool:YES]];
	[pSheet setProgressAction:[NSNumber numberWithInt:PASTE_PROGRESS_ACTION]];
	[pSheet setActionMessage:MBLocaleStr(@"Pasting...")];
	
	NSPasteboard *pb = [NSPasteboard generalPasteboard];
	// start this in an own thread
	//[NSThread detachNewThreadSelector:@selector(readDataFromPasteboard:) toTarget:self withObject:pb];
	[self readDataFromPasteboard:pb];
}

- (IBAction)delete:(id)sender
{
	// delete the current selection (move to trash)
	MBItemBaseController *ibc = [MBItemBaseController standardController];
		
	// deselect all from the view the elements have been deleted from
	// check, which view is the first responder
	if([mainWindow firstResponder] == [itemOutlineViewController outlineView])
	{
		// move to trash
		[ibc moveObjectsToTrashcan:[ibc currentItemSelection]];
		
		[[itemOutlineViewController outlineView] deselectAll:nil];
	}
	else if([mainWindow firstResponder] == [mainViewController itemValueListView])
	{
		// move to trash
		[ibc moveObjectsToTrashcan:[ibc currentItemValueSelection]];
		
		[[mainViewController itemValueListView] deselectAll:nil];
	}
	else if([mainWindow firstResponder] == [searchViewController resultOutlineView])
	{
		// move to trash
		[ibc moveObjectsToTrashcan:[ibc currentSelection]];

		[[searchViewController resultOutlineView] deselectAll:nil];
		// restart search after delete
		[searchViewController startSearch:nil];
	}
	
	// notify about delete
	MBSendNotifyItemSelectionChanged(nil);
	MBSendNotifyItemValueSelectionChanged(nil);	
}

- (IBAction)menuActivateDetailView:(id)sender
{
	[self changeMainViewTo:[NSNumber numberWithInt:0]];
}

- (IBAction)menuActivateSearchView:(id)sender
{
	[self changeMainViewTo:[NSNumber numberWithInt:1]];
}

/**
 \brief action for emptying the trashcan
*/
- (IBAction)menuEmptyTrashcan:(id)sender {
	NSAlert *alert = [NSAlert alertWithMessageText:MBLocaleStr(@"TrashcanDeleteTitle")
									 defaultButton:MBLocaleStr(@"OK")
								   alternateButton:MBLocaleStr(@"Cancel")
									   otherButton:nil 
						 informativeTextWithFormat:MBLocaleStr(@"TrashcanDeleteConfirm")];
	if([alert runModal] == NSAlertDefaultReturn)
	{
		// send notification to start main progressindicator
		MBSendNotifyProgressIndicationActionStarted(nil);
		
		MBItemBaseController *ibc = [MBItemBaseController standardController];
		// we have to delete, user said ok
		NSMutableArray *deleteArray = [NSMutableArray arrayWithArray:[[ibc trashcanItem] children]];
		// delete the items
		[ibc removeObjects:deleteArray];
		// delete the itemValues as well
		deleteArray = [NSMutableArray arrayWithArray:[[ibc trashcanItem] itemValues]];
		[ibc removeObjects:deleteArray];
		
		// send notification to stop main progressindicator
		MBSendNotifyProgressIndicationActionStopped(nil);			
	}
}

/**
 \brief adding a new item
*/
- (IBAction)menuNewItem:(id)sender {
	MBItemBaseController *ibc = [MBItemBaseController standardController];

    NSInteger tag = [(id<NSValidatedUserInterfaceItem>)sender tag];
    
	if(tag == 0) {
		// we are adding a root item
		[ibc addNewItemByType:StdItemType toRoot:YES];
	} else if(tag == ItemRefType) {
		[ibc addNewItemByType:ItemRefType toRoot:NO];
	} else {
		// we are adding a item to the current selection
		[ibc addNewItemByType:StdItemType toRoot:NO];
	}
}

- (IBAction)menuNewItemValue:(id)sender {
	MBItemBaseController *ibc = [MBItemBaseController standardController];

	// create new item value with tag of sender
    NSInteger tag = [(id<NSValidatedUserInterfaceItem>)sender tag];
	[ibc addNewItemValueByType:tag];
}

- (IBAction)menuNewFromTemplate:(id)sender {
	// get Template item from tag (id)
    NSInteger tag = [(id<NSValidatedUserInterfaceItem>)sender tag];
	int itemId = tag;
	if(itemId > 0) {
		MBItem *tItem = [itemController templateItemById:itemId];
		if(tItem != nil) {
			// copy this item
			// this method takes care of destination
			[itemController addItem:tItem operation:CopyOperation];
		} else {
			CocoLog(LEVEL_WARN,@"[MBInterfaceController -menuNewFromTemplate:] template item is nil");
		}
	} else {
		CocoLog(LEVEL_WARN,@"[MBInterfaceController -menuNewFromTemplate:] itemId is invalid");
	}
}

// define as template
- (IBAction)menuDefineAsTemplate:(id)sender {
	// sort out any system items, they cannot be defines as template
	// get selected items
	NSMutableArray *selectedItems = [itemController currentItemSelection];
	NSEnumerator *iter = [selectedItems objectEnumerator];
	MBCommonItem *item = nil;
	while((item = [iter nextObject]))
	{
		if(NSLocationInRange([item identifier],SYSTEMITEM_ID_RANGE))
		{
			[selectedItems removeObject:item];
		}
	}

	// copy all items to the root template item
	MBItemBaseController *ibc = itemController;
	[ibc addObjects:selectedItems toItem:[ibc templateItem] withIndex:-1 withConnectingObjects:YES operation:CopyOperation];
}

/**
 \brief creates a reference of all currently selected items or item values
*/
- (IBAction)menuCreateRef:(id)sender
{
	CocoLog(LEVEL_DEBUG,@"[MBInterfaceController -menuCreateRef:]");
	
	NSMutableArray *copySelection = nil;
	// check, which view is the first responder
	if([mainWindow firstResponder] == [itemOutlineViewController outlineView])
	{
		copySelection = [itemController currentItemSelection];
	}
	else // if([mainWindow firstResponder] == [itemValueListViewController tableView])
	{
		copySelection = [itemController currentItemValueSelection];
	}
	
	if([copySelection count] == 0)
	{
		NSAlert *alert = [NSAlert alertWithMessageText:MBLocaleStr(@"NoSelectionTitle") 
										 defaultButton:MBLocaleStr(@"OK") 
									   alternateButton:nil
										   otherButton:nil 
							 informativeTextWithFormat:MBLocaleStr(@"NoSelectionMsg")];
		[alert runModal];		
	}
	else
	{
		BOOL proceed = YES;
		if([copySelection count] > 1)
		{
			NSAlert *alert = [NSAlert alertWithMessageText:MBLocaleStr(@"MoreItemsSelectedForReferencingTitle") 
											 defaultButton:MBLocaleStr(@"Yes") 
										   alternateButton:MBLocaleStr(@"No")
											   otherButton:nil 
								 informativeTextWithFormat:MBLocaleStr(@"MoreItemsSelectedForReferencingMsg")];
			int result = [alert runModal];
			if(result == NSAlertAlternateReturn)
			{
				proceed = NO;
			}
		}
		
		if(proceed)
		{
			// we do the db transaction ourselfs
			MBDBAccess *dbAccess = [MBDBAccess sharedConnection];
			// send begin transaction
			[dbAccess sendBeginTransaction];
			
			NSEnumerator *iter = [copySelection objectEnumerator];
			MBCommonItem *item = nil;
			while((item = [iter nextObject]))
			{
				if(NSLocationInRange([item identifier],ITEM_ID_RANGE))
				{
					MBItem *parent = (MBItem *)[(MBItem *)item parentItem];
					
					if([item identifier] == ItemRefID)
					{
						item = [(MBRefItem *)item target];
					}
					
					if(item != nil)
					{
						// create reference
						MBRefItem *ref = [[[MBRefItem alloc] initWithTarget:item] autorelease];
						// add this to parent
						[itemController addItem:ref 
										 toItem:parent 
									  withIndex:0 
							 withConnectingItem:YES 
									  operation:AddOperation 
							  withDbTransaction:NO];
					}
				}
				else if(NSLocationInRange([item identifier],ITEMVALUE_ID_RANGE))
				{
					MBItem *parent = (MBItem *)[(MBItemValue *)item item];
					
					if([item identifier] == ItemValueRefID)
					{
						item = [(MBRefItem *)item target];
					}
					
					if(item != nil)
					{
						// create reference
						MBRefItem *ref = [[[MBRefItem alloc] initWithTarget:item] autorelease];
						// add
						[itemController addItemValue:ref 
											  toItem:parent 
								 withConnectingValue:YES 
										   operation:AddOperation
								   withDbTransaction:NO];
					}					
				}
			}
			
			// send commit transaction
			[dbAccess sendCommitTransaction];
			
			// update trees and tableviews
			MBSendNotifyItemTreeChanged(nil);
			MBSendNotifyItemValueListChanged(nil);
		}
	}
}

- (IBAction)menuToggleInfoView:(id)sender {
	// call method of toolbar controller
	[toolbarController toggleInfoView:nil];
}

// import export
- (IBAction)menuExport:(id)sender {
	CocoLog(LEVEL_DEBUG,@"[MBInterfaceController -menuExport:]");
	
	NSMutableArray *copySelection = nil;
	// check, which view is the first responder
	if([mainWindow firstResponder] == [itemOutlineViewController outlineView]) {
		copySelection = [itemController currentItemSelection];
	} else { // if([mainWindow firstResponder] == [itemValueListViewController tableView]) {
		copySelection = [itemController currentItemValueSelection];
	}
	
	if([copySelection count] > 0) {
		// sort out any system items, they cannot be copied, cut or paste
		NSEnumerator *iter = [copySelection objectEnumerator];
		MBCommonItem *item = nil;
		while((item = [iter nextObject])) {
			if(NSLocationInRange([item identifier],SYSTEMITEM_ID_RANGE)) {
				[copySelection removeObject:item];
			}
		}
		MBExporter *exporter = [MBExporter defaultExporter];
		[exporter export:copySelection exportFolder:nil exportType:-1];
	}
}

- (IBAction)menuImport:(id)sender {
	CocoLog(LEVEL_DEBUG,@"[MBInterfaceController -menuImport:]");

	// get current selected item
	MBItem *item = [itemController creationDestinationWithWarningPanel:NO];
	
	MBImporter *importer = [MBImporter defaultImporter];	
	// import
	[importer fileValueImport:nil toItem:item];
}

// open and open with
- (IBAction)menuOpenItem:(id)sender {
	CocoLog(LEVEL_DEBUG,@"[MBInterfaceController -menuOpenItem:]");

    // call open from info detail controller
    [(MBBaseDetailViewController *)[infoViewController currentDetailViewController] openItemValue];
}

- (IBAction)menuOpenItemWith:(id)sender {
	CocoLog(LEVEL_DEBUG,@"[MBInterfaceController -menuOpenItemWith:]");

    // call open from info detail controller
    [(MBBaseDetailViewController *)[infoViewController currentDetailViewController] openItemValueWith];
}

// encryption menu
- (IBAction)menuEncryptWithDefaultPassword:(id)sender {
	CocoLog(LEVEL_DEBUG,@"[MBInterfaceController -menuEncryptWithDefaultPassword:]");
	
	NSArray *itemvals = [itemController currentItemValueSelection];
	// we only can decrypt or encrypt one itemvalue at a time
	if([itemvals count] > 1) {
		NSBeginAlertSheet(MBLocaleStr(@"EncryptingOnlyOneItemValueTitle"),
						  MBLocaleStr(@"OK"),
						  nil,nil,
						  [GlobalWindows mainAppWindow],
						  nil,nil,nil,NULL,
						  MBLocaleStr(@"EncryptingOnlyOneItemValueMsg"));
	} else {
        // get password from Keychain
        NSString *pw = @"";
        EMGenericKeychainItem *kItem = [[EMKeychainProxy sharedProxy] genericKeychainItemForService:@"iKnowAndManage" withUsername:@"DefaultPassword"];
        if(kItem) {
            pw = [kItem password];
        }
        
		if([pw length] == 0) {
			NSBeginAlertSheet(MBLocaleStr(@"NoDefaultEncryptPWSetTitle"),
							  MBLocaleStr(@"OK"),
							  nil,nil,
							  [GlobalWindows mainAppWindow],
							  nil,nil,nil,NULL,
							  MBLocaleStr(@"NoDefaultEncryptPWSetMsg"));			
		} else {
            // now hash
            pw = [pw sha1Hash];
			BOOL error = [self encryptItemValues:itemvals withPassword:pw];
			// has an error occured?
			if(error) {
				CocoLog(LEVEL_WARN,@"[MBInterfaceController -menuEncryptWithDefaultPassword:] one or more ItemValues could not be decrypted!");
				NSBeginAlertSheet(MBLocaleStr(@"EncryptionFailureTitle"),
								  MBLocaleStr(@"OK"),
								  nil,
								  nil,
								  [GlobalWindows mainAppWindow],
								  nil,nil,nil,nil,
								  MBLocaleStr(@"EncryptionFailureMsg"));		
			} else {
				// refresh views
				MBSendNotifyItemValueListChanged(nil);
			}
		}
	}
}

- (IBAction)menuEncryptWithCustomPassword:(id)sender
{
	CocoLog(LEVEL_DEBUG,@"[MBInterfaceController -menuEncryptWithCustumPassword:]");

	NSArray *itemvals = [itemController currentItemValueSelection];
	// we only can decrypt or encrypt one itemvalue at a time
	if([itemvals count] > 1)
	{
		NSBeginAlertSheet(MBLocaleStr(@"EncryptingOnlyOneItemValueTitle"),
						  MBLocaleStr(@"OK"),
						  nil,nil,
						  [GlobalWindows mainAppWindow],
						  nil,nil,nil,NULL,
						  MBLocaleStr(@"EncryptingOnlyOneItemValueMsg"));
	}
	else
	{
		// ask for password for decryption
		MBPasswordInputController *pwC = [MBPasswordInputController sharedController];
		// start password dialog
		[pwC runDoubleInputWindow];
		// ask for dialog result
		CocoLog(LEVEL_DEBUG,@"back from Password Window");
		// get result
		if([pwC dialogResult] == PasswordOK)
		{
			// get password
			NSString *pw = [NSString stringWithString:[pwC password]];

			// encrypt
			BOOL error = [self encryptItemValues:itemvals withPassword:pw];
			
			// has an error occured?
			if(error)
			{
				CocoLog(LEVEL_WARN,@"[MBInterfaceController -menuEncryptWithDefaultPassword:] one or more ItemValues could not be decrypted!");
				NSBeginAlertSheet(MBLocaleStr(@"EncryptionFailureTitle"),
								  MBLocaleStr(@"OK"),
								  nil,
								  nil,
								  [GlobalWindows mainAppWindow],
								  nil,nil,nil,nil,
								  MBLocaleStr(@"EncryptionFailureMsg"));		
			}
			else
			{
				// refresh views
				MBSendNotifyItemValueListChanged(nil);
			}
		}
	}
}

- (IBAction)menuDecrypt:(id)sender
{
	CocoLog(LEVEL_DEBUG,@"[MBInterfaceController -menuDecrypt:]");

	NSArray *itemvals = [itemController currentItemValueSelection];
	// we only can decrypt or encrypt one itemvalue at a time
	if([itemvals count] > 1) {
		NSBeginAlertSheet(MBLocaleStr(@"DecryptingOnlyOneItemValueTitle"),
						  MBLocaleStr(@"OK"),
						  nil,nil,
						  [GlobalWindows mainAppWindow],
						  nil,nil,nil,NULL,
						  MBLocaleStr(@"DecryptingOnlyOneItemValueMsg"));
	} else {
		// ask for password for decryption
		MBPasswordInputController *pwC = [MBPasswordInputController sharedController];
		// start password dialog
		[pwC runSingleInputWindow];
		// ask for dialog result
		CocoLog(LEVEL_DEBUG, @"back from Password Window");
		// get result
		if([pwC dialogResult] == PasswordOK) {
			// get password
			NSString *pw = [NSString stringWithString:[pwC password]];
			
			// encrypt all current ItemValues
			NSEnumerator *iter = [itemvals objectEnumerator];
			MBItemValue *itemval = nil;
			BOOL error = NO;
			while((itemval = [iter nextObject])) {
				// is reference?
				if(([itemval identifier] == ItemRefID) ||
				   ([itemval identifier] == ItemValueRefID)) {
					itemval = (MBItemValue *)[(MBRefItem *)itemval target];
				}
				
				// reference target may not be nil
				if(itemval != nil) {                    
					int stat = [itemval decryptWithString:pw];
					if(stat == MBCryptoOK) {
						// refresh infoview
						MBSendNotifyItemValueAttribsChanged(itemval);			
					} else if(stat == MBCryptoWrongDecryptionKey) {
							NSRunAlertPanel(MBLocaleStr(@"WrongDecryptionPasswordTitle"),
											MBLocaleStr(@"WrongDecryptionPasswordMsgForNoMoreItemsToCome"),
											MBLocaleStr(@"OK"),nil,nil);
					} else {
						error = YES;
					}
				}
			}
			
			// has an error occured?
			if(error) {
				CocoLog(LEVEL_WARN,@"[MBInterfaceController -menDecrypt:] one or more ItemValues could not be decrypted!");
				NSBeginAlertSheet(MBLocaleStr(@"DecryptionFailureTitle"),
								  MBLocaleStr(@"OK"),
								  nil,
								  nil,
								  [GlobalWindows mainAppWindow],
								  nil,nil,nil,nil,
								  MBLocaleStr(@"DecryptionFailureMsg"));		
			} else {
				// refresh views
				MBSendNotifyItemValueListChanged(nil);
			}
		}
	}
}

#pragma mark - NSSplitView delegates

- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize {
    //detect if it's a window resize
    if ([sender inLiveResize]) {
        //info needed
        NSArray *subviews = [sender subviews];
        
        NSView *left = [subviews objectAtIndex:0];
        NSRect leftRect = [left bounds];
        NSView *mid = [subviews objectAtIndex:1];
        NSView *right = nil;
        NSRect rightRect = NSZeroRect;
        if([subviews count] == 3) {
            right = [subviews objectAtIndex:2];
            rightRect = [right bounds];
        }
        
        // left side stays fix
        NSRect tmpRect = [sender bounds];
        tmpRect.size.width = leftRect.size.width;
        tmpRect.origin.x = 0;
        [left setFrame:tmpRect];
        
        // mid dynamic
        tmpRect.size.width = [sender bounds].size.width - (leftRect.size.width + rightRect.size.width + [sender dividerThickness]);
        double midWidth = tmpRect.size.width;
        if(rightRect.size.width > 0.0) {
            tmpRect.size.width -= [sender dividerThickness];
        }
        tmpRect.origin.x = leftRect.size.width + [sender dividerThickness];
        [mid setFrame:tmpRect];
        
        // right side stays fixed
        tmpRect.size.width = rightRect.size.width;
        tmpRect.origin.x = midWidth + leftRect.size.width + 2 * [sender dividerThickness] - 1;
        [right setFrame:tmpRect];
    } else {
        [sender adjustSubviews];
    }
}

@end
