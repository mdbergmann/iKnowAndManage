//
//  MBURLItemValue.m
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

#import "MBURLItemValue.h"
#import "MBElementValue.h"
#import "MBElement.h"
#import "globals.h"
#import "MBValueIndexController.h"

#define ITEMVALUE_URL_VALUE_IDENTIFIER				@"itemvalueurlvalue"

@interface MBURLItemValue (privateAPI)

- (void)createURLValueAttributeWithValue:(NSURL *)url;

@end

@implementation MBURLItemValue (privateAPI)

- (void)createURLValueAttributeWithValue:(NSURL *)url
{
	NSString *key = ITEMVALUE_URL_VALUE_IDENTIFIER;
	MBElementValue *elemval = [[[MBElementValue alloc] initWithIdentifier:key andType:StringValueType] autorelease];
	[elemval setValueDataAsString:[url absoluteString]];	
	[element addElementValue:elemval];
	[attributeDict setObject:elemval forKey:key];
	
	// connect the value to if the element is connected
	[elemval setIsDbConnected:[element isDbConnected] writeIndex:YES];
}

@end

@implementation MBURLItemValue

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
		[self setIdentifier:URLItemValueID];
		// set valuetype
		[self setValuetype:URLItemValueType];		
		// url
		[self setValueData:[NSURL URLWithString:@""]];

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
		return [[self valueData] absoluteString];
	}
	else
	{
		return MBLocaleStr(@"Encrypted");
	}
}

/**
\ here is is just a wrapper for valueDataAsString
 */
- (NSString *)valueDataForComparison
{
	return [self valueDataAsString];
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
				CocoLog(LEVEL_WARN,@"super class returned with error, we will not proceed!");
			}
			else
			{
				NSData *encryptedData = nil;
				ret = [self doEncryptionOfData:[self valueDataAsData] 
								 withKeyString:aString 
								 encryptedData:&encryptedData];
				if(ret == MBCryptoOK)
				{
					// set state
					[self setEncryptionState:EncryptedState];
					// write data
					[self setValueDataAsData:encryptedData];
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
				ret = [self doDecryptionOfData:[self valueDataAsData] 
								 withKeyString:aString 
								 decryptedData:&decryptedData];
				if(ret == MBCryptoOK)
				{
					// set state
					[self setEncryptionState:DecryptedState];
					// write data
					[self setValueDataAsData:decryptedData];
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
	MBURLItemValue *newItemval = [[MBURLItemValue alloc] initWithInitializedElement:[[element copy] autorelease]];
	
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
- (id)initWithCoder:(NSCoder *)decoder
{
	MBURLItemValue *newItemval = nil;
	
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
		newItemval = [[[MBURLItemValue alloc] initWithInitializedElement:elem] autorelease];
	}
	else
	{
		// decode the only encoded object
		MBElement *elem = [decoder decodeObject];
		// create commonitem with that
		newItemval = [[[MBURLItemValue alloc] initWithInitializedElement:elem] autorelease];
	}
	
	return newItemval;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	// use encoding method from super class
	[super encodeWithCoder:encoder];
}

/**
 \brief tests wether this url  is a file (local) url
*/
- (BOOL)isFile
{
	return [[self valueData] isFileURL];
}

/**
 \brief checks wether this is a local <file://> URL
 @return -1 for unknown or error
 @return 0 NO
 @return 1 for YES 
*/
+ (int)isLocalURL:(NSURL *)url
{
	int isLocal = -1;
	
	if(url == nil)
	{
		CocoLog(LEVEL_WARN,@"url is nil!");
	}
	else
	{
		isLocal = (BOOL)[url isFileURL];
	}
	
	return isLocal;
}

/**
 \brief check wether this url a valid with <proto>:// string
 @return -1 for unknown or error
 @return 0 NO
 @return 1 for YES 
 */
+ (int)isValidURL:(NSURL *)url
{
	int isValid;
	
	if(url == nil)
	{
		CocoLog(LEVEL_WARN,@"url is nil!");
		
		isValid = 0;
	}
	else
	{
		NSString *urlStr = [url absoluteString];
		if([urlStr length] > 0)
		{
			NSArray *urlComponents = [urlStr componentsSeparatedByString:@"://"];
									
			// check, if this is a local url
			if([urlComponents count] > 1)
			{
				isValid = 1;
			}
			else
			{
				isValid = -1;
			}
		}
		else
		{
			isValid = 0;
		}
	}
	
	return isValid;	
}

/**
 \brief checks wether this URL can be connected
 @return -1 for unknown or error
 @return 0 NO
 @return 1 for YES 
 */
+ (int)isConnectableURL:(NSURL *)url
{
	int canBeConnected;
	
	if(url != nil)
	{
		if([[url absoluteString] length] > 0)
		{
			// create a NSURLRequest
			NSURLRequest *request = [NSURLRequest requestWithURL:url];
		
			// check, if this url can be connected
			canBeConnected = (int)[NSURLConnection canHandleRequest:request];
		}
		else
		{
			canBeConnected = 0;
		}
	}
	else
	{
		CocoLog(LEVEL_WARN,@"url is nil!");
		
		canBeConnected = -1;
	}
	
	return canBeConnected;
}

/**
 \brief returns the path component of an URL
*/
+ (NSString *)pathComponentOfURL:(NSURL *)url
{
	NSString *pathComponent = nil;
	
	if(url == nil)
	{
		CocoLog(LEVEL_WARN,@"url is nil!");
	}
	else
	{
		pathComponent = [url relativePath];
	}	
	
	return pathComponent;
}

/**
 \brief returns the protocol component of the given url
*/
+ (NSString *)protocolComponentOfURL:(NSURL *)url
{
	NSString *proto = nil;
	
	if(url == nil)
	{
		CocoLog(LEVEL_WARN,@"url is nil!");
	}
	else
	{
		proto = [url scheme];
	}
	
	return proto;
}


@end

@implementation MBURLItemValue (ElementBase)

// attribute setter
- (void)setValueData:(NSURL *)aURL
{
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_URL_VALUE_IDENTIFIER];
	if(elemval != nil)
	{
		[elemval setValueDataAsString:[aURL absoluteString]];

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
		[self createURLValueAttributeWithValue:aURL];
	}		
}

- (void)setValueDataAsData:(NSData *)aURLData
{
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_URL_VALUE_IDENTIFIER];
	if(elemval != nil)
	{
		[elemval setValueDataAsData:aURLData];
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		[self createURLValueAttributeWithValue:[NSURL URLWithString:@""]];
	}
}

