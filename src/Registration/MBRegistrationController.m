//  Created by Manfred Bergmann on 25.07.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import "MBRegistrationController.h"
#import "NSData-Base64Extensions.h"
#import "MBNSDataCryptoExtension.h"
#import "MBRegistrationResource.h"
#import "MBAppInfoItem.h"
#import "MBItemBaseController.h"
#import "globals.h"
#import "NSString-Base64Extensions.h"

#define SERNUM_LENGTH 20
#define MAXTRIALDAYS 30

@interface MBRegistrationController (privateAPI)

- (void)setSerNum:(NSString *)aString;
- (void)setRegName:(NSString *)aString;
- (NSString *)serNum;
- (NSString *)regName;
- (BOOL)checkForCorrectInput;
- (BOOL)compareNumberWithResource:(NSString *)serNum;
- (void)copyRegDataFromAppInfoToRegFile;
- (void)copyRegDataFromUDToRegFile;
- (void)setFirstLaunchDate:(NSDate *)aDate;

- (void)setPathToRegFile:(NSString *)path;
- (NSString *)pathToRegFile;

- (void)saveRegistration:(NSDictionary *)regDict;
- (NSDictionary *)loadRegistration;

@end

@implementation MBRegistrationController (privateAPI)

- (void)setSerNum:(NSString *)aString {
	[aString retain];
	[serNum release];
	serNum = aString;
}

- (void)setRegName:(NSString *)aString {
	[aString retain];
	[regName release];
	regName = aString;	
}

- (NSString *)serNum {
	return serNum;
}

- (NSString *)regName {
	return regName;
}

- (void)setPathToRegFile:(NSString *)path {
	if(path != pathToRegFile) {
		[path retain];
		[pathToRegFile release];
		pathToRegFile = path;		
	}
}

- (NSString *)pathToRegFile {
	return pathToRegFile;
}

- (BOOL)checkForCorrectInput {
	BOOL ok = NO;
	
	if(([regName length] > 0) && ([serNum length] == SERNUM_LENGTH)) {
		ok = [self compareNumberWithResource:[self serNum]];
		if(ok) {
			// this serial number is ok
			[registerButton setEnabled:YES];
		}
	} else {
		[registerButton setEnabled:NO];
		ok = NO;
	}
	
	return ok;
}

/**
 \brief this method will check the given serial number against the resource
*/
- (BOOL)compareNumberWithResource:(NSString *)aSerNum {
	BOOL registered = NO;
	
	// create hash of serial number
	NSData *hashedSerNum = [(NSData *)[aSerNum dataUsingEncoding:NSASCIIStringEncoding] sha1Hash];
	// base64 encode
	//NSString *base64EncodedSerBuf = [hashedSerNum base64EncodedStringWithLineLength:0];
    NSString *base64EncodedSerBuf = [hashedSerNum encodeBase64WithNewlines:NO];
	// get rid of the last character
	NSString *base64EncodedSerNum = [base64EncodedSerBuf substringToIndex:([base64EncodedSerBuf length] - 1)]; 
	
	// get resource
	NSArray *resource = [MBRegistrationResource resource];
	NSEnumerator *iter = [resource objectEnumerator];
	NSString *num = nil;
	while((num = [iter nextObject])) {
		if([base64EncodedSerNum length] == [num length]) {
			if([base64EncodedSerNum isEqualToString:num]) {
				registered = YES;
				break;
			}
		}		
	}	
	
	return registered;
}

/**
 \brief copy the registration info from AppInfo Item to NSUserDefaults
*/
- (void)copyRegDataFromAppInfoToRegFile {
	// get AppInfo item
	MBAppInfoItem *appInfo = [itemController appInfoItem];

	regDict = [[NSMutableDictionary dictionary] retain];
	// copy
	[regDict setObject:[appInfo appMode] forKey:MBDefaultsAppModeKey];
	[regDict setObject:[appInfo regName] forKey:MBDefaultsRegNameKey];
	[regDict setObject:[appInfo serNum] forKey:MBDefaultsSerNumKey];
	
	[self saveRegistration:regDict];
}

