//
//  MBDateItemValue.h
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 25.08.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>
#import "MBItemValue.h"

// repeat enum
typedef enum AlarmRepeatType
{
	AlarmRepeatNone = 0,
	AlarmRepeatDaily,
	AlarmRepeatWeekly,
	AlarmRepeatMonthly,
	AlarmRepeatYearly
}MBAlarmRepeatType;

// alarm set enum
typedef enum AlarmOffsetType
{
	AlarmOffsetYear = 0,
	AlarmOffsetMonth,
	AlarmOffsetDay,
	AlarmOffsetHour,
	AlarmOffsetMinute
}MBAlarmOffsetType;

// alarm ref enum
typedef enum AlarmRefType
{
	AlarmRefFromDate = 0,
	AlarmRefToDate
}MBAlarmRefType;

@interface MBDateItemValue : MBItemValue <NSCopying,NSCoding>
{

}

// NSCopying protocoll
- (id)copyWithZone:(NSZone *)zone;

// NSCoding stuff
- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;

- (id)init;
- (id)initWithDb;
- (id)initWithInitializedElement:(MBElement *)aElem;

// encryption stuff
- (MBCryptoErrorCode)encryptWithString:(NSString *)aString;
- (MBCryptoErrorCode)decryptWithString:(NSString *)aString;

// needed for sorting
- (NSString *)valueDataAsString;
- (NSString *)valueDataForComparison;

// other set methods
//- (void)setValueData:(NSDate *)aDate;
//- (NSDate *)valueData;

- (NSDate *)calculateAlarmDate;

// Date calculations
+ (int)daysOfMonth:(int)month ofYear:(int)year;
+ (NSArray *)daysForMonth;

@end

@interface MBDateItemValue (ElementBase)

// attribute setter
- (void)setFromDate:(NSDate *)aDate;
- (void)setFromDateAsData:(NSData *)aDateData;
- (void)setToDate:(NSDate *)aDate;
- (void)setToDateAsData:(NSData *)aDateData;
- (void)setFormatterString:(NSString *)aFormat;
- (void)setAllowNaturalLanguage:(BOOL)aSetting;
- (void)setUseGlobalFormat:(BOOL)aSetting;
- (void)setIsDateRange:(BOOL)aFlag;
- (void)setHasAlarm:(BOOL)aFlag;
- (void)setAlarmRefType:(MBAlarmRefType)aRefType;
- (void)setAlarmOffsetType:(MBAlarmOffsetType)aOffsetType;
- (void)setAlarmOffsetValue:(int)aValue;
- (void)setAlarmRepeatType:(MBAlarmRepeatType)aType;
- (void)setAlarmDate:(NSDate *)aDate;
- (void)setAlarmProcessed:(BOOL)aFlag;
// attribute getter
- (NSDate *)fromDate;
- (NSData *)fromDateAsData;
- (NSDate *)toDate;
- (NSData *)toDateAsData;
- (NSString *)formatterString;
- (BOOL)allowNaturalLanguage;
- (BOOL)useGlobalFormat;
- (BOOL)isDateRange;
- (BOOL)hasAlarm;
- (MBAlarmRefType)alarmRefType;
- (MBAlarmOffsetType)alarmOffsetType;
- (int)alarmOffsetValue;
- (MBAlarmRepeatType)alarmRepeatType;
- (NSDate *)alarmDate;
- (BOOL)alarmProcessed;

- (void)writeValueIndexEntryWithCreate:(BOOL)flag;

@end