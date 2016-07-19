//
//  ProgramDetailViewController.m
//  CCIP
//
//  Created by FrankWu on 2016/7/19.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "ProgramDetailViewController.h"
#import "ProgramDetailViewPagerController.h"
#import "RoomLocationViewController.h"
#import "NSInvocation+addition.h"

@interface ProgramDetailViewController ()

@end

@implementation ProgramDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated {
    [self.speakername setText:[self.program objectForKey:@"speakername"]];
    [self.subject setText:[self.program objectForKey:@"subject"]];
    
    ProgramDetailViewPagerController *programDetailViewPager = [ProgramDetailViewPagerController new];
    
    [self addChildViewController:programDetailViewPager];
    programDetailViewPager.view.frame = CGRectMake(0, self.topBG.frame.size.height-44, self.view.bounds.size.width, self.view.bounds.size.height-(self.topBG.frame.size.height-44));
    [self.view addSubview:programDetailViewPager.view];
    [programDetailViewPager didMoveToParentViewController:self];
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
