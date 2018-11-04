//
//  ScheduleViewController.m
//  CCIP
//
//  Created by FrankWu on 2017/7/15.
//  Copyright © 2017年 CPRTeam. All rights reserved.
//

#import "ScheduleViewController.h"
#import "AppDelegate.h"
#import "ScheduleTableViewCell.h"
#import "WebServiceEndPoint.h"

@interface ScheduleViewController ()

@property (strong, nonatomic) FBShimmeringView *shimmeringLogoView;

@end

@implementation ScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    [lbTitle setTextAlignment:NSTextAlignmentCenter];
    [lbTitle setTextColor:[UIColor whiteColor]];
    [lbTitle setText:NSLocalizedString(@"ScheduleTitle", nil)];
    [self.navigationItem setTitleView:lbTitle];
    [self.navigationItem setTitle:@""];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
    
    UIButton *favButton = [UIButton new];
    [favButton setTitle:FAVORITE_LIKE
               forState:UIControlStateNormal];
    [favButton addTarget:self
                  action:@selector(showFavoritesTouchDown)
        forControlEvents:UIControlEventTouchDown];
    [favButton addTarget:self
                  action:@selector(showFavoritesTouchUpInside)
        forControlEvents:UIControlEventTouchUpInside];
    [favButton addTarget:self
                  action:@selector(showFavoritesTouchUpOutside)
        forControlEvents:UIControlEventTouchUpOutside];
    [favButton.titleLabel setFont:[UIFont fontWithName:@"FontAwesome"
                                                  size:20.0f]];
    [favButton sizeToFit];
    UIBarButtonItem *favoritesButton = [[UIBarButtonItem alloc] initWithCustomView:favButton];
    [self.navigationItem setRightBarButtonItem:favoritesButton];
    
    UIButton *favButtonFake = [UIButton new];
    [favButtonFake setTitle:FAVORITE_LIKE
                   forState:UIControlStateNormal];
    [favButtonFake.titleLabel setFont:[UIFont fontWithName:@"FontAwesome"
                                                      size:20.0f]];
    [favButtonFake setTitleColor:[UIColor clearColor]
                        forState:UIControlStateNormal];
    [favButtonFake sizeToFit];
    UIBarButtonItem *favoritesButtonFake = [[UIBarButtonItem alloc] initWithCustomView:favButtonFake];
    [self.navigationItem setLeftBarButtonItem:favoritesButtonFake];
    
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, 239);
    UIView *headView = [UIView new];
    [headView setFrame:frame];
    [headView setGradientColorFrom:[AppDelegate AppConfigColor:@"ScheduleTitleLeftColor"]
                                to:[AppDelegate AppConfigColor:@"ScheduleTitleRightColor"]
                        startPoint:CGPointMake(-.4f, .5f)
                           toPoint:CGPointMake(1, .5f)];
    [self.view addSubview:headView];
    [self.view sendSubviewToBack:headView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [AppDelegate setDevLogo:self.shimmeringLogoView
                   WithLogo:ASSETS_IMAGE(@"AssetsUI", @"conf-logo")];
}

- (void)showFavoritesTouchDown {
    [AppDelegate triggerFeedback:ImpactFeedbackMedium];
}

- (void)showFavoritesTouchUpInside {
    [self performSegueWithIdentifier:@"ShowFavorites"
                              sender:nil];
    [AppDelegate triggerFeedback:ImpactFeedbackLight];
}

- (void)showFavoritesTouchUpOutside {
    [AppDelegate triggerFeedback:ImpactFeedbackLight];
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
