#import <CoreGraphics/CoreGraphics.h>//
//  MBDateItemValue.m
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

#import "MBDateItemValue.h"
#import "MBElementValue.h"
#import "MBElement.h"
#import "MBFormatPrefsViewController.h"
#import "globals.h"
#import "MBValueIndexController.h"

#define ITEMVALUE_DATE_DATE_IDENTIFIER						@"itemvaluedatedate"
#define ITEMVALUE_DATE_TODATE_IDENTIFIER					@"itemvaluedatetodate"
#define ITEMVALUE_DATE_ISRANGE_IDENTIFIER					@"itemvaluedateisrange"
#define ITEMVALUE_DATE_ALLOW_NATURAL_LANGUAGE_IDENTIFIER	@"itemvaluedateallownaturallanguage"
#define ITEMVALUE_DATE_USE_GLOBAL_FORMAT_IDENTIFIER			@"itemvaluedateuseglobalformat"
#define ITEMVALUE_DATE_FORMATTERSTRING_IDENTIFIER			@"itemvaluedateformatterstring"
#define ITEMVALUE_DATE_ALARM_ACTIVE_IDENTIFIER				@"itemvaluedatealarmactive"
#define ITEMVALUE_DATE_ALARM_OFFSET_TYPE_IDENTIFIER			@"itemvaluedatealarmoffsettype"
#define ITEMVALUE_DATE_ALARM_OFFSET_VALUE_IDENTIFIER		@"itemvaluedatealarmoffsetvalue"
#define ITEMVALUE_DATE_ALARM_REPEAT_TYPE_IDENTIFIER			@"itemvaluedatealarmrepeattype"
#define ITEMVALUE_DATE_ALARM_REF_DATE_TYPE_IDENTIFIER		@"itemvaluedatealarmrefdatetype"
#define ITEMVALUE_DATE_ALARM_DATE_IDENTIFIER				@"itemvaluedatealarmdate"
#define ITEMVALUE_DATE_ALARM_PROCESSED_IDENTIFIER			@"itemvaluedatealarmprocessed"

@interface MBDateItemValue (privateAPI)

- (void)createDateFromValueAttributeWithValue:(NSDate *)date;
- (void)createDateToValueAttributeWithValue:(NSDate *)date;
- (void)createDateIsRangeAttributeWithValue:(BOOL)flag;
- (void)createDateAllowNatLanguageAttributeWithValue:(BOOL)flag;
- (void)createDateUseGlobalFormatAttributeWithValue:(BOOL)flag;
- (void)createDateFormatterStringAttributeWithValue:(NSString *)string;
- (void)createDateAlarmActiveAttributeWithValue:(BOOL)flag;
- (void)createDateAlarmOffsetTypeAttributeWithValue:(MBAlarmOffsetType)offsetType;
- (void)createDateAlarmOffsetValueAttributeWithValue:(int)offsetValue;
- (void)createDateAlarmRepeatTypeAttributeWithValue:(MBAlarmRepeatType)repeatType;
- (void)createDateAlarmRefDateTypeAttributeWithValue:(MBAlarmRefType)refType;
- (void)createDateAlarmDateAttributeWithValue:(NSDate *)alarmDate;
- (void)createDateAlarmProcessedAttributeWithValue:(BOOL)flag;

@end

@implementation MBDateItemValue (privateAPI)

- (void)createDateFromValueAttributeWithValue:(NSDate *)date
{
	NSString *key = ITEMVALUE_DATE_DATE_IDENTIFIER;
	MBElementValue *elemval = [[[MBElementValue alloc] initWithIdentifier:key andType:NumberValueType] autorelease];
	[elemval setValueDataAsNumber:[NSNumber numberWithDouble:[date timeIntervalSince1970]]];
	[element addElementValue:elemval];
	[attributeDict setObject:elemval forKey:key];
	
	// connect the value to if the element is connected
	[elemval setIsDbConnected:[element isDbConnected] writeIndex:YES];
}

- (void)createDateToValueAttributeWithValue:(NSDate *)date
{
	NSString *key = ITEMVALUE_DATE_TODATE_IDENTIFIER;
	MBElementValue *elemval = [[[MBElementValue alloc] initWithIdentifier:key andType:NumberValueType] autorelease];
	[elemval setValueDataAsNumber:[NSNumber numberWithDouble:[date timeIntervalSince1970]]];
	[element addElementValue:elemval];
	[attributeDict setObject:elemval forKey:key];
	
	// connect the value to if the element is connected
	[elemval setIsDbConnected:[element isDbConnected] writeIndex:NO];
}

- (void)createDateIsRangeAttributeWithValue:(BOOL)flag
{
	NSString *key = ITEMVALUE_DATE_ISRANGE_IDENTIFIER;
	MBElementValue *elemval = [[[MBElementValue alloc] initWithIdentifier:key andType:NumberValueType] autorelease];
	[elemval setValueDataAsNumber:[NSNumber numberWithBool:flag]];
	[element addElementValue:elemval];
	[attributeDict setObject:elemval forKey:key];	
	
	// connect the value to if the element is connected
	[elemval setIsDbConnected:[element isDbConnected] writeIndex:NO];	
}

