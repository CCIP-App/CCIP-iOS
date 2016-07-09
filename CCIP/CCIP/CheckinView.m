//
//  CheckinView.m
//  CCIP
//
//  Created by 腹黒い茶 on 2016/06/26.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "CheckinView.h"
#import "GatewayWebService/GatewayWebService.h"
#import "AppDelegate.h"

@interface CheckinView ()

@property (strong, nonatomic) AppDelegate *appDelegate;

@end

@implementation CheckinView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)gotoTop {
    [self.appDelegate.navigationView popToRootViewControllerAnimated:YES];
}

- (void)setScenario:(NSDictionary *)scenario {
    _scenario = scenario;
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.checkinMessabeLabel setText:NSLocalizedString(@"CheckinNotice", nil)];
    [self.checkinBtn setTitle:NSLocalizedString(@"CheckinButton", nil)
                     forState:UIControlStateNormal];
}

- (IBAction)checkinBtnEvent:(id)sender {
    GatewayWebService *ws = [[GatewayWebService alloc] initWithURL:CC_USE(self.appDelegate.accessToken, [self.scenario objectForKey:@"id"])];
    [ws sendRequest:^(NSDictionary *json, NSString *jsonStr) {
        if (json != nil) {
            NSLog(@"%@", json);
            
            NSDictionary *theScenario = [NSDictionary new];
            for (NSDictionary *dict in [json objectForKey:@"scenarios"]) {
                if ([[dict objectForKey:@"id"] isEqualToString:[self.scenario objectForKey:@"id"]]) {
                    theScenario = dict;
                }
            }
            
            UIViewController *detailViewController = [[UIViewController alloc] initWithNibName:@"StatusView"
                                                                                        bundle:nil];
            [detailViewController.view setBackgroundColor:[UIColor whiteColor]];
            [NSInvocation InvokeObject:detailViewController.view
                    withSelectorString:@"setScenario:"
                         withArguments:@[ theScenario ]];
            [self.appDelegate.navigationView popViewControllerAnimated:NO];
            [self.appDelegate.navigationView pushViewController:detailViewController
                                                       animated:YES];
        }
    }];
}

@end
