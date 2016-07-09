//
//  AppDelegate.h
//  CCIP
//
//  Created by 腹黒い茶 on 2016/06/24.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OneSignal/OneSignal.h>
#import "SplitViewController.h"
#import "MasterViewController.h"
#import "DetailViewController.h"
#import "NSInvocation+addition.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, readonly, nonatomic) OneSignal *oneSignal;
@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) SplitViewController *splitViewController;
@property (strong, nonatomic) MasterViewController *masterView;
@property (strong, nonatomic) DetailViewController *detailView;

@end

