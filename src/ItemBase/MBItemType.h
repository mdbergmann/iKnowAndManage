//
//  MBItemType.h
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

// ranges
#define ITEMVALUE_ID_RANGE              NSMakeRange(100,99)
#define ITEMVALUE_SIMPLE_ID_RANGE       NSMakeRange(100,19)
#define ITEMVALUE_FILEBASED_ID_RANGE    NSMakeRange(120,9)
#define ITEM_ID_RANGE                   NSMakeRange(200,99)
#define SYSTEMITEM_ID_RANGE             NSMakeRange(300,99)

#define SYSTEMITEM_SORTORDER_RANGE	NSMakeRange(1000000,99)
#define SYSTEMITEM_SORTORDER_START	1000000

// Identifier
typedef enum {
    RootItemID = -1,
	TextItemValueID = 100,
	NumberItemValueID = 102,
	CurrencyItemValueID,
	BoolItemValueID,
	DateItemValueID,
	URLItemValueID,
	FileItemValueID = 120,
	ImageItemValueID,
    PDFItemValueID,
	ExtendedTextItemValueID,
	ItemValueRefID = 130,
	StdItemID = 200,
	TableItemID,
	TemplateItemID,
	ItemRefID = 230,
	SystemItemID = 300,
	TrashcanItemID,
	UndoItemID,
	RootTemplateItemID,
	RootContactItemID,
	ImportItemID,
	AppInfoItemID
}MBTypeIdentifier;

// Items
typedef enum {
	StdItemType = 200,
	TableItemType,
	TemplateItemType,
	ContactItemType,
	ItemRefType = 230,
	RootTemplateItemType = 300,
	RootContactItemType,
	ImportItemType,
	TrashcanItemType,
	UndoItemType,
	AppInfoItemType
}MBItemTypes;

typedef enum {
    SimpleTextItemValueType = 100,
    NumberItemValueType = 102,
    CurrencyItemValueType,
    BoolItemValueType,
    DateItemValueType,
    URLItemValueType,
    FileItemValueType = 120,
    ImageItemValueType,
    PDFItemValueType,
    ExtendedTextItemValueType,
    ItemValueRefType = 130,
    ExtendedTextTXTValueType = 150,	// not for normal usage
    ExtendedTextRTFValueType,		// not for normal usage
    ExtendedTextRTFDValueType		// not for normal usage
}MBItemValueTypes;

enum MBSystemItemsSortorders {
	ContactItemSortorder = SYSTEMITEM_SORTORDER_START,
	TemplateItemSortorder,
	ImportItemSortorder,
	TrashcanItemSortorder,
	AppInfoItemSortorder
};

// names
#define STD_ITEMTYPE_NAME			MBLocaleStr(@"StdItemName")
#define TABLE_ITEMTYPE_NAME			MBLocaleStr(@"TableItemName")
#define ROOT_TEMPLATE_ITEMTYPE_NAME	MBLocaleStr(@"RootTemplateItemName")
#define TEMPLATE_ITEMTYPE_NAME		MBLocaleStr(@"TemplateItemName")
#define ROOT_CONTACT_ITEMTYPE_NAME	MBLocaleStr(@"RootContactItemName")
#define CONTACT_ITEMTYPE_NAME		MBLocaleStr(@"ContactItemName")
#define TRASHCAN_ITEMTYPE_NAME		MBLocaleStr(@"TrashcanItemName")
#define IMPORTS_ITEMTYPE_NAME		@"Imports"
#define UNDO_ITEMTYPE_NAME			@"UndoItemName"
#define APPINFO_ITEMTYPE_NAME		@"AppInfoItemName"
#define ITEMREF_ITEMTYPE_NAME		MBLocaleStr(@"ItemRefName")

// names
#define ITEMVALUE_NAME						MBLocaleStr(@"ItemValueName")
#define SIMPLETEXT_ITEMVALUE_TYPE_NAME		MBLocaleStr(@"STextItemValueName")
#define EXTENDEDTEXT_ITEMVALUE_TYPE_NAME	MBLocaleStr(@"ETextItemValueName")
#define NUMBER_ITEMVALUE_TYPE_NAME			MBLocaleStr(@"NumberItemValueName")
#define CURRENCY_ITEMVALUE_TYPE_NAME		MBLocaleStr(@"CurrencyItemValueName")
#define BOOL_ITEMVALUE_TYPE_NAME			MBLocaleStr(@"BoolItemValueName")
#define DATE_ITEMVALUE_TYPE_NAME			MBLocaleStr(@"DateItemValueName")
#define URL_ITEMVALUE_TYPE_NAME				MBLocaleStr(@"URLItemValueName")
#define FILE_ITEMVALUE_TYPE_NAME			MBLocaleStr(@"FileItemValueName")
#define IMAGE_ITEMVALUE_TYPE_NAME			MBLocaleStr(@"ImageItemValueName")
#define PDF_ITEMVALUE_TYPE_NAME             MBLocaleStr(@"PDFItemValueName")
#define ITEMVALUEREF_ITEMTYPE_NAME			MBLocaleStr(@"ItemValueRefName")

@interface MBItemType : NSObject  {
}

+ (NSArray *)itemTypes;
+ (NSArray *)systemItemTypes;
+ (NSArray *)itemValueTypes;

+ (NSDictionary *)defaultFileValueTypeSpec;

@end
