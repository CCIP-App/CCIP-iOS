//
//  ScheduleTableViewController.h
//  CCIP
//
//  Created by FrankWu on 2017/7/16.
//  Copyright © 2017年 CPRTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ScheduleViewPagerController.h"

#define FAV_KEY         (@"favoriteSchedules")

@interface ScheduleTableViewController : UITableViewController<UIViewControllerPreviewingDelegate, ScheduleFavoriteDelegate>

@property (strong, nonatomic) ScheduleViewPagerController *pagerController;
@property (strong, nonatomic) NSMutableDictionary *programs;

@end
