//
//  NSString+Collection.h
//  Collection
//
//  Created by Jordi Puigdellívol on 10/8/16.
//  Copyright © 2016 Revo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Collection)

+ (NSString*)repeat:(NSString*)text times:(int)times;
+ (BOOL)isEmptyString:(NSString*)string;

- (NSArray*)  explode:(NSString*)delimiter;
- (NSString*) initials;
- (NSNumber*) toNumber;
- (NSString*) append:(NSString*)append;
- (NSString*) prepend:(NSString*)prepend;
- (NSString*) substr:(int)from;
- (NSString*) substr:(int)from length:(int)length;

- (NSString*)replace:(NSString*)character with:(NSString*)replace;
- (NSString*)replaceRegexp:(NSString*)regexp with:(NSString*)replace;

- (NSArray*) split;
- (NSArray*) split:(int)splitLength;


/**
 Trims spaces on both ends
 */
- (NSString*) trim;

/**
 Trims spaces and new line characters on both ends
 */
- (NSString*) trimWithNewLine;

- (NSString*) trimLeft;
- (NSString*) trimRight;

/**
 * Converts @"this text" to @"thisText" or @"a_text" to @"aText"
 */
- (NSString *)camelCase;

/**
 * Converts @"this text" to @"ThisText" or @"a_text" to @"AText"
 */
- (NSString *)pascalCase;

/** 
 Converts @"fooBar" to @"foo_bar"
 */
- (NSString *)snakeCase;

/** 
 * Capitalizes first letter
 */
- (NSString *)ucFirst;

/**
 * Lowercases first letter
 */
- (NSString *)lcFirst;

- (NSString*)withoutDiacritic;

- (NSString*) urlEncode;
- (NSString*) urlDecode;
- (NSString*) md5;
- (NSString*) toBase64;
//+ (NSString*) fromBase64;
+ (NSString*) fromHex:(NSString *)str;
- (NSString*) toHex;

-(BOOL)endsWith:    (NSString*)compare;
-(BOOL)startsWith:  (NSString*)compare;
-(BOOL)contains:    (NSString*)compare;
-(BOOL)matches:     (NSString*)regexp;

-(NSString*)lpad:(int)lenght string:(NSString*)string;
-(NSString*)rpad:(int)lenght string:(NSString*)string;
@end
