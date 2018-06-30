//
//  MBElementValue.m
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

#import <CocoLogger/CocoLogger.h>
#import <SifSqlite/SifSqlite.h>
#import "MBElementValue.h"
#import "MBBaseDefinitions.h"
#import "MBElementBaseController.h"
#import "MBDBSqliteElementValue.h"
#import "NSString-Base64Extensions.h"
#import "MBElement.h"
#import "MBDBDocumentEntry.h"
#import "MBNSDataCryptoExtension.h"
#import "NSData-Base64Extensions.h"

@implementation MBElementValue

#pragma mark - Initialization

/**
 here a value that is not connected to db is created. \n
 set isDbConnected to YES to have it connected.
 @returns initialized not nil object
 */
- (id)init {
	self = [self initWithIdentifier:@"" andType:StringValueType];
	if(self == nil) {
		CocoLog(LEVEL_ERR, @"cannot alloc MBElementValue!");
	}
	
	return self;
}

- (id)initWithIdentifier:(NSString *)aIdentifier {
	self = [self initWithIdentifier:aIdentifier andType:StringValueType];
	if(self == nil) {
		CocoLog(LEVEL_ERR, @"cannot alloc MBElementValue!");
	}
	
	return self;		
}

- (id)initWithType:(int)aType {
	self = [self initWithIdentifier:@"" andType:aType];
	if(self == nil) {
		CocoLog(LEVEL_ERR, @"cannot alloc MBElementValue!");
	}
	
	return self;	
}

/**
 Init value with a specific type
 Here a value that is not connected to db is created. \n
 Set isDbConnected to YES to have it connected.
*/
- (id)initWithIdentifier:(NSString *)aIdentifier andType:(int)aType {
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR, @"cannot alloc MBElementValue!");
	} else {
		// this attribute has currently no dbElementValue
		dbElementValue = nil;
		
		// set default value for type
		if(aType == StringValueType) {
			valueData = [[@"" dataUsingEncoding:NSUTF8StringEncoding] retain];
		} else if(aType == NumberValueType) {
			valueData = [[[[NSNumber numberWithInt:0] stringValue] dataUsingEncoding:NSUTF8StringEncoding] retain];
		} else if(aType == BinaryValueType) {
			valueData = [[NSData data] retain];
		} else {
			CocoLog(LEVEL_WARN, @"unrecognized valuetype!");
			valueData = [[@"" dataUsingEncoding:NSUTF8StringEncoding] retain];
		}
		
		// set default dataHoldSize
		dataHoldThreshold = [elementController memoryFootprint];
		valueDataSize = 0;
		
		valueid = -1;
		elementid = -1;
		valuetype = aType;
		identifier = [[NSString stringWithString:aIdentifier] retain];
		gpReg = 0;
		// references
		element = nil;
		
		// observing not active
		observingActive = NO;
	}
	
	return self;
}

/**
 Init this value and create it on db. if this value is altered, all data will be written to db.
 */
- (id)initWithDbAndIndex:(BOOL)flag {
	self = [self initWithDbAndIdentifier:@"" andType:StringValueType writeIndex:flag];
	if(self == nil) {
		CocoLog(LEVEL_ERR, @"cannot alloc MBElementValue!");
	}
	
	return self;	
}

- (id)initWithDbAndType:(int)aType writeIndex:(BOOL)flag {
	self = [self initWithDbAndIdentifier:@"" andType:aType writeIndex:flag];
	if(self == nil) {
		CocoLog(LEVEL_ERR, @"cannot alloc MBElementValue!");
	}
	
	return self;	
}

- (id)initWithDbAndIdentifier:(NSString *)aIdentifier writeIndex:(BOOL)flag {
	self = [self initWithDbAndIdentifier:aIdentifier andType:StringValueType writeIndex:flag];
	if(self == nil) {
		CocoLog(LEVEL_ERR, @"cannot alloc MBElementValue!");
	}
	
	return self;	
}

/**
 Init this value and create it on db. if this value is altered, all data will be written to db.
 @param aType init this value with aType
 */