- (void)createDateAllowNatLanguageAttributeWithValue:(BOOL)flag
{
	NSString *key = ITEMVALUE_DATE_ALLOW_NATURAL_LANGUAGE_IDENTIFIER;
	MBElementValue *elemval = [[[MBElementValue alloc] initWithIdentifier:key andType:NumberValueType] autorelease];
	[elemval setValueDataAsNumber:[NSNumber numberWithBool:flag]];
	[element addElementValue:elemval];
	[attributeDict setObject:elemval forKey:key];
	
	// connect the value to if the element is connected
	[elemval setIsDbConnected:[element isDbConnected] writeIndex:NO];
}

- (void)createDateUseGlobalFormatAttributeWithValue:(BOOL)flag
{
	NSString *key = ITEMVALUE_DATE_USE_GLOBAL_FORMAT_IDENTIFIER;
	MBElementValue *elemval = [[[MBElementValue alloc] initWithIdentifier:key andType:NumberValueType] autorelease];
	[elemval setValueDataAsNumber:[NSNumber numberWithBool:flag]];
	[element addElementValue:elemval];
	[attributeDict setObject:elemval forKey:key];	
	
	// connect the value to if the element is connected
	[elemval setIsDbConnected:[element isDbConnected] writeIndex:NO];
}

- (void)createDateFormatterStringAttributeWithValue:(NSString *)string
{
	NSString *key = ITEMVALUE_DATE_FORMATTERSTRING_IDENTIFIER;
	MBElementValue *elemval = [[[MBElementValue alloc] initWithIdentifier:key andType:StringValueType] autorelease];
	[elemval setValueDataAsString:string];
	[element addElementValue:elemval];
	[attributeDict setObject:elemval forKey:key];
	
	// connect the value to if the element is connected
	[elemval setIsDbConnected:[element isDbConnected] writeIndex:NO];
}

- (void)createDateAlarmActiveAttributeWithValue:(BOOL)flag
{
	NSString *key = ITEMVALUE_DATE_ALARM_ACTIVE_IDENTIFIER;
	MBElementValue *elemval = [[[MBElementValue alloc] initWithIdentifier:key andType:NumberValueType] autorelease];
	[elemval setValueDataAsNumber:[NSNumber numberWithBool:flag]];
	[element addElementValue:elemval];
	[attributeDict setObject:elemval forKey:key];
	
	// connect the value to if the element is connected
	[elemval setIsDbConnected:[element isDbConnected] writeIndex:NO];	
}

- (void)createDateAlarmOffsetTypeAttributeWithValue:(MBAlarmOffsetType)offsetType
{
	NSString *key = ITEMVALUE_DATE_ALARM_OFFSET_TYPE_IDENTIFIER;
	MBElementValue *elemval = [[[MBElementValue alloc] initWithIdentifier:key andType:NumberValueType] autorelease];
	[elemval setValueDataAsNumber:[NSNumber numberWithInt:offsetType]];
	[element addElementValue:elemval];
	[attributeDict setObject:elemval forKey:key];
	
	// connect the value to if the element is connected
	[elemval setIsDbConnected:[element isDbConnected] writeIndex:NO];	
}

- (void)createDateAlarmOffsetValueAttributeWithValue:(int)offsetValue
{
	NSString *key = ITEMVALUE_DATE_ALARM_OFFSET_VALUE_IDENTIFIER;
	MBElementValue *elemval = [[[MBElementValue alloc] initWithIdentifier:key andType:NumberValueType] autorelease];
	[elemval setValueDataAsNumber:[NSNumber numberWithInt:offsetValue]];
	[element addElementValue:elemval];
	[attributeDict setObject:elemval forKey:key];
	
	// connect the value to if the element is connected
	[elemval setIsDbConnected:[element isDbConnected] writeIndex:NO];
}

- (void)createDateAlarmRepeatTypeAttributeWithValue:(MBAlarmRepeatType)repeatType
{
	NSString *key = ITEMVALUE_DATE_ALARM_REPEAT_TYPE_IDENTIFIER;
	MBElementValue *elemval = [[[MBElementValue alloc] initWithIdentifier:key andType:NumberValueType] autorelease];
	[elemval setValueDataAsNumber:[NSNumber numberWithInt:repeatType]];
	[element addElementValue:elemval];
	[attributeDict setObject:elemval forKey:key];
	
	// connect the value to if the element is connected
	[elemval setIsDbConnected:[element isDbConnected] writeIndex:NO];
}

- (void)createDateAlarmRefDateTypeAttributeWithValue:(MBAlarmRefType)refType
{
	NSString *key = ITEMVALUE_DATE_ALARM_REF_DATE_TYPE_IDENTIFIER;
	MBElementValue *elemval = [[[MBElementValue alloc] initWithIdentifier:key andType:NumberValueType] autorelease];
	[elemval setValueDataAsNumber:[NSNumber numberWithInt:refType]];
	[element addElementValue:elemval];
	[attributeDict setObject:elemval forKey:key];
	
	// connect the value to if the element is connected
	[elemval setIsDbConnected:[element isDbConnected] writeIndex:NO];
}

