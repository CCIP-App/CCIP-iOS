//
//  CheckinViewController.m
//  CCIP
//
//  Created by Sars on 7/17/16.
//  Copyright © 2016 CPRTeam. All rights reserved.
//
#define TAG 99

#import <UICKeyChainStore/UICKeyChainStore.h>
#import "UIColor+addition.h"
#import "GatewayWebService/GatewayWebService.h"
#import "AppDelegate.h"
#import "CheckinCardViewController.h"
#import "CheckinViewController.h"
#import "GuideViewController.h"
#import "StatusViewController.h"
#import "InvalidNetworkMessageViewController.h"
#import "UIAlertController+additional.h"

@interface CheckinViewController()

@property (readwrite, nonatomic) BOOL firstLoad;

@property (strong, nonatomic) FBShimmeringView *shimmeringLogoView;

@property (strong, nonatomic) IBOutlet iCarousel *cards;
@property (strong, nonatomic) UIPageControl *pageControl;

@property (strong, nonatomic) NSDictionary *userInfo;
@property (strong, nonatomic) NSArray *scenarios;

@property (strong, nonatomic) SBSBarcodePicker *scanditBarcodePicker;
@property (strong, nonatomic) UIBarButtonItem *qrButton;

@property (strong, nonatomic) GuideViewController *guideViewController;
@property (strong, nonatomic) StatusViewController *statusViewController;
@property (strong, nonatomic) InvalidNetworkMessageViewController *invalidNetworkMsgViewController;

@end

@implementation CheckinViewController

- (void)setUserInfo:(NSDictionary *)userInfo {
    _userInfo = userInfo;
    [[AppDelegate appDelegate] setUserInfo:userInfo];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[AppDelegate appDelegate] setCheckinView:self];
    self.firstLoad = YES;
    
    // set logo on nav title
    UIView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"coscup-logo"]];
    self.shimmeringLogoView = [[FBShimmeringView alloc] initWithFrame:logoView.bounds];
    self.shimmeringLogoView.contentView = logoView;
    self.navigationItem.titleView = self.shimmeringLogoView;
    
    // Init configure carousel
    self.cards.type = iCarouselTypeRotary;
    self.cards.pagingEnabled = YES;
    self.cards.bounceDistance = 0.3f;
    self.cards.contentOffset = CGSizeMake(0, -5.0f);
    
    // Set carousel background linear diagonal gradient
    //   Create the colors
    UIColor *topColor = [UIColor colorFromHtmlColor:@"#00a663"];
    UIColor *bottomColor = [UIColor colorFromHtmlColor:@"#304149"];
    //   Create the gradient
    CAGradientLayer *theViewGradient = [CAGradientLayer layer];
    theViewGradient.colors = [NSArray arrayWithObjects: (id)topColor.CGColor, (id)bottomColor.CGColor, nil];
    theViewGradient.frame = CGRectMake(0, -self.topGuideHeight, self.view.frame.size.width, self.view.frame.size.height);
    theViewGradient.startPoint = CGPointMake(0.2, 0);
    theViewGradient.endPoint = CGPointMake(0.8, 1);
    //   Add gradient to view
    [self.cards.layer insertSublayer:theViewGradient
                             atIndex:0];
    
    // Init configure pageControl
    self.pageControl = [UIPageControl new];

    self.pageControl.numberOfPages = 0;
    [self.cards addSubview:self.pageControl];
    
    SEND_GAI(@"CheckinViewController");
    
    self.navigationItem.titleView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(navSingleTap)];
    [self.navigationItem.titleView addGestureRecognizer:tapGesture];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appplicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [AppDelegate setDevLogo:self.shimmeringLogoView];

    [self handleQRButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reloadCard];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideGuideView];
    [self hideStatusView];
    [self hideInvalidNetworkMsgViewController];
    [self closeBarcodePickerOverlay];
}

- (void)appplicationDidBecomeActive:(NSNotification *)notification {
    [self reloadCard];
}

- (void)navSingleTap {
    //NSLog(@"navSingleTap");
    [self handleNavTapTimes];
}

