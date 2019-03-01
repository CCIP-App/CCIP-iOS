//------------------------------------------------------------------------------------------------//
//                        This file is part of the Scandit Parsing Library                        //
//                                                                                                //
//                   Copyright (c) 2016-2017 Scandit AG. All rights reserved                      //
//------------------------------------------------------------------------------------------------//

#import <Foundation/NSObjCRuntime.h>
#import "SBSCommon.h"

typedef NS_ENUM(NSUInteger, SBSParserDataFormat) {
    SBSParserDataFormatGS1AI SBS_SWIFT_NAME(gs1ai),
    SBSParserDataFormatHIBC SBS_SWIFT_NAME(hibc),
    SBSParserDataFormatDLID SBS_SWIFT_NAME(dlid),
    SBSParserDataFormatMRTD SBS_SWIFT_NAME(mrtd),
    SBSParserDataFormatSWISSQR SBS_SWIFT_NAME(swissqr),
};
