//
//  WebServiceEndPoint.h
//  GatewayWebService
//
//  Created by 腹黒い茶 on 2016/06/24.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#define __TIMEOUT_INTERVAL__    (15)

#define __API_HOST__            (@"https://coscup.cprteam.org/")
#define CC_STATUS(token)        ([__API_HOST__ stringByAppendingFormat:@"status?token=%@", token])
#define CC_USE(token, scenario) ([__API_HOST__ stringByAppendingFormat:@"use/%@?token=%@", scenario, token])
#define CC_ANNOUNCEMENT         ([__API_HOST__ stringByAppendingFormat:@"announcement"])
#define CC_LANDING(token)       ([__API_HOST__ stringByAppendingFormat:@"landing?token=%@", token])

#define COSCUP_WEB_URL          (@"https://coscup.org")
#define ROOM_DATA_URL           (@"https://coscup.org/2016-assets/json/room.json")
#define PROGRAM_DATA_URL        (@"https://coscup.org/2016-assets/json/program.json")
#define PROGRAM_TYPE_DATA_URL   (@"https://coscup.org/2016-assets/json/type.json")
#define SPONSOR_LEVEL_URL       (@"https://coscup.org/2016-assets/json/level.json")
#define SPONSOR_LIST_URL        (@"https://coscup.org/2016-assets/json/sponsor.json")

#define STAFF_DATA_URL          (@"https://staff.coscup.org/api/staffgroups/?format=json")

#define LOG_BOT_URL             (@"https://ysitd.licson.net/channel/coscup/today")
