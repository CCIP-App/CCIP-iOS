//
//  CheckinViewCell.m
//  CCIP
//
//  Created by Sars on 7/17/16.
//  Copyright © 2016 CPRTeam. All rights reserved.
//

#import "CheckinViewCell.h"
#import "AppDelegate.h"
#import "UIAlertController+additional.h"
#import "GatewayWebService/GatewayWebService.h"

@interface CheckinViewCell()

@property (strong, nonatomic) AppDelegate *appDelegate;

@end

@implementation CheckinViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.checkinBtn.layer.cornerRadius = 10.0f;
    [self.checkinBtn addTarget:self action:@selector(checkinBtnTouched) forControlEvents:UIControlEventTouchUpInside];
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

@end
