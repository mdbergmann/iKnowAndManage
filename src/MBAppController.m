
// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <SifSqlite/SifSqlite.h>
#import <Sparkle/Sparkle.h>
#import "MBAppController.h"
#import "globals.h"
#import "MBDatabasePrefsViewController.h"
#import "MBPreferenceController.h"
#import "MBAppInfoItem.h"
#import "MBItemBaseController.h"
#import "ColorRGBAArchiver.h"
#import "MBFormatPrefsViewController.h"
#import "MBGeneralPrefsViewController.h"
#import "MBImExportPrefsViewController.h"
#import "MBExporter.h"
#import "MBHTMLGenerator.h"
#import "MBPrivacyPrefsViewController.h"
#import "MBRegistrationController.h"
#import "MBDBAccess.h"
#import "MBDBSqlite.h"
#import "MBElementBaseController.h"
#import "MBValueIndexController.h"
#import "MBAlarmController.h"
#import "MBAboutWindowController.h"
#import "MBImporter.h"
#import "MBThreadedProgressSheetController.h"

NSString* pathForFolderType(OSType dir,short domain,BOOL createFolder) {
	OSStatus err = 0;
	FSRef folderRef;
	NSString *path = nil;
	NSURL *url = nil;
	
	err = FSFindFolder(domain,dir,createFolder,&folderRef);
	if(err == 0) {
		url = (NSURL *)CFURLCreateFromFSRef(kCFAllocatorSystemDefault, &folderRef);
		if(url) {
			path = [NSString stringWithString:[url path]];
			[url release];
		}
	}
	return path;
}


@interface MBAppController (privateAPI)

- (void)registerDefaults;
- (int)initAppSupportFolder:(NSString **)pathToAppDatabase;
- (int)initDBTables:(id)dbConnection;
- (int)checkAppKitVersion;
- (int)checkDBVersion;
- (int)checkRegistration;
- (int)checkForDbBackup;
- (void)doThreadedBackup;

@end

@implementation MBAppController (privateAPI)

/**
 \brief do backup and compression in a separate thread to not hold the application from startup
*/
- (void)doThreadedBackup {
}

/**
 \brief here we check if we have to do a backup and do it if we have to
*/
- (int)checkForDbBackup {
	int ret = INIT_SUCCESS;
	
	// get BackupActive flag from userdefaults
	BOOL active = (BOOL)[[userDefaults valueForKey:MBDefaultsBackupActiveKey] intValue];
	if(active) {
		// get interval and number of starts
		int interval = [[userDefaults valueForKey:MBDefaultsBackupIntervalKey] intValue];
		int numberOfStarts = [[userDefaults valueForKey:MBDefaultsNumberOfStartsKey] intValue];
		
		// do we have to
		if((numberOfStarts % interval) == 0) {
			BOOL success = YES;

			// you can do it
			// get backup path
			NSFileManager *fm = [NSFileManager defaultManager];
			NSString *backupPath = [userDefaults valueForKey:MBDefaultsBackupPathKey];
			if([fm fileExistsAtPath:backupPath]) {
				// delete first
				success = [fm removeItemAtPath:backupPath error:NULL];
				if(!success) {
					CocoLog(LEVEL_ERR,@"[MBAppController -checkForDbBackup] could not delete old backup file!");
					ret = UNABLE_TO_DELETE_OLD_BACKUPDB;
				}
			}
			
            if(success) {
				// get source db
				NSString *sourcePath = [userDefaults valueForKey:MBDefaultsDatabasePathKey];
				// make copy
				if((success = [fm fileExistsAtPath:sourcePath])) {
					// make copy here
					success = [fm copyItemAtPath:sourcePath toPath:backupPath error:NULL];
					if(!success) {
						CocoLog(LEVEL_ERR,@"[MBAppController -checkForDbBackup] could not copy db to backup path!");
						ret = UNABLE_TO_COPY_BACKUP_DB;					
					}
				} else {
					CocoLog(LEVEL_ERR,@"[MBAppController -checkForDbBackup] source db file does not exist!");
					ret = UNABLE_TO_COPY_BACKUP_DB;			
				}
			}
		}
	}
	
	return ret;
}

