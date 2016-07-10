//
//  MasterViewController.m
//  textmv
//
//  Created by FrankWu on 2016/6/25.
//  Copyright © 2016年 FrankWu. All rights reserved.
//

#import "AppDelegate.h"
#import "GatewayWebService/GatewayWebService.h"
#import "MasterViewController.h"
#import "scenarioCell.h"
#import "UIAlertController+additional.h"
#import "RoomLocationViewController.h"

@interface MasterViewController ()

@property NSMutableArray *objects;
@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) NSDictionary *userInfo;
@property (strong, nonatomic) NSArray *scenarios;

@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.appDelegate.navigationView = (NavigationController *)self.navigationController;
    self.appDelegate.masterView = self;
    [self setTitle:NSLocalizedString(@"Title", nil)];
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self
                            action:@selector(refreshData)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)refreshData {
    [self.refreshControl beginRefreshing];
    
    GatewayWebService *roome_ws = [[GatewayWebService alloc] initWithURL:ROOM_DATA_URL];
    [roome_ws sendRequest:^(NSArray *json, NSString *jsonStr) {
        if (json != nil) {
            NSLog(@"%@", json);
            self.roomsJsonArray = json;
            [self.tableView reloadData];
        }
    }];
    
    GatewayWebService *program_ws = [[GatewayWebService alloc] initWithURL:PROGRAM_DATA_URL];
    [program_ws sendRequest:^(NSArray *json, NSString *jsonStr) {
        if (json != nil) {
            NSLog(@"%@", json);
            self.programsJsonArray = json;
            [self.tableView reloadData];
        }
    }];
    
    GatewayWebService *ws = [[GatewayWebService alloc] initWithURL:CC_STATUS(self.appDelegate.accessToken)];
    [ws sendRequest:^(NSDictionary *json, NSString *jsonStr) {
        if (json != nil) {
            NSLog(@"%@", json);
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:json];
            [userInfo removeObjectForKey:@"scenarios"];
            self.userInfo = [NSDictionary dictionaryWithDictionary:userInfo];
            self.scenarios = [json objectForKey:@"scenarios"];
            [self.appDelegate.oneSignal sendTag:@"user_id" value:[json objectForKey:@"user_id"]];
            [self.tableView reloadData];
        }
        [self.refreshControl endRefreshing];
    }];
}


