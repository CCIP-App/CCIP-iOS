//
//  UIAlertController+Labels.m
//  iOS Portal
//
//  Created by 腹黒い茶 on 25/2/2015.
//  Copyright (c) 2015年 KFSYSCC. All rights reserved.
//

#import "UIAlertController+additional.h"

@implementation UIApplication (additional)

+ (UIViewController *)getMostTopPresentedViewController {
    UIViewController *vc = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    while ([vc presentedViewController])
        vc = [vc presentedViewController];
    return vc;
}

@end

@implementation UIAlertController (additional)
@dynamic titleLabel;
@dynamic messageLabel;

- (NSArray *)viewArray:(UIView *)root {
    //NSLog(@"%@", root.subviews);
    static NSArray *_subviews = nil;
    _subviews = nil;
    for (UIView *v in root.subviews) {
        if (_subviews) {
            break;
        }
        if ([v isKindOfClass:[UILabel class]]) {
            _subviews = root.subviews;
            return _subviews;
        }
        [self viewArray:v];
    }
    return _subviews;
}

- (UILabel *)titleLabel {
    return [self viewArray:self.view][0];
}

- (UILabel *)messageLabel {
    return [self viewArray:self.view][1];
}

+ (UIAlertController *)actionSheet:(id)sender withTitle:(NSString *)title andMessage:(NSString *)message {
    UIAlertController *ac = [self alertControllerWithTitle:title
                                                   message:message
                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIView *sd = sender;
    CGRect frame = [sd frame];
    frame.origin.x += frame.size.width / 2.0f;
    frame.origin.y += frame.size.height / 2.0f;
    frame.size.width = 1.0f;
    frame.size.height = 1.0f;
    sd = [sd superview];
    while(![[[sd class] description] hasSuffix:@"ViewController"] && sd != nil) {
        CGRect f = [sd frame];
        sd = [sd superview];
        frame.origin.x += f.origin.x;
        frame.origin.y += f.origin.y;
    }
    [ac.popoverPresentationController setSourceView:[[UIApplication getMostTopPresentedViewController] view]];
    [ac.popoverPresentationController setSourceRect:frame];
    return ac;
}

+ (UIAlertController *)alertOfTitle:(NSString *)title
                        withMessage:(NSString *)message
                   cancelButtonText:(NSString *)cancelText
                        cancelStyle:(UIAlertActionStyle)cancelStyle
                       cancelAction:(void (^)(UIAlertAction *))cancelAction {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:title
                                                                message:message
                                                         preferredStyle:UIAlertControllerStyleAlert];
    [ac setModalPresentationStyle:UIModalPresentationPopover];
    [ac addActionButton:cancelText
                  style:cancelStyle
                handler:cancelAction];
    return ac;
}

- (void)showAlert:(void (^)(void))completion {
    [[UIApplication getMostTopPresentedViewController] presentViewController:self
                                                                    animated:YES
                                                                  completion:completion];
}

- (void)addActionButton:(NSString *)title
                  style:(UIAlertActionStyle)style
                handler:(void (^)(UIAlertAction *))handler {
    UIAlertAction *action = [UIAlertAction actionWithTitle:title
                                                     style:style
                                                   handler:handler];
    [self addAction:action];
}

@end
