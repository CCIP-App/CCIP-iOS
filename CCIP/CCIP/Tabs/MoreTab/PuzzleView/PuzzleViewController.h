//
//  IRCView.h
//  CCIP
//
//  Created by Sars on 2016/07/03.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <SafariServices/SFSafariViewController.h>
#import <NJKWebViewProgress/NJKWebViewProgress.h>

@interface PuzzleViewController : UIViewController <WKNavigationDelegate, WKUIDelegate, SFSafariViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *goReloadButton;

- (IBAction)reload:(id)sender;

@end
