//
//  DeepCopy.h
//
//  Created by FrankWu
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

// Deep -copy and -mutableCopy methods for NSArray and NSDictionary

@interface NSArray (DeepCopy)

- (NSArray*) deepCopy;
- (NSMutableArray*) mutableDeepCopy;

@end

@interface NSDictionary (DeepCopy)

- (NSDictionary*) deepCopy;
- (NSMutableDictionary*) mutableDeepCopy;

@end