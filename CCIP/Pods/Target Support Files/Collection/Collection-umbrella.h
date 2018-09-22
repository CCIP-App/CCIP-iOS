#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "NSArray+Collection.h"
#import "NSArray+HighOrder.h"
#import "NSCountedSet+Collection.h"
#import "NSDictionary+Collection.h"
#import "NSString+Collection.h"
#import "RVCollection.h"

FOUNDATION_EXPORT double CollectionVersionNumber;
FOUNDATION_EXPORT const unsigned char CollectionVersionString[];

