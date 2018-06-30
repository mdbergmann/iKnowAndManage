//
//  MBDBSqliteElement.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 20.07.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <CocoLogger/CocoLogger.h>
#import <SifSqlite/SifSqlite.h>
#import "MBDBSqliteElement.h"
#import "MBDBSqlite.h"


@implementation MBDBSqliteElement

#pragma mark - Initialization

+ (id<MBDBElementAccessing>)dbElementForElement:(MBElement *)aElem {
	return [[[MBDBSqliteElement alloc] initWithElement:aElem] autorelease];
}

- (id)initWithElement:(MBElement *)aElem {
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"cannot alloc MBDBSqliteElement!");		
    } else {
		// get MBDBSqlite connection
		[self setDbConnection:[MBDBSqlite sharedConnection]];
		
		// create new element and get element id
		elementid = [dbConnection createElementWithElement:aElem];
		if(elementid == -1) {
			CocoLog(LEVEL_ERR, @"cannot create element!");
		} else {
			// logging is not measureable!!!
			CocoLog(LEVEL_DEBUG, @"created element with id: %d", elementid);
		}
	}
	
	return self;	
}

/**
 Init a db element with specified name and type
*/
- (id)init {
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"cannot alloc MBDBSqliteElement!");
	} else {
		// get MBDBSqlite connection
		[self setDbConnection:[MBDBSqlite sharedConnection]];
		elementid = -1;
	}
	
	return self;	
}

/**
 Dealloc of this class is called on closing this document
 */
- (void)dealloc {
	// release our db connection
	[self setDbConnection:nil];
	
	// dealloc object
	[super dealloc];
}

#pragma mark - Getter/Setter

/**
 Set the db connection for this object
 @param aDbConnection a connected and open connection to a db
 */
- (void)setDbConnection:(MBDBAccess<MBDBAccessing> *)aDbConnection {
	// we want to hold our own reference
	[aDbConnection retain];
	[dbConnection release];
	dbConnection = aDbConnection;
}

/**
 Get the db connection of this object
 @return connected and open connection to a db
 */
- (MBDBAccess<MBDBAccessing> *)dbConnection {
	return dbConnection;
}

- (void)setElementid:(int)aElemid {
	elementid = aElemid;
}

- (void)setTreeinfo:(NSString *)aTreeinfo {
	if(aTreeinfo != nil) {
		// write treeinfo value of element to the right element in db
		NSString *sql = [NSString stringWithFormat:@"update element set treeinfo='%@' where id=%d;",
			aTreeinfo,
			elementid];
		
		// execute sql
		[dbConnection executeSql:sql];
		if([dbConnection errorCode] != DB_SUCCESS) {
			NSString *errMsg = [dbConnection errorMessage];
			if(errMsg != nil) {
				CocoLog(LEVEL_ERR, @"%@", errMsg);
			}		
		}
	}
}

- (void)setIdentifier:(NSString *)aIdentifier {
	if(aIdentifier != nil) {
		// write identifier value of element to the right element in db
		NSString *sql = [NSString stringWithFormat:@"update element set identifier='%@' where id=%d;",
			aIdentifier,
			elementid];
		
		// execute sql
		[dbConnection executeSql:sql];
		if([dbConnection errorCode] != DB_SUCCESS) {
			NSString *errMsg = [dbConnection errorMessage];
			if(errMsg != nil) {
				CocoLog(LEVEL_ERR, @"%@", errMsg);
			}		
		}
	}	
}

- (void)setGpReg:(int)aValue {
	// write parentid value of element to the right element in db
	NSString *sql = [NSString stringWithFormat:@"update element set gpreg=%d where id=%d;",
		aValue,
		elementid];
	
	// execute sql
	[dbConnection executeSql:sql];
	if([dbConnection errorCode] != DB_SUCCESS) {
		NSString *errMsg = [dbConnection errorMessage];
		if(errMsg != nil) {
			CocoLog(LEVEL_ERR, @"%@", errMsg);
		}		
	}	
}

- (void)setParentid:(int)aId {
	// write parentid value of element to the right element in db
	NSString *sql = [NSString stringWithFormat:@"update element set parentid=%d where id=%d;",
		aId,
		elementid];
	
	// execute sql
	[dbConnection executeSql:sql];
	if([dbConnection errorCode] != DB_SUCCESS) {
		NSString *errMsg = [dbConnection errorMessage];
		if(errMsg != nil) {
			CocoLog(LEVEL_ERR, @"%@", errMsg);
		}		
	}	
}

