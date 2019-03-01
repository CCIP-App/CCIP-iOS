#import "NSString+Collection.h"
#import "NSArray+Collection.h"
#import <CommonCrypto/CommonDigest.h>

#define str(A,...)          [NSString stringWithFormat:A,##__VA_ARGS__]

@implementation NSString (Collection)


+(NSString*)repeat:(NSString*)text times:(int)times{
    if(times <= 0) return @"";
    NSMutableString* str = [NSMutableString string];
    for(int i = 0; i < times; i++){
        [str appendString:text];
    }
    return str;
}

+(BOOL)isEmptyString:(NSString*)string{
    if(string == nil) return true;
    if([string isKindOfClass:NSNull.class]) return true;
    if([string isEqualToString:@""]) return true;
    return false;
}

-(NSArray*)explode:(NSString*)delimiter{
    return [self componentsSeparatedByString:delimiter];
}

- (NSArray *)explodeWithSet:(NSCharacterSet *)characterSet {
    return [self componentsSeparatedByCharactersInSet:characterSet];
}

- (NSString*)initials{
    NSArray* components = [[self explode:@" "] reject:^BOOL(NSString* text) {
        return text.length == 0;
    }];

    if(components.count == 1) return [self substringToIndex:MIN(3,self.length)];
    
    return [[components take:3] reduce:^id(NSString* carry, NSString* component) {
        return [carry stringByAppendingString:[component substringToIndex:1]];
    } carry:@""];
}

-(NSNumber*)toNumber{
    return @([self stringByReplacingOccurrencesOfString:@"," withString:@"."].floatValue);
}

-(NSString*)append:(NSString*)append{
    return [self stringByAppendingString:append];
}

-(NSString*)prepend:(NSString*)prepend{
    return [prepend stringByAppendingString:self];
}

-(NSString*) substr:(int)from{
    if(from >=0) return [self substringFromIndex:MIN(from,(int)self.length)];
    else         return [self substringFromIndex:MAX((int)self.length + from, 0 )];
}

-(NSString*)substr:(int)from length:(int)length{
    if(from >=0){
        return [self substringWithRange:NSMakeRange(from, MIN(length,self.length))];
    }
    else{
        return [self substringWithRange:NSMakeRange(self.length + from,length)];
    }
}

-(NSString*)limit:(int)length{
    return [self substr:0 length:length];
}

-(NSString*)limit:(int)length ending:(NSString*)ending{
    if (self.length > length){
        if ( (int)(ending.length) >length) {
            return ending;
        }
        return [[self substr:0 length:(int)(length - ending.length)] append:ending];
    }
    return self.copy;
}

-(NSString*)trim{
    return [self trimWithSet:[NSCharacterSet whitespaceCharacterSet]];
}

-(NSString*)trimWithNewLine{
    return [self trimWithSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)trimWithSet:(NSCharacterSet *)characterSet {
    return [self stringByTrimmingCharactersInSet:characterSet];
}

-(NSString*)replace:(NSString*)character with:(NSString*)replace{
    return [self stringByReplacingOccurrencesOfString:character withString:replace];
}

- (NSString*)replaceRegexp:(NSString*)regexp with:(NSString*)replace{
    return [self stringByReplacingOccurrencesOfString:self withString:replace options:NSRegularExpressionSearch range:NSMakeRange(0, self.length)];
}

- (NSString *)replaceCharacterSet:(NSCharacterSet *)characterSet with:(NSString *)replace {
    return [[self explodeWithSet:characterSet] implode:replace];
}

- (NSArray*) split{
    return [self split:1];
}

- (NSArray*) split:(int)splitLength{
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < self.length; i = i+splitLength) {
        [array addObject: [self substr:i length:(int)MIN(splitLength, self.length - i)]];
    }
    return array;
}



- (NSString *)trimLeft{
    NSCharacterSet *characterSet = [NSCharacterSet whitespaceCharacterSet];
    NSUInteger location = 0;
    NSUInteger length = [self length];
    unichar charBuffer[length];
    [self getCharacters:charBuffer];
    
    for (location = 0; location < length; location++) {
        if (![characterSet characterIsMember:charBuffer[location]]) {
            break;
        }
    }
    
    return [self substringWithRange:NSMakeRange(location, length - location)];
}

- (NSString *)trimRight{
    NSCharacterSet *characterSet = [NSCharacterSet whitespaceCharacterSet];
    NSUInteger location = 0;
    NSUInteger length = 0;
    unichar charBuffer[length];
    [self getCharacters:charBuffer];
    
    for (length = self.length; length > 0; length--) {
        if (![characterSet characterIsMember:charBuffer[length - 1]]) {
            break;
        }
    }
    
    return [self substringWithRange:NSMakeRange(location, length - location)];
}

