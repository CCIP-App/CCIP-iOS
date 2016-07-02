//
//  UIAlertController+Labels.h
//  iOS Portal
//
//  Created by 腹黒い茶 on 25/2/2015.
//  Copyright (c) 2015年 KFSYSCC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIApplication (additional)

+ (UIViewController *)getMostTopPresentedViewController;

@end

@interface UIAlertController (additional)

@property (nonatomic, strong) UILabel *titleLabel, *messageLabel;

+ (UIAlertController *)actionSheet:(id)sender withTitle:(NSString *)title andMessage:(NSString *)message;
+ (UIAlertController *)alertOfTitle:(NSString *)title
                        withMessage:(NSString *)message
                   cancelButtonText:(NSString *)cancelText
                        cancelStyle:(UIAlertActionStyle)cancelStyle
                       cancelAction:(void (^)(UIAlertAction *action))cancelAction;
- (void)showAlert:(void (^)(void))completion;
- (void)addActionButton:(NSString *)title
                  style:(UIAlertActionStyle)style
                handler:(void (^)(UIAlertAction *action))handler;

@end
