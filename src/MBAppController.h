/* MBAppController */

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>

@class MBInterfaceController;
@class MBPreferenceController;
@class MBAboutWindowController;

enum MBFileAccessErrorCodes
{
	INIT_SUCCESS = 0,
	UNABLE_TO_FIND_APPSUPPORT,				// Cannot get path to Application Support
	UNABLE_TO_CREATE_APPSUPPORT_FOLDER,		// Cannot create iKnowAndManage folder in Application Support
	UNABLE_TO_CONTINUE_WITH_OS_VERSION,		// if os version is too old
	UNABLE_TO_INIT_DB,
	UNABLE_TO_INIT_TABLES,
	UNABLE_TO_INIT_SYSTEM_ELEMENTS,
	UNABLE_TO_CHECK_DB_VERSION,
	UNABLE_TO_CHECK_REGISTRATION,
	UNABLE_TO_DELETE_OLD_BACKUPDB,
	UNABLE_TO_COPY_BACKUP_DB,
	BETA_PHASE_ENDED
};
 
@interface MBAppController : NSObject
{
	IBOutlet MBInterfaceController *interfaceController;
	
	// our preference controller
	MBPreferenceController *preferenceController;
	// our about controller
	MBAboutWindowController *aboutWindowController;
}

// NSApplication delegate methods
- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames;

- (IBAction)showPreferenceSheet:(id)sender;
- (IBAction)showAboutWindow:(id)sender;
- (IBAction)showRegWindow:(id)sender;

@end
