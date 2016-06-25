//
//  MasterViewController.h
//  CCIP
//
//  Created by FrankWu on 2016/6/25.
//  Copyright © 2016年 FrankWu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Google/Analytics.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;

@end

