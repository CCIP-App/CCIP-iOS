//------------------------------------------------------------------------------------------------//
//                        This file is part of the Scandit Parsing Library                        //
//                                                                                                //
//                   Copyright (c) 2016-2017 Scandit AG. All rights reserved                      //
//------------------------------------------------------------------------------------------------//

#import <Foundation/Foundation.h>

#import "SBSCommon.h"

SBS_ENUM_BEGIN(SBSTransformationError) {
    SBSTransformationErrorTransformation,
    SBSTransformationInvalidJsonObject
} SBS_ENUM_END(SBSTransformationError);


@class SBSTransformationData;

@interface SBSTransformation : NSObject

+ (nullable instancetype)transformationFromJson:(nonnull NSString *)json
                                          error:(NSError * _Nullable * _Nullable)outError;

- (nullable SBSTransformationData *)transform:(nonnull NSArray<SBSTransformationData *> *)inputs
                                        error:(NSError * _Nullable * _Nullable)outError;

@end
