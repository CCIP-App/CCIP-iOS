//
//  CheckinViewController.m
//  CCIP
//
//  Created by Sars on 7/17/16.
//  Copyright © 2016 CPRTeam. All rights reserved.
//
#define TAG 99

#import <UICKeyChainStore/UICKeyChainStore.h>
#import "GatewayWebService/GatewayWebService.h"
#import "AppDelegate.h"
#import "CheckinCardViewController.h"
#import "CheckinViewController.h"
#import "GuideViewController.h"
#import "StatusViewController.h"

@interface CheckinViewController()

@property (strong, nonatomic) NSDictionary *userInfo;
@property (strong, nonatomic) NSArray *scenarios;
@property (strong, nonatomic) GuideViewController *guideViewController;
@property (strong, nonatomic) StatusViewController *statusViewController;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) SBSBarcodePicker *scanditBarcodePicker;
@property (strong, nonatomic) UIBarButtonItem *qrButton;

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

    self.pageControl.numberOfPages = 0;
    [self.cards addSubview:self.pageControl];
    
    SEND_GAI(@"CheckinViewController");
}

- (void)viewWillAppear:(BOOL)animated {
    [self showQRButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reloadCard];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideGuideView];
    [self hideStatusView];
    [self closeBarcodePickerOverlay];
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *destination = segue.destinationViewController;
    if ([destination isMemberOfClass:[GuideViewController class]]) {
        self.guideViewController = (GuideViewController *)destination;
    }
    if ([destination isMemberOfClass:[StatusViewController class]]) {
        self.statusViewController = (StatusViewController *)destination;
        [self.statusViewController setScenario:sender];
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

- (void)hideStatusView {
    if (self.statusViewController != nil) {
        [self.statusViewController dismissViewControllerAnimated:YES
                                                      completion:^{
                                                          self.statusViewController = nil;
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

- (void)showCountdown:(NSDictionary *)json {
    NSLog(@"%@", json);
    [self performSegueWithIdentifier:@"ShowCountdown"
                              sender:json];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showQRButton {
    if (self.qrButton == nil) {
        self.qrButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"QR_Code.png"]
                                           landscapeImagePhone:nil
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(callBarcodePickerOverlay)];
    }
    BOOL isDevMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"DEV_MODE"];
    BOOL hasToken = [[AppDelegate appDelegate].accessToken length] > 0;
    if (isDevMode || !hasToken){
        self.tabBarController.navigationItem.rightBarButtonItem = self.qrButton;
    }
}

- (void)hideQRButton {
    BOOL isDevMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"DEV_MODE"];
    if (!isDevMode) {
        self.tabBarController.navigationItem.rightBarButtonItem = nil;
    }
}
- (void)barcodePicker:(SBSBarcodePicker *)picker didScan:(SBSScanSession *)session {
    [session stopScanning];
    
    NSArray *recognized = session.newlyRecognizedCodes;
    SBSCode *code = [recognized firstObject];
    // Add your own code to handle the barcode result e.g.
    NSLog(@"scanned %@ barcode: %@", code.symbologyName, code.data);
    
    if ([[AppDelegate appDelegate].accessToken length] > 0) {
        [UICKeyChainStore removeItemForKey:@"token"];
    }
    [AppDelegate appDelegate].accessToken = code.data;
    [UICKeyChainStore setString:[AppDelegate appDelegate].accessToken
                         forKey:@"token"];
    [[AppDelegate appDelegate].oneSignal sendTag:@"token" value:[AppDelegate appDelegate].accessToken];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        //Do UI stuff here
        [self performSelector:@selector(reloadCard) withObject:nil afterDelay:0.5];
        [self performSelector:@selector(closeBarcodePickerOverlay) withObject:nil afterDelay:0.5];
    }];
}

//! [SBSBarcodePicker overlayed as a view]

/**
 * A simple example of how the barcode picker can be used in a simple view of various dimensions
 * and how it can be added to any o ther view. This example scales the view instead of cropping it.
 */

- (void)closeBarcodePickerOverlay {
    if (self.scanditBarcodePicker != nil) {
        [self.qrButton setImage:[UIImage imageNamed:@"QR_Code.png"]];
        
        [self.scanditBarcodePicker removeFromParentViewController];
        [self.scanditBarcodePicker.view removeFromSuperview];
        [self.scanditBarcodePicker didMoveToParentViewController:nil];
        self.scanditBarcodePicker = nil;
        
        BOOL hasToken = [[AppDelegate appDelegate].accessToken length] > 0;
        if (!hasToken) {
            [self performSegueWithIdentifier:@"ShowGuide" sender:NULL];
        } else {
            [self hideQRButton];
        }
    }
}

- (void)callBarcodePickerOverlay {
    if (self.guideViewController.isVisible) {
        [self.guideViewController dismissViewControllerAnimated:YES
                                                     completion:^{
                                                         self.guideViewController = nil;
                                                         [self showBarcodePickerOverlay];
                                                     }];
    } else {
        [self showBarcodePickerOverlay];
    }
}

