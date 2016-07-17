//
//  CheckinViewCell.m
//  CCIP
//
//  Created by Sars on 7/17/16.
//  Copyright © 2016 CPRTeam. All rights reserved.
//

#import "CheckinViewCell.h"

@implementation CheckinViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.checkinBtn.layer.cornerRadius = 10.0f;
    [self.checkinBtn addTarget:self action:@selector(checkinBtnTouched) forControlEvents:UIControlEventTouchUpInside];
}

- (void)checkinBtnTouched {
    if ([self.id isEqualToString:@"day1checkin"] || [self.id isEqualToString:@"day2checkin"]) {
        // TODO: Send API request
        
        [self.checkinBtn setTitle:NSLocalizedString(@"CheckinViewButtonPressed", nil) forState:UIControlStateNormal];
        [self.checkinBtn setBackgroundColor:[UIColor colorWithRed:155/255.0 green:155/255.0 blue:155/255.0 alpha:1]];
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"UseButton", nil) message:NSLocalizedString(@"ConfirmAlertText", nil) preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"CONFIRM" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            // TODO: Send API request
            
            [self.checkinBtn setTitle:NSLocalizedString(@"UseButtonPressed", nil) forState:UIControlStateNormal];
            [self.checkinBtn setBackgroundColor:[UIColor colorWithRed:155/255.0 green:155/255.0 blue:155/255.0 alpha:1]];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        
        [alertController addAction:confirmAction];
        [alertController addAction:cancelAction];
        
        UIViewController *topVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        while (topVC.presentedViewController) {
            topVC = topVC.presentedViewController;
        }
        [topVC presentViewController:alertController animated:YES completion:nil];
    }
}

@end
