// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <CocoLogger/CocoLogger.h>
#import "MBMainViewController.h"
#import "globals.h"
#import "MBItemType.h"
#import "MBItemValue.h"
#import "MBExtendedViewController.h"
#import "MBItemValueListViewController.h"

enum MBViewPosition {
	UpperViewCollapsed = 0,
	MiddleViewPosition,
	BelowViewCollapsed,
	UnchangedPosition
};

@interface MBMainViewController (privateAPI)

- (void)setViewState:(int)aState;
- (int)viewState;
- (void)changeViewPositionTo:(int)aPosition;

@end

@implementation MBMainViewController (privateAPI)

- (void)setViewState:(int)aState {
	viewState = aState;
}

- (int)viewState {
	return viewState;
}

- (void)changeViewPositionTo:(int)aPosition {
	// on unchanged position we do nothing
	if(aPosition != UnchangedPosition && !viewInWindow) {
        double midHeight = [theView frame].size.height / 2;

		if(([self viewState] == UpperViewCollapsed) && (aPosition == UpperViewCollapsed)) {
			// nothing to be done here
		} else if(([self viewState] == BelowViewCollapsed) && (aPosition == BelowViewCollapsed)) {
			// here too nothing to be done
		} else if(([self viewState] == MiddleViewPosition) && (aPosition == MiddleViewPosition)) {
			// here too nothing to be done
		} else if(([self viewState] == UpperViewCollapsed) && (aPosition == MiddleViewPosition)) {
            // make upper view size to middle
            /*
            if(![[splitView subviews] containsObject:aboveViewBox]) {
                [splitView addSubview:aboveViewBox positioned:NSWindowAbove relativeTo:extendedViewBox];
            }
             */
            NSView *v = aboveViewBox;
            NSSize size = [v frame].size;
            size.height = midHeight;
            [v setFrameSize:size];
			// set view position state
			[self setViewState:aPosition];
        } else if(([self viewState] == BelowViewCollapsed) && (aPosition == MiddleViewPosition)) {
            // make upper view size to middle
            /*
            if(![[splitView subviews] containsObject:extendedViewBox]) {
                [splitView addSubview:extendedViewBox positioned:NSWindowAbove relativeTo:aboveViewBox];
            }
             */
            NSView *v = extendedViewBox;
            NSSize size = [v frame].size;
            size.height = midHeight;
            [v setFrameSize:size];
			// set view position state
			[self setViewState:aPosition];
		} else if(([self viewState] == MiddleViewPosition) && (aPosition == UpperViewCollapsed)) {
            // make upper view size 0
            /*
            if([[splitView subviews] containsObject:aboveViewBox]) {
                [aboveViewBox removeFromSuperview];
            }
             */
            NSView *v = aboveViewBox;
            NSSize size = [v frame].size;
            size.height = 0;
            [v setFrameSize:size];			
			// set view position state
			[self setViewState:aPosition];
		} else if(([self viewState] == MiddleViewPosition) && (aPosition == BelowViewCollapsed)) {
            // make upper view size 0
            /*
            if([[splitView subviews] containsObject:extendedViewBox]) {
                [extendedViewBox removeFromSuperview];
            }
             */
            NSView *v = extendedViewBox;
            NSSize size = [v frame].size;
            size.height = 0;
            [v setFrameSize:size];            
			// set view position state
			[self setViewState:aPosition];
		}
		
		// refresh splitview
		[splitView adjustSubviews];
		[splitView setNeedsDisplay:YES];
	}
}

@end

@implementation MBMainViewController

- (id)init {
	CocoLog(LEVEL_DEBUG,@"init of MBMainViewController");
	
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"cannot alloc MBMainViewController!");
	} else {
		// set upperViewHeight to initial value
		upperViewHeight = -1;
        viewInWindow = NO;
		[self setViewState:MiddleViewPosition];
	}
	
	return self;
}

- (void)dealloc {
	// dealloc object
	[super dealloc];
}

//--------------------------------------------------------------------
//----------- get and set delegate of this class ---------------------
//--------------------------------------------------------------------
- (void)setDelegate:(id)aClass {
	delegate = aClass;
}

- (id)delegate {
	return delegate;
}

//--------------------------------------------------------------------
//----------- Bundle delegates ---------------------------------------
//--------------------------------------------------------------------
/**
\brief gets called if the nib file has been loaded. all gfx objects are available now.
 */
- (void)awakeFromNib {
	CocoLog(LEVEL_DEBUG,@"awakeFromNib of MBMainViewController");
	
	if(self != nil) {
		// set itewmValueListView
		[aboveViewBox setContentView:[itemValueListViewController theView]];

        [openInWinBtn setEnabled:NO];
        
		// register notification 
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(appInitialized:)
													 name:MBAppInitializedNotification object:nil];
		// register notification 
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(selectedCommonItemChanged:)
													 name:MBItemSelectionChangedNotification object:nil];				
		// register notification 
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(selectedCommonItemChanged:)
													 name:MBItemValueSelectionChangedNotification object:nil];				
        /*
		// register some NSUserDefaults changes
		[[NSUserDefaults standardUserDefaults] addObserver:self 
												forKeyPath:MBDefaultsMetalDisplayKey
												   options:NSKeyValueObservingOptionNew context:nil];
         */
		
		// change initial position
		// [self changeViewPositionTo:BelowViewCollapsed];
	}	
}

