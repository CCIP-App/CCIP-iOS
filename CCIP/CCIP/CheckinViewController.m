//
//  CheckinViewController.m
//  CCIP
//
//  Created by Sars on 7/17/16.
//  Copyright © 2016 CPRTeam. All rights reserved.
//
#define TAG 99

#import "GatewayWebService/GatewayWebService.h"
#import "AppDelegate.h"
#import "CheckinCardViewController.h"
#import "CheckinViewController.h"
#import "GuideViewController.h"

@interface CheckinViewController()

@property (strong, nonatomic) NSDictionary *userInfo;
@property (strong, nonatomic) NSArray *scenarios;
@property (strong, nonatomic) GuideViewController *guideViewController;
@property (strong, nonatomic) UIPageControl *pageControl;

@end

@implementation CheckinViewController

- (void)setUserInfo:(NSDictionary *)userInfo {
    _userInfo = userInfo;
    [[AppDelegate appDelegate] setUserInfo:userInfo];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[AppDelegate appDelegate] setCheckinView:self];
    
    // Init configure carousel
    self.cards.type = iCarouselTypeRotary;
    self.cards.pagingEnabled = YES;
    self.cards.bounceDistance = 0.3f;
    self.cards.contentOffset = CGSizeMake(0, -5.0f);
    
    // Set carousel background linear diagonal gradient
    //   Create the colors
    UIColor *topColor = [UIColor colorWithRed:0.0/255.0 green:166.0/255.0 blue:99.0/255.0 alpha:1.0];
    UIColor *bottomColor = [UIColor colorWithRed:48.0/255.0 green:65.0/255.0 blue:73.0/255.0 alpha:1.0];
    //   Create the gradient
    CAGradientLayer *theViewGradient = [CAGradientLayer layer];
    theViewGradient.colors = [NSArray arrayWithObjects: (id)topColor.CGColor, (id)bottomColor.CGColor, nil];
    theViewGradient.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.topGuideHeight - self.bottomGuideHeight);
    theViewGradient.startPoint = CGPointMake(0.2, 0);
    theViewGradient.endPoint = CGPointMake(0.8, 1);
    //   Add gradient to view
    [self.cards.layer insertSublayer:theViewGradient atIndex:0];
    
    // Init configure pageControl
    self.pageControl = [UIPageControl new];
    self.pageControl.pageIndicatorTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.37f];
    self.pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    // NOTE: remember add [self customizePageControlWithBorder]; aftrer self.pageControl.numberOfPages change

    self.pageControl.numberOfPages = 0;
    [self.cards addSubview:self.pageControl];
    
    SEND_GAI(@"CheckinViewController");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reloadCard];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideGuideView];
}

