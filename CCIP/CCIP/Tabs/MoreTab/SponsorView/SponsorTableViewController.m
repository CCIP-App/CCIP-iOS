//
//  SponsorTableViewController.m
//  CCIP
//
//  Created by Sars on 8/6/16.
//  Copyright © 2016 CPRTeam. All rights reserved.
//

#import "SponsorTableViewController.h"
#import "SponsorTableViewCell.h"
#import "AppDelegate.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SafariServices/SafariServices.h>
#import <AFNetworking/AFNetworking.h>
#import "WebServiceEndPoint.h"

@interface SponsorTableViewController()

@end

@implementation SponsorTableViewController

- (NSArray<id<UIPreviewActionItem>> *)previewActionItems {
    return [self previewActions];
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    return self;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    //
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerForceTouch];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    dispatch_semaphore_t semaList = dispatch_semaphore_create(0);
    
    [self.tableView beginUpdates];
    [manager GET:SPONSOR_LIST_URL parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        if (responseObject != nil) {
            self.sponsorArray = responseObject;
        }
        dispatch_semaphore_signal(semaList);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    while (dispatch_semaphore_wait(semaList, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    }
    
    [self.tableView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self.sponsorArray count])]
                  withRowAnimation:UITableViewRowAnimationFade];
    
    NSMutableArray *indexPaths = [NSMutableArray new];
    for (int sectionNum = 0; sectionNum < [self.sponsorArray count]; sectionNum++) {
        for (int rowNum = 0; rowNum < [[[self.sponsorArray objectAtIndex:sectionNum] objectForKey:@"data"] count]; rowNum++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:rowNum
                                                     inSection:sectionNum]];
        }
    }
    [self.tableView insertRowsAtIndexPaths:indexPaths
                          withRowAnimation:UITableViewRowAnimationFade];
    
    [self.tableView endUpdates];
    
    SEND_GAI(@"SponsorTableView");
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.sponsorArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *filteredArray = [[self.sponsorArray objectAtIndex:section] objectForKey:@"data"];
    return filteredArray != nil ? [filteredArray count] : 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDictionary *level = [[self.sponsorArray objectAtIndex:section] objectForKey:@"name"];
    NSString *language = NSLocalizedString(@"CurrentLang", nil);
    if ([language containsString:@"zh"]) {
        return [level objectForKey:@"zh"];
    } else {
        return [level objectForKey:@"en"];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SponsorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SponsorCell" forIndexPath:indexPath];
    
    NSString *language = NSLocalizedString(@"CurrentLang", nil);
    
    NSArray *filteredSec = [[self.sponsorArray objectAtIndex:indexPath.section] objectForKey:@"data"];
    NSDictionary *filteredRow = [filteredSec objectAtIndex:indexPath.row];
    NSDictionary *title = [filteredRow objectForKey:@"name"];
    
    if ([language containsString:@"zh"]) {
        cell.sponsorTitle.text = [title objectForKey:@"zh"];
    } else {
        cell.sponsorTitle.text = [title objectForKey:@"en"];
    }
    
    [cell.sponsorImg sd_setImageWithURL:[NSURL URLWithString:[filteredRow objectForKey:@"logourl"]]
                       placeholderImage:nil
                                options:SDWebImageRetryFailed];
    
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

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *urlString = [[[[self.sponsorArray objectAtIndex:indexPath.section] objectForKey:@"data"] objectAtIndex:indexPath.row] objectForKey:@"logolink"];
    if ([urlString length] > 0) {
        if (![urlString hasPrefix:@"http://"] && ![urlString hasPrefix:@"https://"]) {
            urlString = [@"http://" stringByAppendingString:urlString];
        }
        NSURL *url = [NSURL URLWithString:urlString];
        
        if ([SFSafariViewController class] != nil) {
            // Open in SFSafariViewController
            SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:url];
            [[UIApplication getMostTopPresentedViewController] presentViewController:safariViewController
                                                                            animated:YES
                                                                          completion:nil];
        } else {
            // Open in Mobile Safari
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                if (!success) {
                    NSLog(@"%@%@",@"Failed to open url:", [url description]);
                }
            }];
        }
    }
    
    SEND_GAI_EVENT(@"SponsorTableView", urlString);
    // Navigation logic may go here, for example:
    // Create the next view controller.
    //<#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    //[self.navigationController pushViewController:detailViewController animated:YES];
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
