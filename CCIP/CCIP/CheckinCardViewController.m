//
//  CheckinCardViewController.m
//  CCIP
//
//  Created by FrankWu on 2016/7/30.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#include <QuartzCore/QuartzCore.h>
#import "UIColor+addition.h"
#import "CheckinCardViewController.h"
#import "CheckinCardView.h"
#import "headers.h"

@interface CheckinCardViewController()

@property (strong, nonatomic) CheckinCardView *cardView;

@end

@implementation CheckinCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.cardView = (CheckinCardView *)self.view;;
    
    [self.cardView.checkinSmallCard.layer setCornerRadius:15.0f]; // set cornerRadius as you want.
    [self.cardView.checkinSmallCard.layer setMasksToBounds:NO];
    [self.cardView.checkinSmallCard.layer setShadowOffset:CGSizeMake(0, 50)];
    [self.cardView.checkinSmallCard.layer setShadowRadius:50.0f];
    [self.cardView.checkinSmallCard.layer setShadowOpacity:0.1f];
}

- (void)viewDidLayoutSubviews {
    [self.cardView.checkinBtn.layer setCornerRadius:self.cardView.checkinBtn.frame.size.height / 2];
    // Set checkin button background linear diagonal gradient
    //   Create the colors
    UIColor *topColor = [UIColor colorFromHtmlColor:@"#2CE4D4"];
    UIColor *bottomColor = [UIColor colorFromHtmlColor:@"#B0F5B6"];
    //   Create the gradient
    CAGradientLayer *theViewGradient = [CAGradientLayer layer];
    theViewGradient.colors = [NSArray arrayWithObjects: (id)topColor.CGColor, (id)bottomColor.CGColor, nil];
    theViewGradient.frame = CGRectMake(0, 0, self.cardView.checkinBtn.frame.size.width, self.cardView.checkinBtn.frame.size.height);
    theViewGradient.startPoint = CGPointMake(1, .5);
    theViewGradient.endPoint = CGPointMake(.2, .8);
    theViewGradient.cornerRadius = self.cardView.checkinBtn.frame.size.height / 2;
    //   Add gradient to view
    if (self.cardView.checkinBtn.layer.sublayers != nil) {
        [self.cardView.checkinBtn.layer replaceSublayer:[self.cardView.checkinBtn.layer.sublayers firstObject]
                                                   with:theViewGradient];
    } else {
        [self.cardView.checkinBtn.layer insertSublayer:theViewGradient
                                               atIndex:0];
    }
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
