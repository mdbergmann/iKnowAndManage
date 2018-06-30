//
//  MBAppInfoItem.h
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 29.08.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>
#import "MBSystemItem.h"

@interface MBAppInfoItem : MBSystemItem {

}

- (id)init;
- (id)initWithDb;
- (id)initWithInitializedElement:(MBElement *)aElem;

- (BOOL)hasRegistrationInformation;
- (void)deleteRegistrationInfo;

@end

@interface MBAppInfoItem (ElementBase)

// attribute setter
- (void)setAppVersion:(NSString *)aVersion;
- (void)setDbVersion:(NSString *)aVersion;
// not used anymore with version 1.0.3
// - (void)setAppMode:(MBAppMode)aMode;
// - (void)setSerNum:(NSString *)aNum;
// - (void)setRegName:(NSString *)aName;
- (void)setDateFirstStart:(NSDate *)aDate;
- (void)setDateLastStart:(NSDate *)aDate;
- (void)setDateLastStop:(NSDate *)aDate;
- (void)setIndexInitiated:(BOOL)flag;
// attribute getter
- (NSString *)appVersion;
- (NSString *)dbVersion;
- (NSData *)appMode;
- (NSString *)serNum;
- (NSString *)regName;
- (NSDate *)datefirstStart;
- (NSDate *)dateLastStart;
- (NSDate *)dateLastStop;
- (BOOL)indexInitiated;

@end