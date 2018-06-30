// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import "MBInfoViewController.h"
#import "MBItemBaseController.h"
#import "MBItem.h"
#import "MBRefItem.h"
#import "MBImagePopUpButton.h"
#import "globals.h"
#import "MBGeneralPrefsViewController.h"
#import "MBStdItem.h"
#import "MBBaseDetailViewController.h"
#import "MBNumberValueDetailViewController.h"
#import "MBNumberItemValue.h"
#import "MBExtendedTextItemValue.h"
#import "MBTextValueDetailViewController.h"
#import "MBTextItemValue.h"
#import "MBBoolItemValue.h"
#import "MBBoolValueDetailViewController.h"
#import "MBDateItemValue.h"
#import "MBDateValueDetailViewController.h"
#import "MBURLItemValue.h"
#import "MBImageItemValue.h"
#import "MBImageValueDetailViewController.h"
#import "MBPDFItemValue.h"
#import "MBExporter.h"
#import "MBETextValueDetailViewController.h"
#import "MBURLValueDetailViewController.h"
#import "MBFileValueDetailViewController.h"
#import "MBPDFValueDetailViewController.h"
#import "MBSystemItem.h"

@interface MBInfoViewController (privateAPI)

- (void)populateTargetPopUpButton;

@end

@implementation MBInfoViewController (privateAPI)

- (void)populateTargetPopUpButton {
	// check target button
	if(isRefItem == YES) {
		[targetPopUpButton setEnabled:YES];
		// populate
		MBItemBaseController *ibc = itemController;
		// build
		NSMenu *menu = [[NSMenu alloc] init];
		
		// do we have a target?
		if(refItem == currentItem) {
			// no
			NSMenuItem *menuItem = [[NSMenuItem alloc] init];
			[menuItem setTitle:@"no target"];
			[menu addItem:menuItem];
			[menuItem release];
		} else {
			// yes
			NSMenuItem *menuItem = [[NSMenuItem alloc] init];
			[menuItem setTitle:[(MBItem *)currentItem name]];
			[menuItem setTag:[currentItem itemID]];
			[menu addItem:menuItem];
			[menuItem release];
			// second time
			menuItem = [[NSMenuItem alloc] init];
			[menuItem setTitle:[(MBItem *)currentItem name]];
			[menuItem setTag:[currentItem itemID]];
			[menu addItem:menuItem];
			[menuItem release];
			// separator
			menuItem = [NSMenuItem separatorItem];
			[menu addItem:menuItem];
		}
		
		if([refItem identifier] == ItemRefID) {
			[ibc generateItemMenu:&menu 
					  forItemtype:-1 
						   ofItem:[ibc rootItem] 
				   withMenuTarget:self 
				   withMenuAction:@selector(setRefTarget:)];
		} else {
			// give our menu
			[ibc generateValueMenu:&menu 
					  forValuetype:-1
							ofItem:[ibc rootItem] 
					withMenuTarget:self 
					withMenuAction:@selector(setRefTarget:)];
		}
					
		// set menu in PopUpButton
		[targetPopUpButton setMenu:menu];
		[menu release];			
	} else {
		[targetPopUpButton setEnabled:NO];			
	}
}

@end


@implementation MBInfoViewController

- (id)init {
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"cannot alloc MBInfoViewController!");		
	} else {
		// nil currentItem
		[self setCurrentItem:nil];
		
		// create undo manager for textviews
		textViewUndoManager = [[NSUndoManager alloc] init];		
	}

	return self;
}

