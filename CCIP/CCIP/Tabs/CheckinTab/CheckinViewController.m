//
//  CheckinViewController.m
//  CCIP
//
//  Created by Sars on 7/17/16.
//  Copyright © 2016 CPRTeam. All rights reserved.
//

#import <UICKeyChainStore/UICKeyChainStore.h>
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "AppDelegate.h"
#import "CheckinCardViewController.h"
#import "CheckinViewController.h"
#import "AfterEventViewController.h"
#import "GuideViewController.h"
#import "StatusViewController.h"
#import "WebServiceEndPoint.h"

@interface CheckinViewController()

@property (strong, nonatomic) FBShimmeringView *shimmeringLogoView;

@property (strong, nonatomic) IBOutlet iCarousel *cards;
@property (weak, nonatomic) IBOutlet UIImageView *ivRectangle;
@property (weak, nonatomic) IBOutlet UIImageView *ivUserPhoto;
@property (weak, nonatomic) IBOutlet UILabel *lbHi;
@property (weak, nonatomic) IBOutlet UILabel *lbUserName;
@property (strong, nonatomic) UIPageControl *pageControl;

@property (strong, nonatomic) NSDictionary *userInfo;
@property (strong, nonatomic) NSArray *scenarios;

@property (strong, nonatomic) SBSBarcodePicker *scanditBarcodePicker;
@property (strong, nonatomic) UIBarButtonItem *qrButtonItem;

@property (strong, nonatomic) GuideViewController *guideViewController;
@property (strong, nonatomic) StatusViewController *statusViewController;
@property (strong, nonatomic) InvalidNetworkMessageViewController *invalidNetworkMsgViewController;

@property (readwrite, nonatomic) CGFloat controllerTopStart;

@property (weak, nonatomic) MBProgressHUD *progress;

@end

@implementation CheckinViewController

#pragma mark private method

- (void)setUserInfo:(NSDictionary *)userInfo {
    _userInfo = userInfo;
    [[AppDelegate appDelegate] setUserInfo:userInfo];
}

#pragma mark View Events

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self.navigationController.navigationBar setHidden:YES];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
    
    [[AppDelegate appDelegate] setCheckinView:self];
    
    // set logo on nav title
    UIView *logoView = [[UIImageView alloc] initWithImage:[Constants AssertImageWithName:@"AssetsUI"
                                                                            InBundleName:@"conf-logo"]];
    self.shimmeringLogoView = [[FBShimmeringView alloc] initWithFrame:logoView.bounds];
    [self.shimmeringLogoView setContentView:logoView];
//    [self.navigationItem setTitleView:self.shimmeringLogoView];
    
    // Init configure pageControl
    self.pageControl = [UIPageControl new];
    [self.pageControl setNumberOfPages:0];
    // Init configure carousel
    [self.cards addSubview:self.pageControl];
    [self.cards setType:iCarouselTypeRotary];
    [self.cards setPagingEnabled:YES];
    [self.cards setBounceDistance:0.3f];
    [self.cards setContentOffset:CGSizeMake(0, -5.0f)];
    [self.lbUserName setText:@" "];
    
    SEND_FIB(@"CheckinViewController");
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(navSingleTap)];
    [self.lbUserName setUserInteractionEnabled:YES];
    [self.lbUserName addGestureRecognizer:tapGesture];
    [self.lbUserName setHidden:![AppDelegate haveAccessToken]];
    [self.lbHi setHidden:![AppDelegate haveAccessToken]];
