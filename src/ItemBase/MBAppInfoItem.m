//
//  MBAppInfoItem.m
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

#import "MBAppInfoItem.h"
#import "MBElementValue.h"
#import "MBElement.h"
#import "globals.h"

#define APPINFOITEM_APPVERSION_IDENTIFIER			@"AppInfoItemAppVersion"
#define APPINFOITEM_DBVERSION_IDENTIFIER			@"AppInfoItemDbVersion"
#define APPINFOITEM_SERNUM_IDENTIFIER				@"AppInfoItemSerNum"
#define APPINFOITEM_REGNAME_IDENTIFIER				@"AppInfoItemRegName"
#define APPINFOITEM_DATEFIRSTSTART_IDENTIFIER		@"AppInfoItemDateFirstStart"
#define APPINFOITEM_DATELASTSTART_IDENTIFIER		@"AppInfoItemDateLastStart"
#define APPINFOITEM_DATELASTSTOP_IDENTIFIER			@"AppInfoItemDateLastStop"
#define APPINFOITEM_APPMODE_IDENTIFIER				@"AppInfoItemAppMode"
#define APPINFOITEM_INDEXINITIALIZED_IDENTIFIER		@"AppInfoItemIndexInitialized"

@interface MBAppInfoItem (privateAPI)

- (void)createAppVersionAttributeWithValue:(NSString *)aString;
- (void)createDbVersionAttributeWithValue:(NSString *)aString;
// these are not longer needed for since version 1.0.3
// registration is saved in NSUserDefaults now
//- (void)createSerNumAttributeWithValue:(NSString *)aString;
//- (void)createRegNameAttributeWithValue:(NSString *)aString;
//- (void)createAppModeAttributeWithValue:(MBAppMode)aMode;
- (void)createDateFirstStartAttributeWithValue:(NSDate *)aDate;
- (void)createDateLastStartAttributeWithValue:(NSDate *)aDate;
- (void)createDateLastStopAttributeWithValue:(NSDate *)aDate;
- (void)createIndexInitializedAttributeWithValue:(BOOL)flag;

@end

@implementation MBAppInfoItem (privateAPI)

- (void)createAppVersionAttributeWithValue:(NSString *)aString {
	// appversion
	NSString *key = APPINFOITEM_APPVERSION_IDENTIFIER;
	MBElementValue *elemval = [[[MBElementValue alloc] initWithIdentifier:key andType:StringValueType] autorelease];
	[elemval setValueDataAsString:aString];
	[element addElementValue:elemval];
	[attributeDict setObject:elemval forKey:key];
}

- (void)createDbVersionAttributeWithValue:(NSString *)aString {
	// dbversion
	NSString *key = APPINFOITEM_DBVERSION_IDENTIFIER;
	MBElementValue *elemval = [[[MBElementValue alloc] initWithIdentifier:key andType:StringValueType] autorelease];
	[elemval setValueDataAsString:aString];
	[element addElementValue:elemval];
	[attributeDict setObject:elemval forKey:key];
}

/**
 \brief SerNum gets Base64 encoded
*/
/*
- (void)createSerNumAttributeWithValue:(NSString *)aString
{
	// sernum
	NSString *key = APPINFOITEM_SERNUM_IDENTIFIER;
	MBElementValue *elemval = [[[MBElementValue alloc] initWithIdentifier:key andType:BinaryValueType] autorelease];
	[elemval setDataHoldTreshold:0];	// load everytime
	[elemval setValueDataAsString:aString];
	[element addElementValue:elemval];
	[attributeDict setObject:elemval forKey:key];
}
*/

/**
\brief SerNum gets Base64 encoded
 */
/*
- (void)createRegNameAttributeWithValue:(NSString *)aString
{
	// regname
	NSString *key = APPINFOITEM_REGNAME_IDENTIFIER;
	MBElementValue *elemval = [[[MBElementValue alloc] initWithIdentifier:key andType:BinaryValueType] autorelease];
	[elemval setDataHoldTreshold:0];	// load everytime
	[elemval setValueDataAsString:aString];
	[element addElementValue:elemval];
	[attributeDict setObject:elemval forKey:key];
}
*/

/**
\brief SerNum gets Base64 encoded on writing to db
 Generally the appmode is sha1 hashed
 */
