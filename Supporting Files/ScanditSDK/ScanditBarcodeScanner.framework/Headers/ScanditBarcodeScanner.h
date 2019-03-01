//
//  ScanditBarcodeScanner.h
//  ScanditBarcodeScanner
//
//  Created by Moritz Hartmeier on 22/05/15.
//  Copyright (c) 2015 Scandit AG. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * \brief Current Version of the Scandit BarcodeScanner framework
 *
 * The version string has the format $major.$minor.$patch$suffix, where suffix may be an
 * empty string, or indicate a pre-release version, e.g. BETA1.
 */
FOUNDATION_EXPORT const unsigned char* ScanditBarcodeScannerVersionString;

#import <ScanditBarcodeScanner/SBSBarcodePickerManager.h>
#import <ScanditBarcodeScanner/SBSLicense.h>
#import <ScanditBarcodeScanner/SBSCode.h>
#import <ScanditBarcodeScanner/SBSTrackedCode.h>
#import <ScanditBarcodeScanner/SBSBarcodePickerView.h>
#import <ScanditBarcodeScanner/SBSOverlayController.h>
#import <ScanditBarcodeScanner/SBSScanSession.h>
#import <ScanditBarcodeScanner/SBSScanSettings.h>
#import <ScanditBarcodeScanner/SBSSymbologySettings.h>
#import <ScanditBarcodeScanner/SBSBarcodePicker.h>
#import <ScanditBarcodeScanner/SBSPropertyObserver.h>
#import <ScanditBarcodeScanner/SBSScanCaseState.h>
#import <ScanditBarcodeScanner/SBSScanCaseDelegate.h>
#import <ScanditBarcodeScanner/SBSScanCase.h>
#import <ScanditBarcodeScanner/SBSScanCaseSession.h>
#import <ScanditBarcodeScanner/SBSScanCaseSettings.h>
#import <ScanditBarcodeScanner/SBSParserTools.h>
#import <ScanditBarcodeScanner/SBSParserField.h>
#import <ScanditBarcodeScanner/SBSParserResult.h>
#import <ScanditBarcodeScanner/SBSEncodingRange.h>
#import <ScanditBarcodeScanner/SBSBarcodeGenerator.h>
