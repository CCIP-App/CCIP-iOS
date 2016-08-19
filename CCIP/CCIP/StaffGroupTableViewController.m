//
//  StaffGroupViewController.m
//  CCIP
//
//  Created by Sars on 2016/07/10.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "GatewayWebService/GatewayWebService.h"
#import "AppDelegate.h"
#import "StaffGroupTableViewController.h"
#import "StaffViewController.h"

@interface StaffGroupViewController()

@end

@implementation StaffGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GatewayWebService *program_ws = [[GatewayWebService alloc] initWithURL:STAFF_DATA_URL];
    [program_ws sendRequest:^(NSArray *json, NSString *jsonStr, NSURLResponse *response) {
        if (json != nil) {
            self.staffJsonArray = json;
            [self.tableView reloadData];
        }
    }];
    
    SEND_GAI(@"StaffGroupView");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *destination = segue.destinationViewController;
    NSString *title = [sender text];
    [destination setTitle:title];
    if ([destination isMemberOfClass:[StaffViewController class]]) {
        StaffViewController *sgv = (StaffViewController *)destination;
        NSDictionary *groupData = [self.staffJsonArray objectAtIndex:[self.tableView indexPathForCell:sender].row];
        [sgv setGroupData:groupData];
        SEND_GAI_EVENT(@"StaffView", [groupData objectForKey:@"name"]);
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.staffJsonArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StaffGroupTableViewCell"
                                                            forIndexPath:indexPath];
    
    cell.textLabel.text = [[self.staffJsonArray objectAtIndex:indexPath.row] objectForKey:@"name"];
    
    return cell;
}

#pragma mark - UITableViewDelegate

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [tableView deselectRowAtIndexPath:indexPath
//                             animated:YES];
//    
//    UIViewController *detailViewController = [[UIViewController alloc] initWithNibName:@"StaffViewController"
//                                                                                bundle:nil];
//    [detailViewController setTitle:[[[tableView cellForRowAtIndexPath:indexPath] textLabel] text]];
//    
//    id groupData = [self.staffJsonArray objectAtIndex:indexPath.row];
//    [NSInvocation InvokeObject:detailViewController.view
//            withSelectorString:@"setGroupData:"
//                 withArguments:@[ groupData ]];
//    
//    SEND_GAI_EVENT(@"StaffView", [groupData objectForKey:@"name"]);
//    
//    [self.navigationController pushViewController:detailViewController
//                                         animated:YES];
//}

@end
