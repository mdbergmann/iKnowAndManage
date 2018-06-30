//
//  MBSearchController.h
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 27.09.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>

// we have a special search item that is only available here
#define AlarmItemID				5000
#define ALARM_ITEM_TYPE_NAME	@"Alarm"

@class MBItem;

// search mode
typedef enum _MBSearchModeType {
	MBSearchModeRegEx = 0,
	MBSearchModeNormal
}MBSearchModeType;

typedef enum _MBMatchType {
	MBMatchAny = 0,		// OR
	MBMatchAll			// AND
}MBMatchType;

@interface MBSearchController : NSObject {
	BOOL caseSensitiveSearch;
	BOOL searchExternalData;
	BOOL recursiveSearch;
	BOOL searchInFiledata;

	// the search mode
	MBSearchModeType searchMode;
	// match type
	MBMatchType matchType;
	
	// words we are supposed to look for
	NSArray *searchWords;
	NSString *currentSearchWord;	
	
	// the source item to start searching
	MBItem *sourceSearchItem;
	
	// search for the specified items
	NSDictionary *searchForItems;
	NSDictionary *allSearchForItems;
}
  
- (void)setCaseSensitiveSearch:(BOOL)flag;
- (void)setSearchExternalData:(BOOL)flag;
- (void)setRecursiveSearch:(BOOL)flag;
- (void)setSearchInFiledata:(BOOL)flag;

- (void)setSearchMode:(MBSearchModeType)type;
- (MBSearchModeType)searchMode;

- (void)setMatchType:(MBMatchType)type;
- (MBMatchType)matchType;

// the source search item, nil for all
- (void)setSourceSearchItem:(MBItem *)aItem;
- (MBItem *)sourceSearchItem;

// searching for types in the given dict
- (BOOL)doSearchForItemsInDict:(NSDictionary *)dict withID:(int)identifier;

// all search Items
- (NSDictionary *)allSearchForItems;
// set the search for items
- (void)setSearchForItems:(NSDictionary *)searchFor;
- (NSDictionary *)searchForItems;

- (long)searchInCommonItemArray:(NSArray *)list forString:(NSString *)sString result:(NSMutableDictionary **)result;
- (long)searchInCommonItemArray:(NSArray *)list 
					  forString:(NSString *)sString 
					  recursive:(BOOL)r
				 searchExternal:(BOOL)e
				  caseSensitive:(BOOL)c 
				 fileDataSearch:(BOOL)f 
						 result:(NSMutableDictionary **)result;

// this is for database search
- (long)searchDbWithinItem:(MBItem *)aItem 
				 forString:(NSString *)sString 
				   doRegex:(BOOL)regex 
			 caseSensitive:(BOOL)cs 
					result:(NSMutableDictionary **)result
					 error:(NSString **)errorMsg;

@end
