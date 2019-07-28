# NSArray+Collection

**Never write another loop again**   

This library is inspired by `Laravel` collection class to use its expressive syntax.
Check the .h file to see the documentation as well as all available methods.


## Installation
Copy the category files to your project or just

```ruby
pod 'Collection' 
```

## Array available methods

`each:block`
`eachWithIndex:blockWithIndex`
`map:block`
`flatMap:block`
`flatMap:key:block`

`filter:blockChecker` 
`filterWith:keyPath` 
`reject:blockChecker` 
`rejectWith:keyPath` 
`first:blockChecker` 
`first:blockChecker:default` 
`first:blockChecker:defaultBlock`
`last:blockChecker` 
`last:blockChecker:default` 
`contains:blockChecker` 
`doesntContain:blockChecker` 
`where:keyPath:like` 
`where:keyPath:is` 
`where:keyPath:isNot` 
`whereAny:keyPaths:like` 
`whereAny:keyPaths:is` 
`whereNull` 
`whereNull:keyPath` 
`whereNotNull`
`whereNotNull:keyPath` 
`whereIn:keyPath:values`

`sort`
`sort:key`
`sort:key:ascending`
`sortWith:block:ascending`

`reverse`
`random:quantity`
`slice:howMany`
`take:howMany`
`splice:howMany`
`pop`

`pluck:keyPath`
`pluck:keyPath:keyKeyPath`
`flatten`
`flatten:keyPath`
`partition:block`
`reduce:block`
`reduce:block:initialCarry`
`pipe:block`
`when:condition:block`
`groupBy:keyPath`
`gorupBy:keyPath:block`
`expand:keypath`

`maxObject`
`maxObject:keyPath`
`maxObjectFor:block`
`minObject`
`minObject:keyPath`
`minObjectFor:block`

`suffled`
`permutations`
`zip:other`
`mapToAssoc:block`
`countedSet`
`implode:glue`
`toString`
`toJson`

`intersect:other`
`union:other`
`join:other`
`diff:other`
`minus:other`
`minusExactOcurrences:other`
`distinct`
`distinct:keypath`

`range:to`
`range:from:to`

`times:times:value`
`times:times:callback`

`crossJoin:list`
`cartesianProduct:arrays`

`sum`
`sum:keyPath`
`sumWith:block`
`avg`
`avg:keyPath`
`max`
`max:keyPath`
`min`
`min:keyPath`
`countKeyPath:`

`map_:selector`
`map_:selector:withObject`
`each_:selector`
`each_:selector:withObject`
`filter_:selector`
`filter_:selector:withObject`
`reject_:selector`
`reject_:selector:withObject`

## Dictionary available methods
`fromData:data`
`fromString:string`
`toString`
`except:keys`
`only:keys`

`each:block`
`filter:block`
`filter:block`
`map:block`

## String available methods
`repeat:text:times`
`isEmptyString`
`explode:delimiter`
`initials`
`toNumber`
`append:other`
`prepend:other`
`substr:from`
`substr:from:length`
`replace:text:with`
`replaceRegexp:regexp:with`
`split`
`split:lenght`
`trim`
`trimWithNewLine`
`trimLeft`
`trimRight`
`camelCase`
`pascalCase`
`snakeCase`
`ucFirst`
`withoutDiacritic`
`urlEncode`
`urlDecode`
`md5`
`toBase64`
`fromHex:str`
`toHex`

`endsWith:text`
`startsWith:text`
`contains:text`
`matches:regexp`

`lpad:length:text`
`rpad:length:text`

## Array Examples

Just some examples, check the .h or the tests to see them all
In the .h there is the explanation of what it really does


```objc
NSArray* array = @[@1,@3,@4,@5,@6];
NSNumber* first = [array first:^BOOL(NSNumber* object) {
    return object.intValue > 4;
}];
NSLog(@"Fist: %@",first);
```

```objc
NSNumber* second = [array first:^BOOL(NSNumber* object) {
    return object.intValue > 10;
} default:@25];
NSLog(@"second: %@",second);
```