/**
\brief check AppKit version. This application supports everything from 10.3.0 on.
 If AppKit version id lower a AlertPanel will come up informing the user about that.
 He then can choose of continuing or quiting.
 */
- (int)checkAppKitVersion {
	int ret = INIT_SUCCESS;
	
	/*
	if(floor(NSAppKitVersionNumber) < NSAppKitVersionNumber10_3_5)
	{
		CocoLog(LEVEL_WARN,@"OS version is too old!");
		int answer = NSRunAlertPanel(MBLocaleStr(@"Warning"),
									 MBLocaleStr(@"OSTooOld"),
									 MBLocaleStr(@"OK"),
									 MBLocaleStr(@"Quit"),nil);			
		// check answer
		if(answer == NSAlertAlternateReturn)
		{
			CocoLog(LEVEL_INFO,@"User choosed to quit!");
			ret = UNABLE_TO_CONTINUE_WITH_OS_VERSION;
		}
	}	
	*/
	
	return ret;
}

/**
\brief Check version of db against bundle. Do db updates if needed.
 @returns INIT_SUCCESS on success
 @returns UNABLE_TO_CHECK_DB_VERSION on error, check log in this case
 */
- (int)checkDBVersion {
	// get itembase controller
	MBItemBaseController *ibc = [MBItemBaseController standardController];
	MBAppInfoItem *item = [ibc appInfoItem];
	// get db version
	NSString *dbVersion = [item appVersion];
	if(dbVersion != nil) {
		// get bundle version
		NSString *appVersion = (NSString *)BUNDLEVERSIONSTRING;
		NSLog(@"db version = %@",dbVersion);
		NSLog(@"app version = %@",appVersion);
		
		// check, if they match
		if([dbVersion isEqualToString:appVersion] == YES) {
			CocoLog(LEVEL_INFO,@"versions match!");
		} else {
			// TODO --- checkfor updates to be done on db
		}
	} else {
		CocoLog(LEVEL_ERR,@"-checkDBVersion: got a nil version string object from db, cannot check versions!");
		return UNABLE_TO_CHECK_DB_VERSION;
	}
	
	return INIT_SUCCESS;
}

- (int)checkRegistration {
	return INIT_SUCCESS;
}

