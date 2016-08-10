//
//  GuideViewController.h
//  CCIP
//
//  Created by 腹黒い茶 on 2016/07/09.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GuideViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *guideMessageLabel;
@property (weak, nonatomic) IBOutlet UITextField *redeemCodeText;
@property (weak, nonatomic) IBOutlet UIButton *redeemButton;
@property(nonatomic) CGPoint originalCenter;

@end
