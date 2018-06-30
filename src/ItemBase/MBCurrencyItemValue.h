//
//  MBCurrencyItemValue.h
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
#import "MBNumberItemValue.h"

@interface MBCurrencyItemValue : MBNumberItemValue <NSCopying,NSCoding>
{

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

- (NSString *)valueDataAsString;
- (NSString *)valueDataForComparison;


@end

@interface MBCurrencyItemValue (ElementBase)

// attribute setter
- (void)setCurrencySymbol:(NSString *)aSymbol;
// attribute getter
- (NSString *)currencySymbol;

- (void)writeValueIndexEntryWithCreate:(BOOL)flag;

@end