- (NSString *)camelCase{
    return self.pascalCase.lcFirst;
}

- (NSString *)pascalCase{
    NSString* withoutWhiteSpaces =  [[self explode:@" "] reduce:^id(NSString* carry, NSString* word) {
        return str(@"%@%@",carry,word.ucFirst);
    } carry:@""];
    
    return [[withoutWhiteSpaces explode:@"_"] reduce:^id(NSString* carry, NSString* word) {
        return str(@"%@%@",carry,word.ucFirst);
    } carry:@""];
}

-(NSString *)snakeCase{
    NSUInteger index = 1;
    NSMutableString *snakeCaseString = [NSMutableString stringWithString:self];
    NSUInteger length = snakeCaseString.length;
    NSMutableCharacterSet *characterSet = [NSCharacterSet uppercaseLetterCharacterSet].mutableCopy;
    [characterSet formUnionWithCharacterSet:[NSCharacterSet whitespaceCharacterSet]];
    while (index < length) {
        if ([characterSet characterIsMember:[snakeCaseString characterAtIndex:index]]) {
            [snakeCaseString insertString:@"_" atIndex:index];
            index++;
        }
        index++;
    }
    return [snakeCaseString.lowercaseString replace:@" " with:@""];
}

- (NSString *)ucFirst  {
    if (self.length <= 1) {
        return self.uppercaseString;
    } else {
        return str(@"%@%@",[[self substringToIndex:1] uppercaseString],
                            [self substringFromIndex:1]);
    }
}

- (NSString *)lcFirst {
    if (self.length <= 1) {
        return self.lowercaseString;
    } else {
        return str(@"%@%@",[[self substringToIndex:1] lowercaseString],
                            [self substringFromIndex:1]);
    }
}

- (NSString*)withoutDiacritic{
    return [self stringByFoldingWithOptions:NSDiacriticInsensitiveSearch
                              locale:[NSLocale systemLocale]];
}

-(BOOL)endsWith:(NSString *)compare{
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH %@",compare];
    return [fltr evaluateWithObject:self];
}

-(BOOL)startsWith:(NSString *)compare{
    //[c] for case insensitive
    //NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self BEGINSWITH[c] %@",compare];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self BEGINSWITH %@",compare];
    return [fltr evaluateWithObject:self];
}

-(BOOL)contains:(NSString *)compare{
    //[c] for case insensitive
    //NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self BEGINSWITH[c] %@",compare];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self CONTAINS %@",compare];
    return [fltr evaluateWithObject:self];
}

-(BOOL)matches:(NSString*)regexp{
    NSPredicate *regexpTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexp];    
    return ([regexpTest evaluateWithObject: self]);
}

-(NSString*)lpad:(int)lenght string:(NSString*)string{
    int finalLength = MAX(0, lenght - (int)self.length);
    NSString* padChars = [[NSString string] stringByPaddingToLength:finalLength
                                                         withString:string
                                                    startingAtIndex:0];
    
    return [padChars append:self];
    
}

-(NSString*)rpad:(int)lenght string:(NSString*)string{
    return [self stringByPaddingToLength:MAX((int)self.length,lenght)
                              withString:string
                         startingAtIndex:0];
}

-(NSString*)urlEncode{
    return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
}

-(NSString*)urlDecode{
    return [self stringByRemovingPercentEncoding];
}

-(NSString*)md5{
    const char *cStr = [self UTF8String];
    unsigned char digest[16];
    
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *md5 = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [md5 appendFormat:@"%02x", digest[i]];
    }
    return md5;
}

-(NSString*)toBase64{
    NSData *plainData = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [plainData base64EncodedStringWithOptions:kNilOptions];
}

+(NSString*)fromBase64:(NSString*)base64{
    NSData *nsdataFromBase64String = [[NSData alloc] initWithBase64EncodedString:base64 options:0];
    return [[NSString alloc] initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
}

+ (NSString *) fromHex:(NSString *)str
{
    NSMutableData *stringData = [[NSMutableData alloc] init];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i;
    for (i=0; i < [str length] / 2; i++) {
        byte_chars[0] = [str characterAtIndex:i*2];
        byte_chars[1] = [str characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [stringData appendBytes:&whole_byte length:1];
    }
    
    return [[NSString alloc] initWithData:stringData encoding:NSASCIIStringEncoding];
}

- (NSString *) toHex
{
    NSUInteger len = self.length;
    unichar *chars = malloc(len * sizeof(unichar));
    [self getCharacters:chars];
    
    NSMutableString *hexString = [[NSMutableString alloc] init];
    
    for(NSUInteger i = 0; i < len; i++ )
    {
        [hexString appendString:[NSString stringWithFormat:@"%x", chars[i]]];
    }
    free(chars);
    
    return hexString;
}


@end
