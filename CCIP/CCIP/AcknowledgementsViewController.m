//
//  AcknowledgementsViewController.m
//  CCIP
//
//  Created by FrankWu on 2016/8/12.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "AcknowledgementsViewController.h"

@interface AcknowledgementsViewController ()

@end

@implementation AcknowledgementsViewController

- (instancetype)init {
    
    CPDContribution *frankwu = [[CPDContribution alloc] initWithName:@"Frank Wu"
                                                      websiteAddress:@"https://github.com/FrankWu100"
                                                                role:@"安安"];
    frankwu.avatarAddress = @"https://www.gravatar.com/avatar/240e508e56aa36c32fcffadeff0a9ee3?r=x&s=86";
    
    CPDContribution *haraguroicha = [[CPDContribution alloc] initWithName:@"腹黒い茶"
                                                           websiteAddress:@"https://github.com/Haraguroicha"
                                                                     role:@"好喔"];
    haraguroicha.avatarAddress = @"https://www.gravatar.com/avatar/c256c1007ebd2c86d146d2d58444c9a8?&r=x&s=86";
    
    CPDContribution *sars = [[CPDContribution alloc] initWithName:@"Sars"
                                                   websiteAddress:@"https://github.com/SarsTW"
                                                             role:@"所以呢?"];
    sars.avatarAddress = @"https://www.gravatar.com/avatar/035d1b5992f40a177cdd93fa743fb606?&r=x&s=86";
    
    CPDContribution *tigerHuang = [[CPDContribution alloc] initWithName:@"TigerHuang"
                                                         websiteAddress:@"https://github.com/TigerHuang"
                                                                   role:@"Only do Initial commit"];
    tigerHuang.avatarAddress = @"https://www.gravatar.com/avatar/1db909a088e514c278884a4f72332807?&r=x&s=86";
    
    NSArray *contributors = @[frankwu, haraguroicha, sars, tigerHuang];
    
    CPDAcknowledgementsViewController *acknowledgementsViewController = [[CPDAcknowledgementsViewController alloc] initWithStyle:nil acknowledgements:nil contributions:contributors];
    
    self = (AcknowledgementsViewController*)acknowledgementsViewController;
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
