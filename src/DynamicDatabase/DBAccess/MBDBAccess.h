//
//  MBDBAccess.h
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

#import <Cocoa/Cocoa.h>

@class MBElement;
@class MBElementValue;
@class MBDBDocumentEntry;
@class ResultRow;

#define DB_VERSION  @"1.0.0"

// here we have all table names of all tables we need
#define TBL_DBCONFIG_NAME           @"dbconfig"
#define TBL_ELEMENT_NAME			@"element"
#define TBL_ELEMENTVALUE_NAME		@"elementvalue"
#define TBL_VALUE_INDEX_NAME		@"valueindex"
#define TBL_DOCUMENT_META_NAME      @"documentmeta"
#define TBL_DOCUMENT_DATA_NAME      @"documentdata"

#define CONFIGENTRY_DBVERSION       @"db_version"

// some enums for Database Tables
enum DBTables {
	TableElement,
	TableElementValue,
	TableValueIndex,
    TableDocumentMeta,
    TableDocumentData,
    TableDbConfig
};

enum DBErrorCodes {
	DB_SUCCESS_FOO = 0,
	DB_ERROR_ON_OPEN_CONNECTION,
	DB_ERROR_ON_CLOSE_CONNECTION,
	DB_ERROR_ON_CONOBJECT_INIT,
	DB_ERROR_ON_QUERY_EXEC,
	DB_ERROR_NIL_RESULTARRAY,
	DB_ERROR_MORE_RESULTS_THAN_EXPECTED,
	DB_ERROR_ON_GETTING_ROWID_OF_LAST_INSERT,
	DB_ERROR_ON_CHECKING_TABLES,
	DB_ERROR_ON_CREATING_TBL_ELEMENT,
	DB_ERROR_ON_CREATING_TBL_ELEMENTVALUE,
	DB_ERROR_ON_CREATING_TBL_VALUEINDEX,
	DB_ERROR_ON_CREATING_TBL_DOCUMENTMETA,
	DB_ERROR_ON_CREATING_TBL_DOCUMENTDATA,
	DB_ERROR_ON_CREATING_TBL_DBCONFIG,
	DB_ERROR_NO_ELEMENT_BY_THIS_ID,
	DB_ERROR_NO_ELEMENTVALUE_BY_THIS_ID
};

@protocol MBDBAccessing

// object creation
+ (id)dbConnection;
+ (id)dbConnectionInMemory;
+ (id)dbConnectionWithPath:(NSString *)aPath;
+ (id)dbConnectionWithDbConnection:(id)aDbConnection;
- (id)initWithInMemoryDb;
- (id)initWithDbPath:(NSString *)aPath;
- (id)initWithDbConnection:(id)aDbConnection;
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

@protocol MBDBElementBaseAccessing

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

@interface MBDBAccess : NSObject <MBDBAccessing, MBDBElementBaseAccessing> {
	int errorCode;
	NSString *errorMessage;
    NSLock *accessLock;
    
	// first start
	BOOL firstStart;    
}

- (BOOL)firstStart;

+ (void)setSharedConnection:(MBDBAccess *)aDbConnection;
+ (MBDBAccess *)sharedConnection;

// error handling
- (int)errorCode;
- (NSString *)errorMessage;
- (void)setErrorCode:(int)aCode;
- (void)setErrorMessage:(NSString *)aErrMsg;

// MBDBAccessing
// object creation
+ (id)dbConnection;
+ (id)dbConnectionInMemory;
+ (id)dbConnectionWithPath:(NSString *)aPath;
+ (id)dbConnectionWithDbConnection:(id)aDbConnection;
- (id)initWithInMemoryDb;
- (id)initWithDbPath:(NSString *)aPath;
- (id)initWithDbConnection:(id)aDbConnection;
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

// MBDBElementBaseAccessing
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