//    [self.ivUserPhoto setUserInteractionEnabled:YES];
//    [self.ivUserPhoto addGestureRecognizer:tapGesture];
    [self.ivUserPhoto setImage:[Constants AssertImageWithName:@"PassAssets"
                                                 InBundleName:@"StaffIconDefault"]];
    [self.ivUserPhoto setHidden:![AppDelegate haveAccessToken]];
    [self.ivUserPhoto.layer setCornerRadius:self.ivUserPhoto.frame.size.height / 2];
    [self.ivUserPhoto.layer setMasksToBounds:YES];
    
    [self.ivRectangle setGradientColorFrom:[AppDelegate AppConfigColor:@"CheckinRectangleLeftColor"]
                                        to:[AppDelegate AppConfigColor:@"CheckinRectangleRightColor"]
                                startPoint:CGPointMake(-.4f, .5f)
                                   toPoint:CGPointMake(1, .5f)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appplicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

    [[[AppDelegate appDelegate] beacon] checkAvailableAndRequestAuthorization];
    [[[AppDelegate appDelegate] beacon] registerBeaconRegionWithUUIDWithUuidString:BEACON_UUID
                                                                        identifier:BEACON_ID
                                                                         isMonitor:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.controllerTopStart = self.navigationController.navigationBar.frame.size.height;
    [AppDelegate setDevLogo:self.shimmeringLogoView
                   WithLogo:[Constants AssertImageWithName:@"AssetsUI"
                                              InBundleName:@"conf-logo"]];
    [self handleQRButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reloadCard];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideGuideView:nil];
    [self hideStatusView:nil];
    [self hideInvalidNetworkMsgViewController:nil];
    [self closeBarcodePickerOverlay];
}

