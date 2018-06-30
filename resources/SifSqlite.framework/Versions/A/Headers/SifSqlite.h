//
//  SifSqlite.h
//  SifSqlite Framework
//
//  Created by Manfred Bergmann on 06.06.05.
//  Copyright 2005 mabe. All rights reserved.
//

#import <SifSqlite/sqlite3.h>
#import <SifSqlite/SqliteAccess.h>
#import <SifSqlite/ResultRow.h>
#import <SifSqlite/RowColumn.h>

/**
 Error codes for SqliteAccess
 */
enum DBAccessErrorCodes {
    DB_SUCCESS = 0,                     /** On success */
	DB_ALREADY_OPEN,                    /** On trying to open an already opened connection */
	DB_PATH_IS_NIL,                     /** If given path is nil */
	DB_SQLSTMT_IS_NIL,                  /** If given sql statement is nil */
	DB_SQLSTMT_IS_EMPTY,                /** If a emtpy sql statement is given */
	DB_SQLBUNCH_IS_NIL,                 /** if given sql array is nil */
	DB_CANNOT_OPEN,                     /** Error occured at sqlite3_open */
	DB_CANNOT_CLOSE,                    /** Error occured at sqlite3_close */
	DB_CANNOT_EXECUTE,                  /** Error on executing a sql statement */
	DB_CANNOT_COMPILE_SQLSTMT,          /** If sql statement could not be compiled */
	DB_CANNOT_ALLOC_MEMORY_FOR_SQLSTMT,	/** if malloc returns a nil pointer */
	DB_NO_OPEN_CONNECTION,              /** If we have no open connection */
	DB_UNRECOGNIZED_COLUMNTYPE,         /** If type of column is not recognized */
	DB_BUSY,                            /** DB is busy, cannot make query or close */
	DB_ABORT                            /** DB aborted query */
};

enum DBAccessType {
    DB_READONLY = SQLITE_OPEN_READONLY,
    DB_READWRITE = SQLITE_OPEN_READWRITE,
    DB_READWRITECREATE = SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE
};
