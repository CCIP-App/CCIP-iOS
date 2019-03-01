//
//  SBSScanSettings+TextRecognition.h
//  ScanditBarcodeScanner
//
//  Created by Marco Biasini on 03/10/16.
//  Copyright © 2016 Scandit AG. All rights reserved.
//

#include "SBSCommon.h"
#include "SBSScanSettings.h"

#include "SBSTextRecognitionSettings.h"

/**
 * \brief Enumeration of supported recognition modes
 */
SBS_ENUM_BEGIN(SBSRecognitionMode) {
    /**
     * \brief Text recognition is enabled.
     *
     * \since 5.1
     */
    SBSRecognitionModeText = 0x01,
    
    /**
     * \brief Barcode/2d code recognition is enabled.
     *
     * \since 5.1
     */
    SBSRecognitionModeCode  = 0x02,

    /**
     * \brief Both text recognition and barcode/2d code recognition are enabled.
     *
     * \since 5.6
     */
    SBSRecognitionModeCodeAndText  = 0x04,
    
} SBS_ENUM_END(SBSRecognitionMode);

/**
 * SBSScanSettings features related to text recognition.
 */
@interface SBSScanSettings (TextRecognition)

/**
 * \brief The text recognition settings to be used.
 *
 * By default, the text recognition settings are set to nil. If you want to use the text recognition 
 * feature, you must set this property and configure the settings accordingly. 
 *
 * This feature is only available if you have text recognition enabled.
 *
 * \since 5.1
 */
@property (nullable, nonatomic, strong) SBSTextRecognitionSettings *textRecognitionSettings;

/**
 * \brief The recognition mode to use for the barcode picker
 * 
 * Use this property to programmatically switch between text and barcode recognition. By default, 
 * barcode recognition is on (\ref SBSRecognitionModeCode).
 *
 * \since 5.1
 */
@property (nonatomic, assign) SBSRecognitionMode recognitionMode;

@end
