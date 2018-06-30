//
//  MBDBSqlite.m
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

#import <SifSqlite/SifSqlite.h>
#import <CocoLogger/CocoLogger.h>
#import "MBDBAccess.h"
#import "MBDBSqlite.h"
#import "MBElement.h"
#import "MBBaseDefinitions.h"
#import "MBElementValue.h"
#import "NSData-Base64Extensions.h"
#import "MBDBDocumentEntry.h"
#import "MBDBSqliteSql.h"

// -------------------------------------------------------------
// ------------------- private methods ------------------
// -------------------------------------------------------------
@interface MBDBSqlite (privateAPI)

- (int)createAllDBTables;
- (int)createDBTableById:(int)tableId;
- (BOOL)checkForExistenceOfTableInResult:(NSArray *)queryResult tableName:(NSString *)aName;

// private getter and setter
- (void)setDbAccess:(SqliteAccess *)aDbAccess;
- (SqliteAccess *)dbAccess;

@end

//-----------------------------------------------------
// ---------- private method implementations ----------
//-----------------------------------------------------
@implementation MBDBSqlite (privateAPI)

- (void)setDbAccess:(SqliteAccess *)aDbAccess {
	[aDbAccess retain];
	[dbAccess release];
	dbAccess = aDbAccess;
}

- (SqliteAccess *)dbAccess {
	return dbAccess;
}

/**
\brief creates all needed DB tables
 
 Calls -createDBTableById: for every table we need
 @returns: DBErrorCodes
 */
- (int)createAllDBTables {
	int stat = 0;

	// create all db tables
	// element
	stat = [self createDBTableById:TableElement];
	if(stat != DB_SUCCESS) {
		return stat;
	}
	
	// elementvalue
	stat = [self createDBTableById:TableElementValue];
	if(stat != DB_SUCCESS) {
		return stat;
	}

	// valueindex
	stat = [self createDBTableById:TableValueIndex];
	if(stat != DB_SUCCESS) {
		return stat;
	}
	
	// document meta
	stat = [self createDBTableById:TableDocumentMeta];
	if(stat != DB_SUCCESS) {
		return stat;
	}

    // document data
	stat = [self createDBTableById:TableDocumentData];
	if(stat != DB_SUCCESS) {
		return stat;
	}
    
    // dbconfig
	stat = [self createDBTableById:TableDbConfig];
	if(stat != DB_SUCCESS) {
		return stat;
	}

	return DB_SUCCESS;
}

/**
 \brief creates a table by giving the tyble id, see enum DBTables
 @returns: DBErrorCodes, if error, the table thast has been created will be deleted
 */
- (int)createDBTableById:(int)tableId {
	int ret = DB_SUCCESS;
	NSString *query = nil;
	NSMutableString *errStr = [NSMutableString stringWithString:@"Error on creating table: "];
	// use a switch for checking which tbl to create
	switch(tableId) {
		// each case block sets an error message and a return value if an error occurs
		case TableElement:
			query = @CREATE_TABLE_ELEMENT;
			[errStr appendString:TBL_ELEMENT_NAME];
			ret = DB_ERROR_ON_CREATING_TBL_ELEMENT;
			break;
		case TableElementValue:
			query = @CREATE_TABLE_ELEMENTVALUE;
			[errStr appendString:TBL_ELEMENTVALUE_NAME];
			ret = DB_ERROR_ON_CREATING_TBL_ELEMENTVALUE;
			break;
		case TableValueIndex:
			query = @CREATE_TABLE_VALUEINDEX;
			[errStr appendString:TBL_VALUE_INDEX_NAME];
			ret = DB_ERROR_ON_CREATING_TBL_VALUEINDEX;
			break;
		case TableDocumentMeta:
			query = @CREATE_TABLE_DOCUMENTMETA;
			[errStr appendString:TBL_DOCUMENT_META_NAME];
			ret = DB_ERROR_ON_CREATING_TBL_DOCUMENTMETA;
			break;
		case TableDocumentData:
			query = @CREATE_TABLE_DOCUMENTDATA;
			[errStr appendString:TBL_DOCUMENT_DATA_NAME];
			ret = DB_ERROR_ON_CREATING_TBL_DOCUMENTDATA;
            break;
		case TableDbConfig:
			query = @CREATE_TABLE_DBCONFIG;
			[errStr appendString:TBL_DBCONFIG_NAME];
			ret = DB_ERROR_ON_CREATING_TBL_DBCONFIG;
            break;
        default:break;
    }
	
	// execute, we expect no result
	[dbAccess executeSql:query];
	if([dbAccess errorCodeOfLastAction] != DB_SUCCESS) {
		NSString *errMsg = [dbAccess errorMessageOfLastAction];
		if(errMsg != nil) {
			CocoLog(LEVEL_ERR, @"%@", errMsg);
		}
		
		return ret;
	}
	
	return DB_SUCCESS;
}

/**
\brief check, if a specific table name exists in the database
 */
- (BOOL)checkForExistenceOfTableInResult:(NSArray *)queryResult tableName:(NSString *)aName {
	BOOL exists = NO;
	
	if(queryResult != nil) {
		// we have a result, now check for each table
		// first appinfo table
		NSEnumerator *iter = [queryResult objectEnumerator];
		ResultRow *row = nil;
		while((row = [iter nextObject]))
		{
            RowColumn *col = [row findColumnForName:@"tbl_name"];
            if(col != nil && [[col value] isEqualToString:aName]) {
                exists = YES;
                // we can kick up here
                break;
            }
		}
	} else {
		CocoLog(LEVEL_ERR, @"have nil queryResult array!");
	}
	
	return exists;
}

@end

//-----------------------------------------------------
// -------------- Class implementation ----------------
//-----------------------------------------------------
@implementation MBDBSqlite

- (id)init {
	CocoLog(LEVEL_DEBUG,@"init of MBDBSqlite");
	
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"cannot alloc MBDBSqlite!");		
	} else {
		firstStart = YES;
		
		// do some initialization work
		// set nil to pathToDB
		[self setConnectionPath:@""];
		[self setErrorMessage:@""];
		[self setErrorCode:DB_SUCCESS];
		
		// init dbAccess with nil
		dbAccess = [[SqliteAccess alloc] init];
		if(dbAccess == nil) {
			[self setErrorMessage:@"could not instantiate connection object!"];
			[self setErrorCode:DB_ERROR_ON_CONOBJECT_INIT];
		} else {
			if([dbAccess errorCodeOfLastAction] != DB_SUCCESS) {
				[self setErrorCode:DB_ERROR_ON_CONOBJECT_INIT];
				[self setErrorMessage:[dbAccess errorMessageOfLastAction]];
			}
		}
	}
	
	return self;	
}

- (void)dealloc {
	CocoLog(LEVEL_DEBUG,@"dealloc of MBDBSqlite");
	
	// close db if not done already
	[self closeConnection];
	[self setDbAccess:nil];	
	[self setConnectionPath:nil];	
	[self setErrorMessage:@""];
	[self setErrorCode:DB_SUCCESS];
	
	// dealloc object
	[super dealloc];
}

- (BOOL)firstStart {
	return firstStart;
}

@end

//-----------------------------------------------------
// -------------- db accessing category ----------------
//-----------------------------------------------------
@implementation MBDBSqlite (DBAccessing)

+ (MBDBSqlite *)dbConnection {
	return [[[MBDBSqlite alloc] init] autorelease];
}

+ (MBDBSqlite *)dbConnectionInMemory {
	return [[[MBDBSqlite alloc] initWithInMemoryDb] autorelease];
}

+ (MBDBSqlite *)dbConnectionWithPath:(NSString *)aPath {
    return [[[MBDBSqlite alloc] initWithDbPath:aPath] autorelease];
}

