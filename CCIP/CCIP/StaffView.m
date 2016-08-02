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
#import <SDWebImage/UIImageView+WebCache.h>

@interface StaffView()

@end

@implementation StaffView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.staffCollectionView registerNib:[UINib nibWithNibName:@"StaffCell" bundle:nil] forCellWithReuseIdentifier:@"StaffCell"];
    
    self.staffCollectionView.delegate = self;
    self.staffCollectionView.dataSource = self;
    
    SEND_GAI(@"StaffView");
}

- (void)setGroup:(NSArray *)scenario {
    self.staffJsonArray = scenario;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.staffJsonArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"StaffCell";
    StaffCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    NSString *avatar = [[[self.staffJsonArray objectAtIndex:indexPath.row] objectForKey:@"profile"] objectForKey:@"avatar"];
    if (![avatar containsString:@"http"]) {
        avatar = [[NSString alloc] initWithFormat:@"https://staff.coscup.org%@", avatar];
    } else {
        avatar = [avatar stringByAppendingString:@"&s=200"];
    }
    
    // not work
    cell.staffImg.image = [UIImage imageNamed:@"StaffIconDefault"];
    
    
    // Here we use the new provided sd_setImageWithURL: method to load the web image
    [cell.staffImg sd_setImageWithURL:[NSURL URLWithString:avatar]
                     placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"avatar_pk_%@.png", [[self.staffJsonArray objectAtIndex:indexPath.row] objectForKey:@"pk"]]]
                              options:indexPath.row == 0 ? SDWebImageRefreshCached : 0];
    
    cell.staffTitle.text = [[[self.staffJsonArray objectAtIndex:indexPath.row] objectForKey:@"profile"] objectForKey:@"title"];
    cell.staffName.text = [[[self.staffJsonArray objectAtIndex:indexPath.row] objectForKey:@"profile"] objectForKey:@"display_name"];
    return cell;
}

@end
