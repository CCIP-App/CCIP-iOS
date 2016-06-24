//
//  GatewayWebService.h
//  GatewayWebService
//
//  Created by 腹黒い茶 on 2016/06/24.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

@import Foundation;
#import "headers.h"
#import "WebServiceEndPoint.h"

//! Project version number for GatewayWebService.
FOUNDATION_EXPORT double GatewayWebServiceVersionNumber;

//! Project version string for GatewayWebService.
FOUNDATION_EXPORT const unsigned char GatewayWebServiceVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <GatewayWebService/PublicHeader.h>

@interface GatewayWebService : NSObject<NSURLConnectionDataDelegate>

typedef void(^ResponseDelegate)(id, NSString *);

@property (strong, nonatomic) NSString *requestURL;

+ (instancetype)sharedInstance;

- (NSArray *)getAcceptedCerts;
- (NSUInteger)getRequestedCount;
- (NSUInteger)getSuccessCount;
- (NSUInteger)getFailedCount;

- (instancetype)init;
- (instancetype)initWithURL:(NSString *)URL;
- (instancetype)initWithURL:(NSString *)URL withData:(id)data;
- (instancetype)initWithURL:(NSString *)URL withDataString:(NSString *)data;
- (void)setURL:(NSString *)URL;
- (void)setData:(NSData *)data;
- (void)setDataWithString:(NSString *)stringData;
- (bool)sendRequest:(ResponseDelegate)responseDelegate;

@end
