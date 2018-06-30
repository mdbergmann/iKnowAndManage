// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <CocoLogger/CocoLogger.h>
#import "MBMainMenuController.h"

@implementation MBMainMenuController

/**
\brief initialize methods gets called in first place on object creation
 */
+ (void)initialize
{
	CocoLog(LEVEL_DEBUG,@"initialize of MBMainMenuController");
}

/**
\brief init is called after alloc:. some initialization work can be done here.
 No GUI elements are available here. It additinally calls the init method of superclass
 @returns initialized not nil object
 */
- (id)init
{
	CocoLog(LEVEL_DEBUG,@"init of MBMainMenuController");
	
	self = [super init];
	if(self == nil)
	{
		CocoLog(LEVEL_ERR,@"cannot alloc MBMainMenuController!");		
	}
	else
	{
		// do some initialization work
	}
	
	return self;
}

/**
\brief dealloc of this class is called on closing this document
 */
- (void)dealloc
{
	CocoLog(LEVEL_DEBUG,@"dealloc of MBMainMenuController");
	
	// dealloc object
	[super dealloc];
}

//--------------------------------------------------------------------
//----------- Bundle delegates ---------------------------------------
//--------------------------------------------------------------------
/**
\brief gets called ig the nib file has been loaded. all gfx objacts are available now.
 */
- (void)awakeFromNib
{
	CocoLog(LEVEL_DEBUG,@"awakeFromNib of MBMainMenuController");
	
	if(self != nil)
	{
		
	}	
}

@end
