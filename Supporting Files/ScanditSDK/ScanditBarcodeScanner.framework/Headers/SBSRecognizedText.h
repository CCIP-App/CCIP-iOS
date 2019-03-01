//
//  SBSRecognizedText.h
//  ScanditBarcodeScanner
//
//  Created by Marco Biasini on 03/10/16.
//  Copyright © 2016 Scandit AG. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * \brief Represents text recognized in a frame.
 *
 * This class is the main result object of the OCR engine.
 */
@interface SBSRecognizedText : NSObject

/**
 * \brief The recognized text
 */
@property (nonnull, strong, nonatomic) NSString *text;

/**
 * \brief Whether this code is rejected or not.
 *
 * If beeping/vibration is enabled, the device will beep and vibrate whenever text has been 
 * recognized. Set this property to YES to suppress beeping/vibration. Use this functionality if you
 * want to perform additional checks on the recognized text that can not be expressed through a 
 * regular expression.
 */
@property (nonatomic, assign) BOOL rejected;

@end
