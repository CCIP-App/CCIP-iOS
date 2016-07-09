//
//  ProgramDetailViewController.m
//  CCIP
//
//  Created by FrankWu on 2016/7/10.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "ProgramDetailViewController.h"
#import <STPopup/STPopup.h>

@interface ProgramDetailViewController ()

@end

@implementation ProgramDetailViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.title = @"View Controller";
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(nextBtnDidTap)];
        self.contentSizeInPopup = CGSizeMake(300, 400);
//        self.landscapeContentSizeInPopup = CGSizeMake(400, 200);
        
        UIBarButtonItem *shareButton = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                        target:self
                                        action:@selector(compartir:)];
        self.navigationItem.rightBarButtonItem = shareButton;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backgroundViewDidTap
{
    NSLog(@"backgroundViewDidTap");
    [self.popupController dismiss];
}

- (void) compartir:(id)sender{
    // TODO: Share Program's Link
    
    NSLog(@"shareButton pressed");
    
    NSString *stringtoshare= @"This is a string to share";
    
    NSArray *activityItems = @[stringtoshare];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
//    activityVC.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypeAirDrop, UIActivityTypeCopyToPasteboard, UIActivityTypeMessage, UIActivityTypePostToTwitter, UIActivityTypePostToFacebook];
    [self presentViewController:activityVC animated:TRUE completion:nil];
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
