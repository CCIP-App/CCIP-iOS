//
//  SBSBarcodePicker.h
//  ScanditBarcodeScanner
//
//  Created by Marco Biasini on 12/06/15.
//  Copyright (c) 2015 Scandit AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import "SBSBarcodeGenerator.h"
#import "SBSCommon.h"
#import "SBSParser.h"
#import "SBSParserDataFormat.h"


@class SBSScanSession;
@class SBSScanSettings;
@class SBSBarcodePicker;
@class SBSOverlayController;
@protocol SBSPropertyObserver;

/**
 * \brief Protocol for accessing the processed sample buffers
 *
 * \ingroup scanditsdk-ios-api
 * \since 4.7.0
 */
@protocol SBSProcessFrameDelegate

/**
 * \brief Method invoked whenever a frame has been processed by the barcode scanner
 *
 * This method is called on the SBSBarcodePicker#processFrameDelegate whenever the barcode
 * scanner has finished processing a frame.
 *
 * \param barcodePicker the barcode picker instance that processed the frame
 * \param frame the sample buffer containing the actual frame data.
 * \param session The current scan session containing the state of the recognition process,
 *     e.g. list of codes recognized in the last processed frame. The scan session
 *     can only be accessed from within this method. It is however possible to use codes returned
 *     by SBSScanSession#newlyRecognizedCodes outside this method.
 *
 * This method is invoked from a picker-internal dispatch queue. To perform UI work, you must
 * dispatch to the main queue first. When new codes have been recognized, this method is invoked
 * after SBSScanDelegate#barcodePicker:didScan is called on the SBSBarcodePicker#scanDelegate.
 */
- (void)barcodePicker:(nonnull SBSBarcodePicker *)barcodePicker
      didProcessFrame:(nonnull CMSampleBufferRef)frame
              session:(nonnull SBSScanSession *)session;

@end

/**
 * \brief Defines the Protocol for a scan event delegate
 *
 * Class implementing the SBSScanDelegate protocol receive barcode/2D code scan events whenever
 * a new code has been scanned.
 *
 * \ingroup scanditsdk-ios-api
 * \since 4.7.0
 */
@protocol SBSScanDelegate

/**
 * \brief Method invoked whenever a new code is scanned.
 *
 * This method is called on the SBSBarcodePicker#scanDelegate whenever the barcode scanner has
 * recognized new barcodes/2D codes. The newly recognized codes can be retrieved from the scan
 * session's SBSScanSession#newlyRecognizedCodes property.
 *
 * \param picker The barcode picker on which codes were scanned.
 * \param session The current scan session containing the state of the recognition
 *     process, e.g. the list of codes recognized in the last processed frame. The scan session
 *     can only be accessed from within this method. It is however possible to use codes returned
 *     by SBSScanSession#newlyRecognizedCodes outside this method.
 *
 * This method is invoked from a picker-internal dispatch queue. To perform UI work, you must
 * dispatch to the main queue first.
 */
- (void)barcodePicker:(nonnull SBSBarcodePicker *)picker didScan:(nonnull SBSScanSession *)session;

@end

@protocol SBSLicenseValidationDelegate

/**
 * \brief Method invoked whenever license validation process fails.
 *
 * This method is called on the SBSBarcodePicker#licenseValidationDelegate whenever there is
 * a problem with license validation. NSString describing the error can be retrieved from
 * the errorMessage parameter.
 *
 * \param picker The barcode picker on which license validation is performed.
 * \param errorMessage Error description in human readable NSString.
 */
- (void)barcodePicker:(nonnull SBSBarcodePicker *)picker failedToValidateLicense:(nonnull NSString *)errorMessage;

@end

