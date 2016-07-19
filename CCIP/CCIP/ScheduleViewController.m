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

#define toolbarHight 44.0

@interface ScheduleViewController ()

@property (strong, nonatomic) UIToolbar *toolbar;
@property (strong, nonatomic) UISegmentedControl *segmentedControl;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) NSArray *rooms;
@property (strong, nonatomic) NSArray *programs;
@property (strong, nonatomic) NSArray *program_types;

@property (strong, nonatomic) NSArray *segments;

@property NSUInteger refreshingCountDown;

@end

@implementation ScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
    //    {
    //        self.edgesForExtendedLayout = UIRectEdgeNone;
    //        self.navigationController.navigationBar.translucent = NO;
    //    }
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    CGFloat topGuide = 0.0;
    CGFloat bottomGuide = 0.0;
    
    if (self.navigationController.navigationBar.translucent) {
        if (self.prefersStatusBarHidden == NO) topGuide += 20;
        if (self.navigationController.navigationBarHidden == NO) topGuide += self.navigationController.navigationBar.bounds.size.height;
    }
    if (self.tabBarController.tabBar.hidden == NO) bottomGuide += self.tabBarController.tabBar.bounds.size.height;
    
    // ... setting up the SegmentedControl here ...
    _segmentedControl = [UISegmentedControl new] ;
    [_segmentedControl setFrame:CGRectMake(0, 0, 200, 30)];
    [_segmentedControl addTarget:self
                          action:@selector(segmentedControlValueDidChange:)
                forControlEvents:UIControlEventValueChanged];
    [_segmentedControl setTintColor:[UIColor colorWithRed:61.0f/255.0f green:152.0f/255.0f blue:60.0f/255.0f alpha:1.0f]];
    
    // ... setting up the Toolbar here ...
    _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, topGuide, self.view.bounds.size.width, toolbarHight)];
    [_toolbar setTranslucent:YES];
    [_toolbar.layer setShadowOffset:CGSizeMake(0, 1.0f/UIScreen.mainScreen.scale)];
    [_toolbar.layer setShadowRadius:0];
    [_toolbar.layer setShadowColor:[UIColor blackColor].CGColor];
    [_toolbar.layer setShadowOpacity:0.25f];
    [self.view addSubview:_toolbar];
    
    // ... setting up the Toolbar's Items here ...
    UIBarButtonItem *segmentedControlButtonItem = [[UIBarButtonItem alloc] initWithCustomView:(UIView *)_segmentedControl];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:nil
                                                                                   action:nil];
    NSArray *barArray = [NSArray arrayWithObjects: flexibleSpace, segmentedControlButtonItem, flexibleSpace, nil];
    [_toolbar setItems:barArray];
    
    // ... setting up the TableView here ...
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, toolbarHight, self.view.bounds.size.width, self.view.bounds.size.height-bottomGuide-toolbarHight)];
    [_tableView setShowsHorizontalScrollIndicator:YES];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [self.view addSubview:_tableView];
    
    [self.view bringSubviewToFront:_toolbar];
    
    // ... setting up the RefreshControl here ...
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.tableView;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = self.refreshControl;
    
    [self refreshData];
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
            
            [self setProgramsDates];
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

-(void)setProgramsDates{

    NSDateFormatter *formatter_full = [[NSDateFormatter alloc] init];
    [formatter_full setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    [formatter_full setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    NSDateFormatter *formatter_s = [[NSDateFormatter alloc] init];
    
    NSDate *time_full = [NSDate new];
    
    NSMutableDictionary *dates = [NSMutableDictionary new];
    
    [formatter_s setDateFormat:@"MM/dd"];
    
    for (NSDictionary *program in self.programs) {
        time_full = [formatter_full dateFromString:[program objectForKey:@"starttime"]];
        NSString *time_s = [formatter_s stringFromDate:time_full];
        
        NSMutableArray *rows = [dates objectForKey:time_s];
        if (rows == nil) {
            rows = [NSMutableArray new];
        }
        [rows addObject:program];
        [dates setObject:rows forKey:time_s];
    }
    
    NSMutableArray *tempSegments = [NSMutableArray new];
    for (NSString *date in [dates allKeys]) {
        [tempSegments addObject:date];
    }
    
    self.segments = tempSegments;
    [self.segmentedControl resetAllSegments:self.segments];
    
    [self checkScheduleDate];
}

-(void)checkScheduleDate {
    NSDateFormatter *formatter_s = [[NSDateFormatter alloc] init];
    [formatter_s setDateFormat:@"MM/dd"];
    
    NSInteger segmentsIndex = 0;
    for (int index = 0; index < [self.segments count]; ++index) {
        if ([[formatter_s stringFromDate:[NSDate new]] isEqualToString:[self.segments objectAtIndex:index]]) {
            segmentsIndex = index;
        }
    }
    
    [self.segmentedControl setSelectedSegmentIndex:segmentsIndex];
}


-(void)segmentedControlValueDidChange:(UISegmentedControl *)segment
{
    switch (segment.selectedSegmentIndex) {
        case 0:{
            //action for the first button (Current)
            break;
        }
        case 1:{
            //action for the first button (Current)
            break;
        }
    }
    [self.tableView reloadData];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"Section #%ld", self.segmentedControl.selectedSegmentIndex];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *titleString = [self tableView:tableView titleForHeaderInSection:section];
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableview_section_bg"]];
    
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 28.0f)];
    [sectionView setBackgroundColor:[UIColor colorWithRed:61.0f/255.0f green:152.0f/255.0f blue:60.0f/255.0f alpha:1.0f]];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectInset(sectionView.frame, 20.0f, 4.0f)];
    titleLabel.font = [UIFont systemFontOfSize:18.0f weight:UIFontWeightMedium];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = titleString;
    [sectionView addSubview:titleLabel];
    
    return sectionView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NULL];
    [cell setAccessoryType:UITableViewCellAccessoryDetailButton];
    
    [cell.textLabel setText:[NSString stringWithFormat:@"Cell #%ld-%ld", self.segmentedControl.selectedSegmentIndex, (long)indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[self.tableView cellForRowAtIndexPath:indexPath] setSelected:NO
                                                    animated:YES];
    // TODO: display selected section detail informations
    
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
