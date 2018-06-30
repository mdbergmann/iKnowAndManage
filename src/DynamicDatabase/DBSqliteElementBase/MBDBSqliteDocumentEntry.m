//
//  MBDBSqliteDocumentEntry.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 22.07.07.
//  Copyright 2007 mabe. All rights reserved.
//

// $Author: $
// $HeadURL: $
// $LastChangedBy: $
// $LastChangedDate: $
// $Rev: $

#import <CocoLogger/CocoLogger.h>
#import <SifSqlite/SifSqlite.h>
#import "MBDBSqliteDocumentEntry.h"
#import "NSData-Base64Extensions.h"
#import "MBDBAccess.h"
#import "MBElementBaseController.h"
#import "NSString-Base64Extensions.h"

@implementation MBDBSqliteDocumentEntry

#pragma mark - Initialization

/**
 Returns the row id of the inserted db entry 
 Subclasses should oberride this method
 */
+ (int)dbInsertDocumentData:(NSData *)data valuetype:(MBValueType)type dbConnection:(MBDBAccess<MBDBAccessing> *)dbAccess {
    int ret = -1;
    
    if(data == nil) {
        CocoLog(LEVEL_ERR, @"nil data!");
    } else {
        // the output string
        NSString *stringData = nil;
        //const char *cStrData = NULL;
        if(type == BinaryValueType) {
            // do base64 encoding
            stringData = [data encodeBase64WithNewlines:NO];
        } else {
            stringData = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
            //cStrData = [aData bytes];
        }

        if(stringData != nil) {
            ret = [dbAccess createDocumentDataEntry:stringData];
        } else {
            CocoLog(LEVEL_ERR, @"could not convert to string!");
        }
    }
    
    return ret;
}

// convenient allocators
+ (id)dbDocumentEntry {
    return [[[MBDBSqliteDocumentEntry alloc] init] autorelease];
}

+ (id)dbDocumentEntryByQueryingForDocId:(int)aDocId {
    return [[[MBDBSqliteDocumentEntry alloc] initByQueryingForDocId:aDocId] autorelease];
}

+ (id)dbDocumentEntryByQueryingForDocHash:(NSString *)aDocHash {
    return [[[MBDBSqliteDocumentEntry alloc] initByQueryingForDocHash:aDocHash] autorelease];    
}

- (id)init {
	return [super init];
}

- (id)initWithReadingFromRow:(ResultRow *)aRow {
    self = [self init];
    if(self) {
        if(aRow) {
            docId = [[[aRow findColumnForName:@"id"] value] intValue];
            docDataId = [[[aRow findColumnForName:@"docdataid"] value] intValue];
            hashType = (HashType) [[[aRow findColumnForName:@"hashtype"] value] intValue];
            encryptionType = (EncryptionType) [[[aRow findColumnForName:@"encryptiontype"] value] intValue];
            docSize = [[[aRow findColumnForName:@"docsize"] value] intValue];
            docSrcSize = [[[aRow findColumnForName:@"docsrcsize"] value] intValue];
            instanceCount = [[[aRow findColumnForName:@"instancecount"] value] intValue];
            docHash = [[[aRow findColumnForName:@"dochash"] value] retain];
            docPath = [[[aRow findColumnForName:@"docpath"] value] retain];
            // set default connection
            [self setDbConnection:[MBDBAccess sharedConnection]];
        }
    }
    
    return self;
}

- (id)initWithDbConnection:(MBDBAccess<MBDBAccessing> *)aDbConnection {
    self = [self init];
    if(self) {
        // for querying, we need a db connection object
        [self setDbConnection:aDbConnection];
    }
    
    return self;
}

- (id)initByQueryingForDocId:(int)aDocId {
    self = [self init];
    if(self) {
        // for querying, we need a db connection object
        [self setDbConnection:[MBDBAccess sharedConnection]];

        // do the query
        ResultRow *row = [[self dbConnection] readDocumentEntryForDocId:aDocId];
        if(row == nil) {
            CocoLog(LEVEL_WARN, @"Dictionary is nil!");
        } else {
            [self setInstanceValuesFromRow:row];
        }
    } else {
        CocoLog(LEVEL_ERR, @"could not init!");
    }
    
    return self;
}

