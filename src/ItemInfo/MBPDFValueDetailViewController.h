//
//  MBPDFValueDetailViewController.h
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 08.07.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author: mbergmann $
// $HeadURL: file:///REPOSITORY/private/cocoa/iKnowAndManage/trunk/src/ItemInfo/MBFileValueDetailViewController.h $
// $LastChangedBy: mbergmann $
// $LastChangedDate: 2009-08-12 16:48:03 +0100 (Wed, 12 Aug 2009) $
// $Rev: 646 $

#import <Cocoa/Cocoa.h>
#import "MBFileBaseDetailViewController.h"

@interface MBPDFValueDetailViewController : MBFileBaseDetailViewController {
	IBOutlet NSTextField *fileSizeLabel;
}

@end
