//
//  ScheduleViewController.m
//  CCIP
//
//  Created by FrankWu on 2017/7/15.
//  Copyright © 2017年 CPRTeam. All rights reserved.
//

#import "ScheduleViewController.h"
#import "AppDelegate.h"
#import "UIColor+addition.h"

@interface ScheduleViewController ()

@property (strong, nonatomic) FBShimmeringView *shimmeringLogoView;

@end

@implementation ScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // set logo on nav title
//    UIView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"coscup-logo"]];
//    self.shimmeringLogoView = [[FBShimmeringView alloc] initWithFrame:logoView.bounds];
//    self.shimmeringLogoView.contentView = logoView;
//    self.navigationItem.titleView = self.shimmeringLogoView;
    self.navigationItem.title = @"SCHEDULE";
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, 239);
    UIImage *recImg = [UIImage imageNamed:@"Rectangle.png"];
    UIImageView *iv = [UIImageView new];
    [iv setFrame:frame];
    [iv setImage:recImg];
    [self.view addSubview:iv];
    [self.view sendSubviewToBack:iv];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [AppDelegate setDevLogo:self.shimmeringLogoView];
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
