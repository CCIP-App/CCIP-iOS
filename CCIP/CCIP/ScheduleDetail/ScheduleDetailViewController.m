//
//  ScheduleDetailViewController.m
//  CCIP
//
//  Created by 腹黒い茶 on 2017/07/21.
//  Copyright © 2017年 CPRTeam. All rights reserved.
//

#import "AppDelegate.h"
#import "ScheduleDetailViewController.h"
#import "UIColor+addition.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ScheduleDetailViewController ()

@property (strong, nonatomic) NSDictionary *detailData;

@end

@implementation ScheduleDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    SEND_GAI(@"ScheduleDetailViewController");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    NSDictionary *data = self.detailData;
    NSDateFormatter *formatter_full = nil;
    formatter_full = [NSDateFormatter new];
    [formatter_full setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSDateFormatter *formatter_date = nil;
    formatter_date = [NSDateFormatter new];
    [formatter_date setDateFormat:@"HH:mm"];
    [formatter_date setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Taipei"]];
    NSDate *startTime = [formatter_full dateFromString:[data objectForKey:@"start"]];
    NSDate *endTime = [formatter_full dateFromString:[data objectForKey:@"end"]];
    NSString *startTimeString = [formatter_date stringFromDate:startTime];
    NSString *endTimeString = [formatter_date stringFromDate:endTime];
    NSString *timeRange = [NSString stringWithFormat:@"%@ - %@", startTimeString, endTimeString];
    UIImage *defaultIcon = [UIImage imageNamed:@"StaffIconDefault"];
    [self.lbTitle setText:[data objectForKey:@"subject"]];
    [self.lbSpeakerName setText:[[data objectForKey:@"speaker"] objectForKey:@"name"]];
    [self.ivSpeakerPhoto setImage:defaultIcon];
    [self.ivSpeakerPhoto sd_setImageWithURL:[NSURL URLWithString:[[data objectForKey:@"speaker"] objectForKey:@"avatar"]]
                           placeholderImage:defaultIcon
                                    options:SDWebImageRefreshCached];
    [self.lbRoomText setText:[data objectForKey:@"room"]];
    [self.lbLangText setText:[data objectForKey:@"lang"]];
    [self.lbTimeText setText:timeRange];
    
    [self.vwHeader setGradientColor:[UIColor colorFromHtmlColor:@"#20E2D7"]
                                 To:[UIColor colorFromHtmlColor:@"#F9FEA5"]
                         StartPoint:CGPointMake(1, .5)
                            ToPoint:CGPointMake(-.4, .5)];
//    [self.view.layer setCornerRadius:15.0f];
//    [self.view.layer setMasksToBounds:NO];
//    [self.view.layer setShadowOffset:CGSizeMake(0, 50)];
//    [self.view.layer setShadowRadius:50.0f];
//    [self.view.layer setShadowOpacity:0.1f];
}

- (void)setDetailData:(NSDictionary *)data {
    _detailData = data;
}

- (NSDictionary *)getDetailData {
    return _detailData;
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
