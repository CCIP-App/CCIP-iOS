//
//  NSArray+Collection.h
//  revo-retail
//
//  Created by Badchoice on 25/5/16.
//  Copyright © 2016 Revo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Collection)

/**
 * @return NSArray with only the elements that pass the truth test
 */
- (NSArray*)filter:(BOOL (^)(id object))condition;

/**
 * @return NSArray with only the elements that keypath is true
 */
- (NSArray*)filterWith:(NSString*)keypath;

/**
 * @return NSArray removing the elements that pass the truth test
 */
- (NSArray*)reject:(BOOL (^)(id object))condition;

/**
 * @return NSArray without the elements that keypath is true
 */
- (NSArray*)rejectWith:(NSString*)keypath;

/**
 * @return id first object that passes the truth test or `nil` if any
 */
- (id)first:(BOOL (^)(id object))condition;

/**
 * @return id first object that passes the truth test or `defaultObject` if any passes
 */
- (id)first:(BOOL (^)(id object))condition default:(id)defaultObject;

/**
 * @return id last object that passes the truth test or `nil` if any
 */
- (id)last:(BOOL (^)(id))condition;

/**
 * @return id last object that passes the truth test or `defaultObject` if any passes
 */
- (id)last:(BOOL (^)(id object))condition default:(id)defaultObject;

/**
 * @return BOOL if any object passes the truth test
 */
- (BOOL)contains:(BOOL (^)(id object))checker;

/**
 * @return BOOL if no object passes the truth test
 */
- (BOOL)doesntContain:(BOOL (^)(id object))checker;

/**
 * @return NSArray elements where the keypath contains the value
 */
- (NSArray*)where:(NSString*)keypath like:(id)value;

/**
 * @return NSArray elements where the keypath is equal to the value
 */
- (NSArray*)where:(NSString*)keypath is:(id)value;

/**
 * @return NSArray elements where any of the keypaths is equal to the value
 */
- (NSArray*)whereAny:(NSArray*)keyPaths is:(id)value;

/**
 * @return NSArray elements where any of the keypaths is like the value
 */
- (NSArray*)whereAny:(NSArray*)keyPaths like:(id)value;

- (NSArray*)whereNull;
- (NSArray*)whereNull:(NSString*)keyPath;
- (NSArray*)whereNotNull;
- (NSArray*)whereNotNull:(NSString*)keyPath;


/**
 * performs the operation to each element
 */
- (void)each:(void(^)(id object))operation;

/**
 * performs the operation to each element
 */
- (void)eachWithIndex:(void(^)(id object, int index, BOOL *stop))operation;


/**
 * @return NSArray sorted using `compare` function of the elements
 */
- (NSArray*)sort;

/**
 * @return NSArray sorted ascending by the key values
 */
- (NSArray*)sort:(NSString*)key;

/**
 * @return NSArray sorted by the key values
 */
- (NSArray*)sort:(NSString*)key ascending:(BOOL)ascending;

/**
 * @return NSArray sorted using custom callback
 */
- (NSArray*)sortWith:(NSComparisonResult (^)(id a, id b))callback;

/**
 * @return NSArray sorted by key value, but leaving the nil values at the end
 */
- (NSArray*)sortWithNilAtTheEnd:(NSString *)key ascending:(BOOL)ascending;
    
/**
 * @return NSArray reverted
 */
- (NSArray*)reverse;

/**
 * @return NSArray starting at howMany position
 */
- (NSArray*)slice   :(int)howMany;

/**
 * @return NSArray from [0 , howMany], if howMany is negative it returns [count - howMany , count]
 */
- (NSArray*)take    :(int)howMany;

/**
 * @return NSArray from [0 , howMany] and removes them from current array
 */
- (NSArray*)splice  :(int)howMany;

/**
 * @return first object and removes it from current array
 */
- (NSString *)pop;

/**
 * @return new NSArray from the result of the block performed to each element
 */
- (NSArray*)map:(id (^)(id obj, NSUInteger idx))block;

/**
 * @return new NSArray by flatting it and performing a map to each element
 */
- (NSArray*)flatMap:(id (^)(id obj, NSUInteger idx))block;

/**
 * @return new NSArray by flatting it with the key and performing a map to each element
 */
- (NSArray*)flatMap:(NSString*)key block:(id (^)(id obj, NSUInteger idx))block;

/**
 * @return NSArray of all element.keyPath
 */
- (NSArray*)pluck:(NSString*)keyPath;

/**
 * @return NSDictionary of all element.keyPath with the key
 */
- (NSDictionary*)pluck:(NSString*)keyPath key:(NSString*)keyKeypath;

/**
 * @return NSArray removes one level of arrays so [[1,2,3],[4,5,6]] becomes [1,2,3,4,5,6]
 */
- (NSArray*)flatten;

/**
 * @return NSArray removes one level with key so [{"hola" => [1,2]},{"hola"=>[3,4]}] becomes [1,2,3,4]
 */
- (NSArray*)flatten:(NSString*)keypath;

/**
 * @return reduces the array to a single value, passing the result of each iteration into the subsequent iteration
 * initial carry value is `nil`
 */
- (id)reduce:(id(^)(id carry, id object))block;

/**
 * @return reduces the array to a single value, passing the result of each iteration into the subsequent iteration
 * initial carry value is `carry`
 */
- (id)reduce:(id(^)(id carry, id object))block carry:(id)carry;

