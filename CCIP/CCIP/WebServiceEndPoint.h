//
//  WebServiceEndPoint.h
//  GatewayWebService
//
//  Created by 腹黒い茶 on 2016/06/24.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#define __TIMEOUT_INTERVAL__    (15)

#define __API_HOST__            (@"https://ccip.coscup.org/")
#define CC_STATUS(token)        ([__API_HOST__ stringByAppendingFormat:@"status?token=%@", token])
#define CC_USE(token, scenario) ([__API_HOST__ stringByAppendingFormat:@"use/%@?token=%@", scenario, token])
#define CC_ANNOUNCEMENT         ([__API_HOST__ stringByAppendingFormat:@"announcement"])
#define CC_LANDING(token)       ([__API_HOST__ stringByAppendingFormat:@"landing?token=%@", token])

#define COSCUP_BASE_URL         (@"https://coscup.org")
#define COSCUP_JSON_DATA(asset) ([COSCUP_BASE_URL stringByAppendingFormat:@"/2016-assets/json/%@.json", asset])
#define ROOM_DATA_URL           (COSCUP_JSON_DATA(@"room"))
#define PROGRAM_DATA_URL        (COSCUP_JSON_DATA(@"program"))
#define PROGRAM_TYPE_DATA_URL   (COSCUP_JSON_DATA(@"type"))
#define SPONSOR_LEVEL_URL       (COSCUP_JSON_DATA(@"level"))
#define SPONSOR_LIST_URL        (COSCUP_JSON_DATA(@"sponsor"))

#define STAFF_BASE_URL          (@"https://staff.coscup.org")
#define STAFF_DATA_URL          ([STAFF_BASE_URL stringByAppendingString:@"/api/staffgroups/?format=json"])
#define STAFF_AVATAR(avatar)    ([avatar containsString:@"http"] ? [NSString stringWithFormat:@"%@&s=200", avatar] : [STAFF_BASE_URL stringByAppendingString:avatar])

#define LOG_BOT_URL             (@"https://ysitd.licson.net/channel/coscup/today")
