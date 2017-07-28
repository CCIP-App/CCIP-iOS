//
//  ScheduleFavoriteDelegate.h
//  CCIP
//
//  Created by 腹黒い茶 on 2017/07/25.
//  Copyright © 2017年 CPRTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ScheduleFavoriteDelegate <NSObject>

- (NSString *)getID:(NSDictionary *)program;
- (void)actionFavorite:(NSString *)scheduleId;
- (BOOL)hasFavorite:(NSString *)scheduleId;

@end
