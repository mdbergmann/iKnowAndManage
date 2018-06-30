//
//  MBFileValueDetailViewController.h
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 08.07.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>
#import "MBFileBaseDetailViewController.h"

@interface MBFileValueDetailViewController : MBFileBaseDetailViewController {
	IBOutlet NSImageView *fileIconImageView;
	IBOutlet NSTextField *filetypeLabel;
	IBOutlet NSTextField *fileSizeLabel;
	IBOutlet NSTextField *fileCreationDateLabel;
	IBOutlet NSTextField *fileModificationDateLabel;
	IBOutlet NSTextField *fileOwnerNameLabel;
	IBOutlet NSTextField *filePosixPermissionsLabel;
}

@end
