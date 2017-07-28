//
//  ScheduleViewCell.m
//  CCIP
//
//  Created by 腹黒い茶 on 2016/08/01.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "ScheduleViewCell.h"
#import <CoreText/CoreText.h>

@implementation ScheduleViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    // set RoomLocationLabel
    // set font Monospaced
    NSArray *monospacedSetting = @[@{UIFontFeatureTypeIdentifierKey: @(kNumberSpacingType),
                                     UIFontFeatureSelectorIdentifierKey: @(kMonospacedNumbersSelector)}];
    UIFontDescriptor *newDescriptor = [[self.RoomLocationLabel.font fontDescriptor] fontDescriptorByAddingAttributes:@{UIFontDescriptorFeatureSettingsAttribute: monospacedSetting}];
    // Size 0 to use previously set font size
    [self.RoomLocationLabel setFont:[UIFont fontWithDescriptor:newDescriptor size:0]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
