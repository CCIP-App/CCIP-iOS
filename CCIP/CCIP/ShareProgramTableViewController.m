//
//  ShareProgramTableViewController.m
//  CCIP
//
//  Created by FrankWu on 2016/7/10.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "ShareProgramTableViewController.h"
#import <STPopup/STPopup.h>

@interface ShareProgramTableViewController ()

@end

@implementation ShareProgramTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.contentSizeInPopup = CGSizeMake(round([[UIScreen mainScreen] bounds].size.width * 4/5), 88);
    self.tableView.alwaysBounceVertical = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setProgram:(NSMutableDictionary *)program {
    _program = program;
}

- (void)doneAction:(id)sender{
    [self.popupController dismiss];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell...
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NULL];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    switch (indexPath.row) {
        case 0:
            [cell.textLabel setText:[NSString stringWithFormat:@"Share link with..."]];
            break;
        case 1:
            [cell.textLabel setText:[NSString stringWithFormat:@"Open link in Safari"]];
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO
                                                    animated:YES];
    
    NSString *subjectSubject = [self.program objectForKey:@"subject"];
    NSURL *programURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://coscup.org/2016/schedules.html#%@", [self.program objectForKey:@"slot"]]];
    
    switch (indexPath.row) {
        case 0: {
            NSArray *activityItems = @[ subjectSubject, programURL ];
            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
            //    activityVC.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypeAirDrop, UIActivityTypeCopyToPasteboard, UIActivityTypeMessage, UIActivityTypePostToTwitter, UIActivityTypePostToFacebook];
            [self presentViewController:activityVC animated:YES completion:nil];
            break;
        }
        case 1: {
            [[UIApplication sharedApplication] openURL:programURL];
            break;
        }
        default:
            break;
    }
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                   target:self
                                   action:@selector(doneAction:)];
    self.navigationItem.rightBarButtonItem = doneButton;

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
