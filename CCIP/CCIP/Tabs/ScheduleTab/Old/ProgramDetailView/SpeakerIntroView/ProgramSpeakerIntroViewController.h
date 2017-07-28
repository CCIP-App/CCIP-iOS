//
//  ProgramSpeakerIntroViewController.h
//  CCIP
//
//  Created by FrankWu on 2016/7/19.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgramSpeakerIntroViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *SpeakerIntroInfo;

@property (strong, nonatomic) NSDictionary *program;

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil Program:(NSDictionary *)program;

@end
