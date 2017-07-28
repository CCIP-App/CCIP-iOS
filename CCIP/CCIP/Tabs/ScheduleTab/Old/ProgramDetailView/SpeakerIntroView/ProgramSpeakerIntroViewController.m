//
//  ProgramSpeakerIntroViewController.m
//  CCIP
//
//  Created by FrankWu on 2016/7/19.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "ProgramSpeakerIntroViewController.h"

@interface ProgramSpeakerIntroViewController ()

@end

@implementation ProgramSpeakerIntroViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil Program:(NSDictionary *)program {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setProgram:program];
    }
    return self;
}

-(void)setView {
    [self.SpeakerIntroInfo setText:[_program objectForKey:@"speakerintro"]];
    
    // disable UITextView's text padding
    [self.SpeakerIntroInfo setTextContainerInset:UIEdgeInsetsZero];
    [self.SpeakerIntroInfo.textContainer setLineFragmentPadding:0.0f];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (self.program) {
        [self setView];
    }}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setProgram:(NSMutableDictionary *)program {
    _program = program;
    [self setView];
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
