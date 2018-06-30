/* MBTextEditorWindowController */

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import <globals.h>
#import <MBThreadedProgressSheetController.h>

@interface MBTextEditorWindowController : NSWindowController
{
    IBOutlet NSButton *okButton;
    IBOutlet NSButton *rulersButton;
    IBOutlet NSButton *spellCheckButton;
    IBOutlet NSTextView *textView;
	
	IBOutlet id delegate;
}

+ (MBTextEditorWindowController *) standardTextEditorController;

- (void)setDelegate:(id)aDelegate;
- (id)delegate;

- (void)setRTFDData:(NSData *)data;
- (NSData *)rtfdData;

- (void)setStringData:(NSString *)data;
- (NSString *)stringData;

- (IBAction)ok:(id)sender;
- (IBAction)switchRulers:(id)sender;
- (IBAction)switchSpellChecking:(id)sender;

@end
