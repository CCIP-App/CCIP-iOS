//
//  IRCView.m
//  CCIP
//
//  Created by Sars on 2016/07/03.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "AppDelegate.h"
#import "IRCView.h"

@interface IRCView()

@end

@implementation IRCView

- (void)drawRect:(CGRect)rect {
    NSURL *nsurl = [NSURL URLWithString:[self.scenario objectForKey:@"url"]];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:nsurl];
    [self.webview setDelegate:self];
    [self.webview loadRequest:requestObj];
    
    [self.activityIndicator startAnimating];
    self.activityIndicator.hidesWhenStopped = YES;
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"IRCView"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityIndicator stopAnimating];
}

- (void)setURL:(NSDictionary *)scenario {
    self.scenario = scenario;
}

@end
