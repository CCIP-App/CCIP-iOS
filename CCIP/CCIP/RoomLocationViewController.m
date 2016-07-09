//
//  RoomLocationViewController.m
//  CCIP
//
//  Created by FrankWu on 2016/7/3.
//  Copyright © 2016年 FrankWu. All rights reserved.
//

#import "RoomLocationViewController.h"
#import "RoomProgramsTableViewController.h"
#import "NSInvocation+addition.h"

@interface RoomLocationViewController () <ViewPagerDataSource, ViewPagerDelegate>

@end

@implementation RoomLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.dataSource = self;
    self.delegate = self;
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setRooms:(NSArray *)rooms {
    _rooms = rooms;
}

- (void)setRoomPrograms:(NSMutableArray *)roomPrograms {
    _roomPrograms = roomPrograms;
}

#pragma mark - ViewPagerDataSource
- (NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager {
    return [self.rooms count];
}

#pragma mark - ViewPagerDataSource
- (UIView *)viewPager:(ViewPagerController *)viewPager viewForTabAtIndex:(NSUInteger)index {
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor clearColor];
    
    label.text = [[self.rooms objectAtIndex:index] objectForKey:@"name"];

    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    [label sizeToFit];
    
    return label;
}

#pragma mark - ViewPagerDataSource
- (UIViewController *)viewPager:(ViewPagerController *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index {

    RoomProgramsTableViewController *roomProgramsTableView = [RoomProgramsTableViewController new];

    NSString *room = [[self.rooms objectAtIndex:index] objectForKey:@"room"];
    
    [NSInvocation InvokeObject:roomProgramsTableView
            withSelectorString:@"setRoom:"
                 withArguments:@[ room ]];
    
    NSMutableArray *programsArray  = [NSMutableArray new];
    for (NSDictionary *dict in self.roomPrograms) {
        if ([[dict objectForKey:@"room"] isEqualToString:room]) {
            [programsArray addObject:dict];
        }
    }
    
    [NSInvocation InvokeObject:roomProgramsTableView
            withSelectorString:@"setPrograms:"
                 withArguments:@[ programsArray ]];
    
    return roomProgramsTableView;
}

#pragma mark - ViewPagerDelegate
- (void)viewPager:(ViewPagerController *)viewPager didChangeTabToIndex:(NSUInteger)index {
    // Do something useful
}

#pragma mark - ViewPagerDelegate
- (CGFloat)viewPager:(ViewPagerController *)viewPager valueForOption:(ViewPagerOption)option withDefault:(CGFloat)value {
    switch (option) {
        case ViewPagerOptionStartFromSecondTab:
            return 0.0;
        case ViewPagerOptionCenterCurrentTab:
            return 1.0;
        case ViewPagerOptionTabLocation:
            return 0.0;
        //case ViewPagerOptionTabHeight:
        //    return 49.0;
        //case ViewPagerOptionTabOffset:
        //    return 36.0;
        case ViewPagerOptionTabWidth:
            return UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ? 240.0f : ([[UIScreen mainScreen] bounds].size.width/3);
        //case ViewPagerOptionFixFormerTabsPositions:
        //    return 1.0;
        //case ViewPagerOptionFixLatterTabsPositions:
        //    return 1.0;
        default:
            return value;
    }
}

- (UIColor *)viewPager:(ViewPagerController *)viewPager colorForComponent:(ViewPagerComponent)component withDefault:(UIColor *)color {
    switch (component) {
        case ViewPagerIndicator:
            return [[UIColor redColor] colorWithAlphaComponent:0.64];
        case ViewPagerTabsView:
            return [UIColor whiteColor];
        case ViewPagerContent:
            return [UIColor whiteColor];
        default:
            return color;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"RoomLocationView"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

@end
