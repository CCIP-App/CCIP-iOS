//
//  NSArray+Collection.m
//  revo-retail
//
//  Created by Badchoice on 25/5/16.
//  Copyright © 2016 Revo. All rights reserved.
//

#import "NSArray+Collection.h"
#import "NSString+Collection.h"

@implementation NSArray (Collection)

- (NSArray*)filter:(BOOL (^)(id object))condition{
    return [self filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return condition(evaluatedObject);
    }]];
}

- (NSArray*)reject:(BOOL (^)(id object))condition{
    return [self filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return !condition(evaluatedObject);
    }]];
}

-(NSArray*)filterWith:(NSString *)keypath{
    return [self filter:^BOOL(id object) {
        return [[object valueForKeyPath:keypath] boolValue];
    }];
}

-(NSArray*)rejectWith:(NSString *)keypath{
    return [self reject:^BOOL(id object) {
        return [[object valueForKeyPath:keypath] boolValue];
    }];
}

- (id)first:(BOOL (^)(id object))condition{
    NSUInteger index = [self indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return condition(obj);
    }];
    
    return (index == NSNotFound) ? nil : self[index];
}


- (id)first:(BOOL (^)(id object))condition default:(id)defaultObject{
    id object = [self first:condition];
    return (object) ? object : defaultObject;
}

- (id)first:(BOOL (^)(id object))condition defaultBlock:(id(^)(void))defaultBlock{
    id object = [self first:condition];
    return (object) ? object : defaultBlock();
}

- (id)last:(BOOL (^)(id))condition{
    return [self.reverse first:condition];
}

- (id)last:(BOOL (^)(id object))condition default:(id)defaultObject{
    id object = [self last:condition];
    return (object) ? object : defaultObject;
}

-(BOOL)contains:(BOOL (^)(id object))checker{
    bool __block found = false;
    [self eachWithIndex:^(id object, int index, BOOL *stop) {
        if (checker(object)){
            found = true;
            *stop = true;
        }
    }];
    return found;
}

-(BOOL)doesntContain:(BOOL (^)(id object))checker{
    bool __block found = false;
    [self eachWithIndex:^(id object, int index, BOOL *stop) {
        if (checker(object)){
            found = true;
            *stop = true;
        }
    }];
    return ! found;
}

- (NSArray*)where:(NSString*)keypath like:(id)value{
    return [self whereAny:@[keypath] like:value];
}

- (NSArray*)where:(NSString*)keypath is:(id)value{
    return [self whereAny:@[keypath] is:value];
}

- (NSArray*)where:(NSString*)keypath isNot:(id)value{
    NSPredicate* predicate      = [NSPredicate predicateWithFormat:@"%K <> %@",keypath, value];
    return [self filteredArrayUsingPredicate:predicate];
}

- (NSArray*)whereAny:(NSArray*)keyPaths is:(id)value{
    NSMutableArray* predicates = [NSMutableArray new];
    
    [keyPaths each:^(NSString* keypath) {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K = %@",keypath,value];
        [predicates addObject:predicate];
    }];
    
    NSPredicate *resultPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicates];
    return [self filteredArrayUsingPredicate:resultPredicate];
}

- (NSArray*)whereAny:(NSArray*)keyPaths like:(id)value{
    NSMutableArray* orPredicates = [NSMutableArray new];
    
    [keyPaths each:^(NSString* keypath) {
        NSMutableArray* andPredicates = [NSMutableArray new];
        NSArray *terms = [value componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [terms each:^(NSString* term) {
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K contains[cd] %@",keypath,term];
            [andPredicates addObject:predicate];
        }];
        [orPredicates addObject:[NSCompoundPredicate andPredicateWithSubpredicates:andPredicates]];
    }];
    
    NSPredicate *resultPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:orPredicates];
    return [self filteredArrayUsingPredicate:resultPredicate];
}

- (NSArray*)whereIn:(NSString*)keyPath values:(id)values{
    return [self filter:^BOOL(id object) {
        return [values containsObject:[object valueForKeyPath:keyPath]];
    }];
}

- (NSArray*)whereNull{
    return [self filter:^BOOL(id object) {
        return [object isEqual:NSNull.null];
    }];
}