- (void)appplicationDidBecomeActive:(NSNotification *)notification {
    [self reloadCard];
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
        InvalidNetworkMessageViewController *inmvc = (InvalidNetworkMessageViewController *)destination;
        [inmvc setMessage:sender];
        [inmvc setDelegate:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refresh {
    [self reloadCard];
}

#pragma mark Dev Mode

- (void)navSingleTap {
    //NSLog(@"navSingleTap");
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

#pragma mark hide custom view controller method

- (void)hideGuideView:(void(^)(void))completion {
    BOOL isVisible = [self.guideViewController isVisible];
    if (isVisible) {
        [self.guideViewController dismissViewControllerAnimated:YES
                                                     completion:^{
                                                         self.guideViewController = nil;
                                                         if (completion != nil) {
                                                             completion();
                                                         }
                                                     }];
    } else {
        if (completion != nil) {
            completion();
        }
    }
}

- (void)hideStatusView:(void(^)(void))completion {
    BOOL isVisible = [self.statusViewController isVisible];
    if (isVisible) {
        [self.statusViewController dismissViewControllerAnimated:YES
                                                      completion:^{
                                                          self.statusViewController = nil;
                                                          if (completion != nil) {
                                                              completion();
                                                          }
                                                      }];
    } else {
        if (completion != nil) {
            completion();
        }
    }
}

- (void)hideInvalidNetworkMsgViewController:(void(^)(void))completion {
    BOOL isVisible = [self.invalidNetworkMsgViewController isVisible];
    if (isVisible) {
        [self.invalidNetworkMsgViewController dismissViewControllerAnimated:YES
                                                                 completion:^{
                                                                     self.invalidNetworkMsgViewController = nil;
                                                                     if (completion != nil) {
                                                                         completion();
                                                                     }
                                                                 }];
    } else {
        if (completion != nil) {
            completion();
        }
    }
}

#pragma mark cards methods

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
            if ([self.cards numberOfItems] > 0) {
//                [self.cards scrollToItemAtIndex:0
//                                       animated:YES];
                // auto scroll to first unused and available item
                NSArray *scenarios = [[AppDelegate appDelegate] availableScenarios];
                for (NSDictionary *scenario in scenarios) {
                    BOOL used = [scenario objectForKey:@"used"] != nil;
                    BOOL disabled = [scenario objectForKey:@"disabled"] != nil;
                    if (!used && !disabled) {
                        [self.cards scrollToItemAtIndex:[scenarios indexOfObject:scenario]
                                               animated:YES];
                        break;
                    }
                }
            }
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [self.progress hide:YES];
}

- (void)reloadAndGoToCard {
    [self.cards reloadData];
    [self goToCard];
}

- (void)reloadCard {
    if (self.progress != nil) {
        [self.progress hide:YES];
    }
    self.progress = [MBProgressHUD showHUDAddedTo:self.view
                                         animated:YES];
    [self.progress setMode:MBProgressHUDModeIndeterminate];
    [self handleQRButton];

    [self.lbHi setHidden:![AppDelegate haveAccessToken]];
    [self.lbUserName setHidden:![AppDelegate haveAccessToken]];
    [self.ivUserPhoto setHidden:![AppDelegate haveAccessToken]];
    [self.lbUserName setText:@" "];
    if (![AppDelegate haveAccessToken]) {
        if (self.scanditBarcodePicker == nil) {
            if (![self.presentedViewController isKindOfClass:[GuideViewController class]]) {
                [self performSegueWithIdentifier:@"ShowGuide"
                                          sender:self.cards];
            }
            self.userInfo = [NSDictionary new];
            self.scenarios = [NSArray new];
            [AppDelegate sendTag:@"user_id"
                           value:@""];
            [[AppDelegate appDelegate] setScenarios:self.scenarios];
            [self reloadAndGoToCard];
        }
    } else {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        
        NSURL *URL = [NSURL URLWithString:CC_STATUS([AppDelegate accessToken])];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            NSLog(@"Response: %@", response);
            if (!error) {
                NSLog(@"Json: %@", responseObject);
                if (responseObject != nil) {
                    [self hideGuideView:nil];
                    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:responseObject];
                    [userInfo removeObjectForKey:@"scenarios"];
                    self.userInfo = [NSDictionary dictionaryWithDictionary:userInfo];
                    self.scenarios = [responseObject objectForKey:@"scenarios"];
                    [self.lbHi setHidden:![AppDelegate haveAccessToken]];
                    [self.ivUserPhoto setHidden:![AppDelegate haveAccessToken]];
                    [self.lbUserName setHidden:![AppDelegate haveAccessToken]];
                    [self.lbUserName setText:[self.userInfo objectForKey:@"user_id"]];
                    NSMutableDictionary *userTags = [NSMutableDictionary dictionaryWithDictionary:self.userInfo];
                    [userTags removeObjectsForKeys:@[
                                                     @"_id",
                                                     @"first_use",
                                                     @"attr" // wait for cleanup
                                                     ]];
                    [AppDelegate sendTags:[NSDictionary dictionaryWithDictionary:userTags]];
                    if ([AppDelegate appDelegate].isLoginSession) {
                        [[AppDelegate appDelegate] displayGreetingsForLogin];
                    }
                    [[AppDelegate appDelegate] setScenarios:self.scenarios];
                    [self reloadAndGoToCard];
                }
            } else {
                NSLog(@"Error: %@", error);
                long statusCode = [(NSHTTPURLResponse *)response statusCode];
                switch (statusCode) {
                    case 400: {
                        if (responseObject != nil) {
                            if ([[responseObject objectForKey:@"message"] isEqual:@"invalid token"]) {
                                NSLog(@"%@", [responseObject objectForKey:@"message"]);
                                
                                [AppDelegate setAccessToken:@""];
                                
                                UIAlertController *ac = [UIAlertController alertOfTitle:NSLocalizedString(@"InvalidTokenAlert", nil)
                                                                            withMessage:NSLocalizedString(@"InvalidTokenDesc", nil)
                                                                       cancelButtonText:NSLocalizedString(@"GotIt", nil)
                                                                            cancelStyle:UIAlertActionStyleCancel
                                                                           cancelAction:^(UIAlertAction *action) {
                                                                               [self reloadCard];
                                                                           }];
                                [ac showAlert:^{
                                    [AppDelegate triggerFeedback:NotificationFeedbackError];
                                }];
                            }
                        }
                        break;
                    }
                    case 403: {
                        [self performSegueWithIdentifier:@"ShowInvalidNetworkMsg"
                                                  sender:NSLocalizedString(@"Networking_WrongWiFi", nil)];
                        break;
                    }
                    default: {
                        // Invalid Network
                        [self performSegueWithIdentifier:@"ShowInvalidNetworkMsg"
                                                  sender:NSLocalizedString(@"Networking_Broken", nil)];
//                        UIAlertController *ac = [UIAlertController alertOfTitle:NSLocalizedString(@"NetworkAlert", nil)
//                                                                    withMessage:NSLocalizedString(@"NetworkAlertDesc", nil)
//                                                               cancelButtonText:NSLocalizedString(@"GotIt", nil)
//                                                                    cancelStyle:UIAlertActionStyleCancel
//                                                                   cancelAction:nil];
//                        [ac showAlert:^{
//                            [AppDelegate triggerFeedback:NotificationFeedbackError];
//                        }];
                        break;
                    }
                }
            }
        }];
        [dataTask resume];
    }
}

#pragma mark display messages

- (void)showCountdown:(NSDictionary *)json {
    NSLog(@"%@", json);
    [self performSegueWithIdentifier:@"ShowCountdown"
                              sender:json];
}

