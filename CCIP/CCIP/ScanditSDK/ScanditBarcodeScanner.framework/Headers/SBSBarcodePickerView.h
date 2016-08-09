//
//  SBSBarcodePickerView.h
//  ScanditBarcodeScanner
//
//  Created by Moritz Hartmeier on 28/05/15.
//  Copyright (c) 2015 Scandit AG. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SBSBarcodePicker.h"


/**
 * \brief Wraps an SBSBarcodePicker instance, exposing simple settings through the Interface 
 * Builder.
 *
 * You can use this view directly in Interface Builder by creating a view and changing the class in
 * the Identity Inspector to SBSBarcodePickerView. In the Attribute Inspector you can then adjust
 * the enabled symbologies and other settings. By default all symbologies are turned off to avoid
 * unnecessary processing.
 *
 * \since 4.7.0
 */
@interface SBSBarcodePickerView : UIView

@property (nonatomic, assign) IBInspectable BOOL startOnLoad;

@property (nonatomic, assign) IBInspectable BOOL EAN13;
@property (nonatomic, assign) IBInspectable BOOL UPC12;
@property (nonatomic, assign) IBInspectable BOOL UPCE;
@property (nonatomic, assign) IBInspectable BOOL EAN8;
@property (nonatomic, assign) IBInspectable BOOL code39;
@property (nonatomic, assign) IBInspectable BOOL code93;
@property (nonatomic, assign) IBInspectable BOOL code128;
@property (nonatomic, assign) IBInspectable BOOL PDF417;
@property (nonatomic, assign) IBInspectable BOOL datamatrix;
@property (nonatomic, assign) IBInspectable BOOL QR;
@property (nonatomic, assign) IBInspectable BOOL ITF;
@property (nonatomic, assign) IBInspectable BOOL MSIPlessey;
@property (nonatomic, assign) IBInspectable BOOL GS1Databar;
@property (nonatomic, assign) IBInspectable BOOL GS1DatabarExpanded;
@property (nonatomic, assign) IBInspectable BOOL codabar;
@property (nonatomic, assign) IBInspectable BOOL aztec;
@property (nonatomic, assign) IBInspectable BOOL twoDigitAddOn;
@property (nonatomic, assign) IBInspectable BOOL fiveDigitAddOn;
@property (nonatomic, assign) IBInspectable BOOL code11;
@property (nonatomic, assign) IBInspectable BOOL maxiCode;
@property (nonatomic, assign) IBInspectable BOOL microPDF417;
@property (nonatomic, assign) IBInspectable BOOL code25;

@property (nonatomic, assign) IBInspectable BOOL uiBeep;
@property (nonatomic, assign) IBInspectable BOOL uiVibrate;
@property (nonatomic, assign) IBInspectable BOOL uiTorchButton;
@property (nonatomic, assign) IBInspectable BOOL uiCameraButton;

@property (nonatomic, assign) IBInspectable BOOL frontCamera;

@property (nullable, nonatomic, weak) IBOutlet id<SBSScanDelegate> scanDelegate;

@property (nonnull, nonatomic, strong, readonly) SBSBarcodePicker *viewController;

/**
 * \brief Returns YES if scanning is in progress.
 *
 * \since 4.7.0
 *
 * \return boolean indicating whether scanning is in progress.
 */
- (BOOL)isScanning;

/**
 * \brief Resume scanning codes
 *
 * Continue (resume) scanning barcodes after a previous call to #pauseScanning, or
 * SBSScanSession#pauseScanning. Calling #resumeScanning on a picker that was stopped with
 * #stopScanning, will not resume the scanning process.
 *
 * In contrast to startScanning, resumeScanning does not clear the current barcode scanner session.
 * Thus if you want accumulate the codes, use #pauseScanning/#resumeScanning, if you want to start
 * from an empty session, use #pauseScanning/#startScanning.
 *
 * \since 4.7.0
 */
- (void)resumeScanning;

/**
 * \brief Pause scanning but keep preview on
 *
 * This method pauses barcode/2D recognition but continues streaming preview images. Use this method
 * if you are interrupting barcode recognition for a short time and  want to continue scanning
 * barcodes/2D codes afterwards.
 *
 * Use #resumeScanning to continue scanning barcodes.
 *
 * \since 4.7.0
 */
- (void)pauseScanning;

/**
 * \brief Starts/restarts the scanning process.
 *
 * Start or continue scanning barcodes after the creation of the barcode picker or a previous call
 * to #pauseScanning, SBSScanSession#pauseScanning, #stopScanning or
 * SBSScanSession#stopScanning.
 *
 * In contrast to resumeScanning, startScanning clears the current barcode scanner session.
 *
 * \since 4.7.0
 */
- (void)startScanning;

/**
 * \brief Starts/restarts the camera and potentially the scanning process.
 *
 * Start or continue scanning barcodes after the creation of the barcode picker or a previous call
 * to #pauseScanning, SBSScanSession#pauseScanning, #stopScanning or
 * SBSScanSession#stopScanning.
 *
 * In contrast to resumeScanning, startScanning clears the current barcode scanner session.
 *
 * \param paused If YES the barcode/2D recognition is paused but the streaming of preview images is
 *        started. If NO both the barcode/2D recognition and the streaming of preview images are
 *        started.
 *
 * \since 4.7.0
 */
- (void)startScanningInPausedState:(BOOL)paused;

/**
 * \brief Stops the scanning process and closes the camera
 *
 * \see SBSBarcodePicker#stopScanning:
 *
 * \since 4.7.0
 */
- (void)stopScanning;


@end
