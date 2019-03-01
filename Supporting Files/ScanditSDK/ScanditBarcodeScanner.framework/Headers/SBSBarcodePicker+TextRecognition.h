//
//  SBSBarcodePicker+TextRecognition.h
//  ScanditBarcodeScanner
//
//  Created by Marco Biasini on 03/10/16.
//  Copyright © 2016 Scandit AG. All rights reserved.
//

#include "SBSBarcodePicker.h"

#include "SBSTextRecognitionDelegate.h"

@interface SBSBarcodePicker (TextRecognition)

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
@property (nullable, weak, nonatomic) id<SBSTextRecognitionDelegate> textRecognitionDelegate;

@end
