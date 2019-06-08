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
#import "AppDelegate.h"

@interface ScheduleTableViewController ()

@property (strong, nonatomic) NSMutableArray *programTimes;
@property (strong, nonatomic) NSMutableDictionary *programSections;

@end

@implementation ScheduleTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerForceTouch];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.programTimes = [NSMutableArray new];
    self.programSections = [NSMutableDictionary new];
    for (NSDictionary *program in self.programs) {
        NSDate *startTime = [Constants DateFromString:[program objectForKey:@"start"]];
        NSString *start = [Constants DateToDisplayTimeString:startTime];
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
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Schedule"
                                                             bundle:nil];
        ScheduleDetailViewController *detailView = [storyboard instantiateViewControllerWithIdentifier:INIT_SCHEDULE_DETAIL_VIEW_STORYBOARD_ID];
        NSDate *time = [self.programTimes objectAtIndex:indexPath.section];
        NSString *timeString = [Constants DateToDisplayTimeString:time];
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
    return [Constants DateToDisplayTimeString:[self.programTimes objectAtIndex:section]];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[AppDelegate AppConfigColor:@"ScheduleSectionTitleTextColor"]];
    [view setTintColor:[AppDelegate AppConfigColor:@"ScheduleSectionTitleBackgroundColor"]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDate *time = [self.programTimes objectAtIndex:section];
    NSString *timeString = [Constants DateToDisplayTimeString:time];
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
    NSString *timeString = [Constants DateToDisplayTimeString:time];
    NSDictionary *program = [[self.programSections objectForKey:timeString] objectAtIndex:indexPath.row];
    [cell setDelegate:self];
    [cell setSchedule:program];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    NSDate *endTime = [Constants DateFromString:[program objectForKey:@"end"]];
    NSTimeInterval sinceEnd = [endTime timeIntervalSinceDate:self.pagerController.today];
    [cell setDisabled:(sinceEnd < 0)];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    NSDate *time = [self.programTimes objectAtIndex:indexPath.section];
    NSString *timeString = [Constants DateToDisplayTimeString:time];
    NSDictionary *program = [[self.programSections objectForKey:timeString] objectAtIndex:indexPath.row];
    [self.pagerController performSegueWithIdentifier:SCHEDULE_DETAIL_VIEW_STORYBOARD_ID
                                              sender:program];
}

- (NSString *)getID:(NSDictionary *)program {
    return [NSString stringWithFormat:@"%@-%@-%@", [program objectForKey:@"room"], [program objectForKey:@"start"], [program objectForKey:@"end"]];
}

- (void)actionFavorite:(NSString *)scheduleId {
    NSDictionary *favProgram = @{};
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSObject *favObj = [userDefault valueForKey:FAV_KEY];
    NSArray *favoriteArray = [favObj isKindOfClass:[NSData class]] ? [NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)favObj] : favObj;
    NSMutableArray *favorites = [NSMutableArray arrayWithArray:favoriteArray];
    for (NSDate *time in self.programTimes) {
        NSString *timeString = [Constants DateToDisplayTimeString:time];
        for (NSDictionary *program in [self.programSections objectForKey:timeString]) {
            if (program != nil && [[self getID:program] isEqualToString:scheduleId]) {
                favProgram = program;
                break;
            }
        }
        if ([[favProgram allKeys] count] > 0) {
            break;
        }
    }
    BOOL hasFavorite = [self hasFavorite:scheduleId];
    if (!hasFavorite) {
        [favorites addObject:favProgram];
    } else {
        [favorites removeObject:favProgram];
    }
    NSData *favData = [NSKeyedArchiver archivedDataWithRootObject:favorites];
    [userDefault setValue:favData
                   forKey:FAV_KEY];
    [userDefault synchronize];
    [self.tableView reloadData];
//    [OPassAPI RegisteringFavoriteScheduleForEvent:[Constants EventId]
//                                        withToken:[Constants AccessToken]
//                                       toSchedule:scheduleId
//                                        isDisable:NO
//                                       completion:^(BOOL success, id _Nullable obj, NSError * _Nonnull error) {
//                                           NSLog(@"%@", obj);
//                                       }];
}

- (BOOL)hasFavorite:(NSString *)scheduleId {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    // ugly convension for crash prevent
    NSObject *favObj = [userDefault valueForKey:FAV_KEY];
    NSArray *favorites = [favObj isKindOfClass:[NSData class]] ? [NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)favObj] : favObj;
    for (NSDictionary *program in favorites) {
        if ([[self getID:program] isEqualToString:scheduleId]) {
            return YES;
        }
    }
    return NO;
}

@end
