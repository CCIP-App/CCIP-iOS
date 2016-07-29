//
//  ProgramDetailViewController.m
//  CCIP
//
//  Created by FrankWu on 2016/7/19.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "ProgramDetailViewController.h"
#import "CAPSPageMenu.h"
#import "ProgramAbstractViewController.h"
#import "ProgramSpeakerIntroViewController.h"

@interface ProgramDetailViewController ()

@property (nonatomic) CAPSPageMenu *pageMenu;

@property (strong, nonatomic) ProgramAbstractViewController *abstractView;
@property (strong, nonatomic) ProgramSpeakerIntroViewController *speakerIntroView;

@property (strong, nonatomic) NSDictionary *program;

@end

@implementation ProgramDetailViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.abstractView = [[ProgramAbstractViewController alloc] initWithNibName:@"ProgramAbstractViewController"
                                                                            bundle:[NSBundle mainBundle]];
        self.abstractView.title = NSLocalizedString(@"Introduction", nil);
        self.speakerIntroView = [[ProgramSpeakerIntroViewController alloc] initWithNibName:@"ProgramSpeakerIntroViewController"
                                                                                    bundle:[NSBundle mainBundle]];
        self.speakerIntroView.title = NSLocalizedString(@"Speaker", nil);
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
    
    NSDictionary *parameters = @{
                                 CAPSPageMenuOptionSelectionIndicatorHeight: @(5.0),
                                 //CAPSPageMenuOptionMenuItemSeparatorWidth: @(4.3),
                                 CAPSPageMenuOptionScrollMenuBackgroundColor: [UIColor clearColor],
                                 CAPSPageMenuOptionViewBackgroundColor: [UIColor clearColor],
                                 //CAPSPageMenuOptionBottomMenuHairlineColor:
                                 CAPSPageMenuOptionSelectionIndicatorColor: [UIColor colorWithRed:184.0f/255.0f green:233.0f/255.0f blue:134.0f/255.0f alpha:1.0f],
                                 //CAPSPageMenuOptionMenuItemSeparatorColor:
                                 CAPSPageMenuOptionMenuMargin: @(0.0),
                                 CAPSPageMenuOptionMenuHeight: @(44.0),
                                 CAPSPageMenuOptionSelectedMenuItemLabelColor: [UIColor whiteColor],
                                 CAPSPageMenuOptionUnselectedMenuItemLabelColor: [UIColor whiteColor],
                                 //CAPSPageMenuOptionUseMenuLikeSegmentedControl: @(YES),   // some bug on 6+
                                 //CAPSPageMenuOptionMenuItemSeparatorRoundEdges:
                                 CAPSPageMenuOptionMenuItemFont: [UIFont systemFontOfSize:18.0f weight:UIFontWeightRegular],
                                 //CAPSPageMenuOptionMenuItemSeparatorPercentageHeight: @(0.1),
                                 CAPSPageMenuOptionMenuItemWidth: @( [[UIScreen mainScreen] bounds].size.width /2 )
                                 //CAPSPageMenuOptionEnableHorizontalBounce:
                                 //CAPSPageMenuOptionAddBottomMenuHairline:
                                 //CAPSPageMenuOptionMenuItemWidthBasedOnTitleTextWidth:
                                 //CAPSPageMenuOptionScrollAnimationDurationOnMenuItemTap:
                                 //CAPSPageMenuOptionCenterMenuItems:
                                 //CAPSPageMenuOptionHideTopMenuBar:
                                 };
    
    _pageMenu = [[CAPSPageMenu alloc] initWithViewControllers:@[ self.abstractView, self.speakerIntroView]
                                                        frame:CGRectMake(0.0, 0.0, self.pagerview.frame.size.width, self.pagerview.frame.size.height)
                                                      options:parameters];
    [self.pagerview addSubview:_pageMenu.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setProgram:(NSMutableDictionary *)program {
    _program = program;
    
    [self.abstractView setProgram:_program];
    [self.speakerIntroView setProgram:_program];
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
