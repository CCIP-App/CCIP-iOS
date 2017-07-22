//
//  IRCView.m
//  CCIP
//
//  Created by Sars on 2016/07/03.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "IRCViewController.h"
#import "GatewayWebService/GatewayWebService.h"
#import "AppDelegate.h"
#import <NJKWebViewProgress/NJKWebViewProgressView.h>

@interface IRCViewController()

@property (strong, nonatomic) FBShimmeringView *shimmeringLogoView;

@property (strong, nonatomic) WKWebView *webView;

@property (strong, nonatomic) NJKWebViewProgressView *progressView;

@end

@implementation IRCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set logo on nav title
    UIView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"coscup-logo"]];
    self.shimmeringLogoView = [[FBShimmeringView alloc] initWithFrame:logoView.bounds];
    self.shimmeringLogoView.contentView = logoView;
    self.navigationItem.titleView = self.shimmeringLogoView;
    
    SEND_GAI(@"IRCView");
    self.webView = [[WKWebView alloc] initWithFrame:self.view.frame];
    [self.webView setNavigationDelegate:self];

    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
    [self.view insertSubview:self.webView atIndex:0];
    
    self.goBackButton.enabled = NO;
    self.goForwardButton.enabled = NO;
    self.goReloadButton.enabled = NO;
        
    CGFloat progressBarHeight = 2.f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.progressBarView.backgroundColor = [UIColor colorWithRed:61/255.0 green:152/255.0 blue:60/255.0 alpha:1.0];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;

    [self.navigationController.navigationBar addSubview:_progressView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [AppDelegate setDevLogo:self.shimmeringLogoView WithLogo:[UIImage imageNamed:@"coscup-logo"]];
    
    NSURL *nsurl = self.webView.URL;
    if (nsurl == nil || [self.webView.URL.absoluteString isEqualToString:@""]) {
        nsurl = [NSURL URLWithString:LOG_BOT_URL];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:nsurl];
        [self.webView loadRequest:requestObj];
    }
}

- (IBAction)reload:(id)sender {
    NSURL *nsurl = self.webView.URL;
    if (nsurl == nil || [self.webView.URL.absoluteString isEqualToString:@""]) {
        nsurl = [NSURL URLWithString:LOG_BOT_URL];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:nsurl];
        [self.webView loadRequest:requestObj];
    }
    else {
        [self.webView reload];
    }
    [self checkButtonStatus];
}

- (IBAction)goBack:(id)sender {
    [self.webView goBack];
}

- (IBAction)goForward:(id)sender {
    [self.webView goForward];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    [self checkButtonStatus];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self checkButtonStatus];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(nonnull NSError *)error {
    [self checkButtonStatus];
}

- (void)checkButtonStatus {
    self.goReloadButton.enabled = self.webView.isLoading ? NO : YES;
    self.goForwardButton.enabled = self.webView.canGoForward ? YES : NO;
    self.goBackButton.enabled = self.webView.canGoBack ? YES : NO;
}

//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
//        NSURL *url = request.URL;
//        
//        if ([url.host isEqualToString:[NSURL URLWithString:LOG_BOT_URL].host]) {
//            return YES;
//        } else {
//            if ([SFSafariViewController class] != nil) {
//                // Open in SFSafariViewController
//                SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:url];
//                [safariViewController setDelegate:self];
//                
//                // SFSafariViewController Toolbar TintColor
//                // [safariViewController.view setTintColor:[UIColor colorWithRed:61/255.0 green:152/255.0 blue:60/255.0 alpha:1]];
//                // or http://stackoverflow.com/a/35524808/1751900
//                
//                // ProgressBar Color Not Found
//                // ...
//                
//                [[UIApplication getMostTopPresentedViewController] presentViewController:safariViewController
//                                                                                animated:YES
//                                                                              completion:nil];
//            } else {
//                // Open in Mobile Safari
//                if (![[UIApplication sharedApplication] openURL:url]) {
//                    NSLog(@"%@%@",@"Failed to open url:", [url description]);
//                }
//            }
//            return NO;
//        }
//    }
//    return YES;
//}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"] && object == self.webView) {
        NSLog(@"%f", self.webView.estimatedProgress);
        // estimatedProgress is a value from 0.0 to 1.0
        // Update your UI here accordingly
        [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
    }
    else {
        // Make sure to call the superclass's implementation in the else block in case it is also implementing KVO
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    // Called when the user taps the Done button to dismiss the Safari view.
}

@end
