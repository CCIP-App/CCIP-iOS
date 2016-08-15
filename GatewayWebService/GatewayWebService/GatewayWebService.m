//
//  GatewayWebService.m
//  GatewayWebService
//
//  Created by 腹黒い茶 on 2016/06/24.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

@import UIKit;
@import MYCrypto;
#import <GatewayWebService/GatewayWebService.h>


@interface GatewayWebService()

@property (strong, nonatomic) NSURL *wsURL;
@property (strong, nonatomic) NSMutableURLRequest *request;
@property (strong, nonatomic) NSOperationQueue *currentQueue;
@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, nonatomic) NSData *requestData;
@property (strong, nonatomic) ResponseDelegate response;
@property (strong, nonatomic) NSURLResponse *responsed;
@property (strong, nonatomic) NSMutableData *responseData;
@property (strong, nonatomic) NSString *responseText;
@property (strong, nonatomic) NSString *methodName;
@property (strong, nonatomic) NSDate *initialTimeStamp;
@property (strong, nonatomic) NSDate *requestTimeStamp;
@property (strong, nonatomic) NSDate *responseTimeStamp;
@property (strong, nonatomic) NSDate *callbackTimeStamp;
@property (readwrite, nonatomic) bool isPOST;

@end

GatewayWebService *sharedInstance;
NSArray *AcceptedCerts;
NSUInteger RequestedCount = 0;
NSUInteger SuccessCount = 0;
NSUInteger FailedCount = 0;

@implementation GatewayWebService

+ (instancetype)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[[self class] alloc] init];
    }
    return sharedInstance;
}

- (void)checkInstance:(BOOL)isShared {
    if (isShared == NO && self == sharedInstance) {
        [NSException raise:@"SharedInstanceExecutionInvalidException"
                    format:@"Invoking separed instance method from shared instance is invalid"];
        return;
    }
    if (isShared == YES && self != sharedInstance) {
        [NSException raise:@"SharedInstanceExecutionInvalidException"
                    format:@"Invoking to shared instance method from separed instance is invalid"];
        return;
    }
}

- (NSArray *)getAcceptedCerts { [self checkInstance:YES]; return AcceptedCerts; }
- (NSUInteger)getRequestedCount { [self checkInstance:YES]; return RequestedCount; }
- (NSUInteger)getSuccessCount { [self checkInstance:YES]; return SuccessCount; }
- (NSUInteger)getFailedCount { [self checkInstance:YES]; return FailedCount; }

- (instancetype)init {
    self = [super init];
    if (self) {
        self.initialTimeStamp = [NSDate date];
        self.wsURL = nil;
        self.request = nil;
        self.connection = nil;
        self.response = nil;
        self.requestURL = nil;
        self.methodName = nil;
        self.isPOST = NO;
    }
    return self;
}

- (instancetype)initWithURL:(NSString *)URL {
    self = [self init];
    if (self) {
        self.isPOST = NO;
        [self setURL:URL];
    }
    return self;
}

- (instancetype)initWithURL:(NSString *)URL withData:(id)data {
    self = [self init];
    if (self) {
        self.isPOST = YES;
        [self setURL:URL];
        if(![data isKindOfClass:[NSData class]])
            data = [NSJSONSerialization dataWithJSONObject:data
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:nil];
        [self setData:data];
    }
    return self;
}

- (instancetype)initWithURL:(NSString *)URL withDataString:(NSString *)data {
    self = [self init];
    if (self) {
        self.isPOST = YES;
        [self setURL:URL];
        [self setDataWithString:data];
    }
    return self;
}

- (void)setURL:(NSString *)URL {
    [self checkInstance:NO];
    self.currentQueue = [NSOperationQueue currentQueue];
    self.queue = [[NSOperationQueue alloc] init];
    [self.queue setName:@"org.coscup.GatewayWebService.InvokeInstance"];
    self.methodName = URL;
    self.wsURL = [NSURL URLWithString:URL];
    self.requestURL = [self.wsURL absoluteString];
    self.request = [[NSMutableURLRequest alloc] initWithURL:self.wsURL
                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                            timeoutInterval:__TIMEOUT_INTERVAL__];
    [self.request setHTTPMethod:(self.isPOST ? @"POST" : @"GET")];
    [self.request setValue:@"application/json"
        forHTTPHeaderField:@"Accept"];
    [self.request setValue:@"application/json"
        forHTTPHeaderField:@"Content-Type"];
}

