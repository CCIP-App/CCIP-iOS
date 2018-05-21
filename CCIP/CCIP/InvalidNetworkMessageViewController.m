//
//  InvalidNetworkMessageViewController.m
//  CCIP
//
//  Created by FrankWu on 2016/8/15.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "InvalidNetworkMessageViewController.h"
#import "AppDelegate.h"
#import "UIColor+addition.h"
#import "UIView+addition.h"
#import "MainNavViewController.h"

@interface InvalidNetworkMessageViewController ()

@property (readwrite, nonatomic) BOOL isRelayout;
@property (strong, nonatomic) NSString *message;

@end

@implementation InvalidNetworkMessageViewController

- (void)setMessage:(NSString *)message {
    _message = message;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.closeButton setTitle:NSLocalizedString(@"InvalidNetworkButtonRetry", nil)
                      forState:UIControlStateNormal];
    [self.closeButton setTintColor:[UIColor whiteColor]];
    [self.closeButton setBackgroundColor:[UIColor colorWithRed:61/255.0 green:152/255.0 blue:60/255.0 alpha:1]];
    [self.closeButton setGradientColor:[AppDelegate AppConfigColor:@"MessageButtonLeftColor"]
                                    To:[AppDelegate AppConfigColor:@"MessageButtonRightColor"]
                            StartPoint:CGPointMake(-.4f, .5f)
                               ToPoint:CGPointMake(1, .5f)];
    CALayer *layer = [self.closeButton.layer.sublayers firstObject];
    [layer setCornerRadius:self.closeButton.frame.size.height / 2];
    [self.closeButton.layer setCornerRadius:self.closeButton.frame.size.height / 2];
    
    [self.messageLabel setText:self.message];
    [self.view setAutoresizingMask:UIViewAutoresizingNone];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appplicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (self.isRelayout != true) {
        MainNavViewController *mnvc = (MainNavViewController *)self.presentingViewController;
        CheckinViewController *cvc = (CheckinViewController *)[[mnvc childViewControllers] firstObject];
        CGFloat topStart = [cvc controllerTopStart];
        topStart = 0;
        self.view.frame = CGRectMake(0.0f,
                                     -44.0f + topStart,
                                     self.view.frame.size.width,
                                     self.view.frame.size.height - topStart - 49.0f + X_TOP(0.0f, 22.0f));
        self.view.superview.frame = CGRectMake(0.0f,
                                               topStart,
                                               self.view.frame.size.width,
                                               self.view.frame.size.height + X_TOP(0.0f, 22.0f));
        self.isRelayout = true;
    }
}

- (IBAction)clossView:(id)sender {
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 if (self.delegate && [self.delegate respondsToSelector:@selector(refresh)]) {
                                     [self.delegate refresh];
                                 }
                             }];
}

- (void)appplicationDidEnterBackground:(NSNotification *)notification {
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
