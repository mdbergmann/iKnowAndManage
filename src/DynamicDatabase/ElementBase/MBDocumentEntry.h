//
//  MBDocumentEntry.h
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
#import <MBBaseDefinitions.h>

@interface MBDBDocumentEntry : NSObject
{
    int docId;
    int docDataId;
    NSData *docData;
    int docSrcSize;
    int docSize;
    NSString *docHash;
    NSString *docPath;
    HashType hashType;
    EncryptionType encryptionType;
    int instanceCount;
    
    id dbDocumentEntry;
}

/**
\brief return autoreleased DocumentEntry object
 */
+ (id)documentEntry;

- (id)init;

// dbValue stuff
- (void)setDbDocumentEntry:(id)aDbDocumentEntry;
- (id)dbDocumentEntry;
- (void)setIsDbConnected:(BOOL)aBool writeIndex:(BOOL)flag;
- (BOOL)isDbConnected;

- (int)docId;
- (void)setDocId:(int)value;

- (int)docDataId;
- (void)setDocDataId:(int)value;

- (NSData *)docData;
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
- (void)setInstanceCount:(int)count;

// deleting
- (void)delete;

@end