- (void)registerDefaults {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	// create a dictionary
	NSMutableDictionary *defaultsDict = [NSMutableDictionary dictionary];
	
	// archive std colors
	NSString *colorAsString = nil;
	// element colors
	colorAsString = [[NSColor blackColor] archiveRGBAComponentsAsString];
	[defaultsDict setObject:colorAsString forKey:MBDefaultsItemFgColorKey];
	colorAsString = [[NSColor whiteColor] archiveRGBAComponentsAsString];
	[defaultsDict setObject:colorAsString forKey:MBDefaultsItemBgColorKey];
	// attribute colors
	colorAsString = [[NSColor blackColor] archiveRGBAComponentsAsString];
	[defaultsDict setObject:colorAsString forKey:MBDefaultsItemValueFgColorKey];
	colorAsString = [[NSColor whiteColor] archiveRGBAComponentsAsString];
	[defaultsDict setObject:colorAsString forKey:MBDefaultsItemValueBgColorKey];
	// outlineview colors
	colorAsString = [[NSColor blackColor] archiveRGBAComponentsAsString];
	[defaultsDict setObject:colorAsString forKey:MBDefaultsOutlineViewFgColorKey];
	colorAsString = [[NSColor whiteColor] archiveRGBAComponentsAsString];
	[defaultsDict setObject:colorAsString forKey:MBDefaultsOutlineViewBgColorKey];	
	// tableview colors
	colorAsString = [[NSColor blackColor] archiveRGBAComponentsAsString];
	[defaultsDict setObject:colorAsString forKey:MBDefaultsTableViewFgColorKey];
	colorAsString = [[NSColor whiteColor] archiveRGBAComponentsAsString];
	[defaultsDict setObject:colorAsString forKey:MBDefaultsTableViewBgColorKey];	
	
	// archive backup stuff
	//NSString *pathToAppSupport = pathForFolderType(kApplicationSupportFolderType,kUserDomain,true);
	//NSString *pathToAppInAppSupport = [pathToAppSupport stringByAppendingPathComponent:APPCNAME];
	// default database path
	[defaultsDict setObject:DEFAULT_DB_PATH forKey:MBDefaultsDatabasePathKey];
	[defaultsDict setObject:DEFAULT_DB_BACK_PATH forKey:MBDefaultsBackupPathKey];
	[defaultsDict setObject:[NSNumber numberWithBool:YES] forKey:MBDefaultsBackupActiveKey];
	[defaultsDict setObject:[NSNumber numberWithInt:1] forKey:MBDefaultsBackupIntervalKey];		// backup on every start
	[defaultsDict setObject:[NSNumber numberWithInt:0] forKey:MBDefaultsNumberOfStartsKey];		// starts counter
	[defaultsDict setObject:[NSNumber numberWithBool:YES] forKey:MBDefaultsBackupCompressionActiveKey];
	
	// set format defaults for number currency and date
	// number
	// TODO use userdefaults default numberformat string
	NSString *numberFormat = MBLocaleStr(@"NumberDefaultFormatString");
	[defaultsDict setObject:numberFormat forKey:MBDefaultsNumberFormatKey];
	[defaultsDict setObject:[NSNumber numberWithBool:NO] forKey:MBDefaultsNumberFormatUseThousandSeparatorKey];
	[defaultsDict setObject:[NSNumber numberWithBool:YES] forKey:MBDefaultsNumberFormatUseDecimalDigitsKey];
	[defaultsDict setObject:[NSNumber numberWithBool:NO] forKey:MBDefaultsNumberFormatUseRedNegativesKey];
	[defaultsDict setObject:[NSNumber numberWithInt:2] forKey:MBDefaultsNumberFormatNumberOfDecimalDigitsKey];
	// currency
	NSString *currencyFormat = MBLocaleStr(@"CurrencyDefaultFormatString");
	[defaultsDict setObject:currencyFormat forKey:MBDefaultsCurrencyFormatKey];
	[defaultsDict setObject:[NSNumber numberWithBool:YES] forKey:MBDefaultsCurrencyFormatUseThousandSeparatorKey];
	[defaultsDict setObject:[NSNumber numberWithBool:YES] forKey:MBDefaultsCurrencyFormatUseDecimalDigitsKey];
	[defaultsDict setObject:[NSNumber numberWithBool:YES] forKey:MBDefaultsCurrencyFormatUseRedNegativesKey];
	[defaultsDict setObject:[NSNumber numberWithInt:2] forKey:MBDefaultsCurrencyFormatNumberOfDecimalDigitsKey];
	// we use the system default currency symbol
	[defaultsDict setObject:[(NSLocale *)[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol]
					 forKey:MBDefaultsCurrencyFormatCurrencySymbolKey];
	// date
	NSString *dateFormat = MBLocaleStr(@"DateDefaultFormatString");
	// we use the system default date format
	[defaultsDict setObject:dateFormat forKey:MBDefaultsDateFormatKey];
	[defaultsDict setObject:[NSNumber numberWithBool:YES] forKey:MBDefaultsDateFormatAllowNaturalLanguageKey];
	
	// set display defaults
	[defaultsDict setObject:[NSNumber numberWithBool:NO] forKey:MBDefaultsMetalDisplayKey];
	[defaultsDict setObject:[NSNumber numberWithBool:NO] forKey:MBDefaultsShowInfoKey];
	
	// confirmations
	//[defaultsDict setObject:[NSNumber numberWithBool:YES] forKey:MBDefaultsDeleteConfirmationKey];
	//[defaultsDict setObject:[NSNumber numberWithBool:YES] forKey:MBDefaultsTrashcanDeleteConfirmationKey];
	
	// number undo steps
	[defaultsDict setObject:[NSNumber numberWithInt:10] forKey:MBDefaultsUndoStepsKey];
	
	// register default filetypes
	[defaultsDict setObject:[MBItemType defaultFileValueTypeSpec] forKey:MBDefaultsFileValueTypeSpecKey];
	
	// register import/export stuff
	[defaultsDict setObject:[NSNumber numberWithBool:YES] forKey:MBDefaultsExportLinksAsLinkKey];
	[defaultsDict setObject:[NSNumber numberWithInt:Export_IKAM] forKey:MBDefaultsExportTypeKey];
	[defaultsDict setObject:[NSNumber numberWithBool:YES] forKey:MBDefaultsImportAsLinkKey];
	[defaultsDict setObject:[NSNumber numberWithBool:YES] forKey:MBDefaultsImportRecursiveKey];
	[defaultsDict setObject:[NSNumber numberWithBool:NO] forKey:MBDefaultsImportAllAsFilesKey];
	[defaultsDict setObject:[NSNumber numberWithBool:NO] forKey:MBDefaultsImportWithAutoloadKey];
	[defaultsDict setObject:[MBHTMLGenerator defaultExportOptions] forKey:MBDefaultsHTMLExportDefaultsOptionsKey];
	 
	// register defauls search stuff
	[defaultsDict setObject:[NSNumber numberWithBool:NO] forKey:MBDefaultsSearchCaseSensitiveKey];
	[defaultsDict setObject:[NSNumber numberWithBool:NO] forKey:MBDefaultsSearchInFiledataKey];
	[defaultsDict setObject:[NSNumber numberWithBool:NO] forKey:MBDefaultsSearchIncludeExternalKey];
	//[defaultsDict setObject:[NSNumber numberWithBool:YES] forKey:MBDefaultsSearchRecursiveKey];
	[defaultsDict setObject:[NSNumber numberWithBool:NO] forKey:MBDefaultsDoRegexSearchKey];
	
	// default encryption password
	[defaultsDict setObject:@"" forKey:MBDefaultsDefaultEncryptionPasswordKey];
	
	// registration info defaults
	[defaultsDict setObject:[MBRegistrationController generateAppModeDataForMode:DemoAppMode] forKey:MBDefaultsAppModeKey];
	[defaultsDict setObject:MBLocaleStr(@"Unregistered") forKey:MBDefaultsRegNameKey];
	[defaultsDict setObject:@"0" forKey:MBDefaultsSerNumKey];	
	
	// update checks
	[defaultsDict setObject:[NSNumber numberWithBool:YES] forKey:MBDefaultsCheckUpdateEveryStartKey];
	
	// Memory Footprint
	[defaultsDict setObject:[NSNumber numberWithInt:0] forKey:MBDefaultsMemoryFootprintKey];
	
	// register the defaults
	[defaults registerDefaults:defaultsDict];
}

/**
\brief checks for Application Support folder and creates folder for App
 
 @param[out] path to AppDatabase in Application Support folder
 @returns 0 on success
 @returns UNABLE_TO_FIND_APPSUPPORT if Application Support folder could not be found
 @returns UNABLE_TO_CREATE_APPSUPPORT_FOLDER if folder for application cannot be created in appsupport
 */
- (int)initAppSupportFolder:(NSString **)pathToAppDatabase {
	// make directory for DB, in Application Support
	// so first get path to Application Default, create Application Support if needed
	NSString *pathToAppSupport = pathForFolderType(kApplicationSupportFolderType,kUserDomain,true);
	if(pathToAppSupport == nil) {
		CocoLog(LEVEL_ERR,@"Cannot get path to Application Support!");
		return UNABLE_TO_FIND_APPSUPPORT;
	}
	CocoLog(LEVEL_INFO,@"Have path to AppSupport, ok.");
	
	// add path for application path in Application Support
	NSString *pathToAppInAppSupport = [pathToAppSupport stringByAppendingPathComponent:APPCNAME];
	
	// check if dir for application exists
	NSFileManager *manager = [NSFileManager defaultManager];
	BOOL exists = [manager fileExistsAtPath:pathToAppInAppSupport];
	if(exists == NO) {
		CocoLog(LEVEL_INFO,@"path to iKnowAndManage does not exist, creating it!");
		// create iKnowAndManage folder
		BOOL success = [manager createDirectoryAtPath:pathToAppInAppSupport withIntermediateDirectories:NO attributes:nil error:NULL];
		if(success == NO) {
			CocoLog(LEVEL_ERR,@"Cannot create iKnowAndManage folder in Application Support!");
			
			return UNABLE_TO_CREATE_APPSUPPORT_FOLDER;
		}
	}
	CocoLog(LEVEL_INFO,@"Have path to App folder in AppSupport, ok.");
	
	// path to App in AppSupport should now exist, append DBName to path
	*pathToAppDatabase = [pathToAppInAppSupport stringByAppendingPathComponent:APPDBNAME];
	
	return INIT_SUCCESS;
}

/**
\brief Init db tables, means, check, if they exist and create them if not.
 @returns INIT_SUCCESS on success
 @returns UNABLE_TO_INIT_TABLES on error, check log in this case
 */
- (int)initDBTables:(id)dbConnection {
	if(dbConnection != nil) {
		int stat = [dbConnection checkAndCreateDBTables];
		if(stat != DB_SUCCESS) {
			CocoLog(LEVEL_ERR,@"initDBTables: something went wrong on table init, please consult the log file for more details!");
			return UNABLE_TO_INIT_TABLES;
		} else {
			CocoLog(LEVEL_INFO,@"initDBTables: successfully initialized tables!");
		}
	} else {
		CocoLog(LEVEL_ERR,@"-initDBTables: dbCon is nil, cannot proceed!");
		return UNABLE_TO_INIT_TABLES;
	}
				
	return INIT_SUCCESS;
}

@end


@implementation MBAppController

/**
\brief init is called after alloc:. some initialization work can be done here.
 No GUI elements are available here. It additinally calls the init method of superclass
 @returns initialized not nil object
 */
- (id)init {
	int stat = 0;

	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"cannot alloc MBAppController!");		
	} else {
		// we cannot setup the application in this case
		NSApplication *app = [NSApplication sharedApplication];

		// register user defaults
		[self registerDefaults];
		
        // update types array
        [userDefaults setObject:[MBItemType defaultFileValueTypeSpec] forKey:MBDefaultsFileValueTypeSpecKey];        
        [userDefaults synchronize];
        
		// check OS Version number
		stat = [self checkAppKitVersion];
		if(stat == UNABLE_TO_CONTINUE_WITH_OS_VERSION)
		{
			[app terminate:nil];
		}
	
		// check for db in userDefaults
		NSString *pathToAppDatabase = nil;
		NSString *dbPath = [userDefaults valueForKey:MBDefaultsDatabasePathKey];
		
		// check, if this exist
		NSFileManager *fm = [NSFileManager defaultManager];
		BOOL exists = [fm fileExistsAtPath:dbPath];
		if(exists == NO) {
			// then create default
			// check for Application Support Folder and get path to app database in Application Support
			stat = [self initAppSupportFolder:&pathToAppDatabase];
			if(stat == UNABLE_TO_CREATE_APPSUPPORT_FOLDER) {
				CocoLog(LEVEL_ERR,@"Error on creating Application Support folder!");
				NSAlert *alert = [NSAlert alertWithMessageText:MBLocaleStr(@"Error")
												 defaultButton:MBLocaleStr(@"OK") 
											   alternateButton:nil 
												   otherButton:nil 
									 informativeTextWithFormat:MBLocaleStr(@"DBInitError")];
				[alert runModal];
				[app terminate:nil];
			} else if(stat == UNABLE_TO_FIND_APPSUPPORT) {
				CocoLog(LEVEL_ERR,@"Error on creating Application Support folder!");
				NSAlert *alert = [NSAlert alertWithMessageText:MBLocaleStr(@"Error")
												 defaultButton:MBLocaleStr(@"OK") 
											   alternateButton:nil 
												   otherButton:nil 
									 informativeTextWithFormat:MBLocaleStr(@"DBInitError")];
				[alert runModal];
				[app terminate:nil];
			} else if(pathToAppDatabase == nil) {
				// error, have no db path
				CocoLog(LEVEL_ERR,@"Error, -initAppSupportFolder returned SUCCESS, but have no path to database!");
				NSAlert *alert = [NSAlert alertWithMessageText:MBLocaleStr(@"Error")
												 defaultButton:MBLocaleStr(@"OK") 
											   alternateButton:nil 
												   otherButton:nil 
									 informativeTextWithFormat:MBLocaleStr(@"DBInitError")];
				[alert runModal];
				[app terminate:nil];
			} else {
				// no error
				CocoLog(LEVEL_DEBUG,@"Success getting path to database!");
			}
		} else {
			// TODO --- check database version
			pathToAppDatabase = dbPath;
		}

        // setup tmp dir
		// check for ikam folder in tmp
		NSString *tempF = TMPFOLDER;
		BOOL isDir;
		if([fm fileExistsAtPath:tempF isDirectory:&isDir] == YES) {
			// delete this dir and create it new, normally it should be deleted on application termination
			BOOL success = [fm removeItemAtPath:tempF error:NULL];
			if(success == NO) {
				CocoLog(LEVEL_WARN,@"cannot delete tmp dir!");
			}
		}
		// check again
		if([fm fileExistsAtPath:tempF isDirectory:&isDir] == NO) {
			// create it
			BOOL success = [fm createDirectoryAtPath:tempF withIntermediateDirectories:NO attributes:nil error:NULL];
			if(success == NO) {
				CocoLog(LEVEL_ERR,@"could not create tmp folder!");
				NSAlert *alert = [NSAlert alertWithMessageText:MBLocaleStr(@"Error")
												 defaultButton:MBLocaleStr(@"OK") 
											   alternateButton:nil 
												   otherButton:nil 
									 informativeTextWithFormat:MBLocaleStr(@"ErrorCreatingTmpFolder")];
				[alert runModal];
				[app terminate:nil];				
			}
		}
        
		// Application Support Folder checked
		// check some things here
		// init sharedDbConnection Instance for main thread
		MBDBAccess *dbCon = [MBDBSqlite sharedConnection];
		// set path and connect
		[dbCon setConnectionPath:pathToAppDatabase];
		[dbCon openConnection];
		if(dbCon == nil) {
			CocoLog(LEVEL_ERR,@"have received a nil dbCon!");
			CocoLog(LEVEL_ERR,@"Error on initializing and opening DB!");
			NSAlert *alert = [NSAlert alertWithMessageText:MBLocaleStr(@"Error")
											 defaultButton:MBLocaleStr(@"OK") 
										   alternateButton:nil 
											   otherButton:nil 
								 informativeTextWithFormat:MBLocaleStr(@"DBInitError")];
			[alert runModal];
			[app terminate:nil];
		}
		// check,if we are connected
		if([dbCon isConnected] == NO) {
			CocoLog(LEVEL_ERR,@"[MBAppController -init]: db connection is not connected, cannot go ahead!");
			NSAlert *alert = [NSAlert alertWithMessageText:MBLocaleStr(@"Error")
											 defaultButton:MBLocaleStr(@"OK") 
										   alternateButton:nil 
											   otherButton:nil 
								 informativeTextWithFormat:MBLocaleStr(@"DBInitError")];
			[alert runModal];
			[app terminate:nil];
		}
		// check further errors
		if([dbCon errorCode] != DB_SUCCESS) {
			CocoLog(LEVEL_ERR, @"%@", [dbCon errorMessage]);
		} else {
			// do table initialization here
			stat = [self initDBTables:dbCon];
			if(stat == UNABLE_TO_INIT_TABLES) {
				CocoLog(LEVEL_ERR,@"Error on initializing DB Tables!");
				NSAlert *alert = [NSAlert alertWithMessageText:MBLocaleStr(@"Error")
												 defaultButton:MBLocaleStr(@"OK") 
											   alternateButton:nil 
												   otherButton:nil 
									 informativeTextWithFormat:MBLocaleStr(@"DBInitTablesError")];
				[alert runModal]; 
				[app terminate:nil];
			} else {
				CocoLog(LEVEL_INFO,@"success initializing db tables!");
				
			}
		}
				
		// db is initialized, we can now initialize the ElementBaseController
		// build the complete Element tree
		// set default memory footprint
		int val = [[userDefaults objectForKey:MBDefaultsMemoryFootprintKey] intValue];
		int memFoot = -1;
		switch(val) {
			case 0:
				memFoot = SmallMemFootprintType;
				break;
			case 1:
				memFoot = MediumMemFootprintType;
				break;
			case 2:
				memFoot = LargeMemFootprintType;
				break;
		}
        MBElementBaseController *elemBase = elementController;
        [elemBase setDocStoragePath:DEFAULT_DOC_STORE_PATH];
		[elemBase setMemoryFootprint:memFoot];
		[elemBase buildElementBase];
		
		// init the upper level Controller "ItemBase" to initialize
		// all needed elements, check, registration and stuff
		MBItemBaseController *ibc = [MBItemBaseController standardController];
		[ibc buildItemBase];
		stat = [ibc checkAndPrepareSystemItems];
		if(stat != 0) {
			CocoLog(LEVEL_ERR,@"error on checking System Items!");
			NSAlert *alert = [NSAlert alertWithMessageText:MBLocaleStr(@"Error")
											 defaultButton:MBLocaleStr(@"OK") 
										   alternateButton:nil 
											   otherButton:nil 
								 informativeTextWithFormat:MBLocaleStr(@"InitSystemItems")];
			[alert runModal];
			[app terminate:nil];
		}

		// after initializing the ItemBaseController, check if we have to run a first initialization of the valueindex
		MBValueIndexController *indexController = [MBValueIndexController defaultController];
		// get the AppInfoItem and make sure
		MBAppInfoItem *appInfo = [ibc appInfoItem];
		if([appInfo indexInitiated] == NO) {
			// run
			[indexController runFirstInitialization];
			// set initialized to appinfo
			[appInfo setIndexInitiated:YES];
		}
		// start timer now
		[indexController startTimer];
		        
		/*
		// check for backup here when Database has been set up
		stat = [self checkForDbBackup];
		if(stat != 0)
		{
			CocoLog(LEVEL_ERR,@"[MBAppController -init] could not make backup of db!");
			NSAlert *alert = [NSAlert alertWithMessageText:MBLocaleStr(@"Error")
											 defaultButton:MBLocaleStr(@"Yes") 
										   alternateButton:MBLocaleStr(@"No")
											   otherButton:nil 
								 informativeTextWithFormat:MBLocaleStr(@"UnableToMakeBackupOfDB")];
			int result = [alert runModal];
			if(result == NSAlertAlternateReturn)
			{
				[app terminate:nil];
			}
		}	
		 */
				
		// prepare registration controller
		regController = [MBRegistrationController sharedRegistration];
		// check mode
		if([regController appMode] != RegisteredAppMode) {
			// run reg window modal
			int ret = [regController runModal:YES];
			if(ret == RegCancel) {
				// the user has choosen to terminate
				[app terminate:nil];				
			}
			
			// alter window title
			[[NSApp mainWindow] setTitle:[NSString stringWithFormat:@"%@ - unregistered",[[NSApp mainWindow] title]]];
		}

		// init Alarm checker
		[MBAlarmController defaultController];        
	}
    
	return self;
}

