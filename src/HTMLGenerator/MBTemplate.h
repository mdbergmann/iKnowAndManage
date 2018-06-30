//
//  MBTemplate.h
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 26.09.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// ----------------------------------------------------------
// Stypesheet URL
// ----------------------------------------------------------
// URL where stylesheet lives
#define HTMLStyleSheetFileURLStringKey @"{$StyleSheetFileURLString}"

// ----------------------------------------------------------
// ItemList specific
// ----------------------------------------------------------
// value of itemvalue encoded as string, whatever this will be
#define HTMLItemValueValueStringKey @"{$ItemValueValueString}"

// ----------------------------------------------------------
// Item specific
// ----------------------------------------------------------
// Identifier like in MBItemType.h
#define HTMLItemIdentifierKey @"{$ItemIdentifier}"
// number of encoded valuedicts
#define HTMLItemNumberOfValuesKey @"{$ItemNumberOfValues}"
// print with Item itself? (0,1)
#define HTMLItemPrintSelfKey @"{$ItemPrintSelf}"
// The array of Value Dicts
#define HTMLItemValuesKey @"{$ItemValues}"
// Item name
#define HTMLItemNameStringKey @"{$ItemNameString}"
// item url
#define HTMLItemNameURLKey @"{$ItemNameURL}"

// ----------------------------------------------------------
// Std general
// ----------------------------------------------------------
// The name of the ItemValue
#define HTMLItemValueNameStringKey @"{$ItemValueNameString}"
// The url of the ItemValue
#define HTMLItemValueNameURLKey @"{$ItemValueNameURL}"
// sText, Number, Currency, Date, Bool, URL
#define HTMLItemValueTypeStringKey @"{$ItemValueTypeString}"
// Comment
#define HTMLItemValueCommentStringKey @"{$ItemValueCommentString}"
// creation date as string
#define HTMLItemValueCreationDateStringKey @"{$ItemValueCreationDateString}"
// "Yes/No"
#define HTMLItemValueEncryptedStringKey @"{$ItemValueEncryptedString}"
// ----------------------------------------------------------
// Std ItemValue specific
// ----------------------------------------------------------
// "Textvalue", "Datevalue", "Numbervalue", "Currencyvalue", "Boolvalue", "URLvalue"
#define HTMLItemValueTypeValStringKey @"{$ItemValueTypeValString}"
// value of the general itemvalue as string
#define HTMLItemValueDataKey @"{$ItemValueData}"

// ----------------------------------------------------------
// Special general
// ----------------------------------------------------------
// "Internal" or "External"
#define HTMLItemValueDataLocationStringKey @"{$ItemValueDataLocationString}"
// "empty" or "URL"
#define HTMLItemValueLocationURLStringKey @"{$ItemValueLocationURLString}"
// ----------------------------------------------------------
// ExtendedText ItemValue specific
// ----------------------------------------------------------
// text type (TXT, RTF, RTFD)
#define HTMLETextValueTextTypeStringKey @"{$ETextValueTextTypeString}"
// preview of the text data, should be TXT, if we do not find a way to convert RTF to HTML
#define HTMLETextValuePreviewDataKey @"{$ETextValuePreviewData}"
// ----------------------------------------------------------
// Image ItemValue specific
// ----------------------------------------------------------
// URL for IMG HTML tag where the preview image is found
#define HRMLImagePreviewURLKey @"{$ImagePreviewURL}"
// Image type string "jpeg", "png", ...
#define HTMLImageValueTypeStringKey @"{$ImageValueTypeString}"
// Image dimensions in pixel (width x height)
#define HTMLImageValueDimensionStringKey @"{$ImageValueDimensionString}"
// Image size in kbytes
#define HTMLImageValueSizeStringKey @"{$ImageValueSizeString}"
// ----------------------------------------------------------
// File ItemValue specific
// ----------------------------------------------------------
// File type string "swx", "pdf", ...
#define HTMLFileValueTypeStringKey @"{$FileValueTypeString}"
// URL for IMG HTML tag where the filetype icon if found
#define HTMLFileValueTypeIconURLKey @"{$FileValueTypeIconURL}"
// Filesize in kbytes
#define HTMLFileValueSizeStringKey @"{$FileValueSizeString}"

// ----------------------------------------------------------
// Main stuff
// ----------------------------------------------------------
// the main html
#define HTMLMainTable @"{$MainTable}"
// a value list row
#define HTMLSimpleValueTableRow @"{$SimpleValueRows}"

@interface MBTemplate : NSObject
{

}

/**
    replace the source string which is a template with the dictionary
    entries.
 */
+ (NSString *)replaceTemplateStringSource:(NSString *)source withDict:(NSDictionary *)dict;

@end