- (void)createDateAlarmDateAttributeWithValue:(NSDate *)alarmDate
{
	NSString *key = ITEMVALUE_DATE_ALARM_DATE_IDENTIFIER;
	MBElementValue *elemval = [[[MBElementValue alloc] initWithIdentifier:key andType:NumberValueType] autorelease];
	[elemval setValueDataAsNumber:[NSNumber numberWithDouble:[alarmDate timeIntervalSince1970]]];
	[element addElementValue:elemval];
	[attributeDict setObject:elemval forKey:key];
	
	// connect the value to if the element is connected
	[elemval setIsDbConnected:[element isDbConnected] writeIndex:NO];	
}

- (void)createDateAlarmProcessedAttributeWithValue:(BOOL)flag
{
	NSString *key = ITEMVALUE_DATE_ALARM_PROCESSED_IDENTIFIER;
	MBElementValue *elemval = [[[MBElementValue alloc] initWithIdentifier:key andType:NumberValueType] autorelease];
	[elemval setValueDataAsNumber:[NSNumber numberWithBool:flag]];
	[element addElementValue:elemval];
	[attributeDict setObject:elemval forKey:key];
	
	// connect the value to if the element is connected
	[elemval setIsDbConnected:[element isDbConnected] writeIndex:NO];		
}

@end

@implementation MBDateItemValue

// inits
- (id)init
{
	self = [super init];
	if(self == nil)
	{
		CocoLog(LEVEL_ERR,@"cannot init super!");
	}
	else
	{
		// set state
		[self setState:InitState];
		
		// set identifier
		[self setIdentifier:DateItemValueID];
		
		// set valuetype
		[self setValuetype:DateItemValueType];
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		// date
		[self setFromDate:[NSDate date]];
		// default is no date range
		[self setIsDateRange:NO];
		// alarm is deactivated by default
		[self setHasAlarm:NO];
		// formatter string
		[self setFormatterString:[defaults objectForKey:MBDefaultsDateFormatKey]];
		// allow natural language
		[self setAllowNaturalLanguage:(BOOL)[[defaults objectForKey:MBDefaultsDateFormatAllowNaturalLanguageKey] intValue]];
		// use global format
		[self setUseGlobalFormat:YES];
		
		// set state
		[self setState:NormalState];
	}
	
	return self;
}

- (id)initWithDb
{
	self = [self init];
	if(self == nil)
	{
		CocoLog(LEVEL_ERR,@"cannot init super!");
	}
	else
	{
		// set state
		[self setState:InitState];
		
		// connect element
		[self setIsDbConnected:YES];
		
		// set state
		[self setState:NormalState];
	}
	
	return self;
}

