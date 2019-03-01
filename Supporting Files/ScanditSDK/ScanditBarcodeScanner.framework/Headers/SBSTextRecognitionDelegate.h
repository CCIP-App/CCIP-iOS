//
//  SBSTextRecognitionDelegate.h
//  ScanditBarcodeScanner
//
//  Created by Marco Biasini on 03/10/16.
//  Copyright © 2016 Scandit AG. All rights reserved.
//

#import "SBSCommon.h"
#import "SBSRecognizedText.h"
#import "SBSBarcodePicker.h"

/**
 * \brief Enumerations of possible barcode picker states. 
 *
 * The barcode picker can be in one of three different states: active, paused, or stopped.
 * When the picker is active, the camera preview is running and recognition is running. In paused
 * state, the camera preview is running, but not recognition takes place. In stopped state, neither 
 * the preview nor recognition are running.
 *
 * \since 5.1
 */
SBS_ENUM_BEGIN(SBSBarcodePickerState) {
    /**
     * \brief Camera preview is on, recognition is running.
     *
     * \since 5.1
     */
    SBSBarcodePickerStateActive = 0x01,
    
    /**
     * \brief Camera preview is on, recognition is not running.
     *
     * \since 5.1
     */
    SBSBarcodePickerStatePaused  = 0x02,
    
    /**
     * \brief Camera is not running, recognition is not running.
     *
     * \since 5.1
     */
    SBSBarcodePickerStateStopped = 0x04,
} SBS_ENUM_END(SBSBarcodePickerState);


@protocol SBSTextRecognitionDelegate

/**
 * Invoked when the text recognition engine has found text that matches the provided regular 
 * expression.
 *
 * \param picker The barcode picker that recognized the text.
 * \param text The recognized text.
 *
 * \returns The new state for the picker. To continue scanning more text, return 
 * \ref SBSBarcodePickerStateActive, to stop scanning, return \ref SBSBarcodePickerStateStopped, to 
 * put the picker into paused state, return \ref SBSBarcodePickerStatePaused.
 *
 * \return 5.1
 */
- (SBSBarcodePickerState)barcodePicker:(nonnull SBSBarcodePicker *)picker
                      didRecognizeText:(nonnull SBSRecognizedText *)text;

@end
