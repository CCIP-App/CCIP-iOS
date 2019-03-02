//
//  WebServiceEndPoint.h
//  GatewayWebService
//
//  Created by 腹黒い茶 on 2016/06/24.
//  Copyright © 2016年 CPRTeam. All rights reserved.
//

#define __TIMEOUT_INTERVAL__    (15)


#define __API_HOST__            ([Constants URL_SERVER_BASE])

#define CC_STATUS(token)        ([__API_HOST__ stringByAppendingFormat:@"/status?token=%@", token])
#define CC_USE(token, scenario) ([__API_HOST__ stringByAppendingFormat:@"/use/%@?token=%@", scenario, token])
#define CC_ANNOUNCEMENT         ([__API_HOST__ stringByAppendingFormat:@"/announcement"])
#define CC_LANDING(token)       ([__API_HOST__ stringByAppendingFormat:@"/landing?token=%@", token])

#define WEB_TOKEN(url, token)   ([NSString stringWithFormat:url, token])

// Cache

#define SCHEDULE_CACHE_CLEAR    (@"ClearScheduleContentCache")
#define SCHEDULE_CACHE_KEY      (@"ScheduleContentCache")
