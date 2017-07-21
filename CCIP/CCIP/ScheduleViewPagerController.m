//
//  ScheduleViewPagerController.m
//  CCIP
//
//  Created by FrankWu on 2017/7/16.
//  Copyright © 2017年 CPRTeam. All rights reserved.
//

#import "ScheduleViewPagerController.h"
#import "WebServiceEndPoint.h"
#import "UIColor+addition.h"
#import <AFNetworking/AFNetworking.h>
#import "ScheduleTableViewController.h"

@interface ScheduleViewPagerController ()

@property (strong, nonatomic) NSArray *programs;
@property (strong, nonatomic) NSArray *segmentsTextArray;
@property (strong, nonatomic) NSMutableDictionary *program_date;
@property (strong, nonatomic) NSMutableDictionary *program_date_section;

@end

@implementation ScheduleViewPagerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dataSource = self;
    self.delegate = self;

    [self.view setBackgroundColor:[UIColor clearColor]];

    [self refreshData];
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


- (void)refreshData {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:SCHEDULES_DATA_URL parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        if (responseObject != nil) {
            self.programs = responseObject;
            [self setScheduleDate];
        }
//        [self endRefreshingWithCountDown];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
//        [self endRefreshingWithCountDown];
    }];
}

//- (void)endRefreshingWithCountDown {
//}

- (void)setScheduleDate {
    static NSDateFormatter *formatter_full = nil;
    if (formatter_full == nil) {
        formatter_full = [NSDateFormatter new];
        [formatter_full setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        [formatter_full setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    }
    
    static NSDateFormatter *formatter_date = nil;
    if (formatter_date == nil) {
        formatter_date = [NSDateFormatter new];
        [formatter_date setDateFormat:@"M/d"];
    }
    
    static NSDate *startTime;
    static NSString *time_date;
    
    NSMutableDictionary *datesDict = [NSMutableDictionary new];
    
    for (NSDictionary *program in self.programs) {
        startTime = [formatter_full dateFromString:[program objectForKey:@"start"]];
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
    
    [self reloadData];

    [self checkScheduleDate];
}

- (void)checkScheduleDate {
    static NSDateFormatter *formatter_s = nil;
    if (formatter_s == nil) {
        formatter_s = [NSDateFormatter new];
        [formatter_s setDateFormat:@"M/d"];
    }
    // To Do
}

#pragma mark - Pager
#pragma mark - ViewPagerDataSource
- (NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager {
    return [self.segmentsTextArray count];
}
//Returns the number of tabs that will be present in ViewPager.

#pragma mark - ViewPagerDataSource
- (UIView *)viewPager:(ViewPagerController *)viewPager viewForTabAtIndex:(NSUInteger)index {
    UILabel *label = [UILabel new];
    label.text = [NSString stringWithFormat:@"DAY %@", [self.segmentsTextArray objectAtIndex:index]];
    label.textColor = [UIColor colorFromHtmlColor:@"#009A79"];
    label.font = [UIFont fontWithName:@"PingFangTC-Medium" size:14];
    [label sizeToFit];
    
    return label;
}
//Returns the view that will be shown as tab. Create a UIView object (or any UIView subclass object) and give it to ViewPager and it will use it as tab view.

#pragma mark - ViewPagerDataSource
- (UIViewController *)viewPager:(ViewPagerController *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index {
    
    ScheduleTableViewController *vc = [ScheduleTableViewController new];
    vc.programs = [self.program_date objectForKey:[self.segmentsTextArray objectAtIndex:index]];
    return vc;
}
//Returns the view controller that will be shown as content. Create a UIViewController object (or any UIViewController subclass object) and give it to ViewPager and it will use the view property of the view controller as content view.
//Alternatively, you can implement - viewPager:contentViewForTabAtIndex: method and return a UIView object (or any UIView subclass object) and ViewPager will use it as content view.
//The - viewPager:contentViewControllerForTabAtIndex: and - viewPager:contentViewForTabAtIndex: dataSource methods are both defined optional. But, you should implement at least one of them! They are defined as optional to provide you an option.
//All delegate methods are optional.

#pragma mark - ViewPagerDelegate
- (void)viewPager:(ViewPagerController *)viewPager didChangeTabToIndex:(NSUInteger)index {
    
    // Do something useful
}
//ViewPager will alert your delegate object via - viewPager:didChangeTabToIndex: method, so that you can do something useful.

#pragma mark - ViewPagerDelegate
- (CGFloat)viewPager:(ViewPagerController *)viewPager valueForOption:(ViewPagerOption)option withDefault:(CGFloat)value {
    switch (option) {
            case ViewPagerOptionStartFromSecondTab:
            return 0.0;
            case ViewPagerOptionCenterCurrentTab:
            return 0.0;
            case ViewPagerOptionTabLocation:
            return 1.0;
            //case ViewPagerOptionTabHeight:
            //    return 49.0;
            //case ViewPagerOptionTabOffset:
            //    return 36.0;
            case ViewPagerOptionTabDisableTopLine:
            return 1.0;
            case ViewPagerOptionTabDisableBottomLine:
            return 1.0;
            case ViewPagerOptionTabNarmalLineWidth:
            return 5.0;
            case ViewPagerOptionTabSelectedLineWidth:
            return 5.0;
            case ViewPagerOptionTabWidth:
            return [[UIScreen mainScreen] bounds].size.width / [self.segmentsTextArray count];
            case ViewPagerOptionFixFormerTabsPositions:
            return 0.0;
            case ViewPagerOptionFixLatterTabsPositions:
            return 0.0;
        default:
            return value;
    }
}
//You can change ViewPager's options via viewPager:valueForOption:withDefault: delegate method. Just return the desired value for the given option. You don't have to return a value for every option. Only return values for the interested options and ViewPager will use the default values for the rest. Available options are defined in the ViewPagerController.h file and described below.

#pragma mark - ViewPagerDelegate
- (UIColor *)viewPager:(ViewPagerController *)viewPager colorForComponent:(ViewPagerComponent)component withDefault:(UIColor *)color {
    switch (component) {
            case ViewPagerIndicator: {
                return [UIColor colorFromHtmlColor:@"#009A79"];
            }
            case ViewPagerTabsView: {
                return [UIColor clearColor];
            }
            case ViewPagerContent: {
                return [UIColor whiteColor];
            }
        default: {
            return color;
        }
    }
}

@end