- (void)awakeFromNib {
	if(self != nil) {
		// set initial size
		viewFrame = [infoViewFrame frame];
        viewFrame.size.width = 350; // min
		
        // load images
		lockedImage = [[NSImage imageNamed:@"lock"] retain];
		unlockedImage = [[NSImage imageNamed:@"unlock"] retain];

		// make normal encryption button hidden
		[encryptionButton setHidden:YES];
		[encryptionButton setEnabled:NO];
		// init encryption popUpButton
		encryptionPopUpButton = [[MBImagePopUpButton alloc] init];
		[encryptionPopUpButton setFrame:NSMakeRect([encryptionButton frame].origin.x,[encryptionButton frame].origin.y,39,32)];
		[encryptionPopUpButton setPullsDown:YES];
		[[encryptionPopUpButton cell] setUsesItemFromMenu:NO];
		[encryptionPopUpButton setIconImage:unlockedImage];
		[encryptionPopUpButton setShowsMenuWhenIconIsClicked:YES];
		[encryptionPopUpButton setAutoresizingMask:(NSViewMaxXMargin | NSViewMinYMargin)];
		// create menu for popupbutton
		[self recreateEncryptionMenu];
		// add to infoview
		[infoView addSubview:encryptionPopUpButton];
		
		// set textvalue textview to richtext
		[commentTextView setRichText:NO];

		// register notification 
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(appInitialized:)
													 name:MBAppInitializedNotification object:nil];
		// register notification
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(itemAttribsChanged:)
													 name:MBItemAttribsChangedNotification object:nil];
		// register notification
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(itemAttribsChanged:)
													 name:MBItemValueAttribsChangedNotification object:nil];
		// register notification 
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(itemSelectionChanged:)
													 name:MBItemSelectionChangedNotification object:nil];		
		// register notification 
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(itemSelectionChanged:)
													 name:MBItemValueSelectionChangedNotification object:nil];		
		// register some NSUserDefaults changes
		[userDefaults addObserver:self 
					   forKeyPath:MBDefaultsUsePanelInfoKey
						  options:NSKeyValueObservingOptionNew context:nil];
	}
}

/**
\brief dealloc of this class is called on closing this document
 */
- (void)dealloc {
	// release undomanager
	[self setTextViewUndoManager:nil];
	
	// release images
	[lockedImage release];
	[unlockedImage release];	
	
	// dealloc object
	[super dealloc];
}

- (void)setDelegate:(id)aDelegate {
    delegate = aDelegate;
}

- (id)delegate {
    return delegate;
}

/**
 \brief the main view itself
*/
- (NSView *)infoView {
	return infoViewFrame;
}

/**
 \brief the initial frame of this view
*/
- (NSRect)viewFrame {
	return viewFrame;
}

// get the current detail view controller
- (id)currentDetailViewController {
    return currentDetailViewController;
}

//--------------------------------------------------------------------
//----------- getters and setters ---------------------------------------
//--------------------------------------------------------------------
/**
\brief set the undo manager for the textviews in this view
 */
- (void)setTextViewUndoManager:(NSUndoManager *)aUndoManager {
	[aUndoManager retain];
	[textViewUndoManager release];
	textViewUndoManager = aUndoManager;
}

/**
\brief get the undomanager for the textviews in this view
 */
- (NSUndoManager *)textViewUndoManager {
	return textViewUndoManager;
}

/**
\brief set the item of which information should be shown
 no retains is made.
 */