/**
 Create an instance of this document entry from a doc hash
 */
- (id)initByQueryingForDocHash:(NSString *)aDocHash {
    self = [self init];
    if(self) {
        // for querying, we need a db connection object
        [self setDbConnection:[MBDBAccess sharedConnection]];
        
        // do query
        ResultRow *row = [[self dbConnection] readDocumentEntryForHashValue:aDocHash];
        if(row == nil) {
            CocoLog(LEVEL_WARN, @"Dictionary is nil!");
        } else {
            [self setInstanceValuesFromRow:row];
        }
    } else {
        CocoLog(LEVEL_ERR, @"could not init!");
    }
    
    return self;
}

/**
 Dealloc of this class is called on closing this document
 */
- (void)dealloc {
	// release our db connection
	[self setDbConnection:nil];
    
    [self setDocPath:nil];
    [self setDocHash:nil];
    //[self setDocData:nil];
	
	// dealloc object
	[super dealloc];
}

/**
 Set all instance values from dictionary
 The valus in the dictionary have been read from the database
 */
- (void)setInstanceValuesFromRow:(ResultRow *)aRow {
    docId = [[[aRow findColumnForName:@"id"] value] intValue];
    docDataId = [[[aRow findColumnForName:@"docdataid"] value] intValue];
    docSize = [[[aRow findColumnForName:@"docsize"] value] intValue];
    docSrcSize = [[[aRow findColumnForName:@"docsrcsize"] value] intValue];
    instanceCount = [[[aRow findColumnForName:@"instancecount"] value] intValue];
    hashType = (HashType) [[[aRow findColumnForName:@"hashtype"] value] intValue];
    encryptionType = (EncryptionType) [[[aRow findColumnForName:@"encryptiontype"] value] intValue];
    
    docHash = [[[aRow findColumnForName:@"dochash"] value] retain];
    docPath = [[[aRow findColumnForName:@"docpath"] value] retain];
}

/**
 Set the db connection for this object
 @param aDbConnection a connected and open connection to a db
 */
- (void)setDbConnection:(MBDBAccess<MBDBAccessing> *)aDbConnection {
	// we want to hold our own reference
    [aDbConnection retain];
	[dbConnection release];
	dbConnection = aDbConnection;
}

/**
 Get the db connection of this object
 @return connected and open connection to a db
 */
- (MBDBAccess<MBDBAccessing> *)dbConnection {
	return dbConnection;
}

/*
// setting the index for this elementvalue
- (void)setIndexValue:(NSString *)aText
{

}

- (BOOL)createIndexEntryWithIdentifier:(NSString *)identifier
{
    return YES;
}
*/

- (int)docId {
    return docId;
}

- (void)setDocId:(int)value {
    if (docId != value) {
        docId = value;
    }
}

- (int)docDataId {
    return docDataId;
}

- (void)setDocDataId:(int)value {
    if(docDataId != value) {
        /*
        if(value > 0)
        {
            NSString *sql = [NSString stringWithFormat:@"update documentmeta set docdataid=%d where id=%d;",
                value,
                docId];
            
            // execute sql
            [dbConnection executeSql:sql];
            if([dbConnection errorCode] != DB_SUCCESS)
            {
                NSString *errMsg = [dbConnection errorMessage];
                if(errMsg != nil)
                {
                    CocoLog(LEVEL_ERR,errMsg);
                }		
            }
        }
         */
        
        docDataId = value;
    }
}

/**
 Check where to load from:
 - this can be file or db
 */
