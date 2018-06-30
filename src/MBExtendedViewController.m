// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <CocoLogger/CocoLogger.h>
#import "MBExtendedViewController.h"
#import "PDFViewer.h"
#import "MBTextEditorViewController.h"
#import "MBExtendedImageViewController.h"
#import "globals.h"
#import "MBItemType.h"
#import "MBItemValue.h"
#import "MBFileItemValue.h"
#import "MBPDFItemValue.h"

@implementation MBExtendedViewController

- (id)init {
	CocoLog(LEVEL_DEBUG,@"init of MBExtendedViewController");
	
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"cannot alloc MBExtendedViewController!");
	} else {
        // init PDFViewer
        pdfViewer = [[PDFViewer alloc] initWithDelegate:self];
	}
	
	return self;
}

/**
\brief dealloc of this class is called on closing this document
 */
- (void)dealloc {
	CocoLog(LEVEL_DEBUG,@"dealloc of MBExtendedViewController");
	
    [pdfViewer release];
    
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
	CocoLog(LEVEL_DEBUG,@"awakeFromNib of MBExtendedViewController");
	
	if(self != nil) {
		// init text editor view
		[MBTextEditorViewController standardTextEditorController];
		
		// init ExtendedImageView
		[MBExtendedImageViewController standardImageViewController];
				
		// register notification 
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(appInitialized:)
													 name:MBAppInitializedNotification object:nil];
	}	
}

/**
 \brief return the collapse height for the type of value
*/
- (float)collapseHeightForValueType:(MBItemValueTypes)type {
	float height = 1.0;
	
	switch((int)type) {
		case ExtendedTextItemValueType:
			height = [[MBTextEditorViewController standardTextEditorController] collapseHeight];
			break;
		case ImageItemValueType:
			height = [[MBExtendedImageViewController standardImageViewController] collapseHeight];
			break;
	}
	
	return height;
}

/**
 \brief for a nil item rturn the noInfoView and not nil
 because setting a nil view into the splitview is not a good idea
*/
- (NSView *)contentViewForItem:(MBCommonItem *)aItem {
	NSView *contentView = noInfoView;
	
	if(aItem != nil) {
		if(NSLocationInRange([aItem identifier], ITEMVALUE_ID_RANGE)) {
			MBItemValue *itemval = (MBItemValue *)aItem;
			// check for value type
			switch([itemval valuetype]) {
				case SimpleTextItemValueType:
				case NumberItemValueType:
				case CurrencyItemValueType:
				case BoolItemValueType:
				case DateItemValueType:
				case URLItemValueType:
				case FileItemValueType:
					// create empty view
					//contentView = [[[NSView alloc] init] autorelease];
					break;
				case ExtendedTextItemValueType:
					// exchange view
					if([itemval encryptionState] == EncryptedState) {
						contentView = encryptedDataView;
					} else {
						contentView = [[MBTextEditorViewController standardTextEditorController] textEditorView];
					}
					break;
				case ImageItemValueType:
					// exchange view
					if([itemval encryptionState] == EncryptedState) {
						contentView = encryptedDataView;
					} else {
						contentView = [[MBExtendedImageViewController standardImageViewController] extendedImageView];
					}
					break;
				case PDFItemValueType:
					// exchange view
					if([itemval encryptionState] == EncryptedState) {
						contentView = encryptedDataView;
					} else {
                        if(([(MBFileItemValue *)aItem isLink] && [(MBFileItemValue *)aItem autoHandleLoadSave]) || ![(MBFileItemValue *)aItem isLink]) {
                            [pdfViewer setDocument:[(MBPDFItemValue *)itemval pdfDocument]];
                        }
						contentView = [pdfViewer view];
					}
					break;
				default:
					break;
			}
			
			// set contentview
			//CocoLog(LEVEL_DEBUG,@"[MBExtendedViewController -setCurrentItem:] exchanging view!");
			//[extendedViewBox setContentView:contentView];
		} else if(NSLocationInRange([aItem identifier],ITEM_ID_RANGE)) {
			contentView = noInfoView;
		}
	}				

	return contentView;
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
	}
}

@end