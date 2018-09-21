
//  MBFileItemValue.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 31.08.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import "MBFileItemValue.h"
#import "MBImageItemValue.h"
#import "MBExtendedTextItemValue.h"
#import "MBValueIndexController.h"
#import "MBElement.h"
#import "MBExporter.h"
#import "MBElementValue.h"
#import "globals.h"

@interface MBFileItemValue (privateAPI)

- (NSString *)identifierValueDataForClassType;
- (NSString *)identifierIsLinkForClassType;
- (NSString *)identifierLinkValueForClassType;
- (NSString *)identifierAutoLoadForClassType;

@end

@implementation MBFileItemValue (privateAPI)

- (NSString *)identifierValueDataForClassType {
    NSString *ret = ITEMVALUE_FILE_DATAVALUE_IDENTIFIER;    
    if([self isKindOfClass:[MBImageItemValue class]]) {
        ret = ITEMVALUE_IMAGE_VALUE_IDENTIFIER;
    } else if([self isKindOfClass:[MBExtendedTextItemValue class]]) {
        ret = ITEMVALUE_ETEXT_VALUE_IDENTIFIER;
    }
    
    return ret;
}

- (NSString *)identifierIsLinkForClassType {    
    NSString *ret = ITEMVALUE_FILE_ISLINK_IDENTIFIER;
    if([self isKindOfClass:[MBImageItemValue class]]) {
        ret = ITEMVALUE_IMAGE_ISLINK_IDENTIFIER;
    } else if([self isKindOfClass:[MBExtendedTextItemValue class]]) {
        ret = ITEMVALUE_ETEXT_ISLINK_IDENTIFIER;
    }
    
    return ret;
}

- (NSString *)identifierLinkValueForClassType {
    NSString *ret = ITEMVALUE_FILE_LINKVALUE_IDENTIFIER;
    if([self isKindOfClass:[MBImageItemValue class]]) {
        ret = ITEMVALUE_IMAGE_LINKVALUE_IDENTIFIER;
    } else if([self isKindOfClass:[MBExtendedTextItemValue class]]) {
        ret = ITEMVALUE_ETEXT_LINKVALUE_IDENTIFIER;
    }
    
    return ret;
}

- (NSString *)identifierAutoLoadForClassType {
    NSString *ret = ITEMVALUE_FILE_AUTOHANDLE_IDENTIFIER;
    if([self isKindOfClass:[MBImageItemValue class]]) {
        ret = ITEMVALUE_IMAGE_AUTOHANDLE_IDENTIFIER;
    } else if([self isKindOfClass:[MBExtendedTextItemValue class]]) {
        ret = ITEMVALUE_ETEXT_AUTOHANDLE_IDENTIFIER;
    }
    
    return ret;    
}

@end

@implementation MBFileItemValue

// inits
- (id)init {
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"cannot init super!");
	} else {
		// set state
		[self setState:InitState];

		// set identifier
		[self setIdentifier:FileItemValueID];
		// set valuetype
		[self setValuetype:FileItemValueType];

		// isLink
		[self setIsLink:NO];
		// link value
		[self setLinkValueAsString:@""];
		// data value
		[self setValueData:[NSData data]];
		// file attributes dictionary
		[self setFileAttributesDict:[NSDictionary dictionary]];

		// set state
		[self setState:NormalState];
	}
	
	return self;
}

- (id)initWithDb {
	self = [self init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"cannot init super!");
	} else {
		// set state
		[self setState:InitState];
		
		// connect element
		[self setIsDbConnected:YES];
		
		// set state
		[self setState:NormalState];
	}
	
	return self;		
}

- (id)initWithInitializedElement:(MBElement *)aElem {
	return [super initWithInitializedElement:aElem];
}

- (void)dealloc {
	[super dealloc];
}

/**
\brief overriding super classes abstract method
 */
- (NSString *)valueDataAsString {
	return @"";
}

/**
\ here is is just a wrapper for valueDataAsString
 */
- (NSString *)valueDataForComparison {
	return [self valueDataAsString];
}

