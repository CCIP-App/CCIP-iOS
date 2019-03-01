/**
 * ScanditSDKBarcodePicker acquires camera frames, decodes barcodes in the
 * camera frames and updates the ScanditSDKOverlayController.
 *
 * Copyright Mirasense AG
 */


#import "SBSScanSession.h"
#import "SBSCommon.h"
#import "SBSBarcodePickerBase.h"
#import "ScanditSDKOverlayController.h"

@class SBSScanSettings;
@class ScanditSDKBarcodePicker;



/**
 * \brief protocol to receive individual frame from barcode picker
 * \ingroup scanditsdk-ios-api
 * \since 2.0.0
 */
@protocol ScanditSDKNextFrameDelegate
/**
 * \brief Returns a jpg encoded camera image of the given height and width.
 *
 * To receive this callback with the barcode picker, the ScanditSDKBarcodePicker#sendNextFrameToDelegate:
 * method needs to be called beforehand. We recommend to not call this method repeatedly
 * while the barcode scanner is running, since the JPG conversion of the camera frame is very slow.
 *
 * \since 2.0.0
 */
- (void)scanditSDKBarcodePicker:(ScanditSDKBarcodePicker*)scanditSDKBarcodePicker 
                didCaptureImage:(NSData*) image 
                     withHeight:(int)height 
                      withWidth:(int)width;
@end




/**
 * \brief Acquires camera frames, decodes barcodes in those camera frames and updates the
 * ScanditSDKOverlayController.
 *
 * \ingroup scanditsdk-ios-api
 *
 * Example (minimal) usage:
 *
 * Set up the barcode picker in one of your view controllers:
 *
 * \code
 *
 * // Instantiate the barcode picker.
 * scanditSDKBarcodePicker = [[ScanditSDKBarcodePicker alloc] initWithAppKey:kScanditBarcodeScannerAppKey];
 *
 * // Set a class as the delegate for the overlay controller to handle events when
 * // a barcode is successfully scanned or manually entered or the cancel button is pressed.
 * scanditSDKBarcodePicker.overlayController.delegate = self;
 *
 * // Present the barcode picker modally
 * [self presentViewController:scanditSDKBarcodePicker animated:YES completion:nil];
 *
 * // Start the scanning
 * [scanditSDKBarcodePicker startScanning];
 *
 * \endcode
 *
 * As of version 4.7.0, we encourage to use SBSBarcodePicker instead of the ScanditSDKBarcodePicker 
 * for scanning of barcodes. No new features will be added to the ScanditSDKBarcodePicker class.  
 * Improvements to the barcode scanning process itself (performance, recognition rates) will 
 * automatically become available for code using the ScanditSDKBarcodePicker.
 
 * \since 1.0.0
 *
 * \nosubgrouping
 * Copyright Scandit AG
 */
SBS_DEPRECATED
@interface ScanditSDKBarcodePicker  : SBSBarcodePickerBase

/**
 * \brief The overlay controller controls the scan user interface.
 *
 * The Scandit SDK contains a default implementation that developers can inherit
 * from to define their own scan UI (enterprise licensees only).
 *
 * \since 1.0.0
 */
@property (nonatomic, strong) ScanditSDKOverlayController *overlayController;

/**
 * \deprecated Use the view's frame instead.
 *
 * \brief The size of the scan user interface.
 *
 * Change the size if you want to scale the picker (see example in the demo project).
 * By default it is set to full screen.
 *
 * \since 2.1.9
 */
@property (nonatomic, assign) CGSize size SBS_DEPRECATED;



/** \name Barcode Picker Setup
 *  Initialize and prepare the barcode picker, control standby state and set overlay
 */
///\{

/**
 * \brief Initiate the barcode picker with the default camera orientation (CameraFacingDirectionBack).
 *
 * Note that the initial invocation of this method will activate the
 * Scandit Barcode Scanner SDK, after which the device will count towards
 * your device limit.
 *
 * \since 2.0.0
 *
 * \param appKey Your Scandit SDK App Key (available from your Scandit account).
 */
- (instancetype)initWithAppKey:(NSString *)appKey;

