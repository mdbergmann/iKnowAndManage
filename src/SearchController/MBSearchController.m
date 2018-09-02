//
//  MBSearchController.m
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

#import <CocoPCRE/CocoPCRE.h>
#import <SifSqlite/SifSqlite.h>
#import "MBSearchController.h"
#import "MBItemValue.h"
#import "MBSearchResult.h"
#import "MBNumberItemValue.h"
#import "MBCurrencyItemValue.h"
#import "MBDateItemValue.h"
#import "MBURLItemValue.h"
#import "MBTextItemValue.h"
#import "MBExtendedTextItemValue.h"
#import "MBImageItemValue.h"
#import "MBPDFItemValue.h"
#import "MBItem.h"
#import "MBStdItem.h"
#import "globals.h"
#import "MBDBAccess.h"
#import "MBItemBaseController.h"
#import "MBRefItem.h"
#import "sys/time.h"

@interface MBSearchController (privateAPI)

- (BOOL)searchItemValue:(MBItemValue *)itemval forRegexList:(NSArray *)regexes result:(NSMutableDictionary *)result;
- (BOOL)searchItem:(MBItem *)item forRegexList:(NSArray *)regexes result:(NSMutableDictionary *)result;

- (void)setSearchWords:(NSArray *)list;
- (NSArray *)searchWords;

- (void)setSearchWordsFromSearchString:(NSString *)sString;

@end

@implementation MBSearchController (privateAPI)

- (void)setSearchWordsFromSearchString:(NSString *)sString {
	if(sString != nil) {
		NSArray *array = [sString componentsSeparatedByString:@" "];
		[self setSearchWords:array];
	}
}

/**
these words we are looking for
 */
- (void)setSearchWords:(NSArray *)list {
	if(list != searchWords) {
		[list retain];
		[searchWords release];
		searchWords = list;
	}
}

- (NSArray *)searchWords {
	return searchWords;
}