- (void)handleNavTapTimes {
    static int tapTimes = 0;
    static NSDate *oldTapTime;
    static NSDate *newTapTime;
    
    newTapTime = [NSDate date];
    if (oldTapTime == nil) {
        oldTapTime = newTapTime;
    }
    
    if ([AppDelegate isDevMode]) {
        //NSLog(@"navSingleTap from MoreTab");
        if ([newTapTime timeIntervalSinceDate: oldTapTime] <= 0.25f) {
            tapTimes++;
            if (tapTimes == 10) {
                NSLog(@"--  Success tap 10 times  --");
                if ([AppDelegate haveAccessToken]) {
                    NSLog(@"-- Clearing the Token --");
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    [AppDelegate setAccessToken:@""];
                    [[AppDelegate appDelegate].checkinView reloadCard];
                } else {
                    NSLog(@"-- Token is already clear --");
                }
            }
        }
        else {
            NSLog(@"--  Failed, just tap %2d times  --", tapTimes);
            NSLog(@"-- Not trigger clean token --");
            tapTimes = 1;
        }
        oldTapTime = newTapTime;
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
    if ([destination isMemberOfClass:[StatusViewController class]]) {
        self.statusViewController = (StatusViewController *)destination;
        [self.statusViewController setScenario:sender];
    }
    if ([destination isMemberOfClass:[InvalidNetworkMessageViewController class]]) {
        [((InvalidNetworkMessageViewController *)destination) setMessage:sender];
    }
}

- (void)hideGuideView {
    if (self.guideViewController.isVisible) {
        [self.guideViewController dismissViewControllerAnimated:YES
                                                     completion:^{
                                                         self.guideViewController = nil;
                                                     }];
    }
}

- (void)hideStatusView {
    if (self.statusViewController.isVisible) {
        [self.statusViewController dismissViewControllerAnimated:YES
                                                      completion:^{
                                                          self.statusViewController = nil;
                                                      }];
    }
}

- (void)hideInvalidNetworkMsgViewController {
    if (self.invalidNetworkMsgViewController.isVisible) {
        [self.invalidNetworkMsgViewController dismissViewControllerAnimated:YES
                                                                 completion:^{
                                                                     self.invalidNetworkMsgViewController = nil;
                                                                 }];
    }
}

- (void)goToCard {
    if ([AppDelegate haveAccessToken]) {
        __nullable id checkinCard = [[NSUserDefaults standardUserDefaults] objectForKey:@"CheckinCard"];
        if (checkinCard) {
            NSString *key = [checkinCard objectForKey:@"key"];
            for (NSDictionary *item in self.scenarios) {
                NSString *id = [item objectForKey:@"id"];
                if ([id isEqualToString:key]) {
                    unsigned long index = (unsigned long)[self.scenarios indexOfObject:item];
                    NSLog(@"%lu", index);
                    [self.cards scrollToItemAtIndex:index
                                           animated:YES];
                }
            }
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CheckinCard"];
        } else {
            // force scroll to first selected item at first load
            if ([self.cards numberOfItems] > 0 && self.firstLoad) {
                self.firstLoad = NO;
                [self.cards scrollToItemAtIndex:0
                                       animated:YES];
            }
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)reloadAndGoToCard {
    [self.cards reloadData];
    [self goToCard];
}

- (void)reloadCard {
    [self handleQRButton];

    if (![AppDelegate haveAccessToken]) {
        [self performSegueWithIdentifier:@"ShowGuide"
                                  sender:self.cards];
        self.userInfo = [NSDictionary new];
        self.scenarios = [NSArray new];
        [[AppDelegate appDelegate].oneSignal sendTag:@"user_id"
                                               value:@""];
        [self reloadAndGoToCard];
    } else {
        GatewayWebService *ws = [[GatewayWebService alloc] initWithURL:CC_STATUS([AppDelegate accessToken])];
        [ws sendRequest:^(NSDictionary *json, NSString *jsonStr, NSURLResponse *response) {
            long statusCode = (long)[(NSHTTPURLResponse *)response statusCode];
            if (statusCode >= 200) {
                switch (statusCode) {
                    case 200: {
                        if (json != nil) {
                            [self hideGuideView];
                            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:json];
                            [userInfo removeObjectForKey:@"scenarios"];
                            self.userInfo = [NSDictionary dictionaryWithDictionary:userInfo];
                            self.scenarios = [json objectForKey:@"scenarios"];
                            [[AppDelegate appDelegate].oneSignal sendTag:@"user_id"
                                                                   value:[json objectForKey:@"user_id"]];
                            if ([AppDelegate appDelegate].isLoginSession) {
                                [[AppDelegate appDelegate] displayGreetingsForLogin];
                            }
                            [self reloadAndGoToCard];
                        }
                        break;
                    }
                    case 400: {
                        if (json != nil) {
                            if ([[json objectForKey:@"message"] isEqual:@"invalid token"]) {
                                NSLog(@"%@", [json objectForKey:@"message"]);
                                
                                [AppDelegate setAccessToken:@""];
                                
                                UIAlertController *ac = [UIAlertController alertOfTitle:NSLocalizedString(@"InvalidTokenAlert", nil) withMessage:NSLocalizedString(@"InvalidTokenAlertDesc", nil) cancelButtonText:NSLocalizedString(@"GotIt", nil) cancelStyle:UIAlertActionStyleCancel cancelAction:^(UIAlertAction *action) {
                                    [self reloadCard];
                                }];
                                [ac showAlert:nil];
                            }
                        }
                        break;
                    }
                    case 403: {
                        [self performSegueWithIdentifier:@"ShowInvalidNetworkMsg"
                                                  sender:NSLocalizedString(@"Networking_WrongWiFi", nil)];
                        break;
                    }
                    default:
                        break;
                }
            } else {
                // Invalid Network
                [self performSegueWithIdentifier:@"ShowInvalidNetworkMsg"
                                          sender:NSLocalizedString(@"Networking_Broken", nil)];
                //                UIAlertController *ac = [UIAlertController alertOfTitle:NSLocalizedString(@"NetworkAlert", nil) withMessage:NSLocalizedString(@"NetworkAlertDesc", nil) cancelButtonText:NSLocalizedString(@"GotIt", nil) cancelStyle:UIAlertActionStyleCancel cancelAction:nil];
                //                [ac showAlert:nil];
            }
        }];
    }
}

- (void)showCountdown:(NSDictionary *)json {
    NSLog(@"%@", json);
    [self performSegueWithIdentifier:@"ShowCountdown"
                              sender:json];
}

- (void)showInvalidNetworkMsg {
    [self performSegueWithIdentifier:@"ShowInvalidNetworkMsg"
                              sender:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleQRButton {
    if (self.qrButton == nil) {
        self.qrButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"QR_Code.png"]
                                           landscapeImagePhone:nil
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(callBarcodePickerOverlay)];
    }
    
    if ([AppDelegate isDevMode] || ![AppDelegate haveAccessToken]){
        self.navigationItem.rightBarButtonItem = self.qrButton;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)hideQRButton {
    if (![AppDelegate isDevMode]) {
        self.navigationItem.rightBarButtonItem = nil;
    }
}
- (void)barcodePicker:(SBSBarcodePicker *)picker didScan:(SBSScanSession *)session {
    [session pauseScanning];
    
    NSArray *recognized = session.newlyRecognizedCodes;
    SBSCode *code = [recognized firstObject];
    // Add your own code to handle the barcode result e.g.
    NSLog(@"scanned %@ barcode: %@", code.symbologyName, code.data);
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        GatewayWebService *ws = [[GatewayWebService alloc] initWithURL:CC_LANDING(code.data)];
        [ws sendRequest:^(NSDictionary *json, NSString *jsonStr, NSURLResponse *response) {
            if (json != nil) {
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:json];
                
                if ([userInfo objectForKey:@"nickname"] && ![[userInfo objectForKey:@"nickname"] isEqualToString:@""]) {
                    [AppDelegate setLoginSession:YES];
                    [AppDelegate setAccessToken:code.data];
                        [self performSelector:@selector(reloadCard)
                                   withObject:nil
                                   afterDelay:0.5f];
                        [self performSelector:@selector(closeBarcodePickerOverlay)
                                   withObject:nil
                                   afterDelay:0.5f];
                } else if ([userInfo objectForKey:@"message"] && [[userInfo objectForKey:@"message"] isEqualToString:@"invalid token"]) {
                    UIAlertController *ac = [UIAlertController alertOfTitle:NSLocalizedString(@"GuideViewTokenErrorTitle", nil)
                                                                withMessage:NSLocalizedString(@"GuideViewTokenErrorDesc", nil)
                                                           cancelButtonText:NSLocalizedString(@"GotIt", nil)
                                                                cancelStyle:UIAlertActionStyleCancel
                                                               cancelAction:^(UIAlertAction *action) {
                                                                   [self.scanditBarcodePicker resumeScanning];
                                                               }];
                    [ac showAlert:nil];
                }
            }
        }];
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
    }
}

- (void)callBarcodePickerOverlay {
    [self hideGuideView];
    [self showBarcodePickerOverlay];
}

- (void)showBarcodePickerOverlay {
    if (self.scanditBarcodePicker != nil) {
        [self closeBarcodePickerOverlay];
        
        if (![AppDelegate haveAccessToken]) {
            [self performSegueWithIdentifier:@"ShowGuide" sender:NULL];
        } else {
            [self hideQRButton];
        }
    } else {
        [self.qrButton setImage:[UIImage imageNamed:@"QR_Code_Filled.png"]];
        
        // Configure the barcode picker through a scan settings instance by defining which
        // symbologies should be enabled.
        SBSScanSettings *scanSettings = [SBSScanSettings defaultSettings];
        // prefer backward facing camera over front-facing cameras.
        scanSettings.cameraFacingPreference = SBSCameraFacingDirectionBack;
        // Enable symbologies that you want to scan
        [scanSettings setSymbology:SBSSymbologyQR
                           enabled:YES];
        
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
            [self.scanditBarcodePicker performSelector:@selector(startScanning)
                                            withObject:nil
                                            afterDelay:0.5];
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
    [self.pageControl setNumberOfPages:0];
    return 0;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    //    UILabel *label = nil;
    
    static CGRect cardRect;
    if (CGRectIsEmpty(cardRect)) {
        // Init cardRect
        // x 0, y 0, left 30, up 40, right 30, bottom 50
        // self.cards.contentOffset = CGSizeMake(0, -5.0f); // set in viewDidLoad
        // 414 736
        cardRect = CGRectMake(0, 0, self.cards.bounds.size.width / 14 * (14-2), self.cards.bounds.size.height / 15.5 * (15.5-2) - 10);
        
        // Init configure pageControl
        CGRect pageControlFrame = self.pageControl.frame;
        self.pageControl.frame = CGRectMake(self.view.frame.size.width / 2 ,
                                            (self.cards.frame.size.height + (self.cards.bounds.size.height / 15.5 * (15.5-1) - 10)) / 2,
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
