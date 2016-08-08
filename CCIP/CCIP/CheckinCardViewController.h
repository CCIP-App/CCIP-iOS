//
//  CheckinCardViewController.h
//  CCIP
//
//  Created by FrankWu on 2016/7/30.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckinCardViewController : UIViewController

@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSNumber *used;
@property (weak, nonatomic) IBOutlet UILabel *checkinDate;
@property (weak, nonatomic) IBOutlet UILabel *checkinTitle;
@property (weak, nonatomic) IBOutlet UILabel *checkinText;
@property (weak, nonatomic) IBOutlet UIButton *checkinBtn;

@end
