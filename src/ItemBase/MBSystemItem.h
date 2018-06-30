//
//  MBSystemItem.h
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 26.08.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>
#import "MBItem.h"

@class MBElement;

@interface MBSystemItem : MBItem  {

}

- (id)init;
- (id)initWithDb;
- (id)initWithInitializedElement:(MBElement *)aElem;

@end
