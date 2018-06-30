// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import "MBThreadedProgressSheetController.h"

@implementation MBThreadedProgressSheetController

+ (MBThreadedProgressSheetController *)standardProgressSheetController
{
	static MBThreadedProgressSheetController *singleton;
	
	if(singleton == nil)
	{
		singleton = [[MBThreadedProgressSheetController alloc] init];
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
	MBLOG(MBLOG_DEBUG,@"init of MBThreadedProgressSheetController");
	
	self = [super init];
	if(self == nil)
	{
		MBLOG(MBLOG_ERR,@"cannot alloc MBThreadedProgressSheetController!");		
	}
	else
	{
	}
	
	return self;
}

/**
\brief dealloc of this class is called on closing this document
 */
- (void)dealloc
{
	MBLOG(MBLOG_DEBUG,@"dealloc of MBThreadedProgressSheetController");
	
	// dealloc object
	[super dealloc];
}

/**
 \brief set value to min
*/
- (void)resetProgressValue
{
	[progressIndicator setDoubleValue:[progressIndicator minValue]];
}

/**
 \brief set if this ThreadedProgressSheet should keep track of progress
*/
- (void)setShouldKeepTrackOfProgress:(NSNumber *)aSetting
{
	shouldKeepTrackOfProgress = [aSetting boolValue];
}

/**
 \brief should this ThreadedProgressSheet keep track of progress?
*/
- (BOOL)shouldKeepTrackOfProgress
{
	return shouldKeepTrackOfProgress;
}

/**
 \brief set the progress action before starting progress tracking
*/
- (void)setProgressAction:(NSNumber *)aAction
{
	progressAction = [aAction intValue];
}

/**
 \brief the progress action that is taking place
*/
- (int)progressAction
{
	return progressAction;
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

// threaded
- (void)setIsThreaded:(NSNumber *)aSetting
{
	[progressIndicator setUsesThreadedAnimation:[aSetting boolValue]];
}

- (BOOL)isThreaded
{
	return [progressIndicator usesThreadedAnimation];
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

// action message
- (void)setActionMessage:(NSString *)aMessage
{
	[actionLabel setStringValue:aMessage];
}

// sheet return code
- (int)sheetReturnCode
{
	return sheetReturnCode;
}

// dealing with progress
- (void)setIsIndeterminateProgress:(NSNumber *)aSetting
{
	[progressIndicator setIndeterminate:[aSetting boolValue]];
}

- (BOOL)isIndeterminateProgress
{
	return [progressIndicator isIndeterminate];
}

- (void)setIsDisplayedWhenStopped:(NSNumber *)aSetting
{
	[progressIndicator setDisplayedWhenStopped:[aSetting boolValue]];
}

- (BOOL)isDisplayedWhenStopped
{
	return [progressIndicator isDisplayedWhenStopped];
}

- (void)animateProgress
{
	[progressIndicator animate:nil];
}

- (void)setMaxProgressValue:(NSNumber *)aValue
{
	[progressIndicator setMaxValue:[aValue doubleValue]];
}

- (double)maxProgressValue
{
	return [progressIndicator maxValue];
}

- (void)setMinProgressValue:(NSNumber *)aValue
{
	[progressIndicator setMinValue:[aValue doubleValue]];
}

- (double)minProgressValue
{
	return [progressIndicator minValue];
}

- (void)setProgressValue:(NSNumber *)aValue
{
	[progressIndicator setDoubleValue:[aValue doubleValue]];
}

- (double)progressValue
{
	return [progressIndicator doubleValue];
}

- (void)incrementProgressBy:(NSNumber *)aValue
{
	[progressIndicator incrementBy:[aValue doubleValue]];
}

- (void)startProgressAnimation
{
	[progressIndicator startAnimation:nil];
}

- (void)stopProgressAnimation
{
	[progressIndicator stopAnimation:nil];
}

// begin sheet
- (void)beginSheet
{
	[NSApp beginSheet:sheet 
	   modalForWindow:sheetWindow 
		modalDelegate:self 
	   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) 
		  contextInfo:nil];
}

// end sheet
- (void)endSheet
{
	[NSApp endSheet:sheet returnCode:0];
}

// end sheet callback
- (void)sheetDidEnd:(NSWindow *)sSheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	/*
	if([delegate respondsToSelector:@selector(threadedSheetDidEnd)] == YES)
	{
		[delegate performSelector:@selector(threadedSheetDidEnd)];
	}
	 */
	
	// hide sheet
	[sSheet orderOut:nil];
	
	sheetReturnCode = returnCode;
}

- (IBAction)cancelButton:(id)sender
{
	// disable button
	[cancelButton setEnabled:NO];
	[NSApp endSheet:sheet returnCode:1];
}

@end