// Resource Fork stuff
+ (OSErr)getResourceDataForResType:(int)resType atPath:(NSString *)path data:(NSData **)data {
	OSErr ret = 0;
	// nil data
	*data = nil;
	
	// get URL resource on my own way
	// open file
	FSRef fileRef;
	OSStatus stat = FSPathMakeRef((UInt8 *)[path UTF8String],&fileRef,NO);
	if(stat == 0) {
		stat = FSOpenResFile(&fileRef,1);		// read permission
		// get number of resources
		int numOfResTypes = Count1Types();
		ResType resourceType;
		//int index = 0;
		int i;
		for(i = 1;i <= numOfResTypes;i++) {
			Get1IndType(&resourceType,i);
			ret = ResError();
			if(ret != 0) {
				CocoLog(LEVEL_ERR,@"error occured and getting resource type!");
			} else {
				// only work on the type we want
				if(resourceType == resType) {
					int numOfRes = Count1Resources(resourceType);
					for(int j = 1;j <= numOfRes;j++) {
						// get the resource itself
						Handle resHandle = Get1IndResource(resourceType,j);
						ret = ResError();
						if(ret == 0) {
							// get data from handle
							if(resHandle != nil) {
								*data = [NSData dataWithBytes:*resHandle length:(NSUInteger) GetHandleSize(resHandle)];
							} else {
								CocoLog(LEVEL_ERR,@"could not get resource Handle!");
							}
						}
					}
				}
			}
		}
	}
	
	return ret;
}

//--------------------------------------------------------------------
//------------- Item De/Encryption ----------------------
//--------------------------------------------------------------------
/**
\brief this method encrypts the number value of this itemvalue
 The super class melthod is called first to do let it do some work.
 @returns MBCryptoErrorCode
 */
- (MBCryptoErrorCode)encryptWithString:(NSString *)aString {
    MBCryptoErrorCode ret = MBCryptoOK;
	
	if((aString != nil) || ([aString length] > 0)) {
		// check the encryption state of this item
		if([self encryptionState] != EncryptedState) {
			// call super first
            MBCryptoErrorCode stat = [super encryptWithString:aString];
			// if we get an error here, do not proceed
			if(stat != MBCryptoOK) {
				ret = stat;
				CocoLog(LEVEL_WARN,@"super class returned with error, we will not proceed!");
			} else {
				NSData *encryptedData = nil;
				ret = [self doEncryptionOfData:[self valueDataByLoadingFromTarget] 
								 withKeyString:aString 
								 encryptedData:&encryptedData];
				if(ret == MBCryptoOK) {
					// write data
					[self setValueDataBySavingToTarget:encryptedData];
					
					if([self isLink]) {
						// encrypt url link data
						ret = [self doEncryptionOfData:[self linkValueAsData] 
										 withKeyString:aString 
										 encryptedData:&encryptedData];
						
						// error?
						if(ret == MBCryptoOK) {
							[self setLinkValueAsData:encryptedData];
							
							// set state
							[self setEncryptionState:EncryptedState];
						} else {
							CocoLog(LEVEL_ERR,@"could not encrypt linkValue!");
						}
					} else {
						// set state
						[self setEncryptionState:EncryptedState];					
					}					
					// register for changing the index
					[[MBValueIndexController defaultController] registerCommonItem:self];
				} else {
					CocoLog(LEVEL_ERR,@"could not encrypt fileValue!");
				}
			}
		}
	} else {
		CocoLog(LEVEL_WARN,@"keyString is nil or empty!");
		ret = MBCryptoUnableToEncrypt;
	}
	
	return ret;
}

/**
\brief this method decrypts the encrypted number and the value that is returned by -valueDataAsData.
 @returns MBCryptoErrorCode
 */
