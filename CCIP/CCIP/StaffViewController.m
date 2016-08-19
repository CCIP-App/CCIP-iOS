//
//  StaffViewController.m
//  CCIP
//
//  Created by Sars on 2016/07/10.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "GatewayWebService/GatewayWebService.h"
#import "AppDelegate.h"
#import "StaffViewController.h"
#import "StaffCell.h"

@interface StaffViewController()

@end

@implementation StaffViewController

static NSString *identifier = @"StaffCell";

- (void)awakeFromNib {
    [super awakeFromNib];
    
    SEND_GAI(@"StaffView");
}

- (void)setGroupData:(NSDictionary *)groupData {
    NSMutableArray *staffArray = [NSMutableArray arrayWithArray:[groupData objectForKey:@"users"]];
    NSString *groupName = [groupData objectForKey:@"name"];

    //handle cross grops's staff move to bottom
    for (int i = 0; i < [staffArray count]; i++) {
        id staff = [staffArray objectAtIndex:i];
        NSString *title = [[staff valueForKey:@"profile"] valueForKey:@"title"];
        if (![title hasPrefix:[groupName substringToIndex:2]]) {
            [staffArray addObject:staff];
            [staffArray removeObjectAtIndex:i];
        }
    }
    
    self.staffJsonArray = staffArray;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.staffJsonArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id staff = [self.staffJsonArray objectAtIndex:indexPath.row];
    StaffCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                forIndexPath:indexPath];
    NSDictionary *profile = [staff objectForKey:@"profile"];
    NSString *avatar = STAFF_AVATAR([profile objectForKey:@"avatar"]);
    UIImage *defaultIcon = [UIImage imageNamed:@"StaffIconDefault"];
    
    [cell.staffTitle setText:[profile objectForKey:@"title"]];
    [cell.staffName setText:[profile objectForKey:@"display_name"]];
    [cell.staffImg setImage:defaultIcon];
    
    // Here we use the new provided sd_setImageWithURL: method to load the web image
    [cell.staffImg sd_setImageWithURL:[NSURL URLWithString:avatar]
                     placeholderImage:defaultIcon
                              options:indexPath.row == 0 ? SDWebImageRefreshCached : 0];
    
    return cell;
}

@end
