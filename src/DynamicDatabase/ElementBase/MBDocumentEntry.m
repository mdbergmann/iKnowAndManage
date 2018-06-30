//
//  MBDocumentEntry.m
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

#import "MBDocumentEntry.h"


@implementation MBDBDocumentEntry

/**
\brief return autoreleased DocumentEntry object
 */
+ (id)documentEntry
{
    MBDocumentEntry *entry = [[MBDocumentEntry alloc] init];
    
    return [entry autorelease];
}

- (id)init
{
    self = [super init];
    if(self)
    {
        // do initialization here
    }
    
    return self;
}

- (int)docId
{
    return docId;
}

// dbValue stuff
- (void)setDbDocumentEntry:(id)aDbDocumentEntry
{

}

- (id)dbDocumentEntry
{

}

/**
\brief set the dbConnection object
 */
- (void)setDbDocumentEntry:(id)aDbDocumentEntry
{
	[aDbDocumentEntry retain];
	[dbDocumentEntry release];
	dbDocumentEntry = aDbDocumentEntry;	
}

/**
\brief connect this value, create a dbElementValue
 */
- (void)setIsDbConnected:(BOOL)aBool writeIndex:(BOOL)flag
{
	if(([self isDbConnected] == NO) && (aBool == YES))
	{
		[self setDbElementValue:[MBDBSqliteElementValue dbElementValueForElementValue:self writeIndex:flag]];
		// take valueid and dates from dbElementValue
		[self setValueid:[dbElementValue valueid]];
		
		// set gpreg
		if(flag)
		{
			[self setHasIndex:YES];
		}
		
		// reset the valueData of this MBElementValue
		// we don't have the space to hold bigger data twice
		// dbElementValue will keep track of valueData
		if((dataHoldThreshold == 0) || (valueDataSize > dataHoldThreshold))
		{
			[valueData release];
			valueData = nil;
		}
	}
	else if(([self isDbConnected] == YES) && (aBool == NO))
	{
		// unset has index
		[self setHasIndex:NO];
	}
}

- (void)setDocId:(int)value
{
    if (docId != value)
    {
        docId = value;
    }
}

- (int)docDataId
{
    return docDataId;
}

- (void)setDocDataId:(int)value
{
    if (docDataId != value)
    {
        docDataId = value;
    }
}

- (NSData *)docData
{
    return [[docData retain] autorelease];
}

- (void)setDocData:(NSData *)value
{
    if (docData != value)
    {
        [docData release];
        docData = [value copy];
    }
}

- (int)docSrcSize
{
    return docSrcSize;
}

- (void)setDocSrcSize:(int)value
{
    if (docSrcSize != value)
    {
        docSrcSize = value;
    }
}

- (int)docSize
{
    return docSize;
}

- (void)setDocSize:(int)value
{
    if (docSize != value)
    {
        docSize = value;
    }
}

- (NSString *)docHash
{
    return [[docHash retain] autorelease];
}

- (void)setDocHash:(NSString *)value
{
    if (docHash != value)
    {
        [docHash release];
        docHash = [value copy];
    }
}

- (NSString *)docPath
{
    return [[docPath retain] autorelease];
}

- (void)setDocPath:(NSString *)value
{
    if (docPath != value) 
    {
        [docPath release];
        docPath = [value copy];
    }
}

- (HashType)hashType
{
    return [[hashType retain] autorelease];
}

- (void)setHashType:(HashType)value
{
    if (hashType != value)
    {
        [hashType release];
        hashType = [value copy];
    }
}

- (EncryptionType)encryptionType
{
    return [[encryptionType retain] autorelease];
}

- (void)setEncryptionType:(EncryptionType)value
{
    if (encryptionType != value)
    {
        [encryptionType release];
        encryptionType = [value copy];
    }
}

@end
