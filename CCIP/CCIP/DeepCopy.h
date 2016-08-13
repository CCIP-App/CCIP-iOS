//
//  DeepCopy.h
//
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