//
//  MBDBSqliteElementValue.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 20.07.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <CocoLogger/CocoLogger.h>
#import <SifSqlite/SifSqlite.h>
#import "MBDBSqliteElementValue.h"
#import "MBDBSqlite.h"
#import "MBElementValue.h"
#import "MBNSDataCryptoExtension.h"
#import "MBElementBaseController.h"
#import "MBDBDocumentEntry.h"
#import "MBDBSqliteDocumentEntry.h"
#import "NSData-Base64Extensions.h"
#import "NSString-Base64Extensions.h"

@implementation MBDBSqliteElementValue

#pragma mark - Initialization

+ (id<MBDBElementValueAccessing>)dbElementValueForElementValue:(MBElementValue *)aElemVal writeIndex:(BOOL)flag {
	return [[[MBDBSqliteElementValue alloc] initWithElementValue:aElemVal writeIndex:flag] autorelease];
}

- (id)init {
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"cannot alloc MBDBSqliteElementValue!");
	} else {
		// get MBDBSqlite connection
		[self setDbConnection:[MBDBSqlite sharedConnection]];
	}
	
	return self;
}

- (id)initWithDelegate:(id)aDelegate {
	self = [self init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"cannot alloc MBDBSqliteElementValue!");
	} else {
        // set delegate
        [self setDelegate:aDelegate];
	}
	
	return self;
}

- (id)initWithElementValue:(MBElementValue *)aElemVal writeIndex:(BOOL)flag {
	self = [self initWithDelegate:aElemVal];
	if(self == nil) {
		CocoLog(LEVEL_ERR, @"cannot alloc MBDBSqliteElementValue!");
	} else {
        
        // if this ElementValue and is single instance stored,
        // then get the documentId and set it instead of the real data which might be attached to this value
        int metaDocId = -1;
        if([aElemVal isSIStored] || ([aElemVal dbElementValue] && [[aElemVal dbElementValue] isSIStored])) {
            NSData *valData = [aElemVal valueDataAsData];
            if(valData != nil) {            
                NSString *dataHash = [valData sha1HashAsHexString];
                if(dataHash) {
                    // check for a single instance document
                    [self setDocumentEntry:[elementController documentEntryForHash:dataHash]];
                    if(documentEntry) {
                        metaDocId = [documentEntry docId];
                    }
                }
            }
        }

		// create new value and get value id
		valueid = [dbConnection createElementValueWithElementValue:aElemVal singleInstanceDocId:metaDocId];
        valueDataSize = [aElemVal valueDataSize];
        gpReg = [aElemVal gpReg];
		valuetype = (MBValueType) [aElemVal valuetype];
		if(valueid == -1) {
			CocoLog(LEVEL_ERR, @"cannot create value!");
		} else {
            
            // have we created a copy of this value?
            // then increment instance count
            if(metaDocId > -1 && valueid > -1) {
                [documentEntry setInstanceCount:[documentEntry instanceCount] + 1];
            }
            
			if(flag) {
				// create index for elementvalue
				int indexid = [dbConnection createIndexEntryWithElementValueID:valueid 
																 andIdentifier:[aElemVal identifier]];
				if(indexid == -1) {
					CocoLog(LEVEL_ERR,@"cannot create index!");
				}
			}
		}
	}
	
	return self;	
}

/**
 Dealloc of this class is called on closing this document
 */
- (void)dealloc {
	[self setDbConnection:nil];
    [self setDocumentEntry:nil];
	// dealloc object
	[super dealloc];
}

#pragma mark - Getter/Setter

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

/**
 Set the document entry
 */
- (void)setDocumentEntry:(MBDBDocumentEntry *)docEntry {
    if(documentEntry != docEntry) {
        [docEntry retain];
        [documentEntry release];
        documentEntry = docEntry;
    }
}

/**
 Get the document entry
 */
- (MBDBDocumentEntry *)documentEntry {
    return documentEntry;
}

/**
 Sets the index value for this elementvalue. MUST be UFT8 String
 Nothing is retained or held here.
 This is just used for searching in the database itself
 */
- (void)setIndexValue:(NSString *)aText {
	// write index value of this elementvalue
	NSString *sql = [NSString stringWithFormat:@"update valueindex set elemvalcontent='%@' where elemvalid=%d;",
		aText,
		valueid];
	
	// execute sql
	[dbConnection executeSql:sql];
	if([dbConnection errorCode] != DB_SUCCESS) {
		NSString *errMsg = [dbConnection errorMessage];
		if(errMsg != nil) {
			CocoLog(LEVEL_ERR, @"%@", errMsg);
		}		
	}	
}

