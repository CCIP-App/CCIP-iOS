//
//  ScheduleViewController.m
//  CCIP
//
//  Created by FrankWu on 2016/7/17.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "ScheduleViewController.h"
#import "UISegmentedControl+addition.h"
#import "GatewayWebService/GatewayWebService.h"
#import "ProgramDetailViewController.h"
#import "NSInvocation+addition.h"

#define toolbarHight 44.0

@interface ScheduleViewController ()

@property (strong, nonatomic) UIToolbar *toolbar;
@property (strong, nonatomic) UISegmentedControl *segmentedControl;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property CGFloat topGuide;
@property CGFloat bottomGuide;
@property BOOL canScrollHide;
@property CGFloat scrollHideSmoothLevel;

@property NSUInteger refreshingCountDown;

@property (strong, nonatomic) NSArray *rooms;
@property (strong, nonatomic) NSArray *programs;
@property (strong, nonatomic) NSArray *program_types;

@property (strong, nonatomic) NSArray *segmentsTextArray;

@property (strong, nonatomic) NSMutableDictionary *program_date;
@property (strong, nonatomic) NSMutableDictionary *program_date_section;

@end

@implementation ScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    _canScrollHide = YES;
    _scrollHideSmoothLevel = 5;
    
    _topGuide = 0.0;
    _bottomGuide = 0.0;
    if (self.navigationController.navigationBar.translucent) {
        if (self.prefersStatusBarHidden == NO) _topGuide += 20;
        if (self.navigationController.navigationBarHidden == NO) _topGuide += self.navigationController.navigationBar.bounds.size.height;
    }
    if (self.tabBarController.tabBar.hidden == NO) _bottomGuide += self.tabBarController.tabBar.bounds.size.height;
    
    // ... setting up the SegmentedControl here ...
    _segmentedControl = [UISegmentedControl new] ;
    [_segmentedControl setFrame:CGRectMake(0, 0, 200, 30)];
    [_segmentedControl addTarget:self
                          action:@selector(segmentedControlValueDidChange:)
                forControlEvents:UIControlEventValueChanged];
    [_segmentedControl setTintColor:[UIColor colorWithRed:61.0f/255.0f
                                                    green:152.0f/255.0f
                                                     blue:60.0f/255.0f
                                                    alpha:1.0f]];
    
    // ... setting up the Toolbar here ...
    _toolbar = [UIToolbar new];
    [_toolbar setFrame:CGRectMake(0, _topGuide, self.view.bounds.size.width, toolbarHight)];
    [_toolbar setTranslucent:YES];
    [_toolbar.layer setShadowOffset:CGSizeMake(0, 1.0f/UIScreen.mainScreen.scale)];
    [_toolbar.layer setShadowRadius:0];
    [_toolbar.layer setShadowColor:[UIColor blackColor].CGColor];
    [_toolbar.layer setShadowOpacity:0.25f];
    [_toolbar setBarTintColor:[[UIToolbar new] barTintColor]];
    [self.view addSubview:_toolbar];
    
    // ... setting up the Toolbar's Items here ...
    UIBarButtonItem *segmentedControlButtonItem = [[UIBarButtonItem alloc] initWithCustomView:(UIView *)_segmentedControl];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:nil
                                                                                   action:nil];
    NSArray *barArray = [NSArray arrayWithObjects: flexibleSpace, segmentedControlButtonItem, flexibleSpace, nil];
    [_toolbar setItems:barArray];
    
    // ... setting up the TableView here ...
    _tableView = [UITableView new];
    [_tableView setFrame:CGRectMake(0, toolbarHight, self.view.bounds.size.width, self.view.bounds.size.height-_bottomGuide-toolbarHight)];
    [_tableView setShowsHorizontalScrollIndicator:YES];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [self.view addSubview:_tableView];
    
    [self.view bringSubviewToFront:_toolbar];
    
    // ... setting up the RefreshControl here ...
    UITableViewController *tableViewController = [UITableViewController new];
    tableViewController.tableView = self.tableView;
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self
                            action:@selector(refreshData)
                  forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = self.refreshControl;
    
    [self refreshData];
    
    
    self.tableView.delegate = self;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)refreshData {
    [self.refreshControl beginRefreshing];
    self.refreshingCountDown = 3;
    
    GatewayWebService *roome_ws = [[GatewayWebService alloc] initWithURL:ROOM_DATA_URL];
    [roome_ws sendRequest:^(NSArray *json, NSString *jsonStr) {
        if (json != nil) {
            NSLog(@"%@", json);
            self.rooms = json;
        }
        [self endRefreshingWithCountDown];
    }];
    
    GatewayWebService *program_ws = [[GatewayWebService alloc] initWithURL:PROGRAM_DATA_URL];
    [program_ws sendRequest:^(NSArray *json, NSString *jsonStr) {
        if (json != nil) {
            NSLog(@"%@", json);
            self.programs = json;
            
            [self setScheduleDate];
        }
        [self endRefreshingWithCountDown];
    }];
    
    GatewayWebService *program_type_ws = [[GatewayWebService alloc] initWithURL:PROGRAM_TYPE_DATA_URL];
    [program_type_ws sendRequest:^(NSArray *json, NSString *jsonStr) {
        if (json != nil) {
            NSLog(@"%@", json);
            self.program_types = json;
        }
        [self endRefreshingWithCountDown];
    }];
}

