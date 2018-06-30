//
//  ResultRow.h
//  SifSqlite
//
//  Created by Manfred Bergmann on 06.01.11.
//  Copyright 2011 Software by MABE. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class RowColumn;

/**
 Defines a row of a query result
 A row consists of a list of RowColumns
 */
@interface ResultRow : NSObject {
    NSMutableArray *columns;
}

- (void)addColumn:(RowColumn *)col;
- (RowColumn *)findColumnForName:(NSString *)colName;
- (NSArray *)rowColumns;

@end
