//
//  AppDelegate.h
//  CCIP
//
//  Created by 腹黒い茶 on 2016/06/24.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OneSignal/OneSignal.h>
#import <ColorArt/UIImage+ColorArt.h>
#import "NavigationController.h"
#import "MasterViewController.h"
#import "NSInvocation+addition.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, readonly, nonatomic) OneSignal *oneSignal;
@property (strong, readonly, nonatomic) SLColorArt *appArt;
@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NavigationController *navigationView;
@property (strong, nonatomic) MasterViewController *masterView;

- (NSInteger)showWhichDay;

@end