/** 
\brief creates a autoreleased dbConnection object with the attributes of a given dbConnection instance
The new dbConnection must not be released.
It has to be connected bevor using it.
*/
+ (MBDBSqlite *)dbConnectionWithDbConnection:(MBDBSqlite *)aDbConnection {
	return [[[MBDBSqlite alloc] initWithDbConnection:aDbConnection] autorelease];
}

/**
 Init object with given path. it is not connected. this has to be done separately
 @param aPath path to db
 */
- (id)initWithInMemoryDb {
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"cannot alloc MBDBSqlite!");
	} else {
		// do some initialization work
		// set nil to pathToDB
		[self setErrorMessage:@""];
		[self setErrorCode:DB_SUCCESS];
		
		// init dbAccess with nil
		dbAccess = [[SqliteAccess alloc] initInMemory];
		if(dbAccess == nil) {
			[self setErrorMessage:@"could not instantiate connection object!"];
			[self setErrorCode:DB_ERROR_ON_CONOBJECT_INIT];
		} else {
			if([dbAccess errorCodeOfLastAction] != DB_SUCCESS) {
				[self setErrorCode:DB_ERROR_ON_CONOBJECT_INIT];
				[self setErrorMessage:[dbAccess errorMessageOfLastAction]];
			}
			[self setConnectionPath:[dbAccess connectionPath]];
		}
	}
	
	return self;	
}

/**
 Create object with given path to db
 */
- (id)initWithDbPath:(NSString *)aPath {
    self = [self init];
    if(self) {
        [self setConnectionPath:aPath];
    }
    
    return self;
}

/**
 Create a new dbConnection object with attributes of a given dbConnection instance
 */
- (id)initWithDbConnection:(MBDBSqlite *)aDbConnection {
	CocoLog(LEVEL_DEBUG,@"init of MBDBSqlite");
	
	self = [self init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"cannot alloc MBDBSqlite!");		
	} else {
		firstStart = NO;
		
		// copy connection paqth from given connection
		[self setConnectionPath:[aDbConnection connectionPath]];
		[self setErrorMessage:@""];
		[self setErrorCode:DB_SUCCESS];
	}
	
	return self;	
}

- (void)openConnection {
	int ret = DB_SUCCESS;
	[self setErrorMessage:@""];
	
	// check, if the connection is not still open
	if(![dbAccess isConnected]) {
		// connect
		[dbAccess openConnection];
		if([dbAccess errorCodeOfLastAction] != DB_SUCCESS) {
			CocoLog(LEVEL_ERR, @"%@", [dbAccess errorMessageOfLastAction]);
			ret = DB_ERROR_ON_OPEN_CONNECTION;
			
			// forward error message
			[self setErrorMessage:[dbAccess errorMessageOfLastAction]];
		}
	} else {
		CocoLog(LEVEL_WARN,@"db connection already opened!");
	}
	
	[self setErrorCode:ret];
}

// closes the database
- (void)closeConnection {
	int ret = DB_SUCCESS;
	[self setErrorMessage:@""];
	
	// check, if we are connected
	if([dbAccess isConnected]) {
		// connect
		[dbAccess closeConnection];
		if([dbAccess errorCodeOfLastAction] != DB_SUCCESS) {
			CocoLog(LEVEL_ERR, @"%@", [dbAccess errorMessageOfLastAction]);
			ret = DB_ERROR_ON_CLOSE_CONNECTION;

			// forward error message
			[self setErrorMessage:[dbAccess errorMessageOfLastAction]];
		}		
	}
	
	[self setErrorCode:ret];
}

- (BOOL)isConnected {
	BOOL ret = NO;
	if(dbAccess != nil) {
		ret = [dbAccess isConnected];
	} else {
		ret = NO;
	}
	
	return ret;
}

/**
 Set connection path
 */
- (void)setConnectionPath:(NSString *)aPath {
	aPath = [aPath copy];
	[connectionPath release];
	connectionPath = aPath;
	
	// set path in dbAccess too
	[dbAccess setConnectionPath:connectionPath];
}

/**
 Get connection path
 */
- (NSString *)connectionPath {
	return connectionPath;
}

#pragma mark - Init DB

// check, if all needed tables are there, if not they are created
- (int)checkAndCreateDBTables {
	int stat = 0;
	int ret;
	[self setErrorMessage:@""];
	
	// get all table entries from sqlite_master table and check if our tables are there
	NSString *query = @"select tbl_name from sqlite_master where type = 'table';";
	// define result Array
	NSArray *result = nil;
	// execute
	result = [dbAccess executeQuery:query];
	if([dbAccess errorCodeOfLastAction] != DB_SUCCESS) {
		NSString *errMsg = [dbAccess errorMessageOfLastAction];
		if(errMsg != nil) {
			CocoLog(LEVEL_ERR, @"%@", errMsg);
		}
		
		ret = DB_ERROR_ON_CHECKING_TABLES;

		// forward error message
		[self setErrorMessage:[dbAccess errorMessageOfLastAction]];
	}

	// no error occured, check, which tables are there and which are not
	// if tables are not there, create them
	BOOL error = NO;
	if(result != nil) {
		if([result count] > 0) {
			firstStart = NO;
			
			CocoLog(LEVEL_INFO,@"some tables seem to exist, check this and create the missing tables!");
			// element table
			if(![self checkForExistenceOfTableInResult:result tableName:TBL_ELEMENT_NAME]) {
				// first start
				firstStart = YES;
				
				stat = [self createDBTableById:TableElement];
				if(stat != DB_SUCCESS) {
					CocoLog(LEVEL_ERR,@"-checkAndCreateDBTables: error on creating element table");
					error = YES;
				}
			}

			// elementvalue table
			if(![self checkForExistenceOfTableInResult:result tableName:TBL_ELEMENTVALUE_NAME]) {
				stat = [self createDBTableById:TableElementValue];
				if(stat != DB_SUCCESS) {
					CocoLog(LEVEL_ERR,@"-checkAndCreateDBTables: error on creating elementvalue table");
					error = YES;
				}
			}

			// the index table
			if(![self checkForExistenceOfTableInResult:result tableName:TBL_VALUE_INDEX_NAME]) {
				CocoLog(LEVEL_DEBUG,@"[MBDBSqlite -checkAndCreateDBTables] creating valueindex table!");
				stat = [self createDBTableById:TableValueIndex];
				if(stat != DB_SUCCESS) {
					CocoLog(LEVEL_ERR,@"-checkAndCreateDBTables: error on creating valueindex table");
					error = YES;
				}
			}
			
			// documentmeta table
			if([self checkForExistenceOfTableInResult:result tableName:TBL_DOCUMENT_META_NAME] == NO) {
				stat = [self createDBTableById:TableDocumentMeta];
				if(stat != DB_SUCCESS) {
					CocoLog(LEVEL_ERR,@"-checkAndCreateDBTables: error on creating documentmeta table");
					error = YES;
				}
			}
			// dbconfig table
			if([self checkForExistenceOfTableInResult:result tableName:TBL_DBCONFIG_NAME] == NO) {
				stat = [self createDBTableById:TableDbConfig];
				if(stat != DB_SUCCESS) {
					CocoLog(LEVEL_ERR,@"-checkAndCreateDBTables: error on creating element table");
					error = YES;
				}
			}
		} else {
			// no table exists, create all tables
			CocoLog(LEVEL_INFO,@"-checkAndCreateDBTables: no table exist, create all!");

			stat = [self createAllDBTables];
			if(stat != DB_SUCCESS) {
				CocoLog(LEVEL_ERR,@"-checkAndCreateDBTables: error on creating all tables!");
				error = YES;
			}
			
			// this is first start
			firstStart = YES;
		}
	} else {
		// we have no result, create all tables from scratch
		CocoLog(LEVEL_WARN,@"[MBDBSqlite -checkAndCreateDBTables] result is nil!");
		error = YES;
	}
	
	// check if errors have occured
	if(error) {
		ret = DB_ERROR_ON_CHECKING_TABLES;
	} else {
		ret = DB_SUCCESS;
        
        // check for a possible update here
        ret = [self updateDB];
	}
	
	return ret;
}

