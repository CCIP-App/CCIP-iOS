//
//  AfterEventViewController.m
//  CCIP
//
//  Created by 腹黒い茶 on 2016/08/19.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "AppDelegate.h"
#import "UIColor+addition.h"
#import "AfterEventViewController.h"

@interface AfterEventViewController ()

@end

@implementation AfterEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view.layer setCornerRadius:15.0f]; // set cornerRadius as you want.
    [self.view.layer setMasksToBounds:NO];
    [self.view.layer setShadowOffset:CGSizeMake(10, 15)];
    [self.view.layer setShadowRadius:5.0f];
    [self.view.layer setShadowOpacity:0.3f];
    
    [self.afterEventMessageLabel setText:NSLocalizedString(@"AfterEventMessage", nil)];
    [self.afterEventMessageLabel setTextColor:[AppDelegate AppConfigColor:@"CardTextColor"]];
    [self.afterEventButton setTitle:NSLocalizedString(@"AfterEventActionTitle", nil)
                           forState:UIControlStateNormal];
    [self.afterEventButton setTintColor:[UIColor whiteColor]];
    [self.afterEventButton setBackgroundColor:[AppDelegate AppConfigColor:@"CardBackgroundColor"]];
    [self.afterEventButton.layer setCornerRadius:10.0f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)afterEventAction:(id)sender {
    // do some thing stuff
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
