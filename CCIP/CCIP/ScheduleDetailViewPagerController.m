//
//  ScheduleDetailViewPagerController.m
//  CCIP
//
//  Created by FrankWu on 2016/7/19.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "ScheduleDetailViewPagerController.h"

@interface ScheduleDetailViewPagerController () <ViewPagerDataSource, ViewPagerDelegate>

@end

@implementation ScheduleDetailViewPagerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dataSource = self;
    self.delegate = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setProgram:(NSMutableDictionary *)program {
    _program = program;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - ViewPagerDataSource
- (NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager {
    return 2;
}

#pragma mark - ViewPagerDataSource
- (UIView *)viewPager:(ViewPagerController *)viewPager viewForTabAtIndex:(NSUInteger)index {
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"ABC";
//    if (index == 0) {
//        label.text = NSLocalizedString(@"All", nil);
//    }
    
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];
    [self.view bringSubviewToFront:label];

    return label;
}

#pragma mark - ViewPagerDataSource
- (UIViewController *)viewPager:(ViewPagerController *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index {
    
    UIViewController *vc = [UIViewController new];
    if (index == 0) {
        [vc.view setBackgroundColor:[UIColor redColor]];
    } else {
        [vc.view setBackgroundColor:[UIColor blueColor]];
    }
    return vc;
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
            return 0.0;
        case ViewPagerOptionTabLocation:
            return 1.0;
            //case ViewPagerOptionTabHeight:
            //    return 49.0;
            //case ViewPagerOptionTabOffset:
            //    return 36.0;
        case ViewPagerOptionTabWidth:
            return UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ? 240.0f : ([[UIScreen mainScreen] bounds].size.width/2);
        case ViewPagerOptionFixFormerTabsPositions:
            return 0.0;
        case ViewPagerOptionFixLatterTabsPositions:
            return 0.0;
        default:
            return value;
    }
}

- (UIColor *)viewPager:(ViewPagerController *)viewPager colorForComponent:(ViewPagerComponent)component withDefault:(UIColor *)color {
    switch (component) {
        case ViewPagerIndicator: {
            return [UIColor colorWithRed:184.0f/255.0f green:233.0f/255.0f blue:134.0f/255.0f alpha:1.0f];
        }
        case ViewPagerTabsView: {
            return [UIColor clearColor];
        }
        case ViewPagerContent: {
            return [UIColor clearColor];
        }
            
        default: {
            return color;
        }
    }
}

@end
