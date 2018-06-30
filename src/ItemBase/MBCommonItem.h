//
//  MBCommonItem.h
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

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import "MBBaseDefinitions.h"
#import "MBItemType.h"

@class MBRefItem;
@class MBElement;
@class MBElementValue;

typedef enum {
	MBCryptoOK = 0,
	MBCryptoUnableToEncrypt,
	MBCryptoUnableToDecrypt,
	MBCryptoWrongDecryptionKey,
	MBCryptoArgumentError
}MBCryptoErrorCode;

typedef enum {
	DecryptedState = 0,
	EncryptedState
}MBEncryptionState;

@interface MBCommonItem : NSObject <NSCopying, NSCoding> {
    /** the state of this item */
	int state;
		
    /** the underlying element */
	MBElement *element;
	
	/** list of referencing items that are to be notified when this here is deleted */
	NSMutableDictionary *refDict;

    /** the dictioinary with all the attributes of this Item */
	NSMutableDictionary *attributeDict;	
}

// NSCopying protocoll
- (id)copyWithZone:(NSZone *)zone;

// NSCoding stuff
- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;

// inits
- (id)init;
- (id)initWithDb;
- (id)initWithInitializedElement:(MBElement *)aElem;

/** for compatibility */
- (id)item;

/**
 create attribute value
 */
- (MBElementValue *)createAttributeForValue:(id)aValue 
                              withValueType:(MBValueType)aType 
                                 identifier:(NSString *)anIdentifier 
                               memFootprint:(MBMemFootprintType)mem 
                                dbConnected:(BOOL)dbConnected 
                                 writeIndex:(BOOL)writeIndex;

/**
 convenience method
 it assumes some attributes like:
 data hold threshold= full cache
 dbConnected= [self isDBConnected]
 writeIndex= YES
 */
- (MBElementValue *)createAttributeForValue:(id)aValue withValueType:(MBValueType)aType identifier:(NSString *)anIdentifier;
/**
 convenience method
 it assumes some attributes like:
 data hold threshold= full cache
 dbConnected= [self isDBConnected]
 */
- (MBElementValue *)createAttributeForValue:(id)aValue withValueType:(MBValueType)aType identifier:(NSString *)anIdentifier writeIndex:(BOOL)index;


// encryption stuff
- (MBCryptoErrorCode)doEncryptionOfData:(NSData *)sourceData withKeyString:(NSString *)aKeyString encryptedData:(NSData **)encryptedData;
- (MBCryptoErrorCode)doDecryptionOfData:(NSData *)encryptedData withKeyString:(NSString *)aKeyString decryptedData:(NSData **)decryptedData;

// state
- (void)setState:(ElementStateType)aState;
- (ElementStateType)state;

// underlying element
- (void)setElement:(MBElement *)aElem;
- (MBElement *)element;

// setting lists and dicts
- (void)setAttributeDict:(NSMutableDictionary *)aDict;
- (NSDictionary *)attributeDict;

// db connection
- (void)setIsDbConnected:(BOOL)flag;
- (BOOL)isDbConnected;

// get elementvalues
- (MBElementValue *)elementValueForIdentifier:(NSString *)identifier;

// adding and deleting from refList
- (void)registerAtTarget:(MBRefItem *)refItem;
- (void)deregisterAtTarget:(MBRefItem *)refItem;
- (void)resetReferences;

// abstract method
- (void)writeValueIndexEntryWithCreate:(BOOL)flag;

@end

@interface MBCommonItem (ElementBase)

- (void)setItemID:(int)aID;
- (void)setIdentifier:(MBTypeIdentifier)aIdentifier;
- (void)setEncryptionState:(MBEncryptionState)aState;
- (void)setSortorder:(int)aSortorder;
//
- (int)itemID;
- (MBTypeIdentifier)identifier;
- (MBEncryptionState)encryptionState;
- (int)sortorder;

- (void)delete;
- (NSString *)treeinfo;

@end

@protocol MBCommonItemReferencing

- (void)targetObjectHasBeenDeleted;

@end
