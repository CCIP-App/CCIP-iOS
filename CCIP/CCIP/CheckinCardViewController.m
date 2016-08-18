//
//  CheckinCardViewController.m
//  CCIP
//
//  Created by FrankWu on 2016/7/30.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#include <QuartzCore/QuartzCore.h>
#import "UIColor+addition.h"
#import "GatewayWebService/GatewayWebService.h"
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
    [self.cardView.layer setMasksToBounds:NO];
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
    
    if ([nilCoalesce([scenario objectForKey:@"id"]) isEqualToString:@"vipkit"] && [scenario objectForKey:@"disabled"] == nil) {
        [self.cardView.layer setShadowColor:[[UIColor colorFromHtmlColor:@"#cff1"] CGColor]];
        [self.cardView.layer setShadowRadius:20.0f];
        CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
        animation.fromValue = @(0.3f);
        animation.toValue = @(0.5f);
        animation.repeatCount = HUGE_VAL;
        animation.duration = 1.0;
        animation.autoreverses = YES;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        [self.cardView.layer addAnimation:animation forKey:@"pulse"];
    }
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
