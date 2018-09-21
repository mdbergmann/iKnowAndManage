#import <CoreGraphics/CoreGraphics.h>//
//  MBItemValue.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 25.08.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import "MBItemValue.h"
#import "MBElement.h"
#import "globals.h"
#import "MBValueIndexController.h"
#import "MBElementValue.h"
#import "ColorRGBAArchiver.h"
#import "MBPreferenceController.h"

@implementation MBItemValue

- (id)init {
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"cannot init super!");
	} else {
		// set state
		[self setState:InitState];
		
		//NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		// add neccesary attributes
		// name
		[self setName:ITEMVALUE_NAME];
		// comment
		[self setComment:@""];
		// type
		[self setValuetype:SimpleTextItemValueType];
		// sortorder
		[self setSortorder:0];
		// dateCreated
		[self setDateCreated:[NSDate date]];
		// date modified
		[self setDateModified:[NSDate date]];
		// fgcolor
		//self setFgColor:[NSColor colorFromRGBAArchivedString:[defaults objectForKey:MBDefaultsItemValueFgColorKey]]];
		// bgcolor
		//[self setBgColor:[NSColor colorFromRGBAArchivedString:[defaults objectForKey:MBDefaultsItemValueBgColorKey]]];
		
		// set item
		item = nil;
		
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
		
		// connect the itemvalue
		[self setIsDbConnected:YES];
		
		// set state
		[self setState:NormalState];
	}
	
	return self;
}

- (id)initWithInitializedElement:(MBElement *)aElement {
	self = [super initWithInitializedElement:aElement];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"cannot init!");
	}
	
	return self;	
}

- (void)dealloc {
	// set state
	[self setState:DeallocState];
	
	// item
	[self setItem:nil];
	
	// release super
	[super dealloc];
}

// parent item
- (void)setItem:(id)aItem {
	item = aItem;
	
	// in lazy mode?
	if(state == NormalState) {
		if(element != nil) {
			// for items we can element base controller set the subtree, because there are no children for itemvalues
			[element setParent:[aItem element]];
		} else {
			CocoLog(LEVEL_ERR,@"element is nil!");
		}
	}
}

- (id)item {
	return item;
}

// number of attributes
- (int)numberOfItemValueAttributes {
	int ret = 0;
	
	if(element != nil) {
		ret = [attributeDict count];
	} else {
		CocoLog(LEVEL_ERR,@"element is nil!");
	}
	
	return ret;
}

// getting the size
/**
 \brief getting the data size in bytes of all element values
*/
- (unsigned int)dataSize {
	int ret = 0;
	
	NSEnumerator *iter = [[[self element] elementValues] objectEnumerator];
	MBElementValue *val = nil;
	while((val = [iter nextObject])) {
		ret += [val valueDataSize];
	}
	
	return ret;
}

// overriding description
- (NSString *)description {
	// return the comment of this itemvalue
	return [self comment];
}

- (NSString *)typeAsString {
	NSString *typeStr;
		
	switch([self valuetype]) {
		case SimpleTextItemValueType:
			typeStr = SIMPLETEXT_ITEMVALUE_TYPE_NAME;
			break;
		case ExtendedTextItemValueType:
			typeStr = EXTENDEDTEXT_ITEMVALUE_TYPE_NAME;
			break;
		case URLItemValueType:
			typeStr = URL_ITEMVALUE_TYPE_NAME;
			break;
		case NumberItemValueType:
			typeStr = NUMBER_ITEMVALUE_TYPE_NAME;
			break;
		case BoolItemValueType:
			typeStr = BOOL_ITEMVALUE_TYPE_NAME;
			break;
		case DateItemValueType:
			typeStr = DATE_ITEMVALUE_TYPE_NAME;
			break;
		case CurrencyItemValueType:
			typeStr = CURRENCY_ITEMVALUE_TYPE_NAME;
			break;
		case FileItemValueType:
			typeStr = FILE_ITEMVALUE_TYPE_NAME;
			break;
		case ImageItemValueType:
			typeStr = IMAGE_ITEMVALUE_TYPE_NAME;
			break;
		case PDFItemValueType:
			typeStr = PDF_ITEMVALUE_TYPE_NAME;
			break;
		case ItemValueRefType:
			typeStr = ITEMVALUEREF_ITEMTYPE_NAME;
			break;
		default:
			typeStr = SIMPLETEXT_ITEMVALUE_TYPE_NAME;
			break;
	}
	
	return typeStr;
}

