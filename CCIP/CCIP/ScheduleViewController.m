//
//  ScheduleViewController.m
//  CCIP
//
//  Created by FrankWu on 2016/7/17.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "ScheduleViewController.h"
#import "UISegmentedControl+addition.h"

#define toolbarHight 44.0

@interface ScheduleViewController ()

@property (strong, nonatomic) UIToolbar *toolbar;
@property (strong, nonatomic) UISegmentedControl *segmented;
@property (strong, nonatomic) UITableView *tableView;

@end

@implementation ScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"viewDidLoad");
    // Do any additional setup after loading the view.
    
    //    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
    //    {
    //        self.edgesForExtendedLayout = UIRectEdgeNone;
    //        self.navigationController.navigationBar.translucent = NO;
    //    }
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    CGFloat topGuide;
    CGFloat bottomGuide;
    
    if (self.navigationController.navigationBar.translucent) {
        if (self.prefersStatusBarHidden == NO) topGuide += 20;
        if (self.navigationController.navigationBarHidden == NO) topGuide += self.navigationController.navigationBar.bounds.size.height;
    }
    if (self.tabBarController.tabBar.hidden == NO) bottomGuide += self.tabBarController.tabBar.bounds.size.height;
    
    // ... setting up the SegmentedControl here ...
    _segmented = [UISegmentedControl new] ;
    [_segmented setFrame:CGRectMake(0, 0, 200, 30)];
    [_segmented addTarget:self
                   action:@selector(segmentedControlValueDidChange:)
         forControlEvents:UIControlEventValueChanged];
    
    // ... setting up the Toolbar here ...
    _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, topGuide, self.view.bounds.size.width, toolbarHight)];
    [_toolbar setTranslucent:YES];
    [_toolbar.layer setShadowOffset:CGSizeMake(0, 1.0f/UIScreen.mainScreen.scale)];
    [_toolbar.layer setShadowRadius:0];
    [_toolbar.layer setShadowColor:[UIColor blackColor].CGColor];
    [_toolbar.layer setShadowOpacity:0.25f];
    [self.view addSubview:_toolbar];
    
    UIBarButtonItem *segmentedControlButtonItem = [[UIBarButtonItem alloc] initWithCustomView:(UIView *)_segmented];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:nil
                                                                                   action:nil];
    NSArray *barArray = [NSArray arrayWithObjects: flexibleSpace, segmentedControlButtonItem, flexibleSpace, nil];
    [self.toolbar setItems:barArray];
    
    // ... setting up the TableView here ...
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, toolbarHight, self.view.bounds.size.width, self.view.bounds.size.height-bottomGuide-toolbarHight)];
    [_tableView setShowsHorizontalScrollIndicator:YES];
    
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [self.view addSubview:_tableView];
    
    [self.view bringSubviewToFront:_toolbar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear");
    
    NSArray *segItemsArray = [NSArray arrayWithObjects: @"One", @"Two", @"Three", nil];
    [_segmented resetAllSegments:segItemsArray];
    [_segmented setSelectedSegmentIndex:0];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"Section #%ld", self.segmented.selectedSegmentIndex];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NULL];
    [cell setAccessoryType:UITableViewCellAccessoryDetailButton];
    
    [cell.textLabel setText:[NSString stringWithFormat:@"Cell #%ld-%ld", self.segmented.selectedSegmentIndex, (long)indexPath.row]];
    
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
