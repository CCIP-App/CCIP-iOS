//
//  MoreTableViewController.m
//  CCIP
//
//  Created by Sars on 7/17/16.
//  Copyright © 2016 CPRTeam. All rights reserved.
//

#import "AppDelegate.h"
#import "MoreTableViewController.h"
#import "AcknowledgementsViewController.h"

@interface MoreTableViewController ()

@property (strong, nonatomic) NSDictionary *userInfo;

@end

@implementation MoreTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIEdgeInsets contentInset = [self.moreTableView contentInset];
    UIEdgeInsets scrollInset = [self.moreTableView scrollIndicatorInsets];
    contentInset.bottom += self.bottomGuideHeight;
    scrollInset.bottom += self.bottomGuideHeight;
    [self.moreTableView setContentInset:contentInset];
    [self.moreTableView setScrollIndicatorInsets:scrollInset];
    
    [self.moreTableView registerNib:[UINib nibWithNibName:@"MoreCell" bundle:nil] forCellReuseIdentifier:@"MoreCell"];
    
    self.userInfo = [[AppDelegate appDelegate] userInfo];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    SEND_GAI(@"MoreTableViewController");
    
    UIEdgeInsets viewInset = [self.moreTableView contentInset];
    UIEdgeInsets viewScrollInset = [self.moreTableView scrollIndicatorInsets];
    
    viewInset.bottom = self.bottomGuideHeight;
    viewInset.top = self.topGuideHeight;
    
    viewScrollInset.bottom = self.bottomGuideHeight;
    viewScrollInset.top = self.topGuideHeight;
    
    [self.moreTableView setContentInset:viewInset];
    [self.moreTableView setScrollIndicatorInsets:viewScrollInset];
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
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.userInfo != nil && [[self.userInfo allKeys] containsObject:@"user_id"] ? [NSString stringWithFormat:NSLocalizedString(@"Hi", nil), [self.userInfo objectForKey:@"user_id"]] : nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MoreCell" forIndexPath:indexPath];
    
    switch (indexPath.row) {
        case 0:
            [cell.textLabel setText:NSLocalizedString(@"Staffs", nil)];
            break;
        case 1:
            [cell.textLabel setText:NSLocalizedString(@"Sponsors", nil)];
            break;
        case 2:
            [cell.textLabel setText:NSLocalizedString(@"Acknowledgements", nil)];
            break;
        default:
            break;
    }
    
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *detailViewController;
    NSString *nibName;
    
    switch (indexPath.row) {
        case 0:
            nibName = @"StaffGroupView";
            detailViewController = [[UIViewController alloc] initWithNibName:nibName bundle:nil];
            break;
        case 1:
            nibName = @"SponsorTableView";
            detailViewController = [[UIViewController alloc] initWithNibName:nibName bundle:nil];
            break;
        case 2: {
            nibName = @"AcknowledgementsView";
            detailViewController = [AcknowledgementsViewController new];
        }
        default:
            break;
    }
    
    [detailViewController setTitle:[[[tableView cellForRowAtIndexPath:indexPath] textLabel] text]];
    [self.navigationController pushViewController:detailViewController animated:YES];
    
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
