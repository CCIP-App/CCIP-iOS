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

@interface MoreTableViewController ()

@property (strong, nonatomic) FBShimmeringView *shimmeringLogoView;

@property (strong, nonatomic) NSDictionary *userInfo;

@property (strong, nonatomic) NSArray *moreItems;

@end

@implementation MoreTableViewController

static NSString *identifier = @"MoreCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set logo on nav title
    UIView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"coscup-logo"]];
    self.shimmeringLogoView = [[FBShimmeringView alloc] initWithFrame:logoView.bounds];
    self.shimmeringLogoView.contentView = logoView;
    self.navigationItem.titleView = self.shimmeringLogoView;
    
    [self.moreTableView registerNib:[UINib nibWithNibName:identifier
                                                   bundle:nil]
             forCellReuseIdentifier:identifier];
    
    self.userInfo = [[AppDelegate appDelegate] userInfo];
    
    SEND_GAI(@"MoreTableViewController");
    
    self.navigationItem.titleView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(navSingleTap)];
    tapGesture.numberOfTapsRequired = 1;
    [self.navigationItem.titleView addGestureRecognizer:tapGesture];
    
    self.moreItems = @[
                       @{
                           @"LocalizedString": NSLocalizedString(@"Staffs", nil),
                           @"NibName": @"StaffGroupView",
                           @"detailViewController": ^(NSString *nibName) { return [StaffGroupView new]; }
                           },
                       @{
                           @"LocalizedString": NSLocalizedString(@"Sponsors", nil),
                           @"NibName": @"SponsorTableView",
                           @"detailViewController": ^(NSString *nibName) { return [[UIViewController alloc] initWithNibName:nibName
                                                                                                                     bundle:nil]; }
                           },
                       @{
                           @"LocalizedString": NSLocalizedString(@"Acknowledgements", nil),
                           @"NibName": @"AcknowledgementsView",
                           @"detailViewController": ^(NSString *nibName) { return [AcknowledgementsViewController new]; }
                           }
                       ];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [AppDelegate setDevLogo:self.shimmeringLogoView];
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
                [AppDelegate setDevLogo:self.shimmeringLogoView];
            } else {
                NSLog(@"-- Disable DEV_MODE --");
                [AppDelegate setIsDevMode:NO];
                [AppDelegate setDevLogo:self.shimmeringLogoView];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier
                                                            forIndexPath:indexPath];
    [cell.textLabel setText:[[self.moreItems objectAtIndex:indexPath.row] objectForKey:@"LocalizedString"]];
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

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    NSDictionary *item = [self.moreItems objectAtIndex:indexPath.row];
    NSString *nibName = [item objectForKey:@"NibName"];
    UIViewController *detailViewController = ((UIViewController *(^)(NSString *))[item objectForKey:@"detailViewController"])(nibName);
    
    [detailViewController setTitle:[[[tableView cellForRowAtIndexPath:indexPath] textLabel] text]];
    [self.navigationController pushViewController:detailViewController
                                         animated:YES];
    
    SEND_GAI_EVENT(@"MoreTableView", nibName);
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
