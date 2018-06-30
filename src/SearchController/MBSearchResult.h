//
//  MBSearchResult.h
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

#import <Cocoa/Cocoa.h>

@class MatchResult;
@class MBCommonItem;


@interface MBSearchResult : NSObject 
{
	MBCommonItem *cItemRef;
	
	NSMutableDictionary *matchResultsDict;
}

+ (id)searchResult;
+ (id)searchResultWithCommonItem:(MBCommonItem *)cItem;

- (id)initWithCommonItem:(MBCommonItem *)cItem;

// set and get Item
- (void)setCommonItem:(MBCommonItem *)cItem;
- (MBCommonItem *)commonItem;
- (int)commonItemID;

// add and get MatchResults
- (void)addMatchResult:(MatchResult *)mResult forPattern:(NSString *)pattern;
- (NSArray *)matchResultsForPattern:(NSString *)pattern;
- (int)numberOfMatchesForPattern:(NSString *)pattern;
- (int)numberOfMatchResults;

@end
