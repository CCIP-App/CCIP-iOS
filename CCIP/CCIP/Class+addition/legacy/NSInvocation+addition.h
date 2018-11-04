//
//  NSInvocation+addition.h
//  CCIP
//
//  Created by 腹黒い茶 on 2016/07/04.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSInvocation (addition)

+ (void)InvokeObject:(id)target withSelectorString:(NSString *)selector;
+ (void)InvokeObject:(id)target withSelectorString:(NSString *)selector withArguments:(NSArray *)args;

@end
