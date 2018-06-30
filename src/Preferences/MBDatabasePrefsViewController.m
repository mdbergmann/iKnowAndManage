//
//  MBDatabasePrefsViewController.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 15.09.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <CocoLogger/CocoLogger.h>
#import "MBDatabasePrefsViewController.h"
#import "MBItemBaseController.h"
#import "MBDBSqlite.h"

@implementation MBDatabasePrefsViewController

- (id)init {
	CocoLog(LEVEL_DEBUG, @"init of MBDatabasePrefsViewController");
	
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR, @"cannot alloc MBDatabasePrefsViewController!");
	} else {
	}
	
	return self;
}

/**
\brief dealloc of this class is called on closing this document
 */
- (void)dealloc {
	CocoLog(LEVEL_DEBUG, @"dealloc of MBDatabasePrefsViewController");
	
	// dealloc object
	[super dealloc];
}

//--------------------------------------------------------------------
//----------- bundle delegates ---------------------------------------
//--------------------------------------------------------------------
- (void)awakeFromNib {
	CocoLog(LEVEL_DEBUG, @"awakeFromNib of MBDatabasePrefsViewController");
	
    // init the viewRect
    viewFrame = [theView frame];
    
    [progressIndicator setUsesThreadedAnimation:YES];
}

/**
 \brief return the view itself
*/
- (NSView *)theView {
	return theView;
}

- (NSRect)viewFrame {
	return viewFrame;
}

- (NSNumber *)numberOfSimpleTextItemValues {
    return [NSNumber numberWithInt:[[itemController listForIdentifier:TextItemValueID] count]];
}

- (NSNumber *)numberOfExtendedTextItemValues {
    return [NSNumber numberWithInt:[[itemController listForIdentifier:ExtendedTextItemValueID] count]];
}

- (NSNumber *)numberOfNumberItemValues {
    return [NSNumber numberWithInt:[[itemController listForIdentifier:NumberItemValueID] count]];
}

- (NSNumber *)numberOfURLItemValues {
    return [NSNumber numberWithInt:[[itemController listForIdentifier:URLItemValueID] count]];
}

- (NSNumber *)numberOfBoolItemValues {
    return [NSNumber numberWithInt:[[itemController listForIdentifier:BoolItemValueID] count]];
}

- (NSNumber *)numberOfCurrencyItemValues {
    return [NSNumber numberWithInt:[[itemController listForIdentifier:CurrencyItemValueID] count]];
}

- (NSNumber *)numberOfFileItemValues {
    return [NSNumber numberWithInt:[[itemController listForIdentifier:FileItemValueID] count]];
}

- (NSNumber *)numberOfImageItemValues {
    return [NSNumber numberWithInt:[[itemController listForIdentifier:ImageItemValueID] count]];
}

- (NSNumber *)numberOfPDFItemValues {
    return [NSNumber numberWithInt:[[itemController listForIdentifier:PDFItemValueID] count]];
}

- (NSNumber *)sumOfItems {
    long ret = 0;
    ret += [[self numberOfSimpleTextItemValues] longValue];
    ret += [[self numberOfExtendedTextItemValues] longValue];
    ret += [[self numberOfNumberItemValues] longValue];
    ret += [[self numberOfURLItemValues] longValue];
    ret += [[self numberOfBoolItemValues] longValue];
    ret += [[self numberOfCurrencyItemValues] longValue];
    ret += [[self numberOfImageItemValues] longValue];
    ret += [[self numberOfPDFItemValues] longValue];
    return [NSNumber numberWithLong:ret];
}

- (IBAction)backupSetPath:(id)sender {
	CocoLog(LEVEL_DEBUG, @"[MBDatabasePrefsViewController -backupSetPath:]");
}

- (IBAction)dbPathSet:(id)sender {
	CocoLog(LEVEL_DEBUG, @"[MBDatabasePrefsViewController -dbPathSet:]");
}

- (IBAction)vacuumDatabase:(id)sender {
    [progressIndicator startAnimation:self];
    [[MBDBSqlite sharedConnection] vacuumDatabase];
    [progressIndicator stopAnimation:self];
}

@end