- (NSArray*)whereNull:(NSString*)keyPath{
    return [self filter:^BOOL(id object) {
        id value = [object valueForKeyPath:keyPath];
        return value == nil || [[object valueForKeyPath:keyPath] isEqual:NSNull.null];
    }];
}
- (NSArray*)whereNotNull{
    return [self filter:^BOOL(id object) {
        return ![object isEqual:NSNull.null];
    }];
}

- (NSArray*)whereNotNull:(NSString*)keyPath{
    return [self filter:^BOOL(id object) {
        id value = [object valueForKeyPath:keyPath];
        return value != nil && ![[object valueForKeyPath:keyPath] isEqual:NSNull.null] ;
    }];
}

- (void)each:(void(^)(id object))operation{
    [self enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        operation(object);
    }];
}

- (void)eachWithIndex:(void(^)(id object, int index, BOOL *stop))operation{
    [self enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        operation(object, (int)idx, stop);
    }];
}

-(NSArray*)sort{
    return [self sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        return [a compare:b];
    }];
}

- (NSArray*)sort:(NSString*)key{
    return [self sort:key ascending:YES];
}

- (NSArray*)sort:(NSString*)key ascending:(BOOL)ascending{
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:key ascending:ascending];
    return [self sortedArrayUsingDescriptors:@[sortDescriptor]];
}

- (NSArray*)sortWith:(NSComparisonResult (^)(id a, id b))callback{
    return [self sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        return callback(a,b);
    }];
}

- (NSArray*)sortWithNilAtTheEnd:(NSString *)key ascending:(BOOL)ascending{
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:key
                                                                     ascending:!ascending
                                                                    comparator:^NSComparisonResult(id obj1, id obj2)  {
                                                                        return [obj2 compare:obj1];
                                                                    }];
    
    return [self sortedArrayUsingDescriptors:@[sortDescriptor]];
}

- (NSArray*)reverse{
    return [[self reverseObjectEnumerator] allObjects];
}

- (NSArray*)slice:(int)howMany{
    if(howMany > self.count) return @[];
    return  [self subarrayWithRange:NSMakeRange(howMany, self.count - howMany)];
}

-(NSArray*)take:(int)howMany{
    if(howMany > 0)
        return  [self subarrayWithRange:NSMakeRange(0, MIN(howMany,self.count))];
    else
        return  [self subarrayWithRange:NSMakeRange(MAX(0, (int)self.count + howMany), MIN(-howMany,self.count))];
}

-(NSArray*)splice:(int)howMany{
    if (![self isKindOfClass:NSMutableArray.class]){
        [NSException raise:@"Array is not mutable" format:@"Array needs to be mutable"];
    }
    NSArray* chunk = [self take:howMany];
    [(NSMutableArray*)self removeObjectsInRange:NSMakeRange(0, MIN(howMany, self.count))];
    return chunk;
}

-(NSString *) pop {
    return [self splice:1].firstObject;
}

- (NSArray *)map:(id (^)(id obj, NSUInteger idx))block {
    NSMutableArray* result = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id currentObject, NSUInteger index, BOOL *stop) {
        id mappedCurrentObject = block(currentObject, index);
        if (mappedCurrentObject) {
            [result addObject:mappedCurrentObject];
        }
    }];
    return result;
}

- (NSArray*)flatMap:(id (^)(id obj, NSUInteger idx))block{
    NSMutableArray* results = [NSMutableArray new];
    [self each:^(NSArray* array) {
        [results addObject:[array map:^id(id obj, NSUInteger idx) {
            return block(obj,idx);
        }]];
    }];
    return results;
}

- (NSArray*)flatMap:(NSString*)key block:(id (^)(id obj, NSUInteger idx))block{
    NSMutableArray* results = [NSMutableArray new];
    [self each:^(id object) {
        [results addObject:[[object valueForKey:key] map:^id(id obj, NSUInteger idx) {
            return block(obj,idx);
        }]];
    }];
    return results;
}

- (NSArray*)flatten{
    NSMutableArray* results = [NSMutableArray new];
    [self each:^(NSArray* array) {
        [results addObjectsFromArray:array];
    }];
    return results;
}

