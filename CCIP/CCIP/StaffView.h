//
//  StaffView.h
//  CCIP
//
//  Created by Sars on 2016/07/10.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Google/Analytics.h>

@interface StaffView : UIView <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, retain) IBOutlet UICollectionView *staffCollectionView;
@property (strong, nonatomic) NSArray *staffJsonArray;

@end