/**
 \brief search for sString in itemval
 returns true on match
*/
- (BOOL)searchItemValue:(MBItemValue *)itemval forRegexList:(NSArray *)regexes result:(NSMutableDictionary *)result {
	BOOL itemvalIsRef = NO;
	MBRefItem *itemvalRef = nil;
	
	BOOL match = NO;
	int stat = -1;
	
	// if the parebtItem is a reference, the target should not be nil
	if(itemval != nil) {
		// check for reference
		if([itemval identifier] == ItemValueRefID) {
			itemvalIsRef = YES;
			itemvalRef = (MBRefItem *)itemval;
			itemval = (MBItemValue *)[(MBRefItem *)itemval target];
		} else {
			itemvalIsRef = NO;
			itemvalRef = nil;
		}
		
		// if it is a reference, the target should not be nil
		if(itemval != nil) {
			MBSearchResult *searchResult = [result objectForKey:[NSNumber numberWithInt:[itemval itemID]]];
			if(searchResult == nil) {
				// we have no searchResult yet, create one
				searchResult = [MBSearchResult searchResultWithCommonItem:itemval];
				[result setObject:searchResult forKey:[NSNumber numberWithInt:[itemval itemID]]];
			}

			// use this matchResult variable
			MatchResult *mResult = nil;

			// every itemvalue has a name
			NSString *name = [itemval name];
			// do this for all regexes
			NSEnumerator *iter = [regexes objectEnumerator];
			Regex *regex = nil;
			while((regex = [iter nextObject])) {
				// check for name first
				mResult = [MatchResult matchResult];
				stat = [regex matchIn:name matchResult:&mResult];
				if(stat == RegexMatch) {
					[searchResult addMatchResult:mResult forPattern:[regex origPattern]];
					match = YES;
				}
			}				
			
			// first determine the itemvalue type
			if(([itemval valuetype] == NumberItemValueType) && ([self doSearchForItemsInDict:searchForItems withID:NumberItemValueID])) {
				// get data in advance
				MBNumberItemValue *val = (MBNumberItemValue *)itemval;
				NSString *num = [[val valueData] stringValue];
				NSString *currSymbol = nil;
				// search for the currency symbol as well
				if([itemval valuetype] == CurrencyItemValueType) {
					MBCurrencyItemValue *val = (MBCurrencyItemValue *)itemval;
					currSymbol = [val currencySymbol];
				}
					
				// do this for all regexes
				NSEnumerator *iter = [regexes objectEnumerator];
				Regex *regex = nil;
				while((regex = [iter nextObject])) {
					// check for number
					mResult = [MatchResult matchResult];
					stat = [regex matchIn:num matchResult:&mResult];
					if(stat == RegexMatch) {
						[searchResult addMatchResult:mResult forPattern:[regex origPattern]];
						match = YES;
					}
						
					if(currSymbol != nil) {
						mResult = [MatchResult matchResult];
						stat = [regex matchIn:currSymbol matchResult:&mResult];
						if(stat == RegexMatch) {
							[searchResult addMatchResult:mResult forPattern:[regex origPattern]];
							match = YES;
						}								 
					}
				}
			} else if(([itemval valuetype] == BoolItemValueType) && ([self doSearchForItemsInDict:searchForItems withID:BoolItemValueID])) {
				// don't know what to do here
				/*
				 MBBoolItemValue *val = itemval;
				 // check for number value
				 BOOL val = [val valueData];
				 // check for name first
				 stat = [self matchIn:sString against:[num stringValue]];
				 if(stat == RegexMatch)
				 {
					 // found a match				
					 // add itemval to result array
					 [*result addObject:itemval];
				 }
				 */
			} else if(([itemval valuetype] == DateItemValueType) && ([self doSearchForItemsInDict:searchForItems withID:DateItemValueID])) {
				MBDateItemValue *val = (MBDateItemValue *)itemval;
				// get string from formatter
				NSString *dateString = [val valueDataAsString];

				// do this for all regexes
				NSEnumerator *iter = [regexes objectEnumerator];
				Regex *regex = nil;
				while((regex = [iter nextObject])) {
					mResult = [MatchResult matchResult];
					stat = [regex matchIn:dateString matchResult:&mResult];
					if(stat == RegexMatch) {
						[searchResult addMatchResult:mResult forPattern:[regex origPattern]];
						match = YES;
					}
				}
			} else if(([itemval valuetype] == DateItemValueType) && ([self doSearchForItemsInDict:searchForItems withID:AlarmItemID])) {
				MBDateItemValue *val = (MBDateItemValue *)itemval;
				
				// is this an alarm?
				if([val hasAlarm]) {
					// get string from formatter
					NSString *dateString = [val valueDataAsString];

					// do this for all regexes
					NSEnumerator *iter = [regexes objectEnumerator];
					Regex *regex = nil;
					while((regex = [iter nextObject])) {
						mResult = [MatchResult matchResult];
						stat = [regex matchIn:dateString matchResult:&mResult];
						if(stat == RegexMatch) {
							// found a match				
							[searchResult addMatchResult:mResult forPattern:[regex origPattern]];
							match = YES;
						}
					}
				}
			} else if(([itemval valuetype] == SimpleTextItemValueType) && ([self doSearchForItemsInDict:searchForItems withID:TextItemValueID])) {
				MBTextItemValue *val = (MBTextItemValue *)itemval;
				// check for text value
				NSString *string = [val valueData];

				// do this for all regexes
				NSEnumerator *iter = [regexes objectEnumerator];
				Regex *regex = nil;
				while((regex = [iter nextObject])) {
					mResult = [MatchResult matchResult];
					stat = [regex matchIn:string matchResult:&mResult];
					if(stat == RegexMatch) {
						// found a match				
						[searchResult addMatchResult:mResult forPattern:[regex origPattern]];
						match = YES;
					}
				}
			} else if(([itemval valuetype] == URLItemValueType) && ([self doSearchForItemsInDict:searchForItems withID:URLItemValueID])) {
				MBURLItemValue *val = (MBURLItemValue *)itemval;
				// check for url
				NSURL *url = [val valueData];
				NSString *string = [url absoluteString];

				NSString *urlContent = nil;
				if((([url isFileURL] == YES) || (([url isFileURL] == NO) && (searchExternalData == YES))) &&
				   [MBURLItemValue isConnectableURL:url]) {
					// check for url
                    urlContent = [NSString stringWithContentsOfURL:[val valueData] encoding:NSUTF8StringEncoding error:NULL];
				}
				
				// do this for all regexes
				NSEnumerator *iter = [regexes objectEnumerator];
				Regex *regex = nil;
				while((regex = [iter nextObject])) {
					mResult = [MatchResult matchResult];
					stat = [regex matchIn:string matchResult:&mResult];
					if(stat == RegexMatch) {
						// found a match				
						[searchResult addMatchResult:mResult forPattern:[regex origPattern]];
						match = YES;
					}
					
					if(urlContent != nil) {
						mResult = [MatchResult matchResult];
						stat = [regex matchIn:urlContent matchResult:&mResult];
						if(stat == RegexMatch) {
							// found a match				
							[searchResult addMatchResult:mResult forPattern:[regex origPattern]];
							match = YES;
						}
					}
				}
			} else if(([itemval valuetype] == ExtendedTextItemValueType) && ([self doSearchForItemsInDict:searchForItems withID:ExtendedTextItemValueID])) {
				MBExtendedTextItemValue *val = (MBExtendedTextItemValue *)itemval;
				
				// get string value
				NSString *string = nil;
				if([val isLink] == NO) {
					// check for text value
					string = [val valueDataAsString];
				} else {
					NSURL *url = [val linkValueAsURL];
					if(([url isFileURL] == YES) || (([url isFileURL] == NO) && (searchExternalData == YES))) {
						// load text from file or internet only if the user specified so
                        string = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];
					}
				}
				
				// get urlvalue
				NSString *urlString = [val linkValueAsString];
				
				// do this for all regexes
				NSEnumerator *iter = [regexes objectEnumerator];
				Regex *regex = nil;
				while((regex = [iter nextObject])) {
					// search
					if(string != nil) {
						mResult = [MatchResult matchResult];
						stat = [regex matchIn:string matchResult:&mResult];
						if(stat == RegexMatch) {
							// found a match				
							[searchResult addMatchResult:mResult forPattern:[regex origPattern]];
							match = YES;
						}
					}
					
					// check url
					mResult = [MatchResult matchResult];
					stat = [regex matchIn:urlString matchResult:&mResult];
					if(stat == RegexMatch) {
						// found a match				
						[searchResult addMatchResult:mResult forPattern:[regex origPattern]];
						match = YES;
					}					
				}					
			} else if(([itemval valuetype] == ImageItemValueType) && ([self doSearchForItemsInDict:searchForItems withID:ImageItemValueID])) {
				MBImageItemValue *val = (MBImageItemValue *)itemval;
				NSString *string = nil;
				/* do not search in image binary value
				if([val isLink] == NO)
				{
					// check for text value
					string = [[[NSString alloc] initWithData:[val valueData] encoding:NSASCIIStringEncoding] autorelease];
				}
				else
				{
					NSURL *url = [val linkValueAsURL];
					if(([url isFileURL] == YES) || (([url isFileURL] == NO) && (searchExternalData == YES)))
					{
						// load text from file or internet only if the user specified so
						string = [NSString stringWithContentsOfURL:url];
					}
				}
				*/
					
				// get urlvalue
				NSString *urlString = [val linkValueAsString];

				// do this for all regexes
				NSEnumerator *iter = [regexes objectEnumerator];
				Regex *regex = nil;
				while((regex = [iter nextObject])) {
					// search
					if(string != nil) {
						mResult = [MatchResult matchResult];
						stat = [regex matchIn:string matchResult:&mResult];
						if(stat == RegexMatch) {
							// found a match				
							[searchResult addMatchResult:mResult forPattern:[regex origPattern]];
							match = YES;
						}
					}
					
					// check url
					mResult = [MatchResult matchResult];
					stat = [regex matchIn:urlString matchResult:&mResult];
					if(stat == RegexMatch) {
						// found a match				
						[searchResult addMatchResult:mResult forPattern:[regex origPattern]];
						match = YES;
					}
				}
			} else if(([itemval valuetype] == FileItemValueType) && ([self doSearchForItemsInDict:searchForItems withID:FileItemValueID])) {
				MBFileItemValue *val = (MBFileItemValue *)itemval;
				NSString *string = nil;
				// do we search in filedata?
				if(searchInFiledata) {
					if([val isLink] == NO) {
						// check for text value
						string = [[[NSString alloc] initWithData:[val valueData] encoding:NSASCIIStringEncoding] autorelease];
					} else {
						NSURL *url = [val linkValueAsURL];
						if(([url isFileURL] == YES) || (([url isFileURL] == NO) && (searchExternalData == YES))) {
							// load text from file or internet only if the user specified so
							string = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];
						}
					}
				}
					
				// get urlvalue
				NSString *urlString = [val linkValueAsString];

				// do this for all regexes
				NSEnumerator *iter = [regexes objectEnumerator];
				Regex *regex = nil;
				while((regex = [iter nextObject])) {
					// search
					if(string != nil) {
						mResult = [MatchResult matchResult];
						stat = [regex matchIn:string matchResult:&mResult];
						if(stat == RegexMatch) {
							// found a match				
							[searchResult addMatchResult:mResult forPattern:[regex origPattern]];
							match = YES;
						}
					}
					
					// check url
					mResult = [MatchResult matchResult];
					stat = [regex matchIn:urlString matchResult:&mResult];
					if(stat == RegexMatch) {
						// found a match				
						[searchResult addMatchResult:mResult forPattern:[regex origPattern]];
						match = YES;
					}
				}
			} else if(([itemval valuetype] == PDFItemValueType) && ([self doSearchForItemsInDict:searchForItems withID:PDFItemValueID])) {
				MBPDFItemValue *val = (MBPDFItemValue *)itemval;
				NSString *string = nil;
				// do we search in filedata?
				if(searchInFiledata) {
					if([val isLink] == NO) {
						// check for text value
						string = [[[NSString alloc] initWithData:[val valueData] encoding:NSASCIIStringEncoding] autorelease];
					} else {
						NSURL *url = [val linkValueAsURL];
						if(([url isFileURL] == YES) || (([url isFileURL] == NO) && (searchExternalData == YES))) {
							// load text from file or internet only if the user specified so
							string = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];
						}
					}
				}
                
				// get urlvalue
				NSString *urlString = [val linkValueAsString];
                
				// do this for all regexes
				NSEnumerator *iter = [regexes objectEnumerator];
				Regex *regex = nil;
				while((regex = [iter nextObject])) {
					// search
					if(string != nil) {
						mResult = [MatchResult matchResult];
						stat = [regex matchIn:string matchResult:&mResult];
						if(stat == RegexMatch) {
							// found a match				
							[searchResult addMatchResult:mResult forPattern:[regex origPattern]];
							match = YES;
						}
					}
					
					// check url
					mResult = [MatchResult matchResult];
					stat = [regex matchIn:urlString matchResult:&mResult];
					if(stat == RegexMatch) {
						// found a match				
						[searchResult addMatchResult:mResult forPattern:[regex origPattern]];
						match = YES;
					}
				}
			}
        }
    } else {
		CocoLog(LEVEL_WARN,@"itemvalue is nil!");
	}
	
	return match;
}