- (id)initWithInitializedElement:(MBElement *)aElem
{
	self = [super initWithInitializedElement:aElem];
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

/**
\brief overriding super classes abstract method
 */
- (NSString *)valueDataAsString
{
	if([self encryptionState] == DecryptedState)
	{
		NSDateFormatter *formatter = nil;
		if([self useGlobalFormat])
		{
			formatter = [[[NSDateFormatter alloc] initWithDateFormat:[userDefaults valueForKey:MBDefaultsDateFormatKey] 
												allowNaturalLanguage:[self allowNaturalLanguage]] autorelease];
		}
		else
		{
			formatter = [[[NSDateFormatter alloc] initWithDateFormat:[self formatterString] 
												allowNaturalLanguage:[self allowNaturalLanguage]] autorelease];		
		}
		
		// generate return string
		NSString *dateString = nil;
		if([self isDateRange])
		{
			dateString = [NSString stringWithFormat:@"%@ - %@",
				[formatter stringForObjectValue:[self fromDate]],
				[formatter stringForObjectValue:[self toDate]]];
		}
		else
		{
			dateString = [formatter stringForObjectValue:[self fromDate]];		
		}
		
		return dateString;
	}
	else
	{
		return MBLocaleStr(@"Encrypted");
	}
}

/**
\ here we return a string with the TimeIntervall since 1970. This way we can sort correctly
 */
- (NSString *)valueDataForComparison {
	NSString *ret;
	// always take the beginning date for sorting
	ret = [[NSNumber numberWithDouble:[[self fromDate] timeIntervalSince1970]] stringValue];
	
	return ret;
}

/**
 /brief get the days of the month, year has to be specified for february
*/
+ (int)daysOfMonth:(int)month ofYear:(int)year {
	int days = 0;
    if(month == 0) month = 1;
	if((month > 0) && (month < 13)) {
		days = [[[MBDateItemValue daysForMonth] objectAtIndex:(NSUInteger)month] intValue];
	
		// for february we have to calculate the days according to the gregorian calendar
		if(month == 2) {
			BOOL isSchaltjahr = NO;
			
			// year has to be dividable by 4
			int diff = year % 4;
			if(diff == 0) {
				// year may not be dividable by 100
				diff = year % 100;
				if(diff != 0) {
					isSchaltjahr = YES;
				}
			}
			
			// if dividable by 100 bot not by 400 it is a normal year
			diff = year % 100;
			if(diff == 0) {
				diff = year % 400;
				if(diff != 0) {
					isSchaltjahr = NO;
				}
			}
			
			// if year is a schaltjahr then it must be dividable by 400
			if(isSchaltjahr) {
				diff = year % 400;
				if(diff != 0) {
					isSchaltjahr = NO;
				}
			}
			
			// if we have a schaltjahr, then we have 29 days otherwise we have 28 days
			if(isSchaltjahr) {
				days = 29;
			} else {
				days = 28;
			}
			CocoLog(LEVEL_DEBUG, @"year: %d is Schaltjahr: %d",year,(int)isSchaltjahr);
		}
	} else {
		CocoLog(LEVEL_WARN, @"month is out of bounds!");
	}
	
	return days;
}

/**
 \brief array of days for each month
 the days for february have to calculated are may not be correct
*/
+ (NSArray *)daysForMonth {
	return [NSArray arrayWithObjects:
		[NSNumber numberWithInt:0],
		[NSNumber numberWithInt:31],
		[NSNumber numberWithInt:28],
		[NSNumber numberWithInt:31],
		[NSNumber numberWithInt:30],
		[NSNumber numberWithInt:31],
		[NSNumber numberWithInt:30],
		[NSNumber numberWithInt:31],
		[NSNumber numberWithInt:31],
		[NSNumber numberWithInt:30],
		[NSNumber numberWithInt:31],
		[NSNumber numberWithInt:30],
		[NSNumber numberWithInt:31],
		nil];		
}

/**
\brief calculate a new alarm date if any settings with alarm have changed
 */
- (NSDate *)calculateAlarmDate
{
	NSDate *alarmDate = nil;
	NSCalendarDate *calDate = nil;
	
	if([self hasAlarm])
	{
		// check alarm date ref
		switch([self alarmRefType])
		{
			case AlarmRefFromDate:
				calDate = [NSCalendarDate dateWithTimeIntervalSince1970:[[self fromDate] timeIntervalSince1970]];
				break;
			case AlarmRefToDate:
				calDate = [NSCalendarDate dateWithTimeIntervalSince1970:[[self toDate] timeIntervalSince1970]];
				break;
		}
		
		// get year, month, day, hour and minute
		int year = [calDate yearOfCommonEra];
		int month = [calDate monthOfYear];
		int day = [calDate dayOfMonth];
		int hour = [calDate hourOfDay];
		int minute = [calDate minuteOfHour];
		
		// check offset
		int offset = [self alarmOffsetValue];
		if(offset != 0)
		{
			int buf = 0;
			switch([self alarmOffsetType])
			{
				// we do it upside down.
				// e.g. if minutes are more then one hour, we also process the hour
				case AlarmOffsetMinute:
					minute = minute + offset;
					offset = 0;		// reset
					// check overflow
					buf = minute / 60;
					minute = minute % 60;
				case AlarmOffsetHour:
					if(buf != 0)
					{
						offset = offset + buf;
					}
					hour = hour + offset;
					offset = 0;		// reset
					// check again hours
					buf = hour / 24;		// on day has 24 hours
					hour = hour % 24;
				case AlarmOffsetDay:
					if(buf != 0)
					{
						offset = offset + buf;
					}
					// check again days
					int daysOfMonth = [MBDateItemValue daysOfMonth:month ofYear:year];
					// check month offset
					buf = offset / daysOfMonth;
					// get correct day and check month offset again
					int mod = offset % daysOfMonth;
					offset = 0;		// reset
					if(mod != 0)
					{
						day += mod;
						if(day > daysOfMonth)
						{
							day = day - daysOfMonth;
							// add overlapping months to buf
							buf++;
						}
					}		
				case AlarmOffsetMonth:
					if(buf != 0)
					{
						offset = offset + buf;
					}
					// check for year offset
					buf = offset / 12;
					// get correct month and check year offset again
					mod = offset % 12;
					offset = 0;		// reset
					if(mod != 0)
					{
						month += mod;
						if(month > 12)
						{
							month = month - 12;
							// add overlapping years to buf
							buf++;
						}
					}		
					case AlarmOffsetYear:
					if(buf != 0)
					{
						offset = offset + buf;
					}
					year = year + offset;
					break;
			}
		}
		
		// generate Calendar date out of components
		NSCalendarDate *newDate = [NSCalendarDate dateWithYear:year 
														 month:(NSUInteger)month
														   day:(NSUInteger)day
														  hour:(NSUInteger)hour
														minute:(NSUInteger)minute
														second:0 
													  timeZone:[NSTimeZone localTimeZone]];
		
		// recalculate the Calendar date to a normal date
		alarmDate = [NSDate dateWithTimeIntervalSince1970:[newDate timeIntervalSince1970]];

		// we also have to include the repeat setting
		if([self alarmRepeatType] > AlarmRepeatNone)
		{
			// get minutes of now
			int nowMin = ((int)[[NSDate date] timeIntervalSince1970] / 60);
			int alarmMin = ((int)[alarmDate timeIntervalSince1970] / 60);
			
			// is this alarm date in the past and processed?
			// we need a date in the future
			while((alarmMin < nowMin))// && ([self alarmProcessed]))
			{
				int daysOfMonth = 0;
				switch([self alarmRepeatType])
				{
					case AlarmRepeatNone:
						break;
					case AlarmRepeatDaily:
						day = day + 1;
						// check month overflow
						daysOfMonth = [MBDateItemValue daysOfMonth:month ofYear:year];
						month = month + (day / daysOfMonth);
						day = day % daysOfMonth;
						// check year overflow
						year = year + (month / 13);
						month = month % 13;
						break;
					case AlarmRepeatWeekly:
						day = day + 7;
						// check month overflow
						daysOfMonth = [MBDateItemValue daysOfMonth:month ofYear:year];
						month = month + (day / daysOfMonth);
						day = day % daysOfMonth;
						// check year overflow
						year = year + (month / 13);
						month = month % 13;
						break;
					case AlarmRepeatMonthly:
						month = month + 1;
						// check year overflow
						year = year + (month / 13);
						month = month % 13;
						break;
					case AlarmRepeatYearly:
						year = year + 1;						
						break;
				}
				
				// generate Calendar date out of components
				newDate = [NSCalendarDate dateWithYear:year 
												 month:(NSUInteger)month
												   day:(NSUInteger)day
												  hour:(NSUInteger)hour
												minute:(NSUInteger)minute
												second:0 
											  timeZone:[NSTimeZone localTimeZone]];
				
				// recalculate the Calendar date to a normal date
				alarmDate = [NSDate dateWithTimeIntervalSince1970:[newDate timeIntervalSince1970]];
				
				// get new alarm minutes
				alarmMin = ((int)[alarmDate timeIntervalSince1970] / 60);
			}			
		}		
	}
	
	return alarmDate;
}

//--------------------------------------------------------------------
//------------- Item De/Encryption ----------------------
//--------------------------------------------------------------------
/**
\brief this method encrypts the number value of this itemvalue
 The super class melthod is called first to do let it do some work.
 @returns MBCryptoErrorCode
 */
- (MBCryptoErrorCode)encryptWithString:(NSString *)aString
{
    MBCryptoErrorCode ret = MBCryptoOK;
	
	if((aString != nil) || ([aString length] > 0))
	{
		// check the encryption state of this item
		if([self encryptionState] != EncryptedState)
		{
			// call super first
            MBCryptoErrorCode stat = [super encryptWithString:aString];
			// if we get an error here, do not proceed
			if(stat != MBCryptoOK)
			{
				ret = stat;
				CocoLog(LEVEL_WARN,@"[MBDateItemValue -encryptWithString:] super class returned with error, we will not proceed!");
			}
			else
			{
				NSData *encryptedData = nil;
				ret = [self doEncryptionOfData:[self fromDateAsData] 
								 withKeyString:aString 
								 encryptedData:&encryptedData];
				if(ret == MBCryptoOK)
				{
					// set state
					[self setEncryptionState:EncryptedState];
					// write data
					[self setFromDateAsData:encryptedData];
					// register for changing the index
					[[MBValueIndexController defaultController] registerCommonItem:self];
				}
			}
		}
	}
	else
	{
		CocoLog(LEVEL_WARN,@"keyString is nil or empty!");
		ret = MBCryptoUnableToEncrypt;
	}
	
	return ret;
}

/**
\brief this method decrypts the encrypted number and the value that is returned by -valueDataAsData.
 @returns MBCryptoErrorCode
 */
- (MBCryptoErrorCode)decryptWithString:(NSString *)aString
{
    MBCryptoErrorCode ret = MBCryptoOK;
	
	if((aString != nil) || ([aString length] > 0))
	{
		// check the encryption state of this item
		if([self encryptionState] == EncryptedState)
		{
			// first call super decrypt
            MBCryptoErrorCode stat = [super decryptWithString:aString];
			// if we get an error here, do not proceed
			if(stat != MBCryptoOK)
			{
				ret = stat;
				CocoLog(LEVEL_WARN,@"super class returned with error, we will not proceed!");
			}
			else
			{
				NSData *decryptedData = nil;
				ret = [self doDecryptionOfData:[self fromDateAsData] 
								 withKeyString:aString 
								 decryptedData:&decryptedData];
				if(ret == MBCryptoOK)
				{
					// set state
					[self setEncryptionState:DecryptedState];
					// write data
					[self setFromDateAsData:decryptedData];
					// register for changing the index
					[[MBValueIndexController defaultController] registerCommonItem:self];
				}	
			}
		}
	}
	else
	{
		CocoLog(LEVEL_WARN,@"keyString is nil or empty!");
		ret = MBCryptoUnableToDecrypt;
	}
	
	return ret;	
}

//--------------------------------------------------------------------
//------------- NSCopying protocoll ---------------------------------------
//--------------------------------------------------------------------
/**
\brief makes a copy of self commonitem for which the sender is responsible for releasing
 */
- (id)copyWithZone:(NSZone *)zone
{
	// make a new object with alloc and init and return that
	MBDateItemValue *newItemval = [[MBDateItemValue alloc] initWithInitializedElement:[[element copy] autorelease]];
	
	if(newItemval == nil)
	{
		CocoLog(LEVEL_ERR,@"cannot alloc new MBItem!");
	}
	else
	{
	}
	
	return newItemval;
}

//--------------------------------------------------------------------
//------------- NSCoding protocoll -----------------------------------
//--------------------------------------------------------------------
- (id)initWithCoder:(NSCoder *)decoder NS_RETURNS_RETAINED {
	MBDateItemValue *newItemval = nil;
	
	/*
	// get instance of threaded progress indicator
	MBThreadedProgressSheetController *pSheet = [MBThreadedProgressSheetController standardProgressSheetController];
	
	if([pSheet shouldKeepTrackOfProgress] == YES)
	{
		// is there a progress indication going on?
		if([pSheet progressAction] == PASTE_PROGRESS_ACTION)
		{
			// increment indicator
			[pSheet performSelectorOnMainThread:@selector(incrementProgressBy:) 
									 withObject:[NSNumber numberWithDouble:1.0]
								  waitUntilDone:YES];
		}
	}
	 */

	if([decoder allowsKeyedCoding])
	{
		// decode the only encoded object
		MBElement *elem = [decoder decodeObjectForKey:@"ItemValueElement"];
		// create commonitem with that
		newItemval = [[MBDateItemValue alloc] initWithInitializedElement:elem];
	}
	else
	{
		// decode the only encoded object
		MBElement *elem = [decoder decodeObject];
		// create commonitem with that
		newItemval = [[MBDateItemValue alloc] initWithInitializedElement:elem];
	}
	
	return newItemval;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	// use encoding method from super class
	[super encodeWithCoder:encoder];
}

@end

@implementation MBDateItemValue (ElementBase)

// attribute setter
- (void)setFromDate:(NSDate *)aDate
{
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_DATE_DATE_IDENTIFIER];
	if(elemval != nil)
	{
		[elemval setValueDataAsNumber:[NSNumber numberWithDouble:[aDate timeIntervalSince1970]]];

		// if this value has an alarm, calculate new alarm date
		if(([self hasAlarm]) && ([self alarmRefType] == AlarmRefFromDate))
		{
			NSDate *newAlarmDate = [self calculateAlarmDate];
			// set the new alarm date
			[self setAlarmDate:newAlarmDate];
		}
		
		// send Notification
		if(([self state] == NormalState) || ([self state] == UnRedoState))
		{
			// register itemvalue to the list of to be processed valueindexes
			[[MBValueIndexController defaultController] registerCommonItem:self];
			
			MBSendNotifyItemValueAttribsChanged(self);
		}
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		[self createDateFromValueAttributeWithValue:aDate];
	}	
}