/*
- (void)createAppModeAttributeWithValue:(MBAppMode)aMode
{
	// appmode
	NSString *key = APPINFOITEM_APPMODE_IDENTIFIER;
	MBElementValue *elemval = [[[MBElementValue alloc] initWithIdentifier:key andType:BinaryValueType] autorelease];
	[elemval setDataHoldTreshold:0];	// load everytime
	NSData *modData = [[[[NSNumber numberWithInt:aMode] stringValue] dataUsingEncoding:NSASCIIStringEncoding] sha1Hash];
	if(modData != nil)
	{
		[elemval setValueDataAsData:modData];
	}
	else
	{
		CocoLog(LEVEL_ERR,@"[MBAppInfoItem -createAppModeAttributeWithValue:] cannot create data of mode!");
	}
	[element addElementValue:elemval];
	[attributeDict setObject:elemval forKey:key];
}
*/

- (void)createDateFirstStartAttributeWithValue:(NSDate *)aDate {
	// date first start
	NSString *key = APPINFOITEM_DATEFIRSTSTART_IDENTIFIER;
	MBElementValue *elemval = [[[MBElementValue alloc] initWithIdentifier:key andType:NumberValueType] autorelease];
	[elemval setValueDataAsNumber:[NSNumber numberWithDouble:[aDate timeIntervalSince1970]]];
	[element addElementValue:elemval];
	[attributeDict setObject:elemval forKey:key];
}

- (void)createDateLastStartAttributeWithValue:(NSDate *)aDate {
	// date last start
	NSString *key = APPINFOITEM_DATELASTSTART_IDENTIFIER;
	MBElementValue *elemval = [[[MBElementValue alloc] initWithIdentifier:key andType:NumberValueType] autorelease];
	[elemval setValueDataAsNumber:[NSNumber numberWithDouble:[aDate timeIntervalSince1970]]];
	[element addElementValue:elemval];
	[attributeDict setObject:elemval forKey:key];
}

- (void)createDateLastStopAttributeWithValue:(NSDate *)aDate {
	// date last start
	NSString *key = APPINFOITEM_DATELASTSTOP_IDENTIFIER;
	MBElementValue *elemval = [[[MBElementValue alloc] initWithIdentifier:key andType:NumberValueType] autorelease];
	[elemval setValueDataAsNumber:[NSNumber numberWithDouble:[aDate timeIntervalSince1970]]];
	[element addElementValue:elemval];
	[attributeDict setObject:elemval forKey:key];	
}

- (void)createIndexInitializedAttributeWithValue:(BOOL)flag {
	// index initialized
	NSString *key = APPINFOITEM_INDEXINITIALIZED_IDENTIFIER;
	MBElementValue *elemval = [[[MBElementValue alloc] initWithIdentifier:key andType:NumberValueType] autorelease];
	[elemval setValueDataAsNumber:[NSNumber numberWithBool:flag]];
	[element addElementValue:elemval];
	[attributeDict setObject:elemval forKey:key];		
}

@end

@implementation MBAppInfoItem

- (id)init {
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"[MBAppInfoItem -init]: cannot init super!");
	} else {
		// set state
		[self setState:InitState];
		
		// set element identifier
		[self setIdentifier:AppInfoItemID];
		
		// add neccesary attributes
		[self createAppVersionAttributeWithValue:(NSString *)BUNDLEVERSIONSTRING];
		[self createDbVersionAttributeWithValue:@"0.0.0"];
		// from version 1.0.3 registration is stored in NSUserDefaults
		// but older version may have the information stored in db
		//[self createAppModeAttributeWithValue:DemoAppMode];
		//[self createSerNumAttributeWithValue:@""];
		//[self createRegNameAttributeWithValue:MBLocaleStr(@"Unregistered")];
		[self createDateFirstStartAttributeWithValue:[NSDate date]];
		[self createDateLastStartAttributeWithValue:[NSDate date]];
		
		// when this method is called we initialize a complete new installation of iKnow & Manage
		// where it is not needed to run a copy run of valueindex
		[self createIndexInitializedAttributeWithValue:YES];

		// set state
		[self setState:NormalState];
	}
	
	return self;		
}

- (id)initWithDb {
	self = [self init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"[MBAppInfoItem -initWithDb]: cannot init super!");
	} else {
		// set state
		[self setState:InitState];

		// connect element
		[self setIsDbConnected:YES];
		
		// set state
		[self setState:NormalState];
	}
	
	return self;	
}