/**
 \brief search in the given item
 options are taken from this searcher instance
*/
- (BOOL)searchItem:(MBItem *)item forRegexList:(NSArray *)regexes result:(NSMutableDictionary *)result {
	BOOL ret = NO;
	
	BOOL itemIsRef = NO;
	MBRefItem *itemRef = nil;
	
	int stat = -1;
	
	// check that item is not nil
	if(item != nil) {
		// check for reference
		if([item identifier] == ItemRefID)
		{
			itemIsRef = YES;
			itemRef = (MBRefItem *)item;
			item = (MBItem *)[(MBRefItem *)item target];
		}		
		
		// if the item is a reference, the target should not be nil
		if(item != nil) {
			// are we searching for items?
			if(([self doSearchForItemsInDict:searchForItems withID:StdItemID]) && (NSLocationInRange([item identifier],ITEM_ID_RANGE))) {
				MBSearchResult *searchResult = [result objectForKey:[NSNumber numberWithInt:[item itemID]]];
				if(searchResult == nil) {
					// we no searchResult yet, create one
					searchResult = [MBSearchResult searchResultWithCommonItem:item];
					[result setObject:searchResult forKey:[NSNumber numberWithInt:[item itemID]]];
				}
				
				MatchResult *mResult = nil;
				
				// every item has a name
				NSString *name = [item name];
				// do this for all regexes
				NSEnumerator *iter = [regexes objectEnumerator];
				Regex *regex = nil;
				while((regex = [iter nextObject])) {
					// check for name first
					mResult = [MatchResult matchResult];
					stat = [regex matchIn:name matchResult:&mResult];
					if(stat == RegexMatch) {
						[searchResult addMatchResult:mResult forPattern:[regex origPattern]];
						//match = YES;
					}
					
					// check for name first
					mResult = [MatchResult matchResult];
					stat = [regex matchIn:[(MBStdItem *)item comment] matchResult:&mResult];
					if(stat == RegexMatch) {
						// found a match	
						[searchResult addMatchResult:mResult forPattern:currentSearchWord];
					}					
				}								
			}
		
			// search in all items
			NSEnumerator *iter = [[item itemValues] objectEnumerator];
			MBItemValue *itemval = nil;
			while((itemval = [iter nextObject])) {
				[self searchItemValue:itemval forRegexList:regexes result:result];
			}
			
			// now search the children and go deeper
			iter = [[item children] objectEnumerator];
			MBItem *buf = nil;
			while((buf = [iter nextObject])) {
				// do we search recursive?
				if(recursiveSearch == YES) {
					// go deeper
					[self searchItem:buf forRegexList:regexes result:result];
				}
			}
		}
		
		// do we have results
		if([result count] > 0) {
			ret = YES;
		}
	} else {
		CocoLog(LEVEL_WARN,@"item is nil!");
	}
	
	return ret;
}

