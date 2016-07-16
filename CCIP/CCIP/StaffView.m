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
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"StaffView"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
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
    }
    
    cell.staffImg.image = [UIImage imageNamed:@"StaffIconDefault"];
    UIImageFromURL( [NSURL URLWithString:avatar], ^( UIImage * image )
    {
        cell.staffImg.image = image;
    }, ^(void){
        NSLog(@"%@",@"Load staff image error!");
    });
    
    cell.staffTitle.text = [[[self.staffJsonArray objectAtIndex:indexPath.row] objectForKey:@"profile"] objectForKey:@"title"];
    cell.staffName.text = [[[self.staffJsonArray objectAtIndex:indexPath.row] objectForKey:@"profile"] objectForKey:@"display_name"];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    
}

void UIImageFromURL( NSURL * URL, void (^imageBlock)(UIImage * image), void (^errorBlock)(void) ) {
    dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ), ^(void) {
        NSData * data = [[NSData alloc] initWithContentsOfURL:URL];
        UIImage * image = [[UIImage alloc] initWithData:data];
        
        dispatch_async( dispatch_get_main_queue(), ^(void){
            if( image != nil ) {
                imageBlock( image );
            } else {
                errorBlock();
            }
        });
    });
}

@end