- (void)showInvalidNetworkMsg {
    [self performSegueWithIdentifier:@"ShowInvalidNetworkMsg"
                              sender:nil];
}

#pragma makr QR Code Scanner

- (void)handleQRButton {
    if (self.qrButtonItem == nil) {
        self.qrButtonItem = [[UIBarButtonItem alloc] initWithImage:[Constants AssertImageWithName:@"AssetsUI"
                                                                                     InBundleName:@"QR_Code"]
                                               landscapeImagePhone:nil
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(callBarcodePickerOverlay)];
    }
    
    self.navigationItem.rightBarButtonItem = nil;
    if ([AppDelegate isDevMode] || ![AppDelegate haveAccessToken]) {
        self.navigationItem.rightBarButtonItem = self.qrButtonItem;
    }
}

- (void)hideQRButton {
    if (![AppDelegate isDevMode]) {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)barcodePicker:(nonnull SBSBarcodePicker *)barcodePicker
      didProcessFrame:(nonnull CMSampleBufferRef)frame
              session:(nonnull SBSScanSession *)session {
    //
}

- (void)barcodePicker:(SBSBarcodePicker *)picker didScan:(SBSScanSession *)session {
    [session pauseScanning];

    NSArray *recognized = session.newlyRecognizedCodes;
    SBSCode *code = [recognized firstObject];
    // Add your own code to handle the barcode result e.g.
    NSLog(@"scanned %@ barcode: %@", code.symbologyName, code.data);
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        
        NSURL *URL = [NSURL URLWithString:CC_LANDING(code.data)];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            NSLog(@"Response: %@", response);
            if (!error) {
                NSLog(@"Json: %@", responseObject);
                if (responseObject != nil) {
                    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:responseObject];
                    
                    if ([userInfo objectForKey:@"nickname"] && ![[userInfo objectForKey:@"nickname"] isEqualToString:@""]) {
                        [AppDelegate setLoginSession:YES];
                        [AppDelegate setAccessToken:code.data];
                        [self performSelector:@selector(reloadCard)
                                   withObject:nil
                                   afterDelay:0.5f];
                        [self performSelector:@selector(closeBarcodePickerOverlay)
                                   withObject:nil
                                   afterDelay:0.5f];
                    }
                }
            } else {
                NSLog(@"Error: %@", error);
                long statusCode = [(NSHTTPURLResponse *)response statusCode];
                switch (statusCode) {
                    case 400: {
                        if (responseObject != nil) {
                            if ([responseObject objectForKey:@"message"] && [[responseObject objectForKey:@"message"] isEqualToString:@"invalid token"]) {
                                UIAlertController *ac = [UIAlertController alertOfTitle:NSLocalizedString(@"GuideViewTokenErrorTitle", nil)
                                                                            withMessage:NSLocalizedString(@"GuideViewTokenErrorDesc", nil)
                                                                       cancelButtonText:NSLocalizedString(@"GotIt", nil)
                                                                            cancelStyle:UIAlertActionStyleCancel
                                                                           cancelAction:^(UIAlertAction *action) {
                                                                               [self.scanditBarcodePicker resumeScanning];
                                                                           }];
                                [ac showAlert:^{
                                    [AppDelegate triggerFeedback:NotificationFeedbackError];
                                }];
                            }
                        }
                        break;
                    }
                    default:
                        break;
                }
            }
        }];
        [dataTask resume];
    }];
}

//! [SBSBarcodePicker overlayed as a view]

/**
 * A simple example of how the barcode picker can be used in a simple view of various dimensions
 * and how it can be added to any o ther view. This example scales the view instead of cropping it.
 */

- (void)closeBarcodePickerOverlay {
    if (self.scanditBarcodePicker != nil) {
        [self.qrButtonItem setImage:[Constants AssertImageWithName:@"AssetsUI"
                                                      InBundleName:@"QR_Code"]];
        
        [self.scanditBarcodePicker removeFromParentViewController];
        [self.scanditBarcodePicker.view removeFromSuperview];
        [self.scanditBarcodePicker didMoveToParentViewController:nil];
        self.scanditBarcodePicker = nil;
        [self.lbHi setHidden:![AppDelegate haveAccessToken]];
        [self.lbUserName setHidden:![AppDelegate haveAccessToken]];
        [self.ivUserPhoto setHidden:![AppDelegate haveAccessToken]];
    }
}

