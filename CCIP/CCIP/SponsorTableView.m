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

@interface SponsorTableView ()

@end

@implementation SponsorTableView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self registerNib:[UINib nibWithNibName:@"SponsorTableViewCell" bundle:nil] forCellReuseIdentifier:@"SponsorCell"];
    
    self.delegate = self;
    self.dataSource = self;
    
    GatewayWebService *sponsor_level_ws = [[GatewayWebService alloc] initWithURL:SPONSOR_LEVEL_URL];
    [sponsor_level_ws sendRequest:^(NSArray *json, NSString *jsonStr) {
        if (json != nil) {
            self.sponsorLevelJsonArray = json;
            NSMutableArray *sponsorListArray = [[NSMutableArray alloc] init];
            
            for (NSInteger i=0; i<[self.sponsorLevelJsonArray count]; ++i) {
                [sponsorListArray addObject:[[NSMutableArray alloc] init]];
            }
            
            GatewayWebService *sponsor_list_ws = [[GatewayWebService alloc] initWithURL:SPONSOR_LIST_URL];
            [sponsor_list_ws sendRequest:^(NSArray *json, NSString *jsonStr) {
                if (json != nil) {
                    for (NSDictionary *sponsor in json) {
                        NSString *levelStr = [sponsor objectForKey:@"level"];
                        NSNumber *number = [NSNumber numberWithLongLong: levelStr.longLongValue];
                        NSUInteger level = number.unsignedIntegerValue - 1;
                        [[sponsorListArray objectAtIndex:level] addObject:sponsor];
                    }
                    
                    self.sponsorArray = sponsorListArray;
                    [self reloadData];
                }
            }];
        }
    }];
    
    SEND_GAI(@"SponsorTableView");
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.sponsorLevelJsonArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.sponsorArray objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDictionary *level = [self.sponsorLevelJsonArray objectAtIndex:section];
    NSString* language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    if ([language containsString:@"zh"]) {
        return [level objectForKey:@"namezh"];
    } else {
        return [level objectForKey:@"nameen"];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    SponsorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SponsorCell" forIndexPath:indexPath];
    
    if ([language containsString:@"zh"]) {
        cell.sponsorTitle.text = [[[self.sponsorArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"namezh"];
    } else {
        cell.sponsorTitle.text = [[[self.sponsorArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"nameen"];
    }
    
    NSString *logo = [NSString stringWithFormat:@"%@%@", COSCUP_WEB_URL, [[[self.sponsorArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"logourl"]];
    [cell.sponsorImg sd_setImageWithURL:[NSURL URLWithString:logo] placeholderImage:nil options:SDWebImageRetryFailed];
    
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