- (void)setFromDateAsData:(NSData *)aDateData
{
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_DATE_DATE_IDENTIFIER];
	if(elemval != nil)
	{
		[elemval setValueDataAsData:aDateData];
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		[self createDateFromValueAttributeWithValue:[NSDate date]];
	}	
}

- (void)setToDate:(NSDate *)aDate
{
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_DATE_TODATE_IDENTIFIER];
	if(elemval != nil)
	{
		[elemval setValueDataAsNumber:[NSNumber numberWithDouble:[aDate timeIntervalSince1970]]];
		
		// if this value has an alarm, calculate new alarm date
		if(([self hasAlarm]) && ([self alarmRefType] == AlarmRefToDate))
		{
			NSDate *newAlarmDate = [self calculateAlarmDate];
			// set the new alarm date
			[self setAlarmDate:newAlarmDate];
		}
		
		// send Notification
		if(([self state] == NormalState) || ([self state] == UnRedoState))
		{
			// register itemvalue to the list of to be processed valueindexes
			[[MBValueIndexController defaultController] registerCommonItem:self];
			
			MBSendNotifyItemValueAttribsChanged(self);
		}
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		[self createDateToValueAttributeWithValue:aDate];
	}	
}

- (void)setToDateAsData:(NSData *)aDateData
{
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_DATE_TODATE_IDENTIFIER];
	if(elemval != nil)
	{
		[elemval setValueDataAsData:aDateData];
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		[self createDateToValueAttributeWithValue:[NSDate date]];
	}	
}