/**
 * \brief Controls the camera and orchestrates the barcode scanning process.
 *
 * The barcode picker provides a high-level interface for scanning barcodes on iOS. The class is
 * responsible for initializing and controlling the camera and manages the low-level barcode scanning
 * process. The barcode picker also provides a configurable scan user interface in which recognized
 * barcodes are highlighted.
 *
 *
 * Example (minimal) usage:
 *
 * Set up the barcode picker in one of your view controllers:
 *
 * \code
 *
 * // Set your app key on the license first.
 * [SBSLicense setAppKey:kScanditBarcodeScannerAppKey];
 *
 * // Create the settings used for the picker.
 * SBSScanSettings *scanSettings = [SBSScanSettings defaultSettings];
 *
 * // Enable symbologies etc.
 * [scanSettings setSymbology:SBSSymbologyEAN13 enabled:YES];
 *
 * // Instantiate the barcode picker
 * SBSBarcodePicker barcodePicker = [[SBSBarcodePicker alloc] initWithSettings:scanSettings];
 *
 * // Set a class as the scan delegate to handle events when a barcode is successfully scanned.
 * barcodePicker.scanDelegate = self;
 *
 * // Present the barcode picker in some way (for example in a navigation controller)
 * [self.navigationController pushViewController:barcodePicker animated:YES];
 *
 * // Start the scanning
 * [barcodePicker startScanning];
 *
 * \endcode
 *
 * \since 4.7.0
 */
@interface SBSBarcodePicker : UIViewController

/**
 * \brief Orientations that the barcode picker is allowed to rotate to.
 *
 * The orientations returned by this view controller's supportedInterfaceOrientations function.
 * Be aware that this orientation mask will not be taken into consideration if the view controller
 * is part of a UITableViewController for example (in that case the UITableViewController's
 * supportedInterfaceOrientations matter). This orientation will also not be taken into
 * consideration if this view controller's view is directly added to a view hierarchy.
 *
 * By default all orientations are allowed (UIInterfaceOrientationMaskAll).
 *
 * \since 4.7.0
 */
@property (nonatomic, assign) UIInterfaceOrientationMask allowedInterfaceOrientations;

/**
 * \brief The overlay controller controls the scan user interface.
 *
 * The Scandit BarcodeScanner contains a default implementation that developers can inherit from to
 * define their own scan UI (enterprise licensees only).
 *
 * \since 4.7.0
 */
@property (nonnull, nonatomic, strong) SBSOverlayController *overlayController;

/**
 * \brief The scan delegate for this barcode picker
 *
 * SBSScanDelegate#barcodePicker:didScan: is invoked on the registered scanDelegate whenever a new
 * barcode/2d code has been recognized. To react to barcode scanned events, you must provide a scan
 * delegate that contains your application logic. Alternatively, you may register a
 * \ref SBSProcessFrameDelegate, which can be used to get notified whenever a frame has finished
 * processing and process the scan events there.
 *
 * \since 4.7.0
 */
@property (nullable, nonatomic, weak) id<SBSScanDelegate> scanDelegate;

/**
 * \brief The process frame delegate for this barcode picker
 *
 * SBSProcessFrameDelegate#barcodePicker:didProcessFrame:session: is invoked on the registered
 * \ref processFrameDelegate whenever a frame has been processed by the barcode picker. Barcodes
 * may or may not have been recognized in that frame. For most uses, you do not require to provide
 * a \ref processFrameDelegate, it is sufficient to just provide a \ref scanDelegate instead.
 *
 * \since 4.7.0
 */
@property (nullable, nonatomic, weak) id<SBSProcessFrameDelegate> processFrameDelegate;

/**
 * \brief The license validation delegate for this barcode picker
 *
 * SBSLicenseValidationDelegate#barcodePicker:failedToValidateLicense:errorMessage: is invoked on
 * the registered \ref licenseValidationDelegate license validation fails. The possible reasons
 * for the method to be called can be e.g. license expiration or missing API key.
 *
 * \since 5.8.0
 */
@property (nullable, nonatomic, weak) id<SBSLicenseValidationDelegate> licenseValidationDelegate;

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

