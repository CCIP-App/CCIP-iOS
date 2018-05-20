//
//  MapsWebViewController.h
//  CCIP
//
//  Created by 腹黒い茶 on 2018/05/21.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <SafariServices/SFSafariViewController.h>
#import <NJKWebViewProgress/NJKWebViewProgress.h>

@interface MapsWebViewController : UIViewController <WKNavigationDelegate, WKUIDelegate, SFSafariViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *goReloadButton;

- (IBAction)reload:(id)sender;

@end
