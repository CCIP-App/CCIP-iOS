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
#import <Google/Analytics.h>

@interface CheckinViewController () <UICollectionViewDataSource>

@end

@implementation CheckinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"CheckinViewController"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CheckinViewCell *cell = (CheckinViewCell  *)[collectionView dequeueReusableCellWithReuseIdentifier:@"reuse" forIndexPath:indexPath];
    [cell.checkinBtn setBackgroundColor:[UIColor colorWithRed:61/255.0 green:152/255.0 blue:60/255.0 alpha:1]];
    
    switch (indexPath.section) {
        case 0:
            [cell setId:@"day1checkin"];
            [cell.checkinTitle setText:NSLocalizedString(@"Checkin", nil)];
            [cell.checkinText setText:NSLocalizedString(@"CheckinText", nil)];
            [cell.checkinBtn setTitle:NSLocalizedString(@"CheckinViewButton", nil)
                             forState:UIControlStateNormal];
            
            // TODO: pre-load current used status into UI
            break;
        case 1:
            [cell setId:@"kit"];
            [cell.checkinTitle setText:NSLocalizedString(@"kit", nil)];
            [cell.checkinText setText:NSLocalizedString(@"CheckinNotice", nil)];
            [cell.checkinBtn setTitle:NSLocalizedString(@"UseButton", nil)
                             forState:UIControlStateNormal];
            
            // TODO: pre-load current used status into UI
            break;
        case 2:
            [cell setId:@"day1lunch"];
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
