//
//  InvalidNetworkMessageViewController.h
//  CCIP
//
//  Created by FrankWu on 2016/8/14.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InvalidNetworkRetryDelegate <NSObject>

- (void)refresh;

@end

@interface InvalidNetworkMessageViewController : UIViewController

@property (weak, nonatomic) id<InvalidNetworkRetryDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

- (void)setMessage:(NSString *)message;

@end
