// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import "MBConfirmationSheetController.h"

@interface MBConfirmationSheetController (privateAPI)

// end sheet callback
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

@end

@implementation MBConfirmationSheetController (privateAPI)

// end sheet callback
- (void)sheetDidEnd:(NSWindow *)sSheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	// hide sheet
	[sSheet orderOut:nil];
	
	sheetReturnCode = returnCode;
	
	// tell delegate that user has made a confirmation
	if(delegate != nil)
	{
		if([delegate respondsToSelector:@selector(confirmationSheetEnded)] == YES)
		{
			[delegate performSelector:@selector(confirmationSheetEnded)];
		}
		else
		{
			CocoLog(LEVEL_WARN,@"[MBConfirmationSheetController -sheetDidEnd:] delegate does not respond to selector!");
		}
	}
}

@end

@implementation MBConfirmationSheetController

+ (MBConfirmationSheetController *)standardConfirmationSheetController
{
	static MBConfirmationSheetController *singleton;
	
	if(singleton == nil)
	{
		singleton = [[MBConfirmationSheetController alloc] init];
	}
	
	return singleton;
}

/**
\brief init is called after alloc:. some initialization work can be done here.
 No GUI elements are available here. It additinally calls the init method of superclass
 @returns initialized not nil object
 */
- (id)init
{
	CocoLog(LEVEL_DEBUG,@"init of MBConfirmationSheetController");
	
	self = [super init];
	if(self == nil)
	{
		CocoLog(LEVEL_ERR,@"cannot alloc MBConfirmationSheetController!");		
	}
	else
	{
		BOOL success = [NSBundle loadNibNamed:CONFIRMATION_SHEET_NIB_NAME owner:self];
		if(success == YES)
		{
		}
		else
		{
			CocoLog(LEVEL_ERR,@"[MBConfirmationSheetController]: cannot load MBConfirmationSheetControllerNib!");
		}
	}
	
	return self;
}

- (void)awakeFromNib
{
	CocoLog(LEVEL_DEBUG,@"awakeFromNib of MBConfirmationSheetController");
	
	if(self != nil)
	{
		// set bold font to confirmation title text field
		NSFont *boldface = [NSFont boldSystemFontOfSize:14.0];
		// set to textfield
		[confirmationTitle setFont:boldface];
		
		// set ImageView to no Frame
		[imageView setImageFrameStyle:NSImageFrameNone];
		// set DialogKind to Warning
		[self setDialogKind:WarningDialogKind];
	}
}

/**
\brief dealloc of this class is called on closing this document
 */
- (void)dealloc
{
	CocoLog(LEVEL_DEBUG,@"dealloc of MBConfirmationSheetController");
	
	// dealloc object
	[super dealloc];
}

// delegate
- (void)setDelegate:(id)anObject
{
	delegate = anObject;
}

- (id)delegate
{
	return delegate;
}

// window title
- (void)setSheetTitle:(NSString *)aTitle
{
	[sheetWindow setTitle:aTitle];
}

- (NSString *)sheetTitle
{
	return [sheetWindow title];
}

// sheet Window
- (void)setSheetWindow:(NSWindow *)aWindow
{
	sheetWindow = aWindow;
}

- (NSWindow *)sheetWindow
{
	return sheetWindow;
}

// sheet return code
- (int)sheetReturnCode
{
	return sheetReturnCode;
}

// confirmation message
- (void)setConfirmationMessage:(NSString *)aMessage
{
	[confirmationText setStringValue:aMessage];
}

// confirmation title
- (void)setConfirmationTitle:(NSString *)aMessage
{
	// set it
	[confirmationTitle setStringValue:aMessage];
}

// context info
- (void)setContextInfo:(void *)aContext
{
	contextInfo = aContext;
}

- (void *)contextInfo
{
	return contextInfo;
}

// set dialog kind
- (void)setDialogKind:(MBConfirmationDialogKind)aKind
{
	NSImage *image = nil;
	
	switch(aKind)
	{
		case InfoDialogKind:
		case WarningDialogKind:
		case AlertDialogKind:
			image = [NSImage imageNamed:@"Warning.icns"];
			break;
	}
	
	if(image != nil)
	{
		[imageView setImage:image];
	}
	
	dialogKind = aKind;
}

