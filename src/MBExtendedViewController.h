/* MBExtendedViewController */

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>
#import "MBItemType.h"

@class PDFViewer;
@class MBCommonItem;

@interface MBExtendedViewController : NSObject {
	// main view boxes
	IBOutlet NSView *encryptedDataView;
	IBOutlet NSView *noInfoView;

    PDFViewer *pdfViewer;
    
	IBOutlet id delegate;	// is MainViewController
}

// the contentView
- (NSView *)contentViewForItem:(MBCommonItem *)aItem;

- (float)collapseHeightForValueType:(MBItemValueTypes)type;

- (void)setDelegate:(id)aClass;
- (id)delegate;

@end