/**
 Writes the value of this element value into the index table
 */
- (BOOL)createIndexEntryWithIdentifier:(NSString *)identifier {
	BOOL ret = YES;
	
	if(dbConnection) {
		// check return value
		int rc = [dbConnection createIndexEntryWithElementValueID:valueid andIdentifier:identifier];
		if(rc < 0) {
			ret = NO;
		}
	}
	
	return ret;
}

- (void)setValueid:(int)aValueid {
	valueid = aValueid;
}

- (void)setElementid:(int)aElemid {
	// write elementid value of attribute to the right attribute in db
	NSString *sql = [NSString stringWithFormat:@"update elementvalue set elementid=%d where id=%d;",
		aElemid,
		valueid];
	
	// execute sql
	[dbConnection executeSql:sql];
	if([dbConnection errorCode] != DB_SUCCESS) {
		NSString *errMsg = [dbConnection errorMessage];
		if(errMsg != nil) {
			CocoLog(LEVEL_ERR, @"%@", errMsg);
		}		
	}	
}

/**
 Update the identifier in elementvalue and valueindex
*/
- (void)setIdentifier:(NSString *)aIdentifier {
	if(aIdentifier != nil) {
		// write name value of elementvalue to the right attribute in db
		NSString *sql = [NSString stringWithFormat:@"update elementvalue ev, valueindex vi set ev.identifier='%@', vi.elemvalidentifier='%@' where id=%d;",
			aIdentifier,
			aIdentifier,
			valueid];
		
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

/**
 Set the new value data for this value
 Sqlite cannot handle binary data. So this NSData object is base64 encoded and saved to db.
*/
- (void)setValueData:(NSData *)aData {
	// but save to db in every way
	if(aData != nil) {
        // check for data size
        // if below SI threshold, do normal save
        // if above, save SI
        // but if there is new data, make sure the old doc instance is deleted/instance count reduced
        
        int len = [aData length];
        
        // prepare data
        NSString *elemValDataStr = @"";
        int elemValDataLen = len;
        
        if(len < SINGLE_INSTANCE_THRESHOLD) {
            // check, if this elementvalue has a valid documententry reference
            // if yes, we need to reduce the instancecount of the document entry and remove the reference
            if(documentEntry != nil) {
                [documentEntry setInstanceCount:[documentEntry instanceCount] - 1];
                [self setDocumentEntry:nil];
            }
            
            // the output string
            if(valuetype == BinaryValueType) {
                // do base64 encoding
                elemValDataStr = [aData encodeBase64WithNewlinesToString:NO];
            } else {
                elemValDataStr = [[[NSString alloc] initWithData:aData encoding:NSUTF8StringEncoding] autorelease];
            }
            
            elemValDataLen = [elemValDataStr length];
            // remove SI storage
            [self setIsSIStored:NO];
        } else {
            // check if the data has really changed by comparing the hashes of the old and new data
            // if it has not changed, do nothing
            // if it has changed, check if there is an instance of this hash already or load it from db and increment the instance count
            // if there is no instance, create one
            
            NSString *dataHash = [aData sha1HashAsHexString];
            if((documentEntry == nil) || ![dataHash isEqualToString:[documentEntry docHash]]) {
                // the data is new, check for an existing document with the hash in the pool
                MBDBDocumentEntry *docEntry = [elementController documentEntryForHash:dataHash];
                if(docEntry == nil) {
                    // no existing document for the given hash, create a new one
                    docEntry = [MBDBSqliteDocumentEntry dbDocumentEntry];
                    
                    // but first add data
                    NSString *path = @"";
                    int dataRowId = -1;
                    if([elementController docStorageType] == DocStorageFS) {
                        path = [MBDBDocumentEntry fileInsertDocumentData:aData withHash:dataHash valuetype:valuetype];
                    } else {
                        dataRowId = [MBDBSqliteDocumentEntry dbInsertDocumentData:aData valuetype:valuetype dbConnection:dbConnection];
                    }
                    
                    // store path or rowid
                    [docEntry setDocDataId:dataRowId];
                    [docEntry setDocPath:path];
                    //[docEntry setDocData:aData];
                    [docEntry setDocHash:dataHash];
                    [docEntry setDocSize:len];
                    [docEntry setInstanceCount:1];  // we are the only at the moment
                    
                    // create this entry
                    int metaRowId = [dbConnection createDocumentEntryForInstance:docEntry];
                    if(metaRowId > 0) {
                        [docEntry setDocId:metaRowId];
                        
                        // it may happen that this elementvalue already has a documentEntry instance
                        // in that case the instance co8unt of that one has to be reduced
                        if(documentEntry) {
                            [documentEntry setInstanceCount:[documentEntry instanceCount] - 1];
                        }
                        
                        // set the new documentEntry instance
                        [self setDocumentEntry:docEntry];
                    }
                } else {
                    // document available, increment instancecount
                    [docEntry setInstanceCount:[docEntry instanceCount] + 1];
                    // set this document
                    [self setDocumentEntry:docEntry];
                }
                
                // use the len to set SI data
                elemValDataLen = len;
                elemValDataStr = [NSString stringWithFormat:@"%d", [docEntry docId]];
                // copy docId
                [self setSiDocId:[docEntry docId]];
            } else {
                // on equal hash, do nothing
            }
            
            // set SI storage
            [self setIsSIStored:YES];
        }
        
        // update the element value entry
        NSString *sql = [NSString stringWithFormat:@"update elementvalue set valuedatasize=%d,valuedata='%@' where id=%d;",
            elemValDataLen,
            elemValDataStr,
            valueid];
        
        // execute sql
        [dbConnection executeSql:sql];
        if([dbConnection errorCode] != DB_SUCCESS) {
            NSString *errMsg = [dbConnection errorMessage];
            if(errMsg != nil) {
                CocoLog(LEVEL_ERR, @"%@", errMsg);
            }		
        }        
    } else {
        CocoLog(LEVEL_WARN,@"have no data to write, data pointer is NULL!");
    }
}

- (void)setGpReg:(int)aValue {
    gpReg = aValue;
    
	// write elementid value of attribute to the right attribute in db
	NSString *sql = [NSString stringWithFormat:@"update elementvalue set gpreg=%d where id=%d;",
		aValue,
		valueid];
	
	// execute sql
	[dbConnection executeSql:sql];
	if([dbConnection errorCode] != DB_SUCCESS) {
		NSString *errMsg = [dbConnection errorMessage];
		if(errMsg != nil) {
			CocoLog(LEVEL_ERR, @"%@", errMsg);
		}		
	}	
}

- (void)setValueDataSize:(int)aSize {
    valueDataSize = aSize;
    
	// write elementid value of attribute to the right attribute in db
	NSString *sql = [NSString stringWithFormat:@"update elementvalue set valuedatasize=%d where id=%d;",
		aSize,
		valueid];
	
	// execute sql
	[dbConnection executeSql:sql];
	if([dbConnection errorCode] != DB_SUCCESS) {
		NSString *errMsg = [dbConnection errorMessage];
		if(errMsg != nil) {
			CocoLog(LEVEL_ERR, @"%@", errMsg);
		}		
	}	
}

/**
 We need to buffer valuetype. If we have a binary value, we have to de/encode it as PList
*/
- (void)setValuetype:(MBValueType)aType {
	// write attributeid of value to the right value in db
	NSString *sql = [NSString stringWithFormat:@"update elementvalue set valuetype=%d where id=%d;",
		aType,
		valueid];
	
	// execute sql
	[dbConnection executeSql:sql];
	if([dbConnection errorCode] != DB_SUCCESS) {
		NSString *errMsg = [dbConnection errorMessage];
		if(errMsg != nil) {
			CocoLog(LEVEL_ERR, @"%@", errMsg);
		}		
	}
	
	valuetype = aType;
}

- (BOOL)isSIStored {
	BOOL ret = NO;
	
	int buf = gpReg & MBElementValueSIStored;
	if(buf > 0) {
		ret = YES;
	}
	
	return ret;    
}

- (void)setIsSIStored:(BOOL)flag {
	// we only set this, if we do not have an index already
	BOOL isSIStored = [self isSIStored];
	if(!isSIStored && flag) {
		// set
        gpReg = (gpReg | MBElementValueSIStored);
		[self setGpReg:gpReg];
	} else if(isSIStored && !flag) {
		// unset
		int mask = ~MBElementValueSIStored;
        gpReg = (gpReg & mask);
		[self setGpReg:gpReg];
	}
    
    // notify delegate that SI has changed
    if(delegate) {
        [delegate performSelector:@selector(singleInstanceStorageChange:) withObject:[NSNumber numberWithInt:gpReg]];
    }
}

- (int)valueid {
	return valueid;
}

- (int)elementid {
	int elementid = -1;
	
	// sql statement
	NSString *sql = [NSString stringWithFormat:@"select elementid from elementvalue where id=%d;",valueid];
	
	// execute sql
	NSArray *result = [dbConnection executeQuery:sql];
	if([dbConnection errorCode] != DB_SUCCESS) {
		NSString *errMsg = [dbConnection errorMessage];
		if(errMsg != nil) {
			CocoLog(LEVEL_ERR, @"%@", errMsg);
		}
	} else {
		// check for result
		if(result == nil) {
			CocoLog(LEVEL_WARN,@"have nil result from query!");
		} else {
			// read valuedata from dict
			// this should only be one entry
			if([result count] == 1) {
				ResultRow *row = [result objectAtIndex:0];
				// get valueid col
				elementid = [[[row findColumnForName:@"elementid"] value] intValue];
			} else {
				CocoLog(LEVEL_WARN,@"incorrect number of results!");
			}
		}
	}
	
	return elementid;
}

- (NSString *)identifier {
	NSString *identifier = nil;
	
	// sql statement
	NSString *sql = [NSString stringWithFormat:@"select identifier from elementvalue where id=%d;",valueid];
	
	// execute sql
	NSArray *result = [dbConnection executeQuery:sql];
	if([dbConnection errorCode] != DB_SUCCESS) {
		NSString *errMsg = [dbConnection errorMessage];
		if(errMsg != nil) {
			CocoLog(LEVEL_ERR, @"%@", errMsg);
		}
	} else {
		// check for result
		if(result == nil) {
			CocoLog(LEVEL_WARN,@"have nil result from query!");
		} else {
			// read valuedata from dict
			// this should only be one entry
			if([result count] == 1) {
				ResultRow *row = [result objectAtIndex:0];
				// get valueid col
				identifier = [[row findColumnForName:@"identifier"] value];
			} else {
				CocoLog(LEVEL_WARN,@"incorrect number of results!");
			}
		}
	}
	
	return identifier;
}

/**
 Returns the value data.
*/
- (NSData *)valueData {
	NSData *data = nil;
	
    NSString *val = @"";
    
    // sql statement
    NSString *sql = [NSString stringWithFormat:@"select valuedata from elementvalue where id=%d;",valueid];
    
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
        CocoLog(LEVEL_WARN, @"have nil result from query!");
    } else {
        // read valuedata from dict
        // this should only be one entry
        if([result count] == 1) {
            ResultRow *row = [result objectAtIndex:0];
            val = [[row findColumnForName:@"valuedata"] value];
        } else {
            CocoLog(LEVEL_WARN,@"incorrect number of results!");
        }
    }

    // SI stored
    if([self isSIStored]) {
        if(val != nil) {
            // get meta doc id when stored as SI
            int docId = [val intValue];
            if(documentEntry == nil) {
                // get document entry
                [self setDocumentEntry:[elementController documentEntryForId:docId]];
            }
            
            if(documentEntry == nil) {
                CocoLog(LEVEL_WARN, @"could not get DocumentEntry!");
            } else {
                data = [documentEntry docData:valuetype];
            }
        }
    } else {
        // check for valuetype
        if(valuetype == BinaryValueType) {
            // get valuedata column
            //data = [[NSData alloc] initWithBase64EncodedString:[dict objectForKey:val]];
            data = [val decodeBase64WithNewlines:NO];
        } else {
            // no decoding needed
            data = [val dataUsingEncoding:NSUTF8StringEncoding];
        }
    }

	return data;
}

- (MBValueType)valuetype {
	// sql statement
	NSString *sql = [NSString stringWithFormat:@"select valuetype from elementvalue where id=%d;",valueid];
	
	// execute sql
	NSArray *result = [dbConnection executeQuery:sql];
	if([dbConnection errorCode] != DB_SUCCESS) {
		NSString *errMsg = [dbConnection errorMessage];
		if(errMsg != nil) {
			CocoLog(LEVEL_ERR, @"%@", errMsg);
		}
	} else {
		// check for result
		if(result == nil) {
			CocoLog(LEVEL_WARN,@"have nil result from query!");
		} else {
			// read valuedata from dict
			// this should only be one entry
			if([result count] == 1) {
				ResultRow *row = [result objectAtIndex:0];
				// get valueid col
				valuetype = (MBValueType) [[[row findColumnForName:@"valuetype"] value] intValue];
			} else {
				CocoLog(LEVEL_WARN,@"incorrect number of results!");
			}
		}
	}
	
	return valuetype;	
}

- (int)gpReg {
	int gpreg = 0;
	
	// sql statement
	NSString *sql = [NSString stringWithFormat:@"select gpreg from elementvalue where id=%d;",valueid];
	
	// execute sql
	NSArray *result = [dbConnection executeQuery:sql];
	if([dbConnection errorCode] != DB_SUCCESS) {
		NSString *errMsg = [dbConnection errorMessage];
		if(errMsg != nil) {
			CocoLog(LEVEL_ERR, @"%@", errMsg);
		}
	} else {
		// check for result
		if(result == nil) {
			CocoLog(LEVEL_WARN,@"have nil result from query!");
		} else {
			// read valuedata from dict
			// this should only be one entry
			if([result count] == 1) {
				ResultRow *row = [result objectAtIndex:0];
				// get gpreg col
				gpreg = [[[row findColumnForName:@"gpreg"] value] intValue];
			} else {
				CocoLog(LEVEL_WARN,@"incorrect number of results!");
			}
		}
	}
	
	return gpreg;	
}

- (int)valueDataSize {
	// sql statement
	NSString *sql = [NSString stringWithFormat:@"select valuedatasize from elementvalue where id=%d;",valueid];
	
	// execute sql
	NSArray *result = [dbConnection executeQuery:sql];
	if([dbConnection errorCode] != DB_SUCCESS) {
		NSString *errMsg = [dbConnection errorMessage];
		if(errMsg != nil) {
			CocoLog(LEVEL_ERR, @"%@", errMsg);
		}
	} else {
		// check for result
		if(result == nil) {
			CocoLog(LEVEL_WARN,@"have nil result from query!");
		} else {
			// read valuedata from dict
			// this should only be one entry
			if([result count] == 1) {
				ResultRow *row = [result objectAtIndex:0];
				// get valuedatasize col
				valueDataSize = [[[row findColumnForName:@"valuedatasize"] value] intValue];
			} else {
				CocoLog(LEVEL_WARN,@"incorrect number of results!");
			}
		}
	}
	
	return valueDataSize;	
}

/**
 Delete the value in elementvalue and the index in valueindex
 */
- (void)delete {
    // decrement instance count of the connected documentEntry
    if([self isSIStored]) {
        if(documentEntry != nil) {
            [documentEntry setInstanceCount:[documentEntry instanceCount] - 1];        
        } else {
            CocoLog(LEVEL_ERR, @"is stored SI but have no documentEntry instance!");
        }
    }

	// delete the elementvalue
	NSString *sql = [NSString stringWithFormat:@"delete from elementvalue where id=%d;",valueid];
	// execute sql
	[dbConnection executeSql:sql];
	if([dbConnection errorCode] != DB_SUCCESS) {
		NSString *errMsg = [dbConnection errorMessage];
		if(errMsg != nil) {
			CocoLog(LEVEL_ERR, @"%@", errMsg);
		}		
	}
	    
	// delete index as well
	[self deleteIndex];
}

/**
 Delete index to this elementvalue
*/
- (void)deleteIndex {
	// delete the index entry
	NSString *sql = [NSString stringWithFormat:@"delete from valueindex where elemvalid=%d;",valueid];	
	// execute sql
	[dbConnection executeSql:sql];
	if([dbConnection errorCode] != DB_SUCCESS) {
		NSString *errMsg = [dbConnection errorMessage];
		if(errMsg != nil) {
			CocoLog(LEVEL_ERR, @"%@", errMsg);
		}		
	}	
}

- (void)setElementValue:(MBElementValue *)elemVal {
	if(elemVal != nil) {
		valueid = [elemVal valueid];
		valuetype = (MBValueType) [elemVal valuetype];
        gpReg = [elemVal gpReg];
	}
}

@end

/**
 Converter methods
 */
@implementation MBDBSqliteElementValue (converters)

+ (NSData *)encodeData:(NSData *)data withPListFormat:(NSPropertyListFormat)format {
	// if we deal with text values, we have to archive the nsdata
	NSMutableData *valueAsData = [NSMutableData data];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:valueAsData];
	//[archiver setOutputFormat:format];
	[archiver encodeObject:data];
	//[archiver finishEncoding];
	// release archiver
	[archiver release];
	
	return valueAsData;
}

+ (NSData *)decodeData:(NSData *)plistData {
	// decode the rtfd data
	NSKeyedUnarchiver *unarchiver = [[[NSKeyedUnarchiver alloc] initForReadingWithData:plistData] autorelease];
	return [unarchiver decodeObject];
}

@end