// attribute getter
- (NSURL *)valueData
{
	NSURL *ret = nil;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_URL_VALUE_IDENTIFIER];
	if(elemval != nil)
	{
		ret = [NSURL URLWithString:[elemval valueDataAsString]];
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		ret = [NSURL URLWithString:@""];
		[self createURLValueAttributeWithValue:ret];
	}
	
	return ret;
}

- (NSData *)valueDataAsData
{
	NSData *ret = nil;
	
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_URL_VALUE_IDENTIFIER];
	if(elemval != nil)
	{
		ret = [elemval valueDataAsData];
	}
	else
	{
		CocoLog(LEVEL_WARN,@"elementvalue is nil, creating it!");
		NSURL *url = [NSURL URLWithString:@""];
		ret = [NSData data];
		[self createURLValueAttributeWithValue:url];
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
	
	// url as string
	MBElementValue *elemval = [attributeDict valueForKey:ITEMVALUE_URL_VALUE_IDENTIFIER];
	if(flag)
	{
		// create valueindex entry
		[elemval createIndexEntryWithIdentifier:ITEMVALUE_URL_VALUE_IDENTIFIER];
	}
	[elemval setIndexValue:[self valueDataAsString]];
}

@end

@implementation MBURLItemValue (export)

// for exporting as .webloc
- (NSDictionary *)exportAsWebloc
{
	NSMutableDictionary *weblocDict = [NSMutableDictionary dictionary];
	// key = "URL"
	// value = URL as String
	[weblocDict setValue:[[self valueData] absoluteString] forKey:@"URL"];
	
	return weblocDict;
}

@end

