//
//  CheckinViewController.h
//  CCIP
//
//  Created by Sars on 7/17/16.
//  Copyright © 2016 CPRTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckinViewController : UIViewController<UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *cards;

- (void)reloadCard;

@end
