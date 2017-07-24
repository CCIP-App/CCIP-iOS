//
//  ScheduleTableViewCell.h
//  CCIP
//
//  Created by FrankWu on 2017/7/16.
//  Copyright © 2017年 CPRTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScheduleFavoriteDelegate.h"

@interface ScheduleTableViewCell : UITableViewCell

@property (weak, nonatomic) id<ScheduleFavoriteDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *ScheduleTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *RoomLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *LabelLabel;
@property (weak, nonatomic) IBOutlet UIButton *FavoriteButton;

- (void)setSchedule:(NSDictionary *)schedule;
- (NSDictionary *)getSchedule;
- (void)setFavorite:(BOOL)favorite;
- (BOOL)getFavorite;
- (IBAction)favoriteAction:(id)sender;

@end
