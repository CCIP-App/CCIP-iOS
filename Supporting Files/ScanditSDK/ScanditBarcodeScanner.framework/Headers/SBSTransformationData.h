//------------------------------------------------------------------------------------------------//
//                        This file is part of the Scandit Parsing Library                        //
//                                                                                                //
//                   Copyright (c) 2016-2017 Scandit AG. All rights reserved                      //
//------------------------------------------------------------------------------------------------//

#import <Foundation/Foundation.h>

@interface SBSTransformationData : NSObject

- (nonnull instancetype)initWithType:(nonnull NSString *)type
                          stringData:(nonnull NSString *)data
                            byteData:(nonnull NSData *)rawData;

@property (nonatomic, readonly, nonnull) NSString *type;
@property (nonatomic, readonly, nonnull) NSString *data;
@property (nonatomic, readonly, nonnull) NSData *rawData;

@end
