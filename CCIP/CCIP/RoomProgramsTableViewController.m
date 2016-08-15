//
//  RoomProgramsTableViewController.m
//  CCIP
//
//  Created by FrankWu on 2016/7/3.
//  Copyright © 2016年 FrankWu. All rights reserved.
//

#import "RoomProgramsTableViewController.h"
#import "GatewayWebService/GatewayWebService.h"
#import "NSInvocation+addition.h"
#import "ProgramDetailPopViewController.h"
#import <STPopup/STPopup.h>

@interface RoomProgramsTableViewController ()

@property NSMutableDictionary *sections;

@end

@implementation RoomProgramsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // MAGIC of disable topLayoutGuide
    [self.navigationController.navigationBar setTranslucent:NO];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(refreshData)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)refreshData {
    GatewayWebService *program_ws = [[GatewayWebService alloc] initWithURL:PROGRAM_DATA_URL];
    [program_ws sendRequest:^(NSArray *json, NSString *jsonStr, NSURLResponse *response) {
        if (json != nil) {
            NSLog(@"%@", json);
            
            if ([self.room isEqualToString:@"all"]) {
                self.programs = json;
            } else {
                NSMutableArray *mutableArray  = [NSMutableArray new];
                for (NSDictionary *dict in json) {
                    if ([[dict objectForKey:@"room"] isEqualToString:self.room]) {
                        [mutableArray addObject:dict];
                    }
                }
                self.programs = [mutableArray copy];
            }
            [self.tableView reloadData];
        }
        [self.refreshControl endRefreshing];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
//    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        [self.navigationController.interactivePopGestureRecognizer setEnabled:NO];
//        [self.navigationController.interactivePopGestureRecognizer setDelegate:self];
//    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        [self.navigationController.interactivePopGestureRecognizer setEnabled:YES];
//        [self.navigationController.interactivePopGestureRecognizer setDelegate:nil];
//    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setRoom:(NSString *)room {
    _room = room;
    self.title = _room;
}

- (void)setPrograms:(NSMutableArray *)programs {
    _programs = programs;
    
    NSDateFormatter *formatter_full = [[NSDateFormatter alloc] init];
    [formatter_full setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    [formatter_full setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    NSDateFormatter *formatter_s = [[NSDateFormatter alloc] init];
    
    NSDate *time_full = [NSDate new];
    
    self.sections = [NSMutableDictionary new];
    
    if ([self.room isEqualToString:@"all"]) {
        [formatter_s setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    } else {
        [formatter_s setDateFormat:@"yyyy-MM-dd"];
    }
    
    for (NSDictionary *program in self.programs) {
        time_full = [formatter_full dateFromString:[program objectForKey:@"starttime"]];
        NSString *time_s = [formatter_s stringFromDate:time_full];
        
        NSMutableArray *rows = [self.sections objectForKey:time_s];
        if (rows == nil) {
            rows = [NSMutableArray new];
        }
        [rows addObject:program];
        [self.sections setObject:rows forKey:time_s];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *allKeys = [[self.sections allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    return [[self.sections objectForKey:[allKeys objectAtIndex:section]] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray *allKeys = [[self.sections allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    NSString *dateString = [allKeys objectAtIndex:section];
    return dateString;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NULL];
    [cell setAccessoryType:UITableViewCellAccessoryDetailButton];
    
    NSArray *allKeys = [[self.sections allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    NSDictionary *program = [[self.sections objectForKey:[allKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    [cell.textLabel setText:[program objectForKey:@"subject"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO
                                                    animated:YES];
    // TODO: display selected section detail informations
    NSArray *allKeys = [[self.sections allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    NSDictionary *program = [[self.sections objectForKey:[allKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    ProgramDetailPopViewController *detailViewController = [ProgramDetailPopViewController new];
    detailViewController.title = [program objectForKey:@"subject"];
    [NSInvocation InvokeObject:detailViewController
            withSelectorString:@"setProgram:"
                 withArguments:@[ program ]];
    
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:detailViewController];
    popupController.containerView.layer.cornerRadius = 4;
//    popupController.navigationBar.barTintColor = [UIColor colorWithRed:0.20 green:0.60 blue:0.86 alpha:1.0];
//    popupController.navigationBar.tintColor = [UIColor whiteColor];
    popupController.navigationBar.barStyle = UIBarStyleDefault;
    
//    if (NSClassFromString(@"UIBlurEffect")) {
//        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
//        popupController.backgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
//    }
    
    [popupController.backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:detailViewController action:@selector(backgroundViewDidTap)]];
    
    [popupController presentInViewController:self];
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