- (NSArray*)flatten:(NSString*)keypath{
    NSMutableArray* results = [NSMutableArray new];
    [self each:^(id object) {
        [results addObjectsFromArray:[object valueForKeyPath:keypath]];
    }];
    return results;
}

- (NSArray<NSMutableArray*>*)partition:(BOOL (^)(id obj))block{
    NSArray<NSMutableArray*>* result = @[NSMutableArray.new, NSMutableArray.new];
    [self each:^(id object) {
        block(object) ? [result.firstObject addObject:object] : [result.lastObject addObject:object];
    }];
    return result;
}

- (NSArray*)pluck:(NSString*)keyPath{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
    [self each:^(id object) {
        NSObject* value = [object valueForKeyPath:keyPath];
        if(value) [result addObject:[object valueForKeyPath:keyPath]];
    }];
    return result;
}

- (NSDictionary*)pluck:(NSString*)keyPath key:(NSString*)keyKeypath{
    NSMutableDictionary* result = [NSMutableDictionary dictionaryWithCapacity:self.count];
    [self each:^(id object) {
        result[[object valueForKey:keyKeypath]] = [object valueForKey:keyPath];
    }];
    return result;
}

- (id)reduce:(id(^)(id carry, id object))block carry:(id)carry{
    id __block carry2 = carry;
    [self each:^(id object) {
        carry2 = block(carry2,object);
    }];
    return carry2;
}

- (id)reduce:(id(^)(id carry, id object))block{
    return [self reduce:block carry:nil];
}

- (id)pipe:(id (^)(NSArray* array))block{
    return block(self);
}

- (id)when:(BOOL)condition block:(id (^)(NSArray* array))block{
    if(condition) return block(self);
    return self;
}

- (NSDictionary*)groupBy:(NSString*)keypath{
    return [self groupBy:keypath block:^NSString *(id object, NSString *key) {
        return key;
    }];
}

- (NSDictionary*)groupBy:(NSString*)keypath block:(NSString*(^)(id object, NSString* key))block{
    NSMutableDictionary *result = [NSMutableDictionary new];
    
    NSString* finalKeypath = [NSString stringWithFormat:@"%@.@distinctUnionOfObjects.self",keypath];
    NSArray *distinct = [self valueForKeyPath:finalKeypath];
    
    [distinct each:^(NSString* value) {
        NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"%K = %@", keypath,value];
        NSArray *objects        = [self filteredArrayUsingPredicate:predicate];
        [result setObject:objects forKey:block(objects[0],value)];
    }];
    
    //NSLog(@"%@", result);
    return result;
}

- (NSDictionary*)expand:(NSString*)keypath{
    return [self expand:keypath unique:NO];
}

- (NSDictionary*)expand:(NSString *)keypath unique:(BOOL)unique{
    if(unique) keypath = [NSString stringWithFormat:@"%@.@distinctUnionOfObjects.self",keypath];
    
    NSMutableDictionary* result = [NSMutableDictionary new];
    [self each:^(id object) {
        [[object valueForKeyPath:keypath] each:^(id key) {
            if(result[key] == nil) result[key] = [NSMutableArray new];
            [result[key] addObject:object];
        }];
    }];
    return result;
}

-(id)maxObject{
    return [self reduce:^id(id carry, id object) {
        return (object > carry ) ? object : carry;
    } carry:self.firstObject];
}

-(id)maxObject:(NSString *)keypath{
    return [self reduce:^id(id carry, id object) {
        return ([[object valueForKeyPath:keypath] doubleValue] > [[carry valueForKeyPath:keypath] doubleValue]) ? object : carry;
    } carry:self.firstObject];
}

-(id)maxObjectFor:(double(^)(id obj))block{
    return [self reduce:^id(id carry, id object) {
        return block(object) > block(carry) ? object : carry;
    } carry:self.firstObject];
}

-(id)minObject{
    return [self reduce:^id(id carry, id object) {
        return (object < carry ) ? object : carry;
    } carry:self.firstObject];
}

-(id)minObjectFor:(double(^)(id obj))block{
    return [self reduce:^id(id carry, id object) {
        return block(object) < block(carry) ? object : carry;
    } carry:self.firstObject];
}