@end

@implementation MBSearchController

- (id)init {
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"cannot alloc MBSearchController!");		
	} else {
		// init perl searcher
		[self setSearchForItems:[self allSearchForItems]];
		[self setSourceSearchItem:nil];
		
		// init search for items
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];		
		// item stuff
		//[dict setObject:STD_ITEMTYPE_NAME forKey:[NSNumber numberWithInt:StdItemID]];
		// add stuff for itemvalues
		[dict setObject:SIMPLETEXT_ITEMVALUE_TYPE_NAME forKey:[NSNumber numberWithInt:TextItemValueID]];
		[dict setObject:EXTENDEDTEXT_ITEMVALUE_TYPE_NAME forKey:[NSNumber numberWithInt:ExtendedTextItemValueID]];
		[dict setObject:NUMBER_ITEMVALUE_TYPE_NAME forKey:[NSNumber numberWithInt:NumberItemValueID]];
		[dict setObject:CURRENCY_ITEMVALUE_TYPE_NAME forKey:[NSNumber numberWithInt:CurrencyItemValueID]];
		[dict setObject:BOOL_ITEMVALUE_TYPE_NAME forKey:[NSNumber numberWithInt:BoolItemValueID]];
		[dict setObject:URL_ITEMVALUE_TYPE_NAME forKey:[NSNumber numberWithInt:URLItemValueID]];
		[dict setObject:DATE_ITEMVALUE_TYPE_NAME forKey:[NSNumber numberWithInt:DateItemValueID]];
		[dict setObject:ALARM_ITEM_TYPE_NAME forKey:[NSNumber numberWithInt:AlarmItemID]];
		[dict setObject:IMAGE_ITEMVALUE_TYPE_NAME forKey:[NSNumber numberWithInt:ImageItemValueID]];
		[dict setObject:FILE_ITEMVALUE_TYPE_NAME forKey:[NSNumber numberWithInt:FileItemValueID]];
		[dict setObject:PDF_ITEMVALUE_TYPE_NAME forKey:[NSNumber numberWithInt:PDFItemValueID]];
		// set as default
		allSearchForItems = [[NSDictionary dictionaryWithDictionary:dict] retain];
		
		// set default search mode
		[self setSearchMode:MBSearchModeRegEx];
		// set match type
		[self setMatchType:MBMatchAny];
		// init search words
		[self setSearchWords:[NSArray array]];
	}
	
	return self;
}

