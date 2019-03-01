//------------------------------------------------------------------------------------------------//
//                        This file is part of the Scandit Parsing Library                        //
//                                                                                                //
//                   Copyright (c) 2016-2017 Scandit AG. All rights reserved                      //
//------------------------------------------------------------------------------------------------//

#import <Foundation/Foundation.h>

/**
 * \brief A particular parsed field
 *
 * \since 5.6
 */
@interface SBSParserField : NSObject

/**
 * \brief The name of the field
 *
 * \since 5.6
 */
@property (nonatomic, readonly, nonnull) NSString *name;

/**
 * \brief The parsed value of the field.
 *
 * Depending on the field type, the returned object is a NSNumber, NSString. NSArray or NSDictionary.
 * Consult the format documentation for more details.
 *
 * \since 5.6
 */
@property (nonatomic, readonly, nullable) id parsed;

/**
 * \brief The rawString of the field, e.g. as it appears in the data.
 *
 * \since 5.6
 */
@property (nonatomic, readonly, nonnull) NSString *rawString;

@end