- (void)setFormatterString:(NSString *)aFormat
{
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_DATE_FORMATTERSTRING_IDENTIFIER];
	if(elemval != nil)
	{
		[elemval setValueDataAsString:aFormat];

		// send Notification
		if(([self state] == NormalState) || ([self state] == UnRedoState))
		{
			MBSendNotifyItemValueAttribsChanged(self);
		}
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		[self createDateFormatterStringAttributeWithValue:aFormat];
	}	
}

- (void)setAllowNaturalLanguage:(BOOL)aSetting
{
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_DATE_ALLOW_NATURAL_LANGUAGE_IDENTIFIER];
	if(elemval != nil)
	{
		[elemval setValueDataAsNumber:[NSNumber numberWithBool:aSetting]];

		// send Notification
		if(([self state] == NormalState) || ([self state] == UnRedoState))
		{
			MBSendNotifyItemValueAttribsChanged(self);
		}
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		[self createDateAllowNatLanguageAttributeWithValue:aSetting];
	}
}

- (void)setUseGlobalFormat:(BOOL)aSetting
{
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_DATE_USE_GLOBAL_FORMAT_IDENTIFIER];
	if(elemval != nil)
	{
		[elemval setValueDataAsNumber:[NSNumber numberWithBool:aSetting]];

		// send Notification
		if(([self state] == NormalState) || ([self state] == UnRedoState))
		{
			MBSendNotifyItemValueAttribsChanged(self);
		}
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		[self createDateUseGlobalFormatAttributeWithValue:aSetting];
	}	
}

- (void)setIsDateRange:(BOOL)aFlag
{
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_DATE_ISRANGE_IDENTIFIER];
	if(elemval != nil)
	{
		[elemval setValueDataAsNumber:[NSNumber numberWithBool:aFlag]];
		
		// send Notification
		if(([self state] == NormalState) || ([self state] == UnRedoState))
		{
			MBSendNotifyItemValueAttribsChanged(self);
		}
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		[self createDateIsRangeAttributeWithValue:aFlag];
	}
}

