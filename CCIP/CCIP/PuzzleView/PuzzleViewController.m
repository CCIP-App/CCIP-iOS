//
//  IRCView.m
//  CCIP
//
//  Created by Sars on 2016/07/03.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "PuzzleViewController.h"
#import "AppDelegate.h"
#import <NJKWebViewProgress/NJKWebViewProgressView.h>
#import "UIColor+addition.h"
#import "UIImage+addition.h"
#import "WebServiceEndPoint.h"

@interface PuzzleViewController()

@property (strong, nonatomic) WKWebView *webView;

@property (strong, nonatomic) NJKWebViewProgressView *progressView;

@end

@implementation PuzzleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SEND_GAI(@"PuzzleView");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGFloat progressBarHeight = 2.f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.progressBarView.backgroundColor = [UIColor colorFromHtmlColor:@"#009A79"];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.navigationController.navigationBar addSubview:_progressView];
    
    self.webView = [[WKWebView alloc] init];
    [self.webView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.webView setNavigationDelegate:self];
    
    [self.webView addObserver:self
                   forKeyPath:@"estimatedProgress"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
    
    [self.view insertSubview:self.webView atIndex:0];
    
    self.goReloadButton.enabled = NO;
    
    [self setWebViewConstraints];
    
    NSURL *nsurl = self.webView.URL;
    if ([AppDelegate haveAccessToken] && (nsurl == nil || [nsurl.absoluteString isEqualToString:@""])) {
        nsurl = [NSURL URLWithString:PUZZLE_GAME_URL([AppDelegate accessTokenSHA1])];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:nsurl];
        [self.webView loadRequest:requestObj];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.webView removeObserver:self
                      forKeyPath:@"estimatedProgress"];
    [self.webView removeFromSuperview];
    [_progressView removeFromSuperview];
}

- (void)setWebViewConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.webView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.bottomLayoutGuide
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.webView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.topLayoutGuide
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.webView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.webView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:0]];
}

- (IBAction)reload:(id)sender {
    NSString *sha1Token = [AppDelegate accessTokenSHA1];
    NSURL *nsurl = self.webView.URL;
    if ([AppDelegate haveAccessToken] && (nsurl == nil || [nsurl.absoluteString isEqualToString:@""] || ![nsurl.absoluteString containsString:sha1Token])) {
        nsurl = [NSURL URLWithString:PUZZLE_GAME_URL(sha1Token)];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:nsurl];
        [self.webView loadRequest:requestObj];
    }
    else {
        [self.webView reload];
    }
    [self checkButtonStatus];
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
}

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
