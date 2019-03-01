//
//  SBSScanSession.h
//  BarcodeScanner
//
//  Created by Marco Biasini on 20/05/15.
//  Copyright (c) 2015 Scandit AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SBSCode;
@class SBSTrackedCode;

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
 * decoded less than 500ms ago, it is filtered out as a duplicate. The exact
 * filtering behavior can be changed by setting the "code duplicate filter", see
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
 * \brief Returns a dictionary representing a map between tracked object identifiers 
 *       and tracked objects.
 *
 * To toggle matrix scan use SBSScanSettings#matrixScanEnabled.
 *
 * \warning It will return nil when matrix scan is disabled.
 * \warning This property is meant to be used only in the session thread.
 *
 * \return a new copy of the dictionary of tracked objects that have been successfully tracked in 
 *    the last frame.
 *
 * \since 5.2
 */
@property (nullable, readonly, nonatomic, copy) NSDictionary<NSNumber *, SBSTrackedCode *> *trackedCodes;

/**
 * \brief Remove all codes from the scan session.
 *
 * Use this method to manually remove all codes from the scan session. Typicaly you 
 * will not have to this method directly but instead configure the duplicate removal 
 * and code caching duration through \ref SBSScanSettings
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
- (void)rejectCode:(nonnull SBSCode *)code;

/**
 * \brief The codes that should be visualized as rejected in the matrix scan view.
 *
 * Use this method to visually reject a certain code in the matrix scan API.
 * In order to use this feature it is necessary to enable SBSScanSettings#matrixScanEnabled
 * and set SBSOverlayController#guiStyle to SBSGuiStyleMatrixScan.
 *
 * \warning This property is meant to be used only in the session thread.
 * Additionally, you should only calls this method from 
 * SBSProcessFrameDelegate#barcodePicker:didProcessFrame:session:.
 *
 * \param trackedCode The tracked code to visually reject
 *
 * \since 5.2
 */
- (void)rejectTrackedCode:(nonnull SBSTrackedCode *)trackedCode;

@end
