//
//  StatusView.m
//  CCIP
//
//  Created by 腹黒い茶 on 2016/06/26.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "AppDelegate.h"
#import "StatusView.h"
#import "UIColor+addition.h"
@import AudioToolbox.AudioServices;

@interface StatusView()

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSDate *countTime;
@property (readwrite, nonatomic) float maxValue;
@property (readwrite, nonatomic) float countDown;
@property (readwrite, nonatomic) NSTimeInterval interval;
@property (strong, nonatomic) NSDateFormatter *formatter;
@property (readwrite, nonatomic) BOOL countDownEnd;

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
//    [[AppDelegate appDelegate].navigationView popToRootViewControllerAnimated:YES];
}

- (void)setScenario:(NSDictionary *)scenario {
    _scenario = scenario;
    [self.statusMessageLabel setText:NSLocalizedString(@"StatusNotice", nil)];
    [self.countdownLabel setHidden:YES];
    if ([[self.scenario objectForKey:@"countdown"] floatValue] > 0) {
        [self.countdownLabel setHidden:NO];
        //[((UIViewController *)self.nextResponder).navigationItem.leftBarButtonItem setEnabled:NO];
        [self performSelector:@selector(startCountDown)
                   withObject:nil
                   afterDelay:0.5f];
    }
    [self setCountDownEnd:NO];
    [self setCountTime:[NSDate new]];
    [self setMaxValue:(float)([[self.scenario objectForKey:@"used"] intValue] + [[self.scenario objectForKey:@"countdown"] intValue] - [self.countTime timeIntervalSince1970])];
    [self setInterval:[[NSDate new] timeIntervalSinceDate:self.countTime]];
    [self setCountDown:(self.maxValue - self.interval)];
    [self setFormatter:[NSDateFormatter new]];
    [self.formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    [self.countdownLabel setText:@""];
    [self.nowTimeLabel setText:@""];
}

- (void)startCountDown {
    [self setCountTime:[NSDate new]];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.001f
                                                  target:self
                                                selector:@selector(updateCountDown)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)updateCountDown {
    UIColor *color = self.tintColor;
    NSDate *now = [NSDate new];
    [self setInterval:[now timeIntervalSinceDate:self.countTime]];
    [self setCountDown:(self.maxValue - self.interval)];
    if (self.countDown <= 0) {
        [self setCountDown:0];
        color = [UIColor redColor];
        if (self.countDownEnd == NO) {
            [((UIViewController *)self.nextResponder).navigationItem.leftBarButtonItem setEnabled:YES];
            [self.timer invalidate];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.25f
                                                          target:self
                                                        selector:@selector(updateCountDown)
                                                        userInfo:nil
                                                         repeats:YES];
            [self setCountDownEnd:YES];
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
        }
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
    [self.nowTimeLabel setText:[self.formatter stringFromDate:now]];
}

@end
