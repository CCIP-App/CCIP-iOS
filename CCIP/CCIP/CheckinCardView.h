//
//  CheckinCardView.h
//  CCIP
//
//  Created by 腹黒い茶 on 2016/07/31.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckinCardView : UIView

@property (strong, nonatomic) NSString *id;
@property (weak, nonatomic) IBOutlet UILabel *checkinDate;
@property (weak, nonatomic) IBOutlet UILabel *checkinTitle;
@property (weak, nonatomic) IBOutlet UILabel *checkinText;
@property (weak, nonatomic) IBOutlet UIButton *checkinBtn;

- (IBAction)checkinBtnTouched:(id)sender;

@end