/**
 * \brief Initializes the barcode picker with the desired camera orientation.
 *
 * Note that the initial invocation of this method will activate the
 * Scandit Barcode Scanner SDK, after which the device will count towards
 * your device limit.
 *
 * \since 2.1.7
 *
 * \param appKey Your Scandit SDK app key (available from your Scandit account).
 * \param facing The desired camera direction.
 */
- (instancetype)initWithAppKey:(NSString *)appKey
        cameraFacingPreference:(SBSCameraFacingDirection)facing;

/**
 *
 * \brief Initializes the barcode picker with the desired camera orientation and working range.
 *
 * Note that the initial invocation of this method will activate the
 * Scandit Barcode Scanner SDK, after which the device will count towards
 * your device limit.
 *
 * \since 4.2.0
 *
 * \param appKey Your Scandit SDK app key (available from your Scandit account).
 * \param facing The desired camera direction.
 * \param workingRange The desired working range for the auto-focus.
 */
- (instancetype)initWithAppKey:(NSString *)appKey
        cameraFacingPreference:(SBSCameraFacingDirection)facing
                  workingRange:(SBSWorkingRange)workingRange;

///\}

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


/**
 * \brief Starts/restarts the scanning process.
 *
 * Start or continue scanning barcodes after the creation of the barcode picker or a previous call
 * to #stopScanning, #stopScanningAndKeepTorchState, or #stopScanningAndFreeze.
 *
 * \since 1.0.0
 */
- (void)startScanning;

/**
 * \brief Stops the scanning process.
 *
 * \see ScanditSDKBarcodePicker#stopScanningAndKeepTorchState:
 *
 * \since 1.0.0
 */
- (void)stopScanning;

/**
 * \brief Stops the scanning process but keeps the torch on if it is already turned on.
 *
 * This is useful when the scan user interface remains visible after a successful barcode scan. To 
 * prevent additional scans of the same barcode, the scanner needs to be stopped at least temporarily. 
 * To avoid making the user switch on the torch again for the next scan, we recommend using this 
 * method instead of :stopScanning:
 *
 * \since 3.0.0
 */
- (void)stopScanningAndKeepTorchState;

/**
 * \brief Stops the scanning process and stops the camera feed, freezing it. This will result in a
 * reset of the focus and take longer to focus on a new code when started again.
 *
 * \since 3.2.4
 */
- (void)stopScanningAndFreeze;

///\}

/**
 * \deprecated This method serves no purpose any more in Scandit SDK 3.0+ and is deprecated.
 *
 * \brief Resets the state of the barcode picker.
 *
 * \since 1.0.0
 *
 */
- (void)reset SBS_DEPRECATED;
///\}


/** \name Analytics Configuration
 *
 */
///\{

/**
 * Sets the device name to identify this device when looking at analytics tools. Sends a request to
 * the server to set this as soon as a connection is available.
 *
 * \param deviceName The device name to be used.
 */
- (void)setDeviceName:(NSString *)deviceName;
///\}


/** \name Barcode Decoder Configuration
 *  Adjust the decoding process and area.
 */
///\{

/**
 * \brief Sets the active scan area for either portrait mode scanning
 *
 * By default, the ScanditSDK searches the whole image for a barcode. Use this method
 * to define the area in which barcodes are to be searched. Rectangle coordinates run
 * from 0 to 1.
 *
 * Calling this method will automatically enable restricted active area scanning
 * (#restrictActiveScanningArea:).
 *
 * \since 4.4
 *
 * Calling this method with other orientation parameters is a no-op.
 * \param rect the new active scan area. The coordinates (top, left, right, bottom) are
 *    defined as seen by the user.
 *
 * \param orientation the device orientation for which to set the scan area. Must be
 *   either SBSOrientationLandscape for landscape orientations
 *   (landscape-right and landscape-left), or SBSOrientationPortrait
 *   for portrait orientations.
 *
 * Invoking this method with invalid rectangles, e.g. rectangles whose top, left,
 * right, or bottom attributes are outside the allowed range of 0.0-1.0, or rectangles
 * with negative width/height will have no effect.
 */