- (int)elementid {
	return elementid;
}

- (NSString *)treeinfo {
	NSString *treeinfo = nil;
	
	// sql statement
	NSString *sql = [NSString stringWithFormat:@"select treeinfo from element where id=%d;",elementid];
	
	// execute sql
	NSArray *result = [dbConnection executeQuery:sql];
	if([dbConnection errorCode] != DB_SUCCESS) {
		NSString *errMsg = [dbConnection errorMessage];
		if(errMsg != nil) {
			CocoLog(LEVEL_ERR, @"%@", errMsg);
		}
	} else {
		// check for result
		if(result == nil) {
			CocoLog(LEVEL_WARN,@"have nil result from query!");
		} else {
			// read treeinfo from dict
			// this should only be one entry
			if([result count] == 1) {
				NSDictionary *dict = [result objectAtIndex:0];
				// get treeinfo col
				treeinfo = [dict objectForKey:@"treeinfo"];
			} else {
				CocoLog(LEVEL_WARN,@"incorrect number of results!");
			}
		}
	}
	
	return treeinfo;
}

- (NSString *)identifier {
	NSString *identifier = nil;
	
	// sql statement
	NSString *sql = [NSString stringWithFormat:@"select identifier from element where id=%d;",elementid];
	
	// execute sql
	NSArray *result = [dbConnection executeQuery:sql];
	if([dbConnection errorCode] != DB_SUCCESS) {
		NSString *errMsg = [dbConnection errorMessage];
		if(errMsg != nil) {
			CocoLog(LEVEL_ERR, @"%@", errMsg);
		}
	} else {
		// check for result
		if(result == nil) {
			CocoLog(LEVEL_WARN,@"have nil result from query!");
		} else {
			// read identifier from dict
			// this should only be one entry
			if([result count] == 1) {
				NSDictionary *dict = [result objectAtIndex:0];
				// get identifier col
				identifier = [dict objectForKey:@"identifier"];
			} else {
				CocoLog(LEVEL_WARN,@"incorrect number of results!");
			}
		}
	}
	
	return identifier;
}

- (int)gpReg {
	int gpreg = 0;
	
	// sql statement
	NSString *sql = [NSString stringWithFormat:@"select gpreg from element where id=%d;",elementid];
	
	// execute sql
	NSArray *result = [dbConnection executeQuery:sql];
	if([dbConnection errorCode] != DB_SUCCESS) {
		NSString *errMsg = [dbConnection errorMessage];
		if(errMsg != nil) {
			CocoLog(LEVEL_ERR, @"%@", errMsg);
		}
	} else {
		// check for result
		if(result == nil) {
			CocoLog(LEVEL_WARN,@"have nil result from query!");
		} else {
			// read gpreg from dict
			// this should only be one entry
			if([result count] == 1) {
				NSDictionary *dict = [result objectAtIndex:0];
				// get gpreg col
				gpreg = [[dict objectForKey:@"gpreg"] intValue];
			} else {
				CocoLog(LEVEL_WARN,@"incorrect number of results!");
			}
		}
	}
	
	return gpreg;	
}

- (int)parentid {
	int parentid = -1;
	
	// sql statement
	NSString *sql = [NSString stringWithFormat:@"select parentid from element where id=%d;",elementid];
	
	// execute sql
	NSArray *result = [dbConnection executeQuery:sql];
	if([dbConnection errorCode] != DB_SUCCESS) {
		NSString *errMsg = [dbConnection errorMessage];
		if(errMsg != nil) {
			CocoLog(LEVEL_ERR, @"%@", errMsg);
		}
	} else {
		// check for result
		if(result == nil) {
			CocoLog(LEVEL_WARN,@"have nil result from query!");
		} else {
			// read parentid from dict
			// this should only be one entry
			if([result count] == 1)
			{
				NSDictionary *dict = [result objectAtIndex:0];
				// get parentid col
				parentid = [[dict objectForKey:@"parentid"] intValue];
			} else {
				CocoLog(LEVEL_WARN,@"incorrect number of results!");
			}
		}
	}
	
	return parentid;
}

#pragma mark - Management

