// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <CocoLogger/CocoLogger.h>
#import "MBItemOutlineViewController.h"
#import "MBItemOutlineView.h"
#import "ThreeCellsCell.h"
#import "globals.h"
#import "MBExporter.h"
#import "MBPasteboardType.h"
#import "MBItemType.h"
#import "MBItem.h"
#import "MBItemBaseController.h"
#import "MBInterfaceController.h"
#import "MBImporter.h"
#import "MBExtendedTextItemValue.h"
#import "MBRefItem.h"

@interface MBItemOutlineViewController (privateAPI)

- (void)setCurrentSelection:(NSArray *)selection;

@end

@implementation MBItemOutlineViewController (privateAPI)

- (void)setCurrentSelection:(NSArray *)selection {
	if(selection != currentSelection) {
		[selection retain];
		[currentSelection release];
		currentSelection = selection;
	}
}

@end

@implementation MBItemOutlineViewController

- (id)init {
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"cannot alloc MBItemOutlineViewController!");		
	} else {
		// do some initialization work
		[self setCurrentSelection:[NSArray array]];
	}
	
	return self;
}

/**
\brief dealloc of this class is called on closing this document
 */
- (void)dealloc {
	// release menus
	[importItemMenu release];
	[trashcanItemMenu release];
	[templateItemMenu release];
	[normalItemMenu release];
	
	// unregister for drag and drop
	[outlineView unregisterDraggedTypes];
	
	[stdItemImage release];
	[tableItemImage release];
	[templateItemImage release];
	[trashcanEmptyItemImage release];
	[trashcanFullItemImage release];
	[rootTemplateItemImage release];
	[importItemImage release];
	
	[self setCurrentSelection:nil];
	
	// dealloc object
	[super dealloc];
}

- (void)awakeFromNib {
	if(self != nil) {
		// insert CombinedImageTextCell for the one tablecolumn
		NSTableColumn *tableColumn = [outlineView tableColumnWithIdentifier:COL_IDENTIFIER_ITEM_NAME];
        /*
		CombinedImageTextCell *imageTextCell = [[[CombinedImageTextCell alloc] init] autorelease];
		[imageTextCell setEditable:YES];
        [imageTextCell setTruncatesLastVisibleLine:YES];
		[tableColumn setDataCell:imageTextCell];
         */
        
		ThreeCellsCell *imageTextCell = [[[ThreeCellsCell alloc] init] autorelease];
		[imageTextCell setEditable:YES];
        if([self respondsToSelector:@selector(setTruncatesLastVisibleLine:)]) {
            [imageTextCell setTruncatesLastVisibleLine:YES];
        }
		[tableColumn setDataCell:imageTextCell];

		// load images
		stdItemImage = [[NSImage imageNamed:@"Folder_16"] retain];
		
		// tableItemImage
		tableItemImage = [stdItemImage retain];
		
		// template
		templateItemImage = [stdItemImage retain];
		
		// Ref Image
		itemRefImage = [[NSImage imageNamed:@"FolderRef_16"] retain];
		
		// system items
		//rootTemplateItemImage = [[NSImage imageNamed:@"FolderSystem_16"] retain];
		//importItemImage = [[NSImage imageNamed:@"FolderImports_16"] retain];
		
		// contact
		
		// trashcan empty
		trashcanEmptyItemImage = [[NSImage imageNamed:@"trash-empty"] retain];		
		// trashcan full
		trashcanFullItemImage = [[NSImage imageNamed:@"trash-full"] retain];		

		// create menus
		[self createNormalItemMenu];
		[self createTrashcanItemMenu];
		[self createTemplateItemMenu];
		[self createImportItemMenu];
		// set default menu
		[outlineView setMenu:normalItemMenu];
		
		// register for drag and drop
		[outlineView registerForDraggedTypes:[self validDragAndDropPbTypes]];
		        
		// register notification
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(appWillTerminate:)
													 name:MBAppWillTerminateNotification object:nil];		
		// register notification 
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(appInitialized:)
													 name:MBAppInitializedNotification object:nil];				
		// register notification 
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(menuChanged:)
													 name:MBMenuChangedNotification object:nil];				
		// register notification
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(itemAttribsChanged:)
													 name:MBItemAttribsChangedNotification object:nil];
		// register notification
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(itemTreeChanged:)
													 name:MBItemTreeChangedNotification object:nil];
		// register notification
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(itemAdded:)
													 name:MBItemAddedNotification object:nil];
		// register notification
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(itemSelectionShouldChange:)
													 name:MBItemSelectionShouldChangeInOutlineViewNotification object:nil];
	}	
}

