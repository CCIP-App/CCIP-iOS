//
//  IRCView.h
//  CCIP
//
//  Created by Sars on 2016/07/03.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SafariServices/SFSafariViewController.h>
#import <NJKWebViewProgress/NJKWebViewProgress.h>

@interface IRCViewController : UIViewController <UIWebViewDelegate, NJKWebViewProgressDelegate, SFSafariViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *goBackButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *goForwardButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *goReloadButton;

- (IBAction)reload:(id)sender;

@end
