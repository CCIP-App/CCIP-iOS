#import <Foundation/Foundation.h>

@interface NSDictionary (Collection)

+ (NSDictionary*)fromData:(NSData*)data;
+ (NSDictionary*)fromString:(NSString*)string;
- (NSString*)toString;
- (NSString*)toJson;
- (NSDictionary*)except:(NSArray*)exceptKeys;
- (NSDictionary*)only:(NSArray*)keysToKeep;
- (NSDictionary*)merge:(NSDictionary*)toMerge;

- (void)each:(void(^)(id key, id object))operation;
- (NSDictionary*)filter:(BOOL (^)(id key, id object))condition;
- (NSDictionary*)reject:(BOOL (^)(id key, id object))condition;
- (NSDictionary*)map:(id (^)(id key, id object))callback;
@end
