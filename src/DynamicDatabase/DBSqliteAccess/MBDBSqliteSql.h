/*
 *  MBSqliteSqlStatements.h
 *  iKnowAndManage
 *
 *  Created by Manfred Bergmann on 03.06.05.
 *  Copyright 2005 mabe. All rights reserved.
 *
 */

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

// here we have SQL defines for creating all tables in db

/**
 This table stores any low level configuration data like db_version
 */
#define CREATE_TABLE_DBCONFIG \
"CREATE TABLE dbconfig (key TEXT DEFAULT '', value TEXT DEFAULT ''); \
INSERT INTO dbconfig (key, value) values ('db_version', '0.0.0');"

/** 
\brief element table for storing elements
*/
#define CREATE_TABLE_ELEMENT \
"CREATE TABLE element ( \
						id INTEGER, \
						parentid INTEGER DEFAULT -1, \
						treeinfo TEXT DEFAULT '', \
						identifier TEXT DEFAULT '', \
						gpreg INTEGER DEFAULT 0, \
						PRIMARY KEY ( id ) \
						);"

/** 
\brief elementvalue table for storing values with element relationship
*/
#define CREATE_TABLE_ELEMENTVALUE \
"CREATE TABLE elementvalue ( \
							 id INTEGER, \
							 elementid INTEGER DEFAULT -1, \
							 identifier TEXT DEFAULT '', \
							 gpreg INTEGER DEFAULT 0, \
							 valuetype INTEGER DEFAULT 0, \
							 valuedata BLOB DEFAULT '', \
							 valuedatasize INTEGER DEFAULT 0, \
							 PRIMARY KEY ( id ) \
						  );"

/**
 \brief the index table for faster searching
 DEPRICATED: will be replaced by SearchKit indexing
 */
#define CREATE_TABLE_VALUEINDEX \
"CREATE TABLE valueindex ( \
						   elemvalid INTEGER, \
						   elemvalidentifier TEXT, \
						   elemvalcontent TEXT, \
						   PRIMARY KEY ( elemvalid ) \
						   );"


/**
 \brief the base of the single instance document pool
 id: unique id of a document
 docdataid: unique number of the document stored in db. if -1 document is stored in fs
 docsrcsize: bytesize of document source (not encrytion)
 docsize: bytesize of data stored
 dochash: sha1 hash of the document used for single instance
 docpath: path in filesystem to the document
 hashtype: sha256|sha1|none  (2|1|0)
 encryptiontype: blowfish|none  (1|0)
*/
#define CREATE_TABLE_DOCUMENTMETA \
"CREATE TABLE documentmeta ( \
                             id INTEGER, \
                             docdataid INTEGER DEFAULT -1, \
                             docsrcsize INTEGER DEFAULT 0, \
                             docsize INTEGER DEFAULT 0, \
                             dochash TEXT DEFAULT '', \
                             docpath TEXT DEFAULT '', \
                             hashtype INTEGER DEFAULT 1, \
                             encryptiontype INTEGER DEFAULT 1, \
                             instancecount INTEGER DEFAULT 0, \
                             PRIMARY KEY ( id ) \
                         );"

/**
 \brief this table actually stores the data blob if storing in database is activated
 */
#define CREATE_TABLE_DOCUMENTDATA \
"CREATE TABLE documentdata ( \
                             id INTEGER, \
                             docdata BLOB DEFAULT '', \
                             PRIMARY KEY ( id ) \
                             );"
