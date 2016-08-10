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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setScenario:(NSDictionary *)scenario {
    [((CheckinCardView *)self.view) setScenario:scenario];
}

- (void)setId:(NSString *)id {
    [((CheckinCardView *)self.view) setId:id];
}

- (void)setUsed:(NSNumber *)used {
    [((CheckinCardView *)self.view) setUsed:used];
}

- (void)setDisabled:(NSNumber *)disabled {
    [((CheckinCardView *)self.view) setDisabled:disabled];
}

- (void)setDelegate:(CheckinViewController *)delegate {
    [((CheckinCardView *)self.view) setDelegate:delegate];
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