- (void)awakeFromNib
{
	if(self != nil)
	{
		
	}
}

/**
\brief dealloc of this class is called on closing this document
 */
- (void)dealloc
{
	[self setSearchForItems:nil];
	[allSearchForItems release];
	
	[self setSearchWords:nil];
	
	// dealloc object
	[super dealloc];
}
 
- (void)setCaseSensitiveSearch:(BOOL)flag
{
	caseSensitiveSearch = flag;
}

- (void)setSearchInFiledata:(BOOL)flag
{
	searchInFiledata = flag;
}

- (void)setSearchExternalData:(BOOL)flag
{
	searchExternalData = flag;
}

- (void)setRecursiveSearch:(BOOL)flag
{
	recursiveSearch = flag;
}

/**
 \brief we only do weak linking here
*/
- (void)setSourceSearchItem:(MBItem *)aItem
{
	sourceSearchItem = aItem;
}

- (MBItem *)sourceSearchItem
{
	return sourceSearchItem;
}

- (void)setSearchMode:(MBSearchModeType)type
{
	searchMode = type;
}

- (MBSearchModeType)searchMode
{
	return searchMode;
}

- (void)setMatchType:(MBMatchType)type
{
	matchType = type;
}

- (MBMatchType)matchType
{
	return matchType;
}

