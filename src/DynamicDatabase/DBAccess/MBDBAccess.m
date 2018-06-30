//
//  MBDBAccess.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 26.05.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import "MBDBAccess.h"
#import "MBDBSqlite.h"

@implementation MBDBAccess

static MBDBAccess *sharedDBSingleton;
+ (void)setSharedConnection:(MBDBAccess *)aDbConnection {
    if(sharedDBSingleton != aDbConnection) {
        [aDbConnection retain];
        [sharedDBSingleton release];
        sharedDBSingleton = aDbConnection;
    }
}

/**
 Opens access to a MBDBAccess object, no path is set and due no db is opened and not connected.
 @return singleton initialized connection. it is not connected.
 @return nil on error
 */
+ (MBDBAccess *)sharedConnection {    
	if(sharedDBSingleton == nil) {
		// alloc new object
		[self setSharedConnection:[MBDBSqlite dbConnection]];
	}
	
	return sharedDBSingleton;
}

- (id)init {
    self = [super init];
    if(self) {
        accessLock = [[NSLock alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    [accessLock release];
    [errorMessage release];
    [super dealloc];
}

- (void)setErrorCode:(int)aCode {
	errorCode = aCode;
}

- (void)setErrorMessage:(NSString *)aErrMsg {
	aErrMsg = [aErrMsg copy];
	[errorMessage release];
	errorMessage = aErrMsg;	
}

- (int)errorCode {
	return errorCode;
}

- (NSString *)errorMessage {
	return errorMessage;
}

- (BOOL)firstStart {
	return firstStart;
}

#pragma mark - MBDBAccessing

+ (id)dbConnection {return nil;}
+ (id)dbConnectionInMemory {return nil;}
+ (id)dbConnectionWithPath:(NSString *)aPath {return nil;}
+ (id)dbConnectionWithDbConnection:(id)aDbConnection {return nil;}
- (id)initWithInMemoryDb {return nil;}
- (id)initWithDbPath:(NSString *)aPath {return nil;}
- (id)initWithDbConnection:(id)aDbConnection {return nil;}

- (void)openConnection {}
- (void)closeConnection {}
- (BOOL)isConnected {return NO;}

- (void)setConnectionPath:(NSString *)aPath {}
- (NSString *)connectionPath {return nil;}

- (int)checkAndCreateDBTables {return -1;}
- (int)updateDB {return -1;}

- (void)executeSql:(NSString *)sql {}
- (NSArray *)executeQuery:(NSString *)query {return nil;}
- (void)sendBeginTransaction {}
- (void)sendCommitTransaction {}
- (void)vacuumDatabase {}

- (NSString *)configValueForKey:(NSString *)aKey {return nil;}
- (BOOL)updateConfigValue:(NSString *)aString forKey:(NSString *)aKey {return NO;}

#pragma mark - MBDBElementBaseAccessing

- (int)createElement {return -1;}
- (int)createElementWithIdentifier:(NSString *)identifier {return -1;}
- (int)createElementWithElement:(MBElement *)aElem {return -1;}
- (ResultRow *)readElementById:(int)elemId {return nil;}
// --------------------
- (int)createElementValue {return -1;}
- (int)createElementValueWithIdentifier:(NSString *)identifier {return -1;}
- (int)createElementValueWithIdentifier:(NSString *)identifier andType:(int)aType {return -1;}
- (int)createElementValueWithElementValue:(MBElementValue *)aAttrib singleInstanceDocId:(int)aDocId {return -1;}
- (ResultRow *)readElementValueById:(int)elemvalId {return nil;}
// --------------------
- (int)createDocumentDataEntry:(NSString *)dataStr {return -1;}
- (int)createDocumentEntryForInstance:(MBDBDocumentEntry *)entry {return -1;}
- (ResultRow *)readDocumentEntryForDocId:(int)docId {return nil;}
- (ResultRow *)readDocumentEntryForHashValue:(NSString *)hashVal {return nil;}
- (NSArray *)listDocumentEntries {return nil;}
- (int)scannedInstanceCountForDocId:(int)aDocId {return -1;}
// --------------------
- (int)createIndexEntryWithElementValueID:(int)elemValID {return -1;}
- (int)createIndexEntryWithElementValueID:(int)elemValID andIdentifier:(NSString *)identifier {return -1;}
- (NSArray *)listIndexEntriesForPattern:(NSString *)pat {return nil;}
- (NSArray *)listIndexEntriesForPattern:(NSString *)pat andTreeinfo:(NSString *)ti {return nil;}
// --------------------
- (NSArray *)listAllElements {return nil;}
- (NSArray *)listAllElementValuesWithoutData {return nil;}
- (NSArray *)listElementValueDataLowerThanSize:(int)byteSize {return nil;}
- (NSArray *)listChildElementsById:(int)elementId withIdentifier:(NSString *)aIdentifier {return nil;}
- (NSArray *)listElementValuesByElementId:(int)elementId withIdentifier:(NSString *)aIdentifier {return nil;}
- (NSArray *)listAllLevelElementValuesByElementId:(int)elementId 
							withElementIdentifier:(NSString *)aElemIdent
					   withElementValueIdentifier:(NSString *)aElemValIdent {return nil;}
// ---------------------
- (NSNumber *)numberOfElementsForIdentifier:(int)anIdentifier {return nil;}

@end
