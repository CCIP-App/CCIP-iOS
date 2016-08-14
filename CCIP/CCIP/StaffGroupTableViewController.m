//
//  StaffGroupView.m
//  CCIP
//
//  Created by Sars on 2016/07/10.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "AppDelegate.h"
#import "StaffGroupTableViewController.h"
#import "GatewayWebService/GatewayWebService.h"

@interface StaffGroupView()

@end

@implementation StaffGroupView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"StaffGroupTableViewCell" bundle:nil] forCellReuseIdentifier:@"StaffGroupViewCell"];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    GatewayWebService *program_ws = [[GatewayWebService alloc] initWithURL:STAFF_DATA_URL];
    [program_ws sendRequest:^(NSArray *json, NSString *jsonStr) {
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.staffJsonArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StaffGroupViewCell" forIndexPath:indexPath];
    
    cell.textLabel.text = [[self.staffJsonArray objectAtIndex:indexPath.row] objectForKey:@"name"];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *detailViewController;
    NSString *vcName = @"StaffView";
    detailViewController = [[UIViewController alloc] initWithNibName:vcName bundle:nil];
    [detailViewController setTitle:[[[tableView cellForRowAtIndexPath:indexPath] textLabel] text]];
    
    [NSInvocation InvokeObject:detailViewController.view withSelectorString:@"setGroupData:" withArguments:@[ [self.staffJsonArray objectAtIndex:indexPath.row]]];
    
    SEND_GAI_EVENT(@"StaffView", [[self.staffJsonArray objectAtIndex:indexPath.row] objectForKey:@"name"]);
    
    [self.navigationController pushViewController:detailViewController animated:YES];
}

@end