- (int)updateDB {
    
    // get current db version
    NSString *dbVersion = [self configValueForKey:CONFIGENTRY_DBVERSION];
    if(dbVersion != nil) {
        if([dbVersion compare:DB_VERSION] == NSOrderedAscending) {
            // update db
            
            // we need exclusive access
            [self sendBeginTransaction];
            // update elements first
            NSString *sql = @"update element set identifier=120 where identifier=107;";
            [self executeSql:sql];
            if([self errorCode] != DB_SUCCESS) {
                CocoLog(LEVEL_ERR, @"%@", [self errorMessage]);
                // end transaction
                [self sendCommitTransaction];
                return DB_ERROR_ON_QUERY_EXEC;
            }
            sql = @"update element set identifier=121 where identifier=108;";
            [self executeSql:sql];
            if([self errorCode] != DB_SUCCESS) {
                CocoLog(LEVEL_ERR, @"%@", [self errorMessage]);
                // end transaction
                [self sendCommitTransaction];
                return DB_ERROR_ON_QUERY_EXEC;
            }
            sql = @"update element set identifier=122 where identifier=109;";
            [self executeSql:sql];
            if([self errorCode] != DB_SUCCESS) {
                CocoLog(LEVEL_ERR, @"%@", [self errorMessage]);
                // end transaction
                [self sendCommitTransaction];
                return DB_ERROR_ON_QUERY_EXEC;
            }
            sql = @"update element set identifier=123 where identifier=101;";
            [self executeSql:sql];
            if([self errorCode] != DB_SUCCESS) {
                CocoLog(LEVEL_ERR, @"%@", [self errorMessage]);
                // end transaction
                [self sendCommitTransaction];
                return DB_ERROR_ON_QUERY_EXEC;
            }
            // update element values
            sql = @"update elementvalue set valuedata=\'120\' where valuedata=\'107\' and identifier=\'itemvaluetype\';";
            [self executeSql:sql];
            if([self errorCode] != DB_SUCCESS) {
                CocoLog(LEVEL_ERR, @"%@", [self errorMessage]);
                // end transaction
                [self sendCommitTransaction];
                return DB_ERROR_ON_QUERY_EXEC;
            }
            sql = @"update elementvalue set valuedata=\'121\' where valuedata=\'108\' and identifier=\'itemvaluetype\';";
            [self executeSql:sql];
            if([self errorCode] != DB_SUCCESS) {
                CocoLog(LEVEL_ERR, @"%@", [self errorMessage]);
                // end transaction
                [self sendCommitTransaction];
                return DB_ERROR_ON_QUERY_EXEC;
            }
            sql = @"update elementvalue set valuedata=\'122\' where valuedata=\'109\' and identifier=\'itemvaluetype\';";
            [self executeSql:sql];
            if([self errorCode] != DB_SUCCESS) {
                CocoLog(LEVEL_ERR, @"%@", [self errorMessage]);
                // end transaction
                [self sendCommitTransaction];
                return DB_ERROR_ON_QUERY_EXEC;
            }
            sql = @"update elementvalue set valuedata=\'123\' where valuedata=\'101\' and identifier=\'itemvaluetype\';";
            [self executeSql:sql];
            if([self errorCode] != DB_SUCCESS) {
                CocoLog(LEVEL_ERR, @"%@", [self errorMessage]);
                // end transaction
                [self sendCommitTransaction];
                return DB_ERROR_ON_QUERY_EXEC;
            }
            
            // update db version
            [self updateConfigValue:DB_VERSION forKey:CONFIGENTRY_DBVERSION];
            
            // end transaction
            [self sendCommitTransaction];
        }
    }
    
	return DB_SUCCESS;
}

//-----------------------------------------------------
// ---------- custom execution ----------
//-----------------------------------------------------
- (void)executeSql:(NSString *)sql {
	int ret = DB_SUCCESS;
	[self setErrorMessage:@""];
	
	if(dbAccess != nil) {
		if([dbAccess isConnected]) {
            // lock
            [accessLock lock];            
			[dbAccess executeSql:sql];
            // unlock
            [accessLock unlock];
			
            ret = [dbAccess errorCodeOfLastAction];
			[self setErrorMessage:[dbAccess errorMessageOfLastAction]];
		}
	}
	
	[self setErrorCode:ret];
}

- (NSArray *)executeQuery:(NSString *)query {
	int ret = DB_SUCCESS;
	[self setErrorMessage:@""];
	
	NSArray *result = nil;
	
	if(dbAccess != nil) {
		if([dbAccess isConnected]) {
            // lock
            [accessLock lock];            
			result = [dbAccess executeQuery:query];
            // unlock
            [accessLock unlock];
			
            ret = [dbAccess errorCodeOfLastAction];
			[self setErrorMessage:[dbAccess errorMessageOfLastAction]];
		}
	}
	
	[self setErrorCode:ret];
	
	return result;
}

/**
 Send begin transaction
 all sql statements in between BEGIN; and COMMIT; are treated as one transaction and with that a lot faster.
 */
- (void)sendBeginTransaction {
	int ret = DB_SUCCESS;
	[self setErrorMessage:@""];
	
	if(dbAccess != nil) {
		if([dbAccess isConnected]) {
			[dbAccess executeSql:@"BEGIN EXCLUSIVE;"];
			ret = [dbAccess errorCodeOfLastAction];
			[self setErrorMessage:[dbAccess errorMessageOfLastAction]];
		}
	}
	
	[self setErrorCode:ret];	
}

/**
 Send begin transaction 
 all sql statements in between BEGIN; and COMMIT; are treated as one transaction and with that a lot faster.
 */
- (void)sendCommitTransaction {
	int ret = DB_SUCCESS;
	[self setErrorMessage:@""];
	
	if(dbAccess != nil) {
		if([dbAccess isConnected]) {
			[dbAccess executeSql:@"COMMIT;"];
			ret = [dbAccess errorCodeOfLastAction];
			[self setErrorMessage:[dbAccess errorMessageOfLastAction]];
		}
	}
	
	[self setErrorCode:ret];	
}

/**
 Optmizes the database structure
 */
- (void)vacuumDatabase {
	int ret = DB_SUCCESS;
	[self setErrorMessage:@""];
	
	if(dbAccess != nil) {
		if([dbAccess isConnected]) {
			[dbAccess executeSql:@"VACUUM;"];
			ret = [dbAccess errorCodeOfLastAction];
			[self setErrorMessage:[dbAccess errorMessageOfLastAction]];
		}
	}
	
	[self setErrorCode:ret];    
}

/**
 gets a config entry
 */
- (NSString *)configValueForKey:(NSString *)aKey {
	int ret = DB_SUCCESS;
	[self setErrorMessage:@""];
	
	// sql statement
	NSString *sql = [NSString stringWithFormat:@"select value from %@ where key = '%@';", TBL_DBCONFIG_NAME, aKey];
	
	// execute sql
    NSString *result = nil;
	NSArray *list = [dbAccess executeQuery:sql];
	if([dbAccess errorCodeOfLastAction] != DB_SUCCESS) {
		NSString *errMsg = [dbAccess errorMessageOfLastAction];
		if(errMsg != nil) {
			CocoLog(LEVEL_ERR, @"%@", errMsg);
		}
		ret = DB_ERROR_ON_QUERY_EXEC;
		[self setErrorMessage:errMsg];
	} else {
		// check for result
		if(list == nil || [list count] == 0) {
			CocoLog(LEVEL_WARN,@"have nil result from query!");
			
			ret = DB_ERROR_NIL_RESULTARRAY;
			[self setErrorMessage:@"have nil result from query!"];
		} else {
            ResultRow *row = [list objectAtIndex:0];
            RowColumn *col = [row findColumnForName:@"value"];
            result = [col value];
        }
	}
	
	[self setErrorCode:ret];
	
	return result;    
}

