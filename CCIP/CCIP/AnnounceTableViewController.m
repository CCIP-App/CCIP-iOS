//
//  AnnounceTableViewController.m
//  CCIP
//
//  Created by Sars on 8/10/16.
//  Copyright © 2016 CPRTeam. All rights reserved.
//

#import "AppDelegate.h"
#import "GatewayWebService/GatewayWebService.h"
#import "AnnounceTableViewController.h"
#import "AnnounceTableViewCell.h"
#import <SafariServices/SafariServices.h>

@interface AnnounceTableViewController ()

@property (strong, nonatomic) FBShimmeringView *shimmeringLogoView;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation AnnounceTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set logo on nav title
    UIView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"coscup-logo"]];
    self.shimmeringLogoView = [[FBShimmeringView alloc] initWithFrame:logoView.bounds];
    self.shimmeringLogoView.contentView = logoView;
    self.navigationItem.titleView = self.shimmeringLogoView;
    
    if (self.refreshControl == nil) {
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self
                                action:@selector(refresh)
                      forControlEvents:UIControlEventValueChanged];
        [self.announceTableView addSubview:self.refreshControl];
        
        [self refresh];
        [self.refreshControl beginRefreshing];
    }
    
    SEND_GAI(@"AnnounceTableViewController");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.shimmeringLogoView setShimmering:[AppDelegate isDevMode]];
}

- (void)refresh {
    GatewayWebService *annoounce_ws = [[GatewayWebService alloc] initWithURL:CC_ANNOUNCEMENT];
    [annoounce_ws sendRequest:^(NSArray *json, NSString *jsonStr, NSURLResponse *response) {
        if (json != nil) {
            self.announceJsonArray = json;
            [self.announceTableView reloadData];
            [self.refreshControl endRefreshing];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - UITableViewControllerDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.announceJsonArray count];
}

- (void)setCell:(AnnounceTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *announce = [self.announceJsonArray objectAtIndex:indexPath.row];
    NSString* language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    
    if ([language containsString:@"zh"]) {
        [cell.msg setText:[announce objectForKey:@"msg_zh"]];
    } else {
        [cell.msg setText:[announce objectForKey:@"msg_en"]];
    }
    NSString *uri = [announce objectForKey:@"uri"];
    [cell setAccessoryType:(!uri || [uri isEqualToString:@""]) ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSNumber *datetime = [announce objectForKey:@"datetime"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[datetime doubleValue]]];
    
    [cell.msgTime setText:strDate];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AnnounceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AnnounceCell" forIndexPath:indexPath];
    
    [self setCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    static AnnounceTableViewCell *cell = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        cell = [tableView dequeueReusableCellWithIdentifier:@"AnnounceCell"];
    });
    
    [self setCell:cell atIndexPath:indexPath];
    
    return [self calculateHeightForConfiguredSizingCell:cell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(AnnounceTableViewCell *)sizingCell {
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *announce = [self.announceJsonArray objectAtIndex:indexPath.row];
    NSString *uri = [announce objectForKey:@"uri"];
    
    if (!uri || [uri isEqualToString:@""]) return;
    
    if ([SFSafariViewController class] != nil) {
        SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:uri]];
        [[UIApplication getMostTopPresentedViewController] presentViewController:safariViewController animated:YES completion:nil];
    } else {
        if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:uri]]) {
            NSLog(@"%@%@",@"Failed to open url:", [[NSURL URLWithString:uri] description]);
        }
    }
    
    SEND_GAI_EVENT(@"AnnounceTableView", uri);
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