- (id)initWithInitializedElement:(MBElement *)aElem {
	self = [super initWithInitializedElement:aElem];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"[MBStdItem -initWithInitializedElement:]: cannot init super!");
	}
	
	return self;
}

- (void)dealloc {
	CocoLog(LEVEL_DEBUG,@"[MBStdItem -dealloc]");
	
	// set state
	[self setState:DeallocState];
	
	// release super
	[super dealloc];
}

/**
 \brief this method checks if the registration is saved in the AppInfo Item
*/
- (BOOL)hasRegistrationInformation {
	BOOL hasReg = NO;
	
	// lets see, if we have the MBElementValues
	if([attributeDict objectForKey:APPINFOITEM_APPMODE_IDENTIFIER]) {
		hasReg = YES;
	}
	
	return hasReg;
}

/**
 \brief with version 1.0.3 the registration info is saved in NSUserDefaults
 After copying the reginfo to NSUserDefaults, we can delete them in AppInfo Item
*/
- (void)deleteRegistrationInfo {
	MBElementValue *elemVal = [attributeDict objectForKey:APPINFOITEM_APPMODE_IDENTIFIER];
	// delete
	[elemVal delete];
	[[elemVal element] removeElementValue:elemVal];
	elemVal = [attributeDict objectForKey:APPINFOITEM_REGNAME_IDENTIFIER];
	[elemVal delete];
	[[elemVal element] removeElementValue:elemVal];
	elemVal = [attributeDict objectForKey:APPINFOITEM_SERNUM_IDENTIFIER];
	[elemVal delete];
	[[elemVal element] removeElementValue:elemVal];
	
	// release dict entries
	[attributeDict removeObjectForKey:APPINFOITEM_APPMODE_IDENTIFIER];
	[attributeDict removeObjectForKey:APPINFOITEM_REGNAME_IDENTIFIER];
	[attributeDict removeObjectForKey:APPINFOITEM_SERNUM_IDENTIFIER];
}

@end

@implementation MBAppInfoItem (ElementBase)

// attribute setter
- (void)setAppVersion:(NSString *)aVersion {
	MBElementValue *elemval = [attributeDict valueForKey:APPINFOITEM_APPVERSION_IDENTIFIER];
	if(elemval != nil) {
		[elemval setValueDataAsString:aVersion];
	} else {
		CocoLog(LEVEL_ERR,@"[MBAppInfoItem -setAppVersion:] elementvalue is nil, creating it!");
		[self createAppVersionAttributeWithValue:aVersion];
	}	
}

- (void)setDbVersion:(NSString *)aVersion {
	MBElementValue *elemval = [attributeDict valueForKey:APPINFOITEM_DBVERSION_IDENTIFIER];
	if(elemval != nil) {
		[elemval setValueDataAsString:aVersion];
	} else {
		CocoLog(LEVEL_ERR,@"[MBAppInfoItem -setDbVersion:] elementvalue is nil, creating it!");
		[self createDbVersionAttributeWithValue:aVersion];
	}	
}

/**
 \brief AppMode is sha1 hashed and written to db base64 encoded
*/
/*
- (void)setAppMode:(MBAppMode)aMode
{
	MBElementValue *elemval = [attributeDict valueForKey:APPINFOITEM_APPMODE_IDENTIFIER];
	if(elemval != nil)
	{
		NSData *modData = [[[[NSNumber numberWithInt:aMode] stringValue] dataUsingEncoding:NSASCIIStringEncoding] sha1Hash];
		if(modData != nil)
		{
			[elemval setValueDataAsData:modData];
		}
		else
		{
			CocoLog(LEVEL_ERR,@"[MBAppInfoItem -setAppMode:] cannot create data of mode!");
		}
	}
	else
	{
		CocoLog(LEVEL_ERR,@"[MBAppInfoItem -setAppMode:] elementvalue is nil, creating it!");
		[self createAppModeAttributeWithValue:aMode];
	}	
}
*/