- (NSView *)itemOutlineView {
	return itemOutlineView;
}

- (NSOutlineView *)outlineView {
	return outlineView;
}

- (NSArray *)validDragAndDropPbTypes {
	return [NSArray arrayWithObjects:
		COMMON_ITEM_PB_TYPE_NAME,
		EXPORT_IKAMARCHIVE_TYPESTRING,
		NSFilenamesPboardType,
		NSFilesPromisePboardType,
		NSURLPboardType,
		NSStringPboardType,
		NSRTFPboardType,
		NSRTFDPboardType,
		nil];
}

/**
 This method tales the mousedown event from tableview and uses it for providing it with
 dragPromisedFilesOfTypes: method
 */
- (void)setMouseDownEvent:(NSEvent *)theEvent {
	mouseDownEvent = theEvent;
}

- (NSEvent *)mouseDownEvent {
	return mouseDownEvent;
}

- (NSArray *)currentSelection {
	return currentSelection;
}

#pragma mark - NSOutlineView delegates

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
	int count = 0;
	
	if(item == nil) {
        // we have 4 root items
        count = 3;
	} else {
        if(item == [itemController rootItem]) {
            count = [(MBItem *)item numberOfChildren];
        } else if(item == [itemController templateItem]) {
            count = [(MBItem *)item numberOfChildren];
        } else if(item == [itemController importItem]) {
            count = [(MBItem *)item numberOfChildren];        
        } else {
            // check for reference
            if([(MBItem *)item identifier] == ItemRefID) {
                item = [(MBRefItem *)item target];
            }
            
            // nil references it not allowed
            if(item != nil) {
                count = [(MBItem *)item numberOfChildren];
            }            
        }
	}
	
	return count;
}

/**
\brief give back item that has been asked for
 */
- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item {
	id ret = nil;
	
	// is item is nil, we check root level
	if(item == nil) {
        if(index == 0) {
            ret = [itemController rootItem];
        } else if(index == 1) {
            ret = [itemController templateItem];
        } else if(index == 2) {
            ret = [itemController importItem];
        }
	} else {
        // check for reference
        if([(MBItem *)item identifier] == ItemRefID) {
            item = [(MBRefItem *)item target];
        }
        
        if(item != nil) {
            ret = [[(MBItem *)item children] objectAtIndex:index];
        }
	}	
	
	return ret;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item  {
	BOOL ret = NO;
	
	if(item != nil) {
        // check for reference
        if([(MBItem *)item identifier] == ItemRefID) {
            item = [(MBRefItem *)item target];
        }
        
        if(item != nil) {
            if([(MBItem *)item numberOfChildren] > 0) {
                ret = YES;
            }
        }            
	}
	
	return ret;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldExpandItem:(id)item {
	return YES;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
	id retVal = nil;
	
	if(item != nil) {
        if([(MBItem *)item identifier] == RootItemID) {
            retVal = MBLocaleStr(@"DATASTORE");
        } else if([(MBItem *)item identifier] == RootTemplateItemID) {
            retVal = MBLocaleStr(@"TEMPLATES");
        } else if([(MBItem *)item identifier] == ImportItemID) {
            retVal = MBLocaleStr(@"IMPORTS");
        } else {
            // check for reference
            if(([(MBItem *)item identifier] == ItemRefID) &&
               ([(MBRefItem *)item target] != nil)) {
                item = [(MBRefItem *)item target];
            }
            retVal = [(MBItem *)item name];            
        }
	}
	
	return retVal;
}

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
	if(object != nil) {
		if(item != nil) {
			// check for reference
			if([(MBItem *)item identifier] == ItemRefID) {
				item = [(MBRefItem *)item target];
			}
			
			if(item != nil) {
                // TODO: what is this?
				[item setValue:object forKey:[tableColumn identifier]];
			}
		}	
	}
}

- (void)outlineView:(NSOutlineView *)aOutlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	// display call with std font
	NSFont *font = MBStdTableViewFont;
	[cell setFont:font];
	//float pointSize = [font pointSize];
	//[aOutlineView setRowHeight:pointSize+7];
    
    // defaults
    [(ThreeCellsCell *)cell setImage:nil];
    [(ThreeCellsCell *)cell setTextColor:[NSColor blackColor]];
    [(ThreeCellsCell *)cell setRightCounter:0];
    [(ThreeCellsCell *)cell setLeftCounter:0];
    
    MBItem *buf = item;
    ThreeCellsCell *imageCell = cell;
    //[imageCell setLeftCounter:[buf numberOfChildren]];
    //[imageCell setRightCounter:[buf numberOfValues]];

    // check for reference
    if(([(MBItem *)item identifier] == ItemRefID) &&
       ([(MBRefItem *)item target] != nil)) {
        item = [(MBRefItem *)item target];
        [imageCell setImage:itemRefImage];            
    }
    
    if([buf identifier] == StdItemID || [buf identifier] == TableItemID) {
        [imageCell setImage:stdItemImage];
    } else if([buf identifier] == RootContactItemID) {
        [imageCell setImage:stdItemImage];
    } else if([buf identifier] == RootItemID || [buf identifier] == RootTemplateItemID || [buf identifier] == ImportItemID) {
        [cell setFont:MBStdBoldTableViewFont];
        [cell setTextColor:[NSColor grayColor]];
    } else if([buf identifier] == TrashcanItemID) {
        // display empty trash if no item or itemValue is in it
        if(([buf numberOfChildren] == 0) && ([buf numberOfValues] == 0)) {
            [imageCell setImage:trashcanEmptyItemImage];
        } else {
            [imageCell setImage:trashcanFullItemImage];
        }
    } else {
        [imageCell setImage:stdItemImage];
    }    
}