- (void)copyRegDataFromUDToRegFile {
	regDict = [[NSMutableDictionary dictionary] retain];
	// copy
	// mode
	id object = [userDefaults objectForKey:MBDefaultsAppModeKey];
	if(!object) {
		[regDict setObject:[MBRegistrationController generateAppModeDataForMode:DemoAppMode] forKey:MBDefaultsAppModeKey];
	}
	[regDict setObject:object forKey:MBDefaultsAppModeKey];		

	// reg name
	object = [userDefaults objectForKey:MBDefaultsRegNameKey];
	if(!object) {
		[regDict setObject:MBLocaleStr(@"Unregistered") forKey:MBDefaultsRegNameKey];
	}
	[regDict setObject:object forKey:MBDefaultsRegNameKey];

	// ser num
	object = [userDefaults objectForKey:MBDefaultsSerNumKey];
	if(!object) {
		[regDict setObject:@"0" forKey:MBDefaultsSerNumKey];		
	}
	[regDict setObject:object forKey:MBDefaultsSerNumKey];

	// if we copy from user defaults, we have the first start date available
	object = [userDefaults objectForKey:MBDefaultsFLDKey];
	if(!object) {
		[self setFirstLaunchDate:[NSDate date]];
		NSString *startDate = [firstLaunchDate description];
		// write to defaults with base64 encoded
		NSData *dateData = [startDate dataUsingEncoding:NSUTF8StringEncoding];
		[regDict setObject:[[dateData encodeBase64] dataUsingEncoding:NSASCIIStringEncoding] forKey:MBDefaultsFLDKey];		
	}
	
	[self saveRegistration:regDict];
}

/**
 \brief this sets the first Launch date for the registration controller
*/
- (void)setFirstLaunchDate:(NSDate *)aDate {
	[aDate retain];
	[firstLaunchDate release];
	firstLaunchDate = aDate;
}

- (void)saveRegistration:(NSDictionary *)aDict {
	// save to disk but do binary encoding instead of XML encoding
	NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:aDict 
																   format:NSPropertyListBinaryFormat_v1_0 
														 errorDescription:nil];
	// write to disk if not nil
	if(plistData != nil) {
		[plistData writeToFile:[self pathToRegFile] atomically:YES];
	}	
}

- (NSDictionary *)loadRegistration {
	NSDictionary *dict = nil;
	
	NSFileManager *fm = [NSFileManager defaultManager];
	if([fm fileExistsAtPath:[self pathToRegFile]]) {
		// get Data From file and make propertylist out of it
		NSData *plistData = [NSData dataWithContentsOfFile:[self pathToRegFile]];
		dict = [NSPropertyListSerialization propertyListFromData:plistData 
												mutabilityOption:NSPropertyListImmutable 
														  format:nil 
												errorDescription:nil];
	}
	
	return dict;
}

@end

@implementation MBRegistrationController

/**
 \brief this is a singleton
*/
+ (MBRegistrationController *)sharedRegistration {
	static MBRegistrationController *singleton;
	
	if(singleton == nil) {
		singleton = [[MBRegistrationController alloc] init];
	}
	
	return singleton;
}

/**
\brief init is called after alloc:. some initialization work can be done here.
 No GUI elements are available here. It additinally calls the init method of superclass
 @returns initialized not nil object
 */
- (id)init {
	CocoLog(LEVEL_DEBUG,@"init of MBRegistrationController");
	
	self = [super initWithWindowNibName:@"Registration"];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"cannot alloc MBRegistrationController!");		
	} else {
		[self setRegName:@""];
		[self setSerNum:@""];
		
		// init pathToRegFile
		[self setPathToRegFile:PATH_TO_HIDDEN_REGFILE];
		
		runsModal = NO;
		retVal = RegCancel;
		
		timer = nil;
		maxTimerSecs = 10;
		
		// check for hidden reginfo file
		NSDictionary *dict = [self loadRegistration];
		if(dict != nil) {
			regDict = [[NSMutableDictionary dictionaryWithDictionary:dict] retain];
			// make sure we have a first start date in regdict, do a base64 encoding of it
            NSDate *startDate = nil;
			NSData *dateData = [regDict objectForKey:MBDefaultsFLDKey];
			if(dateData != nil) {
				// we have a date, get it
                NSString *dateEncStr = [[[NSString alloc] initWithData:dateData encoding:NSASCIIStringEncoding] autorelease];
				dateData = [dateEncStr decodeBase64];
                if(dateData && [dateData length] > 0) {
                    NSString *startDateStr = [[[NSString alloc] initWithData:dateData encoding:NSUTF8StringEncoding] autorelease];
                    // generate date
                    startDate = [NSDate dateWithString:startDateStr];
                    [self setFirstLaunchDate:startDate];                    
                }
			}
            
            if(startDate == nil) {
                startDate = [NSDate date];
				// this is first start of app, set startdate to defaults
				[self setFirstLaunchDate:startDate];
				NSString *startDateStr = [firstLaunchDate description];
				// write to regdict with base64 encoded
				dateData = [startDateStr dataUsingEncoding:NSUTF8StringEncoding];
				[regDict setObject:[[dateData encodeBase64] dataUsingEncoding:NSASCIIStringEncoding] forKey:MBDefaultsFLDKey];
				// write at once
				[self saveRegistration:regDict];                
            }
		} else {
			// regFile seems not to exist, create it
			
			// check registration data in AppInfo and copy it to NSUserDefaults if nesessary
			MBAppInfoItem *appInfo = [itemController appInfoItem];
			if([appInfo hasRegistrationInformation]) {
				// copy to UserDefaults
				[self copyRegDataFromAppInfoToRegFile];
				// delete reginfo in AppInfo
				[appInfo deleteRegistrationInfo];
			} else {
				// reginfo has to be in userDefaults
				// copy it from there
				[self copyRegDataFromUDToRegFile];
			}
		}		
	}
	
	return self;
}

