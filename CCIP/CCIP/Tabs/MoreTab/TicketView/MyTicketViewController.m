//
//  MyTicketViewController.m
//  CCIP
//
//  Created by 腹黒い茶 on 2017/07/24.
//  Copyright © 2017年 CPRTeam. All rights reserved.
//

#import "MyTicketViewController.h"
#import "AppDelegate.h"

@interface MyTicketViewController ()

@end

@implementation MyTicketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *noticeText;
    if ([AppDelegate haveAccessToken]) {
        CGImageRef QRImage = [TicketQRCodeImage generate:[AppDelegate accessToken]
                                                    size:self.ivQRCode.frame.size
                                         backgroundColor:[CIColor colorWithCGColor:[[UIColor whiteColor] CGColor]]
                                         foregroundColor:[CIColor colorWithCGColor:[[UIColor blackColor] CGColor]]
                                               watermark:nil];
        UIImage *qrImage = [UIImage imageWithCGImage:QRImage];
        [self.ivQRCode setImage:qrImage];
        noticeText = NSLocalizedString(@"TicketNotice", nil);
    } else {
        noticeText = NSLocalizedString(@"TicketNonExistNotice", nil);
    }
    [self.lbNotice setText:noticeText];
    [self.lbNotice setTextColor:[AppDelegate AppConfigColor:@"CardTextColor"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
