//
//  ScheduleDetailViewController.h
//  CCIP
//
//  Created by FrankWu on 2016/7/19.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScheduleDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *topBG;
@property (weak, nonatomic) IBOutlet UILabel *speakername;
@property (weak, nonatomic) IBOutlet UILabel *subject;
@property (weak, nonatomic) IBOutlet UIView *pagerview;

@property (strong, nonatomic) NSDictionary *program;

@end
