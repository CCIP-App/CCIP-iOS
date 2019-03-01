//
//  FeedbackType.h
//  CCIP
//
//  Created by 腹黒い茶 on 2018/07/31.
//  Copyright © 2018 CPRTeam. All rights reserved.
//

typedef NS_ENUM(NSInteger, FeedbackType) {
    ImpactFeedbackHeavy = 0x00000001,
    ImpactFeedbackLight = 0x00000010,
    ImpactFeedbackMedium = 0x00000100,
    NotificationFeedbackSuccess = 0x00001000,
    NotificationFeedbackWarning = 0x00010000,
    NotificationFeedbackError = 0x00100000,
    SelectionFeedback = 0x01000000,
};
