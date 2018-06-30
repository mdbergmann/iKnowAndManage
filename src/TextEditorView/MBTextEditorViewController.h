/* MBTextEditorViewController */

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import <globals.h>
#import <MBPrintController.h>

#define MBDefaultTXTFont [NSFont fontWithName: @"Courier" size: 12]
#define MBDefaultRTFFont [NSFont fontWithName: @"Helvetica" size: 12]

@interface MBTextEditorViewController : NSObject {
    IBOutlet NSButton *okButton;
	IBOutlet NSButton *saveButton;
	IBOutlet NSButton *saveAsButton;
    IBOutlet NSButton *rulersButton;
    IBOutlet NSButton *spellCheckButton;
	IBOutlet NSButton *fontButton;
	IBOutlet NSButton *colorButton;
	IBOutlet NSPopUpButton *typeButton;
    IBOutlet NSTextView *textView;
	IBOutlet NSView *saveAccessoryView;
	
	IBOutlet NSView *textEditorView;

	int texttype;
	
	id delegate;
	
	float collapseHeight;
}

+ (MBTextEditorViewController *) standardTextEditorController;

- (void)setDelegate:(id)aDelegate;
- (id)delegate;

- (NSView *)textEditorView;
- (float)collapseHeight;

- (void)setTextDataAsRTF:(NSData *)rtfData;
- (void)setTextDataAsRTFD:(NSData *)rtfdData;
- (void)setTextDataAsTXT:(NSData *)stringData;
- (NSData *)textDataAsTXT;
- (NSData *)textDataAsRTF;
- (NSData *)textDataAsRTFD;

- (IBAction)saveAs:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)switchRulers:(id)sender;
- (IBAction)switchSpellChecking:(id)sender;
- (IBAction)changeTextTypeToTXT:(id)sender;
- (IBAction)changeTextTypeToRTF:(id)sender;
- (IBAction)changeTextTypeToRTFD:(id)sender;
- (IBAction)openFontsPanel:(id)sender;
- (IBAction)openColorsPanel:(id)sender;

// printing
- (IBAction)print:(id)sender;

@end
