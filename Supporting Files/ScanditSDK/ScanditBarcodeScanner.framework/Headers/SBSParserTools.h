//------------------------------------------------------------------------------------------------//
//                        This file is part of the Scandit Parsing Library                        //
//                                                                                                //
//                   Copyright (c) 2016-2017 Scandit AG. All rights reserved                      //
//------------------------------------------------------------------------------------------------//

#import <Foundation/Foundation.h>

@class SBSParserResult;

@interface SBSParserTools : NSObject

+ (nullable NSDate *)dateFromParsedObject:(nonnull id)parsed
                                    error:(NSError * _Nullable * _Nullable)outError;

@end
