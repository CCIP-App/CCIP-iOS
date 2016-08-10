//
//  CheckinCardView.m
//  CCIP
//
//  Created by 腹黒い茶 on 2016/07/31.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CheckinCardView.h"
#import "AppDelegate.h"
#import "UIAlertController+additional.h"
#import "GatewayWebService/GatewayWebService.h"

@interface CheckinCardView()

@end

@implementation CheckinCardView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.layer setCornerRadius:15.0f]; // set cornerRadius as you want.
    [self.layer setMasksToBounds:NO];
    [self.layer setShadowOffset:CGSizeMake(10, 15)];
    [self.layer setShadowRadius:5.0f];
    [self.layer setShadowOpacity:0.3f];
    
    [self.checkinBtn.layer setCornerRadius:10.0f];
}

- (void)showCountdown {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[self.scenario objectForKey:@"used"] longValue]];
    NSLog(@"%@", date);
    [self.delegate showCountdown:self.scenario];
}

- (NSDictionary *)updateScenario:(NSArray *)scenarios {
    for (NSDictionary *scenario in scenarios) {
        NSString *id = [scenario objectForKey:@"id"];
        if ([id isEqualToString:self.id]) {
            self.scenario = scenario;
            break;
        }
    }
    return self.scenario;
}

- (IBAction)checkinBtnTouched:(id)sender {
    UIColor *disabledColor = [UIColor colorWithRed:155/255.0 green:155/255.0 blue:155/255.0 alpha:1];
    if ([self.id isEqualToString:@"day1checkin"] || [self.id isEqualToString:@"day2checkin"]) {
        GatewayWebService *ws = [[GatewayWebService alloc] initWithURL:CC_USE([AppDelegate appDelegate].accessToken, self.id)];
        [ws sendRequest:^(NSDictionary *json, NSString *jsonStr) {
            if (json != nil) {
                NSLog(@"%@", json);
                [self setUsed:[NSNumber numberWithBool:YES]];
                if ([[json objectForKey:@"message"] isEqual:@"invalid token"]) {
                    NSLog(@"%@", [json objectForKey:@"message"]);
                    [self.checkinBtn setBackgroundColor:[UIColor redColor]];
                } else if ([[json objectForKey:@"message"] isEqual:@"has been used"]) {
                    [self showCountdown];
                    NSLog(@"%@", [json objectForKey:@"message"]);
                    [UIView animateWithDuration:0.25f
                                     animations:^{
                                         [self.checkinBtn setBackgroundColor:[UIColor orangeColor]];
                                     }
                                     completion:^(BOOL finished) {
                                         if (finished) {
                                             [UIView animateWithDuration:1.75f
                                                              animations:^{
                                                                  [self.checkinBtn setBackgroundColor:disabledColor];
                                                              }];
                                         }
                                     }];
                } else {
                    [self updateScenario:[json objectForKey:@"scenarios"]];
                    [self showCountdown];
                    [self.checkinBtn setTitle:NSLocalizedString(@"CheckinViewButtonPressed", nil) forState:UIControlStateNormal];
                    [self.checkinBtn setBackgroundColor:disabledColor];
                }
            } else {
                UIAlertController *ac = [UIAlertController alertOfTitle:NSLocalizedString(@"NetworkAlert", nil) withMessage:NSLocalizedString(@"NetworkAlertDesc", nil) cancelButtonText:NSLocalizedString(@"GotIt", nil) cancelStyle:UIAlertActionStyleCancel cancelAction:nil];
                [ac showAlert:nil];
            }
        }];
    } else {
        void (^use)(void) = ^{
            GatewayWebService *ws = [[GatewayWebService alloc] initWithURL:CC_USE([AppDelegate appDelegate].accessToken, self.id)];
            [ws sendRequest:^(NSDictionary *json, NSString *jsonStr) {
                if (json != nil) {
                    NSLog(@"%@", json);
                    [self setUsed:[NSNumber numberWithBool:YES]];
                    if ([[json objectForKey:@"message"] isEqual:@"invalid token"]) {
                        NSLog(@"%@", [json objectForKey:@"message"]);
                        [self.checkinBtn setBackgroundColor:[UIColor redColor]];
                    } else if ([[json objectForKey:@"message"] isEqual:@"has been used"]) {
                        [self showCountdown];
                        NSLog(@"%@", [json objectForKey:@"message"]);
                        [UIView animateWithDuration:0.25f
                                         animations:^{
                                             [self.checkinBtn setBackgroundColor:[UIColor orangeColor]];
                                         }
                                         completion:^(BOOL finished) {
                                             if (finished) {
                                                 [UIView animateWithDuration:1.75f
                                                                  animations:^{
                                                                      [self.checkinBtn setBackgroundColor:disabledColor];
                                                                  }];
                                             }
                                         }];
                    } else {
                        [self updateScenario:[json objectForKey:@"scenarios"]];
                        [self showCountdown];
                        [self.checkinBtn setTitle:NSLocalizedString(@"UseButtonPressed", nil) forState:UIControlStateNormal];
                        [self.checkinBtn setBackgroundColor:disabledColor];
                    }
                }
            }];
        };
        if ([self.used boolValue]) {
            use();
        } else {
            UIAlertController *ac = [UIAlertController alertOfTitle:NSLocalizedString([@"UseButton_" stringByAppendingString:self.id], nil)
                                                        withMessage:NSLocalizedString(@"ConfirmAlertText", nil)
                                                   cancelButtonText:NSLocalizedString(@"Cancel", nil)
                                                        cancelStyle:UIAlertActionStyleCancel
                                                       cancelAction:nil];
            [ac addActionButton:NSLocalizedString(@"CONFIRM", nil)
                          style:UIAlertActionStyleDestructive
                        handler:^(UIAlertAction * _Nonnull action) {
                            use();
                        }];
            [ac showAlert:nil];
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
