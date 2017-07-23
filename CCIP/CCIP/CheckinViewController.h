//
//  CheckinViewController.h
//  CCIP
//
//  Created by Sars on 7/17/16.
//  Copyright © 2016 CPRTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iCarousel/iCarousel.h>
#import <ScanditBarcodeScanner/ScanditBarcodeScanner.h>

@interface CheckinViewController : UIViewController<iCarouselDataSource, iCarouselDelegate, SBSScanDelegate, SBSProcessFrameDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (readonly, nonatomic) CGFloat controllerTopStart;

- (void)goToCard;
- (void)reloadCard;
- (void)showCountdown:(NSDictionary *)json;
- (void)showInvalidNetworkMsg;

@end