/**
\brief dealloc of this class is called on closing this document
 */
- (void)dealloc {
	CocoLog(LEVEL_DEBUG,@"dealloc of MBRegistrationController");

	[self setRegName:nil];
	[self setSerNum:nil];
	[self setPathToRegFile:nil];
	
	// release reg dict
	[regDict release];
	
	// dealloc object
	[super dealloc];
}

/**
\brief the mode is converted to string, sha1 hashed and as NSData instance returned
 */
+ (NSData *)generateAppModeDataForMode:(MBAppMode)aMode {
	NSData *modData = [[[[NSNumber numberWithInt:aMode] stringValue] dataUsingEncoding:NSASCIIStringEncoding] sha1Hash];
	return modData;
}

- (MBAppMode)appMode {
	NSData *modeData = [regDict objectForKey:MBDefaultsAppModeKey];
	if([modeData isEqualToData:[MBRegistrationController generateAppModeDataForMode:RegisteredAppMode]]) {
		// registered mode
		return RegisteredAppMode;
	} else if([modeData isEqualToData:[MBRegistrationController generateAppModeDataForMode:BetaAppMode]]) {
		// beta mode
		return BetaAppMode;
	} else {
		// demo mode
		return DemoAppMode;
	}
}

- (void)resetControlsForModal:(BOOL)flag {
	// use NSUserDefaults for reg info
	// get AppInfoItem
	//MBAppInfoItem *appInfo = [itemController appInfoItem];
	
	// reset all values
	[regNameLabel setStringValue:@""];
	[nameTextField setStringValue:@""];
	[sernumTextField setStringValue:@""];
	[infoLabel setStringValue:@""];
    
//    [(NSTextFieldCell *)[sernumTextField cell] setSe
	
	// display regname
	[regNameLabel setStringValue:[regDict objectForKey:MBDefaultsRegNameKey]];
	
	// check app mode
	if([self appMode] == RegisteredAppMode) {
		// disable try and registered buttons
		[tryButton setEnabled:NO];
		[registerButton setEnabled:NO];
	} else {
		// in all other modes, enable try button and disable register button
		[tryButton setEnabled:YES];
		[registerButton setEnabled:NO];
		
		// if we are not in registered mode, show the remaining day for trying
		NSTimeInterval diff = [[NSDate date] timeIntervalSinceDate:firstLaunchDate];	// seconds
		int daysUsed = (((diff / 60) / 60) / 24);	// days
		if(daysUsed < MAXTRIALDAYS) {
			[infoLabel setStringValue:[NSString stringWithFormat:@"%@ %d", MBLocaleStr(@"TrialDaysLeft"), (MAXTRIALDAYS - daysUsed)]];
			// activate try button
			[tryButton setEnabled:YES];			
		} else {
			[infoLabel setStringValue:MBLocaleStr(@"TrialPeriodExpired")];
			// deactivate try button
			[tryButton setEnabled:NO];
		}
	}
	
#ifdef BETAVERSION 
	// hide all buttons except close and write "BETAVERSION  version"
	[regNameLabel setStringValue:@"Beta version"];
	[tryButton setHidden:YES];
	[registerButton setHidden:YES];
	[nameTextField setEditable:NO];
	[sernumTextField setEditable:NO];
#endif
}

/**
 \brief run dialog modally
*/
- (int)runModal:(BOOL)flag {
	int ret = 0;

	runsModal = flag;
	retVal = -1;	
	
	[self showWindow:nil];
	[[super window] center];
	// reset controlls
	[self resetControlsForModal:flag];
	if(flag) {
		/*
		// start timer to activate try button
		[tryButton setEnabled:NO];
		// print info text
		[infoLabel setStringValue:MBLocaleStr(@"PleaseInsertNameAndSerNum")];
		
		// start timer
		timerSecs = maxTimerSecs;
		struct timespec time;
		time.tv_sec = 0;
		time.tv_nsec = 20000000;

		session = [NSApp beginModalSessionForWindow:[super window]];
		
		int i = 0;
		while(timerSecs > 0)
		{
			if((i % 50) == 0)
			{
				timerSecs--;
				if(timerSecs == 0)
				{
					[tryButton setTitle:MBLocaleStr(@"Try")];	
					// deactivate timer and enable button
					[timer invalidate];
					[tryButton setEnabled:YES];
				}
				else
				{
					[tryButton setTitle:[NSString stringWithFormat:@"%@ - %d",MBLocaleStr(@"Try"),timerSecs]];
				}
			}
			
			// give window a bit time
			if([NSApp runModalSession:session] == NSRunStoppedResponse)
			{
				ret = retVal;
				break;
			}
			
			// sleep for 200 millis
			nanosleep(&time,NULL);
			
			i++;
		}

		// wait for button pressed
		while(retVal < 0)
		{
			if([NSApp runModalSession:session] == NSRunStoppedResponse)
			{
				break;
			}

			// sleep for 200 millis
			nanosleep(&time,NULL);
		}
		
		[NSApp endModalSession:session];
		//[NSApp runModalForWindow:[super window]];
		*/
		
		// run modal window
		[NSApp runModalForWindow:[self window]];
		
		ret = retVal;
	}
	
	return ret;
}