- (MBCryptoErrorCode)decryptWithString:(NSString *)aString {
    MBCryptoErrorCode ret = MBCryptoOK;
	
	if((aString != nil) || ([aString length] > 0)) {
		// check the encryption state of this item
		if([self encryptionState] == EncryptedState) {
			// first call super decrypt
            MBCryptoErrorCode stat = [super decryptWithString:aString];
			// if we get an error here, do not proceed
			if(stat != MBCryptoOK) {
				ret = stat;
				CocoLog(LEVEL_WARN,@"super class returned with error, we will not proceed!");
			} else {
				NSData *decryptedData = nil;
				BOOL error = NO;
				// if this is a link, we first have to decrypt the link data
				// otherwise we will not be able to write the data to the target
				if([self isLink]) {
					// decrypt url link data
					ret = [self doDecryptionOfData:[self linkValueAsData] 
									 withKeyString:aString 
									 decryptedData:&decryptedData];
					
					// error?
					if(ret == MBCryptoOK) {
						[self setLinkValueAsData:decryptedData];
					} else {
						CocoLog(LEVEL_ERR,@"could not decrypt linkValue!");
						error = YES;
					}
				}
				
				// proceed, if we had no error
				if(!error) {
					// decrypt text data
					ret = [self doDecryptionOfData:[self valueDataByLoadingFromTarget] 
									 withKeyString:aString 
									 decryptedData:&decryptedData];
					if(ret == MBCryptoOK) {
						// write data
						[self setValueDataBySavingToTarget:decryptedData];
						// set state
						[self setEncryptionState:DecryptedState];
						// register for changing the index
						[[MBValueIndexController defaultController] registerCommonItem:self];
					} else {
						CocoLog(LEVEL_ERR,@"could not decrypt fileValue!");
					}
				}
			}
		}
	} else {
		CocoLog(LEVEL_WARN,@"keyString is nil or empty!");
		ret = MBCryptoUnableToDecrypt;
	}
	
	return ret;	
}


//--------------------------------------------------------------------
//------------- NSCopying protocoll ---------------------------------------
//--------------------------------------------------------------------
/**
\brief makes a copy of self commonitem for which the sender is responsible for releasing
 */
- (id)copyWithZone:(NSZone *)zone {
	// make a new object with alloc and init and return that
	MBFileItemValue *newItemval = [[MBFileItemValue alloc] initWithInitializedElement:[[element copy] autorelease]];
	
	if(newItemval == nil) {
		CocoLog(LEVEL_ERR,@"[cannot alloc new MBItem!");
	} else {
	}
	
	return newItemval;
}

//--------------------------------------------------------------------
//------------- NSCoding protocoll -----------------------------------
//--------------------------------------------------------------------
- (id)initWithCoder:(NSCoder *)decoder NS_RETURNS_RETAINED {
	MBFileItemValue *newItemval = nil;
	
	if([decoder allowsKeyedCoding]) {
		// decode the only encoded object
		MBElement *elem = [decoder decodeObjectForKey:@"ItemValueElement"];
		// create commonitem with that
		newItemval = [[MBFileItemValue alloc] initWithInitializedElement:elem];

	} else {
		// decode the only encoded object
		MBElement *elem = [decoder decodeObject];
		// create commonitem with that
		newItemval = [[MBFileItemValue alloc] initWithInitializedElement:elem];
	}
	
	return newItemval;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	MBElement *elementForEncoding = element;
	
	// get exporter and check, if we currently are exporting
	// if yes, check, if we should not copy links as links, then make a copy of self and set some values
	MBExporter *exporter = [MBExporter defaultExporter];
	if([exporter exportInProgress]) {
		// do we have a link?
		if([self isLink]) {
			// shall we export links as link?
			if(![exporter exportLinksAsLink]) {
				MBFileItemValue *buf = [[self copy] autorelease];
				// reset isLink
				[buf setIsLink:NO];
				// load link target data
				[buf setValueData:[buf valueDataByLoadingFromTarget]];
				[buf setAutoHandleLoadSave:NO];
				
				// set this element for encoding
				elementForEncoding = [buf element];
			}
		}
	}

	if([encoder allowsKeyedCoding]) {
		// only encode the element itself
		[encoder encodeObject:elementForEncoding forKey:@"ItemValueElement"];
	} else {
		// only encode the element itself
		[encoder encodeObject:elementForEncoding];
	}	
}

/**
\brief if value is a link, load the data from link target and return that
 */
- (NSData *)valueDataByLoadingFromTarget {
	NSData *returnData = nil;
	
	if([self isLink]) {
		returnData = [NSData dataWithContentsOfURL:[self linkValueAsURL]];
	} else {
		returnData = [self valueData];
	}
	
	return returnData;
}

