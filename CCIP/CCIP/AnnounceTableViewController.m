//
//  AnnounceTableViewController.m
//  CCIP
//
//  Created by Sars on 8/10/16.
//  Copyright © 2016 CPRTeam. All rights reserved.
//

#import "AppDelegate.h"
#import "AnnounceTableViewController.h"
#import "AnnounceTableViewCell.h"
#import <SafariServices/SafariServices.h>
#import <AFNetworking/AFNetworking.h>
#import "WebServiceEndPoint.h"
#import "UIColor+addition.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "UIView+FDCollapsibleConstraints.h"
#import "UIView+addition.h"

@interface AnnounceTableViewController ()

@property (strong, nonatomic) FBShimmeringView *shimmeringLogoView;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (readwrite, nonatomic) BOOL loaded;

@property (readwrite, nonatomic) CGFloat controllerTopStart;

@end

@implementation AnnounceTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.announceTableView setSeparatorColor:[UIColor clearColor]];
    self.announceJsonArray = @[];
    if (self.refreshControl == nil) {
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self
                                action:@selector(refresh)
                      forControlEvents:UIControlEventValueChanged];
        [self.announceTableView addSubview:self.refreshControl];
    }
    
    [self.navigationItem setTitle:NSLocalizedString(@"AnnouncementTitle", nil)];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, 239);
    UIView *headView = [UIView new];
    [headView setFrame:frame];
    [headView setGradientColor:[UIColor colorFromHtmlColor:@"#F9FEA5"]
                            To:[UIColor colorFromHtmlColor:@"#20E2D7"]
                    StartPoint:CGPointMake(-.4f, .5f)
                       ToPoint:CGPointMake(1, .5f)];
    [self.view addSubview:headView];
    [self.view sendSubviewToBack:headView];
    
    NSString *noAnnouncementText = NSLocalizedString(@"NoAnnouncementText", nil);
    NSMutableAttributedString *attributedNoAnnouncementText = [[NSMutableAttributedString alloc] initWithString:noAnnouncementText];
    float spacing = 5.0f;
    [attributedNoAnnouncementText addAttribute:NSKernAttributeName
                             value:@(spacing)
                             range:NSMakeRange(0, [noAnnouncementText length])];
    [self.lbNoAnnouncement setAttributedText:attributedNoAnnouncementText];
    
    SEND_GAI(@"AnnounceTableViewController");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.controllerTopStart = self.navigationController.navigationBar.frame.size.height;
    [AppDelegate setDevLogo:self.shimmeringLogoView
                   WithLogo:ASSETS_IMAGE(@"AssetsUI", @"coscup-logo")];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self refresh];
}

- (void)refresh {
    self.loaded = NO;
    [self.refreshControl beginRefreshing];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:CC_ANNOUNCEMENT parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        if (responseObject != nil) {
            self.loaded = YES;
            self.announceJsonArray = responseObject;
            [self.announceTableView reloadData];
            [self.refreshControl endRefreshing];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if ([error code] == -1009) {
            [self performSegueWithIdentifier:@"ShowInvalidNetworkMsg"
                                      sender:NSLocalizedString(@"Networking_Broken", nil)];
        } else {
            self.loaded = YES;
            self.announceJsonArray = @[];
            [self.announceTableView reloadData];
        }
        [self.refreshControl endRefreshing];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *destination = segue.destinationViewController;
    if ([destination isMemberOfClass:[InvalidNetworkMessageViewController class]]) {
        InvalidNetworkMessageViewController *inmvc = (InvalidNetworkMessageViewController *)destination;
        [inmvc setMessage:sender];
        [inmvc setDelegate:self];
    }
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
    NSInteger count = [self.announceJsonArray count];
    if (self.loaded) {
        BOOL NoAnnouncement = count == 0;
        [self.ivNoAnnouncement setHidden:!NoAnnouncement];
        [self.lbNoAnnouncement setHidden:!NoAnnouncement];
    } else {
        [self.ivNoAnnouncement setHidden:YES];
        [self.lbNoAnnouncement setHidden:YES];
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AnnounceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AnnounceCell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:@"AnnounceCell" configuration:^(id cell) {
        [self configureCell:cell atIndexPath:indexPath];
    }];
}

- (void)configureCell:(AnnounceTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    [cell setFd_enforceFrameLayout:NO]; // Enable to use "-sizeThatFits:"
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setClipsToBounds:NO];
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell.layer setZPosition:indexPath.row];
    UIView *vwContent = [cell performSelector:@selector(vwContent)];
    [vwContent.layer setCornerRadius:5.0f];
    [vwContent.layer setMasksToBounds:YES];
    
    UIView *vwShadowContent = [cell performSelector:@selector(vwShadowContent)];
    [vwShadowContent.layer setCornerRadius:5.0f];
    [vwShadowContent.layer setMasksToBounds:NO];
    [vwShadowContent.layer setShadowRadius:50.0f];
    [vwShadowContent.layer setShadowOffset:CGSizeMake(0, 50)];
    [vwShadowContent.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [vwShadowContent.layer setShadowOpacity:0.1f];
    
    NSDictionary *announce = [self.announceJsonArray objectAtIndex:indexPath.row];
    NSString* language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    
    if ([language containsString:@"zh"]) {
        [cell.lbMessage setText:[announce objectForKey:@"msg_zh"]];
    } else {
        [cell.lbMessage setText:[announce objectForKey:@"msg_en"]];
    }
    NSString *uri = [announce objectForKey:@"uri"];
    BOOL hasURL = !(!uri || [uri isEqualToString:@""]);
    //    [cell setAccessoryType:hasURL ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSNumber *datetime = [announce objectForKey:@"datetime"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[datetime doubleValue]]];
    
    [cell.lbMessageTime setText:strDate];
    
    if (hasURL) {
        [cell.lbURL setText:uri];
    } else {
        [cell.lbURL setText:@""];
    }
    [cell.vwDashedLine addDashedLine:[UIColor colorFromHtmlColor:@"#E9E9E9"]];
    
    [cell.vwURL setFd_collapsed:!hasURL];
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