/**
 updates a config entry
 */
- (BOOL)updateConfigValue:(NSString *)aString forKey:(NSString *)aKey {

	int ret = DB_SUCCESS;
	[self setErrorMessage:@""];

    NSString *sql = [NSString stringWithFormat:@"update %@ set value='%@' where key='%@';",
                     TBL_DBCONFIG_NAME,
                     aString,
                     aKey];
    // execute sql
    [dbAccess executeSql:sql];
    if([dbAccess errorCodeOfLastAction] != DB_SUCCESS) {
        NSString *errMsg = [dbAccess errorMessageOfLastAction];
        if(errMsg != nil) {
            CocoLog(LEVEL_ERR, @"%@", errMsg);
        }

        ret = DB_ERROR_ON_QUERY_EXEC;
        [self setErrorMessage:errMsg];
        return NO;
    }
    
    return YES;
}

@end

//-----------------------------------------------------
// -------------- db elementbase stuff ----------------
//-----------------------------------------------------
@implementation MBDBSqlite (DBElementBaseAccessing)
/**
\brief create a new element in db and give the id of the created element back
 @returns id of last inserted row, -1 on error
 */
- (int)createElement {
	return [self createElementWithIdentifier:@""]; 
}

/**
 \brief create a element with a given identifier
*/
- (int)createElementWithIdentifier:(NSString *)identifier {
	int rowid = -1;
	int ret = DB_SUCCESS;
	[self setErrorMessage:@""];
	
	// sql statement
	NSString *sql = [NSString stringWithFormat:@"insert into %@ (identifier) values ('%@');",TBL_ELEMENT_NAME,identifier];
	
	// execute sql
	[dbAccess executeSql:sql];
	if([dbAccess errorCodeOfLastAction] != DB_SUCCESS) {
		NSString *errMsg = [dbAccess errorMessageOfLastAction];
		if(errMsg != nil) {
			CocoLog(LEVEL_ERR, @"%@", errMsg);
		}
		ret = DB_ERROR_ON_QUERY_EXEC;
		[self setErrorMessage:errMsg];
	} else {
		// get resulting rowid
		rowid = [dbAccess idOfLastInsert];		// not measureable, too fast!!!
		if([dbAccess errorCodeOfLastAction] != DB_SUCCESS) {
			rowid = -1;
			CocoLog(LEVEL_ERR,@"cannot get last inserted row id!");
			ret = DB_ERROR_ON_GETTING_ROWID_OF_LAST_INSERT;
			[self setErrorMessage:@"cannot get last inserted row id!"];
		}
	}
	
	[self setErrorCode:ret];
	
	return rowid;		
}

/**
\brief create a new element in db and give the id of the created element back
 @params[in] aElem the element of which data the new element should be created
 @returns rowid of this insert, -1 on error
 */
- (int)createElementWithElement:(MBElement *)aElem
{
	int rowid = -1;
	int ret = DB_SUCCESS;
	[self setErrorMessage:@""];
	
	// sql statement
	NSString *sql = [NSString stringWithFormat:@"insert into %@ (treeinfo,identifier,gpreg,parentid) values ('%@','%@',%d,%d);",
		TBL_ELEMENT_NAME,
		[aElem treeinfo],
		[aElem identifier],
		[aElem gpReg],
		[aElem parentid]];
	
	// execute sql
	[dbAccess executeSql:sql];
	if([dbAccess errorCodeOfLastAction] != DB_SUCCESS)
	{
		NSString *errMsg = [dbAccess errorMessageOfLastAction];
		if(errMsg != nil)
		{
			CocoLog(LEVEL_ERR, @"%@", errMsg);
		}
		ret = DB_ERROR_ON_QUERY_EXEC;
		[self setErrorMessage:errMsg];
	}
	else
	{
		// get resulting rowid
		rowid = [dbAccess idOfLastInsert];		// not measureable, too fast!!!
		if([dbAccess errorCodeOfLastAction] != DB_SUCCESS)
		{
			rowid = -1;
			CocoLog(LEVEL_ERR,@"cannot get last inserted row id!");
			ret = DB_ERROR_ON_GETTING_ROWID_OF_LAST_INSERT;
			[self setErrorMessage:@"cannot get last inserted row id!"];
		}
	}
	
	[self setErrorCode:ret];
	
	return rowid;	
}

/**
\brief read element data for a element by the given id
 
 @param[in] aElemId the element to be read
 @returns NSDictionary with element details, nil on error, dict is autoreleased
*/
- (NSDictionary *)readElementById:(int)aElemId
{
	int ret = DB_SUCCESS;
	[self setErrorMessage:@""];

	NSDictionary *dict = nil;	// the returning one
	
	// sql statement
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where id=%d;",TBL_ELEMENT_NAME,aElemId];
	
	// execute sql
	NSArray *result = [dbAccess executeQuery:sql];
	if([dbAccess errorCodeOfLastAction] != DB_SUCCESS)
	{
		NSString *errMsg = [dbAccess errorMessageOfLastAction];
		if(errMsg != nil)
		{
			CocoLog(LEVEL_ERR, @"%@", errMsg);
		}
		ret = DB_ERROR_ON_QUERY_EXEC;
		[self setErrorMessage:errMsg];
	}
	else
	{
		// check for result
		if(result == nil)
		{
			CocoLog(LEVEL_WARN,@"have nil result from query!");

			ret = DB_ERROR_NIL_RESULTARRAY;
			[self setErrorMessage:@"have nil result from query!"];
		}
		else
		{
			// there must exist only one result
			if([result count] == 1)
			{
				dict = [result objectAtIndex:0];
			}
			else if([result count] == 0)
			{
				ret = DB_ERROR_NO_ELEMENT_BY_THIS_ID;
				[self setErrorMessage:@"have received empty result array!"];				
			}
			else
			{
				ret = DB_ERROR_MORE_RESULTS_THAN_EXPECTED;
				[self setErrorMessage:@"have received more results than expected!"];
			}
		}
	}
	
	[self setErrorCode:ret];
	
	return dict;
}

/**
\brief create a new ElementValue in db and return the id of the created ElementValue
 @returns id of last inserted row, -1 on error
 */
- (int)createElementValue
{
	return [self createElementValueWithIdentifier:@"" andType:StringValueType];
}

/**
\brief create a new ElementValue in db and return the id of the created ElementValue
 @params[in] identifier of this attribute
 @returns rowid of this insert, -1 on error
 */
- (int)createElementValueWithIdentifier:(NSString *)identifier
{
	return [self createElementValueWithIdentifier:identifier andType:StringValueType];
}