- (void)displayInfo {
	if(currentItem != nil) {
		NSString *type = @"";
		NSString *name = @"";
		NSString *comment = @"";
		NSDate *creationDate = [NSDate date];
		NSNumber *numOfChildren = [NSNumber numberWithInt:0];
		NSNumber *numOfChildrenInSubtree = [NSNumber numberWithInt:0];
		NSNumber *numOfValues = [NSNumber numberWithInt:0];
		NSNumber *numOfValuesInSubtree = [NSNumber numberWithInt:0];
		NSNumber *sortorder = [NSNumber numberWithInt:0];
		
		// switch for item identifier
		if(NSLocationInRange([currentItem identifier], ITEM_ID_RANGE)) {
			MBItem *item = (MBItem *)currentItem;

			if(isRefItem == YES) {
				type = ITEMREF_ITEMTYPE_NAME;
			} else {
				// type
				switch([item itemtype]) {
					case StdItemType:
						type = STD_ITEMTYPE_NAME;
						break;
					case TableItemType:
						type = TABLE_ITEMTYPE_NAME;
						break;
					case TemplateItemType:
						type = TEMPLATE_ITEMTYPE_NAME;
						break;
					default:
						// only these types are handled here
						break;
				}

				// date
				creationDate = [(MBStdItem *)item dateCreated];
				// sortorder
				sortorder = [NSNumber numberWithInt:[item sortorder]];
				// comment
				comment = [(MBStdItem *)item comment];
				// numbers
				numOfChildren = [NSNumber numberWithInt:[[(MBItem *)item children] count]];
				numOfChildrenInSubtree = [NSNumber numberWithInt:[(MBItem *)item numberOfChildrenInSubtree:YES]];
				numOfValues = [NSNumber numberWithInt:[[(MBItem *)item itemValues] count]];
				numOfValuesInSubtree = [NSNumber numberWithInt:[(MBItem *)item numberOfItemValuesInSubtree:YES]];
			}
			
			// name
			name = [item name];
			
			// enable stuff
			[nameTextField setEnabled:YES];		
			[commentTextView setEditable:YES];
			[sortorderTextField setEnabled:NO];
			[sortorderStepper setEnabled:NO];
		} else if(NSLocationInRange([currentItem identifier], ITEMVALUE_ID_RANGE) == YES) {
			// activate encryption button, itemvalues can be encrypted
			[encryptionPopUpButton setEnabled:YES];

			MBItemValue *itemval = (MBItemValue *)currentItem;
			
			if(isRefItem == YES) {
				type = ITEMVALUEREF_ITEMTYPE_NAME;
			} else {
				// type
				switch([itemval valuetype]) {
					case SimpleTextItemValueType:
						type = SIMPLETEXT_ITEMVALUE_TYPE_NAME;
						break;
					case ExtendedTextItemValueType:
						type = EXTENDEDTEXT_ITEMVALUE_TYPE_NAME;
						break;
					case NumberItemValueType:
						type = NUMBER_ITEMVALUE_TYPE_NAME;
						break;
					case CurrencyItemValueType:
						type = CURRENCY_ITEMVALUE_TYPE_NAME;
						break;
					case BoolItemValueType:
						type = BOOL_ITEMVALUE_TYPE_NAME;
						break;
					case DateItemValueType:
						type = DATE_ITEMVALUE_TYPE_NAME;
						break;
					case URLItemValueType:
						type = URL_ITEMVALUE_TYPE_NAME;
						break;
					case ImageItemValueType:
						type = IMAGE_ITEMVALUE_TYPE_NAME;
						break;
					case FileItemValueType:
						type = FILE_ITEMVALUE_TYPE_NAME;
						break;
					case PDFItemValueType:
						type = PDF_ITEMVALUE_TYPE_NAME;
						break;
					case ItemValueRefType:
						type = ITEMVALUEREF_ITEMTYPE_NAME;
						break;
				}

				// date
				creationDate = [itemval dateCreated];
				// sortorder
				sortorder = [NSNumber numberWithInt:[itemval sortorder]];
				// comment
				comment = [itemval comment];
				// numbers
				numOfChildren = [NSNumber numberWithInt:0];
				numOfChildrenInSubtree = [NSNumber numberWithInt:0];
				numOfValues = [NSNumber numberWithInt:0];
				numOfValuesInSubtree = [NSNumber numberWithInt:0];
			}
			
			// name
			name = [itemval name];
			
			// enable stuff
			[nameTextField setEnabled:YES];		
			[commentTextView setEditable:YES];
			[sortorderTextField setEnabled:YES];
			[sortorderStepper setEnabled:YES];
			
			// if this itemvalue is encrypted, disable comment textfield and write encrypted in it
			if([itemval encryptionState] == EncryptedState) {
				comment = [NSString stringWithFormat:@"[%@]", MBLocaleStr(@"Encrypted")];
				[commentTextView setEditable:NO];
				// set another image to popupbutton
				[encryptionPopUpButton setIconImage:lockedImage];
			} else {
				[commentTextView setEditable:YES];				
				// set another image to popupbutton
				[encryptionPopUpButton setIconImage:unlockedImage];
			}
		} else if(NSLocationInRange([currentItem identifier],SYSTEMITEM_ID_RANGE) == YES) {
			MBSystemItem *item = (MBSystemItem *)currentItem;

			// type
			type = @"System Item";
			// name
			name = [item name];
			// sortorder
			sortorder = [NSNumber numberWithInt:0];
			// numbers
			numOfChildren = [NSNumber numberWithInt:[[(MBItem *)item children] count]];
			numOfChildrenInSubtree = [NSNumber numberWithInt:[(MBItem *)item numberOfChildrenInSubtree:YES]];
			numOfValues = [NSNumber numberWithInt:[[(MBItem *)item itemValues] count]];
			numOfValuesInSubtree = [NSNumber numberWithInt:[(MBItem *)item numberOfItemValuesInSubtree:YES]];
			
			// enable stuff
			[nameTextField setEnabled:NO];		
			[commentTextView setEditable:NO];
			[sortorderTextField setEnabled:NO];
			[sortorderStepper setEnabled:NO];			
		}
		
		// set encrypted button
		//[encryptionButton setState:(int)[currentItem isEncrypted]];
		//[self acc_EncryptionButton:encryptionButton];
		
		// set things to textfield
		[typeLabel setStringValue:type];
		[nameTextField setStringValue:name];
		[sortorderStepper setObjectValue:sortorder];
		[sortorderTextField setObjectValue:sortorder];
		if(creationDate == nil) {
			[creationDateTextField setStringValue:@""];
		} else {
			[creationDateTextField setObjectValue:creationDate];
		}
		
		// set numbers
		[numberOfChildrenTextField setObjectValue:numOfChildren];
		[numberOfChildrenInSubtreeTextField setObjectValue:numOfChildrenInSubtree];
		[numberOfValuesTextField setObjectValue:numOfValues];
		[numberOfValuesInSubtreeTextField setObjectValue:numOfValuesInSubtree];
		
		// set comment
		initOfTextViews = YES;
		[commentTextView replaceCharactersInRange:NSMakeRange(0,[[commentTextView textStorage] length]) withString:comment];
		initOfTextViews = NO;		
	}

	[self populateTargetPopUpButton];
}

