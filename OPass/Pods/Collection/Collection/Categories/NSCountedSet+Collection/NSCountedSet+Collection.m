#import "NSCountedSet+Collection.h"

@implementation NSCountedSet (Collection)

- (void)each:(void(^)(id object, NSUInteger count))operation{
    [self enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        operation(obj, [self countForObject:obj]);
    }];
}

- (NSArray *)map:(id (^)(id obj, NSUInteger count))block {
    NSMutableArray* result = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        id mappedCurrentObject = block(obj, [self countForObject:obj]);
        if (mappedCurrentObject) {
            [result addObject:mappedCurrentObject];
        }
    }];
    return result;
}

@end