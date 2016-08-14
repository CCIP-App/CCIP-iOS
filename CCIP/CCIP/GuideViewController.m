//
//  GuideViewController.m
//  CCIP
//
//  Created by 腹黒い茶 on 2016/07/09.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import <UICKeyChainStore/UICKeyChainStore.h>
#import "AppDelegate.h"
#import "GuideViewController.h"
#import "UIAlertController+additional.h"
#import "GatewayWebService/GatewayWebService.h"

@interface GuideViewController ()

@property (readwrite, nonatomic) BOOL isRelayout;

@end

@implementation GuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.guideMessageLabel setText:NSLocalizedString(@"GuideViewMessage", nil)];
    [self.redeemButton setTitle:NSLocalizedString(@"GuideViewButton", nil)
                       forState:UIControlStateNormal];
    [self.redeemButton setBackgroundColor:[UIColor colorWithRed:61/255.0 green:152/255.0 blue:60/255.0 alpha:1]];
    self.redeemButton.layer.cornerRadius = 8.0f;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    self.originalCenter = CGPointMake(self.view.center.x, self.view.center.y);
    
    SEND_GAI(@"GuideViewController");
    
    [self.view setAutoresizingMask:UIViewAutoresizingNone];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    if (self.isRelayout != true) {
        self.view.frame = CGRectMake(0.0,
                                     64.0,
                                     self.view.frame.size.width,
                                     self.view.frame.size.height - 64 - 49);
        self.isRelayout = true;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self redeemCode:nil];
    return YES;
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
        GatewayWebService *ws = [[GatewayWebService alloc] initWithURL:CC_LANDING(code)];
        [ws sendRequest:^(NSDictionary *json, NSString *jsonStr) {
            if (json != nil) {
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:json];
                
                if ([userInfo objectForKey:@"nickname"] && ![[userInfo objectForKey:@"nickname"] isEqualToString:@""]) {
                    [AppDelegate setAccessToken:code];
                    [[AppDelegate appDelegate].checkinView reloadCard];
                    [self dismissViewControllerAnimated:YES completion:nil];
                } else if ([userInfo objectForKey:@"message"] && [[userInfo objectForKey:@"message"] isEqualToString:@"invalid token"]) {
                    [self showAlert];
                }
            }
        }];
    } else {
        [self showAlert];
    }
}

- (void)showAlert {
    UIAlertController *ac = [UIAlertController alertOfTitle:NSLocalizedString(@"GuideViewTokenErrorTitle", nil) withMessage:NSLocalizedString(@"GuideViewTokenErrorDesc", nil) cancelButtonText:NSLocalizedString(@"GotIt", nil) cancelStyle:UIAlertActionStyleCancel cancelAction:nil];
    [ac showAlert:nil];
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