- (id)initWithDbAndIdentifier:(NSString *)aIdentifier andType:(int)aType writeIndex:(BOOL)flag {
	self = [self initWithIdentifier:aIdentifier andType:aType];
	if(self == nil) {
		CocoLog(LEVEL_ERR, @"cannot alloc MBElementValue!");
	} else {
		dbElementValue = [[MBDBSqliteElementValue alloc] initWithElementValue:self writeIndex:flag];        
		valueid = [dbElementValue valueid];
		
		// index?
		if(flag) {
			// set hasIndex
			[self setHasIndex:YES];
		}
		
		// release valueData, so it can be read for every access
		[self setValueDataAsData:nil];
	}
	
	return self;	
}

/**
 Init this already existing attribute by reading the data from a initialized dictionary
 @param aDict to be read from
 */
- (id)initWithReadingFromRow:(ResultRow *)aRow {
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"cannot alloc MBElementValue!");		
	} else {
		valueid = [[[aRow findColumnForName:@"id"] value] intValue];
		elementid = [[[aRow findColumnForName:@"elementid"] value] intValue];
		valuetype = [[[aRow findColumnForName:@"valuetype"] value] intValue];
		valueDataSize = [[[aRow findColumnForName:@"valuedatasize"] value] intValue];
		identifier = [[[aRow findColumnForName:@"identifier"] value] retain];
		gpReg = [[[aRow findColumnForName:@"gpreg"] value] intValue];
		// references
		element = nil;

		// set default dataHoldSize
		dataHoldThreshold = [elementController memoryFootprint];

		valueData = nil;

		// only take the data, if we are no value where large datas have to be stored
		if((valueDataSize > 0) && (valueDataSize < dataHoldThreshold) && (dataHoldThreshold != LoadEveryTimeMemFootprintType)) {
			NSData *data = nil;
			NSString *buf = [[aRow findColumnForName:@"valuedata"] value];
            
			// check for valuetype
			if(valuetype == BinaryValueType) {
				// get valuedata column
				//data = [[NSData alloc] initWithBase64EncodedString:[dict objectForKey:@"valuedata"]];
				data = [buf decodeBase64WithNewlines:NO];
			} else {
				// no decoding needed
				data = [buf dataUsingEncoding:NSUTF8StringEncoding];
			}
			
			valueData = [data retain];
		}
		
		// do some initialization work
		dbElementValue = [[MBDBSqliteElementValue alloc] initWithDelegate:self];
		[dbElementValue setElementValue:self];

		// observing not active
		observingActive = NO;
	}
	
	return self;	
}

/**
 Dealloc of this class is called on closing this document
 */
- (void)dealloc {
	CocoLog(LEVEL_DEBUG, @"");

	// switch to not dbConnected
	[self setDbElementValue:nil];
	[self setIdentifier:nil];
	[self setValueDataAsData:nil];

	// dealloc object
	[super dealloc];
}

#pragma mark - Export/Import

/**
 For exporting itemvalues which contain values that have oversize (> DEFAULT_DATA_HOLD_SIZE)
 they are stored in the package as separate file and loaded separately on import)
 */
- (NSString *)exportPath {
	return [elementController oversizeDataExportPath];
}

/**
 For importing ikam packages which contain values that have oversize (> DEFAULT_DATA_HOLD_SIZE)
 they are stored in the package as separate file and loaded separately on import)
*/
- (NSString *)importPath {
	return [elementController oversizeDataImportPath];
}

#pragma mark - Index management

/**
 Sets the index value for this elementvalue. MUST be UFT8 String.
 Nothing is retained or held here.
 This is just used for searching in the database itself.
*/
- (void)setIndexValue:(NSString *)aText {
	if(aText != nil) {
		// does this element value has an index?
		if([self hasIndex]) {
			// set index value in dbIndex
			if(dbElementValue != nil) {
				// escape any unknown characters
				NSString *escape = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
																					   (CFStringRef)aText,
																					   NULL,
																					   CFSTR("'"),
																					   kCFStringEncodingUTF8);
				// write to db
				[dbElementValue setIndexValue:escape];
				// release
				[escape release];
			}
		} else {
			CocoLog(LEVEL_WARN, @"elementvalue has no index, but method called! Doing nothing");
		}
	} else {
		CocoLog(LEVEL_WARN, @"given value is nil!");
	}
}

