//
//  MBCommonItem.m
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

#import "MBCommonItem.h"
#import "globals.h"
#import "MBElement.h"
#import "MBRefItem.h"
#import "MBItemBaseController.h"
#import "MBElementValue.h"
#import "MBNSDataCryptoExtension.h"
#import "NSData-Base64Extensions.h"
#import "NSString-Base64Extensions.h"

#define ITEM_ENCRYPTION_IDENTIFIER			@"itemsecurity"

@interface MBCommonItem (privateAPI)

- (void)setRefDict:(NSMutableDictionary *)dict;
- (NSDictionary *)refDict;

@end

@implementation MBCommonItem (privateAPI)

- (void)setRefDict:(NSMutableDictionary *)dict {
	if(refDict != nil) {
		// reset all references from other items
		NSArray *refs = [refDict allValues];
		if([refs count] > 0) {
			NSEnumerator *iter = [refs objectEnumerator];
			MBRefItem *refItem = nil;
			while((refItem = [iter nextObject])) {
				// reset target
				if([refItem respondsToSelector:@selector(targetObjectHasBeenDeleted)]) {
					[refItem performSelector:@selector(targetObjectHasBeenDeleted)];
				} else {
					CocoLog(LEVEL_WARN,@"[MBCommonItem -setRefDict:] refItem does not respond to selector!");
				}
			}
			
			// nofify outlineview to update
			MBSendNotifyItemTreeChanged(nil);
		}	
	}
	
	[dict retain];
	[refDict release];
	refDict = dict;
}

- (NSDictionary *)refDict {
	return refDict;
}

@end

@implementation MBCommonItem

- (id)init {
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR, @"[MBCommonItem -init]: cannot init super!");
	} else {
		// set state
		[self setState:InitState];
		
		// create the underlying element
		element = [[MBElement alloc] init];
		
		// init lists and dicts
		[self setAttributeDict:[NSMutableDictionary dictionary]];
		
		// init ref dict
		[self setRefDict:[NSMutableDictionary dictionary]];
		
		// add encryption attribute
		[self setEncryptionState:DecryptedState];
		
		// set state
		[self setState:NormalState];
	}
	
	return self;
}

- (id)initWithDb {
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"[MBCommonItem -initWithDb]: cannot init!");
	} else {
		// set state
		[self setState:InitState];
		
		// create the underlying element
		element = [[MBElement alloc] initWithDb];
		
		// init lists and dicts
		[self setAttributeDict:[NSMutableDictionary dictionary]];
		
		// init ref dict
		[self setRefDict:[NSMutableDictionary dictionary]];
        
		// add encryption attribute
		[self setEncryptionState:DecryptedState];
        
		// register item
		[itemController registerCommonItem:self withId:[[self element] elementid]];
		
		// set state
		[self setState:NormalState];
	}
	
	return self;
}

/**
 \brief this init method can be used to init all subclasses of this class
 Only item attributes are set here
 */
- (id)initWithInitializedElement:(MBElement *)aElement {
	self = [super init];
	if(self) {
		// set state
		[self setState:InitState];
		
		// init lists and dicts
		[self setAttributeDict:[NSMutableDictionary dictionaryWithCapacity:[[aElement elementValues] count]]];
		
		// connect element
		[self setElement:aElement];
		
		// build attributedict
		NSEnumerator *iter = [[aElement elementValues] objectEnumerator];
		MBElementValue *elemval = nil;
		while((elemval = [iter nextObject])) {
			[attributeDict setObject:elemval forKey:[elemval identifier]];
		}
		
		// init ref dict
		[self setRefDict:[NSMutableDictionary dictionary]];
        
		// register item
		if([self itemID] > 0) {
			[itemController registerCommonItem:self withId:[self itemID]];
		}
		
		// set state
		[self setState:NormalState];
	}
	
	return self;	
}

- (void)dealloc {
	// set state
	[self setState:DeallocState];
	
	// lists
	[self setAttributeDict:nil];
	
	// unset element
	[self setElement:nil];
	
	// delete reference dictionary
	[self setRefDict:nil];
	
	// release super
	[super dealloc];
}

/**
 create attribute value
 */
