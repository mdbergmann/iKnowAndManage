//
//  MBDBElementValue.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 06.07.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import "MBDBElementValue.h"

@implementation MBDBElementValue

- (id)init {
    self = [super init];
    if(self) {
		valueid = -1;
        valueDataSize = 0;
        gpReg = 0;
        siDocId = -1;
        delegate = nil;        
    }
    
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)setSiDocId:(int)aDocId {
    siDocId = aDocId;
}

- (int)siDocId {
    return siDocId;
}

- (void)setDelegate:(id)aDelegate {
    delegate = aDelegate;
}

- (id)delegate {
    return delegate;
}

@end
