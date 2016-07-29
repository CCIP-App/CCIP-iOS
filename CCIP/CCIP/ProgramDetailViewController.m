//
//  ProgramDetailViewController.m
//  CCIP
//
//  Created by FrankWu on 2016/7/19.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "ProgramDetailViewController.h"
#import "ProgramDetailViewPagerController.h"

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

-(void)setViewPager {
    self.detailViewPager.view.frame = CGRectMake(0, self.topBG.frame.size.height-44, self.view.bounds.size.width, self.view.bounds.size.height-(self.topBG.frame.size.height-44));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setViewPager];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.speakername setText:[self.program objectForKey:@"speakername"]];
    [self.speakername setAdjustsFontSizeToFitWidth:YES];
    [self.speakername setMinimumScaleFactor:0.5];
    
    [self.subject setText:[self.program objectForKey:@"subject"]];
    [self.subject setAdjustsFontSizeToFitWidth:YES];
    [self.subject setMinimumScaleFactor:0.5];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setProgram:(NSMutableDictionary *)program {
    _program = program;
    
    [self.detailViewPager setProgram:self.program];
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
