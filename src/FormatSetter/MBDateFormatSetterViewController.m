#import <CocoLogger/CocoLogger.h>
#import "MBDateFormatSetterViewController.h"
#import "globals.h"

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

@implementation MBDateFormatSetterViewController

- (id)init
{
	self = [super init];
	if(self != nil)
	{
		// create all available dateFormats
		[self setDateFormats:[MBDateFormatSetterViewController availableDateFormats]];
		
		// init currentDate
		displayDate = [[NSDate date] retain];
	}
	
	return self;
}

- (void)dealloc
{
	CocoLog(LEVEL_DEBUG,@"dealloc of MBDateFormatSetterViewController");

	// release some stuff
	[self setDateFormats:nil];
	[self setDateFormatString:nil];
	[self setDisplayDate:nil];
	
	
	// dealloc object
	[super dealloc];
}

- (void)awakeFromNib
{
	CocoLog(LEVEL_DEBUG,@"awakeFromNib of MBDateFormatSetterViewController");
	
	if(self != nil)
	{
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

- (NSView *)theView
{
	return theView;
}

/**
 \brief all available date formats
*/
+ (NSArray *)availableDateFormats
{
	return [NSArray arrayWithObjects:@"%a",@"%A",@"%b",@"%B",@"%c",@"%d",@"%e",@"%F",@"%H",@"%I",@"%j",@"%m",@"%M",@"%p",@"%S",
		@"%w",@"%x",@"%X",@"%y",@"%Y",@"%z",@"%Z",nil];		
}

- (void)setDateFormats:(NSArray *)formats
{
	[formats retain];
	[dateFormats release];
	dateFormats = formats;
}

- (NSArray *)dateFormats
{
	return dateFormats;
}

- (void)setDateFormatString:(NSString *)formatString
{
	[formatString retain];
	[dateFormatString release];
	dateFormatString = formatString;
	
	// set format string textfield as well
	[formatTextField setStringValue:formatString];
	// create dateFormatter
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] initWithDateFormat:formatString 
															 allowNaturalLanguage:[self allowNatLanguage]] autorelease];
	// example textfield with new formatter
	[exampleTextField setFormatter:dateFormatter];
	// set dispaly date to exampletextfield
	[exampleTextField setObjectValue:displayDate];
}

- (NSString *)dateFormatString
{
	return dateFormatString;
}

- (void)setAllowNatLanguage:(BOOL)flag
{
	allowNatLanguage = flag;
	
	// set button as well
	[allowNaturalLanguageButton setState:(int)flag];
	
	// create dateFormatter
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] initWithDateFormat:[self dateFormatString] 
															 allowNaturalLanguage:flag] autorelease];
	// example textfield with new formatter
	[exampleTextField setFormatter:dateFormatter];
	// set dispaly date to exampletextfield
	[exampleTextField setObjectValue:displayDate];
}

- (BOOL)allowNatLanguage
{
	return allowNatLanguage;
}

- (void)setDisplayDate:(NSDate *)date
{
	[date retain];
	[displayDate release];
	displayDate = date;
	
	[exampleTextField setObjectValue:date];
}

- (NSDate *)displayDate
{
	return displayDate;
}

// ---------------------------------------
// actions
// ---------------------------------------
- (IBAction)allowNaturalLanguageSwitch:(id)sender
{
	// set allowNatLanguage
	[self setAllowNatLanguage:(BOOL)[sender state]];

	// inform delegate that the allowNatLanguage setting has changed
	if([delegate respondsToSelector:@selector(allowNatLanguageSettingOfDateSetterControllerChanged:)])
	{
		[delegate performSelector:@selector(allowNatLanguageSettingOfDateSetterControllerChanged:) withObject:self];
	}
	else
	{
		CocoLog(LEVEL_WARN,@"delegate does not respond to method!");
	}
}

- (IBAction)formatInput:(id)sender
{
	// set formatString
	[self setDateFormatString:[sender stringValue]];
	
	// inform delegate that the format has changed
	if([delegate respondsToSelector:@selector(formatStringSettingOfDateSetterControllerChanged:)])
	{
		[delegate performSelector:@selector(formatStringSettingOfDateSetterControllerChanged:) withObject:self];
	}
	else
	{
		CocoLog(LEVEL_WARN,@"delegate does not respond to method!");
	}
}

// ---------------------------------------
// NSTableViewSource delegates
// ---------------------------------------
- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [[self dateFormats] count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	if([[aTableColumn identifier] isEqualToString:@"formatString"])
	{
		return [[self dateFormats] objectAtIndex:rowIndex];
	}
	else
	{
		return [self displayDate];
	}
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	// set smaller font
	NSFont *font = MBStdTableViewFont;
	[aCell setFont:font];
	// set row height according to used font
	// get font height
	double pointSize = [font pointSize];
	[aTableView setRowHeight:pointSize+5];
	
	if([[aTableColumn identifier] isEqualToString:@"formatString"])
	{
		[aCell setFormatter:nil];
	}
	else
	{
		// create and set set DateFormatter for cell
		NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] initWithDateFormat:[[self dateFormats] objectAtIndex:rowIndex] 
																 allowNaturalLanguage:NO] autorelease];
		// set it
		[aCell setFormatter:dateFormatter];
	}
}

- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	// editing now allowed
	return NO;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	// get selected row
	int row = [formatTableView selectedRow];
	
	if(row >= 0)
	{
		// get explanation string from localized strings and set it to textview
		NSString *exl = MBLocaleStr([[self dateFormats] objectAtIndex:row]);
		// set to textview
		[explanationTextView setEditable:YES];
		[explanationTextView replaceCharactersInRange:NSMakeRange(0,[[explanationTextView textStorage] length]) withString:exl];
		[explanationTextView setEditable:NO];
	}
}

@end
