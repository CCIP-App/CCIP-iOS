//
//  SponsorTableViewController.m
//  CCIP
//
//  Created by Sars on 8/6/16.
//  Copyright © 2016 CPRTeam. All rights reserved.
//

#import "SponsorTableView.h"
#import "SponsorTableViewCell.h"
#import "AppDelegate.h"
#import "GatewayWebService/GatewayWebService.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SafariServices/SafariServices.h>

@interface SponsorTableView ()

@end

@implementation SponsorTableView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self registerNib:[UINib nibWithNibName:@"SponsorTableViewCell" bundle:nil] forCellReuseIdentifier:@"SponsorCell"];
    
    self.delegate = self;
    self.dataSource = self;
    
    NSMutableArray *sponsorListArray = [NSMutableArray new];
    
    dispatch_semaphore_t semaLevel = dispatch_semaphore_create(0);
    
    GatewayWebService *sponsor_level_ws = [[GatewayWebService alloc] initWithURL:SPONSOR_LEVEL_URL];
    [sponsor_level_ws sendRequest:^(NSArray *json, NSString *jsonStr, NSURLResponse *response) {
        if (json != nil) {
            self.sponsorLevelJsonArray = json;
        }
        dispatch_semaphore_signal(semaLevel);
    }];
    
    while (dispatch_semaphore_wait(semaLevel, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    }
    
    for (id item in self.sponsorLevelJsonArray) {
        NSLog(@"Level: %@", item);
        [sponsorListArray addObject:[NSMutableArray new]];
    }
    
    dispatch_semaphore_t semaList = dispatch_semaphore_create(0);
    
    GatewayWebService *sponsor_list_ws = [[GatewayWebService alloc] initWithURL:SPONSOR_LIST_URL];
    [sponsor_list_ws sendRequest:^(NSArray *json, NSString *jsonStr, NSURLResponse *response) {
        if (json != nil) {
            for (NSDictionary *sponsor in json) {
                NSUInteger index = [[sponsor objectForKey:@"level"] unsignedIntegerValue] - 1;
                [[sponsorListArray objectAtIndex:index] addObject:sponsor];
            }
        }
        dispatch_semaphore_signal(semaList);
    }];
    
    while (dispatch_semaphore_wait(semaList, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    }
    
    NSSortDescriptor *level_sorter = [[NSSortDescriptor alloc] initWithKey:@"@max.level"
                                                                 ascending:YES];
    NSSortDescriptor *place_sorter = [[NSSortDescriptor alloc] initWithKey:@"@max.place"
                                                                 ascending:YES];
    self.sponsorArray = [sponsorListArray sortedArrayUsingDescriptors:@[ level_sorter, place_sorter ]];
    
    [self beginUpdates];
    
    [self insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self.sponsorLevelJsonArray count])]
        withRowAnimation:UITableViewRowAnimationFade];
    
    NSMutableArray *indexPaths = [NSMutableArray new];
    for (int sectionNum = 0; sectionNum < [self.sponsorLevelJsonArray count]; sectionNum++) {
        for (int rowNum = 0; rowNum < [[self.sponsorArray objectAtIndex:sectionNum] count]; rowNum++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:rowNum
                                                     inSection:sectionNum]];
        }
    }
    [self insertRowsAtIndexPaths:indexPaths
                withRowAnimation:UITableViewRowAnimationFade];
    
    [self endUpdates];
    
    SEND_GAI(@"SponsorTableView");
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.sponsorLevelJsonArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSPredicate *secs = [NSPredicate predicateWithFormat:@"ANY level = %ld", section + 1];
    NSArray *filteredArray = [[self.sponsorArray filteredArrayUsingPredicate:secs] firstObject];
    return filteredArray != nil ? [filteredArray count] : 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSPredicate *secs = [NSPredicate predicateWithFormat:@"level = %ld", section + 1];
    NSDictionary *level = [[self.sponsorLevelJsonArray filteredArrayUsingPredicate:secs] firstObject];
    NSString *language = NSLocalizedString(@"CurrentLang", nil);
    if ([language containsString:@"zh"]) {
        return [level objectForKey:@"namezh"];
    } else {
        return [level objectForKey:@"nameen"];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SponsorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SponsorCell" forIndexPath:indexPath];
    
    NSString *language = NSLocalizedString(@"CurrentLang", nil);
    
    NSPredicate *secs = [NSPredicate predicateWithFormat:@"ANY level = %ld", indexPath.section + 1];
    NSPredicate *rows = [NSPredicate predicateWithFormat:@"place = %ld", indexPath.row + 1];
    NSArray *filteredSec = [[self.sponsorArray filteredArrayUsingPredicate:secs] firstObject];
    NSDictionary *filteredRow = [[filteredSec filteredArrayUsingPredicate:rows] firstObject];
    
    if ([language containsString:@"en"]) {
        cell.sponsorTitle.text = [filteredRow objectForKey:@"nameen"];
    } else {
        cell.sponsorTitle.text = [filteredRow objectForKey:@"namezh"];
    }
    
    NSString *logo = [NSString stringWithFormat:@"%@%@", COSCUP_BASE_URL, [filteredRow objectForKey:@"logourl"]];
    [cell.sponsorImg sd_setImageWithURL:[NSURL URLWithString:logo]
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
    
    NSString *url = [[[self.sponsorArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"logolink"];
    if (![url hasPrefix:@"http://"] && ![url hasPrefix:@"https://"]) {
        url = [@"http://" stringByAppendingString:url];
    }
    
    if ([SFSafariViewController class] != nil) {
        // Open in SFSafariViewController
        SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:url]];        
        [[UIApplication getMostTopPresentedViewController] presentViewController:safariViewController
                                                                        animated:YES
                                                                      completion:nil];
    } else {
        // Open in Mobile Safari
        if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]]) {
            NSLog(@"%@%@",@"Failed to open url:", [[NSURL URLWithString:url] description]);
        }
    }
    
    SEND_GAI_EVENT(@"SponsorTableView", url);
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
