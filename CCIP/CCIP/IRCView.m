//
//  IRCView.m
//  CCIP
//
//  Created by Sars on 2016/07/03.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "GatewayWebService/GatewayWebService.h"
#import "AppDelegate.h"
#import "UIApplication+addition.h"
#import "IRCView.h"

@interface IRCView()

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation IRCView

- (void)drawRect:(CGRect)rect {
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self.webview setDelegate:self];
    [self.webview.scrollView setScrollEnabled:NO];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"IRCView"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    if (self.refreshControl == nil) {
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self
                                action:@selector(refresh)
                      forControlEvents:UIControlEventValueChanged];
        [self.webview.scrollView addSubview:self.refreshControl];
        
        [self refresh];
        [self.webview.scrollView setContentOffset:CGPointMake(0,-128)
                                         animated:NO];
    } else {
        [self refresh];
    }
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

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.refreshControl endRefreshing];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        NSURL *url = request.URL;
        
        if ([url.host isEqualToString:[NSURL URLWithString:LOG_BOT_URL].host]) {
            return YES;
        } else {
            if ([SFSafariViewController class] != nil) {
                // Open in SFSafariViewController
                SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:url];
                [safariViewController setDelegate:self];
                
                // SFSafariViewController Toolbar TintColor
                // [safariViewController.view setTintColor:[UIColor colorWithRed:61/255.0 green:152/255.0 blue:60/255.0 alpha:1]];
                // or http://stackoverflow.com/a/35524808/1751900
                
                // ProgressBar Color Not Found
                // ...
                
                [[UIApplication getMostTopPresentedViewController] presentViewController:safariViewController
                                                                                animated:YES
                                                                              completion:nil];
            } else {
                // Open in Mobile Safari
                if (![[UIApplication sharedApplication] openURL:url]) {
                    NSLog(@"%@%@",@"Failed to open url:", [url description]);
                }
            }
            return NO;
        }
    }
    return YES;
}

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    // Called when the user taps the Done button to dismiss the Safari view.
}

@end
