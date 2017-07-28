//
//  StaffCell.m
//  CCIP
//
//  Created by Sars on 2016/07/10.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "StaffCell.h"

@implementation StaffCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.backgroundColor = [UIColor whiteColor];
    [self.layer setCornerRadius:5.0f];
    [self.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [self.layer setBorderWidth:0.3f];
    [self.layer setShadowColor:[[UIColor grayColor] CGColor]];
    [self.layer setShadowOpacity:0.3f];
    [self.layer setShadowOffset:CGSizeMake(5.0f, 10.0f)];
    [self.layer setMasksToBounds:NO];
}

@end
