//
//  ScheduleTableViewCell.m
//  CCIP
//
//  Created by FrankWu on 2017/7/16.
//  Copyright © 2017年 CPRTeam. All rights reserved.
//

#import "ScheduleTableViewCell.h"
#import "UIColor+addition.h"

@implementation ScheduleTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.LabelLabel setTextColor:[UIColor colorFromHtmlColor:@"#9B9B9B"]];
    [self.LabelLabel setBackgroundColor:[UIColor colorFromHtmlColor:@"#D8D8D8"]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
