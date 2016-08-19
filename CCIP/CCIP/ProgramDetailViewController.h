//
//  ProgramDetailViewController
//  CCIP
//
//  Created by FrankWu on 2016/7/19.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgramDetailViewController : UIViewController<UIViewControllerPreviewingDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *topBG;
@property (weak, nonatomic) IBOutlet UIView *pagerview;
@property (weak, nonatomic) IBOutlet UILabel *speakername;
@property (weak, nonatomic) IBOutlet UILabel *subject;

- (void)setProgram:(NSDictionary *)program;

@end
