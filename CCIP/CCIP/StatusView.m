//
//  StatusView.m
//  CCIP
//
//  Created by 腹黒い茶 on 2016/06/26.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "AppDelegate.h"
#import "StatusView.h"
#import "UIColor+Transition.h"
@import AudioToolbox.AudioServices;

@interface StatusView()

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSDate *countTime;
@property (readwrite, nonatomic) float maxValue;
@property (readwrite, nonatomic) float countDown;
@property (readwrite, nonatomic) NSTimeInterval interval;

@end

@implementation StatusView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)gotoTop {
    [((UINavigationController *)[self.appDelegate.splitViewController.viewControllers firstObject]) popToRootViewControllerAnimated:YES];
}

- (void)setScenario:(NSDictionary *)scenario {
    _scenario = scenario;
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.statusMessageLabel setText:NSLocalizedString(@"StatusNotice", nil)];
    [self.countdownLabel setHidden:YES];
    if ([[self.scenario objectForKey:@"countdown"] floatValue] > 0) {
        [self.countdownLabel setHidden:NO];
        //[((UIViewController *)self.nextResponder).navigationItem.leftBarButtonItem setEnabled:NO];
        [self performSelector:@selector(startCountDown)
                   withObject:nil
                   afterDelay:0.5f];
    }
    [self setCountTime:[NSDate new]];
    self.maxValue = (float)([[self.scenario objectForKey:@"used"] intValue] + [[self.scenario objectForKey:@"countdown"] intValue] - [self.countTime timeIntervalSince1970]);
    self.interval = [[NSDate new] timeIntervalSinceDate:self.countTime];
    self.countDown = self.maxValue - self.interval;
    [self.countdownLabel setText:@""];
}

- (void)startCountDown {
    [self setCountTime:[NSDate new]];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.001f target:self selector:@selector(updateCountDown) userInfo:nil repeats:YES];
}

- (void)updateCountDown {
    UIColor *color = self.tintColor;
    self.interval = [[NSDate new] timeIntervalSinceDate:self.countTime];
    self.countDown = self.maxValue - self.interval;
    if (self.countDown <= 0) {
        self.countDown = 0;
        color = [UIColor redColor];
        [((UIViewController *)self.nextResponder).navigationItem.leftBarButtonItem setEnabled:YES];
        [self.timer invalidate];
        AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate, ^{
            AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate, ^{
                AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate, ^{
                    AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate, ^{
                        AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate, ^{
                        });
                    });
                });
            });
        });
    } else if (self.countDown >= (self.maxValue / 2)) {
        color = [UIColor colorFrom:self.tintColor
                                To:[UIColor purpleColor]
                                At:1 - ((self.countDown - (self.maxValue / 2)) / (self.maxValue - (self.maxValue / 2)))];
    } else if (self.countDown >= (self.maxValue / 6)) {
        color = [UIColor colorFrom:[UIColor purpleColor]
                                To:[UIColor orangeColor]
                                At:1 - ((self.countDown - (self.maxValue / 6)) / (self.maxValue - ((self.maxValue / 2) + (self.maxValue / 6))))];
    } else if (self.countDown > 0) {
        color = [UIColor colorFrom:[UIColor orangeColor]
                                To:[UIColor redColor]
                                At:1 - ((self.countDown - 0) / (self.maxValue - (self.maxValue - (self.maxValue / 6))))];
    }
    [self.countdownLabel setTextColor:color];
    [self.countdownLabel setText:[NSString stringWithFormat:@"%0.3f", self.countDown]];
}

@end
