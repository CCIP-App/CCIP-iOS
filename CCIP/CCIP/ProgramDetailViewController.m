//
//  ProgramDetailViewController.m
//  CCIP
//
//  Created by FrankWu on 2016/7/19.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "ProgramDetailViewController.h"
#import "ProgramDetailViewPagerController.h"

#define NotificationID_Key @"NotificationID"

@interface ProgramDetailViewController ()

@property (strong, nonatomic) ProgramDetailViewPagerController *detailViewPager;

@property (strong, nonatomic) NSDictionary *program;

@end

@implementation ProgramDetailViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.detailViewPager = [ProgramDetailViewPagerController new];
        [self addChildViewController:self.detailViewPager];
        [self.view addSubview:self.detailViewPager.view];
        [self.detailViewPager didMoveToParentViewController:self];
    }
    return self;
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil Program:(NSDictionary *)program {
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setProgram:program];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.speakername setText:[self.program objectForKey:@"speakername"]];
    [self.speakername setAdjustsFontSizeToFitWidth:YES];
    [self.speakername setMinimumScaleFactor:0.5];
    
    [self.subject setText:[self.program objectForKey:@"subject"]];
    [self.subject setAdjustsFontSizeToFitWidth:YES];
    [self.subject setMinimumScaleFactor:0.5];
    
    self.detailViewPager.view.frame = CGRectMake(0, self.topBG.frame.size.height-44, self.view.bounds.size.width, self.view.bounds.size.height-(self.topBG.frame.size.height-44));
    
    // remove followButton, use line bot to provide
    /*
    UIBarButtonItem *followButton = [[UIBarButtonItem alloc] initWithImage:[self haveRegistedLocalNotificationAction] ? [UIImage imageNamed:@"Star_Filled.png"] : [UIImage imageNamed:@"Star.png"]
                                                       landscapeImagePhone:nil
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(followAction:)];
    self.navigationItem.rightBarButtonItem = followButton;
    */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setProgram:(NSMutableDictionary *)program {
    _program = program;
    
    [self.detailViewPager setProgram:self.program];
}

- (void)followAction:(id)sender {
    if ([self haveRegistedLocalNotificationAction]) {
        [self cancelLocalNotificationAction];
    }
    else {
        [self registerLocalNotificationAction];
    }
}

- (BOOL)haveRegistedLocalNotificationAction {
    for (UILocalNotification *notification in [[[UIApplication sharedApplication] scheduledLocalNotifications] copy]){
        NSDictionary *userInfo = notification.userInfo;
        if ([[self.program objectForKey:@"slot"] isEqualToString:[userInfo objectForKey:NotificationID_Key]]){
            return YES;
        }
    }
    return NO;
}

- (void)registerLocalNotificationAction {
    UILocalNotification* notification = [UILocalNotification new];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[self.program objectForKey:@"slot"] forKey:NotificationID_Key];
    notification.userInfo = userInfo;
    
    notification.alertTitle = @"COSCUP 議程提醒";
    notification.alertBody = [NSString stringWithFormat:@"您所關注的「%@」將於 10 分鐘後在 %@ 開始", [self.program objectForKey:@"subject"], [self.program objectForKey:@"room"]];
    
    NSDateFormatter *formatter_full = [[NSDateFormatter alloc] init];
    [formatter_full setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    [formatter_full setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    NSDate *startDateTime = [formatter_full dateFromString:[self.program objectForKey:@"starttime"]];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.fireDate = [startDateTime dateByAddingTimeInterval:-(10*60)];

    // demo test, after 10 secound
    //notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:10];

    notification.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    [self.navigationItem.rightBarButtonItem setImage:[UIImage imageNamed:@"Star_Filled.png"]];
}

- (void)cancelLocalNotificationAction {
    for (UILocalNotification *notification in [[[UIApplication sharedApplication] scheduledLocalNotifications] copy]){
        NSDictionary *userInfo = notification.userInfo;
        if ([[self.program objectForKey:@"slot"] isEqualToString:[userInfo objectForKey:NotificationID_Key]]){
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
            [self.navigationItem.rightBarButtonItem setImage:[UIImage imageNamed:@"Star.png"]];
        }
    }
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
