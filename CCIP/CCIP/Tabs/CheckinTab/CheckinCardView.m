//
//  CheckinCardView.m
//  CCIP
//
//  Created by 腹黒い茶 on 2016/07/31.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIAlertController+additional.h"
#import "UIColor+addition.h"
#import "UIView+addition.h"
#import "CheckinCardView.h"
#import "AppDelegate.h"
#import <AFNetworking/AFNetworking.h>
#import "WebServiceEndPoint.h"

@interface CheckinCardView()

@end

@implementation CheckinCardView

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)layoutSubviews {
    [self.checkinBtn sizeGradientToFit];
}

- (void)showCountdown {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[self.scenario objectForKey:@"used"] longValue]];
    NSDate *stopDate = [date dateByAddingTimeInterval:[[self.scenario objectForKey:@"countdown"] longValue]];
    NSDate *now = [NSDate new];
    NSLog(@"%@ ~ %@ == %@", date, stopDate, now);
//    if ([now timeIntervalSince1970] - [stopDate timeIntervalSince1970] < 0) {
    [self.delegate showCountdown:self.scenario];
//    }
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
    UIAlertController *ac = nil;
    FeedbackType feedbackType = 0;
    UIColor *defaultColor = [AppDelegate AppConfigColor:@"CheckinButtonLeftColor"];
    UIColor *disabledColor = [AppDelegate AppConfigColor:@"DisabledButtonLeftColor"];
    NSDate *availableTime = [NSDate dateWithTimeIntervalSince1970:[[self.scenario objectForKey:@"available_time"] integerValue]];
    NSDate *expireTime = [NSDate dateWithTimeIntervalSince1970:[[self.scenario objectForKey:@"expire_time"] integerValue]];
    NSDate *nowTime = [NSDate new];
    BOOL isCheckin = [[[AppDelegate parseScenarioType:self.id] objectForKey:@"scenarioType"] isEqual:@"checkin"];
    
    __block AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    void (^use)(void) = ^{
        NSURL *url = [NSURL URLWithString:CC_USE([AppDelegate accessToken], self.id)];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            NSLog(@"JSON: %@", responseObject);
            if (responseObject != nil) {
                [self setUsed:[NSNumber numberWithBool:YES]];
                if ([[responseObject objectForKey:@"message"] isEqual:@"invalid token"]) {
                    NSLog(@"%@", [responseObject objectForKey:@"message"]);
//                    [self.checkinBtn setBackgroundColor:[UIColor redColor]];
                    [self.checkinBtn setGradientColor:[UIColor redColor]
                                                   To:[AppDelegate AppConfigColor:@"CheckinButtonRightColor"]
                                           StartPoint:CGPointMake(.2, .8)
                                              ToPoint:CGPointMake(1, .5)];
                } else if ([[responseObject objectForKey:@"message"] isEqual:@"has been used"]) {
                    [self showCountdown];
                    NSLog(@"%@", [responseObject objectForKey:@"message"]);
                    [UIView animateWithDuration:.25f
                                     animations:^{
//                                         [self.checkinBtn setBackgroundColor:[UIColor orangeColor]];
                                         [self.checkinBtn setGradientColor:[UIColor orangeColor]
                                                                        To:[AppDelegate AppConfigColor:@"CheckinButtonRightColor"]
                                                                StartPoint:CGPointMake(.2, .8)
                                                                   ToPoint:CGPointMake(1, .5)];
                                     }
                                     completion:^(BOOL finished) {
                                         if (finished) {
                                             [UIView animateWithDuration:1.75f
                                                              animations:^{
//                                                                  [self.checkinBtn setBackgroundColor:disabledColor];
                                                                  [self.checkinBtn setGradientColor:disabledColor
                                                                                                 To:[AppDelegate AppConfigColor:@"CheckinButtonRightColor"]
                                                                                         StartPoint:CGPointMake(.2, .8)
                                                                                            ToPoint:CGPointMake(1, .5)];
                                                              }];
                                         }
                                     }];
                } else if ([[responseObject objectForKey:@"message"] isEqual:@"link expired/not available now"]) {
                    NSLog(@"%@", [responseObject objectForKey:@"message"]);
                    [UIView animateWithDuration:.25f
                                     animations:^{
//                                         [self.checkinBtn setBackgroundColor:[UIColor orangeColor]];
                                         [self.checkinBtn setGradientColor:[UIColor orangeColor]
                                                                        To:[AppDelegate AppConfigColor:@"CheckinButtonRightColor"]
                                                                StartPoint:CGPointMake(.2, .8)
                                                                   ToPoint:CGPointMake(1, .5)];
                                         [self.checkinBtn setTitle:NSLocalizedString(@"ExpiredOrNotAvailable", nil)
                                                          forState:UIControlStateNormal];
                                     }
                                     completion:^(BOOL finished) {
                                         if (finished) {
                                             [UIView animateWithDuration:1.75f
                                                              animations:^{
//                                                                  [self.checkinBtn setBackgroundColor:defaultColor];
                                                                  [self.checkinBtn setGradientColor:defaultColor
                                                                                                 To:[AppDelegate AppConfigColor:@"CheckinButtonRightColor"]
                                                                                         StartPoint:CGPointMake(.2, .8)
                                                                                            ToPoint:CGPointMake(1, .5)];
                                                              }
                                                              completion:^(BOOL finished) {
                                                                  if (finished) {
                                                                      [UIView animateWithDuration:.25f
                                                                                       animations:^{
                                                                                           [self.checkinBtn setTitle:NSLocalizedString(isCheckin ? @"CheckinViewButton" : @"UseButton", nil)
                                                                                                            forState:UIControlStateNormal];
                                                                                       }];
                                                                  }
                                                              }];
                                         }
                                     }];
                } else {
                    [self updateScenario:[responseObject objectForKey:@"scenarios"]];
                    [self showCountdown];
//                    [self.checkinBtn setBackgroundColor:disabledColor];
                    [self.checkinBtn setGradientColor:disabledColor
                                                   To:[AppDelegate AppConfigColor:@"CheckinButtonRightColor"]
                                           StartPoint:CGPointMake(.2, .8)
                                              ToPoint:CGPointMake(1, .5)];
                    if (isCheckin) {
                        [self.checkinBtn setTitle:NSLocalizedString(@"CheckinViewButtonPressed", nil) forState:UIControlStateNormal];
                        [[AppDelegate appDelegate].checkinView reloadCard];
                    } else {
                        [self.checkinBtn setTitle:NSLocalizedString(@"UseButtonPressed", nil) forState:UIControlStateNormal];
                    }
                    [[AppDelegate appDelegate] setDefaultShortcutItems];
                }
            } else {
                // Invalid Network
                [self.delegate showInvalidNetworkMsg];
                // UIAlertController *ac = [UIAlertController alertOfTitle:NSLocalizedString(@"NetworkAlert", nil) withMessage:NSLocalizedString(@"NetworkAlertDesc", nil) cancelButtonText:NSLocalizedString(@"GotIt", nil) cancelStyle:UIAlertActionStyleCancel cancelAction:nil];
                // [ac showAlert:nil];
            }
        }];
        [dataTask resume];
    };
    
    if ([self.disabled boolValue]) {
        [UIView animateWithDuration:.25f
                         animations:^{
//                             [self.checkinBtn setBackgroundColor:[UIColor orangeColor]];
                             [self.checkinBtn setGradientColor:[UIColor orangeColor]
                                                            To:[AppDelegate AppConfigColor:@"CheckinButtonRightColor"]
                                                    StartPoint:CGPointMake(.2, .8)
                                                       ToPoint:CGPointMake(1, .5)];
                         }
                         completion:^(BOOL finished) {
                             if (finished) {
                                 [UIView animateWithDuration:1.75f animations:^{
//                                     [self.checkinBtn setBackgroundColor:disabledColor];
                                     [self.checkinBtn setGradientColor:disabledColor
                                                                    To:[AppDelegate AppConfigColor:@"CheckinButtonRightColor"]
                                                            StartPoint:CGPointMake(.2, .8)
                                                               ToPoint:CGPointMake(1, .5)];
                                 }];
                             }
                         }];
        SEND_FIB_EVENT(@"CheckinCardView", @{ @"Click": @"click_disabled" });
        feedbackType = NotificationFeedbackWarning;
    } else {
        if ([nowTime compare:availableTime] != NSOrderedAscending && [nowTime compare:expireTime] != NSOrderedDescending) {
            // IN TIME
            if (isCheckin) {
                use();
            } else {
                ac = [UIAlertController alertOfTitle:NSLocalizedString([@"UseButton_" stringByAppendingString:self.id], nil)
                                         withMessage:NSLocalizedString(@"ConfirmAlertText", nil)
                                    cancelButtonText:NSLocalizedString(@"Cancel", nil)
                                         cancelStyle:UIAlertActionStyleCancel
                                        cancelAction:nil];
                [ac addActionButton:NSLocalizedString(@"CONFIRM", nil)
                              style:UIAlertActionStyleDestructive
                            handler:^(UIAlertAction * _Nonnull action) {
                                use();
                            }];
            }
        } else {
            // OUT TIME
            if ([nowTime compare:availableTime] == NSOrderedAscending) {
                ac = [UIAlertController alertOfTitle:NSLocalizedString(@"NotAvailableTitle", nil)
                                         withMessage:NSLocalizedString(@"NotAvailableMessage", nil)
                                    cancelButtonText:NSLocalizedString(@"NotAvailableButtonOk", nil)
                                         cancelStyle:UIAlertActionStyleDestructive
                                        cancelAction:^(UIAlertAction *action) {
                                        }];
                feedbackType = NotificationFeedbackError;
            }
            if ([nowTime compare:expireTime] == NSOrderedDescending || [self.used boolValue]) {
                ac = [UIAlertController alertOfTitle:NSLocalizedString(@"ExpiredTitle", nil)
                                         withMessage:NSLocalizedString(@"ExpiredMessage", nil)
                                    cancelButtonText:NSLocalizedString(@"ExpiredButtonOk", nil)
                                         cancelStyle:UIAlertActionStyleDestructive
                                        cancelAction:^(UIAlertAction *action) {
                                        }];
                feedbackType = NotificationFeedbackError;
            }
        }
    }
    // only out time or need confirm will display alert controller
    if (ac != nil) {
        [ac showAlert:^{
            if (feedbackType != 0) {
                [AppDelegate triggerFeedback:feedbackType];
            }
        }];
    } else {
        if (feedbackType != 0) {
            [AppDelegate triggerFeedback:feedbackType];
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