- (void)setActiveScanningArea:(CGRect)rect forOrientation:(SBSOrientation)orientation;

/**
 * \brief Returns the scan area that is going to be used for the given orientation
 *
 * \since 4.4
 *
 * \param orientation the device orientation. Must either be \ref SBSOrientationPortrait,
 *    or \ref SBSOrientationLandscape
 * \return The rectangle, or null when orientation is not one of the allowed values. When
 *    restricted area scanning is disabled a full-screen area (top=0, left=0, right=1, bottom=1) is
 *    returned, otherwise the area from either specifying the scanning hotspot/height or
 *    calls to #setActiveScanningArea:forOrientation: is returned.
 * \see #setActiveScanningArea:forOrientation:
 */
- (CGRect)activeScanningAreaForOrientation:(SBSOrientation)orientation;

/**
 * \brief Reduces the area in which barcodes are detected and decoded.
 *
 * When activated, the active scanning area is defined by #setScanningHotSpotHeight:
 * and #setScanningHotSpotToX:andY:. If this method is not enabled, barcodes in the full camera
 * image are detected and decoded.
 *
 * \see ScanditSDKBarcodePicker#setScanningHotSpotToX:andY:
 * \see ScanditSDKBarcodePicker#setScanningHotSpotHeight:
 *
 * By default this is not enabled.
 *
 * \since 3.0.0
 
 * \param enabled Whether the scanning area should be restricted.
 */
- (void)restrictActiveScanningArea:(BOOL)enabled;

/**
 * \brief Sets the location in the image where barcodes are decoded with the highest priority.
 *
 * This method shows a slightly different behavior depending on whether the full screen scanning is
 * active or not. In Full screen scanning mode:
 *
 * Sets the location in the image which is decoded with the highest priority when multiple barcodes
 * are present in the image.
 *
 * In restrictActiveScanningArea mode (activated with #restrictActiveScanningArea:):
 *
 * Changes the location of the spot where the barcode decoder actively scans for barcodes.
 *
 * X and Y can be between 0 and 1, where 0/0 corresponds to the top left corner and 1/1 to the bottom right
 * corner.
 *
 * The default hotspot is set to 0.5/0.5
 *
 * \see ScanditSDKBarcodePicker#restrictActiveScanningArea:
 * \see ScanditSDKBarcodePicker#setScanningHotSpotHeight:
 *
 * \since 1.0.0
 *
 * \param x The hotspot's relative x coordinate.
 * \param y The hotspot's relative y coordinate.
 */
- (void)setScanningHotSpotToX:(float)x andY:(float)y;

/**
 * \brief Changes the height of the area where barcodes are decoded in the camera image
 * when restrictActiveScanningArea is activated.
 *
 * The height of the active scanning area is relative to the height of the screen and has to be
 * between 0.0 and 0.5.
 *
 * This only applies if the active scanning area is restricted.
 *
 * The default is 0.25
 *
 * \see ScanditSDKBarcodePicker#restrictActiveScanningArea:
 * \see ScanditSDKBarcodePicker#setScanningHotSpotToX:andY:
 *
 * \since 1.0.0
 *
 * \param height The relative height of the active scanning area.
 */
- (void)setScanningHotSpotHeight:(float)height;

/**
 * \brief Enable the detection/decoding of tiny Data Matrix codes.
 *
 * When this mode is enabled, a dedicated localization algorithm is activated that searches
 * for small Datamatrix codes in the central part of the camera image.
 * This algorithm requires additional resources and slows down the
 * recognition of other barcode symbologies. We recommend using the method
 * only when your application requires the decoding of tiny Datamatrix codes.
 *
 * By default this mode is disabled.
 *
 * \since 2.0.0
 *
 * \param enabled Whether this mode should be enabled.
 */
- (void)setMicroDataMatrixEnabled:(BOOL)enabled;

/**
 * \brief Enables the detection of white on black codes. This option currently only
 * works for Data Matrix and QR codes.
 *
 * By default this mode is disabled.
 *
 * \since 2.0.0 (4.4.0 for QR)
 *
 * \param enabled Whether this mode should be enabled.
 */
