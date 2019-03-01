//
//  SBSBarcodePicker.h
//  ScanditBarcodeScanner
//
//  Created by Marco Biasini on 09/06/15.
//  Copyright (c) 2015 Scandit AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>

#import "SBSOverlayController.h"
#import "SBSScanSettings.h"


/**
 * \brief Implements the base functionality for the pre-4.7 and 4.7+ picker.
 */
@interface SBSBarcodePickerBase : UIViewController

/** \name Barcode Decoder Operation
 */
///\{

/**
 * \brief Returns YES if scanning is in progress.
 *
 * \since 1.0.0
 *
 * \return boolean indicating whether scanning is in progress.
 */
- (BOOL)isScanning;

///\}

/** \name Camera Selection
 */
///\{

/**
 * \brief Returns whether the specified camera facing direction is supported by the current device.
 *
 * \since 3.0.0
 *
 * \param facing The camera facing direction in question.
 * \return Whether the camera facing direction is supported
 */
- (BOOL)supportsCameraFacing:(SBSCameraFacingDirection)facing;

/**
 * \brief Changes to the specified camera facing direction if it is supported.
 *
 * \since 3.0.0
 *
 * \param facing The new camera facing direction
 * \return Whether the change was successful
 */
- (BOOL)changeToCameraFacing:(SBSCameraFacingDirection)facing;

/**
 * \brief Changes to the opposite camera facing if it is supported.
 *
 * \since 3.0.0
 *
 * \return Whether the change was successful
 */
- (BOOL)switchCameraFacing;
///\}

/** \name Torch Control
 */
///\{
/**
 * \brief Switches the torch (if available) on or off programmatically.
 *
 * There is also a method in the ScanditSDKOverlayController to add a torch icon that the user can
 * click to activate the torch.
 *
 * \param on YES when the torch should be switched on, NO if the torch should be turned off.
 *
 * By default the torch switch is off.
 *
 * \since 2.0.0
 */
- (void)switchTorchOn:(BOOL)on;
///\}


/** \name Zoom control
 */
///\{
/**
 * Sets the zoom to the given percentage of the maximum analog zoom possible.
 *
 * \param zoom The percentage of the max zoom (between 0 and 1)
 * \return Whether setting the zoom was successful
 *
 * \since 4.7.0
 */
- (BOOL)setRelativeZoom:(float)zoom;
///\}


/**
 * \brief The facing direction of the used camera
 *
 * \since 2.0.0
 */
@property (readonly, nonatomic) SBSCameraFacingDirection cameraFacingDirection;

/**
 * \brief The orientation of the camera preview.
 *
 * The orientation of the camera preview. In general the preview's orientation will be as wanted,
 * but there may be cases where it needs to be set individually.
 * This does not change the orientation of the overlayed UI elements.
 *
 * Possible values are:
 * AVCaptureVideoOrientationPortrait, AVCaptureVideoOrientationPortraitUpsideDown,
 * AVCaptureVideoOrientationLandscapeLeft, AVCaptureVideoOrientationLandscapeRight
 */
@property (nonatomic, assign) AVCaptureVideoOrientation cameraPreviewOrientation;

/**
 * \brief Whether tapping on the screen should trigger an auto-focus.
 *
 * By default, the camera triggers an auto-focus whenever the user taps the screen. To disable
 * this feature, set this property to NO.
 */
@property (nonatomic, assign) BOOL autoFocusOnTapEnabled;

/**
 * \brief Whether pinch to zoom is enabled
 *
 * By default, the camera preview zoom factor can be changed by using a pinch gesture. To disable 
 * this feature, set this property to NO. The feature is only available on devices with iOS 7 and 
 * greater.
 *
 * \since 4.15
 */
@property (nonatomic, assign) BOOL pinchToZoomEnabled;


@end
