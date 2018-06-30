#import "MBPreferenceSheetController.h"

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

@implementation MBPreferenceSheetController

/**
\brief init is called after alloc:. some initialization work can be done here.
 No GUI elements are available here. It additinally calls the init method of superclass
 @returns initialized not nil object
 */
- (id)init
{
	MBLOG(MBLOG_DEBUG,@"init of MBPreferenceSheetController");
	
	self = [super init];
	if(self == nil)
	{
		MBLOG(MBLOG_ERR,@"cannot alloc MBPreferenceSheetController!");		
	}
	else
	{
		// init formatSetterController
		formatSetterController = [[MBFormatSetterController alloc] init];
	}
	
	return self;
}

/**
\brief dealloc of this class is called on closing this document
 */
- (void)dealloc
{
	MBLOG(MBLOG_DEBUG,@"dealloc of MBPreferenceSheetController");

	// release formatSetterController
	[formatSetterController release];
	
	// dealloc object
	[super dealloc];
}

/**
 \brief the sheet is linked to a window, this sets the window, the sheet should come up
*/
- (void)setSheetWindow:(NSWindow *)aWindow
{
	sheetWindow = aWindow;
}

- (NSWindow *)sheetWindow
{
	return sheetWindow;
}

//--------------------------------------------------------------------
//----------- bundle delegates ---------------------------------------
//--------------------------------------------------------------------
- (void)awakeFromNib
{
	MBLOG(MBLOG_DEBUG,@"awakeFromNib of MBPreferenceSheetController");
	
	if(self != nil)
	{
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

		// load FormatSetterNib, so we have the views we need
		BOOL success = [NSBundle loadNibNamed:FORMAT_SETTER_NIB_NAME owner:formatSetterController];
		if(success == YES)
		{
			// set content views of boxes
			[numberFormatSetterBox setContentViewMargins:NSMakeSize(0.0,0.0)];
			[numberFormatSetterBox setContentView:[formatSetterController numberFormatSetterView]];
			[currencyFormatSetterBox setContentViewMargins:NSMakeSize(0.0,0.0)];
			[currencyFormatSetterBox setContentView:[formatSetterController currencyFormatSetterView]];
			[dateFormatSetterBox setContentViewMargins:NSMakeSize(0.0,0.0)];
			[dateFormatSetterBox setContentView:[formatSetterController dateFormatSetterView]];
		}
		else
		{
			MBLOG(MBLOG_ERR,@"[MBPreferenceSheetController]: cannot load FormatSetterNib!");
		}
		
		// set display settings
		[useMetalLookButton setState:[defaults integerForKey:MBDefaultsMetalDisplayKey]];
		[usePanelInfoButton setState:[defaults integerForKey:MBDefaultsUsePanelInfoKey]];
	}
}

//--------------------------------------------------------------------
//----------- getter and setter --------------------------------------
//--------------------------------------------------------------------
- (void)setDelegate:(id)anObject
{
	delegate = anObject;
}

- (id)delegate
{
	return delegate;
}

//--------------------------------------------------------------------
//----------- sheet stuff --------------------------------------
//--------------------------------------------------------------------
/**
 \brief the sheet return code
*/
- (int)sheetReturnCode
{
	return sheetReturnCode;
}

/**
 \brief bring up this sheet, sheetwindow should have been set
*/
- (void)beginSheet
{
	[NSApp beginSheet:sheet 
	   modalForWindow:sheetWindow 
		modalDelegate:self 
	   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) 
		  contextInfo:nil];
}

/**
 \brief end this sheet
*/
- (void)endSheet
{
	[NSApp endSheet:sheet returnCode:0];
}

// end sheet callback
- (void)sheetDidEnd:(NSWindow *)sSheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	// hide sheet
	[sSheet orderOut:nil];
	
	sheetReturnCode = returnCode;
}

//--------------------------------------------------------------------
//----------- Actions ---------------------------------------
//--------------------------------------------------------------------
- (IBAction)okButton:(id)sender
{
	// end this sheet
	[self endSheet];
}

- (IBAction)backupRestoreFactorySettings:(id)sender
{
}

- (IBAction)backupActivate:(id)sender
{
}

- (IBAction)backupSetPath:(id)sender
{
}

- (IBAction)switchMetalLook:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	// set state of button
	[defaults setInteger:[sender state] forKey:MBDefaultsMetalDisplayKey];

	// call delegate method
	if([delegate respondsToSelector:@selector(switchInterfaceLookAndFeelToMetal:)] == YES)
	{
		[delegate performSelector:@selector(switchInterfaceLookAndFeelToMetal:) withObject:[NSNumber numberWithBool:(BOOL)[sender state]]];
	}
	else
	{
		MBLOG(MBLOG_WARN,@"[MBPreferenceController -switchMetalLook:]: delegate does not respond to selector!");
	}

	// set this window immidiately
	//[prefPanel _setTexturedBackground:(BOOL)[sender state]];
}

- (IBAction)switchUsePanelInfo:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	// set state of button
	[defaults setInteger:[sender state] forKey:MBDefaultsUsePanelInfoKey];

	// call delegate method
	if([delegate respondsToSelector:@selector(switchUseInfoPanel:)] == YES)
	{
		[delegate performSelector:@selector(switchUseInfoPanel:) withObject:[NSNumber numberWithBool:(BOOL)[sender state]]];
	}
	else
	{
		MBLOG(MBLOG_WARN,@"[MBPreferenceController -switchUseInfoPanel:]: delegate does not respond to selector!");
	}
}

@end
