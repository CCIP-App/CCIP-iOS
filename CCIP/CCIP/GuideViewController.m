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
@property (nonatomic) CGPoint changePoint;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appplicationDidEnterBackground:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    SEND_GAI(@"GuideViewController");
    
    [self.view setAutoresizingMask:UIViewAutoresizingNone];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    if (self.isRelayout != true) {
        self.view.frame = CGRectMake(0.0,
                                     0.0,
                                     self.view.frame.size.width,
                                     self.view.frame.size.height - 64 - 49);
        
        self.view.superview.frame = CGRectMake(0.0,
                                               64.0,
                                               self.view.frame.size.width,
                                               self.view.frame.size.height);
        self.isRelayout = true;
    }
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self redeemCode:nil];
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)note {
    if (self.view.frame.size.height <= 480) {
        self.changePoint = CGPointMake(0, -165);
        
        CGRect guideMessageLabelFrame = self.guideMessageLabel.frame;
        guideMessageLabelFrame.origin.y += self.changePoint.y;
        self.guideMessageLabel.frame = guideMessageLabelFrame;
        
        CGRect redeemCodeTextFrame = self.redeemCodeText.frame;
        redeemCodeTextFrame.origin.y += self.changePoint.y;
        self.redeemCodeText.frame = redeemCodeTextFrame;
        
        CGRect redeemButtonFrame = self.redeemButton.frame;
        redeemButtonFrame.origin.y += self.changePoint.y;
        self.redeemButton.frame = redeemButtonFrame;
        
    } else if (self.view.frame.size.height <= 568) {
        self.changePoint = CGPointMake(0, -30);
        
        CGRect guideMessageLabelFrame = self.guideMessageLabel.frame;
        guideMessageLabelFrame.origin.y += self.changePoint.y;
        self.guideMessageLabel.frame = guideMessageLabelFrame;
        
        CGRect redeemCodeTextFrame = self.redeemCodeText.frame;
        redeemCodeTextFrame.origin.y += self.changePoint.y;
        self.redeemCodeText.frame = redeemCodeTextFrame;
        
        CGRect redeemButtonFrame = self.redeemButton.frame;
        redeemButtonFrame.origin.y += self.changePoint.y;
        self.redeemButton.frame = redeemButtonFrame;
    }
}

- (void)keyboardWillHide:(NSNotification *)note {
    CGFloat deltaH = self.changePoint.y * -1;
    
    CGRect guideMessageLabelFrame = self.guideMessageLabel.frame;
    guideMessageLabelFrame.origin.y += deltaH;
    self.guideMessageLabel.frame = guideMessageLabelFrame;
    
    CGRect redeemCodeTextFrame = self.redeemCodeText.frame;
    redeemCodeTextFrame.origin.y += deltaH;
    self.redeemCodeText.frame = redeemCodeTextFrame;
    
    CGRect redeemButtonFrame = self.redeemButton.frame;
    redeemButtonFrame.origin.y += deltaH;
    self.redeemButton.frame = redeemButtonFrame;
    
    self.changePoint = CGPointMake(0, 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)redeemCode:(id)sender {
    NSString *code = [self.redeemCodeText text];
    code = [code stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSCharacterSet *allowedCharacters = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    if ([code length] > 0 && [code rangeOfCharacterFromSet:allowedCharacters].location == NSNotFound) {
        GatewayWebService *ws = [[GatewayWebService alloc] initWithURL:CC_LANDING(code)];
        [ws sendRequest:^(NSDictionary *json, NSString *jsonStr, NSURLResponse *response) {
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
