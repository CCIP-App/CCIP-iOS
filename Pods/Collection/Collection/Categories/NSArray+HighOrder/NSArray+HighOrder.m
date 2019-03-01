//
//  NSArray+HighOrder.m
//  Collection
//
//  Created by Badchoice on 10/10/17.
//  Copyright © 2017 Revo. All rights reserved.
//

#import "NSArray+HighOrder.h"

@implementation NSArray (HighOrder)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

-(NSArray*)map_:(SEL)selector{
    return [self map:^id(id obj, NSUInteger idx) {
        return [obj performSelector:selector];
    }];
}

-(NSArray*)map_:(SEL)selector withObject:(id)object{
    return [self map:^id(id obj, NSUInteger idx) {
        return [obj performSelector:selector withObject:object];
    }];
}

-(void)each_:(SEL)selector{
    [self each:^(id object) {
        [object performSelector:selector];
    }];
}

-(void)each_:(SEL)selector withObject:(id)object{
    [self each:^(id object) {
        [object performSelector:selector withObject:object];
    }];
}

-(NSArray*)filter_:(SEL)selector{
    return [self filter:^BOOL(id object) {
        return (BOOL)[object performSelector:selector];
    }];
}

-(NSArray*)filter_:(SEL)selector withObject:(id)object{
    return [self filter:^BOOL(id obj) {
        return (BOOL)[obj performSelector:selector withObject:object];
    }];
}

-(NSArray*)reject_:(SEL)selector{
    return [self reject:^BOOL(id object) {
        return (BOOL)[object performSelector:selector];
    }];
}

-(NSArray*)reject_:(SEL)selector withObject:(id)object{
    return [self reject:^BOOL(id obj) {
        return (BOOL)[obj performSelector:selector withObject:object];
    }];
}

#pragma clang diagnostic pop
@end
