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
#import "NSInvocation+addition.h"
#import "NavigationController.h"
#import "MasterViewController.h"
#import "CheckinViewController.h"

#define STRINGIZE(x)                    #x
#define STRINGIZE2(x)                   STRINGIZE(x)
#define SOURCE_ROOT                     @ STRINGIZE2(SRC_ROOT)
#define __GAI(gai, name)                ([AppDelegate sendGAI:gai WithName:name Func:__func__ File:__FILE__ Line:__LINE__])
#define SEND_GAI(name)                  (__GAI( [[GAIDictionaryBuilder createScreenView] build], name ))
#define SEND_GAI_EVENT(name, nibName)   (__GAI( [[GAIDictionaryBuilder createEventWithCategory:name action:nibName label:nil value:nil] build], nil ))

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic)  UIWindow * _Null_unspecified window;
@property (strong, readonly, nonatomic) OneSignal * _Null_unspecified oneSignal;
@property (strong, readonly, nonatomic) SLColorArt * _Null_unspecified appArt;
@property (strong, nonatomic) NSString * _Null_unspecified accessToken;
@property (strong, nonatomic) NavigationController * _Null_unspecified navigationView;
@property (strong, nonatomic) MasterViewController * _Null_unspecified masterView;
@property (strong, nonatomic) CheckinViewController * _Null_unspecified checkinView;

+ (void)sendGAI:( NSDictionary * _Nonnull )_gai WithName:( NSString * _Nullable )_name Func:( const char * _Nonnull )_func File:( const char * _Nonnull )_file Line:(int)_line;
- (NSInteger)showWhichDay;

@end

