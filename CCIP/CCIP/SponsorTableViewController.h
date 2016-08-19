//
//  SponsorTableViewController.h
//  CCIP
//
//  Created by Sars on 8/6/16.
//  Copyright © 2016 CPRTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SponsorTableViewController : UITableViewController<UIViewControllerPreviewingDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray *sponsorLevelJsonArray;
@property (strong, nonatomic) NSArray *sponsorArray;

@end