/**
 Should this outlineview item be selected?
 */
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
	BOOL ret = YES;
    
	return ret;
}

/**
 Should this outlineview item be editable?
 */
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    
	// check for reference
	if(([(MBItem *)item identifier] == ItemRefID) &&
	   ([(MBRefItem *)item target] != nil)) {
		item = [(MBRefItem *)item target];
	}
	// changing name of system item  not allowed
	if(NSLocationInRange([(MBCommonItem *)item identifier], SYSTEMITEM_ID_RANGE) || [(MBCommonItem *)item identifier] == RootItemID) {
		return NO;
	}
	
	return YES;
}

/**
 May outlineview change to another item?
 */
- (BOOL)selectionShouldChangeInOutlineView:(NSOutlineView *)outlineView {
	return YES;
}

#pragma mark - NSOutlineView drag&drop

/**
 Method for lazy copy drag & drop types.
 types are:
 IKAM_PB_TYPE_NAME,		PList as string
 NSFilesPromisePboardType
 */
- (void)pasteboard:(NSPasteboard *)pboard provideDataForType:(NSString *)type {
	// do this only if the app is not terminating
	if(!appTerminating) {
		NSArray *draggedItems = [uiController draggingItems];
		NSEnumerator *iter = [draggedItems objectEnumerator];
		MBCommonItem *item = nil;
		while((item = [iter nextObject])) {
			// use special ARP here
			NSAutoreleasePool *myArp = [[NSAutoreleasePool alloc] init];

			// these are our lazy copy pasteboard types
			if([type isEqualToString:IKAM_PB_TYPE_NAME]) {
				CocoLog(LEVEL_DEBUG,@"[MBItemOutlineViewController -pasteboard:provideDataForType:] IKAM");
				
				// copy real data to pb
				MBExporter *exporter = [MBExporter defaultExporter];
				NSData *exportData = [NSData data];
				if(([exporter exportAsIkam:item toFile:nil exportedFile:nil exportedData:&exportData] == YES) && (exportData != nil)) {
					[pboard setData:exportData forType:type];
				}
			}
			
			// release pool
			[myArp release];
		}
	}
}

