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

- (IBAction)checkinBtnEvent:(id)sender {
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    GatewayWebService *ws = [[GatewayWebService alloc] initWithURL:CC_USE(self.appDelegate.accessToken, [self.scenario objectForKey:@"id"])];
    [ws sendRequest:^(NSDictionary *json, NSString *jsonStr) {
        if (json != nil) {
            NSLog(@"%@", json);

        }
    }];
    
    UIViewController *detailViewController = [[UIViewController alloc] initWithNibName:@"StatusViewController"
                                                                                bundle:nil];
    [detailViewController.view setBackgroundColor:[UIColor whiteColor]];
    [detailViewController.navigationItem setLeftBarButtonItem:self.appDelegate.splitViewController.displayModeButtonItem];
    [detailViewController.navigationItem setLeftItemsSupplementBackButton:YES];
    
    UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
    
    [self.appDelegate.splitViewController showDetailViewController:detailNavigationController
                                                sender:self];
    // for hack to toggle the master view in split view on portrait iPad
    UIBarButtonItem *barButtonItem = [self.appDelegate.splitViewController displayModeButtonItem];
    [[UIApplication sharedApplication] sendAction:[barButtonItem action]
                                               to:[barButtonItem target]
                                             from:nil
                                         forEvent:nil];
}

@end