- (void)setInverseDetectionEnabled:(BOOL)enabled;

/**
 * \brief Enable/disable motion compensation.
 *
 * When motion compensation is enabled, special algorithms are run to improve the image quality when
 * the phone or the barcode to be scanned are moving. Motion compensation requires an OpenGLES 3.0
 * compatible device. For devices that do not support OpenGLES 3.0, setting the motion compensation
 * flag has no effect.
 *
 * Motion compensation is enabled by default.
 *
 * \since 4.6.0
 */
- (void)setMotionCompensationEnabled:(BOOL)enabled;

/**
 * Changes the camera frame resolution to the highest possible but a max of 1920x1080.
 */
- (void)setHighDensityModeEnabled:(BOOL)enabled;

/**
 * \brief Forces the barcode scanner to always run the 2D decoders (QR,Datamatrix, etc.),
 * even when the 2D detector did not detect the presence of a 2D code.
 *
 * This slows down the overall scanning speed, but can be useful when your application only tries
 * to read QR codes. It is by default enabled when the micro Datamatrix mode is enabled.
 *
 * By default, this is disabled.
 *
 * \param force boolean indicating whether this mode should be enabled.
 *
 * \since 2.0.0
 */
- (void)force2dRecognition:(BOOL)force;
///\}


/** \name Barcode Symbology Selection
 *  Configure which symbologies are decoded.
 */
///\{

/**
 * \deprecated Individually enable/disable symbologies instead of using this catch all. Turning
 *             on too many irrelevant symbologies will slow down the recognition unnecessarily.
 *
 * \brief Enables or disables the recognition of all 1D barcode symbologies supported by the
 * particular Scandit SDK edition you are using.
 *
 * By default all 1D symbologies except for MSI Plessey and GS1 DataBar are enabled.
 *
 * \since 1.0.0
 *
 * \param enabled Whether all 1D symbologies should be enabled.
 */
- (void)set1DScanningEnabled:(BOOL)enabled SBS_DEPRECATED;

/**
 * \deprecated Individually enable/disable symbologies instead of using this catch all. Turning
 *             on too many irrelevant symbologies will slow down the recognition unnecessarily.
 *
 * \brief Enables or disables the recognition of 2D barcode symbologies supported by the
 * particular Scandit SDK edition you are using.
 *
 * By default only QR is enabled.
 *
 * \since 1.0.0
 *
 * \param enabled boolean indicating whether all 2D symbologies are enabled
 */
- (void)set2DScanningEnabled:(BOOL)enabled SBS_DEPRECATED;

/**
 * \brief Enables or disables the barcode decoder for EAN13 and UPC12/UPCA codes.
 *
 * By default scanning of EAN13 and UPC barcodes is enabled.
 *
 * \since 1.0.0
 *
 * \param enabled Whether this symbology should be enabled.
 */
- (void)setEan13AndUpc12Enabled:(BOOL)enabled;

/**
 * \brief Enables or disables the barcode decoder for EAN8 codes.
 *
 * By default scanning of EAN8 barcodes is enabled.
 *
 * \since 1.0.0
 *
 * \param enabled Whether this symbology should be enabled.
 */
- (void)setEan8Enabled:(BOOL)enabled;

/**
 * \brief Enables or disables the barcode decoder for UPCE codes.
 *
 * By default scanning of UPCE barcodes is enabled.
 *
 * \since 1.0.0
 *
 * \param enabled Whether this symbology should be enabled.
 */
- (void)setUpceEnabled:(BOOL)enabled;

/**
 * \brief Enables or disables the barcode decoder for Code39 codes.
 *
 * By default scanning of Code39 barcodes is enabled. Note:
 * CODE39 scanning is only available with the
 * Scandit SDK Enterprise Basic or Enterprise Premium Package.
 *
 * \since 1.0.0
 *
 * \param enabled Whether this symbology should be enabled.
 */
- (void)setCode39Enabled:(BOOL)enabled;

