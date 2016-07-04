//
//  AppDelegate.h
//  CCIP
//
//  Created by 腹黒い茶 on 2016/06/24.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OneSignal/OneSignal.h>
#import "MasterViewController.h"
#import "DetailViewController.h"
#import "NSInvocation+addition.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, readonly, nonatomic) NSString *accessToken;
@property (strong, readonly, nonatomic) UISplitViewController *splitViewController;
@property (strong, readonly, nonatomic) MasterViewController *masterView;
@property (strong, readonly, nonatomic) DetailViewController *detailView;
@property (strong, readonly, nonatomic) UINavigationController *masterNav;
@property (strong, readonly, nonatomic) UINavigationController *detailNav;

@end