/**
\brief this method is invoked if we call -dragdragPromisedFilesOfTypes:fromRect:source:slideBack:event:
 in outlineView:writeItems:toPasteboard:
 But if using this method, no internal drag and drop is possible
*/
/*
- (NSArray *)namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropDestination
{
	CocoLog(LEVEL_DEBUG,@"namesOfPromisedFilesDroppedAtDestination...!");
	CocoLog(LEVEL_DEBUG,@"dropDestination: %@",[dropDestination absoluteString]);
	
	NSMutableArray *promisedNames = [NSMutableArray array];
	
	// with drag and promising filenames we try to export native types
	MBExporter *exporter = [MBExporter defaultExporter];
	
	// there must be items in draggingList
	NSArray *valList = [itemController draggingItems];
	NSEnumerator *iter = [valList objectEnumerator];
	MBItemValue *itemval = nil;
	while((itemval = [iter nextObject]))
	{
		// guess filename
		NSString *name = [exporter guessFilenameFor:itemval];
		CocoLog(LEVEL_DEBUG,@"name: %@",name);
		NSString *extension = [exporter guessFileExtensionFor:itemval];
		CocoLog(LEVEL_DEBUG,@"extension: %@",extension);
		NSString *filename = [exporter generateFilenameWithExtension:extension 
														fromFilename:name];
		
		// add filename to array
		[promisedNames addObject:filename];
		
		// get URL, extract relativePath component and add filename, then export
		NSString *exportName = [[dropDestination relativePath] stringByAppendingPathComponent:filename];
		NSURL *url = [NSURL fileURLWithPath:exportName];
		CocoLog(LEVEL_DEBUG,[url absoluteString]);
		CocoLog(LEVEL_DEBUG,@"exporting to %@",exportName);
		[exporter exportAsNative:itemval toFile:exportName];
	}
	
	return promisedNames;
}
*/

/**
 \brief these items are selected and are dragged
 check, if there are items that may not be dragged, e.g. SystemItems
*/
- (BOOL)outlineView:(NSOutlineView *)oView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pboard {
	// we make a lazy copy here
	// copy items
	[uiController setDraggingItems:items];	// lazy copy
	[pboard declareTypes:[NSArray arrayWithObjects:COMMON_ITEM_PB_TYPE_NAME, NSFilesPromisePboardType, nil] owner:self];

	// type ITEM
	[pboard setData:[NSData data] forType:COMMON_ITEM_PB_TYPE_NAME];

	// IKAM archive
	//[pboard setData:[NSData data] forType:IKAM_PB_TYPE_NAME];
	
	// promised file for external drops
	[pboard setPropertyList:[NSArray arrayWithObjects:EXPORT_IKAMARCHIVE_TYPESTRING, nil] forType:NSFilesPromisePboardType];

	/*
	int rowIndex = [oView rowForItem:[items objectAtIndex:0]];
	// get current row rect
	NSRect rowRect = [oView rectOfRow:rowIndex];	
	[oView dragPromisedFilesOfTypes:[NSArray arrayWithObject:EXPORT_IKAMARCHIVE_TYPESTRING] 
										fromRect:rowRect
										  source:self 
									   slideBack:YES 
										   event:mouseDownEvent];
	 */
	
	return YES;
}

/**
 \brief this method is called to validate the target of the drag operation
*/
- (NSDragOperation)outlineView:(NSOutlineView *)oView 
				  validateDrop:(id<NSDraggingInfo>)info 
				  proposedItem:(id)item 
			proposedChildIndex:(int)index {
	NSPasteboard *pb = [info draggingPasteboard];

	// set std operation
	int stdOp = NSDragOperationNone;
	if([info draggingSourceOperationMask] == NSDragOperationCopy) {
		stdOp = NSDragOperationCopy;
	} else if(([info draggingSourceOperationMask] & NSDragOperationMove) == NSDragOperationMove) {
		stdOp = NSDragOperationMove;
	}
	
    // dropping to root is not allowed
    if(item == nil) {
        return NSDragOperationNone;
    }
    // we don't drop to imports
    if(item == [itemController importItem]) {
        return NSDragOperationNone;
    }
    
	// check for reference
	if([(MBItem *)item identifier] == ItemRefID) {
		item = [(MBRefItem *)item target];
		// dragging to a ref value is not allowed if the target is nil
		if(item == nil) {
			return NSDragOperationNone;
		}
	}
		
	// check for type
	NSString *type = [pb availableTypeFromArray:[self validDragAndDropPbTypes]];
	if(type == nil) {
		// seems we do not support this type, nil is no good type
		return NSDragOperationNone;		
	} else {
		// we have a type
		if([type isEqualToString:COMMON_ITEM_PB_TYPE_NAME] == YES) {
			// has values?
			BOOL hasValues = NO;
			// check for SystemItems and sources in all dragged items
			NSEnumerator *iter = [[uiController draggingItems] objectEnumerator];
			MBItem *mbItem = nil;
			while((mbItem = [iter nextObject])) {
				// dragging System Items is not allowed
				if(NSLocationInRange([mbItem identifier], SYSTEMITEM_ID_RANGE) || [mbItem identifier] == RootItemID) {
					return NSDragOperationNone;
				} else if(NSLocationInRange([mbItem identifier], ITEMVALUE_ID_RANGE)) {
					// this is a normal item and has values
					hasValues = YES;
				} else if([mbItem identifier] == TemplateItemID) {
					// we make a copy operation here, if we drag a template item
					return NSDragOperationCopy;
				} else {
                    // for all others, we need to process further
                }
			}		

			// if we have values, we may not drop to root
			// check destination items
			if(item == [itemController trashcanItem]) {
				// to trashcan, we move
				return NSDragOperationMove;
			} else if(item == [itemController templateItem]) {
				// to templates itemvalues cannot be dropped
				// items are copied except they are values
				if(hasValues) {
					return NSDragOperationNone;
				}
				return NSDragOperationCopy;
			}
		} else {
            if((item == [itemController templateItem]) ||
               (item == [itemController trashcanItem])) {
                return NSDragOperationNone;
            }
		}
	}

	return stdOp;
}

