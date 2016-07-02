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
        [((UIViewController *)self.nextResponder).navigationItem.leftBarButtonItem setEnabled:NO];
        [self performSelector:@selector(startCountDown)
                   withObject:nil
                   afterDelay:0.5f];
    }
}

- (void)startCountDown {
    [self setCountTime:[NSDate new]];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.001f target:self selector:@selector(updateCountDown) userInfo:nil repeats:YES];
}

- (void)updateCountDown {
    NSTimeInterval interval = [[NSDate new] timeIntervalSinceDate:self.countTime];
    UIColor *color = self.tintColor;
    float maxValue = [[self.scenario objectForKey:@"countdown"] floatValue];
    float countDown = maxValue - interval;
    if (countDown <= 0) {
        countDown = 0;
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
    } else if (countDown >= (maxValue / 2)) {
        color = [UIColor colorFrom:self.tintColor
                                To:[UIColor purpleColor]
                                At:1 - ((countDown - (maxValue / 2)) / (maxValue - (maxValue / 2)))];
    } else if (countDown >= (maxValue / 6)) {
        color = [UIColor colorFrom:[UIColor purpleColor]
                                To:[UIColor orangeColor]
                                At:1 - ((countDown - (maxValue / 6)) / (maxValue - ((maxValue / 2) + (maxValue / 6))))];
    } else if (countDown > 0) {
        color = [UIColor colorFrom:[UIColor orangeColor]
                                To:[UIColor redColor]
                                At:1 - ((countDown - 0) / (maxValue - (maxValue - (maxValue / 6))))];
    }
    [self.countdownLabel setTextColor:color];
    [self.countdownLabel setText:[NSString stringWithFormat:@"%0.3f", countDown]];
}

@end
