//
//  MBApplication.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 20.06.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import "MBApplication.h"
#import "globals.h"

@implementation MBApplication

/**
\brief initialized logging, creates a ARP for logging
*/
- (void)initLogging
{
    @autoreleasepool {
        // get path to "Logs" folder of current user
        NSString *logPath = LOGFILE;
        
#ifdef DEBUG
        // init the logging facility in first place
        [CocoLogger initLogger:logPath
                   logPrefix:@"[iKnow&Manage]"
              logFilterLevel:LEVEL_DEBUG
                appendToFile:YES
                logToConsole:YES];
#endif
#ifdef RELEASE
        // init the logging facility in first place
        [CocoLogger initLogger:logPath
                   logPrefix:@"[iKnow&Manage]"
              logFilterLevel:LEVEL_WARN
                appendToFile:NO 
                logToConsole:NO];	
#endif
        CocoLog(LEVEL_DEBUG, @"initLogging: logging initialized");
    }
}

/**
\brief releases the created ARP
*/
- (void)deinitLogging {
}

@end
