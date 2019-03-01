#import "NSDictionary+Collection.h"
#import "NSArray+Collection.h"

@implementation NSDictionary (Collection)

//===================================
#pragma mark - Converters
//===================================
+(NSDictionary*)fromData:(NSData*)data{
    if(!data) return nil;
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    return json;
}

+(NSDictionary*)fromString:(NSString*)string{
    if( ! string || ! [string isKindOfClass:NSString.class]) return nil;    
    NSData* data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [self.class fromData:data];
}

-(NSString*)toString{
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&err];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

-(NSString*)toJson{
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:self options:0 error:&err];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (NSDictionary*)except:(NSArray*)exceptKeys{
    NSMutableDictionary* result = self.mutableCopy;
    [exceptKeys each:^(NSString* key) {
        [result removeObjectForKey:key];
    }];
    return result;
}

- (NSDictionary*)only:(NSArray*)keysToKeep{
    NSMutableDictionary* result = self.mutableCopy;
    [result.allKeys each:^(id key) {
        if( ! [keysToKeep containsObject:key] )
           [result removeObjectForKey:key];
    }];
    return result;
}

- (NSDictionary*)merge:(NSDictionary*)toMerge{
    NSMutableDictionary* temp = self.mutableCopy;
    [toMerge each:^(id key, id object) {
        temp[key] = object;
    }];
    return temp;
}

//===================================
#pragma mark - Collection
//===================================
- (void)each:(void(^)(id key, id object))operation{
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        operation(key, obj);
    }];
}

- (NSDictionary*)filter:(BOOL (^)(id key, id object))condition{
    
    NSSet *keys = [self keysOfEntriesPassingTest:^BOOL(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        return condition(key,obj);
    }];
    return [self dictionaryWithValuesForKeys:keys.allObjects];
}

- (NSDictionary*)reject:(BOOL (^)(id key, id object))condition{
    NSSet *keys = [self keysOfEntriesPassingTest:^BOOL(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        return ! condition(key,obj);
    }];
    return [self dictionaryWithValuesForKeys:keys.allObjects];
}

- (NSDictionary*)map:(id (^)(id key, id object))callback{
    NSMutableDictionary* newDictionary = [NSMutableDictionary new];
    [self each:^(id key, id object) {
        newDictionary[key] = callback(key,object);
    }];
    return newDictionary;
}
@end
