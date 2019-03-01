//------------------------------------------------------------------------------------------------//
//                        This file is part of the Scandit Parsing Library                        //
//                                                                                                //
//                   Copyright (c) 2016-2017 Scandit AG. All rights reserved                      //
//------------------------------------------------------------------------------------------------//

#import <Foundation/Foundation.h>

#import "SBSCommon.h"


/**
 * \brief An enumeration of possible reasons for failure
 *
 * \since 5.6
 */
SBS_ENUM_BEGIN(SBSParserError) {
    /**
     * \brief The parser failed
     *
     * \since 5.6
     */
    SBSParserErrorParser,
    
    /**
     * \brief The provided data object is invalid
     *
     * \since 5.6
     */
    SBSParserErrorInvalidDateObject,
    
    /**
     * \brief The provided date only uses two digits for the year, so it can't be unambigously be
     * converted to a NSDate.
     *
     * \since 5.6
     */
    SBSParserErrorTwoDigitDateObject,
    
    /**
     * \brief The provided options object is invalid.
     *
     * \since 5.6
     */
    SBSParserErrorInvalidOptionsObject
} SBS_ENUM_END(SBSParserError);

@class SBSParserResult;

/**
 * \brief Defines the interface for a data string parser. Parsers are capable of parsing one
 *     particular data format, which is passed to them during construction.
 *
 * The parser is created through SBSBarcodePicker#parserForFormat:error:. Note that you need to have
 * a valid license to use the parser feature.
 *
 * For documentation on the available formats, go to the
 * <a href="http://docs.scandit.com/parser/index.html">official parser library documentation</a>.
 *
 * \since 5.6
 */
@interface SBSParser : NSObject

/**
 * \brief Parses the data string and returns the contained fields in the result object. In case the
 *     result could not be parsed, the error message is accessible as part of the outError parameter.
 *
 * \param string The string to parse. Must not be nil.
 * \param outError Upon failure will be set to an instance of NSError containing details on why the
 *     data could not be parsed. Can be nil.
 * \returns The result object. Before accessing the fields of the result, you must ensure that the
 *     string was correctly parsed, that is, outError has not been set.
 *
 * \since 5.6
 */
- (nullable SBSParserResult *)parseString:(nonnull NSString *)string
                                    error:(NSError * _Nullable * _Nullable)outError;

/**
 * \brief Parses the raw data and returns the contained fields in the result object. In case the
 *     result could not be parsed, the error message is accessible as part of the outError parameter.
 *
 * Use this variant for binary formats that can't safely be represented as unicode code points.
 *
 * \param data The data to parse. Must not be nil.
 * \param outError Upon failure will be set to an instance of NSError containing details on why the
 *     data could not be parsed. Can be nil.
 * \returns The result object. Before accessing the fields of the result, you must ensure that the
 *     string was correctly parsed, that is, outError has not been set.
 *
 * \since 5.6
 */
- (nullable SBSParserResult *)parseRawData:(nonnull NSData *)data
                                     error:(NSError * _Nullable * _Nullable)outError;

/**
 * \brief Apply the option map to the parser, allowing the user to fine-tune the behavior of the
 *      parser.
 *
 * Available options depend on the data format and are specified in the respective documentation. If
 * the case that the options object is invalid and the operation fails, the error message is
 * accessible as part of the outError parameter.
 *
 * \param opts The options dictionary. Must not be nil.
 * \param outError Upon failure will be set to an instance of NSError containing details on why the
 *      operation failed. Can be nil.
 *
 * \since 5.6
 */
- (BOOL)setOptions:(nonnull NSDictionary *)opts error:(NSError * _Nullable * _Nullable)outError;

@end
