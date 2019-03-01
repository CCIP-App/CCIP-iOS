//
//  AnnounceTableViewCell.h
//  CCIP
//
//  Created by Sars on 8/10/16.
//  Copyright © 2016 CPRTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnnounceTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *vwShadowContent;
@property (weak, nonatomic) IBOutlet UIView *vwMessageTime;
@property (weak, nonatomic) IBOutlet UIView *vwURL;
@property (weak, nonatomic) IBOutlet UIView *vwContent;
@property (weak, nonatomic) IBOutlet UILabel *lbMessage;
@property (weak, nonatomic) IBOutlet UILabel *lbMessageTime;
@property (weak, nonatomic) IBOutlet UIView *vwDashedLine;
@property (weak, nonatomic) IBOutlet UILabel *lbIconOfURL;
@property (weak, nonatomic) IBOutlet UILabel *lbURL;

@property (nonatomic, copy) IBOutletCollection(NSLayoutConstraint) NSArray *fd_collapsibleConstraints;

@end
