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
    // Initialization code
    [self.checkinBtn setBackgroundColor:[UIColor colorWithRed:61/255.0 green:152/255.0 blue:60/255.0 alpha:1]];
    self.checkinBtn.layer.cornerRadius = 10.0f;
}

@end