- (MBConfirmationDialogKind)dialogKind
{
	return dialogKind;
}

// yes/no - ok/cancel
- (void)setButtonTypeYesNoCancel
{
	[defaultButton setTitle:MBLocaleStr(@"Yes")];
	[alternateButton setTitle:MBLocaleStr(@"No")];
	[otherButton setHidden:NO];
	[otherButton setTitle:MBLocaleStr(@"Cancel")];
}

- (void)setButtonTypeOkCancel
{
	[defaultButton setTitle:MBLocaleStr(@"OK")];
	[alternateButton setTitle:MBLocaleStr(@"Cancel")];
	[otherButton setHidden:YES];
}

- (void)setButtonTypeOk
{
	[defaultButton setTitle:MBLocaleStr(@"OK")];
	[alternateButton setHidden:YES];
	[otherButton setHidden:YES];
}

// get ask again state
- (BOOL)askAgainState
{
	return (BOOL)[askAgainButton state];
}

// ask again needed?
- (void)setAskAgainEnabled:(BOOL)enabled
{
	[askAgainButton setEnabled:enabled];
}

- (void)setAskAgainHidden:(BOOL)hidden
{
	[askAgainButton setHidden:hidden];
}

/**
 \brief begin sheet
*/
- (void)beginSheet
{
	// reset switch
	[askAgainButton setState:0];
	
	[NSApp beginSheet:sheet 
	   modalForWindow:sheetWindow 
		modalDelegate:self 
	   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) 
		  contextInfo:nil];
}

/**
 \brief begoin sheet with lots of paranmeters to set
*/
- (void)beginSheetWithTitle:(NSString *)aTitle 
					message:(NSString *)msg 
			  defaultButton:(NSString *)defaultTxt
			alternateButton:(NSString *)alternateTxt
				otherButton:(NSString *)otherTxt
			 askAgainButton:(NSString *)askAgainTxt
				contextInfo:(void *)aContextInfo
				  docWindow:(NSWindow *)aWindow
{
	[self setConfirmationTitle:aTitle];
	[self setConfirmationMessage:msg];

	// checkbuttons
	
	// default button
	if(defaultTxt == nil)
	{
		[defaultButton setHidden:YES];
	}
	else
	{
		[defaultButton setHidden:NO];
		// and set text
		[defaultButton setTitle:defaultTxt];
	}
	// alternate button
	if(alternateTxt == nil)
	{
		[alternateButton setHidden:YES];
	}
	else
	{
		[alternateButton setHidden:NO];
		// and set text
		[alternateButton setTitle:alternateTxt];
	}
	// other button
	if(otherTxt == nil)
	{
		[otherButton setHidden:YES];
	}
	else
	{
		[otherButton setHidden:NO];
		// and set text
		[otherButton setTitle:otherTxt];
	}
	// ask again button
	if(askAgainTxt == nil)
	{
		[askAgainButton setHidden:YES];
	}
	else
	{
		[askAgainButton setHidden:NO];
		// and set text
		[askAgainButton setTitle:askAgainTxt];
		// set state
		[askAgainButton setState:0];
	}
	
	// set contextInfo
	[self setContextInfo:aContextInfo];
	// set window
	[self setSheetWindow:aWindow];
	
	[NSApp beginSheet:sheet 
	   modalForWindow:sheetWindow 
		modalDelegate:self 
	   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) 
		  contextInfo:aContextInfo];	
}

// end sheet
- (void)endSheet
{
	[NSApp endSheet:sheet returnCode:0];
}

/**
 \briefd run modal as window
*/
- (int)runModal
{
	return [NSApp runModalForWindow:sheet];
}

- (IBAction)defaultButton:(id)sender
{
	[NSApp endSheet:sheet returnCode:SheetDefaultButtonCode];	
}

- (IBAction)alternateButton:(id)sender
{
	[NSApp endSheet:sheet returnCode:SheetAlternateButtonCode];
}

- (IBAction)otherButton:(id)sender
{
	[NSApp endSheet:sheet returnCode:SheetOtherButtonCode];
}

- (IBAction)switchNotAskAgain:(id)sender
{
}

@end
