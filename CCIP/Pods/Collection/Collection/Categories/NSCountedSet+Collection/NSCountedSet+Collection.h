#import <Foundation/Foundation.h>

@interface NSCountedSet (Collection)

- (void)each:(void (^)(id object, NSUInteger count))operation;
- (NSArray *)map:(id (^)(id obj, NSUInteger count))block;
@end