/**
 * \brief Enables or disables the barcode decoder for Code93 codes.
 *
 * By default scanning of Code93 barcodes is disabled. Note:
 * CODE93 scanning is only available with the
 * Scandit SDK Enterprise Basic or Enterprise Premium Package.
 *
 * \since 4.0.1
 *
 * \param enabled Whether this symbology should be enabled.
 */
- (void)setCode93Enabled:(BOOL)enabled;

/**
 * \brief Enables or disables the barcode decoder for Code128 codes.
 *
 * By default scanning of Code128 barcodes is enabled. Note:
 * CODE128 scanning is only available with the
 * Scandit SDK Enterprise Basic or Enterprise Premium Package.
 *
 * \since 1.0.0
 *
 * \param enabled Whether this symbology should be enabled.
 */
- (void)setCode128Enabled:(BOOL)enabled;

/**
 * \brief Enables or disables the barcode decoder for ITF (2 out of 5) codes.
 *
 * By default scanning of ITF barcodes is enabled. Note:
 * ITF scanning is only available with the
 * Scandit SDK Enterprise Basic or Enterprise Premium Package.
 *
 * \since 1.0.0
 *
 * \param enabled Whether this symbology should be enabled.
 */
- (void)setItfEnabled:(BOOL)enabled;

/**
 * \brief Enables or disables the barcode decoder for MSI Plessey codes.
 *
 * By default scanning of MSI Plessey barcodes is disabled. Note:
 * MSI Plessey scanning is only available with the
 * Scandit SDK Enterprise Basic or Enterprise Premium Package.
 *
 * \since 3.0.0
 *
 * \param enabled Whether this symbology should be enabled.
 */
- (void)setMsiPlesseyEnabled:(BOOL)enabled;

/**
 * \brief Sets the type of checksum that is expected of the MSI Plessey codes.
 *
 * MSI Plessey is used with different checksums. Set the checksum your application uses
 * with this method.
 *
 * By default it is set to CHECKSUM_MOD_10.
 *
 * \since 3.0.0
 *
 * \param type The MSIPlesseyChecksumType your application uses.
 */
- (void)setMsiPlesseyChecksumType:(SBSMsiPlesseyChecksumType)type;

/**
 * \brief Enables or disables the barcode decoder for GS1 DataBar codes.
 *
 * By default scanning of GS1 DataBar barcodes is disabled. Note:
 * GS1 DataBar scanning is only available with the
 * Scandit SDK Enterprise Basic or Enterprise Premium Package.
 *
 * \since 4.0.0
 *
 * \param enabled Whether this symbology should be enabled.
 */
- (void)setGS1DataBarEnabled:(BOOL)enabled;

/**
 * \brief Enables or disables the barcode decoder for GS1 DataBar Expanded codes.
 *
 * By default scanning of GS1 DataBar Expanded barcodes is disabled. Note:
 * GS1 DataBar scanning is only available with the
 * Scandit SDK Enterprise Basic or Enterprise Premium Package.
 *
 * \since 4.0.0
 *
 * \param enabled Whether this symbology should be enabled.
 */
- (void)setGS1DataBarExpandedEnabled:(BOOL)enabled;

/**
 * \brief Enables or disables the barcode decoder for Codabar codes.
 *
 * By default scanning of Codabar barcodes is disabled. Note: Codabar scanning is only available
 * with the Scandit SDK Enterprise Basic or Enterprise Premium Package.
 *
 * \since 4.0.0
 *
 * \param enabled boolean indicating whether this symbology should be enabled.
 */
- (void)setCodabarEnabled:(BOOL)enabled;

/**
 * \brief Enables or disables the barcode decoder for Code11 codes.
 *
 * By default scanning of Code11 barcodes is disabled. Note: Code11 scanning is only available
 * with the Scandit SDK Enterprise Basic or Enterprise Premium Package.
 *
 * \since 4.9.0
 *
 * \param enabled boolean indicating whether this symbology should be enabled.
 */
- (void)setCode11Enabled:(BOOL)enabled;

/**
 * \brief Enables or disables the barcode decoder for QR codes.
 *
 * By default scanning of QR barcodes is enabled.
 *
 * \since 2.0.0
 *
 * \param enabled Whether this symbology should be enabled.
 */
