//
//  CheckinViewController.m
//  CCIP
//
//  Created by Sars on 7/17/16.
//  Copyright © 2016 CPRTeam. All rights reserved.
//
#define TAG 99

#import <Google/Analytics.h>
#import "GatewayWebService/GatewayWebService.h"
#import "AppDelegate.h"
#import "CheckinCardViewController.h"
#import "CheckinViewController.h"
#import "GuideViewController.h"

@interface CheckinViewController()

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) NSDictionary *userInfo;
@property (strong, nonatomic) NSArray *scenarios;
@property (strong, nonatomic) GuideViewController *guideViewController;

@end

@implementation CheckinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self.appDelegate setCheckinView:self];
    
    //configure carousel
    self.cards.type = iCarouselTypeLinear;
    self.cards.pagingEnabled = YES;
    self.cards.bounceDistance = 0.3f;
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"CheckinViewController"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CGFloat topGuide = 0.0;
    CGFloat bottomGuide = 0.0;
    if (self.navigationController.navigationBar.translucent) {
        if (self.prefersStatusBarHidden == NO) topGuide += 20;
        if (self.navigationController.navigationBarHidden == NO) topGuide += self.navigationController.navigationBar.bounds.size.height;
    }
    if (self.tabBarController.tabBar.hidden == NO) bottomGuide += self.tabBarController.tabBar.bounds.size.height;
    
    self.view.frame = CGRectMake(0, topGuide, self.view.frame.size.width, self.view.frame.size.height - topGuide - bottomGuide);
    
    [self reloadCard];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideGuideView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *destination = segue.destinationViewController;
    if ([destination isMemberOfClass:[GuideViewController class]]) {
        self.guideViewController = (GuideViewController *)destination;
    }
}

- (void)hideGuideView {
    if (self.guideViewController != nil) {
        [self.guideViewController dismissViewControllerAnimated:YES
                                                     completion:^{
                                                         self.guideViewController = nil;
                                                     }];
    }
}

- (void)reloadCard {
    BOOL hasToken = [self.appDelegate.accessToken length] > 0;
    if (!hasToken) {
        [self performSegueWithIdentifier:@"ShowGuide"
                                  sender:self.cards];
    } else {
        [self hideGuideView];
        GatewayWebService *ws = [[GatewayWebService alloc] initWithURL:CC_STATUS(self.appDelegate.accessToken)];
        [ws sendRequest:^(NSDictionary *json, NSString *jsonStr) {
            if (json != nil) {
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:json];
                [userInfo removeObjectForKey:@"scenarios"];
                self.userInfo = [NSDictionary dictionaryWithDictionary:userInfo];
                self.scenarios = [json objectForKey:@"scenarios"];
                [self.appDelegate.oneSignal sendTag:@"user_id" value:[json objectForKey:@"user_id"]];
                [self.cards reloadData];
            }
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    //return the total number of items in the carousel
    if ([self.scenarios count] > 2 && [self.appDelegate showWhichDay] == 1) {
        // Hard code...
        return 3;
    } else {
        return [self.scenarios count];
    }
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    //    UILabel *label = nil;
    
    //create new view if no view is available for recycling
    if (view == nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle:nil];
        CheckinCardViewController *temp = (CheckinCardViewController *)[storyboard instantiateViewControllerWithIdentifier:@"CheckinCardReuseView"];
        
        [temp.view setFrame:CGRectMake(0, 0, self.view.frame.size.width - 80, self.view.frame.size.height - 100)];
        view = (UIView*)temp.view;
        
        NSInteger idx = 1;
        
        // If the time is before 2016/08/20 17:00:00 show day 1, otherwise show day 2
        NSString *checkId, *lunchId, *dateId;
        if ([self.appDelegate showWhichDay] == 1) {
            checkId = @"day1checkin";
            lunchId = @"day1lunch";
            dateId = @"8/20";
            
            if (index == 0) {
                idx = 0;
            } else if (index == 2) {
                idx = 2;
            }
        } else {
            checkId = @"day2checkin";
            lunchId = @"day2lunch";
            dateId = @"8/21";
            
            if (index == 0) {
                idx = 3;
            } else if (index == 2) {
                idx = 4;
            }
        }
        bool isCheckin = NO;
        switch (index) {
            case 0:
                isCheckin = YES;
                [temp setId:checkId];
                [temp.checkinDate setText:dateId];
                [temp.checkinTitle setText:NSLocalizedString(@"Checkin", nil)];
                [temp.checkinText setText:NSLocalizedString(@"CheckinText", nil)];
                break;
            case 1:
                isCheckin = NO;
                [temp setId:@"kit"];
                [temp.checkinDate setText:@"COSCUP"];
                [temp.checkinTitle setText:NSLocalizedString(@"kit", nil)];
                [temp.checkinText setText:NSLocalizedString(@"CheckinNotice", nil)];
                break;
            case 2:
                isCheckin = YES;
                [temp setId:lunchId];
                [temp.checkinDate setText:dateId];
                [temp.checkinTitle setText:NSLocalizedString(@"lunch", nil)];
                [temp.checkinText setText:NSLocalizedString(@"CheckinNotice", nil)];
                break;
            default:
                break;
        }
        
        if ([self.scenarios[idx] objectForKey:@"used"]) {
            if (isCheckin) {
                [temp.checkinBtn setTitle:NSLocalizedString(@"CheckinViewButtonPressed", nil)
                                 forState:UIControlStateNormal];
            } else {
                [temp.checkinBtn setTitle:NSLocalizedString(@"UseButtonPressed", nil)
                                 forState:UIControlStateNormal];
            }
            [temp.checkinBtn setBackgroundColor:[UIColor grayColor]];
        } else {
            if (isCheckin) {
                [temp.checkinBtn setTitle:NSLocalizedString(@"CheckinViewButton", nil)
                                 forState:UIControlStateNormal];
            } else {
                [temp.checkinBtn setTitle:NSLocalizedString(@"UseButton", nil)
                                 forState:UIControlStateNormal];
            }
            [temp.checkinBtn setBackgroundColor:[UIColor colorWithRed:61/255.0 green:152/255.0 blue:60/255.0 alpha:1]];
        }
    } else {
        //get a reference to the label in the recycled view
        //        label = (UILabel *)[view viewWithTag:1];
    }
    
    //set item label
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    //    label.text = [_items[index] stringValue];
    
    return view;
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    switch (option) {
        case iCarouselOptionWrap: {
            //normally you would hard-code this to YES or NO
            return NO;
        }
        case iCarouselOptionSpacing: {
            //add a bit of spacing between the item views
            return value * 1.08f;
        }
        case iCarouselOptionFadeMax: {
            if (self.cards.type == iCarouselTypeCustom) {
                //set opacity based on distance from camera
                return 0.0f;
            }
            return value;
        }
        case iCarouselOptionShowBackfaces:
        case iCarouselOptionRadius:
        case iCarouselOptionAngle:
        case iCarouselOptionArc:
        case iCarouselOptionTilt:
        case iCarouselOptionCount:
        case iCarouselOptionFadeMin:
        case iCarouselOptionFadeMinAlpha:
        case iCarouselOptionFadeRange:
        case iCarouselOptionOffsetMultiplier:
        case iCarouselOptionVisibleItems: {
            return value;
        }
    }
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
