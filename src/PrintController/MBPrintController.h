//
//  MBPrintController.h
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

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface MBPrintController : NSWindowController 
{
	// out needed webview
	IBOutlet WebView *webView;
	IBOutlet NSButton *print;
	IBOutlet NSButton *cancel;
}
  
+ (MBPrintController *)defaultPrintController;

- (void)printItemList:(NSArray *)itemArray;
- (void)printItemValueList:(NSArray *)itemValueArray;
- (void)printView:(NSView *)aView;

- (IBAction)cancelButton:(id)sender;
- (IBAction)printButton:(id)sender;

@end