-(id)minObject:(NSString *)keypath{
    return [self reduce:^id(id carry, id object) {
        return ([[object valueForKeyPath:keypath] doubleValue] < [[carry valueForKeyPath:keypath] doubleValue] ) ? object : carry;
    } carry:self.firstObject];
}

-(id)random{
    NSUInteger randomIndex = arc4random() % self.count;
    return self[randomIndex];
}

-(NSArray*)random:(int)quantity{
    return [self.shuffled take:quantity];
}

-(NSArray*)shuffled{
    NSMutableArray* copy = self.mutableCopy;
    for (NSUInteger i = self.count; i > 1; i--)
        [copy exchangeObjectAtIndex:i - 1 withObjectAtIndex:arc4random_uniform((u_int32_t)i)];
    
    return copy;
}

-(NSArray*)zip:(NSArray*)other{
    NSInteger size = MIN(self.count, other.count);
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:size];
    for (NSUInteger idx = 0; idx < size; idx++)
    {
        [result addObject:[NSArray arrayWithObjects:[self objectAtIndex:idx], [other objectAtIndex:idx], nil]];
    }
    
    return result;
}

-(NSDictionary*)mapToAssoc:(NSArray*(^)(id obj, NSUInteger idx))block{
    NSArray* pairs = [self map:block];
    
    return [pairs reduce:^id(NSMutableDictionary* dict, NSArray* mapped) {
        dict[mapped[0]] = mapped[1];
        return dict;
    } carry:[NSMutableDictionary new]];
}

-(NSCountedSet*)countedSet{
    return [NSCountedSet setWithArray:self];
}

-(NSString*)implode:(NSString*)delimiter{
    return [self componentsJoinedByString:delimiter];
}

-(NSString*)toString{
    NSString* exploded = [self implode:@","];
    return [NSString stringWithFormat:@"[%@]",exploded];
}

-(NSString*)toJson{
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:self options:0 error:&err];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
//==============================================
#pragma mark - Operators
//==============================================
- (NSNumber*)operator:(NSString*)operator keypath:(NSString*)keypath{
    NSString* finalKeyPath;
    if(keypath != nil)
        finalKeyPath = [NSString stringWithFormat:@"%@.@%@.self",keypath, operator];
    else
        finalKeyPath = [NSString stringWithFormat:@"@%@.self",operator];
    
    return [self valueForKeyPath:finalKeyPath];
}

- (NSNumber*)sum                    { return [self operator:@"sum" keypath:nil];    }
- (NSNumber*)sum:(NSString*)keypath { return [self operator:@"sum" keypath:keypath];}
- (NSNumber*)avg                    { return [self operator:@"avg" keypath:nil];    }
- (NSNumber*)avg:(NSString*)keypath { return [self operator:@"avg" keypath:keypath];}
- (NSNumber*)max                    { return [self operator:@"max" keypath:nil];    }
- (NSNumber*)max:(NSString*)keypath { return [self operator:@"max" keypath:keypath];}
- (NSNumber*)min                    { return [self operator:@"min" keypath:nil];    }
- (NSNumber*)min:(NSString*)keypath { return [self operator:@"min" keypath:keypath];}

- (NSUInteger)countKeyPath:(NSString*)keypath{
    return [self flatten:keypath].count;
}

- (NSNumber*)sumWith:(NSNumber*(^)(id object))block{
    return [self reduce:^id(NSNumber* carry, id object) {
        return @(carry.floatValue + block(object).floatValue);
    } carry:@(0)];
}

//==============================================
#pragma mark - Set operations
//==============================================
- (NSArray*)intersect:(NSArray*)b{
    NSMutableOrderedSet *setA = [NSMutableOrderedSet orderedSetWithArray:self];
    NSOrderedSet *setB        = [NSOrderedSet orderedSetWithArray:b];
    [setA intersectOrderedSet:setB];
    return [setA array];
}

- (NSArray*)union:(NSArray*)b{
    NSMutableOrderedSet *setA = [NSMutableOrderedSet orderedSetWithArray:self];
    NSOrderedSet *setB        = [NSOrderedSet orderedSetWithArray:b];
    [setA unionOrderedSet:setB];
    return [setA array];
}

