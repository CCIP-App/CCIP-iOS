//
//  ScheduleDetailViewController.m
//  CCIP
//
//  Created by FrankWu on 2016/7/19.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "ScheduleDetailViewController.h"
#import "ScheduleDetailViewPagerController.h"
#import "RoomLocationViewController.h"
#import "NSInvocation+addition.h"

@interface ScheduleDetailViewController ()

@end

@implementation ScheduleDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated {
    [self.speakername setText:[self.program objectForKey:@"speakername"]];
    [self.subject setText:[self.program objectForKey:@"subject"]];
    
    ScheduleDetailViewPagerController *scheduleDetailViewPager = [ScheduleDetailViewPagerController new];
    
    [self addChildViewController:scheduleDetailViewPager];
    scheduleDetailViewPager.view.frame = CGRectMake(0, self.topBG.frame.size.height-44, self.view.bounds.size.width, self.view.bounds.size.height-(self.topBG.frame.size.height-44));
    [self.view addSubview:scheduleDetailViewPager.view];
    [scheduleDetailViewPager didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setProgram:(NSMutableDictionary *)program {
    _program = program;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