```objc
NSArray* oldHeroes = [self.heroes reject:^BOOL(Hero *object) {
    return object.age.intValue < 20;
}];
[self printHeroArray:oldHeroes];
```

```objc
[self printHeroArray:[self.heroes map:^id(Hero* obj, NSUInteger idx) {
    obj.age = @(obj.age.intValue * 2);
    return obj;
}]];
[self printArray:[self.heroes pluck:@"enemy"]];
```

```objc
NSNumber* totalAge = [self.heroes reduce:^id(NSNumber* carry, Hero* object) {
    return @(object.age.intValue + carry.intValue);
} carry:@(0)];

// or

NSNumber* totalAge2 = [self.heroes sum:@"age"];
```

```objc
NSNumber* age = [self.heroes sum:@"age"];
NSLog(@"Age again: %@",age);

NSNumber* older = [self.heroes max:@"age"];
NSLog(@"older: %@",older);

NSNumber* younger = [self.heroes min:@"age"];
NSLog(@"younger: %@",younger);

NSNumber* average = [self.heroes avg:@"age"];
NSLog(@"average: %@",average);
```

```objc
[self printArray:[@[@1,@2,@3,@4] union:@[@4,@5,@6]]];
[self printArray:[@[@1,@2,@3,@4] intersect:@[@4,@5,@6]]];
[self printArray:[@[@1,@2,@3,@4] join:@[@4,@5,@6]]];
[self printArray:[@[@1,@2,@3,@4] diff:@[@4,@5,@6]]];
```

```objc
[self.heroes groupBy:@"age"];

[self.heroes groupBy:@"age" block:^NSString *(Hero *object, NSString *key) {
    return str(@"age %@", object.age);
}];
```

```objc
NSArray* names = @["Spiderman", @"Batman", @"Robin", @"Luxor"];
BOOL containsSpiderman = [self.names contains:^BOOL(Hero* hero) {
    return [hero.name isEqualToString:@"Spiderman"];
}];

BOOL heroes = [self.names where:@"name" like:@"man"];
// heroes => [@"Spiderman, @"Batman"] 
```


```objc
[@[@1,@2,@3,@4,@5,@6] slice:3];
[@[@1,@2,@3,@4,@5,@6] slice:10];
[@[@1,@2,@3,@4,@5,@6] slice:6];
[@[@1,@2,@3,@4,@5,@6] take:2];
[@[@1,@2,@3,@4,@5,@6] take:10];
[@[@1,@2,@3,@4,@5,@6] take:-2];
[@[@1,@2,@3,@4,@5,@6] take:-10];
```

```objc
NSArray* array2 = @[@1,@2,@3,@4,@5].mutableCopy;
NSArray* chunk = [array2 splice:2];
[self printArray:chunk];
[self printArray:array2];
```

## Dictionary Examples

Just some examples, check the .h or the tests to see them all
    
```objc
NSDictionary* filtered = [@{@"pass":@0, @"dontPass":@1} filter:^BOOL(id key, id object) {
    return object.floatValue == 0;
}];
```

```objc
NSDictionary* result = [@{@"toBeMapped":@"value", @"toBeMapped2":@"value2"} map:^id(id key, id object) {
    return [key append:object];
}];
```

## String Examples

Just some examples, check the .h or the tests to see them all

```objc
// [NSString stringWithFormat:@"a formated %@ string", value]; 
// becomes
str(@"a formated %@ string", value);
```

```objc
NSArray* result         = [@"hola;que;tal" explode:@";"];
NSArray* expectation    = @[@"hola",@"que",@"tal"];
XCTAssertTrue([result isEqual:expectation]);
```

```objc
NSString* result = [@"   trim   " trim];
XCTAssertTrue( [result isEqualToString:@"trim"]);
```

```objc
NSString* result = @"this should be camelcased".camelCase;
XCTAssertTrue( [result isEqualToString:@"thisShouldBeCamelcased"]);
```
