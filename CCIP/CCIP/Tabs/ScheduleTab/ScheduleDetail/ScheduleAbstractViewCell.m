//
//  ScheduleAbstractViewController.m
//  CCIP
//
//  Created by 腹黒い茶 on 2017/07/21.
//  Copyright © 2017年 CPRTeam. All rights reserved.
//

#import "ScheduleAbstractViewCell.h"

@interface ScheduleAbstractViewCell ()

@end

@implementation ScheduleAbstractViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (CGSize)sizeThatFits:(CGSize)size {
    // add LineSpacing setting.
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 2.0;
    
    // counting label height
    CGSize constraintRect = CGSizeMake(290.0, MAXFLOAT);
    CGRect boundingBox = [self.lbAbstractContent.text boundingRectWithSize:constraintRect options: NSStringDrawingUsesLineFragmentOrigin attributes: @{ NSFontAttributeName: self.lbAbstractContent.font, NSParagraphStyleAttributeName: paragraphStyle } context:nil];
    
    // counting cell height
    CGFloat newHeight = 81.0 +  boundingBox.size.height + 48.0;
    
    CGSize newsize = CGSizeMake(size.width, newHeight);
    return newsize;
}

@end
