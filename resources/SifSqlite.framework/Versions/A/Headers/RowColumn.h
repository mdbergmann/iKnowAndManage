//
//  RowColumn.h
//  SifSqlite
//
//  Created by Manfred Bergmann on 06.01.11.
//  Copyright 2011 Software by MABE. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 Defines a Column of a ResultRow of a query.
 RowColumn contains the column name and the value as NSString.
 */
@interface RowColumn : NSObject {
    NSString *name;
    NSString *value;
}

@property (retain, readwrite) NSString *name;
@property (retain, readwrite) NSString *value;

+ (RowColumn *)columnWithName:(NSString *)aName andValue:(NSString *)aValue;

@end