- (void)setQrEnabled:(BOOL)enabled;

/**
 * \brief Enables or disables the barcode decoder for Datamatrix codes.
 *
 * By default scanning of Datamatrix codes is enabled.
 *
 * Note: Datamatrix scanning is only available with the
 * Scandit SDK Enterprise Premium Package.
 *
 * \since 2.0.0
 *
 * \param enabled Whether this symbology should be enabled.
 */
- (void)setDataMatrixEnabled:(BOOL)enabled;

/**
 * \brief Enables or disables the barcode decoder for PDF417 codes.
 *
 * By default scanning of PDF417 codes is disabled (since 3.2.0).
 *
 * Note: PDF417 scanning is only available with the
 * Scandit SDK Enterprise Premium Package.
 *
 * \since 3.0.0
 *
 * \param enabled Whether this symbology should be enabled.
 */
- (void)setPdf417Enabled:(BOOL)enabled;

/**
 * \brief Enables or disables the barcode decoder for Aztec codes.
 *
 * By default scanning of Aztec codes is disabled.
 *
 * Note: Aztec scanning is only available with the
 * Scandit SDK Enterprise Premium Package.
 *
 * \since 4.3.0
 *
 * \param enabled Whether this symbology should be enabled.
 */
- (void)setAztecEnabled:(BOOL)enabled;

/**
 * \brief Enables or disables the barcode decoder for MaxiCode codes.
 *
 * By default scanning of MaxiCode barcodes is disabled. Note: MaxiCode scanning is only available
 * with the Scandit SDK Enterprise Basic or Enterprise Premium Package.
 *
 * \since 4.9.0
 *
 * \param enabled boolean indicating whether this symbology should be enabled.
 */
- (void)setMaxiCodeEnabled:(BOOL)enabled;

/**
 * Enables or disables the recognition of two-digit add-ons for EAN and UPC
 * barcodes.
 *
 * Note that you also need to enable scanning of EAN13/UPCA, EAN8, or UPCE codes
 * in order to scan two-digit add-ons and must set the maximum number of codes per
 * frame to at least 2.
 *
 * \since 4.5.0
 *
 * \param enabled Whether it should be enabled. Default is false.
 */
- (void)setTwoDigitAddOnEnabled:(BOOL)enabled;

/**
 * Enables or disables the recognition of five-digit add-ons for EAN and UPC
 * barcodes.
 *
 * Note that you also need to enable scanning of EAN13/UPCA, EAN8, or UPCE codes
 * in order to scan five-digit add-ons and must set the maximum number of codes
 * per frame to at least 2.
 *
 * \since 4.5.0
 *
 * \param enabled Whether it should be enabled. Default is false.
 */
- (void)setFiveDigitAddOnEnabled:(BOOL)enabled;

/**
 * \brief Enables or disables the barcode decoder for Databar Limited codes
 *
 * By default scanning of Databar Limited barcodes is disabled. Note: Databar Limited scanning is 
 * only available with the Scandit SDK Enterprise Basic or Enterprise Premium Package.
 *
 * \since 4.11.0
 *
 * \param enabled boolean indicating whether this symbology should be enabled.
 */
- (void)setGS1DatabarLimitedEnabled:(BOOL)enabled;


/**
 * \brief Set the maximum number of codes to be decoded per frame.
 *
 * By default at most one code is decoded per frame. Use this method to enable
 * scanning multiple codes.
 *
 * \since 4.7.0
 *
 * \param num the new maximum number of codes to be decoded per frame. Values are
 * clamped to the range 1...6.
 */
- (void)setMaxNumCodesPerFrame:(int)num;

///\}



/** \name Camera Frame Access
 *
 */
///\{
/**
 * \brief Sets the delegate to which the next frame should be sent.
 *
 * The next frame from the camera is
 * then converted to a JPEG image and the ScanditSDKBarcodePicker will pass the jpg image, width and height
 * to the delegate. We recommend to not call this method repeatedly while the barcode scanner is running,
 * since the JPG conversion of the camera frame is very slow.
 *
 * \since 2.0.0
 *
 * \param delegate implementing the ScanditSDKNextFrameDelegate protocol
 */
