//
//  MBPrintController.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 27.09.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <CocoLogger/CocoLogger.h>
#import "MBPrintController.h"
#import "globals.h"
#import "MBHTMLGenerator.h"

@interface MBPrintController (privateAPI)

@end

@implementation MBPrintController (privateAPI)

@end

@implementation MBPrintController

+ (MBPrintController *)defaultPrintController {
	static MBPrintController *singleton;
	
	if(singleton == nil) {
		singleton = [[MBPrintController alloc] init];
	}
	
	return singleton;
}

- (id)init {
	self = [super initWithWindowNibName:@"PrintWebView"];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"cannot alloc MBPrintController!");		
	} else {
	}
	
	return self;
}

- (void)windowDidLoad {
	// set WebPreferences to print background
	WebPreferences *prefs = [webView preferences];
	[prefs setShouldPrintBackgrounds:YES];
}

- (void)dealloc {
	// dealloc object
	[super dealloc];
}
 
/**
 \brief print this itemArray, process elements and build a array with dictionaries for HTMLListCreator
*/
- (void)printItemValueList:(NSArray *)itemValueArray; {
	// get HTMLGenerator
	MBHTMLGenerator *htmlGen = [MBHTMLGenerator defaultGenerator];
	
	NSString *htmlOutputPath = [NSString stringWithFormat:@"%@/%@",TMPFOLDER,@"print"];

	// clean output path first
	NSFileManager *fm = [NSFileManager defaultManager];
	[fm removeFileAtPath:htmlOutputPath handler:nil];
		
	NSString *pathToIndexHTML = [htmlGen generateHTMLForItemValueList:itemValueArray toOutputDir:htmlOutputPath options:[MBHTMLGenerator defaultPrintOptions]];

	// generate url request
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:pathToIndexHTML]];
	
	// set window invisible
	//[[super window] setIsVisible:NO];
	
	// show window
	[self showWindow:self];
	
	// load resource
	[[webView mainFrame] loadRequest:urlRequest];
}

/**
 \brief print item list
*/
- (void)printItemList:(NSArray *)itemArray {
	// get HTMLGenerator
	MBHTMLGenerator *htmlGen = [MBHTMLGenerator defaultGenerator];	
	NSString *htmlOutputPath = [NSString stringWithFormat:@"%@/%@",TMPFOLDER,@"print"];
	
	// clean output path first
	NSFileManager *fm = [NSFileManager defaultManager];
	[fm removeFileAtPath:htmlOutputPath handler:nil];
	
	NSString *pathToIndexHTML = [htmlGen generateHTMLForItemList:itemArray toOutputDir:htmlOutputPath options:[MBHTMLGenerator defaultPrintOptions]];

	// generate url request
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:pathToIndexHTML]];
	
	// set window invisible
	//[[super window] setIsVisible:NO];
	
	// show window
	[self showWindow:self];
	
	// load resource
	[[webView mainFrame] loadRequest:urlRequest];
}

- (void)printView:(NSView *)aView {
	// create print info and stuff
	NSPrintInfo *printInfo = [NSPrintInfo sharedPrintInfo];
	// set not horizontally centered
	[printInfo setHorizontallyCentered:NO];
	[printInfo setVerticallyCentered:NO];
	NSPrintOperation *printOp;
	// print the content of this view
	printOp = [NSPrintOperation printOperationWithView:aView printInfo:printInfo];
	[printOp setShowPanels:YES];
	[printOp runOperation];	
}

- (IBAction)cancelButton:(id)sender {
	[[super window] close];
}

- (IBAction)printButton:(id)sender {	
	[[super window] close];	
	
	//[[[[webView mainFrame] frameView] documentView] print:self];
	NSView *printView = [[[webView mainFrame] frameView] documentView];
	
	// create print info and stuff
	NSPrintInfo *printInfo = [NSPrintInfo sharedPrintInfo];
	// set not horizontally centered
	[printInfo setHorizontallyCentered:YES];
	[printInfo setVerticallyCentered:NO];
	NSPrintOperation *printOp;
	// print the content of this view
	//MBItemPrintView *v = [[[MBItemPrintView alloc] initWithItems:printSelection printInfo:printInfo] autorelease];
	printOp = [NSPrintOperation printOperationWithView:printView printInfo:printInfo];
	[printOp setShowPanels:YES];
	[printOp runOperation];	
}

@end
