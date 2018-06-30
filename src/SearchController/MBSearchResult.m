//
//  MBSearchResult.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 17.05.06.
//  Copyright 2006 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import "MBSearchResult.h"
#import "MBCommonItem.h"

@interface MBSearchResult (privateAPI)

- (void)setMatchResultsDict:(NSMutableDictionary *)dict;
- (NSMutableDictionary *)matchResultsDict;

@end

@implementation MBSearchResult (privateAPI)

- (void)setMatchResultsDict:(NSMutableDictionary *)dict
{
	if(matchResultsDict != dict)
	{
		[dict retain];
		[matchResultsDict release];
		matchResultsDict = dict;
	}
}

- (NSMutableDictionary *)matchResultsDict
{
	return matchResultsDict;
}

@end

@implementation MBSearchResult

+ (id)searchResult
{
	return [[[MBSearchResult alloc] init] autorelease];
}

+ (id)searchResultWithCommonItem:(MBCommonItem *)cItem
{
	return [[[MBSearchResult alloc] initWithCommonItem:cItem] autorelease];
}

- (id)init
{
	return [self initWithCommonItem:nil];
}

- (id)initWithCommonItem:(MBCommonItem *)cItem
{
	self = [super init];
	
	if(self)
	{
		// init dict
		[self setMatchResultsDict:[NSMutableDictionary dictionary]];
		
		[self setCommonItem:cItem];
	}
	
	return self;
}

- (void)dealloc
{
	[self setCommonItem:nil];
	[self setMatchResultsDict:nil];
	
	[super dealloc];
}

// set and get Item
- (void)setCommonItem:(MBCommonItem *)cItem
{
	if(cItem != cItemRef)
	{
		[cItem retain];
		[cItemRef release];
		cItemRef = cItem;
	}
}

- (MBCommonItem *)commonItem
{
	return cItemRef;
}

- (int)commonItemID
{
	int ret = -1;
	
	if(cItemRef != nil)
	{
		ret = [cItemRef itemID];
	}
	
	return ret;
}

	// add and get MatchResults
- (void)addMatchResult:(MatchResult *)mResult forPattern:(NSString *)pattern
{
	// check for matchResults array for pattern
	NSMutableArray *results = [matchResultsDict objectForKey:pattern];
	if(results == nil)
	{
		// there are no results for this pattern yet, create array
		results = [NSMutableArray array];
		[matchResultsDict setObject:results forKey:pattern];
	}

	// add matchresult to array
	[results addObject:mResult];
}

- (NSArray *)matchResultsForPattern:(NSString *)pattern;
{
	return [matchResultsDict objectForKey:pattern];
}

- (int)numberOfMatchesForPattern:(NSString *)pattern
{
	return [[matchResultsDict objectForKey:pattern] count];
}

- (int)numberOfMatchResults
{
	return [[matchResultsDict allValues] count];
}

@end