- (void)sendNextFrameToDelegate:(id<ScanditSDKNextFrameDelegate>)delegate;

///\}





/** \name Deprecated Standby Related Setup
 *  With the removal of the standby state in 4.7.0 these functions do not do anything anymore.
 */
///\{

/**
 * \deprecated With the removal of the standby state in 4.7.0 this does not do anything anymore.
 *
 * \brief Prepares a ScanditSDKBarcodePicker which accelerates the camera start.
 *
 * We no longer recommend to use this method since the impact on performance is no
 * longer as significant with
 * iOS7/8 and the recent generation of ios devices.
 *
 * Note that the initial invocation of this method will activate the
 * Scandit Barcode Scanner SDK, after which the device will count towards
 * your device limit.
 *
 * The method prepares the default backwards facing camera.
 * \nosubgrouping
 * \since 3.0.0
 *
 * \param scanditSDKAppKey your Scandit SDK App Key (available from your Scandit account)
 */
+ (void)prepareWithAppKey:(NSString *)scanditSDKAppKey SBS_DEPRECATED;

/**
 * \deprecated With the removal of the standby state in 4.7.0 this does not do anything anymore.
 *
 * \brief Prepares a ScanditSDKBarcodePicker which accelerates the camera start with the
 * desired camera orientation.
 *
 * We no longer recommend to use this method since the impact on performance is
 * no longer as significant with
 * iOS7/8 and the recent generation of ios devices.
 *
 * Note that the initial invocation of this method will activate the
 * Scandit Barcode Scanner SDK, after which the device will count towards
 * your device limit.
 *
 * \since 3.0.0
 *
 * \param scanditSDKAppKey your Scandit SDK App Key (available from your Scandit account)
 * \param facing the desired camera direction
 */
+ (void)prepareWithAppKey:(NSString *)scanditSDKAppKey
   cameraFacingPreference:(CameraFacingDirection)facing SBS_DEPRECATED;

/**
 * \deprecated With the removal of the standby state in 4.7.0 this does not do anything anymore.
 *
 * \brief Prepares a ScanditSDKBarcodePicker which accelerates the camera start with the
 * desired camera orientation and working range
 *
 * Note that the initial invocation of this method will activate the
 * Scandit Barcode Scanner SDK, after which the device will count towards
 * your device limit.
 *
 * \param scanditSDKAppKey the Scandit Barcode Scanner (ScanditSDK) app key.
 * \param facing the preferred camera facing direction to use.
 * \param range The working range for the auto-focus
 *
 * \since 4.2.0
 */
+ (void)prepareWithAppKey:(NSString *)scanditSDKAppKey
   cameraFacingPreference:(CameraFacingDirection)facing
             workingRange:(WorkingRange)range SBS_DEPRECATED;

/**
 * \deprecated With the removal of the standby state in 4.7.0 this does not do anything anymore.
 *
 * \brief Forces the release of the barcode picker and all attached objects.
 *
 * By default the camera is being held in a standby mode when the barcode picker object is released.
 * Forcing a release will lead to the deallocation of all resources and shut down the camera completely.
 * This frees up resources (memory, power), but also increases the startup time and time to a successful
 * scan for subsequent scanning attempts.
 *
 * \see ScanditSDKBarcodePicker#disableStandbyState:
 *
 * \since 3.0.3
 */
- (void)forceRelease SBS_DEPRECATED;

/**
 * \deprecated With the removal of the standby state in 4.7.0 this does not do anything anymore.
 *
 * \brief Prevents the camera from entering a standby state after the barcode picker object is deallocated.
 *
 * This will free up resources (power, memory) after each scan that are used by the camera in standby mode,
 * but also increases the startup time and time to successful scan for subsequent scans. This method is not
 * enabled by default. We recommend enabling it when conserving battery power is important.
 *
 * \since 3.0.0
 */
- (void)disableStandbyState SBS_DEPRECATED;



                                                                               
///\}

@end