- (void)setHasAlarm:(BOOL)aFlag
{
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_DATE_ALARM_ACTIVE_IDENTIFIER];
	if(elemval != nil)
	{
		[elemval setValueDataAsNumber:[NSNumber numberWithBool:aFlag]];
		
		// recalculate new alarm
		NSDate *alarmDate = [self calculateAlarmDate];
		[self setAlarmDate:alarmDate];
		
		// send Notification
		if(([self state] == NormalState) || ([self state] == UnRedoState))
		{
			MBSendNotifyItemValueAttribsChanged(self);
		}
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		[self createDateAlarmActiveAttributeWithValue:aFlag];
	}	
}

- (void)setAlarmRefType:(MBAlarmRefType)aRefType
{
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_DATE_ALARM_REF_DATE_TYPE_IDENTIFIER];
	if(elemval != nil)
	{
		[elemval setValueDataAsNumber:[NSNumber numberWithInt:aRefType]];
		
		// recalculate new alarm
		NSDate *alarmDate = [self calculateAlarmDate];
		[self setAlarmDate:alarmDate];
		
		// send Notification
		if(([self state] == NormalState) || ([self state] == UnRedoState))
		{
			MBSendNotifyItemValueAttribsChanged(self);
		}
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		[self createDateAlarmRefDateTypeAttributeWithValue:aRefType];
	}	
}

- (void)setAlarmOffsetType:(MBAlarmOffsetType)aOffsetType
{
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_DATE_ALARM_OFFSET_TYPE_IDENTIFIER];
	if(elemval != nil)
	{
		[elemval setValueDataAsNumber:[NSNumber numberWithInt:aOffsetType]];
		
		// recalculate new alarm
		NSDate *alarmDate = [self calculateAlarmDate];
		[self setAlarmDate:alarmDate];
		
		// send Notification
		if(([self state] == NormalState) || ([self state] == UnRedoState))
		{
			MBSendNotifyItemValueAttribsChanged(self);
		}
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		[self createDateAlarmOffsetTypeAttributeWithValue:aOffsetType];
	}	
}

- (void)setAlarmOffsetValue:(int)aValue
{
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_DATE_ALARM_OFFSET_VALUE_IDENTIFIER];
	if(elemval != nil)
	{
		[elemval setValueDataAsNumber:[NSNumber numberWithInt:aValue]];
		
		// recalculate new alarm
		NSDate *alarmDate = [self calculateAlarmDate];
		[self setAlarmDate:alarmDate];
		
		// send Notification
		if(([self state] == NormalState) || ([self state] == UnRedoState))
		{
			MBSendNotifyItemValueAttribsChanged(self);
		}
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		[self createDateAlarmOffsetValueAttributeWithValue:aValue];
	}	
}

- (void)setAlarmRepeatType:(MBAlarmRepeatType)aType
{
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_DATE_ALARM_REPEAT_TYPE_IDENTIFIER];
	if(elemval != nil)
	{
		[elemval setValueDataAsNumber:[NSNumber numberWithInt:aType]];
		
		// recalculate new alarm
		NSDate *alarmDate = [self calculateAlarmDate];
		[self setAlarmDate:alarmDate];
		
		// send Notification
		if(([self state] == NormalState) || ([self state] == UnRedoState))
		{
			MBSendNotifyItemValueAttribsChanged(self);
		}
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		[self createDateAlarmRepeatTypeAttributeWithValue:aType];
	}	
}

- (void)setAlarmDate:(NSDate *)aDate
{
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_DATE_ALARM_DATE_IDENTIFIER];
	if(elemval != nil)
	{
		[elemval setValueDataAsNumber:[NSNumber numberWithDouble:[aDate timeIntervalSince1970]]];
		
		// if the alarm date changes, set it unprocessed
		[self setAlarmProcessed:NO];
		
		// send Notification
		if(([self state] == NormalState) || ([self state] == UnRedoState))
		{
			MBSendNotifyItemValueAttribsChanged(self);
		}		
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		[self createDateAlarmDateAttributeWithValue:aDate];
	}	
}

- (void)setAlarmProcessed:(BOOL)aFlag
{
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_DATE_ALARM_PROCESSED_IDENTIFIER];
	if(elemval != nil)
	{
		[elemval setValueDataAsNumber:[NSNumber numberWithBool:aFlag]];		
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		[self createDateAlarmProcessedAttributeWithValue:aFlag];
	}	
}

// attribute getter
- (NSDate *)fromDate
{
	NSDate *ret = nil;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_DATE_DATE_IDENTIFIER];
	if(elemval != nil)
	{
		ret = [NSDate dateWithTimeIntervalSince1970:[[elemval valueDataAsNumber] doubleValue]];
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		ret = [NSDate date];
		[self createDateFromValueAttributeWithValue:ret];
	}
	
	return ret;
}

- (NSData *)fromDateAsData
{
	NSData *ret = nil;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_DATE_DATE_IDENTIFIER];
	if(elemval != nil)
	{
		ret = [elemval valueDataAsData];
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		ret = [[[NSDate date] description] dataUsingEncoding:NSUTF8StringEncoding];
		[self createDateFromValueAttributeWithValue:[NSDate date]];
	}
	
	return ret;	
}