- (NSData *)docData:(MBValueType)type {
    NSData *ret = nil;
    
    if([elementController docStorageType] == DocStorageFS) {
        // load from file
        NSString *path = docPath;
        if(path == nil) {
            path = [MBDBDocumentEntry storagePathForDocumentHash:docHash createFolders:NO];
        }
        // add to basepath
        path = [[elementController docStoragePath] stringByAppendingPathComponent:path];
        // on file, no conversation from Base64 needed
        ret = [NSData dataWithContentsOfFile:path];
    } else {
        // load from db

        // sql statement
        NSString *sql = [NSString stringWithFormat:@"select docdata from documentdata where id=%d;", docDataId];
        
        // execute sql
        NSArray *result = [dbConnection executeQuery:sql];
        if([dbConnection errorCode] != DB_SUCCESS) {
            NSString *errMsg = [dbConnection errorMessage];
            if(errMsg != nil) {
                CocoLog(LEVEL_ERR, @"%@", errMsg);
            }
        }        

        // check for result
        if(result == nil) {
            CocoLog(LEVEL_WARN,@"have nil result from query!");
        } else {
            // read valuedata from dict
            // this should only be one entry
            if([result count] == 1) {
                NSDictionary *dict = [result objectAtIndex:0];
                // check for valuetype
                if(type == BinaryValueType) {
                    // get valuedata column
                    ret = [[dict objectForKey:@"docdata"] decodeBase64WithNewlines:NO];
                } else {
                    // no decoding needed
                    ret = [[dict objectForKey:@"docdata"] dataUsingEncoding:NSUTF8StringEncoding];
                }
            } else {
                CocoLog(LEVEL_WARN,@"incorrect number of results!");
            }
        }
    }
    
    return ret;
}

/**
 Not stored here
 */
- (void)setDocData:(NSData *)value {
    if(docData != value) {
        [value retain];
        [docData release];
        docData = value;
    }
}

- (int)docSrcSize {
    return docSrcSize;
}

- (void)setDocSrcSize:(int)value {
    if (docSrcSize != value) {
        /*
        if(value > 0)
        {
            NSString *sql = [NSString stringWithFormat:@"update documentmeta set docsrcsize=%d where id=%d;",
                value,
                docId];
            
            // execute sql
            [dbConnection executeSql:sql];
            if([dbConnection errorCode] != DB_SUCCESS)
            {
                NSString *errMsg = [dbConnection errorMessage];
                if(errMsg != nil)
                {
                    CocoLog(LEVEL_ERR,errMsg);
                }		
            }
        }
         */

        docSrcSize = value;
    }
}

- (int)docSize {
    return docSize;
}

- (void)setDocSize:(int)value {
    if (docSize != value) {
        /*
        if(value > 0)
        {
            NSString *sql = [NSString stringWithFormat:@"update documentmeta set docsize=%d where id=%d;",
                value,
                docId];
            
            // execute sql
            [dbConnection executeSql:sql];
            if([dbConnection errorCode] != DB_SUCCESS)
            {
                NSString *errMsg = [dbConnection errorMessage];
                if(errMsg != nil)
                {
                    CocoLog(LEVEL_ERR,errMsg);
                }		
            }
        }
         */

        docSize = value;
    }
}

- (NSString *)docHash {
    return docHash;
}

- (void)setDocHash:(NSString *)value {
    if(docHash != value)  {
        /*
        if(value != nil)
        {
            NSString *sql = [NSString stringWithFormat:@"update documentmeta set dochash='%@' where id=%d;",
                value,
                docId];
            
            // execute sql
            [dbConnection executeSql:sql];
            if([dbConnection errorCode] != DB_SUCCESS)
            {
                NSString *errMsg = [dbConnection errorMessage];
                if(errMsg != nil)
                {
                    CocoLog(LEVEL_ERR,errMsg);
                }		
            }
        }
         */

        [docHash release];
        docHash = [value copy];
    }
}

- (NSString *)docPath {
    return docPath;
}

- (void)setDocPath:(NSString *)value {
    if(docPath != value) {
        /*
        if(value != nil)
        {
            NSString *sql = [NSString stringWithFormat:@"update documentmeta set docpath='%@' where id=%d;",
                value,
                docId];
            
            // execute sql
            [dbConnection executeSql:sql];
            if([dbConnection errorCode] != DB_SUCCESS)
            {
                NSString *errMsg = [dbConnection errorMessage];
                if(errMsg != nil)
                {
                    CocoLog(LEVEL_ERR,errMsg);
                }		
            }
        }
         */

        [docPath release];
        docPath = [value copy];
    }
}