/**
 Calls the same method in the underlying dbElementValue, if there is one
 and if this elementvalue does not have an index entry already
*/
- (BOOL)createIndexEntryWithIdentifier:(NSString *)aIdentifier {
	BOOL ret = YES;
	
	if(![self hasIndex] && [self isDbConnected]) {
		ret = [dbElementValue createIndexEntryWithIdentifier:aIdentifier];
		if(ret) {
			// set hasIndex, to be done only on creation
			[self setHasIndex:YES];
		}
	}
	
	return ret;
}

/**
 Does this element value has a db index?
*/
- (BOOL)hasIndex {
	BOOL ret = NO;
	
	int buf = gpReg & MBElementValueHasIndex;
	if(buf > 0) {
		ret = YES;
	}
	
	return ret;
}

/**
 Set hasIndex in gpreg
*/
- (void)setHasIndex:(BOOL)flag {
	// we only set this, if we do not have an index already
	BOOL hasIndex = [self hasIndex];
	if(!hasIndex && flag) {
		// set
		[self setGpReg:(gpReg | MBElementValueHasIndex)];
	} else if(hasIndex && !flag) {
		// unset
		int mask = ~MBElementValueHasIndex;
		[self setGpReg:(gpReg & mask)];
	}
}

/*
- (BOOL)isSIStored
{
    return [dbElementValue isSIStored];
}

- (void)setIsSIStored:(BOOL)flag
{
    [dbElementValue setIsSIStored:flag];
}
*/

#pragma mark - Getter/Setter

- (BOOL)isSIStored {
	BOOL ret = NO;
	
	int buf = gpReg & MBElementValueSIStored;
	if(buf > 0) {
		ret = YES;
	}
	
	return ret;    
}

- (void)setIsSIStored:(BOOL)flag {
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
}

// state
- (void)setState:(int)aState {
	state = aState;
}

- (int)state {
	return state;
}

/**
 Set data hold treshold in bytes, -1 for hold, 0 load everytime
*/
- (void)setDataHoldTreshold:(int)threshold {
	dataHoldThreshold = threshold;
}

- (int)dataHoldTreshold {
	return dataHoldThreshold;
}

/**
 Set the dbConnection object
*/
- (void)setDbElementValue:(id<MBDBElementValueAccessing>)aDbElementValue {
    if(dbElementValue != aDbElementValue) {        
        [aDbElementValue retain];
        [dbElementValue release];
        dbElementValue = aDbElementValue;        
    }
}

/**
 Connect this value, create a dbElementValue
 */
- (void)setIsDbConnected:(BOOL)aBool writeIndex:(BOOL)flag {
	if(![self isDbConnected] && aBool) {
		[self setDbElementValue:[MBDBSqliteElementValue dbElementValueForElementValue:self writeIndex:flag]];
		// take valueid and dates from dbElementValue
		[self setValueid:[dbElementValue valueid]];
		
		// set gpreg
		if(flag) {
			[self setHasIndex:YES];
		}
		
		// reset the valueData of this MBElementValue
		// we don't have the space to hold bigger data twice
		// dbElementValue will keep track of valueData
		if((dataHoldThreshold == 0) || (valueDataSize > dataHoldThreshold)) {
			[valueData release];
			valueData = nil;
		}
	} else if(([self isDbConnected]) && !aBool) {
		// unset has index
		[self setHasIndex:NO];
	}
}

/**
 \brief set the valueid of this value. Nothing is saved to db.
*/
- (void)setValueid:(int)aId {
	valueid = aId;
}

/**
 Sets the element id
 */
- (void)setElementid:(int)aId {
	if(aId != elementid) {
		elementid = aId;
		// not setting same values
		
		// check element base controller for state
		// if we are in normal operation state, we have to deal with treeinfo and dbElement connection
		if([elementController state] == NormalState) {
			// set elementid in dbElementValue
			if(dbElementValue != nil) {
				[dbElementValue setElementid:elementid];
			}
		}
	}
}

