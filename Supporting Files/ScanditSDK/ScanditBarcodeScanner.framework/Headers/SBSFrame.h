//
//  SBSFrame.h
//  ScanditBarcodeScanner
//
//  Created by Luca Torella on 14.03.18.
//  Copyright © 2018 Scandit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

@class SBSTrackedCode;
@class SBSScanSession;

NS_ASSUME_NONNULL_BEGIN

/**
 * \brief An extended abstraction of a frame that is being processed by the \link SBSMatrixScanHandler\endlink.
 *
 * The SBSFrame holds more
 * advanced data computed by the \link SBSMatrixScanHandler\endlink, e.g. \link SBSFrame#addedIdentifiers\endlink, \link
 * SBSFrame#scanSession\endlink, etc.
 *
 * All the class members are public to allow easy access to the data carried by the SBSFrame.
 *
 * \since 5.9.0
 */
@interface SBSFrame : NSObject

/**
 * \brief A set of tracked barcodes' identifiers that have been added while processing this SBSFrame.
 * \since 5.9.0
 */
@property (nonatomic, strong, readonly) NSSet<NSNumber *> *addedIdentifiers;

/**
 * \brief A set of tracked barcodes' identifiers that have been removed while processing this SBSFrame.
 * \since 5.9.0
 */
@property (nonatomic, strong, readonly) NSSet<NSNumber *> *removedIdentifiers;

/**
 * \brief A set of tracked barcodes' identifiers that have been updated while processing this SBSFrame.
 * \since 5.9.0
 */
@property (nonatomic, strong, readonly) NSSet<NSNumber *> *updatedIdentifiers;

/**
 * \brief All tracked barcodes as a dictionary.
 *
 * The entries in the dictionary map barcode's identifier to the tracked barcode itself.
 *
 * \since 5.9.0
 */
@property (nonatomic, strong, readonly) NSDictionary<NSNumber *, SBSTrackedCode *> *trackedCodes;

/**
 * \brief Current Scan Session.
 * \since 5.9.0
 */
@property (nonatomic, weak, nullable, readonly) SBSScanSession *scanSession;

@end

NS_ASSUME_NONNULL_END
