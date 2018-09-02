// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import "MBTextEditorViewController.h"

@implementation MBTextEditorViewController

+ (MBTextEditorViewController *) standardTextEditorController
{
	static MBTextEditorViewController *singleton;
	
	if(singleton == nil)
	{
		singleton = [[MBTextEditorViewController alloc] init];
	}
	
	return singleton;	
}

- (id)init {
	CocoLog(LEVEL_DEBUG,@"[MBTextEditorViewController -init]");

	self = [super init];
	if(self != nil) {
		BOOL success = [NSBundle loadNibNamed:@"TextEditorView" owner:self];
		if(success == YES) {
		} else {
			CocoLog(LEVEL_ERR,@"[MBTextEditorViewController]: cannot load TextEditorNib!");
			
			// set default texttype to txt
			texttype = 0;
		}
	}
	
	return self;
}

/**
\brief dealloc of this class is called on closing this document
 */
- (void)dealloc {
	CocoLog(LEVEL_DEBUG,@"[MBTextEditorViewController -dealloc]");
	
	// dealloc object
	[super dealloc];
}

//--------------------------------------------------------------------
//----------- Bundle delegates ---------------------------------------
//--------------------------------------------------------------------
/**
\brief gets called ig the nib file has been loaded. all gfx objacts are available now.
 */
- (void)awakeFromNib {
	CocoLog(LEVEL_DEBUG,@"[MBTextEditorViewController -awakeFromNib]");
	
	if(self != nil) {
		// calculate collapse height
		collapseHeight = [textEditorView frame].size.height - [textView frame].size.height;
	}	
}

- (void)setDelegate:(id)aDelegate {
	delegate = aDelegate;
}

- (id)delegate {
	return delegate;
}

- (NSView *)textEditorView {
	return textEditorView;
}

- (float)collapseHeight {
	return collapseHeight;
}

- (void)setTextDataAsRTFD:(NSData *)rtfdData {
	// set font
	[textView setFont:MBDefaultRTFFont];
	// activate ruler button
	[rulersButton setEnabled:YES];
	// set rich text directory
	[textView setRichText:YES];
	[textView setImportsGraphics:YES];
	[textView replaceCharactersInRange:NSMakeRange(0,[[textView textStorage] length]) withRTFD:rtfdData];
	
	// deactivate save button
	[saveButton setEnabled:NO];

	// rtfd type
	[self changeTextTypeToRTFD:nil];
}

- (void)setTextDataAsRTF:(NSData *)rtfData {
	// set font
	[textView setFont:MBDefaultRTFFont];
	// activate ruler button
	[rulersButton setEnabled:YES];
	// set rich text
	[textView setRichText:YES];
	[textView setImportsGraphics:NO];
	[textView replaceCharactersInRange:NSMakeRange(0,[[textView textStorage] length]) withRTF:rtfData];
	
	// deactivate save button
	[saveButton setEnabled:NO];

	// rtf type
	[self changeTextTypeToRTF:nil];
}

- (void)setTextDataAsTXT:(NSData *)txtData {
	// set font
	[textView setFont:MBDefaultTXTFont];
	// deactivate ruler button
	[rulersButton setEnabled:NO];
	[rulersButton setState:0];
	// deactivate ruler
	[self switchRulers:rulersButton];
	// set txt
	[textView setRichText:NO];
	[textView setImportsGraphics:NO];
	NSString *txtString = [[[NSString alloc] initWithData:txtData encoding:NSUTF8StringEncoding] autorelease];
	if([txtString length] > 0) {
        [textView replaceCharactersInRange:NSMakeRange(0,[[textView textStorage] length]) withString:txtString];
	} else {
	    [textView setString:@""];
    }

	// deactivate save button
	[saveButton setEnabled:NO];

	// txt type
	[self changeTextTypeToTXT:nil];
}

- (NSData *)textDataAsTXT {
	NSData *data = nil;
	// string
	data = [[[textView textStorage] string] dataUsingEncoding:NSUTF8StringEncoding];
	
	return data;
}

- (NSData *)textDataAsRTF {
	NSData *data = nil;
	// rtf
	data = [textView RTFFromRange:NSMakeRange(0,[[textView textStorage] length])];

	return data;
}

- (NSData *)textDataAsRTFD {
	NSData *data = nil;
	// rtfd
	data = [textView RTFDFromRange:NSMakeRange(0,[[textView textStorage] length])];
	
	return data;
}

