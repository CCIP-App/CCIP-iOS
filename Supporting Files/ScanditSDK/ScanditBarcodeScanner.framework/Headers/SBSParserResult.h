//------------------------------------------------------------------------------------------------//
//                        This file is part of the Scandit Parsing Library                        //
//                                                                                                //
//                   Copyright (c) 2016-2017 Scandit AG. All rights reserved                      //
//------------------------------------------------------------------------------------------------//

#import <Foundation/Foundation.h>
#import "SBSParserField.h"
#import "SBSCommon.h"

/**
 * \brief Holds the result of a successfully parsed data string
 *
 * The result can be accessed in one of many ways:
 *
 * - Through an array of parser fields. The order of the fields in the array matches the order of
 *   how they appear in the data.
 * - Through a dictionary (fieldsByName).
 * - through a jsonString.
 *
 * The fields contained in the result are different for each type of parser. Consult the
 * <a href="http://docs.scandit.com/parser/formats.html">format documentation</a> for more
 * information.
 *
 * \since 5.6
 */
@interface SBSParserResult : NSObject

/**
 * \brief The result object as a serialized JSON string
 *
 * \since 5.6
 */
@property (nonatomic, readonly, nonnull) NSString *jsonString;
@property (nonatomic, readonly, nonnull) NSDictionary<NSString *, SBSParserField *> *fieldsDict SBS_DEPRECATED_MSG_ATTRIBUTE("Use fieldsByName instead.");
@property (nonatomic, readonly, nonnull) NSArray<SBSParserField *> *fieldsArray SBS_DEPRECATED_MSG_ATTRIBUTE("Use fields instead.");
/**
 * \brief The fields contained in the result as a dictionary
 *
 * The entries in the dictionary map the field name to the parser field.
 *
 * \since 5.6
 */
@property (nonatomic, readonly, nonnull) NSDictionary<NSString *, SBSParserField *> *fieldsByName;

/**
 * \brief The fields contained in the result as an array.
 *
 * The order of the fields in array depends on the order of the fields in the input data.
 *
 * \since 5.6
 */
@property (nonatomic, readonly, nonnull) NSArray<SBSParserField *> *fields;

@end