- (MBElementValue *)createAttributeForValue:(id)aValue 
                              withValueType:(MBValueType)aType 
                                 identifier:(NSString *)anIdentifier 
                               memFootprint:(MBMemFootprintType)mem 
                                dbConnected:(BOOL)dbConnected 
                                 writeIndex:(BOOL)writeIndex {
    MBElementValue *elemval = [[MBElementValue alloc] initWithIdentifier:anIdentifier andType:aType];
	[elemval setDataHoldTreshold:mem];
    switch(aType) {
        case NumberValueType:
            [elemval setValueDataAsNumber:aValue];
            break;
        case StringValueType:
            [elemval setValueDataAsString:aValue];
            break;
        case BinaryValueType:
            [elemval setValueDataAsData:aValue];
        case ExternalBinaryValueType:
            break;
    }
	[element addElementValue:elemval];
	[attributeDict setObject:elemval forKey:anIdentifier];
	[elemval release];
    
    // do this later to have the index written
    [elemval setIsDbConnected:dbConnected writeIndex:writeIndex];
    
    return elemval;
}

/**
 convenience method
 it assumes some attributes like:
 data hold threshold= full cache
 dbConnected= [self isDBConnected]
 writeIndex= YES
 */
- (MBElementValue *)createAttributeForValue:(id)aValue 
                              withValueType:(MBValueType)aType 
                                 identifier:(NSString *)anIdentifier {
    return [self createAttributeForValue:aValue 
                           withValueType:aType 
                              identifier:anIdentifier 
                            memFootprint:FullCacheMemFootprintType 
                             dbConnected:[self isDbConnected] 
                              writeIndex:YES];
}

/**
 convenience method
 it assumes some attributes like:
 data hold threshold= full cache
 dbConnected= [self isDBConnected]
 */
- (MBElementValue *)createAttributeForValue:(id)aValue withValueType:(MBValueType)aType identifier:(NSString *)anIdentifier writeIndex:(BOOL)index {
    return [self createAttributeForValue:aValue 
                           withValueType:aType 
                              identifier:anIdentifier 
                            memFootprint:FullCacheMemFootprintType 
                             dbConnected:[self isDbConnected] 
                              writeIndex:index];    
}

- (id)item {
    return self;
}

// state
- (void)setState:(ElementStateType)aState {
	state = aState;
}

- (ElementStateType)state {
	return (ElementStateType) state;
}

- (void)setAttributeDict:(NSMutableDictionary *)aDict {
	[aDict retain];
	[attributeDict release];
	attributeDict = aDict;
}

- (NSDictionary *)attributeDict {
	return attributeDict;
}

- (void)setElement:(MBElement *)aElem {
	[aElem retain];
	[element release];
	element = aElem;
}

- (MBElement *)element {
	return element;
}

/**
 \brief wrapper for the underlying -setIsDbConnected: (MBElement *)
 */
- (void)setIsDbConnected:(BOOL)flag {
	if(element != nil) {
		// TODO --- implement case if setIsDbConected;NO
		[element setIsDbConnected:flag];
		if(flag) {
			// write initial index
			[self writeValueIndexEntryWithCreate:YES];			
			
			// register id
			[itemController registerCommonItem:self withId:[element elementid]];
		}
	} else {
		CocoLog(LEVEL_WARN,@"[MBCommonItem -setIsDbConnected:] have no underlying MBElement, cannot do action!");
	}
}

- (BOOL)isDbConnected {
	if(element != nil) {
		return [element isDbConnected];
	} else {
		CocoLog(LEVEL_WARN,@"[MBCommonItem -isDbConnected:] have no underlying MBElement, cannot do action!");
	}
	
	return NO;
}

/**
 \brief add a referencing object to out list
 */
- (void)registerAtTarget:(MBRefItem *)refItem {
	if(refItem != nil) {
		[refDict setObject:refItem forKey:[NSNumber numberWithInt:[refItem itemID]]];
	} else {
		CocoLog(LEVEL_WARN,@"[MBCommonItem -registerAtTarget:] ref item is nil!");
	}
}

/**
 \brief remove referencing object from list
 */
- (void)deregisterAtTarget:(MBRefItem *)refItem {
	if(refItem != nil) {
		[refDict removeObjectForKey:[NSNumber numberWithInt:[refItem itemID]]];
	} else {
		CocoLog(LEVEL_WARN,@"[MBCommonItem -deregisterAtTarget:] ref item is nil!");	
	}
}

/**
 \brief reset all references to this object
 */
- (void)resetReferences {
	[self setRefDict:[NSMutableDictionary dictionary]];
}

// get elementvalues
- (MBElementValue *)elementValueForIdentifier:(NSString *)identifier {
	return [attributeDict objectForKey:identifier];
}