/**
 This method is called if the mouse button has been released and data is dropped at a target
*/
-(BOOL)outlineView:(NSOutlineView *)oView acceptDrop:(id <NSDraggingInfo>)info item:(id)item childIndex:(int)index {
    
    if([(MBItem *)item identifier] == ItemRefID) {
		item = [(MBRefItem *)item target];
    }
    
	// init importer
	MBImporter *importer = [MBImporter defaultImporter];
	
	NSPasteboard *pb = [info draggingPasteboard];
	// get pb type
	NSString *type = [pb availableTypeFromArray:[self validDragAndDropPbTypes]];
	if(type != nil) {
		unsigned int sourceMask = [info draggingSourceOperationMask];
		// identify drag operation
		int operation = MoveOperation;
		if(sourceMask == NSDragOperationCopy) {
			operation = CopyOperation;
		} else if((sourceMask & NSDragOperationCopy) > 0) {
            // copy has priority
			operation = CopyOperation;
		} else {
			operation = MoveOperation;
		}
		
		if([type isEqualToString:COMMON_ITEM_PB_TYPE_NAME]) {
            // internal

			// draggedItems has the dragged data, now move it
			// item is the target
			[itemController addObjects:[uiController draggingItems] 
								toItem:item 
							 withIndex:index 
				 withConnectingObjects:YES
							 operation:operation];
			
			// update views
			MBSendNotifyItemTreeChanged(nil);
			MBSendNotifyItemValueListChanged(nil);
		} else if([type isEqualToString:NSFilenamesPboardType]) {
            // external
            
			// get array of Filenames
			NSArray *filenames = [pb propertyListForType:type];
			// import
			[importer fileValueImport:filenames toItem:item];
		} else if([type isEqualToString:NSFilesPromisePboardType]) {
			NSString *tmpFolder = TMPFOLDER;
			
			NSArray *files = [info namesOfPromisedFilesDroppedAtDestination:[NSURL fileURLWithPath:tmpFolder]];
			// build filenames
			NSMutableArray *filenames = [NSMutableArray arrayWithCapacity:[files count]];
			NSEnumerator *iter = [files objectEnumerator];
			NSString *filename = nil;
			while((filename = [iter nextObject])) {
				// build complete filename
				NSString *absolute = [NSString pathWithComponents:[NSArray arrayWithObjects:tmpFolder, filename, nil]];
				// add to new array
				[filenames addObject:absolute];
			}
			// import
			[importer fileValueImport:filenames toItem:item];
		} else if([type isEqualToString:NSURLPboardType]) {
			NSArray *urlList = [pb propertyListForType:type];
			NSURL *url = [NSURL URLWithString:[urlList objectAtIndex:0]];
			[importer urlValueImport:url toItem:item asTransaction:YES];
		} else if([type isEqualToString:NSStringPboardType]) {
			NSString *text = [pb stringForType:type];
			[importer eTextValueImport:[text dataUsingEncoding:NSUTF8StringEncoding] toItem:item forType:TextTypeTXT asTransaction:YES];
		} else if([type isEqualToString:NSRTFPboardType]) {
			NSData *textData = [pb dataForType:type];
			[importer eTextValueImport:textData toItem:item forType:TextTypeRTF asTransaction:YES];			
		} else if([type isEqualToString:NSRTFDPboardType]) {
			NSData *textData = [pb dataForType:type];
			[importer eTextValueImport:textData toItem:item forType:TextTypeRTFD asTransaction:YES];
        } else if([type isEqualToString:NSPDFPboardType]) {
            NSData *pdfData = [pb dataForType:type];
            [importer pdfValueImport:pdfData toItem:item asTransaction:YES];			
        }
    } else {
		return NO;
	}
	
	return YES;
}

