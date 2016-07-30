//
//  CheckinCardViewController.m
//  CCIP
//
//  Created by FrankWu on 2016/7/30.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "CheckinCardViewController.h"
#import "AppDelegate.h"
#import "UIAlertController+additional.h"
#import "GatewayWebService/GatewayWebService.h"

@interface CheckinCardViewController ()

@property (strong, nonatomic) AppDelegate *appDelegate;

@end

@implementation CheckinCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.view.layer.cornerRadius = 15.0f; // set cornerRadius as you want.
    self.checkinBtn.layer.cornerRadius = 10.0f;
    [self.checkinBtn addTarget:self action:@selector(checkinBtnTouched) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)checkinBtnTouched {
    if ([self.id isEqualToString:@"day1checkin"] || [self.id isEqualToString:@"day2checkin"]) {
        GatewayWebService *ws = [[GatewayWebService alloc] initWithURL:CC_USE(self.appDelegate.accessToken, self.id)];
        [ws sendRequest:^(NSDictionary *json, NSString *jsonStr) {
            if (json != nil) {
                NSLog(@"%@", json);
                if ([[json objectForKey:@"message"] isEqual:@"invalid token"]) {
                    NSLog(@"%@", [json objectForKey:@"message"]);
                    [self.checkinBtn setBackgroundColor:[UIColor redColor]];
                } else {
                    [self.checkinBtn setTitle:NSLocalizedString(@"CheckinViewButtonPressed", nil) forState:UIControlStateNormal];
                    [self.checkinBtn setBackgroundColor:[UIColor colorWithRed:155/255.0 green:155/255.0 blue:155/255.0 alpha:1]];
                }
            }
        }];
    } else {
        UIAlertController *ac = [UIAlertController alertOfTitle:NSLocalizedString(@"UseButton", nil)
                                                    withMessage:NSLocalizedString(@"ConfirmAlertText", nil)
                                               cancelButtonText:NSLocalizedString(@"Cancel", nil)
                                                    cancelStyle:UIAlertActionStyleCancel
                                                   cancelAction:nil];
        [ac addActionButton:NSLocalizedString(@"CONFIRM", nil)
                      style:UIAlertActionStyleDestructive
                    handler:^(UIAlertAction * _Nonnull action) {
                        GatewayWebService *ws = [[GatewayWebService alloc] initWithURL:CC_USE(self.appDelegate.accessToken, self.id)];
                        [ws sendRequest:^(NSDictionary *json, NSString *jsonStr) {
                            if (json != nil) {
                                NSLog(@"%@", json);
                                if ([[json objectForKey:@"message"] isEqual:@"invalid token"]) {
                                    NSLog(@"%@", [json objectForKey:@"message"]);
                                    [self.checkinBtn setBackgroundColor:[UIColor redColor]];
                                } else {
                                    [self.checkinBtn setTitle:NSLocalizedString(@"UseButtonPressed", nil) forState:UIControlStateNormal];
                                    [self.checkinBtn setBackgroundColor:[UIColor colorWithRed:155/255.0 green:155/255.0 blue:155/255.0 alpha:1]];
                                }
                            }
                        }];
                    }];
        [ac showAlert:nil];
    }
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
