//
//  SBSScanCaseSession.h
//  ScanditBarcodeScanner
//
//  Created by Luca Torella on 17/02/16.
//  Copyright © 2016 Scandit AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SBSCode;

/**
 * \brief Holds all barcodes that were decoded in the current session.
 *
 * <h2>Configuring Session Behavior</h2>
 *
 * The scan session is responsible for determining the list of "relevant" barcodes
 * by filtering out duplicates. Depending on your app, different duplicate removal
 * is required. For some applications, only one barcode is required. The scanning
 * process is stopped as soon as one code is decoded. For other applications,
 * multiple codes are scanned after another. For example, a scanner at the cash
 * desk may need to scan multiple products. To avoid duplicates, the same barcode
 * should not be scanned in short succession. The same barcode (data, symbology)
 * should not count as a duplicate if encountered again after a few seconds.
 *
 * By default, if a barcode has the same symbology and data as code that was
 * decoded less than 1000ms ago, it is filtered out as a duplicate.
 *
 * <h2>Session Lifetime</h2>
 *
 * The session is cleared when \ref SBSScanCase state changes from \ref SBSScanCaseStateOff
 * to \ref SBSScanCaseStateActive, or when the user manually clears the session using
 * \ref SBSScanCaseSession#clear.
 */
@interface SBSScanCaseSession : NSObject

/**
 * \brief A new copy of the list of barcodes that have been successfully decoded in the last frame.
 */
@property (nonnull, readonly, nonatomic, copy) NSArray<SBSCode *> *newlyRecognizedCodes;

/**
 * \brief A new copy of the list of barcodes that have been localized but not
 * recognized in the last frame.
 */
@property (nonnull, readonly, nonatomic, copy) NSArray<SBSCode *> *newlyLocalizedCodes;

/**
 * \brief Returns the list of  barcodes (data, symbology) that have been decoded
 * (recognized) in this session.
 *
 * Depending on the code caching and duplicate filtering behavior, different
 * sets of codes are returned by this method.
 *
 * \see SBSScanSettings#codeDuplicateFilter
 * \see SBSScanSettings#codeCachingDuration
 *
 * \return a new copy of the list of barcodes that have been successfully
 * decoded in this session
 */
@property (nonnull, readonly, nonatomic, copy) NSArray<SBSCode *> *allRecognizedCodes;

/**
 * \brief Remove all codes from the scan session
 *
 * Use this method to manually remove all codes from the scan session. Typicaly you
 * will not have to this method directly but instead configure the duplicate removal
 * and code caching duration with through \ref SBSScanSettings
 */
- (void)clear;

@end
