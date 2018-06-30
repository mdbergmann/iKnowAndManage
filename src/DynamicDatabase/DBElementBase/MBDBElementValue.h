//
//  MBDBElementValue.h
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 06.07.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>
#import "MBBaseDefinitions.h"

@class MBElementValue;
@class MBDBDocumentEntry;
@protocol MBDBElementValueAccessing;
@protocol MBDBAccessing;
@class MBDBAccess;

@interface MBDBElementValue : NSObject  {
	/** The db connection for this DBValue */
    MBDBAccess<MBDBAccessing> *dbConnection;
	
	int valueid;
    int valueDataSize;
	MBValueType valuetype;
    int gpReg;
    int siDocId;
    
    /** the single instance doc entry */
    MBDBDocumentEntry *documentEntry;
    
    /** the delegate that this db element reports to */
    id delegate;
}

- (void)setSiDocId:(int)aDocId;
- (int)siDocId;

- (void)setDelegate:(id)aDelegate;
- (id)delegate;

@end

@protocol MBDBElementValueAccessing

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

// delete
- (void)delete;
- (void)deleteIndex;

@end
