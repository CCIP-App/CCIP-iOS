//
//  AnnounceTableViewCell.m
//  CCIP
//
//  Created by Sars on 8/10/16.
//  Copyright © 2016 CPRTeam. All rights reserved.
//

#import "AnnounceTableViewCell.h"

@implementation AnnounceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    float width = [UIScreen mainScreen].applicationFrame.size.width;
    self.msg.preferredMaxLayoutWidth = width - 48;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
