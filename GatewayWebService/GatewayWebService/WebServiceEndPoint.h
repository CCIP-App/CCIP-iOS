//
//  WebServiceEndPoint.h
//  GatewayWebService
//
//  Created by 腹黒い茶 on 2016/06/24.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#define __TIMEOUT_INTERVAL__    (15)

#define __API_HOST__            (@"https://ccip.cprteam.org/")
#define CC_STATUS(token)        ([__API_HOST__ stringByAppendingFormat:@"status?token=%@", token])
#define CC_USE(token, scenario) ([__API_HOST__ stringByAppendingFormat:@"use/%@?token=%@", scenario, token])

#define ROOM_DATA_URL           (@"https://coscup.org/2016-assets/json/room.json")
#define PROGRAM_DATA_URL        (@"https://coscup.org/2016-assets/json/program.json")
#define PROGRAM_TYPE_DATA_URL   (@"https://coscup.org/2016-assets/json/type.json")

#define STAFF_DATA_URL          (@"https://staff.coscup.org/api/staffgroups/?format=json")

#define LOG_BOT_URL             (@"https://logbot.g0v.tw/channel/coscup/today")
