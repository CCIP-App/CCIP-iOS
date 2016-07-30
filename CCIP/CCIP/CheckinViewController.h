//
//  CheckinViewController.h
//  CCIP
//
//  Created by Sars on 7/17/16.
//  Copyright © 2016 CPRTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iCarousel/iCarousel.h>

@interface CheckinViewController : UIViewController<iCarouselDataSource, iCarouselDelegate>

@property (strong, nonatomic) IBOutlet iCarousel *cards;

- (void)reloadCard;

@end