- (IBAction)save:(id)sender {
	// notify delegate that text has changed
	if([delegate respondsToSelector:@selector(acc_Save:)]) {
		[delegate performSelector:@selector(acc_Save:) withObject:nil];
		// deactivate save button
		[saveButton setEnabled:NO];
	} else {
		CocoLog(LEVEL_WARN,@"[MBTextEditorViewController -acc_Save:] delegate does not respond to selector!");
	}	
}

- (IBAction)saveAs:(id)sender {
	// save to disk
	int runResult;
	
	// create SavePanel
	NSSavePanel *sp = [NSSavePanel savePanel];
	// add AccessoryView for choosing texttype
	[sp setAccessoryView:saveAccessoryView];
	[sp setCanCreateDirectories:YES];
	[sp setCanSelectHiddenExtension:YES];
	
	/* display the NSSavePanel */
	runResult = [sp runModalForDirectory:NSHomeDirectory() file:@""];
	//runResult = [NSApp runModalForWindow:[super window]];
	/* if successful, save file under designated name */
	if(runResult == NSOKButton) {
		// first make sure we have a filename extension
		NSString *filename = [sp filename];
		BOOL hasExtension = YES;
		if([[filename pathExtension] isEqualToString:@""]) {
			hasExtension = NO;
		}
		
		NSData *textData = nil;
		switch(texttype) {
			case 0:
				// txt
				textData = [self textDataAsTXT];
				// save
				if(hasExtension == NO) {
					filename = [filename stringByAppendingString:@".txt"];
				}
				[textData writeToFile:filename atomically:YES];
				break;
			case 1:
				// rtf
				textData = [self textDataAsRTF];
				// save
				if(hasExtension == NO) {
					filename = [filename stringByAppendingString:@".rtf"];
				}
					[textData writeToFile:filename atomically:YES];
				break;
			case 2:
				// rtfd
				// for rtfd we have to save a special way
				// save
				if(hasExtension == NO) {
					filename = [filename stringByAppendingString:@".rtfd"];
				}
				[textView writeRTFDToFile:filename atomically:YES];
				break;
		}		
	}
}

- (IBAction)switchRulers:(id)sender {
	[textView setRulerVisible:(BOOL)[sender state]];
}

- (IBAction)switchSpellChecking:(id)sender {
	[textView setContinuousSpellCheckingEnabled:(BOOL)[sender state]];
}

- (IBAction)changeTextTypeToTXT:(id)sender {
	CocoLog(LEVEL_DEBUG,@"[changing type to string");
	// string
	texttype = 0;
	
	// deactivate font and color menu
	[fontButton setEnabled:YES];
	[colorButton setEnabled:YES];
}

- (IBAction)changeTextTypeToRTF:(id)sender {
	CocoLog(LEVEL_DEBUG,@"[changing type to rtf");
	// rtf
	texttype = 1;

	// activate font and color menu
	[fontButton setEnabled:YES];
	[colorButton setEnabled:YES];
}

- (IBAction)changeTextTypeToRTFD:(id)sender {
	CocoLog(LEVEL_DEBUG,@"[changing type to rtfd");
	// rtfd
	texttype = 2;

	// activate font and color menu
	[fontButton setEnabled:YES];
	[colorButton setEnabled:YES];
}

/**
 \brief opens the system fonts panel
*/
- (IBAction)openFontsPanel:(id)sender {
	NSFontPanel *fp = [NSFontPanel sharedFontPanel];
	[fp setIsVisible:YES];
}

/**
 \brief open system colors panel
*/
- (IBAction)openColorsPanel:(id)sender {
	NSColorPanel *cp = [NSColorPanel sharedColorPanel];
	[cp setIsVisible:YES];
}

/**
\brief figure what should be printed, prepare views and show print dialog
 */
- (IBAction)print:(id)sender {
	CocoLog(LEVEL_DEBUG,@"[MBTextEditorViewController -print:]");
	
	// use MBPrintController
	MBPrintController *pC = [MBPrintController defaultPrintController];
	[pC printView:textView];
}

//--------------------------------------------------------------------
//----------- NSTextView Notifications -------------------------------
//--------------------------------------------------------------------
- (void)textDidChange:(NSNotification *)aNotification {
	// test has changed
	
	// notify delegate that text has changed
	if([delegate respondsToSelector:@selector(textChangedNotify)] == YES) {
		[delegate performSelector:@selector(textChangedNotify)];
		
		// activate save button
		[saveButton setEnabled:YES];
	} else {
		CocoLog(LEVEL_WARN,@"[MBTextEditorViewController -textDidChange:] delegate does not respond to selector!");
	}
}

@end
