//
//  MBDBDocumentEntry.h
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

#import <Cocoa/Cocoa.h>
#import "MBBaseDefinitions.h"

@class MBDBAccess;
@protocol MBDBAccessing;

@protocol MBDBDocumentEntryAccessing

+ (int)dbInsertDocumentData:(NSData *)data valuetype:(MBValueType)type dbConnection:(id<MBDBAccessing>)dbAccess;

// convenient allocators
+ (id)dbDocumentEntry;
+ (id)dbDocumentEntryByQueryingForDocId:(int)aDocId;
+ (id)dbDocumentEntryByQueryingForDocHash:(NSString *)aDocHash;

// special init methods
- (id)initWithDbConnection:(id<MBDBAccessing>)aDbConnection;
- (id)initByQueryingForDocId:(int)aDocId;
- (id)initByQueryingForDocHash:(NSString *)aDocHash;
- (id)initWithReadingFromRow:(ResultRow *)aRow;

// getter and setter for db connection
- (void)setDbConnection:(MBDBAccess<MBDBAccessing> *)aDbConnection;
- (MBDBAccess<MBDBAccessing> *)dbConnection;

/*
// setting the index for this elementvalue
- (void)setIndexValue:(NSString *)aText;
- (BOOL)createIndexEntryWithIdentifier:(NSString *)identifier;
*/

- (int)docId;
- (void)setDocId:(int)value;

- (int)docDataId;
- (void)setDocDataId:(int)value;

- (NSData *)docData:(MBValueType)type;
- (void)setDocData:(NSData *)value;

- (int)docSrcSize;
- (void)setDocSrcSize:(int)value;

- (int)docSize;
- (void)setDocSize:(int)value;

- (NSString *)docHash;
- (void)setDocHash:(NSString *)value;

- (NSString *)docPath;
- (void)setDocPath:(NSString *)value;

- (HashType)hashType;
- (void)setHashType:(HashType)value;

- (EncryptionType)encryptionType;
- (void)setEncryptionType:(EncryptionType)value;

- (int)instanceCount;
- (void)setInstanceCount:(int)value;

// delete
- (void)delete;
//- (void)deleteIndex;

@end


/**
this class implements abstract methods and should be overriden by subclasses
 */
@interface MBDBDocumentEntry : NSObject <MBDBDocumentEntryAccessing> {
	/** The db connection for this DBElement. */
	id<MBDBAccessing> dbConnection;
	
	int docId;
    int docDataId;
    int docSrcSize;
    int docSize;
    NSData *docData;
    NSString *docHash;
    NSString *docPath;
    HashType hashType;
    EncryptionType encryptionType;
    int instanceCount;
}

+ (NSString *)storagePathForDocumentHash:(NSString *)docHash createFolders:(BOOL)create;
/** returns the path to where the file has been stored */
+ (NSString *)fileInsertDocumentData:(NSData *)data withHash:(NSString *)dataHash valuetype:(MBValueType)type;

@end
