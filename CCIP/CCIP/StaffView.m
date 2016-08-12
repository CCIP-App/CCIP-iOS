//
//  StaffView.m
//  CCIP
//
//  Created by Sars on 2016/07/10.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "GatewayWebService/GatewayWebService.h"
#import "AppDelegate.h"
#import "StaffView.h"
#import "StaffCell.h"

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

- (void)setGroupData:(NSDictionary *)groupData {
    NSString *groupName = [groupData objectForKey:@"name"];
    NSMutableArray *staffArray = [NSMutableArray arrayWithArray:[groupData objectForKey:@"users"]];
    
    
    // sorting
    NSDictionary *temp;
    for (int i = 0; i < [staffArray count]; i++)
    {
        for (int j = 0; j < [staffArray count] - 1 - i; j++) {
            NSInteger thisPlace = [[[staffArray objectAtIndex:j] valueForKey:@"pk"] integerValue];
            NSInteger nextPlace = [[[staffArray objectAtIndex:j + 1] valueForKey:@"pk"] integerValue];
            if (thisPlace > nextPlace)
            {
                temp = [staffArray objectAtIndex:j];
                [staffArray replaceObjectAtIndex:j withObject:[staffArray objectAtIndex:j+1]];
                [staffArray replaceObjectAtIndex:j + 1 withObject:temp];
            }
        }
    }
    
    //handle cross grops's staff move to bottom
    for (int i = 0; i < [staffArray count]; i++)
    {
        NSString *title = [[[staffArray objectAtIndex:i] valueForKey:@"profile"] valueForKey:@"title"];
        if (![title hasPrefix:[groupName substringToIndex:2]])
        {
            [staffArray addObject:[staffArray objectAtIndex:i]];
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
    NSString *identifier = @"StaffCell";
    StaffCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                        forIndexPath:indexPath];
    
    NSString *avatar = [[staff objectForKey:@"profile"] objectForKey:@"avatar"];
    if (![avatar containsString:@"http"]) {
        avatar = [[NSString alloc] initWithFormat:@"https://staff.coscup.org%@", avatar];
    } else {
        avatar = [avatar stringByAppendingString:@"&s=200"];
    }
    
    [cell.staffTitle setText:[[staff objectForKey:@"profile"] objectForKey:@"title"]];
    [cell.staffName setText:[[staff objectForKey:@"profile"] objectForKey:@"display_name"]];
    [cell.staffImg setImage:[UIImage imageNamed:@"StaffIconDefault"]];
    
    // Here we use the new provided sd_setImageWithURL: method to load the web image
    [cell.staffImg sd_setImageWithURL:[NSURL URLWithString:avatar]
                     placeholderImage:[UIImage imageNamed:@"StaffIconDefault"]
                              options:indexPath.row == 0 ? SDWebImageRefreshCached : 0];
    
    return cell;
}

@end
