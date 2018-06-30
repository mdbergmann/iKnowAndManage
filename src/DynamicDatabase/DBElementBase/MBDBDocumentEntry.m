//
//  MBDBDocumentEntry.m
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
#import "MBDBDocumentEntry.h"
#import "MBElementBaseController.h"


@implementation MBDBDocumentEntry

+ (NSString *)storagePathForDocumentHash:(NSString *)docHash createFolders:(BOOL)create {
    // get path
    NSString *ret = @"";
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSString *basePath = [elementController docStoragePath];
    // according to hashvalue
    NSString *hash = docHash;
    // we loop and take two letters, 5 times
    NSUInteger i;
    for(i = 0;i < 5;i++) {
        NSString *subStr = [hash substringWithRange:NSMakeRange((i * 2), 2)];
        ret = [ret stringByAppendingPathComponent:subStr];
        if(create) {
            if(![fm fileExistsAtPath:ret]) {
                // create
                [fm createDirectoryAtPath:[basePath stringByAppendingPathComponent:ret] attributes:nil];
            }
        }
    }
    
    // append the full filename
    ret = [ret stringByAppendingPathComponent:hash];
    
    return ret;
}

/** returns the path to where the file has been stored */
+ (NSString *)fileInsertDocumentData:(NSData *)data withHash:(NSString *)dataHash valuetype:(MBValueType)type; {
    NSString *ret = nil;
    
    if(data != nil) {
        // get path to store it to
        ret = [MBDBDocumentEntry storagePathForDocumentHash:dataHash createFolders:YES];
        NSString *fullPath = [[elementController docStoragePath] stringByAppendingPathComponent:ret];
        // write data
        BOOL success = [data writeToFile:fullPath atomically:YES];
        if(!success) {
            CocoLog(LEVEL_ERR, @"[MBDBDocumentEntry -fileInsertDocumentData:] could not write data to file: %@", ret);
            ret = nil;
        }
    } else {
        CocoLog(LEVEL_ERR, @"[MBDBDocumentEntry -insertDocumentDataToFile:] nil data!");
    }
    
    return ret;
}

/**
    returns the row id of the inserted db entry 
    subclasses should oberride this method
*/
+ (int)dbInsertDocumentData:(NSData *)data valuetype:(MBValueType)type dbConnection:(id<MBDBAccessing>)dbAccess {
    return -1;
}

// convenient allocators
+ (id)dbDocumentEntry {
    return nil;
}

+ (id)dbDocumentEntryByQueryingForDocId:(int)aDocId {
    return nil;
}

+ (id)dbDocumentEntryByQueryingForDocHash:(NSString *)aDocHash {
    return nil;
}

// special init methods
- (id)init {
    self = [super init];
    if(self) {
        // set initial values
		docId = -1;
        docDataId = -1;
        hashType = HashNone;
        encryptionType = EncryptionNone;
        docSize = 0;
        docSrcSize = 0;
        instanceCount = -1;
        //[self setDocData:nil];
        docHash = [[NSString alloc] initWithString:@""];
        docPath = [[NSString alloc] initWithString:@""];        
    }
    
    return self;
}

- (id)initWithReadingFromRow:(ResultRow *)aRow {
    return [self init];
}

- (id)initWithDbConnection:(id<MBDBAccessing>)aDbConnection {
    return [self init];
}

- (id)initByQueryingForDocId:(int)aDocId {
    return [self init];
}

- (id)initByQueryingForDocHash:(NSString *)aDocHash {
    return [self init];
}

    // getter and setter for db connection
- (void)setDbConnection:(id<MBDBAccessing>)aDbConnection {}
- (id<MBDBAccessing>)dbConnection {
    return nil;
}

/*
    // setting the index for this elementvalue
- (void)setIndexValue:(NSString *)aText
{}
- (BOOL)createIndexEntryWithIdentifier:(NSString *)identifier
{
    return NO;
}
*/

- (int)docId {
    return -1;
}

- (void)setDocId:(int)value {}

- (int)docDataId {
    return -1;
}

- (void)setDocDataId:(int)value {}

- (NSData *)docData:(MBValueType)type {
    return nil;
}

- (void)setDocData:(NSData *)value {}

- (int)docSrcSize {
    return -1;
}

- (void)setDocSrcSize:(int)value {}

- (int)docSize {
    return -1;
}

- (void)setDocSize:(int)value {}

- (NSString *)docHash {
    return nil;
}

- (void)setDocHash:(NSString *)value {}

- (NSString *)docPath {
    return nil;
}

- (void)setDocPath:(NSString *)value {}

- (HashType)hashType {
    return -1;
}

- (void)setHashType:(HashType)value {}

- (EncryptionType)encryptionType {
    return -1;
}

- (void)setEncryptionType:(EncryptionType)value {}

- (int)instanceCount {
    return -1;
}

- (void)setInstanceCount:(int)value {}

- (void)delete {}

- (void)dealloc {
    [docHash release];
    [docPath release];
    [docData release];
    [super dealloc];
}
/*
- (void)deleteIndex
{}
*/

@end
