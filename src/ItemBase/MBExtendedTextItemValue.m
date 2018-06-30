//
//  MBExtendedTextItemValue.m
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

#import <CocoLogger/CocoLogger.h>
#import "MBFileItemValue.h"
#import "MBExtendedTextItemValue.h"
#import "globals.h"
#import "MBElement.h"
#import "MBElementValue.h"

@implementation MBExtendedTextItemValue

// inits
- (id)init {
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"cannot init super!");
	} else {
		// set state
		[self setState:InitState];

		// set identifier
		[self setIdentifier:ExtendedTextItemValueID];
		// set valuetype
		[self setValuetype:ExtendedTextItemValueType];

		// set the extended rtf text value
		NSAttributedString *attribString = [[[NSAttributedString alloc] initWithString:@""] autorelease];
		[self setValueData:[attribString RTFFromRange:NSMakeRange(0, [attribString length]) documentAttributes:nil]];

		// auto handle load save
		[self setAutoHandleLoadSave:NO];
		// text type
		[self setTextType:TextTypeRTF];

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
		
		// create index
		[self writeValueIndexEntryWithCreate:YES];
		
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
 \brief if value is a link, load the data from link target and return that
*/
- (NSData *)valueDataByLoadingFromTarget {
	NSData *returnData = [super valueDataByLoadingFromTarget];
	if([self isLink]) {
		if(returnData != nil) {
			switch([self textType]) {
				case TextTypeTXT:
					break;
				case TextTypeRTF:
				{
					NSAttributedString *attribString = [[[NSAttributedString alloc] initWithRTF:returnData documentAttributes:nil] autorelease];
					returnData = [attribString RTFFromRange:NSMakeRange(0, [attribString length]) documentAttributes:nil];
				}
					break;
				case TextTypeRTFD:
				{
					NSAttributedString *attribString = [[[NSAttributedString alloc] initWithRTFD:returnData documentAttributes:nil] autorelease];
					returnData = [attribString RTFDFromRange:NSMakeRange(0, [attribString length]) documentAttributes:nil];
				}
					break;
			}
		}
	}
	
	return returnData;
}

/**
\brief overriding super classes abstract method
 */
- (NSString *)valueDataAsString {
	NSString *ret = nil;
	
	if([self encryptionState] == DecryptedState) {
		ret = [MBExtendedTextItemValue convertDataToString:[self valueData] withTextType:[self textType]];
	} else {
		ret = MBLocaleStr(@"Encrypted");
	}
	
	return ret;
}

/**
 \brief convert any TXT, RTF, RTFD data to string
*/
+ (NSString *)convertDataToString:(NSData *)textData withTextType:(int)textType
{
	NSString *ret = nil;
	
	switch(textType)
	{
		case TextTypeTXT:
		{
			ret = [[[NSString alloc] initWithData:textData encoding:NSUTF8StringEncoding] autorelease];
			break;
		}
		case TextTypeRTF:
		{
			NSAttributedString *attribString = [[[NSAttributedString alloc] initWithRTF:textData 
																	 documentAttributes:nil] autorelease];
			NSAttributedString *rtfData = [[[NSAttributedString alloc] initWithRTF:[attribString RTFFromRange:NSMakeRange(0,[attribString length]) documentAttributes:nil]
																documentAttributes:nil] autorelease]; 
			// extract text as string
			ret = [rtfData string];
			break;
		}
		case TextTypeRTFD:
		{
			NSAttributedString *attribString = [[[NSAttributedString alloc] initWithRTFD:textData 
																	  documentAttributes:nil] autorelease];
			NSAttributedString *rtfdData = [[[NSAttributedString alloc] initWithRTF:[attribString RTFFromRange:NSMakeRange(0,[attribString length]) documentAttributes:nil]
																 documentAttributes:nil] autorelease]; 
			// extract text as string
			ret = [rtfdData string];
			break;
		}
        default:break;
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
	MBExtendedTextItemValue *newItemval = [[MBExtendedTextItemValue alloc] initWithInitializedElement:[[element copy] autorelease]];
	if(newItemval == nil) {
		CocoLog(LEVEL_ERR,@"cannot alloc new MBItem!");
	} else {
	}
	
	return newItemval;
}

//--------------------------------------------------------------------
//------------- NSCoding protocoll -----------------------------------
//--------------------------------------------------------------------
- (id)initWithCoder:(NSCoder *)decoder {
	MBExtendedTextItemValue *newItemval = nil;
	
	if([decoder allowsKeyedCoding]) {
		// decode the only encoded object
		MBElement *elem = [decoder decodeObjectForKey:@"ItemValueElement"];
		// create commonitem with that
		newItemval = [[[MBExtendedTextItemValue alloc] initWithInitializedElement:elem] autorelease];
	} else {
		// decode the only encoded object
		MBElement *elem = [decoder decodeObject];
		// create commonitem with that
		newItemval = [[[MBExtendedTextItemValue alloc] initWithInitializedElement:elem] autorelease];
	}
	
	return newItemval;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
}

@end

@implementation MBExtendedTextItemValue (ElementBase)

// attribute setter
- (void)setTextType:(MBTextType)aType {
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_ETEXT_TEXTTYPE_IDENTIFIER];
	if(elemval != nil) {
		[elemval setValueDataAsNumber:[NSNumber numberWithInt:aType]];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
        [self createAttributeForValue:[NSNumber numberWithInt:aType] withValueType:NumberValueType identifier:ITEMVALUE_ETEXT_TEXTTYPE_IDENTIFIER writeIndex:NO];
	}
}

// attribute getter
- (NSData *)valueData {
	NSData *ret = nil;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_ETEXT_VALUE_IDENTIFIER];
	if(elemval != nil) {
		ret = [elemval valueDataAsData];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		// set the extended rtf text value
		NSAttributedString *attribString = [[[NSAttributedString alloc] initWithString:@""] autorelease];
		ret = [attribString RTFFromRange:NSMakeRange(0,[attribString length]) documentAttributes:nil];
        [self createAttributeForValue:ret withValueType:BinaryValueType identifier:ITEMVALUE_ETEXT_VALUE_IDENTIFIER writeIndex:YES];
	}
	
	return ret;
}

- (MBTextType)textType {
    MBTextType ret = TextTypeRTF;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_ETEXT_TEXTTYPE_IDENTIFIER];
	if(elemval != nil) {
		ret = (MBTextType) [[elemval valueDataAsNumber] intValue];
	} else {
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
        [self createAttributeForValue:[NSNumber numberWithInt:ret] withValueType:NumberValueType identifier:ITEMVALUE_ETEXT_TEXTTYPE_IDENTIFIER writeIndex:NO];
	}
	
	return ret;
}

/**
\brief write initial valueindex entries to the table
 */
- (void)writeValueIndexEntryWithCreate:(BOOL)flag {
	// first super
	[super writeValueIndexEntryWithCreate:flag];
	
	// text as string
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_ETEXT_VALUE_IDENTIFIER];
	if(flag && ![self isLink])
	{
		// create valueindex entry
		[elemval createIndexEntryWithIdentifier:ITEMVALUE_ETEXT_VALUE_IDENTIFIER];
	}
	[elemval setIndexValue:[self valueDataAsString]];
}

@end