- (int)createElementValueWithIdentifier:(NSString *)identifier andType:(int)type
{
	int rowid = -1;
	int ret = DB_SUCCESS;
	[self setErrorMessage:@""];
	
	// sql statement
	NSString *sql = [NSString stringWithFormat:@"insert into %@ (identifier,valuetype) values ('%@',%d);",
		TBL_ELEMENTVALUE_NAME,
		identifier,
		type];
	
	// execute sql
	[dbAccess executeSql:sql];
	if([dbAccess errorCodeOfLastAction] != DB_SUCCESS)
	{
		NSString *errMsg = [dbAccess errorMessageOfLastAction];
		if(errMsg != nil)
		{
			CocoLog(LEVEL_ERR, @"%@", errMsg);
		}
		ret = DB_ERROR_ON_QUERY_EXEC;
		[self setErrorMessage:errMsg];
	}
	else
	{
		// get resulting rowid
		rowid = [dbAccess idOfLastInsert];		// not measureable, too fast!!!
		if([dbAccess errorCodeOfLastAction] != DB_SUCCESS)
		{
			rowid = -1;
			CocoLog(LEVEL_ERR,@"cannot get last inserted row id!");
			ret = DB_ERROR_ON_GETTING_ROWID_OF_LAST_INSERT;
			[self setErrorMessage:@"cannot get last inserted row id!"];
		}
	}
	
	[self setErrorCode:ret];
	
	return rowid;	
}

/**
 Create a new ElementValue in db and return the id of the created ElementValue
 @param[in] aElemVal the ElementValue of which data the new has to be created
 @return rowid of this insert, -1 on error
 */
- (int)createElementValueWithElementValue:(MBElementValue *)aElemVal singleInstanceDocId:(int)aDocId {
	int rowid = -1;
	int ret = DB_SUCCESS;
	[self setErrorMessage:@""];
	
	// check, if we have to encode valuedata
	NSString *valueAsString = nil;
	//const char *cStrData = NULL;
	NSString *sql = nil;
	NSData *valData = [aElemVal valueDataAsData];
	if(valData != nil) {        
        if(aDocId > -1) {
            valueAsString = [[NSNumber numberWithInt:aDocId] stringValue];
        } else {
            if([aElemVal valuetype] == BinaryValueType) {
                //NSData *plistData = [MBDBSqliteElementValue encodeData:[aElemVal valueDataAsData] withPListFormat:NSPropertyListXMLFormat_v1_0];
                valueAsString = [[aElemVal valueDataAsData] encodeBase64WithNewlines:NO];
                //cStrData = [[valData base64EncodedDataWithLineLength:0] bytes];
            } else {
                valueAsString = [aElemVal valueDataAsString];
                //cStrData = [[aElemVal valueDataAsData] bytes];
            }            
        }
	
		// sql statement
		sql = [NSString stringWithFormat:@"insert into %@ (elementid,identifier,gpreg,valuetype,valuedatasize,valuedata) values (%d,'%@',%d,%d,%lu,'%@');",
			TBL_ELEMENTVALUE_NAME,
			[aElemVal elementid],
			[aElemVal identifier],
			[aElemVal gpReg],
			(int)[aElemVal valuetype],
			(unsigned long)[valueAsString length],
			valueAsString];
	} else {
		// sql statement
		sql = [NSString stringWithFormat:@"insert into %@ (elementid,identifier,gpreg,valuetype) values (%d,'%@',%d,%d);",
			TBL_ELEMENTVALUE_NAME,
			[aElemVal elementid],
			[aElemVal identifier],
			[aElemVal gpReg],
			(int)[aElemVal valuetype]];
	}	

	// execute sql
	[dbAccess executeSql:sql];
	if([dbAccess errorCodeOfLastAction] != DB_SUCCESS) {
		NSString *errMsg = [dbAccess errorMessageOfLastAction];
		if(errMsg != nil) {
			CocoLog(LEVEL_ERR, @"%@", errMsg);
		}
		ret = DB_ERROR_ON_QUERY_EXEC;
		[self setErrorMessage:errMsg];
	} else {
		// get resulting rowid
		rowid = [dbAccess idOfLastInsert];		// not measureable, too fast!!!
		if([dbAccess errorCodeOfLastAction] != DB_SUCCESS) {
			rowid = -1;
			CocoLog(LEVEL_ERR,@"cannot get last inserted row id!");
			ret = DB_ERROR_ON_GETTING_ROWID_OF_LAST_INSERT;
			[self setErrorMessage:@"cannot get last inserted row id!"];
		}
	}
	
	[self setErrorCode:ret];
	
	return rowid;	
}

/**
\brief read attribute data for a attribute by the given id
 
 @param[in] aAttribId the ElementValue to be read
 @returns NSDictionary with ElementValue details, nil on error, dict is autoreleased
 */
- (ResultRow *)readElementValueById:(int)aElemValId
{
	int ret = DB_SUCCESS;
	[self setErrorMessage:@""];
	
	ResultRow *row = nil;	// the returning one
	
	// sql statement
	NSString *sql = [NSString stringWithFormat:@"select id,elementid,identifier,gpreg,valuetype,valuedatasize from %@ where id=%d;",TBL_ELEMENTVALUE_NAME,aElemValId];
	
	// execute sql
	NSArray *result = [dbAccess executeQuery:sql];
	if([dbAccess errorCodeOfLastAction] != DB_SUCCESS)
	{
		NSString *errMsg = [dbAccess errorMessageOfLastAction];
		if(errMsg != nil)
		{
			CocoLog(LEVEL_ERR, @"%@", errMsg);
		}
		ret = DB_ERROR_ON_QUERY_EXEC;
		[self setErrorMessage:errMsg];
	}
	else
	{
		// check for result
		if(result == nil)
		{
			CocoLog(LEVEL_WARN,@"have nil result from query!");
			
			ret = DB_ERROR_NIL_RESULTARRAY;
			[self setErrorMessage:@"have nil result from query!"];
		}
		else
		{
			// there must exist only one result
			if([result count] == 1)
			{
                row = [result objectAtIndex:0];
			}
			else if([result count] == 0)
			{
				ret = DB_ERROR_NO_ELEMENTVALUE_BY_THIS_ID;
				[self setErrorMessage:@"have received empty result array!"];				
			}
			else
			{
				ret = DB_ERROR_MORE_RESULTS_THAN_EXPECTED;
				[self setErrorMessage:@"have received more results than expected!"];
			}
		}
	}
	
	[self setErrorCode:ret];
	
	return row;
}

/**
creates a document data entry for the given data string
 */
- (int)createDocumentDataEntry:(NSString *)dataStr
{
	int rowid = -1;
	int ret = DB_SUCCESS;
	[self setErrorMessage:@""];
    
	if(dataStr != nil)
	{
        // check for real data in the entry
        NSString *sql = [NSString stringWithFormat:
            @"insert into %@ (docdata) values ('%@');",
            TBL_DOCUMENT_DATA_NAME,
            dataStr];
                
        // execute sql
        [dbAccess executeSql:sql];
        if([dbAccess errorCodeOfLastAction] != DB_SUCCESS)
        {
            NSString *errMsg = [dbAccess errorMessageOfLastAction];
            if(errMsg != nil)
            {
                CocoLog(LEVEL_ERR, @"%@", errMsg);
            }
            ret = DB_ERROR_ON_QUERY_EXEC;
            [self setErrorMessage:errMsg];
        }
        else
        {
            // get resulting rowid
            rowid = [dbAccess idOfLastInsert];
            if([dbAccess errorCodeOfLastAction] != DB_SUCCESS)
            {
                rowid = -1;
                CocoLog(LEVEL_ERR,@"cannot get last inserted row id!");
                ret = DB_ERROR_ON_GETTING_ROWID_OF_LAST_INSERT;
                [self setErrorMessage:@"cannot get last inserted row id!"];
            }
        }
	}
	else
	{
        CocoLog(LEVEL_ERR, @"have a nil entry!");
	}	
    
	[self setErrorCode:ret];
	
	return rowid;
}

/**
 Create Document entry.
 This methods stored the given meta data and also the blob in the docdata table
 */