- (BOOL)setValueDataBySavingToTarget:(NSData *)aData {
	BOOL ret = YES;
	
	if(aData != nil) {
		if([self isLink]) {
			BOOL stat = [aData writeToURL:[self linkValueAsURL] atomically:YES];
			if(!stat) {
				ret = NO;
				CocoLog(LEVEL_ERR,@"could not write data to: %@",[self linkValueAsString]);
			}
		} else {
			[self setValueData:aData];
		}
	} else {
		CocoLog(LEVEL_WARN,@"data is nil!");
		ret = NO;
	}
	
	return ret;
}

@end

@implementation MBFileItemValue (ElementBase)

- (void)setAutoHandleLoadSave:(BOOL)aValue {
    NSString *identifier = [self identifierAutoLoadForClassType];
	MBElementValue *elemval = [attributeDict valueForKey:identifier];
	if(elemval != nil) {
		[elemval setValueDataAsNumber:[NSNumber numberWithBool:aValue]];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
        [self createAttributeForValue:[NSNumber numberWithBool:aValue] withValueType:NumberValueType identifier:identifier writeIndex:NO];
	}	
}

- (BOOL)autoHandleLoadSave {
	BOOL ret = NO;
    NSString *identifier = [self identifierAutoLoadForClassType];
	MBElementValue *elemval = [attributeDict valueForKey:identifier];
	if(elemval != nil) {
		ret = (BOOL)[[elemval valueDataAsNumber] intValue];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
        [self createAttributeForValue:[NSNumber numberWithBool:ret] withValueType:NumberValueType identifier:identifier writeIndex:NO];
	}
	
	return ret;
}

- (void)setValueData:(NSData *)valueData {
    NSString *identifier = [self identifierValueDataForClassType];    
	MBElementValue *elemval = [attributeDict valueForKey:identifier];
	if(elemval != nil) {
		[elemval setValueDataAsData:valueData];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
        [self createAttributeForValue:valueData withValueType:BinaryValueType identifier:identifier writeIndex:NO];
	}		
}

- (NSData *)valueData {
	NSData *ret = nil;
	
    NSString *identifier = [self identifierValueDataForClassType];    
	MBElementValue *elemval = [attributeDict valueForKey:identifier];
	if(elemval != nil) {
		ret = [elemval valueDataAsData];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		ret = [NSData data];
        [self createAttributeForValue:ret withValueType:BinaryValueType identifier:identifier writeIndex:NO];
	}
	
	return ret;
}

- (void)setIsLink:(BOOL)aValue {
    NSString *identifier = [self identifierIsLinkForClassType];
	MBElementValue *elemval = [attributeDict valueForKey:identifier];
	if(elemval != nil) {
		[elemval setValueDataAsNumber:[NSNumber numberWithBool:aValue]];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
        [self createAttributeForValue:[NSNumber numberWithBool:aValue] withValueType:NumberValueType identifier:identifier writeIndex:NO];
	}			
}

- (BOOL)isLink {
	BOOL ret = NO;
	
    NSString *identifier = [self identifierIsLinkForClassType];
	MBElementValue *elemval = [attributeDict valueForKey:identifier];
	if(elemval != nil) {
		ret = (BOOL)[[elemval valueDataAsNumber] intValue];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
        [self createAttributeForValue:[NSNumber numberWithBool:ret] withValueType:NumberValueType identifier:identifier writeIndex:NO];
	}
	
	return ret;
}

- (void)setLinkValueAsString:(NSString *)aStringLinkValue {
    NSString *identifier = [self identifierLinkValueForClassType];    
	MBElementValue *elemval = [attributeDict valueForKey:identifier];
	if(elemval != nil) {
		[elemval setValueDataAsString:aStringLinkValue];
        
		// send Notification
		if(([self state] == NormalState) || ([self state] == UnRedoState)) {
			// register itemvalue to the list of to be processed valueindexes
			[[MBValueIndexController defaultController] registerCommonItem:self];
			
			MBSendNotifyItemValueAttribsChanged(self);
		}
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
        [self createAttributeForValue:aStringLinkValue withValueType:StringValueType identifier:identifier writeIndex:YES];
	}	
}

