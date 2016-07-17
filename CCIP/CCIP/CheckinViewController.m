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

@interface CheckinViewController () <UICollectionViewDataSource>

@end

@implementation CheckinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 3;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CheckinViewCell *cell = (CheckinViewCell  *)[collectionView dequeueReusableCellWithReuseIdentifier:@"reuse" forIndexPath:indexPath];
    [cell.checkinBtn setBackgroundColor:[UIColor colorWithRed:61/255.0 green:152/255.0 blue:60/255.0 alpha:1]];
    
    switch (indexPath.section) {
        case 0:
            cell.id = @"day1checkin";
            cell.checkinTitle.text = NSLocalizedString(@"Checkin", nil);
            [cell.checkinBtn setTitle:NSLocalizedString(@"CheckinViewButton", nil) forState:UIControlStateNormal];
            break;
        case 1:
            cell.id = @"kit";
            cell.checkinTitle.text = NSLocalizedString(@"kit", nil);
            [cell.checkinBtn setTitle:NSLocalizedString(@"UseButton", nil) forState:UIControlStateNormal];
            break;
        case 2:
            cell.id = @"day1lunch";
            cell.checkinTitle.text = NSLocalizedString(@"lunch", nil);
            [cell.checkinBtn setTitle:NSLocalizedString(@"UseButton", nil) forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    [self configureCell:cell withIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(CheckinViewCell *)cell withIndexPath:(NSIndexPath *)indexPath
{
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
