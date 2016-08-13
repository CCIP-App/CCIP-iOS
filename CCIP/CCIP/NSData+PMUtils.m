// Copyright (c) 2013-2014 Peter Meyers
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//  NSData+PMUtils.m
//  Created by Peter Meyers on 3/1/14.
//

#import "NSData+PMUtils.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSData (PMUtils)

- (NSString *) hexString
{
    NSUInteger bytesCount = self.length;
    if (bytesCount) {
        static char const *kHexChars = "0123456789ABCDEF";
        const unsigned char *dataBuffer = self.bytes;
        char *chars = malloc(sizeof(char) * (bytesCount * 2 + 1));
        char *s = chars;
        for (unsigned i = 0; i < bytesCount; ++i) {
            *s++ = kHexChars[((*dataBuffer & 0xF0) >> 4)];
            *s++ = kHexChars[(*dataBuffer & 0x0F)];
            dataBuffer++;
        }
        *s = '\0';
        NSString *hexString = [NSString stringWithUTF8String:chars];
        free(chars);
        return hexString;
    }
    return @"";
}

- (NSData *)sha1Hash
{
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    if (CC_SHA1(self.bytes, (CC_LONG)self.length, digest)) {
        return [NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
    }
    return nil;
}

- (NSData *)md5Hash
{
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    if (CC_MD5(self.bytes, (CC_LONG)self.length, digest)) {
        return [NSData dataWithBytes:digest length:CC_MD5_DIGEST_LENGTH];
    }
    return nil;
}


@end