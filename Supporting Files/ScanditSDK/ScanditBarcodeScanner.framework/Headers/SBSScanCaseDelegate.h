//
//  SBSScanCaseDelegate.h
//  ScanditBarcodeScanner
//
//  Created by Luca Torella on 17/02/16.
//  Copyright © 2016 Scandit AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBSScanCaseState.h"

@class SBSScanCase, SBSScanCaseSession;

/**
 * \brief Calls the Protocol for events fired by SBSScanCase, e.g. when new codes are scanned.
 *
 * Classes implementing the SBSScanCaseDelegate protocol receive barcode/2D code scan events whenever
 * a new code has been scanned. 
 * The class implementing the protocol also gets notified when SBSScanCase has completed initialization,
 * and when SBSScanCase::state is changed.
 *
 * \ingroup scanditsdk-ios-api
 * \since 4.13.0
 */
@protocol SBSScanCaseDelegate

/**
 * \brief Method invoked when SBSScanCase has finished the initialization.
 *
 * This method is called on the SBSScanCase#delegate as soon as SBSScanCase has completed
 * the initialization process and the scanner is ready to be used. 
 * At this point the SBSScanCase::state is SBSScanCaseStandby.
 *
 * \param scanCase The scan case initialized.
 *
 * This method is invoked from a scan-case-internal dispatch queue. To perform UI work, you must
 * dispatch to the main queue first.
 */
- (void)didInitializeScanCase:(nonnull SBSScanCase *)scanCase;

/**
 * \brief Method invoked whenever a new code is scanned.
 *
 * This method is called on the SBSScanCase#delegate whenever the barcode scanner has
 * recognized new barcodes/2D codes. The newly recognized codes can be retrieved from the scan
 * session's SBSScanCaseSession#newlyRecognizedCodes property.
 *
 * \param scanCase The scan case on which codes were scanned.
 * \param session The current scan session containing the state of the recognition
 *     process, e.g. the list of codes recognized in the last processed frame. The scan session
 *     can only be accessed from within this method. It is however possible to use codes returned
 *     by SBSScanSession#newlyRecognizedCodes outside this method.
 *
 * \return The new state for the scan case; e.g. return SBSScanCaseStateActive if you want to keep scanning,
 *     or return SBSScanCaseStateStandby if you want to pause the scanner.
 *
 * This method is invoked from a scan-case-internal dispatch queue. To perform UI work, you must
 * dispatch to the main queue first.
 */
- (SBSScanCaseState)scanCase:(nonnull SBSScanCase *)scanCase
                     didScan:(nonnull SBSScanCaseSession *)session;

/**
 * \brief Method invoked whenever SBSScanCase::state changed.
 *
 * This method is called on the SBSScanCase#delegate whenever SBSScanCase::state changes.
 *
 * \param scanCase The scan case on which codes were scanned.
 * \param state The new state of the scan case.
 * \param reason The reason for the state change.
 *
 * This method is invoked from a scan-case-internal dispatch queue. To perform UI work, you must
 * dispatch to the main queue first.
 */
- (void)scanCase:(nonnull SBSScanCase *)scanCase
  didChangeState:(SBSScanCaseState)state
          reason:(SBSScanCaseStateChangeReason)reason;

@end