/**
\brief dealloc of this class is called on closing this document
 */
- (void)dealloc {
	// release preference controller
	[preferenceController release];
	
	// release aboutWindowController
	[aboutWindowController release];
	
	// dealloc object
	[super dealloc];
}

//-------------------------------------------------------------------
// NSApplication delegate method
//-------------------------------------------------------------------
- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames {
	MBImporter *importer = [MBImporter defaultImporter];	
	[importer fileValueImport:filenames toItem:nil];
	[sender replyToOpenOrPrint:NSApplicationDelegateReplySuccess];
}


//-------------------------------------------------------------------
// show PreferencePanel (this method also is used for delegate methods from interface copntroller to open prefs panel)
//-------------------------------------------------------------------
- (IBAction)showPreferenceSheet:(id)sender {
	// check if preference controller already exists
	if(preferenceController == nil) {
		// create it
		preferenceController = [[MBPreferenceController alloc] init];
		// set delegate of preferenceController
		[preferenceController setDelegate:self];
		// load PreferenceSheet, so we have the views we need
		BOOL success = [NSBundle loadNibNamed:PREFERENCE_CONTROLLER_NIB_NAME owner:preferenceController];
		if(success == NO) {
			CocoLog(LEVEL_ERR,@"cannot load Preferences.nib!");
		}		
	}
	
	// show panel
	[preferenceController beginSheetForWindow:nil];
}

