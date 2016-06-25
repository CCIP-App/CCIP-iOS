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
    [((UINavigationController *)[self.appDelegate.splitViewController.viewControllers firstObject]) popToRootViewControllerAnimated:YES];
}

- (IBAction)checkinBtnEvent:(id)sender {
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    GatewayWebService *ws = [[GatewayWebService alloc] initWithURL:CC_USE(self.appDelegate.accessToken, [self.scenario objectForKey:@"id"])];
    [ws sendRequest:^(NSDictionary *json, NSString *jsonStr) {
        if (json != nil) {
            NSLog(@"%@", json);
            UIViewController *detailViewController = [[UIViewController alloc] initWithNibName:@"StatusViewController"
                                                                                        bundle:nil];
            SEL setScenarioValue = NSSelectorFromString(@"setScenario:");
            if ([detailViewController.view canPerformAction:setScenarioValue withSender:nil]) {
                [detailViewController.view performSelector:setScenarioValue
                                                withObject:self.scenario];
            }
            [detailViewController.view setBackgroundColor:[UIColor whiteColor]];
            UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(gotoTop)];
            [detailViewController.navigationItem setLeftBarButtonItem:backButton];
            [detailViewController.navigationItem setLeftItemsSupplementBackButton:NO];
            UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
            [self.appDelegate.splitViewController showDetailViewController:detailNavigationController
                                                                    sender:self];
        }
    }];
}

@end
