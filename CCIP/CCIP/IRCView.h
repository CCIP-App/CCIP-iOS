//
//  IRCView.h
//  CCIP
//
//  Created by Sars on 2016/07/03.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Google/Analytics.h>
#import <SafariServices/SFSafariViewController.h>

@interface IRCView : UIView <UIWebViewDelegate, SFSafariViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webview;

@end