//--------------------------------------------------------------------
//------------- Item De/Encryption ----------------------
//--------------------------------------------------------------------
/**
 \brief this method encrypts the comment and the value that is returned by -valueDataAsString
 First the comment is encrypted, if however an error occurs on encrypting the valueDataAsString, 
 the comment is decrypted to have a complete decrypted state.
 @returns MBCryptoErrorCode
*/
- (MBCryptoErrorCode)encryptWithString:(NSString *)aString {
	int ret = MBCryptoOK;
	
	if((aString != nil) || ([aString length] > 0)) {
		// check the encryption state of this item
		if([self encryptionState] != EncryptedState) {
			NSData *commentData = [self commentAsData];
			NSData *encryptedData = nil;
			ret = [self doEncryptionOfData:commentData
							 withKeyString:aString 
							 encryptedData:&encryptedData];
			if(ret == MBCryptoOK) {
				// set state
				[self setEncryptionState:EncryptedState];
				// write data
				[self setCommentAsData:encryptedData];
			}
		}
	} else {
		CocoLog(LEVEL_WARN,@"keyString is nil or empty!");
		ret = MBCryptoUnableToEncrypt;
	}
	
	return ret;
}

/**
 \brief this method decrypts the encrypted comment and the value that is returned by -valueDataAsString.
 @returns MBCryptoErrorCode
*/
- (MBCryptoErrorCode)decryptWithString:(NSString *)aString {
	int ret = MBCryptoOK;
	
	if((aString != nil) || ([aString length] > 0)) {
		// check the encryption state of this item
		if([self encryptionState] == EncryptedState) {
			NSData *commentData = [self commentAsData];
			NSData *decryptedData = nil;
			ret = [self doDecryptionOfData:commentData
							 withKeyString:aString 
							 decryptedData:&decryptedData];
			if(ret == MBCryptoOK) {
				// set state
				[self setEncryptionState:DecryptedState];
				// write data
				[self setCommentAsData:decryptedData];
			}
		} else {
			CocoLog(LEVEL_WARN,@"this item is not encrypted, doing nothing here!");
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
	MBItemValue *newItemval = [[MBItemValue alloc] initWithInitializedElement:[[element copy] autorelease]];
	if(newItemval == nil) {
		CocoLog(LEVEL_ERR,@"cannot alloc new MBItem!");
	} else {
	}
	
	return newItemval;
}

//--------------------------------------------------------------------
//------------- NSCoding protocoll -----------------------------------
//--------------------------------------------------------------------
- (id)initWithCoder:(NSCoder *)decoder NS_RETURNS_RETAINED {
	MBItemValue *newItemval = nil;
	
	if([decoder allowsKeyedCoding]) {
		// decode the only encoded object
		MBElement *elem = [decoder decodeObjectForKey:@"ItemValueElement"];
		// create commonitem with that
		newItemval = [[MBItemValue alloc] initWithInitializedElement:elem];
	} else {
		// decode the only encoded object
		MBElement *elem = [decoder decodeObject];
		// create commonitem with that
		newItemval = [[MBItemValue alloc] initWithInitializedElement:elem];
	}
	
	return newItemval;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	if([encoder allowsKeyedCoding]) {
		// only encode the element itself
		[encoder encodeObject:element forKey:@"ItemValueElement"];
	} else {
		// only encode the element itself
		[encoder encodeObject:element];
	}	
}

/**
\brief abstract method -setValueData: Each subclass has to override this method
 */
- (void)setValueData:(NSData *)aData {
	// does nothing
}

/**
\brief abstract method -valueData: Each subclass has to override this method
 */
- (NSData *)valueData {
	return [NSData data];
}

/**
\brief abstract method -valueDataAsString: Each subclass has to override this method
 */
- (NSString *)valueDataAsString {
	return @"";
}

/**
\brief abstract method -valueDataForComparison: Each subclass has to override this method
 */
- (NSString *)valueDataForComparison {
	return @"";
}

@end

@implementation MBItemValue (ElementBase)

// attribute setter
- (void)setName:(NSString *)aName {
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_NAME_IDENTIFIER];
	if(elemval != nil) {
		[elemval setValueDataAsString:aName];
		// send Notification
		if(([self state] == NormalState) || ([self state] == UnRedoState)) {
			// register itemvalue to the list of to be processed valueindexes
			[[MBValueIndexController defaultController] registerCommonItem:self];
			
			MBSendNotifyItemValueAttribsChanged(self);
		}
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
        [self createAttributeForValue:aName withValueType:StringValueType identifier:ITEMVALUE_NAME_IDENTIFIER];
	}
}

- (void)setComment:(NSString *)aComment {
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_COMMENT_IDENTIFIER];
	if(elemval != nil) {
		[elemval setValueDataAsString:aComment];
		// register itemvalue to the list of to be processed valueindexes
		[[MBValueIndexController defaultController] registerCommonItem:self];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
        [self createAttributeForValue:aComment withValueType:StringValueType identifier:ITEMVALUE_COMMENT_IDENTIFIER];
	}	
}