- (int)createDocumentEntryForInstance:(MBDBDocumentEntry *)entry {
	int rowid = -1;
	int ret = DB_SUCCESS;
	[self setErrorMessage:@""];
	
	if(entry != nil) {
        if([entry docDataId] == -1 && ([entry docPath] == nil || [[entry docPath] length] == 0)) {
            CocoLog(LEVEL_WARN, @"[MBDBSqlite -createDocumentEntryForInstance:] entry does not have docdataid nor docpath!!!");
        }
        
        // enter the document meta data
		NSString *sql = [NSString stringWithFormat:
            @"insert into %@ (docdataid,docsrcsize,docsize,dochash,docpath,hashtype,encryptiontype,instancecount) values (%d,%d,%d,'%@','%@',%d,%d,%d);",
			TBL_DOCUMENT_META_NAME,
            [entry docDataId],
            [entry docSrcSize],
            [entry docSize],
            [entry docHash],
            [entry docPath],
            [entry hashType],
            [entry encryptionType],
            [entry instanceCount]];

        // execute sql
        [dbAccess executeSql:sql];
        if([dbAccess errorCodeOfLastAction] != DB_SUCCESS) {
            NSString *errMsg = [dbAccess errorMessageOfLastAction];
            if(errMsg != nil) {
                CocoLog(LEVEL_ERR, @"%@", errMsg);
            }
            ret = DB_ERROR_ON_QUERY_EXEC;
            [self setErrorMessage:errMsg];
        } else {
            // get resulting rowid
            rowid = [dbAccess idOfLastInsert];
            if([dbAccess errorCodeOfLastAction] != DB_SUCCESS) {
                rowid = -1;
                CocoLog(LEVEL_ERR,@"cannot get last inserted row id!");
                ret = DB_ERROR_ON_GETTING_ROWID_OF_LAST_INSERT;
                [self setErrorMessage:@"cannot get last inserted row id!"];
            }
        }
	} else {
        CocoLog(LEVEL_ERR, @"have a nil entry!");
	}	
    
	[self setErrorCode:ret];
	
	return rowid;
}

/**
 \brief this method read the data for the document for the given element value id
 */
- (ResultRow *)readDocumentEntryForDocId:(int)docId
{
	int ret = DB_SUCCESS;
	[self setErrorMessage:@""];
	
	ResultRow *row = nil;	// the returning one
	
	// sql statement
	NSString *sql = [NSString stringWithFormat:
        @"select id,docdataid,docsrcsize,docsize,dochash,docpath,hashtype,encryptiontype,instancecount from %@ where id=%d;",
        TBL_DOCUMENT_META_NAME,
        docId];
	
	// execute sql
	NSArray *result = [dbAccess executeQuery:sql];
	if([dbAccess errorCodeOfLastAction] != DB_SUCCESS)
	{
		NSString *errMsg = [dbAccess errorMessageOfLastAction];
		if(errMsg != nil)
		{
			CocoLog(LEVEL_ERR, @"%@", errMsg);
		}
		ret = DB_ERROR_ON_QUERY_EXEC;
		[self setErrorMessage:errMsg];
	}
	else
	{
		// check for result
		if(result == nil)
		{
			CocoLog(LEVEL_WARN,@"have nil result from query!");
			
			ret = DB_ERROR_NIL_RESULTARRAY;
			[self setErrorMessage:@"have nil result from query!"];
		}
		else
		{
			// there must exist only one result
			if([result count] == 1)
			{
				row = [result objectAtIndex:0];
			}
			else if([result count] == 0)
			{
				ret = DB_ERROR_NO_ELEMENTVALUE_BY_THIS_ID;
				[self setErrorMessage:@"have received empty result array!"];				
			}
			else
			{
				ret = DB_ERROR_MORE_RESULTS_THAN_EXPECTED;
				[self setErrorMessage:@"have received more results than expected!"];
			}
		}
	}
	
	[self setErrorCode:ret];
	
	return row;
}

- (ResultRow *)readDocumentEntryForHashValue:(NSString *)hashVal
{
	int ret = DB_SUCCESS;
	[self setErrorMessage:@""];
	
	ResultRow *row = nil;	// the returning one
	
	// sql statement
	NSString *sql = [NSString stringWithFormat:
        @"select id,docdataid,docsrcsize,docsize,dochash,docpath,hashtype,encryptiontype,instancecount from %@ where dochash='%@';",
        TBL_DOCUMENT_META_NAME,
        hashVal];
	
	// execute sql
	NSArray *result = [dbAccess executeQuery:sql];
	if([dbAccess errorCodeOfLastAction] != DB_SUCCESS)
	{
		NSString *errMsg = [dbAccess errorMessageOfLastAction];
		if(errMsg != nil)
		{
			CocoLog(LEVEL_ERR, @"%@", errMsg);
		}
		ret = DB_ERROR_ON_QUERY_EXEC;
		[self setErrorMessage:errMsg];
	}
	else
	{
		// check for result
		if(result == nil)
		{
			CocoLog(LEVEL_WARN,@"have nil result from query!");
			
			ret = DB_ERROR_NIL_RESULTARRAY;
			[self setErrorMessage:@"have nil result from query!"];
		}
		else
		{
			// there must exist only one result
			if([result count] == 1)
			{
				row = [result objectAtIndex:0];
			}
			else if([result count] == 0)
			{
				ret = DB_ERROR_NO_ELEMENTVALUE_BY_THIS_ID;
				[self setErrorMessage:@"have received empty result array!"];				
			}
			else
			{
                // use the first entry even though this is an error to single instance saving
                // TODO: try to find better solution
                row = [result objectAtIndex:0];
				ret = DB_ERROR_MORE_RESULTS_THAN_EXPECTED;
				[self setErrorMessage:@"have received more results than expected!"];
			}
		}
	}
	
	[self setErrorCode:ret];
	
	return row;
}

- (NSArray *)listDocumentEntries {
	int ret = DB_SUCCESS;
	[self setErrorMessage:@""];
	
	// sql statement
	NSString *sql = [NSString stringWithFormat:@"select id,docdataid,docsrcsize,docsize,dochash,docpath,hashtype,encryptiontype,instancecount from %@;", TBL_DOCUMENT_META_NAME];
	
	// execute sql
	NSArray *result = [dbAccess executeQuery:sql];
	if([dbAccess errorCodeOfLastAction] != DB_SUCCESS) {
		NSString *errMsg = [dbAccess errorMessageOfLastAction];
		if(errMsg != nil) {
			CocoLog(LEVEL_ERR, @"%@", errMsg);
		}
		ret = DB_ERROR_ON_QUERY_EXEC;
		[self setErrorMessage:errMsg];
	} else {
		// check for result
		if(result == nil) {
			CocoLog(LEVEL_WARN,@"have nil result from query!");
			
			ret = DB_ERROR_NIL_RESULTARRAY;
			[self setErrorMessage:@"have nil result from query!"];
		}
	}
	
	[self setErrorCode:ret];
	
	return result;
}

/**
 counts the real number of instances for a single instance value from the number of values that have the docid as value.
 */
- (int)scannedInstanceCountForDocId:(int)aDocId {
	int count = -1;
	int ret = DB_SUCCESS;
	[self setErrorMessage:@""];
	
    if(aDocId > 0) {
        // enter the document meta data
		NSString *sql = [NSString stringWithFormat:@"select count(*) from %@ where gpreg & 2 and valuedata = '%d';", TBL_ELEMENTVALUE_NAME, aDocId];
        
        // execute sql
        NSArray *result = [dbAccess executeQuery:sql];
        if([dbAccess errorCodeOfLastAction] != DB_SUCCESS) {
            NSString *errMsg = [dbAccess errorMessageOfLastAction];
            if(errMsg != nil) {
                CocoLog(LEVEL_ERR, @"%@", errMsg);
            }
            ret = DB_ERROR_ON_QUERY_EXEC;
            [self setErrorMessage:errMsg];
        } else {
            if([result count] == 1) {
                count = [[[(ResultRow *)[result objectAtIndex:0] findColumnForName:@"count(*)"] value] intValue];
            } else {
                CocoLog(LEVEL_ERR, @"[MBDBSqlite -scannedInstanceCountForDocId:] wrong number of results: %lu", (unsigned long)[result count]);
            }
        }
	} else {
        CocoLog(LEVEL_ERR, @"have a nil entry!");
	}	
    
	[self setErrorCode:ret];
	
	return count;    
}

