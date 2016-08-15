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

@interface IRCViewController()

@property (strong, nonatomic) FBShimmeringView *shimmeringLogoView;

@end

@implementation IRCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set logo on nav title
    UIView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"coscup-logo"]];
    self.shimmeringLogoView = [[FBShimmeringView alloc] initWithFrame:logoView.bounds];
    self.shimmeringLogoView.contentView = logoView;
    self.navigationItem.titleView = logoView;
    
    SEND_GAI(@"IRCView");
    
    [self.webview setDelegate:self];
    
    self.goBackButton.enabled = NO;
    self.goForwardButton.enabled = NO;
    self.goReloadButton.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.shimmeringLogoView setShimmering:[AppDelegate isDevMode]];
    
    NSURL *nsurl = self.webview.request.URL;
    if (nsurl == nil || [self.webview.request.URL.absoluteString isEqualToString:@""]) {
        nsurl = [NSURL URLWithString:LOG_BOT_URL];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:nsurl];
        [self.webview loadRequest:requestObj];
    }
}

- (IBAction)reload:(id)sender {
    NSURL *nsurl = self.webview.request.URL;
    if (nsurl == nil || [self.webview.request.URL.absoluteString isEqualToString:@""]) {
        nsurl = [NSURL URLWithString:LOG_BOT_URL];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:nsurl];
        [self.webview loadRequest:requestObj];
    }
    else {
        [self.webview reload];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self checkButtonStatus];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self checkButtonStatus];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self checkButtonStatus];
}

- (void)checkButtonStatus {
    self.goReloadButton.enabled = self.webview.isLoading ? NO : YES;
    self.goForwardButton.enabled = self.webview.canGoForward ? YES : NO;
    self.goBackButton.enabled = self.webview.canGoBack ? YES : NO;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
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
