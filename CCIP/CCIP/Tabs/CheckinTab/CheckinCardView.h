//
//  CheckinCardView.h
//  CCIP
//
//  Created by 腹黒い茶 on 2016/07/31.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckinViewController.h"

@interface CheckinCardView : UIView

@property (strong, nonatomic) CheckinViewController *delegate;
@property (strong, nonatomic) NSDictionary *scenario;
@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSNumber *used;
@property (strong, nonatomic) NSNumber *disabled;
@property (weak, nonatomic) IBOutlet UIView *checkinSmallCard;
@property (weak, nonatomic) IBOutlet UILabel *checkinDate;
@property (weak, nonatomic) IBOutlet UILabel *checkinTitle;
@property (weak, nonatomic) IBOutlet UILabel *checkinText;
@property (weak, nonatomic) IBOutlet UIButton *checkinBtn;
@property (weak, nonatomic) IBOutlet UIImageView *checkinIcon;

- (IBAction)checkinBtnTouched:(id)sender;

@end