/**
 Sets the identifier
 */
- (void)setIdentifier:(NSString *)aIdentifier {
	// not setting same value
	if(![aIdentifier isEqualToString:identifier]) {
		if(aIdentifier != nil) {
			// write identifier only if we are in normalmode
			if([elementController state] == NormalState) {
				// set identifier in dbAttribute
				if(dbElementValue != nil) {
					[dbElementValue setIdentifier:aIdentifier];
				}
			}
		}
		
		aIdentifier = [aIdentifier retain];
		[identifier release];
		identifier = aIdentifier;
	}
}

/**
 Sets General Purpose register
 */
- (void)setGpReg:(int)aValue {
	// do not set same vcalues
	if(aValue != gpReg) {
		gpReg = aValue;
		
		// check element base controller for state
		// if we are in normal operation state, we have to deal with parentid
		if([elementController state] == NormalState) {
			// set gpreg in dbElementValue
			if(dbElementValue != nil) {
				[dbElementValue setGpReg:aValue];
			}
		}
	}	
}

- (int)gpReg {
	return gpReg;
}

/**
 Set the valuedata of this value. the given NSData is converted to a string. \n
 Get this string with -valueDataAsString:
*/
- (void)setValueDataAsData:(NSData *)aData {
	if(aData != nil) {
		// set data length
		valueDataSize = [aData length];
		
		// set data in dbElementValue
		if(dbElementValue != nil) {
			[dbElementValue setValueData:aData];
			
			// only take the data, if we are no value where large datas have to be stored
			if((dataHoldThreshold == FullCacheMemFootprintType) || (valueDataSize < dataHoldThreshold)) {
				[aData retain];
				[valueData release];
				valueData = aData;
			} else {
				[valueData release];
				valueData = nil;
			}
		} else {
			// if we do not have a dbElementValue, we MUST hold the data
			[aData retain];
			[valueData release];
			valueData = aData;
		}
	} else {
		[valueData release];
		valueData = aData;	
	}
}

/**
 Set the valuedata with the given string. The string is converted to NSData object.
*/
- (void)setValueDataAsString:(NSString *)aString {	
	if(aString != nil) {
		NSString *escape = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
																			   (CFStringRef)aString,
																			   NULL,
																			   CFSTR("'"),
																			   kCFStringEncodingUTF8);
		[escape autorelease];
		[self setValueDataAsData:[escape dataUsingEncoding:NSUTF8StringEncoding]];
	} else {
		CocoLog(LEVEL_DEBUG, @"given NSString is nil!");
	}
}

/**
 Set the valuedata with the given number. The number is converted to NSData object.
 Internally setDataValueAsString is called.
 */
- (void)setValueDataAsNumber:(NSNumber *)aNumber {
	if(aNumber != nil) {
		// call setValueDataAsString to have this number saved as string interpretation
		NSString *numberAsString = [aNumber stringValue];
		[self setValueDataAsData:[numberAsString dataUsingEncoding:NSUTF8StringEncoding]];
	} else {
		CocoLog(LEVEL_DEBUG, @"given NSNumber is nil!");
	}
}

/**
 Set the type of this value. for basic types this value is enough. for extended valuetypes an extra object is created
 for storing the available information.
*/
- (void)setValuetype:(int)aType {
	if(aType != valuetype) {
		// write valuetype only if we are in normalmode
		if([elementController state] == NormalState) {
			// set new attributeid in dbElementValue
			if(dbElementValue != nil) {
				[dbElementValue setValuetype:aType];
			}
		}

		valuetype = aType;
		// not setting same values
	}
}

/**
 Sets the value data byte size
 */
- (void)setValueDataSize:(int)aSize {
	// do not set same vcalues
	if(aSize != valueDataSize) {
		valueDataSize = aSize;
		
		// check element base controller for state
		// if we are in normal operation state, we have to deal with parentid
		if([elementController state] == NormalState) {
			// set gpreg in dbElementValue
			if(dbElementValue != nil) {
				[dbElementValue setValueDataSize:aSize];
			}
		}
	}	
}

