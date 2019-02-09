//
//  SBSScanSession.h
//  BarcodeScanner
//
//  Created by Marco Biasini on 20/05/15.
//  Copyright (c) 2015 Scandit AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBSCode.h"

/**
 * \brief Holds all barcodes that were decoded in the current session.
 *
 * <h2>Configuring Session Behaviour</h2>
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
 * decoded less than 500ms ago, it is filtered out as a duplicate. The exact
 * filtering behaviour can be changed by setting the "code duplicate filter", see
 * \ref SBSScanSettings#codeDuplicateFilter for details.
 *
 * <h2>Session Lifetime</h2>
 *
 * The session is cleared when \ref SBSBarcodePicker#startScanning is called,
 * or when the user manually clears the session using 
 * \ref SBSScanSession#clear.
 */
@interface SBSScanSession : NSObject

/**
 * \brief A new copy of the list of barcodes that have been successfully decoded in the last frame.
 */
@property (nonnull, readonly, nonatomic, copy) NSArray* newlyRecognizedCodes;

/**
 * \brief A new copy of the list of barcodes that have been localized but not
 * recognized in the last frame.
 */
@property (nonnull, readonly, nonatomic, copy) NSArray* newlyLocalizedCodes;

/**
 * \brief Returns the list of  barcodes (data, symbology) that have been decoded
 * (recognized) in this session.
 *
 * Depending on the code caching and duplicate filtering behaviour, different
 * sets of codes are returned by this method.
 *
 * \see SBSScanSettings#codeDuplicateFilter
 * \see SBSScanSettings#codeCachingDuration
 *
 * @return a new copy of the list of barcodes that have been successfully
 * decoded in this session
 */
@property (nonnull, readonly, nonatomic, copy) NSArray* allRecognizedCodes;

/**
 * \brief Remove all codes from the scan session
 *
 * Use this method to manually remove all codes from the scan session. Typicaly you 
 * will not have to this method directly but instead configure the duplicate removal 
 * and code caching duration with through \ref SBSScanSettings
 */
- (void)clear;

/**
 * \brief Immediately pauses barcode recognition, but keeps camera preview open.
 *
 * This is useful for briefly pausing the barcode recognition to show the
 * recognized code in an overlay and then resume the scan process to scan
 * more codes.
 *
 * When only scanning one code and then returning to another part of the
 * application, it is recommended to call \ref stopScanning instead.
 *
 * Pausing will not clear the scan session. To remove all codes from the
 * scan session call \ref clear.
 */
- (void)pauseScanning;

/**
 * \brief Immediately stop barcode recognition and close camera.
 *
 * Use this method when you finished scanning barcodes. In case you want to only 
 * briefly pause barcode recognition, use #pauseScanning instead.
 */
- (void)stopScanning;

/**
 * \brief Prevent beeping/vibrate and highlighting for a particular code.
 *
 * Use this method to reject a certain code if you have additional methods for 
 * verifying the integrity of the code, e.g. with a custom checksum. Rejected 
 * codes won't be highlighted in the scan UI. Additionally beep and vibration 
 * will be surpressed.
 *
 * For this feature to work, you will have to enable code rejection by setting
 * \ref SBSScanSettings::codeRejectionEnabled to YES.
 *
 * Rejected codes will be added to allRecognizedCodes like all other codes.
 *
 * Note that you should only pass codes returned by \ref newlyRecognizedCodes, 
 * as passing any other code will have no effect. Additionally, you should only 
 * calls this method from SBSScanDelegate::barcodePicker:didScan:.
 *
 * \param code The code to reject
 *
 * \since 4.15
 */
- (void)rejectCode:(nonnull SBSCode*)code;

@end
