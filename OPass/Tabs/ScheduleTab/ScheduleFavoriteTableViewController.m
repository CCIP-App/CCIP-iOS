//
//  ScheduleFavoriteTableViewController.m
//  CCIP
//
//  Created by 腹黒い茶 on 2017/07/25.
//  Copyright © 2017年 CPRTeam. All rights reserved.
//

#import "AppDelegate.h"
#import "ScheduleFavoriteTableViewController.h"
#import "ScheduleTableViewController.h"
#import "ScheduleTableViewCell.h"
#import "ScheduleDetailViewController.h"

@interface ScheduleFavoriteTableViewController ()

@property (strong, nonatomic) NSMutableArray *favoriteTimes;
@property (strong, nonatomic) NSMutableDictionary *favoritesSections;

@end

@implementation ScheduleFavoriteTableViewController

static UIView *headView;
static NSDate *today = nil;
static NSDateFormatter *formatter_full = nil;
static NSDateFormatter *formatter_date = nil;

- (void)viewDidLoad {
    [super viewDidLoad];
    if (formatter_full == nil) {
        formatter_full = [NSDateFormatter new];
        [formatter_full setDateFormat:[AppDelegate AppConfig:@"DateTimeFormat"]];
    }
    if (formatter_date == nil) {
        formatter_date = [NSDateFormatter new];
        [formatter_date setDateFormat:[NSString stringWithFormat:@"%@ %@", [AppDelegate AppConfig:@"DisplayDateFormat"], [AppDelegate AppConfig:@"DisplayTimeFormat"]]];
        [formatter_date setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Taipei"]];
    }
    if (today == nil) {
        today = [NSDate new];
    }
    
    [self parseFavorites];
    
    [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];

    NSDictionary *titleAttribute = @{
                                     NSFontAttributeName: [Constants fontOfAwesomeWithSize:20 inStyle:fontAwesomeStyleSolid],
                                     NSForegroundColorAttributeName: [UIColor whiteColor],
                                     };
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:[Constants fontAwesomeWithCode:@"fa-heart"] attributes:titleAttribute];

    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    [lbTitle setTextAlignment:NSTextAlignmentCenter];
    [lbTitle setTextColor:[UIColor whiteColor]];
    [lbTitle setAttributedText:title];
    [self.navigationItem setTitleView:lbTitle];
    [self.navigationItem setTitle:@""];
    
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect frame = CGRectMake(0, 0,
                              self.view.frame.size.width, self.navigationController.navigationBar.frame.origin.y + navigationBarBounds.size.height);
    headView = [UIView new];
    [headView setFrame:frame];
    [headView setGradientColorFrom:[AppDelegate AppConfigColor:@"ScheduleTitleLeftColor"]
                                to:[AppDelegate AppConfigColor:@"ScheduleTitleRightColor"]
                        startPoint:CGPointMake(-.4f, .5f)
                           toPoint:CGPointMake(1, .5f)];
    [self.navigationController.navigationBar.superview addSubview:headView];
    [self.navigationController.navigationBar.superview bringSubviewToFront:headView];
    [self.navigationController.navigationBar.superview bringSubviewToFront:self.navigationController.navigationBar];

    NSDictionary *titleAttributeFake = @{
                                         NSFontAttributeName: [Constants fontOfAwesomeWithSize:20 inStyle:fontAwesomeStyleSolid],
                                         NSForegroundColorAttributeName: [UIColor clearColor],
                                         };
    NSAttributedString *titleFake = [[NSAttributedString alloc] initWithString:[Constants fontAwesomeWithCode:@"fa-heart"] attributes:titleAttributeFake];
    UIButton *favButtonFake = [UIButton new];
    [favButtonFake setAttributedTitle:titleFake
                             forState:UIControlStateNormal];
    [favButtonFake setTitleColor:[UIColor clearColor]
                        forState:UIControlStateNormal];
    [favButtonFake sizeToFit];
    UIBarButtonItem *favoritesButtonFake = [[UIBarButtonItem alloc] initWithCustomView:favButtonFake];
    [self.navigationItem setRightBarButtonItem:favoritesButtonFake];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [headView setAlpha:0];
    [headView setHidden:NO];
    [UIView animateWithDuration:.5f
                     animations:^{
                         [headView setAlpha:1];
                     } completion:^(BOOL finished) {
                         [headView setAlpha:1];
                     }];
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    if (parent == nil) {
        [headView removeFromSuperview];
    }
}

