//
//  TableViewController.m
//  CCIP
//
//  Created by 腹黒い茶 on 2016/06/25.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "AppDelegate.h"
#import "GatewayWebService/GatewayWebService.h"
#import "TableViewController.h"
#import "scenarioCell.h"

@interface TableViewController ()

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) NSArray *scenarios;

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    GatewayWebService *ws = [[GatewayWebService alloc] initWithURL:CC_STATUS(self.appDelegate.accessToken)];
    [ws sendRequest:^(NSDictionary *json, NSString *jsonStr) {
        if (json != nil) {
            NSLog(@"%@", json);
            self.scenarios = [json objectForKey:@"scenarios"];
            [self.tableView reloadData];
        }
    }];
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
    return [self.scenarios count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"scenario";
    scenarioCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"scenarioCell"
                                              bundle:nil]
        forCellReuseIdentifier:CellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    NSDictionary *scenario = [self.scenarios objectAtIndex:indexPath.row];
    [cell.scenarioLabel setText:[scenario objectForKey:@"id"]];
    if ([[scenario allKeys] containsObject:@"disabled"]) {
        if ([[scenario objectForKey:@"disabled"] length] > 0) {
            [cell.scenarioLabel setTextColor:[UIColor lightGrayColor]];
            [cell setBackgroundColor:[UIColor colorWithWhite:0.8f alpha:0.5f]];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [cell setUserInteractionEnabled:NO];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *scenario = [self.scenarios objectAtIndex:indexPath.row];
    
    UIViewController *detailViewController = [[UIViewController alloc] initWithNibName:nil
                                                                                bundle:nil];
    [detailViewController setTitle:[scenario objectForKey:@"id"]];
    [detailViewController.view setBackgroundColor:[UIColor whiteColor]];
    [detailViewController.navigationItem setLeftBarButtonItem:self.splitViewController.displayModeButtonItem];
    [detailViewController.navigationItem setLeftItemsSupplementBackButton:YES];
    
    UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
    
    [self.splitViewController showDetailViewController:detailNavigationController
                                                sender:self];
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