/**
 Delegate method for promised files
 This method if only available on Tiger and above systems
 \todo --- use threaded progressindicator sheet for this action
*/
- (NSArray *)outlineView:(NSOutlineView *)outlineView namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropDestination 
		 forDraggedItems:(NSArray *)items {	
	NSMutableArray *promisedNames = [NSMutableArray array];
	
	// start global progress indicator
	MBSendNotifyProgressIndicationActionStarted(nil);
	
	// with drag and promising filenames we try to export native types
	MBExporter *exporter = [MBExporter defaultExporter];
	
	// there must be items in draggingList
	//NSArray *valList = [itemController draggingItems];
	//NSEnumerator *iter = [valList objectEnumerator];
	NSEnumerator *iter = [items objectEnumerator];
	MBItem *item = nil;
	while((item = [iter nextObject])) {
		// guess filename
		NSString *name = [exporter guessFilenameFor:item];
		NSString *extension = [exporter guessFileExtensionFor:item];
		NSString *filename = [exporter generateFilenameWithExtension:extension 
														fromFilename:name];

		// get URL, extract relativePath component and add filename, then export
		NSString *exportName = [[dropDestination relativePath] stringByAppendingPathComponent:filename];
		NSString *exportedFilename = @"";
		[exporter exportAsNative:item toFile:exportName exportedFile:&exportedFilename exportedData:nil];
		
		// add filename to array
		[promisedNames addObject:exportedFilename];
	}

	// start global progress indicator
	MBSendNotifyProgressIndicationActionStopped(nil);
	
	return promisedNames;	
}

/**
 Notification is called when the selection has changed
 After determining the item which has been selected it is set in ItemBaseController.
 ItemBasEcontroller is responsible for sending Notifications to all Views that should update their views.
 */
- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
	MBItemBaseController *ibc = itemController;
	
	if(notification != nil) {
		NSOutlineView *oview = [notification object];
		if(oview != nil) {
			// set CurrentSelItem in ItemBaseController
			NSIndexSet *selectedRows = [oview selectedRowIndexes];
			MBItem *item = nil;
			int len = [selectedRows count];
			NSMutableArray *selection = [NSMutableArray arrayWithCapacity:len];
			if(len > 0) {
				unsigned long indexes[len];
				[selectedRows getIndexes:indexes maxCount:len inIndexRange:nil];
				
				for(int i = 0;i < len;i++) {
					item = [oview itemAtRow:indexes[i]];
                    if([item identifier] != RootItemID) {
                        [selection addObject:item];
                    }
				}
				
				// check selection for changing the outlineView menu
				if(len == 1) {
					// check for reference
					if(([(MBItem *)item identifier] == ItemRefID) &&
					   ([(MBRefItem *)item target] != nil)) {
						item = (MBItem *)[(MBRefItem *)item target];
					}
					
					if([item identifier] == TrashcanItemID) {
						// set trashcan menu
						[outlineView setMenu:trashcanItemMenu];
					} else if([item identifier] == RootTemplateItemID) {
						// set template menu
						[outlineView setMenu:templateItemMenu];
					} else if([item identifier] == ImportItemID) {
						// set import menu
						[outlineView setMenu:importItemMenu];
					} else {
						// set normal menu
						[outlineView setMenu:normalItemMenu];
					}
				} else {	// len > 1 {
					// set normal menu
					[outlineView setMenu:normalItemMenu];
				}
			} else {	// len <= 0 {
				// set normal menu
				[outlineView setMenu:normalItemMenu];
			}
			
			// set selection
			[self setCurrentSelection:selection];
			// set the selection in itemController
			[ibc setCurrentItemSelection:selection];
		} else {
			CocoLog(LEVEL_WARN,@"have a nil notification object!");
		}
	} else {
		CocoLog(LEVEL_WARN,@"have a nil notification!");
	}
}

/**
\brief user clicked in tablecolumn
 if this happens, we sort the data using sortorder.
 */
