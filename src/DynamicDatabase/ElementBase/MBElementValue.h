//
//  MBElementValue.h
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 26.05.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>

@class MBElement;
@class ResultRow;
@protocol MBDBElementValueAccessing;

@interface MBElementValue : NSObject <NSCopying, NSCoding> {
	int valueid;
	int elementid;
	NSString *identifier;
	NSData *valueData;
	int valuetype;
	int gpReg;
	int valueDataSize;
	
	int dataHoldThreshold;
	
	MBElement *element;			// the reference to our element
	id<MBDBElementValueAccessing> dbElementValue;			// the reference to our DBElementValue

	// observing state
	BOOL observingActive;
	
	// state of element
	int state;
}

// NSCopying protocoll
- (id)copyWithZone:(NSZone *)zone;

// NSCoding stuff
- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;

// inits
- (id)init;
- (id)initWithIdentifier:(NSString *)aIdentifier;
- (id)initWithType:(int)aType;
- (id)initWithIdentifier:(NSString *)aIdentifier andType:(int)aType;
- (id)initWithDbAndIndex:(BOOL)flag;
- (id)initWithDbAndIdentifier:(NSString *)aIdentifier writeIndex:(BOOL)flag;
- (id)initWithDbAndType:(int)aType writeIndex:(BOOL)flag;
- (id)initWithDbAndIdentifier:(NSString *)aIdentifier andType:(int)aType writeIndex:(BOOL)flag;
- (id)initWithReadingFromRow:(ResultRow *)aRow;

// data hold threshold, only applicable for binary data
- (void)setDataHoldTreshold:(int)threshold;
- (int)dataHoldTreshold;

// state
- (void)setState:(int)aState;
- (int)state;

// dbValue stuff
- (void)setDbElementValue:(id<MBDBElementValueAccessing>)aDbElementValue;
- (id<MBDBElementValueAccessing>)dbElementValue;
- (void)setIsDbConnected:(BOOL)aBool writeIndex:(BOOL)flag;
- (BOOL)isDbConnected;

// observing parent
- (void)startObserveElement:(MBElement *)aElement;
- (void)stopObserveElement:(MBElement *)aElement;
// callback for changes of observing
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

// export path
- (NSString *)exportPath;
- (NSString *)importPath;

// setting the index value
- (void)setIndexValue:(NSString *)aText;
- (BOOL)createIndexEntryWithIdentifier:(NSString *)identifier;

// gpreg uses
- (BOOL)hasIndex;
- (void)setHasIndex:(BOOL)flag;
- (BOOL)isSIStored;
- (void)setIsSIStored:(BOOL)flag;
/*
- (HashType)hashType;
- (void)setHashType:(HashType)aType;
- (EncryptionType)encryptionType;
- (void)setEncryptionType:(EncryptionType)aType;
*/

// setters
- (void)setValueid:(int)aId;
- (void)setElementid:(int)aId;
- (void)setIdentifier:(NSString *)aIdentifier;
- (void)setGpReg:(int)aValue;
- (void)setValueDataAsData:(NSData *)aData;
- (void)setValueDataAsString:(NSString *)aString;
- (void)setValueDataAsNumber:(NSNumber *)aNumber;
- (void)setValuetype:(int)aType;
- (void)setValueDataSize:(int)aSize;
- (void)setElement:(MBElement *)aElement;

- (void)setMemoryValueDataWithConversation:(NSString *)aValue;

// getters
- (int)valueid;
- (int)elementid;
- (NSString *)identifier;
- (int)gpReg;
- (NSData *)valueDataAsData;
- (NSString *)valueDataAsString;
- (NSNumber *)valueDataAsNumber;
- (int)valuetype;
- (int)valueDataSize;
- (MBElement *)element;

// deleting
- (void)delete;

// db element notifications
- (void)singleInstanceStorageChange:(NSNumber *)generalPurposeRegister;

@end