- (void)viewWillAppear:(BOOL)animated {
    [self setClearsSelectionOnViewWillAppear:[self.splitViewController isCollapsed]];
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"MasterView"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    [self refreshData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return (self.roomsJsonArray != nil && self.programsJsonArray != nil) ? 2 : 0;
        case 1:
            return [self.scenarios count];
        case 2:
            return 1;
        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 1:
            return 66.0f;
            break;
        default:
            return 44.0f;
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return NSLocalizedString(@"Schedule", nil);
        case 1:
            return self.userInfo != nil ? [self.userInfo objectForKey:@"user_id"] : @"";
        case 2:
            return NSLocalizedString(@"Addition", nil);
        default:
            return 0;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        // section 0 Start
        
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NULL];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
        switch (indexPath.row) {
            case 0:
                [cell.textLabel setText:NSLocalizedString(@"HSSBuilding", nil)];
                break;
            case 1:
                [cell.textLabel setText:NSLocalizedString(@"ActivityCenter", nil)];
                break;
            default:
                [cell.textLabel setText:@"null"];
                break;
        }
        
        return cell;
        // section 0 End
    } else if (indexPath.section == 1) {
        // section 1 Start
        
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
        NSDate *availableTime = [NSDate dateWithTimeIntervalSince1970:[[scenario objectForKey:@"available_time"] integerValue]];
        NSDate *expireTime = [NSDate dateWithTimeIntervalSince1970:[[scenario objectForKey:@"expire_time"] integerValue]];
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"MM/dd HH:mm"];
        NSDate *nowTime = [NSDate new];
        if ([nowTime compare:availableTime] != NSOrderedAscending && [nowTime compare:expireTime] != NSOrderedDescending) {
            // IN TIME
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        } else {
            // OUT TIME
            [cell setAccessoryType:UITableViewCellAccessoryDetailButton];
        }
        [cell.scenarioLabel setText:[scenario objectForKey:@"id"]];
        [cell.timeRangeLabel setText:[NSString stringWithFormat:@"%@ ~ %@", [formatter stringFromDate:availableTime], [formatter stringFromDate:expireTime]]];
        
        NSString *usedTimeString = @"";
        if ([[scenario allKeys] containsObject:@"disabled"]) {
            if ([[scenario objectForKey:@"disabled"] length] > 0) {
                [cell setAccessoryType:UITableViewCellAccessoryDetailButton];
                [cell.scenarioLabel setTextColor:[UIColor lightGrayColor]];
                [cell setBackgroundColor:[UIColor colorWithWhite:0.8f alpha:0.5f]];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                [cell setUserInteractionEnabled:NO];
            }
        }
        if ([[scenario allKeys] containsObject:@"used"]) {
            NSInteger usedTime = [[scenario objectForKey:@"used"] integerValue];
            if (usedTime > 0) {
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                [formatter setDateFormat:@"MM/dd HH:mm:ss"];
                usedTimeString = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:usedTime]];
                [formatter setDateFormat:@"MM/dd HH:mm"];
            }
        }
        [cell.usedTimeLabel setText:usedTimeString];
        
        return cell;
        // section 1 End
    } else if (indexPath.section == 2) {
        // section 0 Start
        
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NULL];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
        switch (indexPath.row) {
            case 0:
                [cell.textLabel setText:@"IRC"];
                break;
            default:
                [cell.textLabel setText:@"null"];
                break;
        }
        
        return cell;
        // section 0 End
    } else {
        // default
        
        return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NULL];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        // section 0 Start
        RoomLocationViewController *roomLocationView = [RoomLocationViewController new];
        [roomLocationView setTitle:[[[tableView cellForRowAtIndexPath:indexPath] textLabel] text]];
        
        NSMutableArray *rooms = [NSMutableArray new];
        NSString *roomKey = @"";
        
        switch (indexPath.row) {
            case 0:
                roomKey = @"R";
                break;
            case 1:
                roomKey = @"H";
                break;
            default:
                roomKey = @"";
                break;
        }
        
        for (NSDictionary *dict in self.roomsJsonArray) {
            if ([[[dict objectForKey:@"room"] substringToIndex:1] isEqualToString:roomKey]) {
                [rooms addObject:dict];
            }
        }
        
        [NSInvocation InvokeObject:roomLocationView
                withSelectorString:@"setRooms:"
                     withArguments:@[ rooms ]];
        
        [NSInvocation InvokeObject:roomLocationView
                withSelectorString:@"setRoomPrograms:"
                     withArguments:@[ self.programsJsonArray ]];
        
        
        [self.navigationController pushViewController:roomLocationView
                                             animated:YES];
        
        // section 0 End
    } else if (indexPath.section == 1) {
        // section 1 Start
        
        NSDictionary *scenario = [self.scenarios objectAtIndex:indexPath.row];
        BOOL isUsed = [[scenario allKeys] containsObject:@"used"] ? [scenario objectForKey:@"used"] > 0 : NO;
        NSString *vcName = isUsed ? @"StatusView" : @"CheckinView";
        vcName = @"CheckinView";
        UIViewController *detailViewController = [[UIViewController alloc] initWithNibName:vcName
                                                                                    bundle:nil];
        [detailViewController.view setBackgroundColor:[UIColor whiteColor]];
        
        NSDate *availableTime = [NSDate dateWithTimeIntervalSince1970:[[scenario objectForKey:@"available_time"] integerValue]];
        NSDate *expireTime = [NSDate dateWithTimeIntervalSince1970:[[scenario objectForKey:@"expire_time"] integerValue]];
        NSDate *nowTime = [NSDate new];
        
        if ([nowTime compare:availableTime] != NSOrderedAscending && [nowTime compare:expireTime] != NSOrderedDescending) {
            // IN TIME Start
            [NSInvocation InvokeObject:detailViewController.view
                    withSelectorString:@"setScenario:"
                         withArguments:@[ scenario ]];
            [detailViewController setTitle:[scenario objectForKey:@"id"]];
            [self.navigationController pushViewController:detailViewController
                                                 animated:YES];
            // IN TIME End
        } else {
            // OUT TIME Start
            NSDate *countTime = [NSDate new];
            float maxValue = (float)([[scenario objectForKey:@"used"] intValue] + [[scenario objectForKey:@"countdown"] intValue] - [countTime timeIntervalSince1970]);
            float interval = [[NSDate new] timeIntervalSinceDate:countTime];
            float countDown = maxValue - interval;
            BOOL isUsed = [[scenario allKeys] containsObject:@"used"] && [[scenario objectForKey:@"used"] intValue] > 0 && countDown <= 0;
            
            UIAlertController *ac = nil;
            if ([nowTime compare:availableTime] == NSOrderedAscending) {
                ac = [UIAlertController alertOfTitle:NSLocalizedString(@"NotAvailableTitle", nil)
                                         withMessage:NSLocalizedString(@"NotAvailableMessage", nil)
                                    cancelButtonText:NSLocalizedString(@"NotAvailableButtonOk", nil)
                                         cancelStyle:UIAlertActionStyleDestructive
                                        cancelAction:^(UIAlertAction *action) {
                                            [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO
                                                                                            animated:YES];
                                        }];
            }
            if ([nowTime compare:expireTime] == NSOrderedDescending || isUsed) {
                ac = [UIAlertController alertOfTitle:NSLocalizedString(@"ExpiredTitle", nil)
                                         withMessage:NSLocalizedString(@"ExpiredMessage", nil)
                                    cancelButtonText:NSLocalizedString(@"ExpiredButtonOk", nil)
                                         cancelStyle:UIAlertActionStyleDestructive
                                        cancelAction:^(UIAlertAction *action) {
                                            [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO
                                                                                            animated:YES];
                                        }];
            }
            if (ac != nil) {
                [ac showAlert:^{}];
            }
            // OUT TIME End
        }
        // section 1 End
    } else if (indexPath.section == 2) {
        // section 2 Start
        NSString *vcName = @"IRCView";
        UIViewController *detailViewController = [[UIViewController alloc] initWithNibName:vcName bundle:nil];
        
        [NSInvocation InvokeObject:detailViewController.view
                withSelectorString:@"setURL:"
                     withArguments:@[ @{@"url": LOG_BOT_URL} ]];

        [detailViewController setTitle:[[[tableView cellForRowAtIndexPath:indexPath] textLabel] text]];
        [self.navigationController pushViewController:detailViewController
                                             animated:YES];
        // section 2 End
    }
}

- (void)gotoTop {
    [self.appDelegate.navigationView popToRootViewControllerAnimated:YES];
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
