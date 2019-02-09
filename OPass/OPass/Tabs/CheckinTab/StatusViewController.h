//
//  StatusViewController.h
//  CCIP
//
//  Created by 腹黒い茶 on 2016/06/26.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatusViewController : UIViewController

@property (strong, nonatomic) NSDictionary *scenario;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *visualEffectView;
@property (weak, nonatomic) IBOutlet UILabel *statusMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *attributesLabel;
@property (weak, nonatomic) IBOutlet UILabel *countdownLabel;
@property (weak, nonatomic) IBOutlet UILabel *noticeTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *kitTitle;
@property (weak, nonatomic) IBOutlet UILabel *nowTimeLabel;

- (void)startCountDown;

@end