/**
 \brief here a dictionary with all identifiers which are to be searched can be set
*/
- (void)setSearchForItems:(NSDictionary *)searchFor
{
	if(searchFor != searchForItems)
	{
		[searchFor retain];
		[searchForItems release];
		searchForItems = searchFor;
	}
}

- (NSDictionary *)searchForItems
{
	return searchForItems;
}

/**
 \brief return whether the given identifier is in the given dict
*/
- (BOOL)doSearchForItemsInDict:(NSDictionary *)dict withID:(int)identifier
{
	// lets see, if this identifier is the searchFor dictionary as key
	if([dict objectForKey:[NSNumber numberWithInt:identifier]])
	{
		return YES;
	}
	else
	{
		return NO;
	}
}

/**
 \brief all search for items available
*/
- (NSDictionary *)allSearchForItems
{
	return allSearchForItems;
}

/**
 \brief this is just a wrapper for the same method with more attributes
 we take the one from the instance
*/
- (long)searchInCommonItemArray:(NSArray *)list forString:(NSString *)sString result:(NSMutableDictionary *)result
{
	struct timeval starttime;
	struct timeval stoptime;
	struct timeval difftime;
		
	// start timetake
	gettimeofday(&starttime,nil);
	
	// set SearchWords
	[self setSearchWordsFromSearchString:sString];
	
	// init array for regexes
	NSMutableArray *regexList = [NSMutableArray array];
	
	int words = [searchWords count];
	for(int i = 0;i < words;i++)
	{
		NSString *sWord = [searchWords objectAtIndex:i];
		
		if([sWord length] > 0)
		{
			// expand search pattern to get captured substrings
			NSString *pattern = [NSString stringWithFormat:@"%@%@%@",@"(.{0,50})(",sWord,@")(.{0,50})"];
			
			// create regex
			Regex *regex = [Regex regexWithPattern:pattern];
			[regex setOrigPattern:sWord];
			// add regex
			[regexList addObject:regex];
			
			// set case sentitive
			[regex setCaseSensitive:caseSensitiveSearch];
			// study the pattern
			[regex studyPattern];			
		}
	}
	
	if([regexList count] > 0)
	{
		// go through the list and process each item
		NSEnumerator *iter = [list objectEnumerator];
		MBCommonItem *cItem = nil;
		while((cItem = [iter nextObject]))
		{
			if(NSLocationInRange([cItem identifier],ITEMVALUE_ID_RANGE))
			{
				[self searchItemValue:(MBItemValue *)cItem forRegexList:regexList result:result];
			}
			else
			{
				[self searchItem:(MBItem *)cItem forRegexList:regexList result:result];
			}
		}
	}
	
	// check AND here
	// delete all entries with 0 matches
	NSEnumerator *iter = [[result allKeys] objectEnumerator];
	NSNumber *key = nil;
	while((key = [iter nextObject]))
	{
		MBSearchResult *sr = [result objectForKey:key];
		if([sr numberOfMatchResults] == 0)
		{
			[result removeObjectForKey:key];
		}
	}
	
	gettimeofday(&stoptime,nil);
	
	// convert to ms instead of us
	starttime.tv_usec = starttime.tv_usec;
	stoptime.tv_usec = stoptime.tv_usec;
	// calculate timeinterval of execution
	if(stoptime.tv_usec < starttime.tv_usec)
	{
		stoptime.tv_usec = stoptime.tv_usec + 1000000;	// add 1 sec
		stoptime.tv_sec = stoptime.tv_sec - 1;		// sub 1 sec
	}
	difftime.tv_sec = stoptime.tv_sec - starttime.tv_sec;
	difftime.tv_usec = stoptime.tv_usec - starttime.tv_usec;
	
	unsigned int millis = (difftime.tv_usec / 1000) + (difftime.tv_sec * 1000);
	
	return millis;	
}