- (NSString *)linkValueAsString {
	NSString *ret = nil;
	
    NSString *identifier = [self identifierLinkValueForClassType];    
	MBElementValue *elemval = [attributeDict valueForKey:identifier];
	if(elemval != nil) {
		ret = [elemval valueDataAsString];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		ret = @"";
        [self createAttributeForValue:ret withValueType:StringValueType identifier:identifier writeIndex:YES];
	}
	
	return ret;	
}

/** convenience method */
- (void)setLinkValueAsURL:(NSURL *)aURLLinkValue {
	[self setLinkValueAsString:[aURLLinkValue absoluteString]];
}

- (NSURL *)linkValueAsURL {
	return [NSURL URLWithString:[self linkValueAsString]];
}

/** strictly used for encrypted data */
- (void)setLinkValueAsData:(NSData *)aLinkValueData {
    NSString *identifier = [self identifierLinkValueForClassType];    
	MBElementValue *elemval = [attributeDict valueForKey:identifier];
	if(elemval != nil) {
		[elemval setValueDataAsData:aLinkValueData];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
        [self createAttributeForValue:[NSURL URLWithString:@""] withValueType:StringValueType identifier:identifier writeIndex:YES];
	}	
}

- (NSData *)linkValueAsData {
	NSData *ret = nil;
	
    NSString *identifier = [self identifierLinkValueForClassType];
	MBElementValue *elemval = [attributeDict valueForKey:identifier];
	if(elemval != nil) {
		ret = [elemval valueDataAsData];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		ret = [NSData data];
        [self createAttributeForValue:[NSURL URLWithString:@""] withValueType:StringValueType identifier:identifier writeIndex:YES];
	}
	
	return ret;
}

- (void)setFileAttributesDict:(NSDictionary *)fileAttribs {
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_FILE_ATTRIBUTES_IDENTIFIER];
	if(elemval != nil) {
		[elemval setValueDataAsData:[NSKeyedArchiver archivedDataWithRootObject:fileAttribs]];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
        [self createAttributeForValue:[NSKeyedArchiver archivedDataWithRootObject:fileAttribs] 
                        withValueType:BinaryValueType 
                           identifier:ITEMVALUE_FILE_ATTRIBUTES_IDENTIFIER writeIndex:NO];
	}
}

/**
 \brief returns the file attributes as described in NSFileManager
 if this is a link, attributes are only returned if it is a local link
 if it is no link, the file attributes are returned that have been read at import
*/
- (NSDictionary *)fileAttributesDict {
	NSDictionary *ret = nil;
	
	// check for link
	if(![self isLink]) {
		MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_FILE_ATTRIBUTES_IDENTIFIER];
		if(elemval != nil) {
			ret = [NSKeyedUnarchiver unarchiveObjectWithData:[elemval valueDataAsData]];
		} else {
			CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
			ret = [NSDictionary dictionary];
            [self createAttributeForValue:[NSKeyedArchiver archivedDataWithRootObject:ret] 
                            withValueType:BinaryValueType 
                               identifier:ITEMVALUE_FILE_ATTRIBUTES_IDENTIFIER writeIndex:NO];
		}
	} else {
		// get fileattributes
		NSURL *url = [self linkValueAsURL];
		if([url isFileURL]) {
			NSFileManager *fm = [NSFileManager defaultManager];
			ret = [fm fileAttributesAtPath:[url relativePath] traverseLink:YES];
			if(ret == nil) {
				CocoLog(LEVEL_WARN,@"file is external url, cannot collect file attributes!");
			}
		} else {
			CocoLog(LEVEL_WARN,@"no local file, cannot get file attributes!");
		}		
	}
	
	return ret;		
}

/**
\brief write initial valueindex entries to the table
 */
- (void)writeValueIndexEntryWithCreate:(BOOL)flag {
	// first super
	[super writeValueIndexEntryWithCreate:flag];
	
	// linkvalue
    NSString *identifier = [self identifierLinkValueForClassType];
	MBElementValue *elemval = [attributeDict valueForKey:identifier];
	if(flag) {
		// create valueindex entry
		[elemval createIndexEntryWithIdentifier:identifier];
	}
	[elemval setIndexValue:[self linkValueAsString]];
}

@end

