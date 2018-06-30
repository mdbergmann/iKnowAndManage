//
//  MBItemPrintView.h
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 29.11.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import <MBItemBaseController.h>

@interface MBItemPrintView : NSView 
{
	NSArray *items;
	NSMutableDictionary *attributes;
	NSSize paperSize;
	float leftMargin;
	float topMargin;
}

- (id)initWithItems:(NSArray *)array printInfo:(NSPrintInfo *)pi;

- (NSRect)rectForItem:(int)index;
- (int)itemsPerPage;

@end
