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
    [super drawRect:rect];
    
    if (self.webview.delegate == nil) {
        [self.webview setDelegate:self];
        UIEdgeInsets contentInset = [self.webview.scrollView contentInset];
        UIEdgeInsets scrollInset = [self.webview.scrollView scrollIndicatorInsets];
        contentInset.bottom += self.bottomGuideHeight;
        scrollInset.bottom += self.bottomGuideHeight;
        [self.webview.scrollView setContentInset:contentInset];
        [self.webview.scrollView setScrollIndicatorInsets:scrollInset];
    }
    
    SEND_GAI(@"IRCView");
    
    if (self.refreshControl == nil) {
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self
                                action:@selector(refresh)
                      forControlEvents:UIControlEventValueChanged];
        [self.webview.scrollView addSubview:self.refreshControl];
        
        [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
        
        [self refresh];
        [self.refreshControl beginRefreshing];
        [self.webview.scrollView setContentOffset:CGPointMake(0, self.webview.scrollView.contentOffset.y - 60)
                                         animated:NO];
        
        UIEdgeInsets viewInset = [self.webview.scrollView contentInset];
        UIEdgeInsets viewScrollInset = [self.webview.scrollView scrollIndicatorInsets];

        viewInset.bottom = self.bottomGuideHeight;
        viewInset.top = self.topGuideHeight + 60;
        
        viewScrollInset.bottom = self.bottomGuideHeight;
        viewScrollInset.top = self.topGuideHeight;
        
        [self.webview.scrollView setContentInset:viewInset];
        [self.webview.scrollView setScrollIndicatorInsets:viewScrollInset];
    }
    
}

- (void)refresh {
    NSURL *nsurl = self.webview.request.URL;
    if (nsurl == nil || [nsurl.absoluteString isEqualToString:@"about:blank"]) {
        nsurl = [NSURL URLWithString:LOG_BOT_URL];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:nsurl];
        [self.webview loadRequest:requestObj];
    }
    else {
        [self.webview reload];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSURL *nsurl = self.webview.request.URL;
    if (![nsurl.absoluteString isEqualToString:@"about:blank"]) {
        [self.refreshControl endRefreshing];
    }
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
