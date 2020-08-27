//
//  NSInvocation+addition.h
//  OPass
//
//  Created by 腹黒い茶 on 2016/07/04.
//  2016 OPass.
//

#import <Foundation/Foundation.h>

@interface NSInvocation (addition)

+ (void)InvokeObject:(id)target withSelectorString:(NSString *)selector;
+ (void)InvokeObject:(id)target withSelectorString:(NSString *)selector withArguments:(NSArray *)args;

@end
