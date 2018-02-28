//
//  ScheduleTableViewController.m
//  CCIP
//
//  Created by FrankWu on 2017/7/16.
//  Copyright © 2017年 CPRTeam. All rights reserved.
//

#import "ScheduleTableViewController.h"
#import "ScheduleTableViewCell.h"
#import "ScheduleDetailViewController.h"
#import "UIColor+addition.h"
#import "AppDelegate.h"

@interface ScheduleTableViewController ()

@property (strong, nonatomic) NSMutableArray *programTimes;
@property (strong, nonatomic) NSMutableDictionary *programSections;

@end

@implementation ScheduleTableViewController

static NSDateFormatter *formatter_full = nil;
static NSDateFormatter *formatter_date = nil;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerForceTouch];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if (formatter_full == nil) {
        formatter_full = [NSDateFormatter new];
        [formatter_full setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    }
    if (formatter_date == nil) {
        formatter_date = [NSDateFormatter new];
        [formatter_date setDateFormat:@"HH:mm"];
        [formatter_date setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Taipei"]];
    }
    self.programTimes = [NSMutableArray new];
    self.programSections = [NSMutableDictionary new];
    for (NSDictionary *program in self.programs) {
        NSDate *startTime = [formatter_full dateFromString:[program objectForKey:@"start"]];
        NSString *start = [formatter_date stringFromDate:startTime];
        NSMutableArray *section = [self.programSections objectForKey:start];
        if (section == nil) {
            section = [NSMutableArray new];
            [self.programTimes addObject:startTime];
        }
        [section addObject:program];
        [self.programSections setObject:section
                                 forKey:start];
    }
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeIntervalSince1970"
                                                                   ascending:YES];
    [self.programTimes sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray<id<UIPreviewActionItem>> *)previewActionItems {
    return [self previewActions];
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    UITableView *tableView = (UITableView *)[previewingContext sourceView];
    NSIndexPath *indexPath = [((NSArray *)[tableView valueForKey:@"_highlightedIndexPaths"]) firstObject];
    if (indexPath != nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle:nil];
        ScheduleDetailViewController *detailView = [storyboard instantiateViewControllerWithIdentifier:INIT_SCHEDULE_DETAIL_VIEW_STORYBOARD_ID];
        NSDate *time = [self.programTimes objectAtIndex:indexPath.section];
        NSString *timeString = [formatter_date stringFromDate:time];
        NSDictionary *program = [[self.programSections objectForKey:timeString] objectAtIndex:indexPath.row];
        [detailView setDetailData:program];
        UITableViewCell *tableCell = [tableView cellForRowAtIndexPath:indexPath];
        [previewingContext setSourceRect:[self.view convertRect:tableCell.frame fromView:tableView]];
        return detailView;
    } else {
        return nil;
    }
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self.navigationController showViewController:viewControllerToCommit sender:nil];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.programSections count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [formatter_date stringFromDate:[self.programTimes objectAtIndex:section]];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor colorFromHtmlColor:COLOR_TITLE_HIGHLIGHTED]];
    [view setTintColor:[UIColor colorFromHtmlColor:@"#ECF5F4"]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDate *time = [self.programTimes objectAtIndex:section];
    NSString *timeString = [formatter_date stringFromDate:time];
    return [[self.programSections objectForKey:timeString] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *scheduleCellName = @"ScheduleCell";
    
    ScheduleTableViewCell *cell = (ScheduleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:scheduleCellName];
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"ScheduleTableViewCell" bundle:nil] forCellReuseIdentifier:scheduleCellName];
        cell = (ScheduleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:scheduleCellName];
    }
    
    NSDate *time = [self.programTimes objectAtIndex:indexPath.section];
    NSString *timeString = [formatter_date stringFromDate:time];
    NSDictionary *program = [[self.programSections objectForKey:timeString] objectAtIndex:indexPath.row];
    [cell setDelegate:self];
    [cell setSchedule:program];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    NSDate *endTime = [formatter_full dateFromString:[program objectForKey:@"end"]];
    NSTimeInterval sinceEnd = [endTime timeIntervalSinceDate:self.pagerController.today];
    [cell setDisabled:(sinceEnd < 0)];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    NSDate *time = [self.programTimes objectAtIndex:indexPath.section];
    NSString *timeString = [formatter_date stringFromDate:time];
    NSDictionary *program = [[self.programSections objectForKey:timeString] objectAtIndex:indexPath.row];
    [self.pagerController performSegueWithIdentifier:SCHEDULE_DETAIL_VIEW_STORYBOARD_ID
                                              sender:program];
}

- (NSString *)getID:(NSDictionary *)program {
    return [NSString stringWithFormat:@"%@-%@-%@", [program objectForKey:@"room"], [program objectForKey:@"start"], [program objectForKey:@"end"]];
}

- (void)actionFavorite:(NSString *)scheduleId {
    NSDictionary *favProgram;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favorites = [NSMutableArray arrayWithArray:[userDefault arrayForKey:FAV_KEY]];
    for (NSDate *time in self.programTimes) {
        NSString *timeString = [formatter_date stringFromDate:time];
        for (NSDictionary *program in [self.programSections objectForKey:timeString]) {
            if ([[self getID:program] isEqualToString:scheduleId]) {
                favProgram = program;
                break;
            }
        }
        if (favProgram) {
            break;
        }
    }
    BOOL hasFavorite = [self hasFavorite:scheduleId];
    if (!hasFavorite) {
        [favorites addObject:favProgram];
    } else {
        [favorites removeObject:favProgram];
    }
    [userDefault setValue:favorites
                   forKey:FAV_KEY];
    [userDefault synchronize];
    [self.tableView reloadData];
}

- (BOOL)hasFavorite:(NSString *)scheduleId {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSArray *favorites = [userDefault valueForKey:FAV_KEY];
    for (NSDictionary *program in favorites) {
        if ([[self getID:program] isEqualToString:scheduleId]) {
            return YES;
        }
    }
    return NO;
}

@end
