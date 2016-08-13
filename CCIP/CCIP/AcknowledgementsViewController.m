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

@interface AcknowledgementsViewController ()

@end

@implementation AcknowledgementsViewController

- (instancetype)init {
    NSMutableArray *contributors = [NSMutableArray new];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Project_Info_and_Contributors" ofType:@"json"];
    NSString *projectInfoJSON = [[NSString alloc] initWithContentsOfFile:filePath
                                                                encoding:NSUTF8StringEncoding
                                                                   error:NULL];
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
    
    CPDAcknowledgementsViewController *acknowledgementsViewController = [[CPDAcknowledgementsViewController alloc] initWithStyle:nil acknowledgements:nil contributions:contributors];
    
    self = (AcknowledgementsViewController*)acknowledgementsViewController;
    
    return self;
}

- (NSString *)getWebsiteAddress:(NSDictionary *)contributor {
    // website > github_site(github.login) > nil
    NSString *website = [contributor objectForKey:@"website"];
    NSString *githubLogin = [[contributor objectForKey:@"github"] objectForKey:@"login"];
    
    if ([website length] > 0) {
        return website;
    }
    else
        if ([githubLogin length] > 0) {
        return [NSString stringWithFormat:@"https://github.com/%@", githubLogin];
    }
    else {
        return nil;
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
    }
    else if ([gravatarHash length] > 0) {
        return [NSString stringWithFormat:@"https://www.gravatar.com/avatar/%@?&r=x&s=86", gravatarHash];
    }
    else if ([gravatarEmail length] > 0) {
        return [NSString stringWithFormat:@"https://www.gravatar.com/avatar/%@?&r=x&s=86", [[[[gravatarEmail dataUsingEncoding:NSUTF8StringEncoding] MD5Sum] hexString] lowercaseString]];
    }
    else if ([githubId length] > 0) {
        return [NSString stringWithFormat:@"https://avatars.githubusercontent.com/u/%@?v=3&s=86", githubId];
    }
    else if ([githubLogin length] > 0) {
        return [NSString stringWithFormat:@"https://avatars.githubusercontent.com/%@?v=3&s=86", githubLogin];
    }
    else {
        return @"https://www.gravatar.com/avatar/?f=y&d=mm&s=86";
    }
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