- (NSDate *)toDate
{
	NSDate *ret = nil;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_DATE_TODATE_IDENTIFIER];
	if(elemval != nil)
	{
		ret = [NSDate dateWithTimeIntervalSince1970:[[elemval valueDataAsNumber] doubleValue]];
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		ret = [NSDate date];
		[self createDateToValueAttributeWithValue:ret];
	}
	
	return ret;
}

- (NSData *)toDateAsData
{
	NSData *ret = nil;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_DATE_TODATE_IDENTIFIER];
	if(elemval != nil)
	{
		ret = [elemval valueDataAsData];
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		ret = [[[NSDate date] description] dataUsingEncoding:NSUTF8StringEncoding];
		[self createDateToValueAttributeWithValue:[NSDate date]];
	}
	
	return ret;	
}

- (NSString *)formatterString
{
	NSString *ret = nil;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_DATE_FORMATTERSTRING_IDENTIFIER];
	if(elemval != nil)
	{
		ret = [elemval valueDataAsString];
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		ret = [userDefaults valueForKey:MBDefaultsDateFormatKey];
		[self createDateFormatterStringAttributeWithValue:ret];
	}
	
	return ret;
}

- (BOOL)allowNaturalLanguage
{
	BOOL ret = YES;

	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_DATE_ALLOW_NATURAL_LANGUAGE_IDENTIFIER];
	if(elemval != nil)
	{
		ret = [[elemval valueDataAsNumber] boolValue];
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		[self createDateAllowNatLanguageAttributeWithValue:ret];
	}
	
	return ret;	
}

- (BOOL)isDateRange
{
	BOOL ret = NO;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_DATE_ISRANGE_IDENTIFIER];
	if(elemval != nil)
	{
		ret = [[elemval valueDataAsNumber] boolValue];
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		[self createDateIsRangeAttributeWithValue:ret];
	}
	
	return ret;	
}

- (BOOL)useGlobalFormat
{
	BOOL ret = YES;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_DATE_USE_GLOBAL_FORMAT_IDENTIFIER];
	if(elemval != nil)
	{
		ret = [[elemval valueDataAsNumber] boolValue];
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		[self createDateUseGlobalFormatAttributeWithValue:ret];
	}
	
	return ret;		
}

- (BOOL)hasAlarm
{
	BOOL ret = NO;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_DATE_ALARM_ACTIVE_IDENTIFIER];
	if(elemval != nil)
	{
		ret = [[elemval valueDataAsNumber] boolValue];
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		[self createDateAlarmActiveAttributeWithValue:ret];
	}
	
	return ret;	
}

- (MBAlarmRefType)alarmRefType
{
    MBAlarmRefType ret = AlarmRefFromDate;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_DATE_ALARM_REF_DATE_TYPE_IDENTIFIER];
	if(elemval != nil)
	{
		ret = (MBAlarmRefType) [[elemval valueDataAsNumber] intValue];
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		[self createDateAlarmRefDateTypeAttributeWithValue:ret];
	}
	
	return ret;		
}

- (MBAlarmOffsetType)alarmOffsetType
{
    MBAlarmOffsetType ret = AlarmOffsetYear;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_DATE_ALARM_OFFSET_TYPE_IDENTIFIER];
	if(elemval != nil)
	{
		ret = (MBAlarmOffsetType) [[elemval valueDataAsNumber] intValue];
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		[self createDateAlarmOffsetTypeAttributeWithValue:ret];
	}
	
	return ret;	
}

- (int)alarmOffsetValue
{
	int ret = 0;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_DATE_ALARM_OFFSET_VALUE_IDENTIFIER];
	if(elemval != nil)
	{
		ret = [[elemval valueDataAsNumber] intValue];
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		[self createDateAlarmOffsetValueAttributeWithValue:ret];
	}
	
	return ret;	
}

- (MBAlarmRepeatType)alarmRepeatType
{
    MBAlarmRepeatType ret = AlarmRepeatNone;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_DATE_ALARM_REPEAT_TYPE_IDENTIFIER];
	if(elemval != nil)
	{
		ret = (MBAlarmRepeatType) [[elemval valueDataAsNumber] intValue];
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		[self createDateAlarmRepeatTypeAttributeWithValue:ret];
	}
	
	return ret;	
}

- (NSDate *)alarmDate
{
	NSDate *ret = nil;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_DATE_ALARM_DATE_IDENTIFIER];
	if(elemval != nil)
	{
		ret = [NSDate dateWithTimeIntervalSince1970:[[elemval valueDataAsNumber] doubleValue]];
	}
	
	return ret;	
}

- (BOOL)alarmProcessed
{
	BOOL ret = NO;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_DATE_ALARM_PROCESSED_IDENTIFIER];
	if(elemval != nil)
	{
		ret = [[elemval valueDataAsNumber] boolValue];
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		[self createDateAlarmProcessedAttributeWithValue:ret];
	}
	
	return ret;		
}

/**
\brief write initial valueindex entries to the table
 */
- (void)writeValueIndexEntryWithCreate:(BOOL)flag
{
	// first super
	[super writeValueIndexEntryWithCreate:flag];
	
	// from date as string
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_DATE_DATE_IDENTIFIER];
	if(flag)
	{
		// create valueindex entry
		[elemval createIndexEntryWithIdentifier:ITEMVALUE_DATE_DATE_IDENTIFIER];
	}
	[elemval setIndexValue:[self valueDataAsString]];
}

@end