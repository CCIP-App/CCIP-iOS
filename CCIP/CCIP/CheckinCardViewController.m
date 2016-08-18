//
//  CheckinCardViewController.m
//  CCIP
//
//  Created by FrankWu on 2016/7/30.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "CheckinCardViewController.h"
#import "CheckinCardView.h"

@interface CheckinCardViewController()

@property (strong, nonatomic) CheckinCardView *cardView;

@end

@implementation CheckinCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.cardView = (CheckinCardView *)self.view;;
    
    [self.cardView.layer setCornerRadius:15.0f]; // set cornerRadius as you want.
    [self.cardView.layer setMasksToBounds:YES];
    [self.cardView.layer setShadowOffset:CGSizeMake(10, 15)];
    [self.cardView.layer setShadowRadius:5.0f];
    [self.cardView.layer setShadowOpacity:0.3f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setScenario:(NSDictionary *)scenario {
    [self.cardView setScenario:scenario];
}

- (void)setId:(NSString *)id {
    [self.cardView setId:id];
}

- (void)setUsed:(NSNumber *)used {
    [self.cardView setUsed:used];
}

- (void)setDisabled:(NSNumber *)disabled {
    [self.cardView setDisabled:disabled];
}

- (void)setDelegate:(CheckinViewController *)delegate {
    [self.cardView setDelegate:delegate];
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
