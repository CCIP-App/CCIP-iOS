//
//  AnnounceTableViewController.h
//  CCIP
//
//  Created by Sars on 8/10/16.
//  Copyright © 2016 CPRTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnnounceTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *announceTableView;
@property (strong, nonatomic) NSArray *announceJsonArray;
@property (weak, nonatomic) IBOutlet UIImageView *ivNoAnnouncement;
@property (weak, nonatomic) IBOutlet UILabel *lbNoAnnouncement;

@end
