//
//  ScheduleDetailTableViewController.m
//  CCIP
//
//  Created by FrankWu on 2017/7/22.
//  Copyright © 2017年 CPRTeam. All rights reserved.
//

#import "ScheduleDetailTableViewController.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "ScheduleDetailViewController.h"
#import "ScheduleAbstractViewCell.h"
#import "ScheduleSpeakerInfoViewCell.h"

#define ABSTRACT_CELL       (@"ScheduleAbstract")
#define SPEAKERINFO_CELL    (@"ScheduleSpeakerInfo")

@interface ScheduleDetailTableViewController ()

@property (strong, nonatomic) NSArray *identifiers;
@property (strong, nonatomic) NSDictionary *schedule;

@end

@implementation ScheduleDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.identifiers = @[ ABSTRACT_CELL, SPEAKERINFO_CELL ];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    self.schedule = [((ScheduleDetailViewController *)self.parentViewController) getDetailData];
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
    return [self.identifiers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self.identifiers objectAtIndex:indexPath.row]];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:[self.identifiers objectAtIndex:indexPath.row] configuration:^(id cell) {
        [self configureCell:cell atIndexPath:indexPath];
    }];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    [cell setFd_enforceFrameLayout:NO]; // Enable to use "-sizeThatFits:"
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setClipsToBounds:NO];
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell.layer setZPosition:indexPath.row];
    UIView *vwContent = [cell performSelector:@selector(vwContent)];
    [vwContent.layer setCornerRadius:5.0f];
    [vwContent.layer setShadowRadius:50.0f];
    [vwContent.layer setShadowOffset:CGSizeMake(0, 50)];
    [vwContent.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [vwContent.layer setShadowOpacity:0.1f];
    [vwContent.layer setMasksToBounds:NO];
    NSDictionary *cells = @{
      ABSTRACT_CELL: ^{
          ScheduleAbstractViewCell *abstractCell = (ScheduleAbstractViewCell *)cell;
          NSString *summary = [NSString stringWithFormat:@"%@\n", [self.schedule objectForKey:@"summary"]];
          NSLog(@"Set summary: %@", summary);
          [abstractCell.lbAbstractContent setText:summary];
          [abstractCell.lbAbstractContent sizeToFit];
      },
      SPEAKERINFO_CELL: ^{
          ScheduleSpeakerInfoViewCell *speakerInfoCell = (ScheduleSpeakerInfoViewCell *)cell;
          NSString *bio = [NSString stringWithFormat:@"%@\n", [[self.schedule objectForKey:@"speaker"] objectForKey:@"bio"]];
          NSLog(@"Set bio: %@", bio);
          [speakerInfoCell.lbSpeakerInfoContent setText:bio];
          [speakerInfoCell.lbSpeakerInfoContent sizeToFit];
      }
      };
    @try {
        void(^block)(void) = [cells objectForKey:[self.identifiers objectAtIndex:indexPath.row]];
        block();
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
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