- (void)setCurrentItem:(MBCommonItem *)aItem {
	currentItem = aItem;
	
	// check for reference
	if(([currentItem identifier] == ItemRefID) ||
	   ([currentItem identifier] == ItemValueRefID)) {
		isRefItem = YES;
		refItem = (MBRefItem *)currentItem;
		if([refItem target] != nil) {
			currentItem = [(MBRefItem *)refItem target];
		}
	} else {
		isRefItem = NO;
		refItem = nil;
	}

	if(currentItem != nil) {
		if(NSLocationInRange([currentItem identifier],ITEMVALUE_ID_RANGE)) {
			MBItemValue *itemval = (MBItemValue *)currentItem;

			NSView *detailView = nil;
			if([itemval encryptionState] != EncryptedState) {
				// check for value type
				switch([itemval valuetype]) {
					case SimpleTextItemValueType:
						[textValueViewController setCurrentItemValue:(MBTextItemValue *)itemval];
						[textValueViewController displayInfo];
						currentDetailViewController = textValueViewController;
						detailView = [textValueViewController theView];
						break;
					case ExtendedTextItemValueType:
						[eTextValueViewController setCurrentItemValue:(MBExtendedTextItemValue *)itemval];
						[eTextValueViewController displayInfo];
						currentDetailViewController = eTextValueViewController;
						detailView = [eTextValueViewController theView];
						break;
					case NumberItemValueType:
					case CurrencyItemValueType:
						[numberValueViewController setCurrentItemValue:(MBNumberItemValue *)itemval];
						[numberValueViewController displayInfo];
						currentDetailViewController = numberValueViewController;
						detailView = [numberValueViewController theView];
						break;
					case BoolItemValueType:
						[boolValueViewController setCurrentItemValue:(MBBoolItemValue *)itemval];
						[boolValueViewController displayInfo];
						currentDetailViewController = boolValueViewController;
						detailView = [boolValueViewController theView];						
						break;
					case DateItemValueType:
						[dateValueViewController setCurrentItemValue:(MBDateItemValue *)itemval];
						[dateValueViewController displayInfo];
						currentDetailViewController = dateValueViewController;
						detailView = [dateValueViewController theView];
						break;
					case URLItemValueType:
						[urlValueViewController setCurrentItemValue:(MBURLItemValue *)itemval];
						[urlValueViewController displayInfo];
						currentDetailViewController = urlValueViewController;
						detailView = [urlValueViewController theView];
						break;
					case ImageItemValueType:
						[imageValueViewController setCurrentItemValue:(MBImageItemValue *)itemval];
						[imageValueViewController displayInfo];
						currentDetailViewController = imageValueViewController;
						detailView = [imageValueViewController theView];
						break;
					case FileItemValueType:
						[fileValueViewController setCurrentItemValue:(MBFileItemValue *)itemval];
						[fileValueViewController displayInfo];
						currentDetailViewController = fileValueViewController;
						detailView = [fileValueViewController theView];
						break;
					case PDFItemValueType:
						[pdfValueViewController setCurrentItemValue:(MBPDFItemValue *)itemval];
						[pdfValueViewController displayInfo];
						currentDetailViewController = pdfValueViewController;
						detailView = [pdfValueViewController theView];
						break;
					case ItemValueRefType:
						detailView = noDetailsAvailableView;
						break;						
					default:
						[textValueViewController setCurrentItemValue:(MBTextItemValue *)itemval];
						[textValueViewController displayInfo];
						currentDetailViewController = textValueViewController;
						detailView = [textValueViewController theView];
						break;
				}
				
				// set to contentview of 2. tabitem
				NSTabViewItem *tabItem = [tabView tabViewItemAtIndex:1];
				[tabItem setView:detailView];
				[tabView selectTabViewItem:tabItem];				
			} else {
				detailView = encryptedDataView;
				
				// set to contentview of 2. tabitem
				NSTabViewItem *tabItem = [tabView tabViewItemAtIndex:1];
				[tabItem setView:detailView];
				[tabView selectTabViewItemAtIndex:0];
			}

			// set infoview on first tabitem
			NSTabViewItem *tabItem = [tabView tabViewItemAtIndex:0];
			[tabItem setView:infoView];
		} else if(NSLocationInRange([currentItem identifier],ITEM_ID_RANGE)) {
			// send nil to detailViewController
			[currentDetailViewController setCurrentItemValue:nil];
			// reset display
			[currentDetailViewController displayInfo];
			
			// set to contentview of 2. tabitem
			NSTabViewItem *tabItem = [tabView tabViewItemAtIndex:1];
			[tabItem setView:noDetailsAvailableView];
			
			// switch to tabviewitem 0
			tabItem = [tabView tabViewItemAtIndex:0];
			[tabItem setView:infoView];
			[tabView selectTabViewItem:tabItem];
		}
	} else {
		// set to contentview of 2. tabitem
		NSTabViewItem *tabItem = [tabView tabViewItemAtIndex:1];
		[tabItem setView:noDetailsAvailableView];
		
		tabItem = [tabView tabViewItemAtIndex:0];
		[tabItem setView:noInfoAvailableView];
		
		// switch to tabviewitem 0
		[tabView selectTabViewItemAtIndex:0];	
	}
}

