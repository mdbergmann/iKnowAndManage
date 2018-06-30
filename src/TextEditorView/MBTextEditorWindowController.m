// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import "MBTextEditorWindowController.h"

@implementation MBTextEditorWindowController

+ (MBTextEditorWindowController *) standardTextEditorController
{
	static MBTextEditorWindowController *singleton;
	
	if(singleton == nil)
	{
		singleton = [[MBTextEditorWindowController alloc] init];
	}
	
	return singleton;	
}

- (id)init
{
	MBLOG(MBLOG_DEBUG,@"[MBTextEditorWindowController -init]");

	self = [super initWithWindowNibName:@"TextEditor"];
	if(self != nil)
	{
		// do something
	}
	
	return self;
}

/**
\brief dealloc of this class is called on closing this document
 */
- (void)dealloc
{
	MBLOG(MBLOG_DEBUG,@"[MBTextEditorWindowController -dealloc]");
	
	// dealloc object
	[super dealloc];
}

//--------------------------------------------------------------------
//----------- Bundle delegates ---------------------------------------
//--------------------------------------------------------------------
/**
\brief gets called ig the nib file has been loaded. all gfx objacts are available now.
 */
- (void)windowDidLoad
{
	MBLOG(MBLOG_DEBUG,@"[MBTextEditorWindowController -windowDidLoad]");
	
	if(self != nil)
	{
		// set textvalue textview to richtext
		[textView setRichText:YES];
	}	
}

- (void)setDelegate:(id)aDelegate
{
	delegate = aDelegate;
}

- (id)delegate
{
	return delegate;
}

- (void)setRTFDData:(NSData *)data
{
	// set rich text
	[textView setRichText:YES];
	[textView setImportsGraphics:YES];
	[textView replaceCharactersInRange:NSMakeRange(0,[[textView textStorage] length]) withRTFD:data];
}

- (NSData *)rtfdData
{
	return [textView RTFDFromRange:NSMakeRange(0,[[textView textStorage] length])];
}

- (void)setStringData:(NSString *)data
{
	// set ordinary text
	[textView setRichText:NO];	
	[textView replaceCharactersInRange:NSMakeRange(0,[[textView textStorage] length]) withString:data];
}

- (NSString *)stringData
{
	return [textView string];
}

- (IBAction)ok:(id)sender
{
	if(delegate != nil)
	{
		if([delegate respondsToSelector:@selector(editorEndedEditing)] == YES)
		{
			// check for data size
			NSData *rtfdData = [textView RTFDFromRange:NSMakeRange(0,[[textView textStorage] length])];
			if([rtfdData length] > (500 * 1024))
			{
				// greater than 500 kByte
				MBThreadedProgressSheetController *pSheet = [MBThreadedProgressSheetController standardProgressSheetController];
				[pSheet setDelegate:self];
				[pSheet setSheetWindow:[self window]];
				[pSheet setIsIndeterminateProgress:[NSNumber numberWithBool:YES]];
				[pSheet setActionMessage:MBLocaleStr(@"SavingTextEditorData")];
				[pSheet beginSheet];
				[pSheet startProgressAnimation];
				
				[delegate performSelector:@selector(editorEndedEditing)];

				[pSheet stopProgressAnimation];
				[pSheet endSheet];
			}
			else
			{
				[delegate performSelector:@selector(editorEndedEditing)];
			}
		}
		else
		{
			MBLOG(MBLOG_WARN,@"[MBTextEditorWindowController: ok:] delegate does not respond to selector!");
		}
	}
	else
	{
		MBLOG(MBLOG_WARN,@"[MBTextEditorWindowController: ok:] delegate is nil!");
	}
	
	[[self window] close];
}

- (IBAction)switchRulers:(id)sender
{
	[textView setRulerVisible:(BOOL)[sender state]];
}

- (IBAction)switchSpellChecking:(id)sender
{
}

@end