- (int)valueDataSize {
	return valueDataSize;
}

/**
 Only copy the reference to the owner element.
 The element value will stop observing the old and start observing the new element here.
 @param aElement the element that this attribute belongs to
 */
- (void)setElement:(MBElement *)aElement {
	// take this instance
	element = aElement;
	
	if(element != nil) {
		// set elementid
		[self setElementid:[element elementid]];
	}
}

/**
 Sets valuedata for this element value with the right conversation according to value type.
 Data is only stored in mem and not on db.
 This method is called during element base initialization.
 The passed in value, in case of single instance, is the document id.
*/
- (void)setMemoryValueDataWithConversation:(NSString *)aValue {
	if(aValue != nil) {
        if([self isSIStored]) {
            if(dbElementValue) {
                int docId = [aValue intValue];
                [dbElementValue setSiDocId:docId];
                [dbElementValue setDocumentEntry:[elementController documentEntryForId:docId]];
            }
            [self setValueDataAsData:nil];
        } else {
            NSData *data = nil;            
            // check for valuetype
            if(valuetype == BinaryValueType) {
                // get valuedata column
                //data = [[NSData alloc] initWithBase64EncodedString:[dict objectForKey:@"valuedata"]];
                data = [aValue decodeBase64WithNewlines:NO];
            } else {
                // no decoding needed
                data = [aValue dataUsingEncoding:NSUTF8StringEncoding];
            }            
            valueData = [data retain];
        }        		
	} else {
		CocoLog(LEVEL_WARN, @"have nil data!");
	}
}

#pragma mark - Getter

- (BOOL)isDbConnected {
	if([self dbElementValue] == nil) {
		return NO;
	}
    
    return YES;
}

- (id<MBDBElementValueAccessing>)dbElementValue {
	return dbElementValue;
}

- (int)valueid {
	return valueid;
}

- (int)elementid {
	return elementid;
}

/**
 Get the valuedata as NSData object.
 This method should be used if binary data is saved.
 */
- (NSData *)valueDataAsData {
	NSData *data = nil;
	
	if(valueData == nil || [valueData length] == 0) {
		data = [dbElementValue valueData];
		
		if((dataHoldThreshold == FullCacheMemFootprintType) || (valueDataSize < dataHoldThreshold)) {
			// hold data
			[data retain];
			[valueData release];
			valueData = data;
		}
	} else {
		data = valueData;
	}
	
	return data;
}

/**
 If this value is a date, then the valueData of this value is the number (as string) of seconds since 1970
 */
- (NSString *)valueDataAsString {
	NSData *data = [self valueDataAsData];
	
	NSString *stringData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSString *escape = (NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
																						   (CFStringRef)stringData,
																						   CFSTR(""),
																						   kCFStringEncodingUTF8);	
	[stringData release];
	return [escape autorelease];
}

/**
 Return the data of this value as number. if the data is no number, nil is returned.
 */
- (NSNumber *)valueDataAsNumber {
	// try to convert data to string and string to number
	NSString *numberAsString = [[NSString alloc] initWithData:[self valueDataAsData] encoding:NSUTF8StringEncoding];
	NSNumber *num = [NSNumber numberWithDouble:[numberAsString doubleValue]];
	// release numberAsString
	[numberAsString release];
	
	return num;
}

- (NSString *)identifier {
	return identifier;
}

- (int)valuetype {
	return valuetype;
}

- (MBElement *)element {
	return element;
}

// deleting
- (void)delete {
	CocoLog(LEVEL_DEBUG, @"");
	
	// stop observing our element
	[self stopObserveElement:element];
	
	// simply call delete method of dbElementValue
	if(dbElementValue != nil) {
		[dbElementValue delete];
	}
}

#pragma mark - Key Value Observing

/**
 Elementvalue observes the element for the element instance itself and the dbConnection
 */
