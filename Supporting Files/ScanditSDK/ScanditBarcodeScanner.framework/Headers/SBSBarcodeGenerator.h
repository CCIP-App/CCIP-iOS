//
//  SBSBarcodeGenerator.h
//  ScanditBarcodeScanner
//
//  Created by Tibor Molnár on 13/07/2018.
//  Copyright © 2018 Scandit AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBSCode.h"

/**
 * \brief Enumeration of different error types related to the \class SBSBarcodeGenerator.
 *
 * \since 5.9.0
 */
SBS_ENUM_BEGIN(SBSGeneratorError){
    SBSGeneratorErrorEmptyInput,
    SBSGeneratorErrorInvalidOptionsObject,
    SBSGeneratorErrorNullContextGiven
} SBS_ENUM_END(SBSGeneratorError);

NS_ASSUME_NONNULL_BEGIN

/**
 * \brief The NSError domain of the SBSBarcodeGenerator related errors.
 *
 * \since 5.9.0
 */
FOUNDATION_EXPORT NSString *const SBSGeneratorErrorDomain;

@class SBSEncodingRange;

/**
 * \brief A barcode generator
 *
 * \since 5.9.0
 */
@interface SBSBarcodeGenerator : NSObject

/**
 * \brief Generates a UIImage instance holding the encoded data.
 *
 * \param string the string to be encoded. Can be nil.
 * \param outError the error object. Upon failure, it's contents will be filled. Can be nil.
 *
 * \return the encoded data as a UIImage or nil if there was an error.
 *
 * \since 5.9.0
 */
- (nullable UIImage *)generateFromString:(nullable NSString *)string error:(NSError *_Nullable *_Nullable)outError;

/**
 * \brief Generates a UIImage instance holding the encoded data.
 *
 * \param data the NSData to be encoded. Can be nil.
 * \param outError the error object. Upon failure, it's contents will be filled. Can be nil.
 *
 * \return the encoded data as a UIImage or nil if there was an error.
 *
 * \since 5.9.0
 */
- (nullable UIImage *)generateFromData:(nullable NSData *)data error:(NSError *_Nullable *_Nullable)outError;

/**
 * \brief Generates a UIImage instance holding the encoded data.
 *
 * \param data the NSData to be encoded. Can be nil.
 * \param encodings the NSArray of SBSEncodingRange instances. Can be nil.
 * \param outError the error object. Upon failure, it's contents will be filled. Can be nil.
 *
 * \return the encoded data as a UIImage or nil if there was an error.
 *
 * \since 5.9.0
 */
- (nullable UIImage *)generateFromData:(nullable NSData *)data
                             encodings:(nullable NSArray<SBSEncodingRange *> *)encodings
                                 error:(NSError *_Nullable *_Nullable)outError;

/**
 * \brief Sets the given options to the generator enine.
 *
 * \param options the NSDictionary of options. Cannot be nil.
 * \param outError the error object. Upon failure, it's contents will be filled. Can be nil.
 *
 * \return YES if the operation was successful. NO upon failure.
 *
 * \since 5.9.0
 */
- (BOOL)setOptions:(NSDictionary<NSString *, id> *)options error:(NSError *_Nullable *_Nullable)outError;

@end

NS_ASSUME_NONNULL_END