/**
 * \brief Initializes the barcode picker with the desired scan settings.
 *
 * Note that the initial invocation of this method will activate the Scandit Barcode Scanner SDK,
 * after which the device will count towards your device limit.
 *
 * Make sure to set the app key available from your Scandit account through SBSLicense#setAppKey
 * before you call this initializer.
 *
 * \since 4.7.0
 *
 * \param settings The scan settings to use. You may pass nil, which is identical to passing a
 *     settings instance constructed through SBSScanSettings#defaultSettings.
 *
 * \return The newly constructed barcode picker instance.
 */
- (nonnull instancetype)initWithSettings:(nullable SBSScanSettings *)settings SBS_DESIGNATED_INITIALIZER;

/** \name Barcode Decoder Configuration
 */
///\{

/**
 * \brief Change the scan settings of an existing picker instance.
 *
 * The scan settings are applied asynchronously after this call returns. You may use the completion
 * handler to get notified when the settings have been applied to the picker. All frames processed
 * after the settings have been applied will use the new scan settings.
 *
 * \param settings The new scan settings to apply.
 *
 * \param handler An optional block that will be invoked when the settings have been
 *    applied to the picker. The block will be invoked on an internal picker dispatch queue.
 *
 * \since 4.7.0
 */
- (void)applyScanSettings:(nonnull SBSScanSettings *)settings
        completionHandler:(nullable void (^)(void))handler;

///\}

/**
 * \brief Add a observer that gets called whenever a property changes
 *
 * This API is experimental. There are no API stability guarantees at this point and this API might
 * change or dissapear in a future release.
 *
 * \param observer The observer to add
 *
 * \since 4.14.0
 */
- (void)addPropertyObserver:(nullable id<SBSPropertyObserver>)observer SBS_SWIFT_NAME(addPropertyObserver(_:));

/**
 * \brief remove a property changed delegate
 *
 * In case the observer was not registered previously, this call has no effect.
 *
 * \param observer The observer to remove
 *
 * \since 4.14.0
 */
- (void)removePropertyObserver:(nullable id<SBSPropertyObserver>)observer SBS_SWIFT_NAME(removePropertyObserver(_:));

/** \name Barcode Recognition Operation
 */
///\{

/**
 * \brief Starts/restarts the camera and the scanning process.
 *
 * Start or continue scanning barcodes after the creation of the barcode picker or a previous call
 * to #pauseScanning, SBSScanSession#pauseScanning, #stopScanning or
 * SBSScanSession#stopScanning.
 *
 * This method is identical to calling \c [SBSBarcodePicker startScanningInPausedState:NO];
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
 * \since 4.7.0
 *
 * \param paused If YES the barcode/2D recognition is paused but the streaming of preview images is
 *        started. If NO both the barcode/2D recognition and the streaming of preview images are
 *        started.
 */
- (void)startScanningInPausedState:(BOOL)paused;

/**
 * \brief Starts/restarts the camera and potentially the scanning process.
 *
 * Start or continue scanning barcodes after the creation of the barcode picker or a previous call
 * to #pauseScanning, SBSScanSession#pauseScanning, #stopScanning or
 * SBSScanSession#stopScanning.
 *
 * In contrast to resumeScanning, startScanning clears the current barcode scanner session.
 *
 * \since 4.12.0
 *
 * \param paused If YES the barcode/2D recognition is paused but the streaming of preview images is
 *        started. If NO both the barcode/2D recognition and the streaming of preview images are
 *        started.
 * \param handler If nonnull, the handler is invoked when the camera has completed initialization.
 *        The handler is invoked from a picker-internal queue, which may or may not run on the UI
 *        thread.
 */
- (void)startScanningInPausedState:(BOOL)paused completionHandler:(nullable void (^)(void))handler;

