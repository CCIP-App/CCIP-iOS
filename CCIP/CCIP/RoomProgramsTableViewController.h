//
//  RoomProgramsTableViewController.h
//  CCIP
//
//  Created by FrankWu on 2016/7/3.
//  Copyright © 2016年 FrankWu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoomProgramsTableViewController : UITableViewController<UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSString *room;
@property (strong, nonatomic) NSArray *programs;

@end
