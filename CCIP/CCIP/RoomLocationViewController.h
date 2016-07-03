//
//  RoomLocationViewController.h
//  CCIP
//
//  Created by FrankWu on 2016/7/3.
//  Copyright © 2016年 FrankWu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ICViewPager/ViewPagerController.h>

@interface RoomLocationViewController : ViewPagerController

@property (strong, nonatomic) NSArray *rooms;
@property (strong, nonatomic) NSArray *roomPrograms;

@end

