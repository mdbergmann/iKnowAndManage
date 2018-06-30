/*
 *  SingletonSyntesizer.h
 *  iKnowAndManage
 *
 *  Created by Manfred Bergmann on 15.08.09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#define SYNTHESIZE_SINGLETON_FOR_CLASS(classname) \
\
static classname *shared##classname = nil; \
\
+ (classname *)shared##classname { \
    @synchronized(self) { \
        if (shared##classname == nil) { \
            shared##classname = [[self alloc] init]; \
        } \
    } \
\
    return shared##classname; \
} \
\
+ (id)allocWithZone:(NSZone *)zone { \
    @synchronized(self) { \
        if (shared##classname == nil) { \
            shared##classname = [super allocWithZone:zone]; \
            return shared##classname; \
        } \
    } \
\
    return nil; \
} \
\
- (id)copyWithZone:(NSZone *)zone { \
    return self; \
} \
\
- (id)retain { \
    return self; \
} \
\
- (unsigned long)retainCount { \
    return ULONG_MAX; \
} \
\
- (void)release { \
} \
\
- (id)autorelease { \
    return self; \
}
