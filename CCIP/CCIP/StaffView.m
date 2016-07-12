//
//  StaffView.m
//  CCIP
//
//  Created by Sars on 2016/07/10.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "AppDelegate.h"
#import "StaffView.h"
#import "GatewayWebService/GatewayWebService.h"
#import "StaffCell.h"

@interface StaffView()

@end

@implementation StaffView

-(void)awakeFromNib {
    [super awakeFromNib];
    
    [self.staffCollectionView registerNib:[UINib nibWithNibName:@"StaffCell" bundle:nil] forCellWithReuseIdentifier:@"StaffCell"];
    
    self.staffCollectionView.delegate = self;
    self.staffCollectionView.dataSource = self;
    
    GatewayWebService *program_ws = [[GatewayWebService alloc] initWithURL:STAFF_DATA_URL];
    [program_ws sendRequest:^(NSArray *json, NSString *jsonStr) {
        if (json != nil) {
            self.staffJsonArray = json;
            [self.staffCollectionView reloadData];
        }
    }];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"StaffView"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 100;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"StaffCell";
    StaffCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    
}

@end
