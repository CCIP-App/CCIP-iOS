//
//  ProgramDetailViewPagerController.h
//  CCIP
//
//  Created by FrankWu on 2016/7/19.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import <ICViewPager/ViewPagerController.h>

@interface ProgramDetailViewPagerController : ViewPagerController<ViewPagerDataSource, ViewPagerDelegate>

@property (strong, nonatomic) NSDictionary *program;

@end
