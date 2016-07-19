//
//  ProgramDetailViewController
//  CCIP
//
//  Created by FrankWu on 2016/7/19.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgramDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *topBG;
@property (weak, nonatomic) IBOutlet UILabel *speakername;
@property (weak, nonatomic) IBOutlet UILabel *subject;
@property (weak, nonatomic) IBOutlet UIView *pagerview;

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil Program:(NSDictionary *)program;

@end