- (int)createIndexEntryWithElementValueID:(int)elemValID
{
	return [self createIndexEntryWithElementValueID:elemValID andIdentifier:@""];
}

/**
 \brief this creates a new index entry for the given elementvalue id (must be > 0)
*/
- (int)createIndexEntryWithElementValueID:(int)elemValID andIdentifier:(NSString *)identifier
{
	int rowid = -1;
	int ret = DB_SUCCESS;
	[self setErrorMessage:@""];
    
	if(elemValID > 0)
	{
		// sql statement
		NSString *sql = [NSString stringWithFormat:@"insert into %@ (elemvalid,elemvalidentifier) values (%d,'%@');",
			TBL_VALUE_INDEX_NAME,
			elemValID,
			identifier];
		
		// execute sql
		[dbAccess executeSql:sql];
		if([dbAccess errorCodeOfLastAction] != DB_SUCCESS)
		{
			NSString *errMsg = [dbAccess errorMessageOfLastAction];
			if(errMsg != nil)
			{
				CocoLog(LEVEL_ERR, @"%@", errMsg);
			}
			ret = DB_ERROR_ON_QUERY_EXEC;
			[self setErrorMessage:errMsg];
		}
		else
		{
			// get resulting rowid
			rowid = [dbAccess idOfLastInsert];		// not measureable, too fast!!!
			if([dbAccess errorCodeOfLastAction] != DB_SUCCESS)
			{
				rowid = -1;
				CocoLog(LEVEL_ERR,@"cannot get last inserted row id!");
				ret = DB_ERROR_ON_GETTING_ROWID_OF_LAST_INSERT;
				[self setErrorMessage:@"cannot get last inserted row id!"];
			}
		}
		
		[self setErrorCode:ret];		
	}
	else
	{
		CocoLog(LEVEL_WARN,@"id < 0!");
	}
	
	return rowid;	
}

/**
 \brief get all entries of index with the specified pattern
*/
- (NSArray *)listIndexEntriesForPattern:(NSString *)pat
{
	// by default list all entries for root
	return [self listIndexEntriesForPattern:pat andTreeinfo:@".1"];
}

/**
 \brief list all entries in within the given treeinfo as source and the given pattern
 coloumns are: treeinfo, elementid, elemvalid, elemvalcontent
*/
- (NSArray *)listIndexEntriesForPattern:(NSString *)pat andTreeinfo:(NSString *)ti
{
	int ret = DB_SUCCESS;
	[self setErrorMessage:@""];
	
	// alter pattern
	NSString *pattern = [NSString stringWithFormat:@"%%%@%%",pat];
	// alter treeinfo
	NSString *treeinfo = [NSString stringWithFormat:@"%@.%%",ti];
	
	// sql statement
	NSString *sql = [NSString stringWithFormat:@"select e.treeinfo, ev.elementid, ei.elemvalid, ei.elemvalcontent from valueindex ei \
left outer join elementvalue ev on ev.id = ei.elemvalid \
left outer join element e on ev.elementid = e.id \
where ei.elemvalcontent like '%@' \
AND e.treeinfo like '%@';",pattern,treeinfo];
	
	// execute sql
	NSArray *result = [dbAccess executeQuery:sql];
	if([dbAccess errorCodeOfLastAction] != DB_SUCCESS)
	{
		NSString *errMsg = [dbAccess errorMessageOfLastAction];
		if(errMsg != nil)
		{
			CocoLog(LEVEL_ERR, @"%@", errMsg);
		}
		ret = DB_ERROR_ON_QUERY_EXEC;
		[self setErrorMessage:errMsg];
	}
	else
	{
		// check for result
		if(result == nil)
		{
			CocoLog(LEVEL_WARN,@"have nil result from query!");
			
			ret = DB_ERROR_NIL_RESULTARRAY;
			[self setErrorMessage:@"have nil result from query!"];
		}
	}
	
	[self setErrorCode:ret];
	
	return result;	
}

/**
\brief get all elements from element table
 
 @returns NSArray with all result rows of the select
*/
- (NSArray *)listAllElements
{
	int ret = DB_SUCCESS;
	[self setErrorMessage:@""];

	// sql statement
	NSString *sql = [NSString stringWithFormat:@"select * from %@;",TBL_ELEMENT_NAME];
	
	// execute sql
	NSArray *result = [dbAccess executeQuery:sql];
	if([dbAccess errorCodeOfLastAction] != DB_SUCCESS)
	{
		NSString *errMsg = [dbAccess errorMessageOfLastAction];
		if(errMsg != nil)
		{
			CocoLog(LEVEL_ERR, @"%@", errMsg);
		}
		ret = DB_ERROR_ON_QUERY_EXEC;
		[self setErrorMessage:errMsg];
	}
	else
	{
		// check for result
		if(result == nil)
		{
			CocoLog(LEVEL_WARN,@"have nil result from query!");
			
			ret = DB_ERROR_NIL_RESULTARRAY;
			[self setErrorMessage:@"have nil result from query!"];
		}
	}
	
	[self setErrorCode:ret];
	
	return result;
}

/**
\brief get all ElementValues without value data from value table
 Any ElementValue data is not read. ElementValue deal with reading value data themselfs
 @returns NSArray with all result rows of the select
 */
- (NSArray *)listAllElementValuesWithoutData;
{
	int ret = DB_SUCCESS;
	[self setErrorMessage:@""];
	
	// sql statement
	NSString *sql = [NSString stringWithFormat:@"select id,elementid,identifier,gpreg,valuetype,valuedatasize from %@;", TBL_ELEMENTVALUE_NAME];
	
	// execute sql
	NSArray *result = [dbAccess executeQuery:sql];
	if([dbAccess errorCodeOfLastAction] != DB_SUCCESS)
	{
		NSString *errMsg = [dbAccess errorMessageOfLastAction];
		if(errMsg != nil)
		{
			CocoLog(LEVEL_ERR, @"%@", errMsg);
		}
		ret = DB_ERROR_ON_QUERY_EXEC;
		[self setErrorMessage:errMsg];
	}
	else
	{
		// check for result
		if(result == nil)
		{
			CocoLog(LEVEL_WARN,@"have nil result from query!");
			
			ret = DB_ERROR_NIL_RESULTARRAY;
			[self setErrorMessage:@"have nil result from query!"];
		}
	}
	
	[self setErrorCode:ret];
	
	return result;	
}

/**
 List element values data where the size is smaller than byteSize and which are single instance stored
 In case of single instance stored values, the value is the document id.
*/
- (NSArray *)listElementValueDataLowerThanSize:(int)byteSize {
	int ret = DB_SUCCESS;
	[self setErrorMessage:@""];
	
	// sql statement
	NSString *sql = [NSString stringWithFormat:@"select id,valuedata from %@ where valuedatasize < %d or gpreg & 2;", TBL_ELEMENTVALUE_NAME, byteSize];
	
	// execute sql
	NSArray *result = [dbAccess executeQuery:sql];
	if([dbAccess errorCodeOfLastAction] != DB_SUCCESS) {
		NSString *errMsg = [dbAccess errorMessageOfLastAction];
		if(errMsg != nil) {
			CocoLog(LEVEL_ERR, @"%@", errMsg);
		}
		ret = DB_ERROR_ON_QUERY_EXEC;
		[self setErrorMessage:errMsg];
	} else {
		// check for result
		if(result == nil) {
			CocoLog(LEVEL_WARN,@"have nil result from query!");
			
			ret = DB_ERROR_NIL_RESULTARRAY;
			[self setErrorMessage:@"have nil result from query!"];
		}
	}
	
	[self setErrorCode:ret];
	
	return result;	
}