// abstract method
- (void)writeValueIndexEntryWithCreate:(BOOL)flag {
	CocoLog(LEVEL_WARN,@"[MBCommonItem -writeValueIndexEntryWithCreate:] called on commonItem!");
}

/**
 \brief encrypts data with key string and returns encrypted data
 this method will add some extra data to the source to check decryption success on decrypting
 this method will also encode the encrypted data to base64
 The output on encryptedData is autoreleased
 */
- (MBCryptoErrorCode)doEncryptionOfData:(NSData *)sourceData withKeyString:(NSString *)aKeyString encryptedData:(NSData **)encryptedData {
    MBCryptoErrorCode ret = MBCryptoOK;
    
	// check source data
	if(sourceData == nil) {
		ret = MBCryptoArgumentError;
		CocoLog(LEVEL_WARN,@"[MBCommonItem -doEncryptionOfData:withKeyString:encryptedData:] sourceData is either nil or empty!");
	} else {
		// check keyString
		if((aKeyString == nil) || ([aKeyString length] == 0)) {
			ret = MBCryptoArgumentError;
			CocoLog(LEVEL_WARN,@"[MBCommonItem -doEncryptionOfData:withKeyString:encryptedData:] key string is either nil or empty!");
		} else {
			// we even encrypt empty data, this means no big waste of time since this should go fast
			// and we can check the password of the to be decrypted item first
			NSMutableData *srcData = [NSMutableData dataWithData:sourceData];
			// add some data to comment to make sure that it was the same data after decrypting
			NSData *addData = [@"22M09B73" dataUsingEncoding:NSASCIIStringEncoding];
			[srcData appendData:addData];
			
			// encrypt comment
			NSData *encData = [srcData blowfishEncryptedDataForKey:aKeyString];
			if(encData != nil) {
				if([encData length] == [srcData length]) {
					// do base64 encoding of data and write to db
					NSData *base64Enc = [[encData encodeBase64] dataUsingEncoding:NSASCIIStringEncoding];
					if(base64Enc == nil) {
						CocoLog(LEVEL_WARN,@"[MBCommonItem -encryptWithString:] could not base64 encode encrypted data!");
						ret = MBCryptoUnableToEncrypt;
						*encryptedData = nil;
					} else {
						// all went good, copy reference
						*encryptedData = base64Enc;
					}
				} else {
					CocoLog(LEVEL_WARN,@"[MBCommonItem -encryptWithString:] datasize of encrypted does not match original!");
					ret = MBCryptoUnableToEncrypt;
				}
			} else {
				CocoLog(LEVEL_WARN,@"[MBCommonItem -encryptWithString:] cannot encrypt string!");
				ret = MBCryptoUnableToEncrypt;
			}
		}
	}
	
	return ret;
}

- (MBCryptoErrorCode)doDecryptionOfData:(NSData *)encryptedData withKeyString:(NSString *)aKeyString decryptedData:(NSData **)decryptedData {
    MBCryptoErrorCode ret = MBCryptoOK;
	
	// check source data
	if(encryptedData == nil) {
		ret = MBCryptoArgumentError;
		CocoLog(LEVEL_WARN,@"[MBCommonItem -doDecryptionOfData:withKeyString:decryptedData:] encryptedData is either nil or empty!");
	} else {
		// check keyString
		if((aKeyString == nil) || ([aKeyString length] == 0)) {
			ret = MBCryptoArgumentError;
			CocoLog(LEVEL_WARN,@"[MBCommonItem -doDecryptionOfData:withKeyString:decryptedData:] key string is either nil or empty!");
		} else {
			// if the encrypted data is empty, return an empty data object
			if([encryptedData length] == 0) {
				*decryptedData = [NSData data];
			} else {
				// do base64 decode
				NSData *base64DecData = [[[[NSString alloc] initWithData:encryptedData encoding:NSASCIIStringEncoding] autorelease] decodeBase64];
				if(base64DecData != nil) {
					// encrypt comment
					NSData *decData = [base64DecData blowfishDecryptedDataForKey:aKeyString];
					if(decData != nil) {
						NSUInteger decryptedLength = [decData length];
						if(decryptedLength == [base64DecData length]) {
							// lets see, if we have our added byte sequence at the end of the data instance
							NSData *addData = [@"22M09B73" dataUsingEncoding:NSASCIIStringEncoding];
							NSUInteger addLength = [addData length];
							if(decryptedLength >= addLength) {
								// go ahead, all right until here
								// extract the last bytes end compare
								NSData *mySeq = [decData subdataWithRange:NSMakeRange((decryptedLength - addLength),addLength)];
								if([mySeq isEqualToData:addData]) {
									// right password, we got the right data back
									// extract data without added seq
									NSData *data = [decData subdataWithRange:NSMakeRange(0,(decryptedLength - addLength))];
									// copy reference
									*decryptedData = data;
								} else {
									CocoLog(LEVEL_WARN,@"[MBCommonItem -doDecryptionOfData:withKeyString:decryptedData:] decrypted data is not the same as the original, password was probably not correct!");
									ret = MBCryptoWrongDecryptionKey;									
								}
							} else {
								CocoLog(LEVEL_WARN,@"[MBCommonItem -doDecryptionOfData:withKeyString:decryptedData:] decrypted data does not have the right length!");
								ret = MBCryptoUnableToDecrypt;
							}							
						} else {
							CocoLog(LEVEL_WARN,@"[MBCommonItem -doDecryptionOfData:withKeyString:decryptedData:] datasize of decrypted does not match original!");
							ret = MBCryptoUnableToDecrypt;
						}
					} else {
						CocoLog(LEVEL_WARN,@"[MBCommonItem -doDecryptionOfData:withKeyString:decryptedData:] cannot decrypt encrypted data!");
						ret = MBCryptoUnableToDecrypt;
					}
				} else {
					CocoLog(LEVEL_WARN,@"[MBCommonItem -doDecryptionOfData:withKeyString:decryptedData:] could not decode base64!");					
					ret = MBCryptoUnableToDecrypt;
				}
			}
		}
	}
	
	return ret;
}

