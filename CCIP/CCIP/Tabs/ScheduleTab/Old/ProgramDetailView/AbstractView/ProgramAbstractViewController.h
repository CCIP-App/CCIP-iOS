//
//  ProgramAbstractViewController.h
//  CCIP
//
//  Created by FrankWu on 2016/7/19.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgramAbstractViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *roomInfo;
@property (weak, nonatomic) IBOutlet UILabel *langInfo;
@property (weak, nonatomic) IBOutlet UILabel *timeInfo;
@property (weak, nonatomic) IBOutlet UITextView *abstractInfo;

@property (strong, nonatomic) NSDictionary *program;

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil Program:(NSDictionary *)program;

@end