/**
 Returns the number of children of this element.
 @param[in] aIdentifier return the number of children that have this identifier, nil for no identifier comparison
 @param[in] complete (YES/NO) returns the number of children in the complete subtree
*/
- (int)numberOfChildrenWithIdentifier:(NSString *)aIdentifier inWholeSubtree:(BOOL)complete
{
	int count = -1;
	
	// sql statement
	NSString *sql = nil;
	if(aIdentifier == nil) {
		if(complete) {
			sql = [NSString stringWithFormat:@"select count(*) from element where treeinfo like (select treeinfo from element where id=%d)||'%@';",
				elementid,
				@".%"];
		} else {
			sql = [NSString stringWithFormat:@"select count(*) from element where parentid=%d;",elementid];
		}
	} else {
		if(complete) {
			sql = [NSString stringWithFormat:@"select count(*) from element where treeinfo like (select treeinfo from element where id=%d)||'%@' AND identifier like '%@';",
				elementid,
				@".%",
				aIdentifier];
		} else {
			sql = [NSString stringWithFormat:@"select count(*) from element where parentid=%d AND identifier like '%@';",
				elementid,
				aIdentifier];
		}
	}
	
	// execute sql
	NSArray *result = [dbConnection executeQuery:sql];
	if([dbConnection errorCode] != DB_SUCCESS) {
		NSString *errMsg = [dbConnection errorMessage];
		if(errMsg != nil) {
			CocoLog(LEVEL_ERR, @"%@", errMsg);
		}
	} else {
		// check for result
		if(result == nil) {
			CocoLog(LEVEL_WARN,@"have nil result from query!");
		} else {
			// read count from dict
			// this should only be one entry
			if([result count] == 1) {
				ResultRow *row = [result objectAtIndex:0];
				// get count col
				count = [[[row findColumnForName:@"count(*)"] value] intValue];
			} else {
				CocoLog(LEVEL_WARN,@"incorrect number of results!");
			}
		}
	}
	
	return count;	
}

/**
 Returns the number of children of this element.
 @param[in] aIdentifier returns the number of children that have this identifier, nil for no identifier comparison
 @param[in] complete (YES/NO) returns the number of children in the complete subtree
 */
- (int)numberOfValuesWithIdentifier:(NSString *)aIdentifier inWholeSubtree:(BOOL)complete
{
	int count = -1;
	
	/*
	// sql statement
	NSString *sql = nil;
	if(aIdentifier == nil)
	{
		if(complete == YES)
		{
			sql = [NSString stringWithFormat:@"select count(*) from elementvalue where elementid=%d;",
				elementid];
		}
		else
		{
			sql = [NSString stringWithFormat:@"select count(*) from element where treeinfo like (select treeinfo from element where id=%d)||'._';",
				elementid];
		}
	}
	else
	{
		if(complete == YES)
		{
			sql = [NSString stringWithFormat:@"select count(*) from element where treeinfo like (select treeinfo from element where id=%d)||'.%' where identifier='%@';",
				elementid,aIdentifier];
		}
		else
		{
			sql = [NSString stringWithFormat:@"select count(*) from element where treeinfo like (select treeinfo from element where id=%d)||'._' where identifier='%@';",
				elementid,aIdentifier];
		}
	}
	
	// execute sql
	NSArray *result = [dbConnection executeQuery:sql];
	if([dbConnection errorCode] != DB_SUCCESS)
	{
		NSString *errMsg = [dbConnection errorMessage];
		if(errMsg != nil)
		{
			CocoLog(LEVEL_ERR,errMsg);
		}
	}
	else
	{
		// check for result
		if(result == nil)
		{
			CocoLog(LEVEL_WARN,@"[MBDBSqliteElement -numberOfChildrenWithIdentifier:inWholeSubtree:] have nil result from query!");
		}
		else
		{
			// read valuedata from dict
			// this should only be one entry
			if([result count] == 1)
			{
				NSDictionary *dict = [result objectAtIndex:0];
				// get valueid col
				count = [[dict objectForKey:@"count(*)"] intValue];
			}
			else
			{
				CocoLog(LEVEL_WARN,@"[MBDBSqliteElement -numberOfChildrenWithIdentifier:inWholeSubtree:] incorrect number of results!");				
			}
		}
	}
	 */
	
	return count;	
}

/**
 Currently elements are put into the trashcan on delete.
 if the trashacn is emptied, this method will be called on all items
 */
- (void)delete {
	// first delete all elementvalues first
	NSString *sql = [NSString stringWithFormat:@"delete from element where id=%d;",elementid];
	
	// execute sql
	[dbConnection executeSql:sql];
	if([dbConnection errorCode] != DB_SUCCESS) {
		NSString *errMsg = [dbConnection errorMessage];
		if(errMsg != nil) {
			CocoLog(LEVEL_ERR, @"%@", errMsg);
		}		
	}	
}

@end