- (void)startObserveElement:(MBElement *)aElement {
	if(!observingActive) {
		// we want to have the new value
		[aElement addObserver:self forKeyPath:@"elementid" options:NSKeyValueObservingOptionNew context:nil];
		[aElement addObserver:self forKeyPath:@"dbElement" options:NSKeyValueObservingOptionNew context:nil];
	}
	
	// observing active
	observingActive = YES;
}

/**
 Stop observing the parent
 */
- (void)stopObserveElement:(MBElement *)aElement {
	if(observingActive) {
		[aElement removeObserver:self forKeyPath:@"elementid"];
		[aElement removeObserver:self forKeyPath:@"dbElement"];	
	}
	
	// observing active
	observingActive = NO;	
}

/**
 Called when any of te observed values change.
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	// check for keyPath
	if([keyPath isEqualToString:@"elementid"]) {
		// treeinfo of parent has changed
		MBElement *elem = object;
		[self setElementid:[elem elementid]];
	} else if([keyPath isEqualToString:@"dbElement"]) {
		// if new value is not nil, connect this
		id newValue = [change valueForKey:NSKeyValueChangeNewKey];
		if(newValue != nil) {
			[self setIsDbConnected:YES writeIndex:[self hasIndex]];
		}
	}
}

#pragma mark - NSCopying

/**
 Makes a copy of self value for which the sender is responsible for releasing
 If self has a dbElementValue it will not be copied. The dbElementValue should be copied seperately and set with -setDbValue:
 To have this value connected to db.
 */