- (HashType)hashType {
    return hashType;
}

- (void)setHashType:(HashType)value {
    if(hashType != value) {
        /*
        if(value > 0)
        {
            NSString *sql = [NSString stringWithFormat:@"update documentmeta set hashtype=%d where id=%d;",
                value,
                docId];
            
            // execute sql
            [dbConnection executeSql:sql];
            if([dbConnection errorCode] != DB_SUCCESS)
            {
                NSString *errMsg = [dbConnection errorMessage];
                if(errMsg != nil)
                {
                    CocoLog(LEVEL_ERR,errMsg);
                }		
            }
        }
         */

        hashType = value;
    }
}

- (EncryptionType)encryptionType {
    return encryptionType;
}

- (void)setEncryptionType:(EncryptionType)value {
    if(encryptionType != value) {
        /*
        if(value > 0)
        {
            NSString *sql = [NSString stringWithFormat:@"update documentmeta set encryptiontype=%d where id=%d;",
                value,
                docId];
            
            // execute sql
            [dbConnection executeSql:sql];
            if([dbConnection errorCode] != DB_SUCCESS)
            {
                NSString *errMsg = [dbConnection errorMessage];
                if(errMsg != nil)
                {
                    CocoLog(LEVEL_ERR,errMsg);
                }		
            }
        }
         */

        encryptionType = value;
    }
}

- (int)instanceCount {
    return instanceCount;
}

/**
 Instance count is the only value that gets updated
 */
- (void)setInstanceCount:(int)value {
    if(instanceCount != value) {
        instanceCount = value;
        
        if(docId > 0) {
            if(instanceCount <= 0) {
                // delete
                [self delete];
            } else {        
                // if we havea db connection, update this value in db
                if(dbConnection != nil) {
                    NSString *sql = [NSString stringWithFormat:@"update documentmeta set instancecount=%d where id=%d;",
                        value,
                        docId];
                    
                    // execute sql
                    [dbConnection executeSql:sql];
                    if([dbConnection errorCode] != DB_SUCCESS) {
                        NSString *errMsg = [dbConnection errorMessage];
                        if(errMsg != nil) {
                            CocoLog(LEVEL_ERR, @"%@", errMsg);
                        }		
                    }        
                }
            }
        }
    }
}

- (void)delete {
    // only delete if we have a instncecount of 0
    if(instanceCount <= 0) {
        // if docDataId is < 0 then this document is stored in fs
        if([elementController docStorageType] == DocStorageFS) {
            NSString *relPath = docPath;
            if(relPath == nil) {
                relPath = [MBDBDocumentEntry storagePathForDocumentHash:docHash createFolders:NO];
            }
            NSString *fullPath = [[elementController docStoragePath] stringByAppendingPathComponent:relPath];
            // if file exists, delete it
            NSFileManager *fm = [NSFileManager defaultManager];
            if([fm fileExistsAtPath:fullPath]) {
                [fm removeItemAtPath:fullPath error:NULL];
            }            
        } else {
            // delete the document data entry
            NSString *sql = [NSString stringWithFormat:@"delete from documentdata where id=%d;", docDataId];
            // execute sql
            [dbConnection executeSql:sql];
            if([dbConnection errorCode] != DB_SUCCESS) {
                NSString *errMsg = [dbConnection errorMessage];
                if(errMsg != nil) {
                    CocoLog(LEVEL_ERR, @"%@", errMsg);
                }
            }
        }
        
        // delete the meta entry
        NSString *sql = [NSString stringWithFormat:@"delete from documentmeta where id=%d;", docId];
        // execute sql
        [dbConnection executeSql:sql];
        if([dbConnection errorCode] != DB_SUCCESS) {
            NSString *errMsg = [dbConnection errorMessage];
            if(errMsg != nil) {
                CocoLog(LEVEL_ERR, @"%@", errMsg);
            }		
        }        
    }
}

@end