/**
 * Final collection is run through the transformer
 * and then the output of that is returned
 */
- (id)pipe:(id (^)(NSArray* array))block;

/**
 * If condition is true, the collection is run throught block and is result is returned
 * if condition is false, it is ignored, and self is returned
 */
- (id)when:(BOOL)condition block:(id (^)(NSArray* array))block;

/**
 * returns NSDictionary by grouping the array items by a given key:
 */
- (NSDictionary*)groupBy:(NSString*)keypath;

/**
 * returns NSDictionary by grouping the array items by a given key where the new diciontary key is the result of block:
 */
- (NSDictionary*)groupBy:(NSString*)keypath block:(NSString*(^)(id object, NSString* key))block;

/**
 * return NSDictionary copping to keypath all the elements of the keypath so
 *   [
 *       {"groups" => [1,2]   },
 *       {"groups" => [2,3,3] }
 *   ]
 *   becomes
 *   {
 *       1 => [
 *           {"groups" => [1,2]}
 *       ]
 *       2 => [
 *           {"groups" => [1,2]},
 *           {"groups" => [2,3,3]}
 *       ]
 *       3 => [
 *           {"groups" => [2,3,3]}
 *           {"groups" => [2,3,3]}
 *       ]
 *   }
 */
- (NSDictionary*)expand:(NSString*)keypath;

/**
 * return same as expand but with uniques test so dictionary doesn't have duplicated values
 */
- (NSDictionary*)expand:(NSString *)keypath unique:(BOOL)unique;

/**
 * Returns the greatests element in the array
 */
-(id)maxObject;

/**
 * Returns the greatests element.keypath in the array
 */
-(id)maxObject:(NSString*)keypath;

/**
 * Returns the minimum block(element) in the array
 */
-(id)maxObjectFor:(double(^)(id obj))block;

/**
 * Returns the greatests element in the array
 */
-(id)minObject;

/**
 * Returns the minimum element.keypath in the array
 */
-(id)minObject:(NSString*)keypath;

/**
 * Returns the minimum block(element) in the array
 */
-(id)minObjectFor:(double(^)(id obj))block;

/**
 * Returns a random object from within the array
 */
-(id)random;

/**
 * Returns an array of `quantity` number of object from the array
 */
-(NSArray*)random:(int)quantity;

/**
 * Returns the same array with the items sorted randomly
 */
-(NSArray*)shuffled;

/**
 * Returns an array of all permutations
 */
-(NSArray*)permutations;

/**
 *zip lets you take one collection, and pair every element in that collection with the
 *corresponding element in another collection.*/
-(NSArray*)zip:(NSArray*)other;

/**
 * Associates 
 */
-(NSDictionary*)mapToAssoc:(NSArray*(^)(id obj, NSUInteger idx))block;

/**
 * Convenience method for creating the counted set
 */
-(NSCountedSet*)countedSet;

/** 
 * Returns an string concatedated with delimiter
 */
-(NSString*)implode:(NSString*)delimiter;

/**
 * Adds or removes the object depending if it is in the array
 * @param object the object to toggle
 */
-(void)toggleObject:(id)object;

/**
 * Converts the array into json string
 * of type [1,2,3]
 */
-(NSString*)toString;

/** 
 * Converts the array to json string
 */
-(NSString*)toJson;

#pragma mark - Operators
- (NSArray*)intersect:(NSArray*)b;
- (NSArray*)union:(NSArray*)b;
- (NSArray*)join:(NSArray*)b;
- (NSArray*)diff:(NSArray*)b;
- (NSArray*)minus:(NSArray*)b;
- (NSArray*)distinct;
- (NSArray*)distinct:(NSString*)keypath;
- (NSArray*)minusExactOcurrences:(NSArray*)b;

+ (NSArray *)range:(int)to;

/**
 * @param from the starting number
 * @param to the final number
 * @return an array [@from, ...., @to]
 */
+ (NSArray *)range:(int)from to:(int)to;

/**
 * @param from the starting number
 * @param to the final number
 * @param step the step for each jump
 * @return an array [@from, ...., @to]
 */
+ (NSArray *)range:(int)from to:(int)to step:(int)step;

/**
 * Creates a new array with times value
 * @param times the value should be added
 * @param value the value to be added
 */
+ (NSArray *)times:(int)times value:(id)value;

/**
 * Creates a new array with times value
 * @param times the value should be added
 * @param callback the callback the result will be added
 */
+ (NSArray *)times_:(int)times callback:(id (^)(int number))callback;

/**
 * Returns all the combinations with all array items
 */
- (NSArray*)crossJoin:(NSArray*)list;
+ (NSArray*)cartesianProduct:(NSArray*)arrays; //used by the cross join

#pragma mark - Set Operators
- (NSNumber*)sum;
- (NSNumber*)sum:(NSString*)keypath;
- (NSNumber*)sumWith:(NSNumber*(^)(id object))block;
- (NSNumber*)avg;
- (NSNumber*)avg:(NSString*)keypath;
- (NSNumber*)max;
- (NSNumber*)max:(NSString*)keypath;
- (NSNumber*)min;
- (NSNumber*)min:(NSString*)keypath;
- (NSUInteger)countKeyPath:(NSString*)keypath;

typedef void(^tapBlock)(id object);
id tap(id theObject, tapBlock theBlock);

@end