- (id)copyWithZone:(NSZone *)zone {
	// make a new object with alloc and init and return that
	// create a not db connected elementvalue
	// to connect it, call -setIsDbConnected:YES
	MBElementValue *newVal = [[MBElementValue alloc] init];
	if(newVal != nil) {
		// set state
		[newVal setState:CopyState];
		
		// now copy all value attributes of this value
		//[newVal setValueid:valueid];
		[newVal setIdentifier:identifier];
		[newVal setGpReg:gpReg];
		[newVal setValuetype:valuetype];
		[newVal setValueDataSize:valueDataSize];

		// check dataHoldThreshold and copy valueData. Only copy data in memory
		//if((dataHoldThreshold == FullCacheMemFootprintType) || (valueDataSize < dataHoldThreshold)) {
			[newVal setValueDataAsData:[self valueDataAsData]];
		//} else {
		//	[newVal setValueDataAsData:nil];
		//}
		
		// set reference to the element this value belongs
		//[newVal setElement:element];
		// set the underlying dbElementValue when we paste this value elsewhere to create a valueid
		//[newVal setDbElementValue:nil];

		// set state
		[newVal setState:NormalState];
	} else {
		CocoLog(LEVEL_ERR, @"cannot alloc new value!");
	}
	
	return newVal;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
	// first create a new MBElementValue
	MBElementValue *newValue = [[[MBElementValue alloc] init] autorelease];
	
	if([decoder allowsKeyedCoding]) {
		// decode the data and create a MBElementValue with it
		[newValue setValueid:[decoder decodeIntForKey:@"ElementValueIdKey"]];
		[newValue setElementid:[decoder decodeIntForKey:@"ElementValueElementIdKey"]];
		[newValue setIdentifier:[decoder decodeObjectForKey:@"ElementValueIdentifierKey"]];
		[newValue setGpReg:[decoder decodeIntForKey:@"ElementValueGpRegKey"]];
		[newValue setValuetype:[decoder decodeIntForKey:@"ElementValueTypeKey"]];
		[newValue setValueDataSize:[decoder decodeIntForKey:@"ElementValueDataSizeKey"]];
		
		// export big data to a export path that is given to us
		if([newValue valueDataSize] > [elementController memoryFootprint]) {
			NSString *importPath = [self importPath];
			if(importPath != nil) {
				// get filename, it is encoded
				// as of version 1.1.0b4 the value is written to file with the filename of the hashed data
				// to not save data twice but we have to support both
				NSString *filename = [decoder decodeObjectForKey:@"ElementValueExportFilename"];
				// this supports the old way
				if(filename == nil) {
					filename = [NSString stringWithFormat:@"%@.%@",[[NSNumber numberWithInt:[newValue valueid]] stringValue],@"ikamex"];
				}
				NSString *exportString = [NSString pathWithComponents:[NSArray arrayWithObjects:importPath,filename,nil]];
				[newValue setValueDataAsData:[NSData dataWithContentsOfFile:exportString]];
				// we cannot hold too much data, connect this elementvalue to db
				// index is not written here, must be called explicitly
				[newValue setIsDbConnected:YES writeIndex:NO];
			} else {
				CocoLog(LEVEL_WARN,@"have no importPath for oversize value!");
			}
		} else {
			if([newValue valuetype] == BinaryValueType) {
				// if we have binary data, make base64 decoding
				[newValue setValueDataAsData:[[decoder decodeObjectForKey:@"ElementValueDataKey"] decodeBase64WithNewlines:NO]];
			} else {
				// otherwise do no base64 decoding
				[newValue setValueDataAsData:[decoder decodeObjectForKey:@"ElementValueDataKey"]];		
			}
		}
	} else {
		// decode the data and create a MBElementValue with it
		[newValue setValueid:[[decoder decodeObject] intValue]];
		[newValue setElementid:[[decoder decodeObject] intValue]];
		[newValue setIdentifier:[decoder decodeObject]];
		[newValue setGpReg:[[decoder decodeObject] intValue]];
		[newValue setValuetype:[[decoder decodeObject] intValue]];
		[newValue setValueDataSize:[[decoder decodeObject] intValue]];

		// export big data to a export path that is given to us
		if([newValue valueDataSize] > [elementController memoryFootprint]) {
			NSString *importPath = [self importPath];
			if(importPath != nil) {
				// as of version 1.1.0b4 the value is written to file with the filename of the hashed data
				// to not save data twice but we have to support both
				NSString *filename = [decoder decodeObject];
				// this supports the old way
				if(filename == nil) {
					filename = [NSString stringWithFormat:@"%@.%@",[[NSNumber numberWithInt:[newValue valueid]] stringValue],@"ikamex"];
				}
				NSString *exportString = [NSString pathWithComponents:[NSArray arrayWithObjects:[self importPath],filename,nil]];
				[newValue setValueDataAsData:[NSData dataWithContentsOfFile:exportString]];
				// we cannot hold too much data, connect this elementvalue to db
				// index is not written here, must be called explicitly
				[newValue setIsDbConnected:YES writeIndex:NO];
			} else {
				CocoLog(LEVEL_WARN,@"have no importPath for oversize value!");
			}
		} else {
			if([newValue valuetype] == BinaryValueType) {
				// if we have binary data, make base64 decoding
				[newValue setValueDataAsData:[[decoder decodeObject] decodeBase64WithNewlines:NO]];
			} else {
				// otherwise do no base64 decoding
				[newValue setValueDataAsData:[decoder decodeObject]];		
			}
		}
	}
	
	return newValue;
}