#pragma mark - NSCopying

/**
 Makes a copy of self commonitem for which the sender is responsible for releasing
 */
- (id)copyWithZone:(NSZone *)zone {
	// make a new object with alloc and init and return that
	MBCommonItem *newItem = [[MBCommonItem alloc] initWithInitializedElement:[[element copy] autorelease]];
	if(newItem == nil) {
		CocoLog(LEVEL_ERR,@"[MBCommonItem -copyWithZone:]: cannot alloc new commonitem!");
	} else {
	}
	
	return newItem;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
	MBCommonItem *newItem = nil;
    
	if([decoder allowsKeyedCoding]) {
		// decode the only encoded object
		MBElement *elem = [decoder decodeObjectForKey:@"ItemElement"];
		// create commonitem with that
		newItem = [[[MBCommonItem alloc] initWithInitializedElement:elem] autorelease];
	} else {
		// decode the only encoded object
		MBElement *elem = [decoder decodeObject];
		// create commonitem with that
		newItem = [[[MBCommonItem alloc] initWithInitializedElement:elem] autorelease];
	}
	
	return newItem;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	if([encoder allowsKeyedCoding]) {
		// only encode the element itself
		[encoder encodeObject:element forKey:@"ItemElement"];
	} else {
		// only encode the element itself
		[encoder encodeObject:element];
	}	
}

@end

@implementation MBCommonItem (ElementBase)

- (void)delete {
	// deregister from itemController
	[itemController deregisterCommonItemWithId:[self itemID]];
    
	// reset all references from other items
	NSArray *refs = [refDict allValues];
	if([refs count] > 0) {
		NSEnumerator *iter = [refs objectEnumerator];
		MBRefItem *refItem = nil;
		while((refItem = [iter nextObject])) {
			// reset target
			if([refItem respondsToSelector:@selector(targetObjectHasBeenDeleted)]) {
				[refItem performSelector:@selector(targetObjectHasBeenDeleted)];
			} else {
				CocoLog(LEVEL_WARN,@"[MBCommonItem -delete] refItem does not respond to selector!");
			}
		}
		
		// nofify outlineview to update
		MBSendNotifyItemTreeChanged(nil);
	}
	
	// delete the underlaying element
	if(element != nil) {
		// delete
		[element delete];
	} else {
		CocoLog(LEVEL_ERR,@"[MBCommonItem -delete] element is nil!");		
	}
}

- (MBEncryptionState)encryptionState {
	MBElementValue *elemval = [attributeDict valueForKey:ITEM_ENCRYPTION_IDENTIFIER];
	if(elemval != nil) {
		return (MBEncryptionState) [[elemval valueDataAsNumber] intValue];
	} else {
		CocoLog(LEVEL_WARN,@"[MBCommonItem -encryptionState:] elementvalue is nil, creating it!");
        [self createAttributeForValue:[NSNumber numberWithInt:EncryptionNone] 
                        withValueType:NumberValueType 
                           identifier:ITEM_ENCRYPTION_IDENTIFIER];
	}		
	
	return DecryptedState;	
}