- (void)setCommentAsData:(NSData *)aCommentData {
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_COMMENT_IDENTIFIER];
	if(elemval != nil) {
		[elemval setValueDataAsData:aCommentData];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, cannot write comment!");
	}	
}

- (void)setValuetype:(MBItemValueTypes)aType {
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_TYPE_IDENTIFIER];
	if(elemval != nil) {
		[elemval setValueDataAsNumber:[NSNumber numberWithInt:aType]];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
        [self createAttributeForValue:[NSNumber numberWithInt:aType] withValueType:NumberValueType identifier:ITEMVALUE_TYPE_IDENTIFIER writeIndex:NO];
	}		
}

- (void)setDateCreated:(NSDate *)aDate {
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_DATECREATED_IDENTIFIER];
	if(elemval != nil) {
		[elemval setValueDataAsNumber:[NSNumber numberWithDouble:[aDate timeIntervalSince1970]]];
	} else {
		CocoLog(LEVEL_WARN,@"[elementvalue is nil, creating it!");
        [self createAttributeForValue:[NSNumber numberWithDouble:[aDate timeIntervalSince1970]] 
                        withValueType:NumberValueType identifier:ITEMVALUE_DATECREATED_IDENTIFIER writeIndex:NO];
	}	
}

- (void)setDateModified:(NSDate *)aDate {
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_DATEMODIFIED_IDENTIFIER];
	if(elemval != nil) {
		[elemval setValueDataAsNumber:[NSNumber numberWithDouble:[aDate timeIntervalSince1970]]];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
        [self createAttributeForValue:[NSNumber numberWithDouble:[aDate timeIntervalSince1970]] 
                        withValueType:NumberValueType identifier:ITEMVALUE_DATEMODIFIED_IDENTIFIER writeIndex:NO];
	}
}

- (void)setFgColor:(NSColor *)aColor {
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_FGCOLOR_IDENTIFIER];
	if(elemval != nil) {
		[elemval setValueDataAsString:[aColor archiveRGBAComponentsAsString]];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
        [self createAttributeForValue:[aColor archiveRGBAComponentsAsString] withValueType:StringValueType identifier:ITEMVALUE_FGCOLOR_IDENTIFIER writeIndex:NO];
	}		
}

- (void)setBgColor:(NSColor *)aColor {
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_BGCOLOR_IDENTIFIER];
	if(elemval != nil) {
		[elemval setValueDataAsString:[aColor archiveRGBAComponentsAsString]];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
        [self createAttributeForValue:[aColor archiveRGBAComponentsAsString] withValueType:StringValueType identifier:ITEMVALUE_FGCOLOR_IDENTIFIER writeIndex:NO];
	}	
}

// attribute getter
- (NSString *)name {
	NSString *ret = nil;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_NAME_IDENTIFIER];
	if(elemval != nil) {
		ret = [elemval valueDataAsString];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		ret = ITEMVALUE_NAME;
        [self createAttributeForValue:ret withValueType:StringValueType identifier:ITEMVALUE_NAME_IDENTIFIER];
	}	
	
	return ret;
}

- (NSString *)comment {
	NSString *ret = nil;
	
	if([self encryptionState] == DecryptedState) {
		MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_COMMENT_IDENTIFIER];
		if(elemval != nil) {
			ret = [elemval valueDataAsString];
		} else {
			CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
			ret = @"";
            [self createAttributeForValue:ret withValueType:StringValueType identifier:ITEMVALUE_COMMENT_IDENTIFIER];
		}
	} else {
		ret = MBLocaleStr(@"Encrypted");
	}
	
	return ret;
}

