//
//  SBSEncodingRange.h
//  ScanditBarcodeScanner
//
//  Created by Tibor Molnár on 13/07/2018.
//  Copyright © 2018 Scandit AG. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * \brief An encoding range for the barcode generator. Specifies the encoding and the start and end index
 * of the data to be encoded to specify which range the encoding should be used.
 *
 * \since 5.9.0
 */
@interface SBSEncodingRange : NSObject

@property (nonatomic, readonly, strong) NSString *encoding;
@property (nonatomic, readonly) NSUInteger start;
@property (nonatomic, readonly) NSUInteger end;

/**
 * \brief Initialize the encoding range.
 *
 * \param encoding IANA encoding.
 * \param start The index at which the specified encoding should start being used.
 * \param end The index after which the specified encoding should no longed be used.
 *
 * \since 5.9.0
 */
- (instancetype)initWithEncoding:(NSString *)encoding start:(NSUInteger)start end:(NSUInteger)end;

@end

NS_ASSUME_NONNULL_END
