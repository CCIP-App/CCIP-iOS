//
//  CheckinCardViewController.m
//  CCIP
//
//  Created by FrankWu on 2016/7/30.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "CheckinCardViewController.h"
#import "CheckinCardView.h"

@implementation CheckinCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.layer.cornerRadius = 15.0f; // set cornerRadius as you want.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setId:(NSString *)id {
    _id = id;
    [((CheckinCardView *)self.view) setId:id];
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