- (void)parseFavorites {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSObject *favObj = [userDefault valueForKey:FAV_KEY];
    NSArray *favorites = [favObj isKindOfClass:[NSData class]] ? [NSKeyedUnarchiver unarchiveObjectWithData:favObj] : favObj;
    
    self.favoriteTimes = [NSMutableArray new];
    self.favoritesSections = [NSMutableDictionary new];
    for (NSDictionary *program in favorites) {
        NSDate *startTime = [formatter_full dateFromString:[program objectForKey:@"start"]];
        NSString *start = [formatter_date stringFromDate:startTime];
        NSMutableArray *section = [self.favoritesSections objectForKey:start];
        if (section == nil) {
            section = [NSMutableArray new];
            [self.favoriteTimes addObject:startTime];
        }
        [section addObject:program];
        [self.favoritesSections setObject:section
                                   forKey:start];
    }
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeIntervalSince1970"
                                                                   ascending:YES];
    [self.favoriteTimes sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showViewController:(UIViewController *)vc sender:(id)sender {
    [UIView animateWithDuration:.5f
                     animations:^{
                         [headView setAlpha:0];
                     } completion:^(BOOL finished) {
                         [headView setHidden:YES];
                         [headView setAlpha:1];
                     }];
    [self.navigationController pushViewController:vc
                                         animated:YES];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.favoritesSections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDate *time = [self.favoriteTimes objectAtIndex:section];
    NSString *timeString = [formatter_date stringFromDate:time];
    return [[self.favoritesSections objectForKey:timeString] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [formatter_date stringFromDate:[self.favoriteTimes objectAtIndex:section]];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[AppDelegate AppConfigColor:@"HighlightedColor"]];
    [view setTintColor:[UIColor colorFromHtmlColor:@"#ECF5F4"]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *scheduleCellName = @"ScheduleCell";
    
    ScheduleTableViewCell *cell = (ScheduleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:scheduleCellName];
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"ScheduleTableViewCell" bundle:nil] forCellReuseIdentifier:scheduleCellName];
        cell = (ScheduleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:scheduleCellName];
    }
    
    NSDate *time = [self.favoriteTimes objectAtIndex:indexPath.section];
    NSString *timeString = [formatter_date stringFromDate:time];
    NSDictionary *program = [[self.favoritesSections objectForKey:timeString] objectAtIndex:indexPath.row];
    
    [cell setDelegate:self];
    [cell setSchedule:program];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    NSDate *endTime = [formatter_full dateFromString:[program objectForKey:@"end"]];
    NSTimeInterval sinceEnd = [endTime timeIntervalSinceDate:today];
    [cell setDisabled:(sinceEnd < 0)];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    NSDate *time = [self.favoriteTimes objectAtIndex:indexPath.section];
    NSString *timeString = [formatter_date stringFromDate:time];
    NSDictionary *program = [[self.favoritesSections objectForKey:timeString] objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:SCHEDULE_DETAIL_VIEW_STORYBOARD_ID
                              sender:program];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:SCHEDULE_DETAIL_VIEW_STORYBOARD_ID]) {
        ScheduleDetailViewController *detailView = (ScheduleDetailViewController *)segue.destinationViewController;
        [detailView setDetailData:sender];
    }
}

- (NSString *)getID:(NSDictionary *)program {
    return [NSString stringWithFormat:@"%@-%@-%@", [program objectForKey:@"room"], [program objectForKey:@"start"], [program objectForKey:@"end"]];
}

- (void)actionFavorite:(NSString *)scheduleId {
    NSDictionary *favProgram = @{};
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSObject *favObj = [userDefault valueForKey:FAV_KEY];
    NSArray *favoriteArray = [favObj isKindOfClass:[NSData class]] ? [NSKeyedUnarchiver unarchiveObjectWithData:favObj] : favObj;
    NSMutableArray *favorites = [NSMutableArray arrayWithArray:favoriteArray];
    for (NSDictionary *program in favorites) {
        if ([[self getID:program] isEqualToString:scheduleId]) {
            favProgram = program;
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
    [self parseFavorites];
}

- (BOOL)hasFavorite:(NSString *)scheduleId {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSObject *favObj = [userDefault valueForKey:FAV_KEY];
    NSArray *favorites = [favObj isKindOfClass:[NSData class]] ? [NSKeyedUnarchiver unarchiveObjectWithData:favObj] : favObj;
    for (NSDictionary *program in favorites) {
        if ([[self getID:program] isEqualToString:scheduleId]) {
            return YES;
        }
    }
    return NO;
}

@end