- (NSArray *)listChildElementsById:(int)elementId withIdentifier:(NSString *)aIdentifier
{
	int ret = DB_SUCCESS;
	[self setErrorMessage:@""];
	
	// sql statement
	NSString *sql = nil;
	if(aIdentifier == nil)
	{
		sql = [NSString stringWithFormat:@"select * from %@ where parentid=%d;",
			TBL_ELEMENT_NAME,
			elementId];
	}
	else
	{
		sql = [NSString stringWithFormat:@"select * from %@ where parentid=%d AND identifier like '%@';",
			TBL_ELEMENT_NAME,
			elementId,
			aIdentifier];
	}
	
	// execute sql
	NSArray *result = [dbAccess executeQuery:sql];
	if([dbAccess errorCodeOfLastAction] != DB_SUCCESS)
	{
		NSString *errMsg = [dbAccess errorMessageOfLastAction];
		if(errMsg != nil)
		{
			CocoLog(LEVEL_ERR, @"%@", errMsg);
		}
		ret = DB_ERROR_ON_QUERY_EXEC;
		[self setErrorMessage:errMsg];
	}
	else
	{
		// check for result
		if(result == nil)
		{
			CocoLog(LEVEL_WARN,@"have nil result from query!");
			
			ret = DB_ERROR_NIL_RESULTARRAY;
			[self setErrorMessage:@"have nil result from query!"];
		}
	}
	
	[self setErrorCode:ret];
	
	return result;	
}

- (NSArray *)listElementValuesByElementId:(int)elementId withIdentifier:(NSString *)aIdentifier
{
	int ret = DB_SUCCESS;
	[self setErrorMessage:@""];
	
	// sql statement
	NSString *sql = nil;
	if(aIdentifier == nil)
	{
		sql = [NSString stringWithFormat:@"select id,elementid,identifier,valuetype from %@ where elementid=%d;",
			TBL_ELEMENTVALUE_NAME,
			elementId];
	}
	else
	{
		sql = [NSString stringWithFormat:@"select id,elementid,identifier,valuetype,valuedatasize from %@ where elementid=%d AND identifier like '%@';",
			TBL_ELEMENTVALUE_NAME,
			elementId,
			aIdentifier];		
	}
	
	// execute sql
	NSArray *result = [dbAccess executeQuery:sql];
	if([dbAccess errorCodeOfLastAction] != DB_SUCCESS)
	{
		NSString *errMsg = [dbAccess errorMessageOfLastAction];
		if(errMsg != nil)
		{
			CocoLog(LEVEL_ERR, @"%@", errMsg);
		}
		ret = DB_ERROR_ON_QUERY_EXEC;
		[self setErrorMessage:errMsg];
	}
	else
	{
		// check for result
		if(result == nil)
		{
			CocoLog(LEVEL_WARN,@"have nil result from query!");
			
			ret = DB_ERROR_NIL_RESULTARRAY;
			[self setErrorMessage:@"have nil result from query!"];
		}
	}
	
	[self setErrorCode:ret];
	
	return result;	
}

/**
 brief list all elementvalues of one level
*/
- (NSArray *)listAllLevelElementValuesByElementId:(int)elementId 
							withElementIdentifier:(NSString *)aElemIdent
					   withElementValueIdentifier:(NSString *)aElemValIdent
{
	int ret = DB_SUCCESS;
	[self setErrorMessage:@""];
	
	// sql statement
	NSString *sql = nil;
	if(aElemIdent == nil)
	{
		if(aElemValIdent == nil)
		{
			sql = [NSString stringWithFormat:@"select ev.id,ev.elementid,ev.valuetype,ev.identifier,ev.gpreg,ev.valuedatasize from elementvalue ev left outer join element e on e.id = ev.elementid where e.parentid=%d;",
				elementId];
		}
		else
		{
			sql = [NSString stringWithFormat:@"select ev.id,ev.elementid,ev.valuetype,ev.identifier,ev.gpreg,ev.valuedatasize from elementvalue ev left outer join element e on e.id = ev.elementid where e.parentid=%d AND ev.identifier like '%@';",
				elementId,
				aElemValIdent];			
		}
	}
	else
	{
		if(aElemValIdent == nil)
		{
			sql = [NSString stringWithFormat:@"select ev.id,ev.elementid,ev.valuetype,ev.identifier,ev.gpreg,ev.valuedatasize from elementvalue ev left outer join element e on e.id = ev.elementid where e.parentid=%d AND e.identifier like '%@';",
				elementId,
				aElemIdent];
		}
		else
		{
			sql = [NSString stringWithFormat:@"select ev.id,ev.elementid,ev.valuetype,ev.identifier,ev.gpreg,ev.valuedatasize from elementvalue ev left outer join element e on e.id = ev.elementid where e.parentid=%d AND e.identifier like '%@' AND ev.identifier like '%@';",
				elementId,
				aElemIdent,
				aElemValIdent];
		}
	}
	
	// execute sql
	NSArray *result = [dbAccess executeQuery:sql];
	if([dbAccess errorCodeOfLastAction] != DB_SUCCESS)
	{
		NSString *errMsg = [dbAccess errorMessageOfLastAction];
		if(errMsg != nil)
		{
			CocoLog(LEVEL_ERR, @"%@", errMsg);
		}
		ret = DB_ERROR_ON_QUERY_EXEC;
		[self setErrorMessage:errMsg];
	}
	else
	{
		// check for result
		if(result == nil)
		{
			CocoLog(LEVEL_WARN,@"have nil result from query!");
			
			ret = DB_ERROR_NIL_RESULTARRAY;
			[self setErrorMessage:@"have nil result from query!"];
		}
	}
	
	[self setErrorCode:ret];
	
	return result;	
}

- (NSNumber *)numberOfElementsForIdentifier:(int)anIdentifier {
	int ret = DB_SUCCESS;
	[self setErrorMessage:@""];
	
	// sql statement
	NSString *sql = [NSString stringWithFormat:@"select count(*) from %@ where identifier like '%d';",
                     TBL_ELEMENT_NAME,
                     anIdentifier];
	
	// execute sql
    NSNumber *result = [NSNumber numberWithLong:-1];
	NSArray *list = [dbAccess executeQuery:sql];
	if([dbAccess errorCodeOfLastAction] != DB_SUCCESS) {
		NSString *errMsg = [dbAccess errorMessageOfLastAction];
		if(errMsg != nil) {
			CocoLog(LEVEL_ERR, @"%@", errMsg);
		}
		ret = DB_ERROR_ON_QUERY_EXEC;
		[self setErrorMessage:errMsg];
	} else {
		// check for result
		if(list == nil || [list count] == 0) {
			CocoLog(LEVEL_WARN,@"have nil result from query!");
			
			ret = DB_ERROR_NIL_RESULTARRAY;
			[self setErrorMessage:@"have nil result from query!"];
		} else {
            NSDictionary *row = [list objectAtIndex:0];
            NSArray *allValues = [row allValues];
            NSString *str = [allValues objectAtIndex:0];
            result = [NSNumber numberWithLong:[str intValue]];
        }
	}
	
	[self setErrorCode:ret];
	
	return result;    
}

@end