/**
 \brief Serial Number is base64 encoded when written to db
*/
/*
- (void)setSerNum:(NSString *)aString
{
	MBElementValue *elemval = [attributeDict valueForKey:APPINFOITEM_SERNUM_IDENTIFIER];
	if(elemval != nil)
	{
		[elemval setValueDataAsString:aString];
	}
	else
	{
		CocoLog(LEVEL_ERR,@"[MBAppInfoItem -setSerNum:] elementvalue is nil, creating it!");
		[self createSerNumAttributeWithValue:aString];
	}	
}

- (void)setRegName:(NSString *)aName
{
	MBElementValue *elemval = [attributeDict valueForKey:APPINFOITEM_REGNAME_IDENTIFIER];
	if(elemval != nil)
	{
		[elemval setValueDataAsString:aName];
	}
	else
	{
		CocoLog(LEVEL_ERR,@"[MBAppInfoItem -setRegName:] elementvalue is nil, creating it!");
		[self createRegNameAttributeWithValue:aName];
	}	
}
*/

- (void)setDateFirstStart:(NSDate *)aDate {
	MBElementValue *elemval = [attributeDict valueForKey:APPINFOITEM_DATEFIRSTSTART_IDENTIFIER];
	if(elemval != nil) {
		[elemval setValueDataAsNumber:[NSNumber numberWithDouble:[aDate timeIntervalSince1970]]];
	} else {
		CocoLog(LEVEL_ERR,@"[MBAppInfoItem -setDateFirstStart:] elementvalue is nil, creating it!");
		[self createDateFirstStartAttributeWithValue:aDate];
	}	
}

- (void)setDateLastStart:(NSDate *)aDate {
	MBElementValue *elemval = [attributeDict valueForKey:APPINFOITEM_DATELASTSTART_IDENTIFIER];
	if(elemval != nil) {
		[elemval setValueDataAsNumber:[NSNumber numberWithDouble:[aDate timeIntervalSince1970]]];
	} else {
		CocoLog(LEVEL_ERR,@"[MBAppInfoItem -setDateLastStart:] elementvalue is nil, creating it!");
		[self createDateLastStartAttributeWithValue:aDate];
	}	
}

- (void)setDateLastStop:(NSDate *)aDate {
	MBElementValue *elemval = [attributeDict valueForKey:APPINFOITEM_DATELASTSTOP_IDENTIFIER];
	if(elemval != nil) {
		[elemval setValueDataAsNumber:[NSNumber numberWithDouble:[aDate timeIntervalSince1970]]];
	} else {
		CocoLog(LEVEL_ERR,@"[MBAppInfoItem -setDateLastStart:] elementvalue is nil, creating it!");
		[self createDateLastStopAttributeWithValue:aDate];
	}	
}

/**
 \brief for the first start the valueindex table may be created but the indexvalue may not be initialized
 after initializing set this flag
*/
- (void)setIndexInitiated:(BOOL)flag {
	MBElementValue *elemval = [attributeDict valueForKey:APPINFOITEM_INDEXINITIALIZED_IDENTIFIER];
	if(elemval != nil) {
		[elemval setValueDataAsNumber:[NSNumber numberWithBool:flag]];
	} else {
		CocoLog(LEVEL_ERR,@"[MBAppInfoItem -setIndexInitiated:] elementvalue is nil, creating it!");
		[self createIndexInitializedAttributeWithValue:NO];
	}
}

// attribute getter
- (NSString *)appVersion {
	NSString *ret = nil;
	
	MBElementValue *elemval = [attributeDict valueForKey:APPINFOITEM_APPVERSION_IDENTIFIER];
	if(elemval != nil) {
		ret = [elemval valueDataAsString];
	} else {
		CocoLog(LEVEL_ERR,@"[MBAppInfoItem -appVersion] elementvalue is nil, creating it!");
		ret = (NSString *)BUNDLEVERSIONSTRING;
		[self createAppVersionAttributeWithValue:ret];
	}	
	
	return ret;
}

- (NSString *)dbVersion {
	NSString *ret = nil;
	
	MBElementValue *elemval = [attributeDict valueForKey:APPINFOITEM_DBVERSION_IDENTIFIER];
	if(elemval != nil) {
		ret = [elemval valueDataAsString];
	} else {
		CocoLog(LEVEL_ERR,@"[MBAppInfoItem -dbVersion] elementvalue is nil, creating it!");
		ret = @"0.0.0";
		[self createDbVersionAttributeWithValue:ret];
	}	
	
	return ret;
}