- (NSArray*)minus:(NSArray*)b{
    NSMutableOrderedSet *setA = [NSMutableOrderedSet orderedSetWithArray:self];
    NSOrderedSet *setB        = [NSOrderedSet orderedSetWithArray:b];
    [setA minusOrderedSet:setB];
    return [setA array];
}

- (NSArray*)minusExactOcurrences:(NSArray*)b{
    NSMutableArray* result = self.mutableCopy;
    [b each:^(id object) {
        NSUInteger index = [result indexOfObject:object];
        if(index == NSNotFound) return;
        [result removeObjectAtIndex:index];
    }];
    return result;
}

-(NSArray*)diff:(NSArray*)b{
    return [self minus:b];
}

- (NSArray*)join:(NSArray*)b{
    return [self arrayByAddingObjectsFromArray:b];
}

- (NSArray*)distinct{
    NSOrderedSet *distinct = [NSOrderedSet orderedSetWithArray:self];
    return [distinct array];
}

- (NSArray*)distinct:(NSString*)keypath{
    NSString* finalKeypath = [NSString stringWithFormat:@"%@.@distinctUnionOfObjects.self",keypath];
    return [self valueForKeyPath:finalKeypath];
}

+ (NSArray*)range:(int)to{
    return [self range:0 to:to step:1];
}

+ (NSArray*)range:(int)from to:(int)to{
    return [self range:from to:to step:1];
}

+ (NSArray*)range:(int)from to:(int)to step:(int)step{
    NSMutableArray * result = NSMutableArray.new;
    for (int i = from; i <= to;  i = i + step){
        [result addObject:@(i)];
    }
    return result;
}

+ (NSArray *)times:(int)times value:(id)value{
    return [[self.class range:times-1] map:^id(id obj, NSUInteger idx) {
        return value;
    }];
}

+ (NSArray *)times_:(int)times callback:(id (^)(int number))callback{
    return [[self.class range:times-1] map:^id(NSNumber *number, NSUInteger idx) {
        return callback(number.intValue);
    }];
}

-(NSArray<NSArray*>*)chunk:(int)size{
    NSMutableArray * result = NSMutableArray.new;
    NSMutableArray * origin = self.mutableCopy;
    while (origin.count > 0) {
        [result addObject:[origin splice:size]];
    }
    return result;
}

-(NSArray*)crossJoin:(NSArray*)list{
    if([list.firstObject isKindOfClass:NSArray.class]){
        return [self.class cartesianProduct:[@[self] join:list]];
    }
    return [self.class cartesianProduct:@[self, list]];
}

+(NSArray*)cartesianProduct:(NSArray*)arrays{
    int arraysCount = (int)arrays.count;
    unsigned long resultSize = 1;
    for (NSArray *array in arrays)
        resultSize *= array.count;
    NSMutableArray *product = [NSMutableArray arrayWithCapacity:resultSize];
    for (unsigned long i = 0; i < resultSize; ++i) {
        NSMutableArray *cross = [NSMutableArray arrayWithCapacity:arraysCount];
        [product addObject:cross];
        unsigned long n = i;
        for (NSArray *array in arrays) {
            [cross addObject:[array objectAtIndex:n % array.count]];
            n /= array.count;
        }
    }
    return product;
}

-(NSArray*)permutations{
    NSMutableArray * permutations = [NSMutableArray new];
    
    for (NSObject *object in self){
        [permutations addObject:@[object]];
    }
    
    for (int i = 1; i < self.count ; i++){
        NSMutableArray *aCopy = permutations.copy;
        [permutations removeAllObjects];
        
        for (NSObject *object in self){
            for (NSArray *oldArray in aCopy){
                if ([oldArray containsObject:object] == NO){
                    NSMutableArray *newArray = [NSMutableArray arrayWithArray:oldArray];
                    [newArray addObject:object];
                    [permutations addObject:newArray];
                }
            }
        }        
    }
    return permutations;
}

-(void)toggleObject:(id)object{
    NSMutableArray* mutableArray = (NSMutableArray*)self;
    if ([self containsObject:object]) {
        [mutableArray removeObject:object];
    } else {
        [mutableArray addObject:object];
    }
}

id tap(id theObject, tapBlock theBlock){
    theBlock(theObject);
    return theObject;
}

@end
