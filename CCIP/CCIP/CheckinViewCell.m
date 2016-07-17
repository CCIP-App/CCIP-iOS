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
        [self.checkinBtn setTitle:NSLocalizedString(@"CheckinViewButtonPressed", nil) forState:UIControlStateNormal];
    } else {
        [self.checkinBtn setTitle:NSLocalizedString(@"UseButtonPressed", nil) forState:UIControlStateNormal];
    }
    
    [self.checkinBtn setBackgroundColor:[UIColor colorWithRed:155/255.0 green:155/255.0 blue:155/255.0 alpha:1]];
}

@end