- (void)customizePageControlWithBorder {
    for (int i = 0; i < _pageControl.numberOfPages; i++) {
        UIView* dot = [_pageControl.subviews objectAtIndex:i];
        dot.layer.cornerRadius = dot.frame.size.height / 2;
        dot.layer.borderColor = [UIColor whiteColor].CGColor;
        dot.layer.borderWidth = 1;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *destination = segue.destinationViewController;
    if ([destination isMemberOfClass:[GuideViewController class]]) {
        self.guideViewController = (GuideViewController *)destination;
    }
}

- (void)hideGuideView {
    if (self.guideViewController != nil) {
        [self.guideViewController dismissViewControllerAnimated:YES
                                                     completion:^{
                                                         self.guideViewController = nil;
                                                     }];
    }
}

- (void)reloadCard {
    BOOL hasToken = [[AppDelegate appDelegate].accessToken length] > 0;
    if (!hasToken) {
        [self performSegueWithIdentifier:@"ShowGuide"
                                  sender:self.cards];
    } else {
        [self hideGuideView];
        GatewayWebService *ws = [[GatewayWebService alloc] initWithURL:CC_STATUS([AppDelegate appDelegate].accessToken)];
        [ws sendRequest:^(NSDictionary *json, NSString *jsonStr) {
            if (json != nil) {
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:json];
                [userInfo removeObjectForKey:@"scenarios"];
                self.userInfo = [NSDictionary dictionaryWithDictionary:userInfo];
                self.scenarios = [json objectForKey:@"scenarios"];
                [[AppDelegate appDelegate].oneSignal sendTag:@"user_id" value:[json objectForKey:@"user_id"]];
                [self.cards reloadData];
            }
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark iCarousel methods
-(void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel {
    [self.pageControl setCurrentPage:carousel.currentItemIndex];
}

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    //return the total number of items in the carousel
    if ([self.scenarios count] > 2 && [[AppDelegate appDelegate] showWhichDay] == 1) {
        // Hard code...
        [self.pageControl setNumberOfPages:3];
        [self customizePageControlWithBorder];
        return 3;
    } else {
        [self.pageControl setNumberOfPages:[self.scenarios count]];
        [self customizePageControlWithBorder];
        return [self.scenarios count];
    }
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    //    UILabel *label = nil;
    
    static CGRect cardRect;
    if (CGRectIsEmpty(cardRect)) {
        // Init cardRect
        // x 0, y 0, left 30, up 40, right 30, bottom 50
        // self.cards.contentOffset = CGSizeMake(0, -5.0f); // set in viewDidLoad
        cardRect = CGRectMake(0, 0, self.cards.bounds.size.width - 30*2, self.cards.bounds.size.height - 40 - 50);
        
        // Init configure pageControl
        CGRect pageControlFrame = self.pageControl.frame;
        self.pageControl.frame = CGRectMake(self.view.frame.size.width / 2 ,
                                            (self.cards.frame.size.height + (self.cards.frame.size.height - 50)) / 2,
                                            pageControlFrame.size.width,
                                            pageControlFrame.size.height);
    }

    //create new view if no view is available for recycling
    if (view == nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle:nil];
        CheckinCardViewController *temp = (CheckinCardViewController *)[storyboard instantiateViewControllerWithIdentifier:@"CheckinCardReuseView"];
        
        [temp.view setFrame:cardRect];
        
        view = (UIView*)temp.view;
        
        NSInteger idx = 1;
        
        // If the time is before 2016/08/20 17:00:00 show day 1, otherwise show day 2
        NSString *checkId, *lunchId, *dateId;
        if ([[AppDelegate appDelegate] showWhichDay] == 1) {
            checkId = @"day1checkin";
            lunchId = @"day1lunch";
            dateId = @"8/20";
            
            if (index == 0) {
                idx = 0;
            } else if (index == 2) {
                idx = 2;
            }
        } else {
            checkId = @"day2checkin";
            lunchId = @"day2lunch";
            dateId = @"8/21";
            
            if (index == 0) {
                idx = 3;
            } else if (index == 2) {
                idx = 4;
            }
        }
        bool isCheckin = NO;
        switch (index) {
            case 0:
                isCheckin = YES;
                [temp setId:checkId];
                [temp.checkinDate setText:dateId];
                [temp.checkinTitle setText:NSLocalizedString(@"Checkin", nil)];
                [temp.checkinText setText:NSLocalizedString(@"CheckinText", nil)];
                break;
            case 1:
                isCheckin = NO;
                [temp setId:@"kit"];
                [temp.checkinDate setText:@"COSCUP"];
                [temp.checkinTitle setText:NSLocalizedString(@"kit", nil)];
                [temp.checkinText setText:NSLocalizedString(@"CheckinNotice", nil)];
                break;
            case 2:
                isCheckin = NO;
                [temp setId:lunchId];
                [temp.checkinDate setText:dateId];
                [temp.checkinTitle setText:NSLocalizedString(@"lunch", nil)];
                [temp.checkinText setText:NSLocalizedString(@"CheckinNotice", nil)];
                break;
            default:
                break;
        }
        
        if ([self.scenarios[idx] objectForKey:@"used"]) {
            if (isCheckin) {
                [temp.checkinBtn setTitle:NSLocalizedString(@"CheckinViewButtonPressed", nil)
                                 forState:UIControlStateNormal];
            } else {
                [temp.checkinBtn setTitle:NSLocalizedString(@"UseButtonPressed", nil)
                                 forState:UIControlStateNormal];
            }
            [temp.checkinBtn setBackgroundColor:[UIColor grayColor]];
        } else {
            if (isCheckin) {
                [temp.checkinBtn setTitle:NSLocalizedString(@"CheckinViewButton", nil)
                                 forState:UIControlStateNormal];
            } else {
                [temp.checkinBtn setTitle:NSLocalizedString(@"UseButton", nil)
                                 forState:UIControlStateNormal];
            }
            [temp.checkinBtn setBackgroundColor:[UIColor colorWithRed:61/255.0 green:152/255.0 blue:60/255.0 alpha:1]];
        }
    } else {
        //get a reference to the label in the recycled view
        //        label = (UILabel *)[view viewWithTag:1];
    }
    
    //set item label
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    //    label.text = [_items[index] stringValue];
    
    return view;
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    switch (option) {
        case iCarouselOptionWrap: {
            //normally you would hard-code this to YES or NO
            return NO;
        }
        case iCarouselOptionSpacing: {
            //add a bit of spacing between the item views
            return value * 1.08f;
        }
        case iCarouselOptionFadeMax: {
            return 0.0;
        }
        case iCarouselOptionFadeMin: {
            return 0.0;
        }
        case iCarouselOptionFadeMinAlpha: {
            return 0.85;
        }
        case iCarouselOptionArc: {
            return value * (carousel.numberOfItems/48.0f);
        }
        case iCarouselOptionRadius: {
            return value * 1.0f;
        }
        case iCarouselOptionShowBackfaces:
        case iCarouselOptionAngle:
        case iCarouselOptionTilt:
        case iCarouselOptionCount:
        case iCarouselOptionFadeRange:
        case iCarouselOptionOffsetMultiplier:
        case iCarouselOptionVisibleItems: {
            return value;
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
