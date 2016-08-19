//
//  AcknowledgementsViewController.m
//  CCIP
//
//  Created by FrankWu on 2016/8/12.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#import "AcknowledgementsViewController.h"
#import "GatewayWebService/GatewayWebService.h"
#import "NSData+CommonCrypto.h"
#import "NSData+PMUtils.h"
#import <SafariServices/SFSafariViewController.h>

#import <CPDAcknowledgements/CPDAcknowledgementsViewController.h>
#import <CPDAcknowledgements/CPDContribution.h>
#import <CPDAcknowledgements/CPDCocoaPodsLibrariesLoader.h>
#import <CPDAcknowledgements/CPDLibrary.h>

@interface AcknowledgementsViewController ()

@property (strong, nonatomic) NSString *githubRepoLink;

@end

@implementation AcknowledgementsViewController

- (void)configuration {
    NSMutableArray *contributors = [NSMutableArray new];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Project_Info_and_Contributors" ofType:@"json"];
    NSString *projectInfoJSON = [[NSString alloc] initWithContentsOfFile:filePath
                                                                encoding:NSUTF8StringEncoding
                                                                   error:nil];
    NSError *error =  nil;
    NSDictionary *projectInfoData = [NSJSONSerialization JSONObjectWithData:[projectInfoJSON dataUsingEncoding:NSUTF8StringEncoding]
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:&error];
    
    NSArray *selfContributorIndexList = [[projectInfoData objectForKey:@"self"] objectForKey:@"contributors"];
    NSArray *allContributorArray = [projectInfoData objectForKey:@"contributors"];
    
    if (!error) {
        for (NSNumber *contributorIndex in selfContributorIndexList) {
            for (NSDictionary *contributorDict in allContributorArray) {
                if ([contributorDict objectForKey:@"index"] == contributorIndex) {
                    CPDContribution *contributor = [[CPDContribution alloc] initWithName:[contributorDict objectForKey:@"nick_name"]
                                                                          websiteAddress:[self getWebsiteAddress:contributorDict]
                                                                                    role:[contributorDict objectForKey:@"role"]];
                    contributor.avatarAddress = [self getAvatarAddress:contributorDict];
                    [contributors addObject:contributor];
                    break;
                }
            }
        }
    }
    
    NSString *githubRepo = [[projectInfoData objectForKey:@"self"] objectForKey:@"github_repo"];
    if (githubRepo && ![githubRepo isEqualToString:@""]) {
        self.githubRepoLink = [NSString stringWithFormat:@"https://github.com/%@", githubRepo];
    }
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSMutableArray *acknowledgements = [NSMutableArray arrayWithArray:[CPDCocoaPodsLibrariesLoader loadAcknowledgementsWithBundle:bundle]];
    
    
    NSString *customAckJSONPath = [[NSBundle mainBundle] pathForResource:@"Project_3rd_Lib_License" ofType:@"json"];
    NSString *customAckJSON = [[NSString alloc] initWithContentsOfFile:customAckJSONPath
                                                              encoding:NSUTF8StringEncoding
                                                                 error:nil];
    NSArray *customAckArray = [NSJSONSerialization JSONObjectWithData:[customAckJSON dataUsingEncoding:NSUTF8StringEncoding]
                                                              options:NSJSONReadingAllowFragments
                                                                error:&error];
    
    for (NSDictionary *acknowledgementDict in customAckArray) {
        [acknowledgements addObject:[[CPDLibrary alloc] initWithCocoaPodsMetadataPlistDictionary:acknowledgementDict]];
    }
    
    CPDAcknowledgementsViewController *acknowledgementsViewController;
    acknowledgementsViewController = [[CPDAcknowledgementsViewController alloc] initWithStyle:nil
                                                                             acknowledgements:acknowledgements
                                                                                contributions:contributors];
    [self addChildViewController:acknowledgementsViewController];
    acknowledgementsViewController.view.frame = self.view.frame;
    [self.view addSubview:acknowledgementsViewController.view];
    [acknowledgementsViewController didMoveToParentViewController:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle {
    self = [super initWithNibName:nibName bundle:bundle];
    if (self) {
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (NSString *)getWebsiteAddress:(NSDictionary *)contributor {
    // website > github_site(github.login) > nil
    NSString *website = [contributor objectForKey:@"website"];
    NSString *githubLogin = [[contributor objectForKey:@"github"] objectForKey:@"login"];
    
    if ([website length] > 0) {
        return website;
    } else {
        if ([githubLogin length] > 0) {
            return [NSString stringWithFormat:@"https://github.com/%@", githubLogin];
        } else {
            return nil;
        }
    }
}

- (NSString *)getAvatarAddress:(NSDictionary *)contributor {
    // avatar_link > gravatar_email > github_avatar (github.id > github.login) > default
    NSString *avatarLink = [contributor objectForKey:@"avatar_link"];
    NSString *gravatarHash = [contributor objectForKey:@"gravatar_hash"];
    NSString *gravatarEmail = [contributor objectForKey:@"gravatar_email"];
    NSString *githubId = [[contributor objectForKey:@"github"] objectForKey:@"id"];
    NSString *githubLogin = [[contributor objectForKey:@"github"] objectForKey:@"login"];
    
    if ([avatarLink length] > 0) {
        return avatarLink;
    } else if ([gravatarHash length] > 0) {
        return [NSString stringWithFormat:@"https://www.gravatar.com/avatar/%@?&r=x&s=86", gravatarHash];
    } else if ([gravatarEmail length] > 0) {
        return [NSString stringWithFormat:@"https://www.gravatar.com/avatar/%@?&r=x&s=86", [[[[gravatarEmail dataUsingEncoding:NSUTF8StringEncoding] MD5Sum] hexString] lowercaseString]];
    } else if ([githubId length] > 0) {
        return [NSString stringWithFormat:@"https://avatars.githubusercontent.com/u/%@?v=3&s=86", githubId];
    } else if ([githubLogin length] > 0) {
        return [NSString stringWithFormat:@"https://avatars.githubusercontent.com/%@?v=3&s=86", githubLogin];
    } else {
        return @"https://www.gravatar.com/avatar/?f=y&d=mm&s=86";
    }
}

- (void)openGithubRepo {
    NSURL *url = [NSURL URLWithString:self.githubRepoLink];
    
    if ([SFSafariViewController class] != nil) {
        // Open in SFSafariViewController
        SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:url];
        [self presentViewController:safariViewController
                           animated:YES
                         completion:nil];
    } else {
        // Open in Mobile Safari
        if (![[UIApplication sharedApplication] openURL:url]) {
            NSLog(@"%@%@",@"Failed to open url:", [url description]);
        }
    }
}

- (void)viewDidLoad {
    [self configuration];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.githubRepoLink != nil) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ToolButton-GitHub_Filled.png"]
                                                                    landscapeImagePhone:nil
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(openGithubRepo)];
    }
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
