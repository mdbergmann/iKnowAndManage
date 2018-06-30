//
//  ElementBaseTest.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 19.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ElementBaseTest.h"
#import "MBElementBaseController.h"
#import "MBDBAccess.h"
#import "MBDBSqlite.h"
#import "MBElement.h"
#import "MBElementValue.h"
#import "MBBaseDefinitions.h"

@implementation ElementBaseTest

- (void)setUp {
    
    // create folder in tmp which we use
    NSFileManager *fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:@"/tmp/iKnowAndManageTest"]) {
        // delete
        [fm removeFileAtPath:@"/tmp/iKnowAndManageTest" handler:nil];
    }
    // create folder
    [fm createDirectoryAtPath:@"/tmp/iKnowAndManageTest" attributes:nil];
    
    @try {
        // setup db access instance
        MBDBSqlite *dbAccess = [MBDBSqlite dbConnectionWithPath:@"/tmp/iKnowAndManageTest/db"];
        // make it default
        [MBDBSqlite setSharedConnection:dbAccess];
        // check tables
        if([dbAccess checkAndCreateDBTables] == DB_SUCCESS) {
            // set up element base instance
            elemBase = [MBElementBaseController standardController];
            // set doc storage type and path
            [elemBase setDocStorageType:DocStorageFS];
            [elemBase setDocStoragePath:@"/tmp/iKnowAndManageTest/DocStorage"];
            // build up element base
            [elemBase buildElementBase];            
        }        
    }
    @catch(NSException *e) {
        NSLog(@"Exception: %@", [e reason]);
    }
}

- (void)tearDown {
}

- (void)testCreateElement {
    MBElement *elem = [[MBElement alloc] initWithDbAndIdentifier:@"myidentifier"];
    STAssertNotNil(elem, @"Created element is nil");
    STAssertEqualObjects(@"myidentifier", [elem identifier], @"Identifier do not match");
    
    int rootLen = [[elemBase rootElementList] count];
    [elemBase addElementToRootList:elem];
    [elem release];
    STAssertEquals(rootLen + 1, [[elemBase rootElementList] count], @"root item length does not match!");
}

@end