- (void)setData:(NSData *)data {
    [self checkInstance:NO];
    self.requestData = data;
    if(self.request != nil) {
        [self.request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[self.requestData length]] forHTTPHeaderField:@"Content-Length"];
        [self.request setHTTPBody:self.requestData];
        id requestData = [NSJSONSerialization JSONObjectWithData:self.requestData
                                                         options:NSJSONReadingAllowFragments
                                                           error:nil];
        requestData = [NSJSONSerialization dataWithJSONObject:requestData
                                                      options:NSJSONWritingPrettyPrinted
                                                        error:nil];
        requestData = [[NSString alloc] initWithData:requestData
                                            encoding:NSUTF8StringEncoding];
        NSLog(@"Request WS Data: %@", requestData);
    }
}

- (void)setDataWithString:(NSString *)stringData {
    [self checkInstance:NO];
    NSData *data;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[stringData dataUsingEncoding:NSUTF8StringEncoding]
                                                         options:NSJSONReadingAllowFragments
                                                           error:nil];
    data = [NSJSONSerialization dataWithJSONObject:json
                                           options:NSJSONWritingPrettyPrinted
                                             error:nil];
    [self setData:data];
}

- (bool)sendRequest:(ResponseDelegate)responseDelegate {
    [self checkInstance:NO];
    if(self.requestURL != nil && self.request != nil) {
        RequestedCount++;
        self.requestTimeStamp = [NSDate date];
        self.responseData = [NSMutableData data];
        self.response = responseDelegate;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        self.connection = [[NSURLConnection alloc] initWithRequest:self.request
                                                          delegate:self
                                                  startImmediately:NO];
        [self.connection setDelegateQueue:self.queue];
        [self.connection start];
        [self.queue addOperationWithBlock:^{
            [[NSThread currentThread] setName:[self.queue name]];
        }];
        return YES;
    }
    return NO;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSLog(@"Gateway loading with folllowing Error message: %@", error);
    return [self callbackResponse:nil
                 WithOriginalData:@""];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
    NSLog(@"Gateway WS receieved data: %lu bytes (concurrent: %lu bytes)", (unsigned long)[data length], (unsigned long)[self.responseData length]);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.responsed = response;
    self.responseTimeStamp = [NSDate date];
    [self.responseData setLength:0];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.responseText = [[NSString alloc] initWithData:self.responseData
                                              encoding:NSUTF8StringEncoding];
    NSLog(@"Gateway WS receieved data content: %@", self.responseText);
    if (self.responseText == nil) {
        [self callbackResponse:nil
              WithOriginalData:@""];
        return;
    }
    id json = [NSJSONSerialization JSONObjectWithData:[self.responseText dataUsingEncoding:NSUTF8StringEncoding]
                                               options:NSJSONReadingAllowFragments
                                                 error:nil];
    id d = nil;
    if ([json class] == [NSDictionary class]) {
        d = [json objectForKey:@"d"];
    }
    if(d == nil || [d isKindOfClass:[NSNull class]]) {
        if (json != nil) {
            [self callbackResponse:json
                  WithOriginalData:self.responseText];
        } else {
            [self callbackResponse:nil
                  WithOriginalData:@""];
        }
    } else {
        NSString *jsonStr = @"";
        @try {
            jsonStr = [NSJSONSerialization JSONObjectWithData:[NSJSONSerialization dataWithJSONObject:d
                                                                                              options:NSJSONWritingPrettyPrinted
                                                                                                error:nil]
                                                      options:NSJSONReadingAllowFragments
                                                        error:nil];
        }
        @catch (NSException *exception) {
            jsonStr = [NSString stringWithFormat:@"%@", d];
        }
        @finally {
            NSLog(@"Gateway responsed WS Data: %@", d);
            if (d != nil && ![d isKindOfClass:[NSNull class]]) {
                [self callbackResponse:d
                      WithOriginalData:jsonStr];
            } else {
                [self callbackResponse:nil
                      WithOriginalData:@""];
            }
        }
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (id)SerializationData:(NSData *)data {
    if ([data length] == 0) {
        return [NSDictionary new];
    } else {
        return [NSJSONSerialization JSONObjectWithData:data
                                               options:NSJSONReadingAllowFragments
                                                 error:nil];
    }
}

- (void)callbackResponse:(id)jsonData WithOriginalData:(id)jsonString {
    if (jsonData != nil) {
        SuccessCount++;
    } else {
        FailedCount++;
    }
    self.callbackTimeStamp = [NSDate date];
    [self.currentQueue addOperationWithBlock:^{
        self.response(jsonData, jsonString, self.responsed);
    }];
}

@end