//-------------------------------------------------------------------
// show Registration Window
//-------------------------------------------------------------------
- (IBAction)showRegWindow:(id)sender {
	// get shared reg controller
	regController = [MBRegistrationController sharedRegistration];
	// show window
	[regController runModal:NO];
}

//-------------------------------------------------------------------
// show AboutWindow
//-------------------------------------------------------------------
- (IBAction)showAboutWindow:(id)sender {
	if(aboutWindowController == nil) {
		// create it
		aboutWindowController = [[MBAboutWindowController alloc] init];
	}
	
	// show window
	[aboutWindowController showWindow:self];
}

//--------------------------------------------------------------------
//---------------- KVO observers --------------------------
//--------------------------------------------------------------------
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	// check for keyPath
	if([keyPath isEqualToString:MBDefaultsCheckUpdateEveryStartKey] == YES) {
         // get new value
         id newValue = [change valueForKey:NSKeyValueChangeNewKey];
         if(newValue != nil) {
             [[SUUpdater sharedUpdater] setAutomaticallyChecksForUpdates:(BOOL)[newValue intValue]];
         }
	}
}

//--------------------------------------------------------------------
//----------- app delegates ---------------------------------------
//--------------------------------------------------------------------
/**
 \brief gets called if the nib file has been loaded. all gfx objacts are available now.
*/
- (void)awakeFromNib {
	if(self != nil) {
		// load FormatSetterNib, so we have the views we need
		MBThreadedProgressSheetController *pc = [MBThreadedProgressSheetController standardProgressSheetController];
		BOOL success = [NSBundle loadNibNamed:THREADED_PROGRESS_SHEET_NIB_NAME owner:pc];
		if(success == YES) {
			[pc setIsThreaded:[NSNumber numberWithBool:YES]];
		} else {
			CocoLog(LEVEL_ERR,@"cannot load ThreadedProgressSheetControllerNib!");
		}
		
		// register some NSUserDefaults changes
		[[NSUserDefaults standardUserDefaults] addObserver:self 
												forKeyPath:MBDefaultsCheckUpdateEveryStartKey
												   options:NSKeyValueObservingOptionNew context:nil];

		// send Notification that db has been initialized
		MBSendNotifyDbInitialized(nil);		
	}
}

