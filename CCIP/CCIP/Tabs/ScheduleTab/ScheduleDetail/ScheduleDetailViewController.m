//
//  ScheduleDetailViewController.m
//  CCIP
//
//  Created by 腹黒い茶 on 2017/07/21.
//  Copyright © 2017年 CPRTeam. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "UITableView+FDTemplateLayoutCell.h"
#import "AppDelegate.h"
#import "ScheduleDetailViewController.h"
#import "UIColor+addition.h"
#import "UIView+addition.h"
#import "WebServiceEndPoint.h"
#import "ScheduleAbstractViewCell.h"
#import "ScheduleSpeakerInfoViewCell.h"

#define ABSTRACT_CELL       (@"ScheduleAbstract")
#define SPEAKERINFO_CELL    (@"ScheduleSpeakerInfo")

@interface ScheduleDetailViewController ()

@property (strong, nonatomic) NSArray *identifiers;
@property (strong, nonatomic) NSDictionary *detailData;

@end

@implementation ScheduleDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    SEND_FIB(@"ScheduleDetailViewController");
    
    self.identifiers = @[ ABSTRACT_CELL, SPEAKERINFO_CELL ];
    [self.tvContent setSeparatorColor:[UIColor clearColor]];
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
    UIImage *defaultIcon = ASSETS_IMAGE(@"PassAssets", @"StaffIconDefault");
    [self.lbTitle setText:[data objectForKey:@"subject"]];
    [self.lbSpeakerName setText:[[data objectForKey:@"speaker"] objectForKey:@"name"]];
    [self.ivSpeakerPhoto setImage:defaultIcon];
    [self.ivSpeakerPhoto sd_setImageWithURL:[NSURL URLWithString:[[[data objectForKey:@"speaker"] objectForKey:@"avatar"] stringByReplacingOccurrencesOfString:@"http:"
                                                                                                                                                    withString:@"https:"]]
                           placeholderImage:defaultIcon
                                    options:SDWebImageRefreshCached];
    [self.ivSpeakerPhoto.layer setCornerRadius:self.ivSpeakerPhoto.frame.size.height / 2];
    [self.ivSpeakerPhoto.layer setMasksToBounds:YES];
    [self.lbRoomText setText:[data objectForKey:@"room"]];
    [self.lbLangText setText:[data objectForKey:@"lang"]];
    [self.lbTimeText setText:timeRange];
    
    [self.vwHeader setGradientColor:[AppDelegate AppConfigColor:@"ScheduleTitleLeftColor"]
                                 To:[AppDelegate AppConfigColor:@"ScheduleTitleRightColor"]
                         StartPoint:CGPointMake(1, .5)
                            ToPoint:CGPointMake(-.4, .5)];
    
    // following constraint for fix the storyboard autolayout broken the navigation bar alignment
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.vwHeader
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:0]];

    NSArray *lbs = @[
                     self.lbSpeaker,
                     self.lbSpeakerName,
                     self.lbTitle,
                     self.lbRoom,
                     self.lbRoomText,
                     self.lbLang,
                     self.lbLangText,
                     self.lbTime,
                     self.lbTimeText
                     ];
    for (UILabel *lb in lbs) {
        [lb setTextColor:[AppDelegate AppConfigColor:@"ScheduleTitleTextColor"]];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.identifiers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self.identifiers objectAtIndex:indexPath.row]];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:[self.identifiers objectAtIndex:indexPath.row] configuration:^(id cell) {
        [self configureCell:cell atIndexPath:indexPath];
    }];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    [cell setFd_enforceFrameLayout:NO]; // Enable to use "-sizeThatFits:"
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setClipsToBounds:NO];
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell.layer setZPosition:indexPath.row];
    UIView *vwContent = [cell performSelector:@selector(vwContent)];
    [vwContent.layer setCornerRadius:5.0f];
    [vwContent.layer setShadowRadius:50.0f];
    [vwContent.layer setShadowOffset:CGSizeMake(0, 50)];
    [vwContent.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [vwContent.layer setShadowOpacity:0.1f];
    [vwContent.layer setMasksToBounds:NO];
    NSDictionary *cells = @{
                            ABSTRACT_CELL: ^{
                                ScheduleAbstractViewCell *abstractCell = (ScheduleAbstractViewCell *)cell;
                                NSString *summary = [NSString stringWithFormat:@"%@\n", [self.detailData objectForKey:@"summary"]];
                                NSLog(@"Set summary: %@", summary);
                                [abstractCell.lbAbstractContent setText:summary];
                                [abstractCell.lbAbstractContent sizeToFit];
                                [abstractCell.lbAbstractText setTextColor:[UIColor colorFromHtmlColor:COLOR_CARD_TEXT]];
                            },
                            SPEAKERINFO_CELL: ^{
                                ScheduleSpeakerInfoViewCell *speakerInfoCell = (ScheduleSpeakerInfoViewCell *)cell;
                                NSString *bio = [NSString stringWithFormat:@"%@\n", [[self.detailData objectForKey:@"speaker"] objectForKey:@"bio"]];
                                NSLog(@"Set bio: %@", bio);
                                [speakerInfoCell.lbSpeakerInfoContent setText:bio];
                                [speakerInfoCell.lbSpeakerInfoContent sizeToFit];
                                [speakerInfoCell.lbSpeakerInfoTitle setTextColor:[UIColor colorFromHtmlColor:COLOR_CARD_TEXT]];
                            }
                            };
    @try {
        void(^block)(void) = [cells objectForKey:[self.identifiers objectAtIndex:indexPath.row]];
        block();
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

- (void)setDetailData:(NSDictionary *)data {
    _detailData = data;
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
