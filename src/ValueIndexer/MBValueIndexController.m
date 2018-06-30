//  Created by Manfred Bergmann on 25.07.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$
 
#import "MBValueIndexController.h"
#import <MBItemBaseController.h>
#import <MBDBSqlite.h>

@interface MBValueIndexController (privateAPI)

- (void)timeElapsed;

- (void)setRegisteredCommonItems:(NSMutableDictionary *)array;
- (NSMutableDictionary *)registeredCommonItems;

@end

@implementation MBValueIndexController (privateAPI)

/**
 \brief every minute/60 seconds, check for changed ItemValues of which the index value has to be changed
*/
- (void)timeElapsed {
	CocoLog(LEVEL_DEBUG,@"[MBValueIndexController -timeElapsed:] checking to be processed itemvalues!");
	
	NSArray *regValues = [registeredCommonItems allValues];
	
	if([regValues count] > 0) {
		// begin transaction
		[[MBDBAccess sharedConnection] sendBeginTransaction];
		
		// process all registered ItemValues
		NSEnumerator *iter = [regValues objectEnumerator];
		MBCommonItem *cItem = nil;
		while((cItem = [iter nextObject])) {
			[cItem writeValueIndexEntryWithCreate:NO];
			// remove entry
			[registeredCommonItems removeObjectForKey:[NSNumber numberWithInt:[cItem itemID]]];
		}
		
		// commit transaction
		[[MBDBAccess sharedConnection] sendCommitTransaction];
	}
}

- (void)setRegisteredCommonItems:(NSMutableDictionary *)array {
	if(array != registeredCommonItems) {
		[array retain];
		[registeredCommonItems release];
		registeredCommonItems = array;
	}
}

- (NSMutableDictionary *)registeredCommonItems {
	return registeredCommonItems;
}

@end

@implementation MBValueIndexController

+ (MBValueIndexController *)defaultController {
	static MBValueIndexController *singleton;
	
	if(singleton == nil) {
		singleton = [[MBValueIndexController alloc] init];
	}
	
	return singleton;	
}

- (id)init {
	CocoLog(LEVEL_DEBUG,@"init of MBValueIndexController");
	
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"cannot alloc MBValueIndexController!");		
	} else {
		// init things here
		[self setRegisteredCommonItems:[NSMutableDictionary dictionary]];
	}
	
	return self;	
}

/**
\brief dealloc of this class is called on closing this document
 */
- (void)dealloc {
	CocoLog(LEVEL_DEBUG,@"dealloc of MBValueIndexController");

	[self setRegisteredCommonItems:nil];
	
	// dealloc object
	[super dealloc];
}

- (void)startTimer {
	// if everything has been loaded successfully, we can start the timer.		
	// run every 15 seconds
	[NSTimer scheduledTimerWithTimeInterval:15.0 
									 target:self 
								   selector:@selector(timeElapsed) 
								   userInfo:nil 
									repeats:YES];
}

/**
 \brief if the program has been run before and the valueindex table has been created later on
 we have to run a first initialization phase where we copy the index of all available ItemValues into the valueindex table.
*/
- (void)runFirstInitialization {
	CocoLog(LEVEL_DEBUG,@"[MBValueIndexController -runFirstInitialization]");
	
	// get all registered ItemValues
	NSArray *list = [itemController listForIdentifierRange:ITEMVALUE_ID_RANGE];
	if([list count] > 0) {
		// start transaction
		MBDBAccess *dbCon = [MBDBAccess sharedConnection];
		[dbCon sendBeginTransaction];
		
		NSEnumerator *iter = [list objectEnumerator];
		MBItemValue *itemval = nil;
		while((itemval = [iter nextObject])) {
			// we do not process references. They do not hold any special data
			if([itemval identifier] != ItemValueRefID) {
				// tell itemval to write initial valueindex entry
				[itemval writeValueIndexEntryWithCreate:YES];
			}
		}
			
		// commit transaction
		[dbCon sendCommitTransaction];
	}
}

/**
 \brief register an itemvalue
 the registered itemvalues are processed whenever the timer elapses
*/
- (void)registerCommonItem:(MBCommonItem *)cItem {
	[registeredCommonItems setObject:cItem forKey:[NSNumber numberWithInt:[cItem itemID]]];
}

@end
