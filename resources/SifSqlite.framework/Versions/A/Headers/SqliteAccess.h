//
//  SqliteAccess.h
//  SifSqlite Framework
//
//  Created by Manfred Bergmann on 04.06.05.
//  Copyright 2005 mabe. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SifSqlite/SifSqlite.h>

@interface SqliteAccess : NSObject {
	/**
	This is the connection reference to Sqlite database
	 */
	sqlite3 *sqlCon;
	
	NSString *connectionPath;
	
	NSString *errorMessageOfLastAction;
	int errorCodeOfLastAction;
}

- (id)initWithPath:(NSString *)aPath;
- (id)initInMemory;

/**
 \brief set the connection path of this instance. next step would be to call -openConnection
 @param[in] aPath the path to the database, if it does not exist, it will be created
 */
- (void)setConnectionPath:(NSString *)aPath;

/**
 \brief get the connection path that this instance is set with
 @returns connection path of instance
 */
- (NSString *)connectionPath;

/**
 \brief get the error message, if there is one, of the last action made. Check -errorCodeOfLastAction befor calling this method.
 @returns NSString with action message or nil if there is none
 */
- (NSString *)errorMessageOfLastAction;

/**
 \brief get error code of last action made.
 @returns one of DBAccessErrorCodes
 */
- (int)errorCodeOfLastAction;

/**
 \brief checks if the current db is still opened
 
 @return YES or NO
 */
- (BOOL)isConnected;

/**
 \brief Open sqlite database to whatever is connectionPath set to. \n
 Can also be ":memory:" for opening memory dbs. \n
 Sets errorCodeOfLastAction and errorMessageOfLastAction.
 */
- (void)openConnection;

/**
 \brief Open sqlite database to whatever is connectionPath set to. \n
 Can also be ":memory:" for opening memory dbs. \n
 Sets errorCodeOfLastAction and errorMessageOfLastAction.
 
 @param[in] accessType as in DBAccessType enum
 */
- (void)openConnectionWithAccessType:(int)accessType;

/**
 \brief Close Sqlite database. \n
 Sets errorCodeOfLastAction and errorMessageOfLastAction.
 */
- (void)closeConnection;

/**
 \brief Execute Sql statement without result. \n
 Sets errorCodeOfLastAction and errorMessageOfLastAction.
 
 @param[in] sqlStmt the Sql statement to be executed, must not be nil
 */
- (void)executeSql:(NSString *)sqlStmt;

/**
 \brief Execute more sql statements at once. \n
 Sets errorCodeOfLastAction and errorMessageOfLastAction.
 
 Will be executed as complete transaction. if there are select queries withins the bunch,
 a result will be given back from the last select query.
 
 @param[in] sqlBunch NSArray with NSString entries, each for one sql statement
 @param[in] aSetting defines if a BEGIN EXCLUSIVE or just a BEGIN transaction is made.
 */
- (void)executeSqlBunch:(NSArray *)sqlBunch exclusiveAccess:(BOOL)aSetting;

/**
 \brief Execute Sql statement on db. \n
 Sets errorCodeOfLastAction and errorMessageOfLastAction.
 
 The resultArray is a NSMutableArray which is filled with NSDictionaries (column name, column value). \n
 Valuetypes: \n
 Integer: NSNumber \n
 Float: NSNumber \n
 Text: NSString \n
 BLOB: NSData \n
 NULL: nil \n
 
 @param[in] sqlStmt the Sql statement to be executed, must not be nil
 @returns result of query as autoreleased NSArray
 */
- (NSArray *)executeQuery:(NSString *)sqlStmt;

/**
 \brief return the rowid of the last insert sql statement. \n
 Sets errorCode and errorMessageOfLastAction
 @returns id of last insert as int
 */
- (int)idOfLastInsert;

@end
