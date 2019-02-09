//
//  ScheduleViewPagerController.h
//  CCIP
//
//  Created by FrankWu on 2017/7/16.
//  Copyright © 2017年 CPRTeam. All rights reserved.
//

#import <ICViewPager/ViewPagerController.h>

@interface ScheduleViewPagerController : ViewPagerController<ViewPagerDataSource, ViewPagerDelegate>

@property (strong, nonatomic) NSDate *selected_section;
@property (strong, readonly, nonatomic) NSDate *today;

@end
