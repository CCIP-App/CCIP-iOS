//
//  StaffCell.h
//  CCIP
//
//  Created by Sars on 2016/07/10.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StaffCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *staffImg;
@property (weak, nonatomic) IBOutlet UILabel *staffTitle;
@property (weak, nonatomic) IBOutlet UILabel *staffName;

@end
