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

@interface CheckinViewController : UIViewController<iCarouselDataSource, iCarouselDelegate, SBSScanDelegate>

@property (strong, nonatomic) IBOutlet iCarousel *cards;

- (void)reloadCard;
- (void)showCountdown:(NSDictionary *)json;

@end
