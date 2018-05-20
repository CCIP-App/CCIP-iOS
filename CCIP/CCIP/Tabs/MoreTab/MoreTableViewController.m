//
//  MoreTableViewController.m
//  CCIP
//
//  Created by Sars on 7/17/16.
//  Copyright © 2016 CPRTeam. All rights reserved.
//

#import "AppDelegate.h"
#import "MoreTableViewController.h"
#import "StaffGroupTableViewController.h"
#import "AcknowledgementsViewController.h"
#import "MoreCell.h"
#import <AFNetworking/AFNetworking.h>
#import "WebServiceEndPoint.h"
#import "UIColor+addition.h"
#import "UIImage+addition.h"
#import "UIView+addition.h"

@interface MoreTableViewController ()

@property (strong, nonatomic) FBShimmeringView *shimmeringLogoView;

@property (strong, nonatomic) NSDictionary *userInfo;

@property (strong, nonatomic) NSArray *moreItems;

@property (strong, nonatomic) NSArray *staffs;

@end

@implementation MoreTableViewController

- (void)prefetchStaffs {
    if ([[AppDelegate AppConfig:@"URL.StaffUseWeb"] boolValue] == NO) {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager GET:[AppDelegate AppConfigURL:@"StaffPath"]
          parameters:nil
            progress:nil
             success:^(NSURLSessionTask *task, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
            if (responseObject != nil) {
                self.staffs = responseObject;
            }
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *destination = segue.destinationViewController;
    NSString *title = [sender text];
    SEND_FIB_EVENT(@"MoreTableView", @{ @"MoreTitle": title });
    [destination setTitle:title];
    if ([destination isMemberOfClass:[StaffGroupTableViewController class]]) {
        StaffGroupTableViewController *sgt = (StaffGroupTableViewController *)destination;
        [sgt setStaffJsonArray:self.staffs];
    }
    [((UITableViewCell *)sender) setSelected:NO
                                    animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set logo on nav title
    UIImageView *logoView = [[UIImageView alloc] initWithImage:[ASSETS_IMAGE(@"AssetsUI", @"conf-logo") imageWithColor:[UIColor whiteColor]]];
    self.shimmeringLogoView = [[FBShimmeringView alloc] initWithFrame:logoView.bounds];
    self.shimmeringLogoView.contentView = logoView;
    self.navigationItem.titleView = self.shimmeringLogoView;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
    [self.navigationController.navigationBar setTranslucent:NO];
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height);
    UIView *headView = [[UIView alloc] initWithFrame:frame];
    [headView setGradientColor:[AppDelegate AppConfigColor:@"MoreTitleLeftColor"]
                            To:[AppDelegate AppConfigColor:@"MoreTitleRightColor"]
                    StartPoint:CGPointMake(-.4f, .5f)
                       ToPoint:CGPointMake(1, .5f)];
    UIImage *naviBackImg = [[headView.layer.sublayers lastObject] toImage];
    [self.navigationController.navigationBar setBackgroundImage:naviBackImg forBarMetrics:UIBarMetricsDefault];
    
    self.userInfo = [[AppDelegate appDelegate] userInfo];
    
    SEND_FIB(@"MoreTableViewController");
    
    self.navigationItem.titleView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(navSingleTap)];
    tapGesture.numberOfTapsRequired = 1;
    [self.navigationItem.titleView addGestureRecognizer:tapGesture];
    
    self.moreItems = @[
                       @"Puzzle",
                       @"Ticket",
                       @"Telegram",
                       [NSString stringWithFormat:@"Maps%@", [[AppDelegate AppConfig:@"URL.MapsUseWeb"] boolValue] ? @"Web" : @""],
                       [NSString stringWithFormat:@"Staffs%@", [[AppDelegate AppConfig:@"URL.StaffUseWeb"] boolValue] ? @"Web" : @""],
                       [NSString stringWithFormat:@"Sponsors%@", [[AppDelegate AppConfig:@"URL.SponsorUseWeb"] boolValue] ? @"Web" : @""],
                       @"Acknowledgements",
                       ];
    if (self.staffs == nil) {
        [self prefetchStaffs];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([[AppDelegate AppConfig:@"URL.StaffUseWeb"] boolValue] == NO) {
        dispatch_semaphore_t semaStaff = dispatch_semaphore_create(0);
        while (dispatch_semaphore_wait(semaStaff, DISPATCH_TIME_NOW)) {
            if (self.staffs != nil) {
                dispatch_semaphore_signal(semaStaff);
            }
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                     beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [AppDelegate setDevLogo:self.shimmeringLogoView
                   WithLogo:[ASSETS_IMAGE(@"AssetsUI", @"conf-logo") imageWithColor:[UIColor whiteColor]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)navSingleTap {
    //NSLog(@"navSingleTap");
    [self handleNavTapTimes];
}

- (void)handleNavTapTimes {
    static int tapTimes = 0;
    static NSDate *oldTapTime;
    static NSDate *newTapTime;
    
    newTapTime = [NSDate date];
    if (oldTapTime == nil) {
        oldTapTime = newTapTime;
    }
    
    if ([newTapTime timeIntervalSinceDate: oldTapTime] <= 0.25f) {
        tapTimes++;
        if (tapTimes == 10) {
            NSLog(@"--  Success tap 10 times  --");
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            
            if (![AppDelegate isDevMode]) {
                NSLog(@"-- Enable DEV_MODE --");
                [AppDelegate setIsDevMode: YES];
                [AppDelegate setDevLogo:self.shimmeringLogoView
                               WithLogo:[ASSETS_IMAGE(@"AssetsUI", @"conf-logo") imageWithColor:[UIColor whiteColor]]];
            } else {
                NSLog(@"-- Disable DEV_MODE --");
                [AppDelegate setIsDevMode:NO];
                [AppDelegate setDevLogo:self.shimmeringLogoView
                               WithLogo:[ASSETS_IMAGE(@"AssetsUI", @"conf-logo") imageWithColor:[UIColor whiteColor]]];
            }
        }
    }
    else {
        NSLog(@"--  Failed, just tap %2d times  --", tapTimes);
        NSLog(@"-- Failed to trigger DEV_MODE --");
        tapTimes = 1;
    }
    oldTapTime = newTapTime;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.moreItems count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.userInfo != nil && [[self.userInfo allKeys] containsObject:@"user_id"] ? [NSString stringWithFormat:NSLocalizedString(@"Hi", nil), [self.userInfo objectForKey:@"user_id"]] : nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = [self.moreItems objectAtIndex:indexPath.row];
    MoreCell *cell = (MoreCell *)[tableView dequeueReusableCellWithIdentifier:cellId
                                                                 forIndexPath:indexPath];
    [cell.textLabel setText:NSLocalizedString(cellId, nil)];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

//#pragma mark - Table view delegate
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [tableView deselectRowAtIndexPath:indexPath
//                             animated:YES];
//    NSDictionary *item = [self.moreItems objectAtIndex:indexPath.row];
//    NSString *title = [[[tableView cellForRowAtIndexPath:indexPath] textLabel] text];
//    ((void(^)(NSString *))[item objectForKey:@"detailViewController"])(title);
//    SEND_FIB_EVENT(@"MoreTableView", title);
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