/**
 \brief is called when application loading is nearly finished
*/
- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
}

/**
\brief is called when application loading is finished
 */
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// sent notification that app is finished with initializing
	MBSendNotifyAppInitialized(nil);
	
	// increment numberOfStarts
	NSNumber *numberOfStarts = [userDefaults valueForKey:MBDefaultsNumberOfStartsKey];
	[userDefaults setObject:[NSNumber numberWithInt:[numberOfStarts intValue]+1] forKey:MBDefaultsNumberOfStartsKey];
	
	// write date of last start (this)
	MBAppInfoItem *appInfo = [itemController appInfoItem];
	[appInfo setDateLastStart:[NSDate date]];
}

/**
\brief is called when application is terminated
 */
- (NSApplicationTerminateReply)applicationShouldTerminate:(id)sender {
	// send appWillTerminate notification
	MBSendNotifyAppWillTerminate(nil);
	
	// get db connection and save before kicking up
	MBDBAccess *dbCon = [MBDBSqlite sharedConnection];
	if(dbCon != nil) {
		if([dbCon isConnected] == YES) {
			// send BEGIN transaction command to speed things up
			// TODO --- activate for speed improvements
			//[dbCon sendCommitTransaction];	
		}
	}

	// delete tmpdir
	// setup tmp dir
	NSFileManager *fm = [NSFileManager defaultManager];
	// check for ikam folder in tmp
	NSString *tempF = TMPFOLDER;
	BOOL isDir;
	if([fm fileExistsAtPath:tempF isDirectory:&isDir] == YES) {
		// delete this dir and create it new, normally it should be deleted on application termination
		BOOL success = [fm removeItemAtPath:tempF error:NULL];
		if(success == NO) {
			CocoLog(LEVEL_WARN,@"cannot delete tmp dir!");
		}
	}	
	
	// write date of last stop
	MBAppInfoItem *appInfo = [itemController appInfoItem];
	[appInfo setDateLastStop:[NSDate date]];
	
	// close db connection
	[dbCon closeConnection];
	
	// close logger
	[CocoLogger closeLogger];
	
	// we want to terminate NOW
	return NSTerminateNow;
}

@end
