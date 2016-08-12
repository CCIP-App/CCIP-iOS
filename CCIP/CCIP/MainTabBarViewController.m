//
//  MainTabBarViewController.m
//  CCIP
//
//  Created by Sars on 7/16/16.
//  Copyright © 2016 CPRTeam. All rights reserved.
//

#import "MainTabBarViewController.h"
#import "GatewayWebService/GatewayWebService.h"
#import "NSInvocation+addition.h"
#import "UIImage+addition.h"
#import "ScheduleViewController.h"
#import "MoreTableViewController.h"
#import "AppDelegate.h"
#import <UICKeyChainStore/UICKeyChainStore.h>
#import <Shimmer/FBShimmeringView.h>

@interface MainTabBarViewController ()

@property (strong, nonatomic) FBShimmeringView *shimmeringLogoView;

@end

@implementation MainTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor *titleHighlightedColor = [UIColor colorWithRed:65/255.0 green:117/255.0 blue:5/255.0 alpha:1.0];
    
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    
    UIView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"coscup-logo"]];
    self.shimmeringLogoView = [[FBShimmeringView alloc] initWithFrame:logoView.bounds];
    self.shimmeringLogoView.contentView = logoView;
    
    self.shimmeringLogoView.shimmering = [AppDelegate isDevMode];
    
    self.navigationItem.titleView = self.shimmeringLogoView;
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor grayColor], NSForegroundColorAttributeName, nil]
                                             forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:titleHighlightedColor, NSForegroundColorAttributeName, nil]
                                             forState:UIControlStateSelected];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appplicationIsActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    // setting selected image color from original image with replace custom color filter
    for(UITabBarItem *item in self.tabBar.items) {
        UIImage *image = [item.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        image = [image imageWithColor:titleHighlightedColor];
        [item setSelectedImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    }
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.titleView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navSingleTap)];
    [self.navigationItem.titleView addGestureRecognizer:tapGesture];
}

- (void)navSingleTap
{
    //NSLog(@"navSingleTap");
    [self handleNavTapTimes];
}

- (void)handleNavTapTimes {
    static int tapTimes = 0;
    static NSDate *oldTapTime;
    static NSDate *newTapTime;
    
    newTapTime = [NSDate date];
    if (oldTapTime == nil) {
        oldTapTime = newTapTime;
    }
    
    switch (self.selectedIndex) {
        case 0: {
            if ([AppDelegate isDevMode]) {
                //NSLog(@"navSingleTap from MoreTab");
                if ([newTapTime timeIntervalSinceDate: oldTapTime] <= 0.25f) {
                    tapTimes++;
                    if (tapTimes == 10) {
                        NSLog(@"--  Success tap 10 times  --");
                        if ([AppDelegate haveAccessToken]) {
                            NSLog(@"-- Clearing the Token --");
                            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                            [AppDelegate setAccessToken:@""];
                            [[AppDelegate appDelegate].checkinView reloadCard];
                        } else {
                            NSLog(@"-- Token is already clear --");
                        }
                    }
                }
                else {
                    NSLog(@"--  Failed, just tap %2d times  --", tapTimes);
                    NSLog(@"-- Not trigger clean token --");
                    tapTimes = 1;
                }
                oldTapTime = newTapTime;
            }
            break;
        }
        case 4: {
            //NSLog(@"navSingleTap from MoreTab");
            if ([newTapTime timeIntervalSinceDate: oldTapTime] <= 0.25f) {
                tapTimes++;
                if (tapTimes == 10) {
                    NSLog(@"--  Success tap 10 times  --");
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    
                    if (![AppDelegate isDevMode]) {
                        NSLog(@"-- Enable DEV_MODE --");
                        [AppDelegate setIsDevMode: YES];
                        self.shimmeringLogoView.shimmering = YES;
                    } else {
                        NSLog(@"-- Disable DEV_MODE --");
                        [AppDelegate setIsDevMode:NO];
                        self.shimmeringLogoView.shimmering = NO;
                    }
                }
            }
            else {
                NSLog(@"--  Failed, just tap %2d times  --", tapTimes);
                NSLog(@"-- Failed to trigger DEV_MODE --");
                tapTimes = 1;
            }
            oldTapTime = newTapTime;
            break;
        }
        default:
            break;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self handleShortcutItem];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self handleShortcutItem];
}

- (void)appplicationIsActive:(NSNotification *)notification {
    NSLog(@"Application Did Become Active");
    [self handleShortcutItem];
}

- (void)handleShortcutItem {
    NSObject *mainTabBarViewIndexObj = [[NSUserDefaults standardUserDefaults] objectForKey:@"MainTabBarViewIndex"];
    if (mainTabBarViewIndexObj) {
        NSInteger index = [(NSNumber*)mainTabBarViewIndexObj integerValue];
        [self setSelectedIndex:index];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MainTabBarViewIndex"];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    switch ([self selectedIndex]) {
        case 1:
        {
            NSObject *scheduleIndexTextObj = [[NSUserDefaults standardUserDefaults] objectForKey:@"ScheduleIndexText"];
            if (scheduleIndexTextObj) {
                NSString *scheduleIndexText = (NSString*)scheduleIndexTextObj;
                [NSInvocation InvokeObject:[[self viewControllers] objectAtIndex:1]
                        withSelectorString:@"setSegmentedAndTableWithText:"
                             withArguments:@[ scheduleIndexText ]];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ScheduleIndexText"];
            }
            break;
        }
        default:
            break;
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
