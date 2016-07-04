//
//  NSInvocation+addition.m
//  CCIP
//
//  Created by 腹黒い茶 on 2016/07/04.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "NSInvocation+addition.h"

@implementation NSInvocation (addition)

+ (void)InvokeObject:(id)target withSelectorString:(NSString *)selector {
    [self InvokeObject:target
    withSelectorString:selector
         withArguments:nil];
}

+ (void)InvokeObject:(id)target withSelectorString:(NSString *)selector withArguments:(NSArray *)args {
    SEL sel = NSSelectorFromString(selector);
    NSString *assertMsg = [NSString stringWithFormat:@"I cannot found the target selector! Are sure calling [%@ %@] is correct as you want?", [[target class] description], selector];
    NSAssert([target respondsToSelector:sel], assertMsg);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:sel]];
    [invocation setTarget:target];
    [invocation setSelector:sel];
    int i = 0;
    for (id arg in args) {
        id a = arg;
        [invocation setArgument:&a
                        atIndex:2 + i++];
    }
    [invocation invoke];
}

@end
