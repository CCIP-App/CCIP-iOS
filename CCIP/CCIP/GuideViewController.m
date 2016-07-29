//
//  GuideViewController.m
//  CCIP
//
//  Created by 腹黒い茶 on 2016/07/09.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "AppDelegate.h"
#import "GuideViewController.h"
#import <UICKeyChainStore/UICKeyChainStore.h>

@interface GuideViewController ()

@property (strong, nonatomic) AppDelegate *appDelegate;

@end

@implementation GuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.guideMessageLabel setText:NSLocalizedString(@"GuideViewMessage", nil)];
    [self.redeemButton setTitle:NSLocalizedString(@"GuideViewButton", nil)
                       forState:UIControlStateNormal];
    [self.redeemButton setBackgroundColor:[UIColor colorWithRed:61/255.0 green:152/255.0 blue:60/255.0 alpha:1]];
    self.redeemButton.layer.cornerRadius = 8.0f;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    self.originalCenter = CGPointMake(self.view.center.x, self.view.center.y);
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"GuideViewController"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)keyboardDidShow:(NSNotification *)note {
    if (self.view.frame.size.height <= 480) {
        self.view.center = CGPointMake(self.originalCenter.x, self.originalCenter.y - 130);
    } else if (self.view.frame.size.height <= 568) {
        self.view.center = CGPointMake(self.originalCenter.x, self.originalCenter.y - 30);
    }
}

- (void)keyboardWillHide:(NSNotification *)note {
    self.view.center = CGPointMake(self.originalCenter.x, self.originalCenter.y);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)redeemCode:(id)sender {
    NSString *code = [self.redeemCodeText text];
    if ([code length] > 0) {
        if ([self.appDelegate.accessToken length] > 0) {
            [UICKeyChainStore removeItemForKey:@"token"];
        }
        self.appDelegate.accessToken = code;
        [UICKeyChainStore setString:self.appDelegate.accessToken
                             forKey:@"token"];
        [self.appDelegate.oneSignal sendTag:@"token" value:self.appDelegate.accessToken];
    }
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 [self.appDelegate.masterView refreshData];
                             }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
