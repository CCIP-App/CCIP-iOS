//
//  CheckinViewCell.h
//  CCIP
//
//  Created by Sars on 7/17/16.
//  Copyright © 2016 CPRTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckinViewCell : UICollectionViewCell

@property (strong, nonatomic) NSString *id;
@property (weak, nonatomic) IBOutlet UILabel *checkinDate;
@property (weak, nonatomic) IBOutlet UILabel *checkinTitle;
@property (weak, nonatomic) IBOutlet UIButton *checkinBtn;
@property (weak, nonatomic) IBOutlet UILabel *checkinText;

@end
