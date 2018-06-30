//
//  MBDBSqliteElementValue.h
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

#import <Cocoa/Cocoa.h>
#import "MBDBElementValue.h"

@class MBDBDocumentEntry;
@class MBElementValue;
@protocol MBDBAccessing;

@interface MBDBSqliteElementValue : MBDBElementValue <MBDBElementValueAccessing> {
}

// convenient allocators
+ (id<MBDBElementValueAccessing>)dbElementValueForElementValue:(MBElementValue *)aElemVal writeIndex:(BOOL)flag;

// special init methods
- (id)initWithDelegate:(id)aDelegate;
- (id)initWithElementValue:(MBElementValue *)aElemVal writeIndex:(BOOL)flag;

// getter and setter for db connection
- (void)setDbConnection:(MBDBAccess<MBDBAccessing> *)aDbConnection;
- (MBDBAccess<MBDBAccessing> *)dbConnection;

// the document entry
- (void)setDocumentEntry:(MBDBDocumentEntry *)docEntry;
- (MBDBDocumentEntry *)documentEntry;

// setting the index for this elementvalue
- (void)setIndexValue:(NSString *)aText;
- (BOOL)createIndexEntryWithIdentifier:(NSString *)identifier;

// setter
- (void)setValueid:(int)aValueid;
- (void)setElementid:(int)aElemid;
- (void)setIdentifier:(NSString *)aIdentifier;
- (void)setGpReg:(int)aValue;
- (void)setIsSIStored:(BOOL)flag;
- (void)setValueDataSize:(int)aSize;
- (void)setValueData:(NSData *)aData;
- (void)setValuetype:(MBValueType)aType;
// getter
- (int)valueid;
- (int)elementid;
- (NSString *)identifier;
- (int)gpReg;
- (BOOL)isSIStored;
- (int)valueDataSize;
- (NSData *)valueData;
- (MBValueType)valuetype;

- (void)setElementValue:(MBElementValue *)elemVal;

// delete
- (void)delete;
- (void)deleteIndex;

@end

@interface MBDBSqliteElementValue (converters)

+ (NSData *)encodeData:(NSData *)data withPListFormat:(NSPropertyListFormat)format;
+ (NSData *)decodeData:(NSData *)plistData;

@end