- (MBCommonItem *)currentItem {
	return currentItem;
}

// encryption menu creation
- (void)recreateEncryptionMenu {
	// create the menu entries for encryption
	NSMenu *subMenu = [[NSMenu alloc] init];
	// make a dummy menuitem
	[subMenu addItem:[[[NSMenuItem alloc] init] autorelease]];
	// for through list of menu item and add a copy of them to subMenu
	NSArray *itemArray = [[encryptionMenuItem submenu] itemArray];
	for(int i = 0;i < [itemArray count];i++) {
		NSMenuItem *item = [itemArray objectAtIndex:i];
		item = [item copy];
		[subMenu addItem:item];
		[item release];
	}
	[encryptionPopUpButton setMenu:subMenu];
	[subMenu release];	
}

//--------------------------------------------------------------------
//----------- actions ---------------------------------------
//--------------------------------------------------------------------
- (void)setRefTarget:(id)sender {
	if(refItem != nil) {
		MBItemBaseController *ibc = itemController;
		
		// get itemid
		int itemid = [sender tag];
		MBCommonItem *target = [ibc commonItemForId:itemid];

		BOOL setTarget = YES;
		if([refItem identifier] == ItemRefID) {
			// check, if the ref target is in the same subtree as the reference item
			if([ibc isChild:(MBItem *)refItem inSubtreeOfParent:(MBItem *)target]) {
				NSAlert *alert  = [NSAlert alertWithMessageText:MBLocaleStr(@"ReferenceNotInSameSubtreeTitle") 
												  defaultButton:MBLocaleStr(@"OK") 
												alternateButton:nil 
													otherButton:nil 
									  informativeTextWithFormat:MBLocaleStr(@"ReferenceNotInSameSubtreeMsg")];
				[alert runModal];
				
				setTarget = NO;
			}
		}

		// do we set the target=
		if(setTarget) {
			// set reference target
			[refItem setTarget:target];
			
			// we have a new currentIte, too
			currentItem = target;
			
			// recreate menu
			[self populateTargetPopUpButton];
		}
	}
}

- (IBAction)acc_NameInput:(id)sender {
	// set new name for item
	if(currentItem != nil) {
		if(NSLocationInRange([currentItem identifier],ITEMVALUE_ID_RANGE)) {
			MBItemValue *itemval = (MBItemValue *)currentItem;			
			[itemval setName:[sender stringValue]];
		} else if(NSLocationInRange([currentItem identifier],ITEM_ID_RANGE)) {
			MBItem *item = (MBItem *)currentItem;			
			[item setName:[sender stringValue]];
		}
	}
}