- (NSData *)appMode {
	NSData *modeData = nil;
	
	MBElementValue *elemval = [attributeDict valueForKey:APPINFOITEM_APPMODE_IDENTIFIER];
	if(elemval != nil) {
		modeData = [elemval valueDataAsData];
	} else {
		CocoLog(LEVEL_ERR,@"[MBAppInfoItem -appMode] elementvalue is nil!");
		//[self createAppModeAttributeWithValue:DemoAppMode];
		//modeData = [self appMode];
	}		
	
	return modeData;
}

/**
 \brief serial number is in plain text format except in db where it is stored base64 encoded
*/
- (NSString *)serNum {
	NSString *ret = nil;

	MBElementValue *elemval = [attributeDict valueForKey:APPINFOITEM_SERNUM_IDENTIFIER];
	if(elemval != nil) {
		ret = [elemval valueDataAsString];
	} else {
		CocoLog(LEVEL_ERR,@"[MBAppInfoItem -serNum] elementvalue is nil!");
		ret = @"";
		//[self createSerNumAttributeWithValue:ret];
	}	
	
	return ret;
}

- (NSString *)regName {
	NSString *ret = nil;
	
	MBElementValue *elemval = [attributeDict valueForKey:APPINFOITEM_REGNAME_IDENTIFIER];
	if(elemval != nil) {
		ret = [elemval valueDataAsString];
	} else {
		CocoLog(LEVEL_ERR,@"[MBAppInfoItem -regName] elementvalue is nil, creating it!");
		ret = MBLocaleStr(@"Unregistered");
		//[self createRegNameAttributeWithValue:ret];
	}	
	
	return ret;
}

- (NSDate *)datefirstStart {
	NSDate *ret = nil;
	
	MBElementValue *elemval = [attributeDict valueForKey:APPINFOITEM_DATEFIRSTSTART_IDENTIFIER];
	if(elemval != nil) {
		ret = [NSDate dateWithTimeIntervalSince1970:[[elemval valueDataAsNumber] doubleValue]];
	} else {
		CocoLog(LEVEL_ERR,@"[MBAppInfoItem -datefirstStart] elementvalue is nil, creating it!");
		ret = [NSDate date];
		[self createDateFirstStartAttributeWithValue:ret];
	}	
	
	return ret;
}

- (NSDate *)dateLastStart {
	NSDate *ret = nil;
	
	MBElementValue *elemval = [attributeDict valueForKey:APPINFOITEM_DATELASTSTART_IDENTIFIER];
	if(elemval != nil) {
		ret = [NSDate dateWithTimeIntervalSince1970:[[elemval valueDataAsNumber] doubleValue]];
	} else {
		CocoLog(LEVEL_WARN,@"[MBAppInfoItem -datefirstStart] elementvalue is nil, creating it!");
		ret = [NSDate date];
		[self createDateLastStartAttributeWithValue:ret];
	}	
	
	return ret;
}

- (NSDate *)dateLastStop {
	NSDate *ret = nil;
	
	MBElementValue *elemval = [attributeDict valueForKey:APPINFOITEM_DATELASTSTOP_IDENTIFIER];
	if(elemval != nil) {
		ret = [NSDate dateWithTimeIntervalSince1970:[[elemval valueDataAsNumber] doubleValue]];
	} else {
		CocoLog(LEVEL_WARN,@"[MBAppInfoItem -dateLastStop] elementvalue is nil, creating it!");
		ret = [NSDate date];
		[self createDateLastStopAttributeWithValue:ret];
	}	
	
	return ret;	
}

/**
 \brief if this is the first run of the program it is not needed to copy anything to the valueindex table. returns yes in this case
 if the program has been run before and we need to initialize the index later on, return NO here
*/
- (BOOL)indexInitiated {
	BOOL ret = NO;
	
	MBElementValue *elemval = [attributeDict valueForKey:APPINFOITEM_INDEXINITIALIZED_IDENTIFIER];
	if(elemval != nil) {
		ret = (BOOL)[[elemval valueDataAsNumber] intValue];
	} else {
		CocoLog(LEVEL_WARN,@"[MBAppInfoItem -indexInitiated] elementvalue is nil, creating it!");
		ret = NO;
		[self createIndexInitializedAttributeWithValue:ret];
	}	
	
	return ret;		
}

@end