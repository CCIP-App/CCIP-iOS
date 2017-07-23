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
#import <AFNetworking/AFNetworking.h>
#import "WebServiceEndPoint.h"
#import "UIColor+addition.h"
#import "MainNavViewController.h"

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
    [self.redeemButton setTintColor:[UIColor whiteColor]];
    [self.redeemButton setBackgroundColor:[UIColor colorWithRed:61/255.0 green:152/255.0 blue:60/255.0 alpha:1]];
    [self.redeemButton.layer setCornerRadius:7.0f];
    
    // Set carousel background linear diagonal gradient
    //   Create the colors
    UIColor *topColor = [UIColor colorFromHtmlColor:@"#20E2D7"];
    UIColor *bottomColor = [UIColor colorFromHtmlColor:@"#ABF4B7"];
    //   Create the gradient
    CAGradientLayer *theViewGradient = [CAGradientLayer layer];
    theViewGradient.colors = [NSArray arrayWithObjects: (id)topColor.CGColor, (id)bottomColor.CGColor, nil];
    theViewGradient.frame = CGRectMake(0, 0, self.redeemButton.frame.size.width, self.redeemButton.frame.size.height);
    theViewGradient.startPoint = CGPointMake(1, 0.5);
    theViewGradient.endPoint = CGPointMake(0, 0.2);
    theViewGradient.cornerRadius = 7.0f;
    //   Add gradient to view
    [self.redeemButton.layer insertSublayer:theViewGradient
                             atIndex:0];
    
    
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

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (self.isRelayout != true) {
        MainNavViewController *mnvc = (MainNavViewController *)self.presentingViewController;
        CheckinViewController *cvc = (CheckinViewController *)[[mnvc childViewControllers] firstObject];
        CGFloat topStart = [cvc controllerTopStart];
        self.view.frame = CGRectMake(0.0f,
                                     -44.0f + topStart,
                                     self.view.frame.size.width,
                                     self.view.frame.size.height - topStart - 49.0f + 22.0f);
        self.view.superview.frame = CGRectMake(0.0f,
                                               22.0f + topStart,
                                               self.view.frame.size.width,
                                               self.view.frame.size.height + 22.0f);
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
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        
        NSURL *URL = [NSURL URLWithString:CC_LANDING(code)];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            NSLog(@"Response: %@", response);
            if (!error) {
                NSLog(@"Json: %@", responseObject);
                if (responseObject != nil) {
                    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:responseObject];
                    
                    if ([userInfo objectForKey:@"nickname"] && ![[userInfo objectForKey:@"nickname"] isEqualToString:@""]) {
                        [AppDelegate setLoginSession:YES];
                        [AppDelegate setAccessToken:code];
                        [[AppDelegate appDelegate].checkinView reloadCard];
                        [self dismissViewControllerAnimated:YES
                                                 completion:nil];
                    }
                }
            } else {
                NSLog(@"Error: %@", error);
                long statusCode = [(NSHTTPURLResponse *)response statusCode];
                switch (statusCode) {
                    case 400:
                        if ([responseObject objectForKey:@"message"] && [[responseObject objectForKey:@"message"] isEqualToString:@"invalid token"]) {
                            [self showAlert];
                        }
                        break;
                    default:
                        break;
                }
            }
        }];
        [dataTask resume];
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