- (IBAction)acc_SortorderInput:(id)sender {
	// set sortorder for item
	if(currentItem != nil) {
		if(NSLocationInRange([currentItem identifier],ITEMVALUE_ID_RANGE)) {
			MBItemValue *itemval = (MBItemValue *)currentItem;
			[itemval setSortorder:[sender intValue]];
			// set same value for stepper
			[sortorderStepper setIntValue:[sender intValue]];
		}
	}		
}

- (IBAction)acc_SortorderStepperChange:(id)sender {
	// set sortorder for item
	if(currentItem != nil) {
		if(NSLocationInRange([currentItem identifier],ITEMVALUE_ID_RANGE)) {
			MBItemValue *itemval = (MBItemValue *)currentItem;
			[itemval setSortorder:[sender intValue]];
			// set same value for stepper
			[sortorderTextField setObjectValue:[NSNumber numberWithInt:[sender intValue]]];
		}
	}			
}

- (IBAction)acc_ExportButton:(id)sender {
	MBExporter *exporter = [MBExporter defaultExporter];	
	// export the current selected item or itemvalue
	NSArray *array = [NSArray arrayWithObject:currentItem];
	[exporter export:array exportFolder:nil exportType:-1];
}

- (IBAction)acc_EncryptionButton:(id)sender {
	/*
	// save
	[currentItem setEncrypted:(BOOL)[sender state]];

	if([sender state] == 0)
	{
		// unlocked
		[(NSButton *)sender setImage:unlockedImage];
	}
	else
	{
		// locked
		[(NSButton *)sender setImage:lockedImage];	
	}
	 */
}

//-----------------------------------------------------------------
// NSText delegate methods
//-----------------------------------------------------------------
/**
\brief called when the text in textview has been edited
 */
- (void)textDidEndEditing:(NSNotification *)aNotification {
	if(aNotification != nil) {
		if(currentItem != nil) {
			if(initOfTextViews == NO) {
				MBStdItem *buf = (MBStdItem *)currentItem;
				// set comment in item
				[buf setComment:[[aNotification object] string]];

				// if name has changed, send a notification that the outlineview should reread this item
				MBSendNotifyItemAttribsChanged(currentItem);
			}
		}
	}
}

//-----------------------------------------------------------------
// NSTextView delegate methods
//-----------------------------------------------------------------
- (NSUndoManager *)undoManagerForTextView:(NSTextView *)aTextView {
	return [self textViewUndoManager];
}

// -------------------------------------------------------------------
// KVO Observing
// -------------------------------------------------------------------
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	// check for keyPath
    /*
	if([keyPath isEqualToString:MBDefaultsUsePanelInfoKey] == YES) {
		// get new value
		id newValue = [change valueForKey:NSKeyValueChangeNewKey];
		if(newValue != nil) {
			BOOL showInfo = (BOOL)[newValue intValue];
			// do we show the info right now?
			if(showInfo == YES)
			{
				// nil drawer content
				[infoDrawerController setContentView:nil];
				// close drawer and open panel
				[infoPanelController setContentView:infoViewFrame];
			}
			else
			{
				// nil panel view
				[infoPanelController setContentView:nil];
				// close panel and open drawer
				[infoDrawerController setContentView:infoViewFrame];
			}
		}
	}
     */
}

// -------------------------------------------------------------------
// Notifications
// -------------------------------------------------------------------
/** 
\brief notification that the application has finished with initialization
*/
- (void)appInitialized:(NSNotification *)aNotification {
	if(aNotification != nil) {		
		// start with no info and no detail views
		[self setCurrentItem:nil];
	}
}

- (void)itemAttribsChanged:(NSNotification *) aNotification {
	if(aNotification != nil) {
		MBCommonItem *item = [aNotification object];
		
		// only update if the changed is the selected one
		if(item != nil) {
			if((item == currentItem) || (item == refItem)) {
				// update view
				[self displayInfo];
			}
		}
	}
}

/** 
\brief notification that the selected item has changed

Notification object is the selected MBItem. Now the contentView of MBInfoDrawer is changed to MBItemInfoView
and information of the selected Item is shown.
*/
- (void)itemSelectionChanged:(NSNotification *)aNotification {
	if(aNotification != nil) {
		NSArray *itemSelection = [aNotification object];
		
		if((itemSelection == nil) || ([itemSelection count] == 0)) {
			[self setCurrentItem:nil];
		} else {
			[self setCurrentItem:[itemSelection objectAtIndex:0]];
			
			// display info
			[self displayInfo];
		}
	}
}

@end
