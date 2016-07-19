//
//  ProgramDetailPopViewController.m
//  CCIP
//
//  Created by FrankWu on 2016/7/10.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "ProgramDetailPopViewController.h"
#import <STPopup/STPopup.h>
#import "ShareProgramTableViewController.h"
#import "NSInvocation+addition.h"


@interface ProgramDetailPopViewController ()


@property BOOL enableBackgroundViewTap;

@end

@implementation ProgramDetailPopViewController

- (instancetype)init
{
    if (self = [super init]) {
//        coscup.org/2016/schedules.html#R13
        self.title = @"View Controller";
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(nextBtnDidTap)];
        self.contentSizeInPopup = CGSizeMake(round([[UIScreen mainScreen] bounds].size.width * 4/5), round([[UIScreen mainScreen] bounds].size.height * 3/5));
//        self.landscapeContentSizeInPopup = CGSizeMake(400, 200);
        
        UIBarButtonItem *shareButton = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                        target:self
                                        action:@selector(shareAction:)];
        self.navigationItem.rightBarButtonItem = shareButton;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _enableBackgroundViewTap = YES;
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    _enableBackgroundViewTap = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setProgram:(NSMutableDictionary *)program {
    _program = program;
}

- (void)backgroundViewDidTap
{
    NSLog(@"backgroundViewDidTap");
    if (_enableBackgroundViewTap == YES)
    {
        [self.popupController dismiss];
    }
}

- (void)shareAction:(id)sender{
    // TODO: Share Program's Link
    
    ShareProgramTableViewController *shareTableViewController = [ShareProgramTableViewController new];
    
    [NSInvocation InvokeObject:shareTableViewController
            withSelectorString:@"setProgram:"
                 withArguments:@[ self.program ]];
    
    [self.popupController pushViewController:shareTableViewController animated:YES];
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