- (void)callBarcodePickerOverlay {
    [self hideGuideView:^{
        [self showBarcodePickerOverlay];
    }];
}

- (void)showBarcodePickerOverlay {
    if (self.scanditBarcodePicker != nil) {
        [self closeBarcodePickerOverlay];
        
        if (![AppDelegate haveAccessToken]) {
            [self performSegueWithIdentifier:@"ShowGuide"
                                      sender:nil];
        } else {
            [self hideQRButton];
        }
    } else {
        [self.lbHi setHidden:YES];
        [self.ivUserPhoto setHidden:YES];
        [self.qrButtonItem setImage:[Constants AssertImageWithName:@"AssetsUI"
                                                      InBundleName:@"QR_Code_Filled"]];
        
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
        self.scanditBarcodePicker.processFrameDelegate = self;
        
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
                                                               constant:self.controllerTopStart + X_TOP(0.0f, 22.0f)]];
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
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0
                                                               constant:0.0]];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setFrame:CGRectMake(65, 15, 60, 40)];
        [button setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.35f]];
        [button.layer setMasksToBounds:YES];
        [button.layer setCornerRadius:20.0f];
        
        [button setTitle:@"Files" forState:UIControlStateNormal];
        [button setTintColor:[UIColor blackColor]];
        
        [button addTarget:self action:@selector(getImageFromLibrary) forControlEvents:UIControlEventTouchUpInside];

        [self.scanditBarcodePicker.view addSubview:button];
        
        [self.scanditBarcodePicker startScanningInPausedState:YES completionHandler:^{
            [self.scanditBarcodePicker performSelector:@selector(startScanning)
                                            withObject:nil
                                            afterDelay:0.5];
        }];
    }
}

#pragma mark QR Code from Camera Roll Library

- (void)getImageFromLibrary {
    UIImagePickerController *imagePicker = [UIImagePickerController new];
    [imagePicker setDelegate:self];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    [self presentViewController:imagePicker
                       animated:YES
                     completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:@"public.image"]) {
        UIImage *srcImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy: CIDetectorAccuracyHigh }];
        CIImage *image = [CIImage imageWithCGImage:srcImage.CGImage];
        NSArray *features = [detector featuresInImage:image];
        for (CIQRCodeFeature *feature in features) {
            NSLog(@"%@", feature.messageString);
        }
        CIQRCodeFeature *feature = [features firstObject];
        
        NSString *result = feature.messageString;
        NSLog(@"QR: %@", result);
        
        __block UIAlertController *ac;
        if (result != nil) {
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            
            NSURL *URL = [NSURL URLWithString:CC_LANDING(result)];
            NSURLRequest *request = [NSURLRequest requestWithURL:URL];
            
            NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                NSLog(@"Response: %@", response);
                if (!error) {
                    NSLog(@"Json: %@", responseObject);
                    if (responseObject != nil) {
                        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:responseObject];
                        
                        if ([userInfo objectForKey:@"nickname"] && ![[userInfo objectForKey:@"nickname"] isEqualToString:@""]) {
                            [AppDelegate setLoginSession:YES];
                            [AppDelegate setAccessToken:result];
                            [picker dismissViewControllerAnimated:YES completion:^{
                                [self reloadCard];
                            }];
                        }
                    }
                } else {
                    NSLog(@"Error: %@", error);
                    long statusCode = [(NSHTTPURLResponse *)response statusCode];
                    switch (statusCode) {
                        case 400: {
                            if (responseObject != nil) {
                                if ([responseObject objectForKey:@"message"] && [[responseObject objectForKey:@"message"] isEqualToString:@"invalid token"]) {
                                    ac = [UIAlertController alertOfTitle:NSLocalizedString(@"GuideViewTokenErrorTitle", nil)
                                                             withMessage:NSLocalizedString(@"GuideViewTokenErrorDesc", nil)
                                                        cancelButtonText:NSLocalizedString(@"GotIt", nil)
                                                             cancelStyle:UIAlertActionStyleCancel
                                                            cancelAction:nil];
                                    [picker dismissViewControllerAnimated:YES
                                                               completion:^{
                                                                   [ac showAlert:^{
                                                                       [AppDelegate triggerFeedback:NotificationFeedbackError];
                                                                   }];
                                                               }];
                                }
                            }
                            break;
                        }
                        default:
                            break;
                    }
                }
            }];
            [dataTask resume];
        } else {
            ac = [UIAlertController alertOfTitle:NSLocalizedString(@"QRFileNotAvailableTitle", nil)
                                     withMessage:NSLocalizedString(@"QRFileNotAvailableDesc", nil)
                                cancelButtonText:NSLocalizedString(@"GotIt", nil)
                                     cancelStyle:UIAlertActionStyleCancel
                                    cancelAction:nil];
            [picker dismissViewControllerAnimated:YES
                                       completion:^{
                                           [ac showAlert:^{
                                               [AppDelegate triggerFeedback:NotificationFeedbackError];
                                           }];
                                       }];
        }
    }
}

