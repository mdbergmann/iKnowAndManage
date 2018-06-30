//
//  MBItemValueListTableView.h
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 20.09.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>
#import "AMToolTipTableView.h"

@interface MBItemValueListTableView : AMToolTipTableView
{
	// delegate responds to mousedown
	BOOL delegateRespondsToMouseDown;
}

// actions from first responder
- (IBAction)menuExport:(id)sender;

@end