- (void)outlineView:(NSOutlineView *)aOutlineView didClickTableColumn:(NSTableColumn *)tableColumn {
	//if([[tableColumn identifier] isEqualToString:COL_IDENTIFIER_ITEM_NAME] == YES)
	//{
		//MBItemBaseController *ibc = [MBItemBaseController standardController];
		//[ibc sortItemData];
		
		//[outlineView reloadData];
		
		// tell item browser to reload data due to sorting the list
		//MBSendNotifyItemListHasBeenSorted(nil);
	//}
}

#pragma mark - Menu stuff

- (void)createNormalItemMenu {
	// build context menu
	normalItemMenu = [[NSMenu alloc] init];
	[normalItemMenu setDelegate:self];
	// set menu items
	// new item
	NSMenuItem *mItem = [[newItemMenuItem copy] autorelease];
	[normalItemMenu addItem:mItem];
	// new itemvalue
	[normalItemMenu addItem:[[newItemValueMenuItem copy] autorelease]];
	// separater
	[normalItemMenu addItem:(NSMenuItem *)[NSMenuItem separatorItem]];
	// cut
	[normalItemMenu addItem:[[cutMenuItem copy] autorelease]];
	// copy
	[normalItemMenu addItem:[[copyMenuItem copy] autorelease]];
	// paste
	[normalItemMenu addItem:[[pasteMenuItem copy] autorelease]];
	// delete
	[normalItemMenu addItem:[[deleteMenuItem copy] autorelease]];
	// separater
	[normalItemMenu addItem:(NSMenuItem *)[NSMenuItem separatorItem]];
	// define as template
	[normalItemMenu addItem:[[defineAsTemplateMenuItem copy] autorelease]];
	// create ref
	[normalItemMenu addItem:[[createRefMenuItem copy] autorelease]];
	// separater
	[normalItemMenu addItem:(NSMenuItem *)[NSMenuItem separatorItem]];
	// import
	[normalItemMenu addItem:[[importMenuItem copy] autorelease]];
	// export
	[normalItemMenu addItem:[[exportMenuItem copy] autorelease]];	
}

- (void)createTrashcanItemMenu {
	// build context menu
	trashcanItemMenu = [[NSMenu alloc] init];
	[trashcanItemMenu setDelegate:self];
	// emptytrash
	[trashcanItemMenu addItem:[[emptyTrashMenuItem copy] autorelease]];
}

- (void)createTemplateItemMenu {
	// build context menu
	templateItemMenu = [[NSMenu alloc] init];
	[templateItemMenu setDelegate:self];
	// new item
	NSMenuItem *mItem = [[newItemMenuItem copy] autorelease];
	[templateItemMenu addItem:mItem];
	// separater
	[templateItemMenu addItem:(NSMenuItem *)[NSMenuItem separatorItem]];
	// import
	[templateItemMenu addItem:[[importMenuItem copy] autorelease]];
	// export
	[templateItemMenu addItem:[[exportMenuItem copy] autorelease]];
}

- (void)createImportItemMenu {
	// build context menu
	importItemMenu = [[NSMenu alloc] init];
	[importItemMenu setDelegate:self];
	// emptytrash
	//[templateItemMenu addItem:[[emptyTrashMenuItem copy] autorelease]];
	// separater
	//[normalItemMenu addItem:(NSMenuItem *)[NSMenuItem separatorItem]];
	// import
	//[templateItemMenu addItem:[[importMenuItem copy] autorelease]];
	// export
	//[templateItemMenu addItem:[[exportMenuItem copy] autorelease]];
}

#pragma mark - Notifications

- (void)appWillTerminate:(NSNotification *)aNotification {
	CocoLog(LEVEL_DEBUG,@"[MBItemOutlineViewController appWillTerminate:]!");
	
	appTerminating = YES;
}

/** 
 Notification that the application has finished with initialization.
 Now the item outlineview can be reread.
*/
- (void)appInitialized:(NSNotification *)aNotification {
	if(aNotification != nil) {
		// reload outline view
		[outlineView reloadData];

        // expand root item
        [outlineView expandItem:[itemController rootItem]];
	}
}

/**
 After adding a new created Item to another item this Notification is send
 */