// the view
- (NSView *)theView {
	return theView;
}

// the tableview from itemValueListViewController
- (NSTableView *)itemValueListView {
	return [itemValueListViewController tableView];
}

// view up/down methods
- (void)viewUp {
	if([self viewState] > UpperViewCollapsed) {
		[self changeViewPositionTo:[self viewState]-1];
	}
}

- (void)viewDown {
	if([self viewState] < BelowViewCollapsed) {
		[self changeViewPositionTo:[self viewState]+1];
	}	
}

// searching
- (void)applySearchString:(NSString *)aString {
    [itemValueListViewController applySearchString:aString];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
}

#pragma mark - Actions

- (IBAction)openInWindow:(id)sender {
    // remove box from splitview
    [extendedViewBox removeFromSuperview];
    // put box as contentview into window
    [extendedViewWindow setContentView:extendedViewBox];
    [extendedViewWindow makeKeyAndOrderFront:self];
    viewInWindow = YES;
}



#pragma mark - Notifications

- (void)windowWillClose:(NSNotification *)notification {
    // put box back to splitview
    [splitView addSubview:extendedViewBox];
    viewInWindow = NO;
}

/** 
\brief notification that the application has finished with initialization
Now, the contentview of the detailView can be set and the info drawer can be opened
*/
- (void)appInitialized:(NSNotification *)aNotification {
	if(aNotification != nil) {
		// set itewmValueListView
		[aboveViewBox setContentView:[itemValueListViewController theView]];
		[extendedViewBox setContentView:[extendedViewController contentViewForItem:nil]];
	}
}
 
/** 
 \brief notification if (common) item has changed
 make sure that the texteditor view or the imageviewerview are not resized when in splitview
 replace them befor.
*/
- (void)selectedCommonItemChanged:(NSNotification *)aNotification {
	if(aNotification != nil) {
		NSArray *itemSelection = [aNotification object];
		if(itemSelection != nil) {
			if([itemSelection count] > 0) {
				MBCommonItem *currentItem = [itemSelection objectAtIndex:0];
				if(NSLocationInRange([currentItem identifier], ITEMVALUE_ID_RANGE)) {
					MBItemValue *itemval = (MBItemValue *)currentItem;

                    // disable this button
                    [openInWinBtn setEnabled:NO];					
                    
					// check for value type
					switch([itemval valuetype]) {
						case SimpleTextItemValueType:
						case NumberItemValueType:
						case CurrencyItemValueType:
						case BoolItemValueType:
						case DateItemValueType:
						case URLItemValueType:
                            break;
						case FileItemValueType:
						{
							// set contentview for extended view
							[extendedViewBox setContentView:[extendedViewController contentViewForItem:currentItem]];
							
                            // position of views
                            [self changeViewPositionTo:BelowViewCollapsed];                            
							
							break;
						}
						case ExtendedTextItemValueType:
						{
                            [openInWinBtn setEnabled:YES];
                            // position of views
                            if([self viewState] == BelowViewCollapsed) {
                                [self changeViewPositionTo:MiddleViewPosition];
                            } else {
                                [self changeViewPositionTo:UnchangedPosition];							
                            }
							
							// set contentview for extended view
							[extendedViewBox setContentView:[extendedViewController contentViewForItem:currentItem]];
							break;
						}
						case ImageItemValueType:
						{
                            [openInWinBtn setEnabled:YES];
                            // position of views
                            if([self viewState] == BelowViewCollapsed) {
                                [self changeViewPositionTo:MiddleViewPosition];
                            } else {
                                [self changeViewPositionTo:UnchangedPosition];							
                            }
							
							// set contentview for extended view
							[extendedViewBox setContentView:[extendedViewController contentViewForItem:currentItem]];
							break;
						}
						case PDFItemValueType:
						{
                            [openInWinBtn setEnabled:YES];
							// position of views
							if([self viewState] == BelowViewCollapsed) {
								[self changeViewPositionTo:MiddleViewPosition];
							} else {
								[self changeViewPositionTo:UnchangedPosition];							
							}
							
							// set contentview for extended view
							[extendedViewBox setContentView:[extendedViewController contentViewForItem:currentItem]];
							break;
                        }
						default:
						{
							// set contentview for extended view
							[extendedViewBox setContentView:[extendedViewController contentViewForItem:currentItem]];

							// position of views
							[self changeViewPositionTo:UnchangedPosition];
							
							break;
						}
					}
				} else if((NSLocationInRange([currentItem identifier], ITEM_ID_RANGE)) ||
                          (NSLocationInRange([currentItem identifier], SYSTEMITEM_ID_RANGE))) {
					// set contentview for extended view
					[extendedViewBox setContentView:[extendedViewController contentViewForItem:currentItem]];

					// position of views
					[self changeViewPositionTo:BelowViewCollapsed];
				}
			}
		} else {
			// set contentview for extended view
			[extendedViewBox setContentView:[extendedViewController contentViewForItem:nil]];
			
			// position of views
			[self changeViewPositionTo:BelowViewCollapsed];
		}
	}
}

@end