- (void)setEncryptionState:(MBEncryptionState)aState {
	MBElementValue *elemval = [attributeDict valueForKey:ITEM_ENCRYPTION_IDENTIFIER];
	if(elemval != nil) {
		if([[elemval valueDataAsNumber] intValue] != aState) {
			// set value
			[elemval setValueDataAsNumber:[NSNumber numberWithInt:aState]];
		}
	} else {
		CocoLog(LEVEL_WARN,@"[MBCommonItem -setEncryptionState:] elementvalue is nil, creating it!");		
        [self createAttributeForValue:[NSNumber numberWithInt:aState] 
                        withValueType:NumberValueType 
                           identifier:ITEM_ENCRYPTION_IDENTIFIER];
	}		
}

/**
 \brief set sortorder of item
 Sortorder is used to sort the items in outlineview
 Sortorder is changed is a move operation (drag and drop or copy and paste) has taken place.
 */
- (void)setSortorder:(int)aSortorder {
    
    NSString *identifier = ITEM_SORTORDER_IDENTIFIER;
    if([self isKindOfClass:[MBItemValue class]]) {
        identifier = ITEMVALUE_SORTORDER_IDENTIFIER;
    }
    
	MBElementValue *elemval = [attributeDict valueForKey:identifier];
	if(elemval != nil) {
		if([[elemval valueDataAsNumber] intValue] != aSortorder) {
			// set value
			[elemval setValueDataAsNumber:[NSNumber numberWithInt:aSortorder]];
            
            if([self isKindOfClass:[MBItemValue class]]) {
                // sort itemvalue list new
                MBItemBaseController *ibc = itemController;
                [ibc sortItemValuesOfItems:[NSArray arrayWithObject:[self item]] usingSortDescriptors:[ibc itemValueListSortDescriptors]];                
            }
            
			// send Notification
			if(([self state] == NormalState) || ([self state] == UnRedoState)) {
                if([self isKindOfClass:[MBItemValue class]]) {
                    MBSendNotifyItemValueAttribsChanged(self);
                } else {
                    MBSendNotifyItemAttribsChanged(self);
                }
			}
		}
	} else {
		CocoLog(LEVEL_WARN,@"[MBCommonItem -setSortorder:] elementvalue is nil, creating it!");        
        [self createAttributeForValue:[NSNumber numberWithInt:0]
                        withValueType:NumberValueType 
                           identifier:identifier 
                         memFootprint:FullCacheMemFootprintType 
                          dbConnected:[self isDbConnected] 
                           writeIndex:NO];
	}	
}

- (int)sortorder {
	int ret = 0;
	
    NSString *identifier = ITEM_SORTORDER_IDENTIFIER;
    if([self isKindOfClass:[MBItemValue class]]) {
        identifier = ITEMVALUE_SORTORDER_IDENTIFIER;
    }

	MBElementValue *elemval = [attributeDict valueForKey:identifier];
	if(elemval != nil) {
		ret = [[elemval valueDataAsNumber] intValue];
	} else {
		CocoLog(LEVEL_WARN,@"[MBCommonItem -sortorder] elementvalue is nil, creating it!");
        [self createAttributeForValue:[NSNumber numberWithInt:0]
                        withValueType:NumberValueType 
                           identifier:identifier 
                         memFootprint:FullCacheMemFootprintType 
                          dbConnected:[self isDbConnected] 
                           writeIndex:NO];
	}		
	
	return ret;
}

- (MBTypeIdentifier)identifier {
	if(element != nil) {
		return (MBTypeIdentifier) [[element identifier] intValue];
	} else {
		CocoLog(LEVEL_ERR,@"[MBCommonItem -identifier] element is nil!");		
	}
	
	return -1;
}

- (void)setIdentifier:(MBTypeIdentifier)aIdentifier {
	if(element != nil) {
		[element setIdentifier:[[NSNumber numberWithInt:aIdentifier] stringValue]];
	} else {
		CocoLog(LEVEL_ERR,@"[MBCommonItem -setIdentifier] element is nil!");		
	}
}

- (NSString *)treeinfo {
	if(element != nil) {
		return [element treeinfo];
	}
	
	return nil;
}

- (void)setItemID:(int)aID {
	if(element != nil) {
		[element setElementid:aID];
	}
}

- (int)itemID {
	if(element != nil) {
		return [element elementid];
	}
	
	return -1;
}

@end
