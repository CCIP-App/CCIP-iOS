//
//  SBSScanCaseState.h
//  ScanditBarcodeScanner
//
//  Created by Luca Torella on 17/02/16.
//  Copyright © 2016 Scandit AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBSCommon.h"

/**
 * Enumerates the possible state for the scan case
 *
 * \ingroup scanditsdk-ios-api
 * \since 4.13.0
 */
SBS_ENUM_BEGIN(SBSScanCaseState) {
    /**
     * Camera is off, torch is off.
     */
    SBSScanCaseStateOff = 0,
    /**
     * Camera is on but with throttled frame-rate, scanner is off, torch is off.
     */
    SBSScanCaseStateStandby = 1 << 0,
    /**
     * Camera is on, scanner is on, torch is on.
     */
    SBSScanCaseStateActive = 1 << 1,
} SBS_ENUM_END(SBSScanCaseState);

/**
 * Enumerates the possible reasons for which the scan case state has changed
 *
 * \ingroup scanditsdk-ios-api
 * \since 4.13.0
 */
SBS_ENUM_BEGIN(SBSScanCaseStateChangeReason) {
    /**
     * The state was changed directly.
     */
    SBSScanCaseStateChangeReasonManual = 0,
    /**
     * The change of state was driven by a timeout.
     */
    SBSScanCaseStateChangeReasonTimeout = 1 << 0,
    /**
     * The change of state was driven by the volume button.
     */
    SBSScanCaseStateChangeReasonVolumeButton = 1 << 1,
} SBS_ENUM_END(SBSScanCaseStateChangeReason);
