//
//  MBExtendedTextItemValue.h
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
#import "MBFileItemValue.h"

#define ITEMVALUE_ETEXT_VALUE_IDENTIFIER			@"itemvalueetextvalue"
#define ITEMVALUE_ETEXT_ISLINK_IDENTIFIER			@"itemvalueetextislink"
#define ITEMVALUE_ETEXT_LINKVALUE_IDENTIFIER		@"itemvalueetextlinkvalue"
#define ITEMVALUE_ETEXT_AUTOHANDLE_IDENTIFIER		@"itemvalueetextautohandleloadsave"
#define ITEMVALUE_ETEXT_TEXTTYPE_IDENTIFIER			@"itemvalueetexttexttype"

/**
\brief these are the texttypes we have available to this extended text value
 */
typedef enum {
	TextTypeTXT = 0,
	TextTypeRTF = 1,
	TextTypeRTFD = 2
}MBTextType;

@interface MBExtendedTextItemValue : MBFileItemValue <NSCopying, NSCoding> {

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

- (NSData *)valueDataByLoadingFromTarget;

// converting
+ (NSString *)convertDataToString:(NSData *)textData withTextType:(int)textType;

// needed for sorting
- (NSString *)valueDataAsString;

@end

@interface MBExtendedTextItemValue (ElementBase)

// attribute setter
- (void)setTextType:(MBTextType)aType;
// attribute getter
- (MBTextType)textType;

- (void)writeValueIndexEntryWithCreate:(BOOL)flag;

@end