- (void)showBarcodePickerOverlay {
    if (self.scanditBarcodePicker != nil) {
        [self closeBarcodePickerOverlay];
    } else {
        [self.qrButton setImage:[UIImage imageNamed:@"QR_Code_Filled.png"]];
        
        // Configure the barcode picker through a scan settings instance by defining which
        // symbologies should be enabled.
        SBSScanSettings *scanSettings = [SBSScanSettings defaultSettings];
        // prefer backward facing camera over front-facing cameras.
        scanSettings.cameraFacingPreference = SBSCameraFacingDirectionBack;
        // Enable symbologies that you want to scan
        [scanSettings setSymbology:SBSSymbologyQR enabled:YES];
        
        self.scanditBarcodePicker = [[SBSBarcodePicker alloc] initWithSettings:scanSettings];
        
        /* Set the delegate to receive callbacks.
         * This is commented out here in the demo app since the result view with the scan results
         * is not suitable for this overlay view */
        self.scanditBarcodePicker.scanDelegate = self;
        
        // Add a button behind the subview to close it.
        // self.backgroundButton.hidden = NO;
        
        [self addChildViewController:self.scanditBarcodePicker];
        [self.view addSubview:self.scanditBarcodePicker.view];
        [self.scanditBarcodePicker didMoveToParentViewController:self];
        
        [self.scanditBarcodePicker.view setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        // Add constraints to scale the view and place it in the center of the controller.
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.scanditBarcodePicker.view
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.scanditBarcodePicker.view
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1.0
                                                               constant:self.view.topGuideHeight]];
        // Add constraints to set the width to 200 and height to 400. Since this is not the aspect ratio
        // of the camera preview some of the camera preview will be cut away on the left and right.
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.scanditBarcodePicker.view
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:1.0
                                                               constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.scanditBarcodePicker.view
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.cards
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:1.0
                                                               constant:0.0]];
        
        [self.scanditBarcodePicker startScanningInPausedState:YES completionHandler:^{
            [self.scanditBarcodePicker performSelector:@selector(startScanning) withObject:nil afterDelay:0.5];
        }];
        
    }
}

#pragma mark iCarousel methods
- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel {
    [self.pageControl setCurrentPage:carousel.currentItemIndex];
}

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    //return the total number of items in the carousel
    if ([self.scenarios count] > 3) {
        [self.pageControl setNumberOfPages:4];
        return 4;
    }

    return 0;
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
        
        // index in scenario array
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
        
        if (index == 3) {
            idx = 5;
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
                [temp setId:@"kit"];
                [temp.checkinDate setText:@"COSCUP"];
                [temp.checkinTitle setText:NSLocalizedString(@"kit", nil)];
                [temp.checkinText setText:NSLocalizedString(@"CheckinNotice", nil)];
                break;
            case 2:
                [temp setId:lunchId];
                [temp.checkinDate setText:dateId];
                [temp.checkinTitle setText:NSLocalizedString(@"lunch", nil)];
                [temp.checkinText setText:NSLocalizedString(@"CheckinNotice", nil)];
                break;
            case 3:
                [temp setId:@"vipkit"];
                [temp.checkinDate setText:@"COSCUP"];
                [temp.checkinTitle setText:NSLocalizedString(@"vipkit", nil)];
                [temp.checkinText setText:NSLocalizedString(@"CheckinTextVipKit", nil)];
            default:
                break;
        }
        
        if ([self.scenarios[idx] objectForKey:@"disabled"]) {
            [temp setDisabled:[NSNumber numberWithBool:YES]];
            [temp.checkinBtn setTitle:[self.scenarios[idx] objectForKey:@"disabled"] forState:UIControlStateNormal];
            [temp.checkinBtn setBackgroundColor:[UIColor grayColor]];
        } else if ([self.scenarios[idx] objectForKey:@"used"]) {
            [temp setUsed:[NSNumber numberWithBool:YES]];
            if (isCheckin) {
                [temp.checkinBtn setTitle:NSLocalizedString(@"CheckinViewButtonPressed", nil)
                                 forState:UIControlStateNormal];
            } else {
                [temp.checkinBtn setTitle:NSLocalizedString(@"UseButtonPressed", nil)
                                 forState:UIControlStateNormal];
            }
            [temp.checkinBtn setBackgroundColor:[UIColor grayColor]];
        } else {
            [temp setUsed:[NSNumber numberWithBool:NO]];
            if (isCheckin) {
                [temp.checkinBtn setTitle:NSLocalizedString(@"CheckinViewButton", nil)
                                 forState:UIControlStateNormal];
            } else {
                [temp.checkinBtn setTitle:NSLocalizedString(@"UseButton", nil)
                                 forState:UIControlStateNormal];
            }
            [temp.checkinBtn setBackgroundColor:[UIColor colorWithRed:61/255.0 green:152/255.0 blue:60/255.0 alpha:1]];
        }
        
        [temp setDelegate:self];
        [temp setScenario:[self.scenarios objectAtIndex:idx]];
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