/**
 * \brief Stop scanning and the video preview.
 *
 * This method will stop the scanning and video preview asynchronously. If non-null, the
 * completion handler will be invoked once the preview and the scanning have been stopped.
 *
 * \param handler handler to be invoked when the preview and scanning has been stopped.
 *
 * \since 4.7.0
 */
- (void)stopScanningWithCompletionHandler:(nullable void (^)(void))handler;

/**
 * \brief Stop scanning and the video preview.
 *
 * This method will stop the scanning and video preview asynchronously. If your are restarting the
 * scanning shortly after stopping, use #stopScanningWithCompletionHandler: and call startScanning
 * only after the completion handler has been called.
 *
 * \since 4.7.0
 */
- (void)stopScanning;

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
 * \param handler Block to be invoked when the scanning has been resumed.
 *
 * \since 4.16.0
 */
- (void)resumeScanningWithCompletionHandler:(nullable void (^)(void))handler;

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
 * \brief Pause scanning but keep preview on
 *
 * This method pauses barcode/2D recognition but continues streaming preview images. Use this method
 * if you are interrupting barcode recognition for a short time and  want to continue scanning
 * barcodes/2D codes afterwards.
 *
 * Use #resumeScanning to continue scanning barcodes.
 *
 * \param handler Block to be invoked when the scanning has been paused.
 *
 * \since 4.16.0
 */
- (void)pauseScanningWithCompletionHandler:(nullable void (^)(void))handler;

///\}

/** \name Utility
 */
///\{

/**
 * \brief Converts a point of an SBSCode's location into this picker's coordinate system.
 *
 * The conversion takes the current resolution of the camera feed into consideration which means
 * that if the resolution should change converting a previously retrieved point successfully is no
 * longer possible. A change in resolution happens for example if
 * SBSScanSettings#highDensityModeEnabled is changed or the camera is switched from back to front
 * or vice versa.
 *
 * \since 4.9.0
 *
 * \param point The point to be converted.
 * \return The point in the picker's coordinate system.
 *
 * \see SBSCode#location
 */
- (CGPoint)convertPointToPickerCoordinates:(CGPoint)point;

///\}

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
 * Note that this value might be overwritten by the relative zoom value of the scan settings
 * (\ref SBSScanSettings#relativeZoom), if the scan settings are applied after this method has been
 * called.
 *
 * \since 4.7.0
 */
- (BOOL)setRelativeZoom:(float)zoom;
///\}

/** \name Parser Instantiation
 */
///\{
/**
 * Instantiates a parser object.
 *
 * \param dataFormat The format of the input data for the parser.
 * \param outError Describes errors during instantiation of the parser. This out parameter is set to
                   nil on success.
 * \return A parser instance or nil
 *
 * This method only returns a parser instance if the license used to instantiate the picker includes
 * the usage of the Scandit Parser Library. Otherwise a nil pointer is returned.
 *
 * \since 5.5.0
 */
- (nullable SBSParser *)parserForFormat:(SBSParserDataFormat)dataFormat error:(NSError * _Nullable * _Nullable)outError;
///\}

/** \name Generator Instantiation
 */
///\{
/**
 * Instantiates a generator object.
 *
 * \param symbology The symbology to generate the image. It has to be one of the following values:
 * - \ref SBSSymbologyQR
 * - \ref SBSSymbologyDatamatrix
 * - \ref SBSSymbologyCode128
 * - \ref SBSSymbologyEAN13
 * - \ref SBSSymbologyUPC12
 * \param outError Describes errors during the instantiation of the generator. The our parameters is set to
                   nil on success.
 * This method only returns a parser instance if the license used to instantiate the picker includes
 * the usage of the Scandit Generator Library. Otherwise a nil pointer is returned.
 *
 * \since 5.9.0
 */
- (nullable SBSBarcodeGenerator *)barcodeGeneratorForSymbology:(SBSSymbology)symbology error:(NSError * _Nullable * _Nullable)outError;
///\}

@end