/**
 \brief this is just a wrapper for -searchInCommonItemArray:forString:result:
 the attributes are copied to the instance
*/
- (long)searchInCommonItemArray:(NSArray *)list 
							  forString:(NSString *)sString 
							  recursive:(BOOL)r
						 searchExternal:(BOOL)e 
						  caseSensitive:(BOOL)c 
						 fileDataSearch:(BOOL)f 
								 result:(NSMutableDictionary *)result;
{
	// set settings
	[self setCaseSensitiveSearch:c];
	[self setSearchInFiledata:f];
	[self setSearchExternalData:e];
	[self setRecursiveSearch:r];
	
	return [self searchInCommonItemArray:list forString:sString result:result];
}

/**
 \brief this method will search in the valueindex table for the given pattern
*/
- (long)searchDbWithinItem:(MBItem *)aItem 
						 forString:(NSString *)sString 
						   doRegex:(BOOL)regex 
					 caseSensitive:(BOOL)cs 
							result:(NSMutableDictionary *)result
							 error:(NSString **)errorMsg
{
	struct timeval starttime;
	struct timeval stoptime;
	struct timeval difftime;
	
	// start timetake
	gettimeofday(&starttime,nil);
	
	// get dbCon
	MBDBAccess *dbCon = [MBDBAccess sharedConnection];
	
	// get ItemBaseController
	MBItemBaseController *itc = itemController;

	// extract search words if more
	[self setSearchWordsFromSearchString:sString];
	int words = [searchWords count];
	for(int i = 0;i < words;i++)
	{
		NSString *sWord = [searchWords objectAtIndex:i];
		
		if([sWord length] > 0)
		{
			// do we make a regex search?
			if(!regex)
			{
				// if we have a ".", search for all
				if([sWord isEqualToString:@"."])
				{
					sWord = @"";
				}
				// for every search word do search in db
				NSArray *dbResult = [dbCon listIndexEntriesForPattern:sWord andTreeinfo:[aItem treeinfo]];
				
				// process array and generate SearchResults for every CommonItem
				NSEnumerator *iter = [dbResult objectEnumerator];
				ResultRow *row = nil;
				while((row = [iter nextObject]))
				{
					// get match content
					NSString *content = [[row findColumnForName:@"elemvalcontent"] value];
					
					// only add if we have content
					if([content length] > 0)
					{
						int elementid = [[[row findColumnForName:@"elementid"] value] intValue];

						// get common item for id
						// make sure, we search for this item identifier
						MBCommonItem *ci = [itc commonItemForId:elementid];
						int identifier = [ci identifier];
						
						// check for Alarms as special case
						if(identifier == DateItemValueID)
						{
							MBDateItemValue *date = (MBDateItemValue *)ci;
							if([date hasAlarm])
							{
								identifier = AlarmItemID;
							}
						}					
						if([self doSearchForItemsInDict:[self searchForItems] withID:identifier])
						{
							// get ItemValue
							NSNumber *elemID = [NSNumber numberWithInt:elementid];
							MBSearchResult *sr = [result objectForKey:elemID];
							if(sr == nil)
							{
								sr = [MBSearchResult searchResultWithCommonItem:ci];
								// add to result
								[result setObject:sr forKey:elemID];
							}
							
							// add match
							MatchResult *mr = [MatchResult matchResult];
							[mr addMatch:content];
							[sr addMatchResult:mr forPattern:sWord];
						}						
					}
				}
			}
			else
			{
				// get data from db, get all data, we search here with regex
				NSArray *dbResult = [dbCon listIndexEntriesForPattern:@"" andTreeinfo:[aItem treeinfo]];
				
				// process array and generate SearchResults for every CommonItem
				NSEnumerator *iter = [dbResult objectEnumerator];
				ResultRow *row = nil;
				while((row = [iter nextObject]))
				{
					// get match content
					NSString *content = [[row findColumnForName:@"elemvalcontent"] value];
					
					// only search for, if we have an content
					if([content length] > 0)
					{
						// get elementid
						NSNumber *elemID = [NSNumber numberWithInt:[[[row findColumnForName:@"elementid"] value] intValue]];
						
						// get common item for id
						// make sure, we search for this item identifier
						MBCommonItem *ci = [itc commonItemForId:[elemID intValue]];
						int identifier = [ci identifier];
						
						// check for Alarms as special case
						if(identifier == DateItemValueID)
						{
							MBDateItemValue *date = (MBDateItemValue *)ci;
							if([date hasAlarm])
							{
								identifier = AlarmItemID;
							}
						}
						if([self doSearchForItemsInDict:[self searchForItems] withID:identifier])
						{
							BOOL add = false;
							
							// we do regex search
							// create regex from search string
							Regex *regExpression = [Regex regexWithPattern:sWord];
							// check error
							if([regExpression errorCodeOfLastAction] != RegexSuccess)
							{
								// set error string and return
								*errorMsg = [NSString stringWithString:[regExpression errorMessageOfLastAction]];
								return -1;
							}

							// set case sensitive on or off
							// for case sentitivity the pattern has to be compiled and this can go wrong
							[regExpression setCaseSensitive:cs];
							// check error
							if([regExpression errorCodeOfLastAction] != RegexSuccess)
							{
								// set error string and return
								*errorMsg = [NSString stringWithString:[regExpression errorMessageOfLastAction]];
								return -1;
							}

							// these methods do not set errors
							[regExpression setCaptureSubstrings:NO];
							[regExpression setFindAll:NO];
													
							// does it match?
							MatchResult *mResult = [MatchResult matchResult];
							if([regExpression matchIn:content matchResult:&mResult] == RegexMatch)
							{
								add = YES;
							}				
							
							// add?
							if(add)
							{
								// get ItemValue
								MBSearchResult *sr = [result objectForKey:elemID];
								if(sr == nil)
								{
									sr = [MBSearchResult searchResultWithCommonItem:ci];
									// add to result
									[result setObject:sr forKey:elemID];
								}
								
								// add match
								[sr addMatchResult:mResult forPattern:sWord];							
							}
						}
					}
				}
			}
		}
	}
	
	// if we do AND search, remove all entries that do not have matches for all subjects
	if((matchType == MBMatchAll) && (words > 1))
	{
		NSEnumerator *iter = [[result allKeys] objectEnumerator];
		NSNumber *key = nil;
		while((key = [iter nextObject]))
		{
			// get SearchResult for key
			MBSearchResult *sr = [result objectForKey:key];
			
			BOOL remove = NO;
			
			// check search result for matches in all subjects
			// every search word has to have a match
			for(int i = 0;i < words;i++)
			{
				NSString *sWord = [searchWords objectAtIndex:i];
				if([sr numberOfMatchesForPattern:sWord] < 1)
				{
					// no match, remove this SearchResult
					remove = YES;
					break;
				}
			}
			
			if(remove)
			{
				[result removeObjectForKey:key];
			}
		}
	}
	
	gettimeofday(&stoptime,nil);
	
	// convert to ms instead of us
	starttime.tv_usec = starttime.tv_usec;
	stoptime.tv_usec = stoptime.tv_usec;
	// calculate timeinterval of execution
	if(stoptime.tv_usec < starttime.tv_usec)
	{
		stoptime.tv_usec = stoptime.tv_usec + 1000000;	// add 1 sec
		stoptime.tv_sec = stoptime.tv_sec - 1;		// sub 1 sec
	}
	difftime.tv_sec = stoptime.tv_sec - starttime.tv_sec;
	difftime.tv_usec = stoptime.tv_usec - starttime.tv_usec;
	
	unsigned int millis = (difftime.tv_usec / 1000) + (difftime.tv_sec * 1000);
	
	return millis;		
}

@end