#pragma mark iCarousel methods
- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel {
    if ([[[AppDelegate appDelegate] availableScenarios] count] > 0) {
        [self.pageControl setCurrentPage:carousel.currentItemIndex];
    }
}

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    //return the total number of items in the carousel
    NSInteger count = [[[AppDelegate appDelegate] availableScenarios] count];
    [self.pageControl setNumberOfPages:count];
    return count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    //    UILabel *label = nil;
    
    static CGRect cardRect;
    if (CGRectIsEmpty(cardRect)) {
        // Init configure pageControl
        [self.pageControl setHidden:YES];  // set page control to hidden
        CGRect pageControlFrame = self.pageControl.frame;
        self.pageControl.frame = CGRectMake(self.view.frame.size.width / 2 ,
                                            (self.cards.frame.size.height + self.cards.bounds.size.height - (self.pageControl.hidden ? 0 : 10)) / 2,
                                            pageControlFrame.size.width,
                                            pageControlFrame.size.height);
        // Init cardRect
        // x 0, y 0, left 30, up 40, right 30, bottom 50
        // self.cards.contentOffset = CGSizeMake(0, -5.0f); // set in viewDidLoad
        // 414 736
        cardRect = CGRectMake(0, 0, self.cards.bounds.size.width, self.cards.bounds.size.height - (self.pageControl.hidden ? 0 : 10));
    }

    //create new view if no view is available for recycling
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    BOOL haveScenario = [[[AppDelegate appDelegate] availableScenarios] count] > 0;
    if (view == nil) {
        if (haveScenario) {
            CheckinCardViewController *temp = (CheckinCardViewController *)[storyboard instantiateViewControllerWithIdentifier:@"CheckinCardReuseView"];
            
            [temp.view setFrame:cardRect];
            view = temp.view;
            
            NSDictionary *scenario = [[[AppDelegate appDelegate] availableScenarios] objectAtIndex:index];
            
            NSString *id = [scenario objectForKey:@"id"];
            BOOL isCheckin = [id rangeOfString:@"checkin" options:NSCaseInsensitiveSearch].length > 0;
            BOOL isLunch = [id rangeOfString:@"lunch" options:NSCaseInsensitiveSearch].length > 0;
            BOOL isKit = [[id lowercaseString] isEqualToString:@"kit"];
            BOOL isVipKit = [[id lowercaseString] isEqualToString:@"vipkit"];
            BOOL isShirt = [[id lowercaseString] isEqualToString:@"shirt"];
            BOOL isRadio = [id rangeOfString:@"radio" options:NSCaseInsensitiveSearch].length > 0;
            [temp setId:id];
            NSArray *dateRange = [AppDelegate parseRange:scenario];
            NSString *availableRange = [NSString stringWithFormat:@"%@\n%@", [dateRange firstObject], [dateRange lastObject]];
            NSDictionary *dd = [AppDelegate parseScenarioType:id];
            NSString *did = [dd objectForKey:@"did"];
            NSString *scenarioType = [dd objectForKey:@"scenarioType"];
            NSDictionary *displayText = [scenario objectForKey:@"display_text"];
            NSString *lang = [AppDelegate longLangUI];
            UIImage *defaultIcon = [Constants AssertImageWithName:@"PassAssets"
                                                     InBundleName:@"doc"];
            UIImage *scenarioIcon = nilCoalesceDefault([Constants AssertImageWithName:@"PassAssets"
                                                                         InBundleName:scenarioType], defaultIcon);
            [temp.checkinTitle setTextColor:[AppDelegate AppConfigColor:@"CardTextColor"]];
            [temp.checkinDate setTextColor:[AppDelegate AppConfigColor:@"CardTextColor"]];
            [temp.checkinText setTextColor:[AppDelegate AppConfigColor:@"CardTextColor"]];
            [temp.checkinTitle setText:[displayText objectForKey:lang]];
//            [temp.checkinDate setText:NSLocalizedString(@"Title", nil)];
            [temp.checkinDate setText:availableRange];
            [temp.checkinText setText:NSLocalizedString(@"CheckinNotice", nil)];
            [temp.checkinIcon setImage:scenarioIcon];
            if (isCheckin) {
                [temp.checkinIcon setImage:[Constants AssertImageWithName:@"PassAssets"
                                                             InBundleName:[@"day" stringByAppendingString:did]]];
                [temp.checkinText setText:NSLocalizedString(@"CheckinText", nil)];
            }
            if (isLunch) {
                // nothing to do
            }
            if (isKit) {
                // nothing to do
            }
            if (isVipKit) {
                [temp.checkinText setText:NSLocalizedString(@"CheckinTextVipKit", nil)];
            }
            if (isShirt) {
                [temp.checkinText setText:NSLocalizedString(@"CheckinStaffShirtNotice", nil)];
            }
            if (isRadio) {
                [temp.checkinText setText:NSLocalizedString(@"CheckinStaffRadioNotice", nil)];
            }
            
            if ([scenario objectForKey:@"disabled"]) {
                [temp setDisabled:[NSNumber numberWithBool:YES]];
                [temp.checkinBtn setTitle:[scenario objectForKey:@"disabled"] forState:UIControlStateNormal];
                [temp.checkinBtn setGradientColorFrom:[AppDelegate AppConfigColor:@"DisabledButtonLeftColor"]
                                                   to:[AppDelegate AppConfigColor:@"DisabledButtonRightColor"]
                                           startPoint:CGPointMake(.2, .8)
                                              toPoint:CGPointMake(1, .5)];
            } else if ([scenario objectForKey:@"used"]) {
                [temp setUsed:[NSNumber numberWithBool:YES]];
                if (isCheckin) {
                    [temp.checkinBtn setTitle:NSLocalizedString(@"CheckinViewButtonPressed", nil)
                                     forState:UIControlStateNormal];
                } else {
                    [temp.checkinBtn setTitle:NSLocalizedString(@"UseButtonPressed", nil)
                                     forState:UIControlStateNormal];
                }
                [temp.checkinBtn setGradientColorFrom:[AppDelegate AppConfigColor:@"UsedButtonLeftColor"]
                                                   to:[AppDelegate AppConfigColor:@"UsedButtonRightColor"]
                                           startPoint:CGPointMake(.2, .8)
                                              toPoint:CGPointMake(1, .5)];
            } else {
                [temp setUsed:[NSNumber numberWithBool:NO]];
                if (isCheckin) {
                    [temp.checkinBtn setTitle:NSLocalizedString(@"CheckinViewButton", nil)
                                     forState:UIControlStateNormal];
                } else {
                    [temp.checkinBtn setTitle:NSLocalizedString(@"UseButton", nil)
                                     forState:UIControlStateNormal];
                }
                [temp.checkinBtn setGradientColorFrom:[AppDelegate AppConfigColor:@"CheckinButtonLeftColor"]
                                                   to:[AppDelegate AppConfigColor:@"CheckinButtonRightColor"]
                                           startPoint:CGPointMake(.2, .8)
                                              toPoint:CGPointMake(1, .5)];
            }
            [temp.checkinBtn setTintColor:[UIColor whiteColor]];
            
            [temp setDelegate:self];
            [temp setScenario:scenario];
//        } else if ([[[AppDelegate appDelegate] availableDays] count] > 0 && [AppDelegate isAfterEvent]) {
//            AfterEventViewController *temp = (AfterEventViewController *)[storyboard instantiateViewControllerWithIdentifier:@"AfterEventCardReuseView"];
//
//            [temp.view setFrame:cardRect];
//            view = temp.view;
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
            return value * (1.08f - 0.18f);
        }
        case iCarouselOptionFadeMax: {
            return 0.0;
        }
        case iCarouselOptionFadeMin: {
            return 0.0;
        }
        case iCarouselOptionFadeMinAlpha: {
            return 0.85 - 0.2;
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