- (void)itemAdded:(NSNotification *)aNotification {
	// get notification object
	MBItem *addedItem = [aNotification object];
	
	if(addedItem != nil) {
		// get parent Item
		MBItem *parent = [addedItem parentItem];
		
		// expand Parent it isn't
		if([outlineView isItemExpanded:parent] == NO) {
			// expand it and select the currently added
			[outlineView expandItem:parent];
			// get row of item
			int rowNumber = [outlineView rowForItem:addedItem];
			// select item
			[outlineView selectRow:rowNumber byExtendingSelection:NO];
		}
	} else {
		CocoLog(LEVEL_WARN,@"[MBItemOutlineViewController -itemAdded:] added Item is nil!");
	}
}

/**
 The menu has been changed reparse templates
 */
- (void)menuChanged:(NSNotification *)aNotification {
	// create template menu new
	[self createNormalItemMenu];
}

- (void)itemAttribsChanged:(NSNotification *) aNotification {
	if(aNotification != nil) {
		MBItem *item = [aNotification object];
		
		if(item == nil) {
			// reload complete outline view
			[outlineView reloadData];
		} else {
			// update the changed item only
			[outlineView reloadItem:item];
		}
	}
}

- (void)itemTreeChanged:(NSNotification *) aNotification {
	if(aNotification != nil) {
		MBItem *item = [aNotification object];
		if(item == nil) {
			// reload complete outline view
			[outlineView reloadData];
		} else {
			// update the changed item only
			[outlineView reloadItem:item reloadChildren:YES];
		}		
	}
}

/**
 This notification is received if this outlineview should select another item
 */
- (void)itemSelectionShouldChange:(NSNotification *)aNotification {
	if(aNotification != nil) {
		NSArray *itemSelection = [aNotification object];
		if(itemSelection == nil) {
			CocoLog(LEVEL_WARN,@"[MBItemOutlineViewController -itemSelectionShouldChange:]: notification object is nil!");
		} else {
			if([itemSelection count] > 0) {
				MBItemBaseController *ibc = itemController;
				
				// collapse all before finding the item
                [outlineView collapseItem:[ibc rootItem] collapseChildren:YES];
				
				// go through all selected items, must be in one subtree
				NSEnumerator *iter = [itemSelection objectEnumerator];
                MBItem *item = nil;
				while((item = [iter nextObject])) {
					// we first have to go up in the tree and memorize all items that lie on the way
					NSMutableArray *way = [NSMutableArray array];
					do {
						// add the first one
						[way addObject:item];
						
						// we have another item
						item = [item parentItem];
					}
					while(item != nil);
					
					int row = -1;
					// now go from root item to the selected and find out the row to be selected
					// on any knots, that are not expanded, expand them
					for(int i = [way count]-1;i >= 0;i--) {
						MBItem *buf = [way objectAtIndex:i];
						
						// check, this item is expandable, if yes, expand it
						if([outlineView isExpandable:buf]) {
							[outlineView expandItem:buf];
						}
						
						// check for the row to be selected
                        if(buf == [ibc rootItem]) {
                            row = 0;
                        } else if([buf parentItem] != nil) {
                            row = row + [[[buf parentItem] children] indexOfObject:buf] + 1;
                        } else {
                            CocoLog(LEVEL_WARN,@"[MBItemOutlineViewController -itemSelectionShouldChange:]: buf has no parent, cannot get row!");						
                        }
					}
					
					// select the row we want
					if(row > -1) {
						// select the item in outlineview
						[outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
					} else {
						CocoLog(LEVEL_WARN,@"[MBItemOutlineViewController -itemSelectionShouldChange:]: could not get row. row = -1!");
					}
				}
			}
		}
	}
}

#pragma mark - Actions

- (IBAction)menuExport:(id)sender {
	CocoLog(LEVEL_DEBUG,@"[MBItemOutlineViewController -menuExport:]");
	
	NSMutableArray *copySelection = [NSMutableArray arrayWithArray:[self currentSelection]];
	
	if([copySelection count] > 0) {
		// sort out any system items, they cannot be copied, cut or paste
		NSEnumerator *iter = [copySelection objectEnumerator];
		MBCommonItem *item = nil;
		while((item = [iter nextObject])) {
			if(NSLocationInRange([item identifier],SYSTEMITEM_ID_RANGE) == YES) {
				[copySelection removeObject:item];
			}
		}
		
		MBExporter *exporter = [MBExporter defaultExporter];
		[exporter export:copySelection exportFolder:nil exportType:-1];
	}
}

@end