/**
 Encoding elementvalues with a NSArchiver or NSKeyedArchiver
 if the valueDataSize is > DEFAULT_DATA_HOLD_SIZE the value is saved to a exportPath in the filesystem instead.
*/
- (void)encodeWithCoder:(NSCoder *)encoder {
	if([encoder allowsKeyedCoding]) { 
		// encode data of element
		[encoder encodeInt:valueid forKey:@"ElementValueIdKey"];
		[encoder encodeInt:elementid forKey:@"ElementValueElementIdKey"];
		[encoder encodeObject:identifier forKey:@"ElementValueIdentifierKey"];
		[encoder encodeInt:gpReg forKey:@"ElementValueGpRegKey"];
		[encoder encodeInt:valuetype forKey:@"ElementValueTypeKey"];
		[encoder encodeInt:valueDataSize forKey:@"ElementValueDataSizeKey"];
		
		// export big data to a export path that is given to us
		if(valueDataSize > [elementController memoryFootprint]) {
			NSString *exportPath = [self exportPath];
			if(exportPath != nil) {
				// we have to use our own ARP here
				NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			
				// generate filename
				// with version 1.1.0b4 we change this to a hashed filename to save every filename with the same content only once
				// this would be called single instance saving
				//NSString *filename = [NSString stringWithFormat:@"%@.%@",[[NSNumber numberWithInt:valueid] stringValue],@"ikamex"];
				// Hash filedata
                NSString *hash = nil;
                NSData *data = [self valueDataAsData];
                if([self isDbConnected]) {
                    id dbElemVal = [self dbElementValue];
                    // check if SI saved
                    if([dbElemVal isSIStored]) {
                        hash = [[dbElemVal documentEntry] docHash];
                    }
                }
                
                if(hash == nil) {
                    // still nil???
                    hash = [data sha1HashAsHexString];
                }
				// as of version 1.1.0b4 we have hashedfiledata.valueid as filename
				NSString *filename = [NSString stringWithFormat:@"%@.%@", hash, @"ikamexh"];
				NSString *exportString = [NSString pathWithComponents:[NSArray arrayWithObjects:exportPath, filename, nil]];
				[data writeToFile:exportString atomically:YES];
				
				// encode additional properties to identify the exported file
				[encoder encodeObject:filename forKey:@"ElementValueExportFilename"];
				
				// release arp
				[pool release];
			} else {
				CocoLog(LEVEL_WARN,@"have no exportPath for oversize value!");
			}
		} else {
			if(valuetype == BinaryValueType) {
				// do base64 encoding
				[encoder encodeObject:[[self valueDataAsData] encodeBase64WithNewlines:NO] forKey:@"ElementValueDataKey"];
			} else {
				// no base64 encoding
				[encoder encodeObject:[self valueDataAsData] forKey:@"ElementValueDataKey"];
			}
		}
	} else {
		// encode data of element
		[encoder encodeObject:[NSNumber numberWithInt:valueid]];
		[encoder encodeObject:[NSNumber numberWithInt:elementid]];
		[encoder encodeObject:identifier];
		[encoder encodeObject:[NSNumber numberWithInt:gpReg]];
		[encoder encodeObject:[NSNumber numberWithInt:valuetype]];
		[encoder encodeObject:[NSNumber numberWithInt:valueDataSize]];

		// export big data to a export path that is given to us
		if(valueDataSize > [elementController memoryFootprint]) {
			NSString *exportPath = [self exportPath];
			if(exportPath != nil) {
				// we have to use our own ARP here
				NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
				
				// generate filename
				// with version 1.1.0b4 we change this to a hashed filename to save every filename with the same content only once
				// this would be called single instance saving
				//NSString *filename = [NSString stringWithFormat:@"%@.%@",[[NSNumber numberWithInt:valueid] stringValue],@"ikamex"];
				// Hash filedata
                NSString *hash = nil;
                NSData *data = [self valueDataAsData];
                if([self isDbConnected] == YES) {
                    id dbElemVal = [self dbElementValue];
                    // check if SI saved
                    if([dbElemVal isSIStored] == YES) {
                        hash = [[dbElemVal documentEntry] docHash];
                    }
                }
                
                if(hash == nil) {
                    // still nil???
                    hash = [data sha1HashAsHexString];
                }
				// as of version 1.1.0b4 we have hashedfiledata.valueid as filename
				NSString *filename = [NSString stringWithFormat:@"%@.%@", hash, @"ikamexh"];
				NSString *exportString = [NSString pathWithComponents:[NSArray arrayWithObjects:exportPath,filename,nil]];
				[data writeToFile:exportString atomically:YES];
				
				// encode additional properties to identify the exported file
				[encoder encodeObject:filename];

				// release arp
				[pool release];
			} else {
				CocoLog(LEVEL_WARN,@"have no exportPath for oversize value!");
			}
		} else {
			if(valuetype == BinaryValueType) {
				// do base64 encoding
				[encoder encodeObject:[[self valueDataAsData] encodeBase64WithNewlines:NO]];
			} else {
				// no base64 encoding
				[encoder encodeObject:[self valueDataAsData]];
			}
		}
	}	
}

#pragma mark - DBElementValue Delegate notifications

- (void)singleInstanceStorageChange:(NSNumber *)generalPurposeRegister {
    gpReg = [generalPurposeRegister intValue];
}

@end
