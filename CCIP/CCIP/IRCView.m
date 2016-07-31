//
//  IRCView.m
//  CCIP
//
//  Created by Sars on 2016/07/03.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "GatewayWebService/GatewayWebService.h"
#import "AppDelegate.h"
#import "IRCView.h"

@interface IRCView()

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation IRCView

- (void)drawRect:(CGRect)rect {
    [self.webview setDelegate:self];
    [self.webview.scrollView setScrollEnabled:NO];
    
    [self.activityIndicator setHidden:YES];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"IRCView"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
    [self.webview.scrollView addSubview:self.refreshControl];
    
    [self refresh];
    [self.webview.scrollView setContentOffset:CGPointMake(0,-128) animated:NO];
}

- (void)refresh {
    [self.refreshControl beginRefreshing];

    NSURL *nsurl = self.webview.request.URL;
    if (nsurl == nil) {
        nsurl = [NSURL URLWithString:LOG_BOT_URL];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:nsurl];
        [self.webview loadRequest:requestObj];
    }
    else {
        [self.webview reload];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (self.webview.scrollView.scrollEnabled == NO) {
        [self.webview.scrollView setScrollEnabled:YES];
    }
    [self.refreshControl endRefreshing];
}

@end
