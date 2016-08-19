//
//  StaffViewController.h
//  CCIP
//
//  Created by Sars on 2016/07/10.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StaffViewController : UIViewController<UIViewControllerPreviewingDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, retain) IBOutlet UICollectionView *staffCollectionView;
@property (strong, nonatomic) NSArray *staffJsonArray;

- (void)setGroupData:(NSDictionary *)groupData;

@end