- (NSData *)commentAsData {
	NSData *ret = nil;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_COMMENT_IDENTIFIER];
	if(elemval != nil) {
		ret = [elemval valueDataAsData];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		ret = [NSData data];
        [self createAttributeForValue:@"" withValueType:StringValueType identifier:ITEMVALUE_COMMENT_IDENTIFIER];
	}	
	
	return ret;
}

- (MBItemValueTypes)valuetype {
	int ret;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_TYPE_IDENTIFIER];
	if(elemval != nil) {
		ret = [[elemval valueDataAsNumber] intValue];
	} else {
		CocoLog(LEVEL_WARN,@"[elementvalue is nil, creating it!");
		ret = SimpleTextItemValueType;
        [self createAttributeForValue:[NSNumber numberWithInt:ret] withValueType:NumberValueType identifier:ITEMVALUE_TYPE_IDENTIFIER writeIndex:NO];
	}
	
	return ret;
}

- (NSDate *)dateCreated {
	NSDate *ret = nil;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_DATECREATED_IDENTIFIER];
	if(elemval != nil) {
		ret = [NSDate dateWithTimeIntervalSince1970:[[elemval valueDataAsNumber] doubleValue]];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		ret = [NSDate date];
        [self createAttributeForValue:[NSNumber numberWithDouble:[ret timeIntervalSince1970]] 
                        withValueType:NumberValueType identifier:ITEMVALUE_DATECREATED_IDENTIFIER writeIndex:NO];
	}
	
	return ret;
}

- (NSDate *)dateModified {
	NSDate *ret = nil;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_DATEMODIFIED_IDENTIFIER];
	if(elemval != nil) {
		ret = [NSDate dateWithTimeIntervalSince1970:[[elemval valueDataAsNumber] doubleValue]];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		ret = [NSDate date];
        [self createAttributeForValue:[NSNumber numberWithDouble:[ret timeIntervalSince1970]] 
                        withValueType:NumberValueType identifier:ITEMVALUE_DATEMODIFIED_IDENTIFIER writeIndex:NO];
	}
	
	return ret;
}

- (NSColor *)fgColor {
	NSColor *ret = nil;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_FGCOLOR_IDENTIFIER];
	if(elemval != nil) {
		ret = [NSColor colorFromRGBAArchivedString:[elemval valueDataAsString]];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		ret = [NSColor colorFromRGBAArchivedString:[userDefaults valueForKey:MBDefaultsItemValueFgColorKey]];
        [self createAttributeForValue:[ret archiveRGBAComponentsAsString] withValueType:StringValueType identifier:ITEMVALUE_FGCOLOR_IDENTIFIER writeIndex:NO];
	}	
	
	return ret;
}

- (NSColor *)bgColor {
	NSColor *ret = nil;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_BGCOLOR_IDENTIFIER];
	if(elemval != nil) {
		ret = [NSColor colorFromRGBAArchivedString:[elemval valueDataAsString]];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		ret = [NSColor colorFromRGBAArchivedString:[userDefaults valueForKey:MBDefaultsItemValueBgColorKey]];
        [self createAttributeForValue:[ret archiveRGBAComponentsAsString] withValueType:StringValueType identifier:ITEMVALUE_FGCOLOR_IDENTIFIER writeIndex:NO];
	}
	
	return ret;
}

/**
 \brief write initial valueindex entries to the table
*/
- (void)writeValueIndexEntryWithCreate:(BOOL)flag {
	// here name, comment
	
	// name
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_NAME_IDENTIFIER];
	if(flag) {
		// create valueindex entry
		[elemval createIndexEntryWithIdentifier:ITEMVALUE_NAME_IDENTIFIER];
	}
	[elemval setIndexValue:[self name]];

	// comment
	elemval = [attributeDict valueForKey:ITEMVALUE_COMMENT_IDENTIFIER];
	if(flag)
	{
		// create valueindex entry
		[elemval createIndexEntryWithIdentifier:ITEMVALUE_COMMENT_IDENTIFIER];
	}
	[elemval setIndexValue:[self comment]];
}

@end
