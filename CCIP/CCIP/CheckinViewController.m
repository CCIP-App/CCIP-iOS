//
//  CheckinViewController.m
//  CCIP
//
//  Created by Sars on 7/17/16.
//  Copyright © 2016 CPRTeam. All rights reserved.
//
#define TAG 99

#import "CheckinViewController.h"
#import "CheckinViewCell.h"
#import "AppDelegate.h"
#import "GatewayWebService/GatewayWebService.h"
#import <Google/Analytics.h>

@interface CheckinViewController () <UICollectionViewDataSource>

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) NSDictionary *userInfo;
@property (strong, nonatomic) NSArray *scenarios;

@end

@implementation CheckinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
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
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"CheckinViewController"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if ([self.scenarios count] > 2) {
        // Hard code...
        return 3;
    }
    
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CheckinViewCell *cell = (CheckinViewCell  *)[collectionView dequeueReusableCellWithReuseIdentifier:@"reuse" forIndexPath:indexPath];
    [cell.checkinBtn setBackgroundColor:[UIColor colorWithRed:61/255.0 green:152/255.0 blue:60/255.0 alpha:1]];
    
    // If the time is before 2016/08/20 17:00:00 show day 1, otherwise show day 2
    NSString *checkId, *lunchId;
    if ([self.appDelegate showWhichDay] == 1) {
        checkId = @"day1checkin";
        lunchId = @"day1lunch";
    } else {
        checkId = @"day2checkin";
        lunchId = @"day2lunch";
        [cell.checkinDate setText:@"8/21"];
    }
    
    switch (indexPath.section) {
        case 0:
            [cell setId:checkId];
            [cell.checkinTitle setText:NSLocalizedString(@"Checkin", nil)];
            [cell.checkinText setText:NSLocalizedString(@"CheckinText", nil)];
            [cell.checkinBtn setTitle:NSLocalizedString(@"CheckinViewButton", nil)
                             forState:UIControlStateNormal];
            
            // TODO: pre-load current used status into UI
            break;
        case 1:
            [cell setId:@"kit"];
            [cell.checkinDate setText:@"COSCUP"];
            [cell.checkinTitle setText:NSLocalizedString(@"kit", nil)];
            [cell.checkinText setText:NSLocalizedString(@"CheckinNotice", nil)];
            [cell.checkinBtn setTitle:NSLocalizedString(@"UseButton", nil)
                             forState:UIControlStateNormal];
            
            // TODO: pre-load current used status into UI
            break;
        case 2:
            [cell setId:lunchId];
            [cell.checkinTitle setText:NSLocalizedString(@"lunch", nil)];
            [cell.checkinText setText:NSLocalizedString(@"CheckinNotice", nil)];
            [cell.checkinBtn setTitle:NSLocalizedString(@"UseButton", nil)
                             forState:UIControlStateNormal];
            
            // TODO: pre-load current used status into UI
            break;
        default:
            break;
    }
    [self configureCell:cell withIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(CheckinViewCell *)cell withIndexPath:(NSIndexPath *)indexPath {
    UIView  *subview = [cell.contentView viewWithTag:TAG];
    [subview removeFromSuperview];
    
    switch (indexPath.section) {
        case 0:
            break;
        case 1:
            break;
        case 2:
            break;
        default:
            break;
    }
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
