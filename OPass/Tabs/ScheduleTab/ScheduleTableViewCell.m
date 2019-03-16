//
//  ScheduleTableViewCell.m
//  CCIP
//
//  Created by FrankWu on 2017/7/16.
//  Copyright © 2017年 CPRTeam. All rights reserved.
//

#import "ScheduleTableViewCell.h"
#import "AppDelegate.h"

@interface ScheduleTableViewCell()

@property (readwrite, nonatomic) BOOL favorite;
@property (strong, nonatomic) NSDictionary *schedule;
@property (readwrite, nonatomic) BOOL disabled;

@end

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

- (NSString *)getID {
    if (self.schedule) {
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(getID:)]) {
                return [self.delegate getID:_schedule];
            }
        }
        return @"";
    } else {
        return @"";
    }
}

- (void)setSchedule:(NSDictionary *)schedule {
    _schedule = schedule;
    NSDate *startTime = [Constants DateFromString:[_schedule objectForKey:@"start"]];
    NSDate *endTime = [Constants DateFromString:[_schedule objectForKey:@"end"]];
    long mins = [[NSNumber numberWithDouble:([endTime timeIntervalSinceDate:startTime] / 60)] longValue];
    NSString *type = [Constants GetScheduleTypeName:[_schedule objectForKey:@"type"]];
    NSDictionary *currentLangObject = [_schedule objectForKey:[AppDelegate shortLangUI]];
    [self.ScheduleTitleLabel setText:[currentLangObject objectForKey:@"title"]];
    [self.RoomLocationLabel setText:[NSString stringWithFormat:@"Room %@ - %ld mins", [_schedule objectForKey:@"room"], mins]];
    [self.LabelLabel setText:[NSString stringWithFormat:@"   %@   ", type]];
    [self.LabelLabel.layer setCornerRadius:self.LabelLabel.frame.size.height / 2];
    [self.LabelLabel sizeToFit];
    [self.LabelLabel setHidden:[type length] == 0];
    [self setFavorite:NO];
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(hasFavorite:)]) {
            [self setFavorite:[self.delegate hasFavorite:[self getID]]];
        }
    }
}

- (NSDictionary *)getSchedule {
    return _schedule;
}

- (IBAction)favoriteTouchDownAction:(id)sender {
    [UIImpactFeedback triggerFeedback:UIImpactFeedbackTypeImpactFeedbackMedium];
}

- (IBAction)favoriteTouchUpInsideAction:(id)sender {
    self.favorite = !self.favorite;
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(actionFavorite:)]) {
            [self.delegate actionFavorite:[self getID]];
        }
    }
    [UIImpactFeedback triggerFeedback:UIImpactFeedbackTypeImpactFeedbackLight];
}

- (IBAction)favoriteTouchUpOutsideAction:(id)sender {
    [UIImpactFeedback triggerFeedback:UIImpactFeedbackTypeImpactFeedbackLight];
}

- (void)setFavorite:(BOOL)favorite {
    _favorite = favorite;
    NSDictionary *titleAttribute = @{
                                     NSFontAttributeName: [Constants fontOfAwesomeWithSize:20 inStyle:(_favorite ? fontAwesomeStyleSolid : fontAwesomeStyleRegular)],
                                     NSForegroundColorAttributeName: [AppDelegate AppConfigColor:@"FavoriteButtonColor"],
                                     };
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:[Constants fontAwesomeWithCode:@"fa-heart"] attributes:titleAttribute];
    [self.FavoriteButton setAttributedTitle:title
                                   forState:UIControlStateNormal];
}

- (BOOL)getFavorite {
    return _favorite;
}

- (void)setDisabled:(BOOL)disabled {
    _disabled = disabled;
    [self.ScheduleTitleLabel setAlpha:_disabled ? .2f : 1];
}

- (BOOL)getDisabled {
    return _disabled;
}

@end