//--------------------------------------------------------------------
//----------- bundle delegates ---------------------------------------
//--------------------------------------------------------------------
- (void)windowDidLoad {
	CocoLog(LEVEL_DEBUG,@"windowDidLoad of MBRegistrationController");
	
	if(self != nil) {
		// fill controller
		[self resetControlsForModal:runsModal];
	}
}

- (IBAction)registerButton:(id)sender {
	// save registration in RegFile
	[regDict setObject:[MBRegistrationController generateAppModeDataForMode:RegisteredAppMode] forKey:MBDefaultsAppModeKey];
	[regDict setObject:[self regName] forKey:MBDefaultsRegNameKey];
	[regDict setObject:[self serNum] forKey:MBDefaultsSerNumKey];
	// save at once
	[self saveRegistration:regDict];
	
	// disable registered button
	[registerButton setEnabled:NO];
		
	// close window
	[[super window] close];
	
	retVal = RegOk;

	if(runsModal) {
		// deactivate modality
		[NSApp stopModal];
		runsModal = NO;
	}
    
    // change window title
    [[NSApp mainWindow] setTitle:@"iKnow & Manage"];
}

- (IBAction)tryButton:(id)sender {
	// save registration in RegFile
	[regDict setObject:[MBRegistrationController generateAppModeDataForMode:DemoAppMode] forKey:MBDefaultsAppModeKey];
	[regDict setObject:MBLocaleStr(@"Unregistered") forKey:MBDefaultsRegNameKey];
	[regDict setObject:@"0" forKey:MBDefaultsSerNumKey];
	// save at once
	[self saveRegistration:regDict];
	
	// close window
	[[super window] close];
	
	retVal = RegOk;

	if(runsModal) {
		// deactivate modality
		[NSApp stopModal];
		runsModal = NO;
	}
}

- (IBAction)cancelButton:(id)sender
{
	// do nothing than close the window
	[[super window] close];
	
	retVal = RegCancel;

	if(runsModal) {
		// deactivate modality
		//[NSApp endModalSession:session];
		[NSApp stopModal];
		runsModal = NO;
	}	
}

- (IBAction)serNumInput:(id)sender
{
	// get sernum
	[self setSerNum:[sender stringValue]];
	
	// check reg
	if([self checkForCorrectInput]) {
		[infoLabel setStringValue:MBLocaleStr(@"CorrectSerialNumberThanks")];
	} else {
		[infoLabel setStringValue:MBLocaleStr(@"WrongSerialNumber")];
	}
}

- (IBAction)nameInput:(id)sender {
	// get name
	[self setRegName:[sender stringValue]];
	
	// check reg
	[self checkForCorrectInput];
}

//--------------------------------------------------------------------
//----------- Timer action ---------------------------------------
//--------------------------------------------------------------------
- (void)tryButtonTimer {
	timerSecs--;
	if(timerSecs == 0) {
		[tryButton setTitle:MBLocaleStr(@"Try")];	
		// deactivate timer and enable button
		[timer invalidate];
		[tryButton setEnabled:YES];
	} else {
		[tryButton setTitle:[NSString stringWithFormat:@"%@ - %d", MBLocaleStr(@"Try"), timerSecs]];
	}
}

//--------------------------------------------------------------------
//----------- NSTextField delegates ---------------------------------------
//--------------------------------------------------------------------
- (void)controlTextDidChange:(NSNotification *)aNotification {
	CocoLog(LEVEL_DEBUG,@"[MBRegistrationController -textDidChange:]");

	NSTextField *object = [aNotification object];
	if(object == sernumTextField) {
		// get sernum
		[self setSerNum:[object stringValue]];
		
		// check reg
		[self checkForCorrectInput];		
	}
}

- (void)textDidEndEditing:(NSNotification *)aNotification {
	CocoLog(LEVEL_DEBUG,@"[MBRegistrationController -textDidEndEditing:]");
}

@end
