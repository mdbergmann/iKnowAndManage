//
//  MBDBSqlite.h
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

// headers
#import <Cocoa/Cocoa.h>
#import "MBDBAccess.h"

@class MBElement;
@class MBElementValue;
@class MBDBSqliteElement;
@class MBDBDocumentEntry;
@class MBDBSqliteDocumentEntry;
@class SqliteAccess;

@interface MBDBSqlite : MBDBAccess {
	// need low level interface from SifSqlite
	SqliteAccess *dbAccess;
	NSString *connectionPath;	
}

@end 

@interface MBDBSqlite (DBAccessing) <MBDBAccessing>

// object creation
+ (MBDBSqlite *)dbConnection;
+ (MBDBSqlite *)dbConnectionInMemory;
+ (MBDBSqlite *)dbConnectionWithPath:(NSString *)aPath;
+ (MBDBSqlite *)dbConnectionWithDbConnection:(MBDBSqlite *)aDbConnection;

- (id)initWithInMemoryDb;
- (id)initWithDbPath:(NSString *)aPath;
- (id)initWithDbConnection:(MBDBSqlite *)aDbConnection;

// connection dealing
- (void)openConnection;
- (void)closeConnection;
- (BOOL)isConnected;

// connection path
- (void)setConnectionPath:(NSString *)aPath;
- (NSString *)connectionPath;

// maintenance stuff
- (int)checkAndCreateDBTables;
- (int)updateDB;

// custom execution
- (void)executeSql:(NSString *)sql;
- (NSArray *)executeQuery:(NSString *)query;
- (void)sendBeginTransaction;
- (void)sendCommitTransaction;
- (void)vacuumDatabase;

// queries for dbconfig table
- (NSString *)configValueForKey:(NSString *)aKey;
- (BOOL)updateConfigValue:(NSString *)aString forKey:(NSString *)aKey;

@end

@interface MBDBSqlite (DBElementBaseAccessing) <MBDBElementBaseAccessing>

// --------------------
- (int)createElement;
- (int)createElementWithIdentifier:(NSString *)identifier;
- (int)createElementWithElement:(MBElement *)aElem;
- (ResultRow *)readElementById:(int)elemId;
// --------------------
- (int)createElementValue;
- (int)createElementValueWithIdentifier:(NSString *)identifier;
- (int)createElementValueWithIdentifier:(NSString *)identifier andType:(int)aType;
- (int)createElementValueWithElementValue:(MBElementValue *)aAttrib singleInstanceDocId:(int)aDocId;
- (ResultRow *)readElementValueById:(int)elemvalId;
// --------------------
- (int)createDocumentDataEntry:(NSString *)dataStr;
- (int)createDocumentEntryForInstance:(MBDBDocumentEntry *)entry;
- (ResultRow *)readDocumentEntryForDocId:(int)docId;
- (ResultRow *)readDocumentEntryForHashValue:(NSString *)hashVal;
- (NSArray *)listDocumentEntries;
- (int)scannedInstanceCountForDocId:(int)aDocId;
// --------------------
- (int)createIndexEntryWithElementValueID:(int)elemValID;
- (int)createIndexEntryWithElementValueID:(int)elemValID andIdentifier:(NSString *)identifier;
- (NSArray *)listIndexEntriesForPattern:(NSString *)pat;
- (NSArray *)listIndexEntriesForPattern:(NSString *)pat andTreeinfo:(NSString *)ti;
// --------------------
- (NSArray *)listAllElements;
- (NSArray *)listAllElementValuesWithoutData;
- (NSArray *)listElementValueDataLowerThanSize:(int)byteSize;
- (NSArray *)listChildElementsById:(int)elementId withIdentifier:(NSString *)aIdentifier;
- (NSArray *)listElementValuesByElementId:(int)elementId withIdentifier:(NSString *)aIdentifier;
- (NSArray *)listAllLevelElementValuesByElementId:(int)elementId 
							withElementIdentifier:(NSString *)aElemIdent
					   withElementValueIdentifier:(NSString *)aElemValIdent;
// ---------------------
- (NSNumber *)numberOfElementsForIdentifier:(int)anIdentifier;

@end