-(void)endRefreshingWithCountDown{
    self.refreshingCountDown -= 1;
    if (self.refreshingCountDown == 0) {
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
    }
}

-(void)setScheduleDate{
    NSDateFormatter *formatter_full = [NSDateFormatter new];
    [formatter_full setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    [formatter_full setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    NSDateFormatter *formatter_date = [NSDateFormatter new];
    [formatter_date setDateFormat:@"MM/dd"];
    
    NSDate *startTime;
    NSString *time_date;
    
    NSMutableDictionary *datesDict = [NSMutableDictionary new];

    for (NSDictionary *program in self.programs) {
        startTime = [formatter_full dateFromString:[program objectForKey:@"starttime"]];
        time_date = [formatter_date stringFromDate:startTime];
        
        NSMutableArray *tempArray = [datesDict objectForKey:time_date];
        if (tempArray == nil) {
            tempArray = [NSMutableArray new];
        }
        [tempArray addObject:program];
        [datesDict setObject:tempArray forKey:time_date];
    }
    
    self.program_date = datesDict;
    self.segmentsTextArray = [[self.program_date allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    [self.segmentedControl resetAllSegments:self.segmentsTextArray];
    
    [self checkScheduleDate];
    
    // UIApplicationShortcutIcon
    // UIApplicationShortcutItem
    
    NSMutableArray *shortcutItems = [NSMutableArray new];
    
    UIApplicationShortcutItem * shortcutItem;
    shortcutItem =[[UIApplicationShortcutItem alloc] initWithType:@"Checkin"
                                                   localizedTitle:@"day1 報到"
                                                localizedSubtitle:nil
                                                             icon:[UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeTaskCompleted]
                                                         userInfo:nil];
    [shortcutItems addObject:shortcutItem];
    
    shortcutItem =[[UIApplicationShortcutItem alloc] initWithType:@"Checkin"
                                                   localizedTitle:@"day1 領便當"
                                                localizedSubtitle:nil
                                                             icon:[UIApplicationShortcutIcon iconWithType: UIApplicationShortcutIconTypeTask]
                                                         userInfo:nil];
    [shortcutItems addObject:shortcutItem];
    
    for (NSString *dateText in self.segmentsTextArray) {
        UIApplicationShortcutItem * shortcutItem;
        shortcutItem =[[UIApplicationShortcutItem alloc] initWithType:@"Schedule"
                                                       localizedTitle:dateText
                                                    localizedSubtitle:@"議程"
                                                                 icon:[UIApplicationShortcutIcon iconWithType: UIApplicationShortcutIconTypeDate]
                                                             userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                        self.segmentsTextArray, @"segmentsTextArray",
                                                                        self.program_date, @"program_date",
                                                                        nil]];
        [shortcutItems addObject:shortcutItem];
    }
    
    [UIApplication sharedApplication].shortcutItems = shortcutItems;
}

-(void)setSegmentedAndTableWithText:(NSString *)selectedSegmentText{
    if ([self.segmentsTextArray count] == 0) {
        NSObject *scheduleDataObj = [[NSUserDefaults standardUserDefaults] objectForKey:@"ScheduleData"];
        if (scheduleDataObj) {
            NSDictionary *scheduleDataDict = (NSDictionary*)scheduleDataObj;
            self.segmentsTextArray = [scheduleDataDict objectForKey:@"segmentsTextArray"];
            self.program_date = [scheduleDataDict objectForKey:@"program_date"];
            
            [self.segmentedControl resetAllSegments:self.segmentsTextArray];
        }
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ScheduleData"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSInteger segmentsIndex = [self.segmentsTextArray indexOfObject:selectedSegmentText];
    [self setSegmentedAndTableWithIndex:segmentsIndex];
}

-(void)setSegmentedAndTableWithIndex:(NSInteger)selectedSegmentIndex{
    [self.segmentedControl setSelectedSegmentIndex:selectedSegmentIndex];

    NSDateFormatter *formatter_full = [NSDateFormatter new];
    [formatter_full setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    [formatter_full setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    NSDateFormatter *formatter_HHmm = [NSDateFormatter new];
    [formatter_HHmm setDateFormat:@"HH:mm"];
    
    NSDate *startTime;
    NSDate *endTime;
    NSString *startTime_str;
    NSString *endTime_str;
    NSString *timeKey;
    
    NSMutableDictionary *sectionDict = [NSMutableDictionary new];
    
    for (NSDictionary *program in [self.program_date objectForKey:[self.segmentsTextArray objectAtIndex:selectedSegmentIndex]]) {
        startTime = [formatter_full dateFromString:[program objectForKey:@"starttime"]];
        endTime = [formatter_full dateFromString:[program objectForKey:@"endtime"]];
        startTime_str = [formatter_HHmm stringFromDate:startTime];
        endTime_str = [formatter_HHmm stringFromDate:endTime];
        timeKey = [NSString stringWithFormat:@"%@ ~ %@", startTime_str, endTime_str];
        
        NSMutableArray *tempArray = [sectionDict objectForKey:timeKey];
        if (tempArray == nil) {
            tempArray = [NSMutableArray new];
        }
        [tempArray addObject:program];
        [sectionDict setObject:tempArray forKey:timeKey];
    }
    
    self.program_date_section = sectionDict;
    
    [self.tableView reloadData];
}

-(void)checkScheduleDate {
    NSDateFormatter *formatter_s = [NSDateFormatter new];
    [formatter_s setDateFormat:@"MM/dd"];
    
    if ([self.segmentedControl selectedSegmentIndex] == -1) {
        NSInteger segmentsIndex = 0;
        for (int index = 0; index < [self.segmentsTextArray count]; ++index) {
            if ([[formatter_s stringFromDate:[NSDate new]] isEqualToString:[self.segmentsTextArray objectAtIndex:index]]) {
                segmentsIndex = index;
            }
        }
        [self setSegmentedAndTableWithIndex:segmentsIndex];
    }
}

-(void)segmentedControlValueDidChange:(UISegmentedControl *)segment
{
    [self setSegmentedAndTableWithIndex:segment.selectedSegmentIndex];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

// Somewhere in your implementation file:
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ( (self.tableView.contentSize.height/2+toolbarHight*_scrollHideSmoothLevel) > self.tableView.frame.size.height && _canScrollHide) {
        CGFloat changeY = (self.tableView.contentOffset.y + _topGuide) / _scrollHideSmoothLevel;
        CGRect viewRect = self.view.bounds;
        if (changeY <= 0) {
            _toolbar.frame = CGRectMake(0, _topGuide, viewRect.size.width, toolbarHight);
            _tableView.frame = CGRectMake(0, toolbarHight, viewRect.size.width, viewRect.size.height-_bottomGuide-toolbarHight);
            
        }
        else if (changeY > toolbarHight) {
            _toolbar.frame = CGRectMake(0, _topGuide-toolbarHight, viewRect.size.width, toolbarHight);
            _tableView.frame = CGRectMake(0, toolbarHight-toolbarHight, viewRect.size.width, viewRect.size.height-_bottomGuide);
        }
        else {
            _toolbar.frame = CGRectMake(0, _topGuide-changeY, viewRect.size.width, toolbarHight);
            _tableView.frame = CGRectMake(0, toolbarHight-changeY, viewRect.size.width, viewRect.size.height-_bottomGuide-changeY);
            
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.program_date_section count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *allKeys = [[self.program_date_section allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    return [[self.program_date_section objectForKey:[allKeys objectAtIndex:section]] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray *allKeys = [[self.program_date_section allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    return [allKeys objectAtIndex:section];;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *titleString = [self tableView:tableView titleForHeaderInSection:section];
    
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 28.0f)];
    [sectionView setBackgroundColor:[UIColor colorWithRed:61.0f/255.0f
                                                    green:152.0f/255.0f
                                                     blue:60.0f/255.0f
                                                    alpha:1.0f]];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectInset(sectionView.frame, 20.0f, 4.0f)];
    [titleLabel setFont:[UIFont systemFontOfSize:18.0f
                                          weight:UIFontWeightMedium]];
    [titleLabel setTextAlignment:NSTextAlignmentLeft];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    
    [titleLabel setText:titleString];
    [sectionView addSubview:titleLabel];
    
    return sectionView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NULL];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    NSArray *allKeys = [[self.program_date_section allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    NSDictionary *program = [[self.program_date_section objectForKey:[allKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    [cell.textLabel setText:[program objectForKey:@"subject"]];
    [cell.detailTextLabel setText:[program objectForKey:@"room"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[self.tableView cellForRowAtIndexPath:indexPath] setSelected:NO
                                                    animated:YES];
    // TODO: display selected section detail informations
    
    NSArray *allKeys = [[self.program_date_section allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    NSDictionary *program = [[self.program_date_section objectForKey:[allKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    ProgramDetailViewController *detailViewController = [[ProgramDetailViewController alloc] initWithNibName:@"ProgramDetailViewController"
                                                                                                      bundle:[NSBundle mainBundle]
                                                                                                     Program:program];
    [self.navigationController pushViewController:detailViewController animated:YES];
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

@end
