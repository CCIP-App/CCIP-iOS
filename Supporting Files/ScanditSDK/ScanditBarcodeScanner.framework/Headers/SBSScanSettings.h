//
//  SBSScanSettings.h
//  BarcodeScanner
//
//  Created by Moritz Hartmeier on 20/05/15.
//  Copyright (c) 2015 Scandit AG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SBSCommon.h"
#import "SBSSymbologySettings.h"
#import "SBSScanAreaSettings.h"

/**
 * \brief Holds settings that affect the recognition of barcodes, such as enabled barcode
 * symbologies, scanning hot spot etc.
 *
 * The SBSScanSettings class was introduced in ScanditSDK 4.7 to hold all
 * scan-specific settings. The settings are passed to the SBSBarcodePicker
 * when it is constructed.
 *
 * Scan settings are not directly allocated, instead you should use one of the factory settings
 * (#defaultSettings or #pre47DefaultSettings) to receive a settings instance.
 *
 * \since 4.7.0
 */

@interface SBSScanSettings : NSObject<NSCopying>

/**
 * \brief Settings object with default values
 *
 * \return new settings object
 */
+ (nonnull instancetype)defaultSettings;

/**
 * \brief Convenience method to retrieve default settings as they were before ScanditSDK 4.7
 *
 * This method will return a settings object with symbologies on that were
 * on by default for ScanditSDK 4.6 and older. These symbologies include
 * EAN13, UPC12, EAN8, UPCE, CODE39, ITF, CODE128, QR, DATAMATRIX.
 *
 * The use of this method is discouraged. Use #defaultSettings instead and explicitly enable the 
 * symbologies that are required by your app.
 *
 * \return new settings object
 */
+ (nonnull instancetype)pre47DefaultSettings SBS_DEPRECATED_MSG_ATTRIBUTE("use defaultSettings and enable the required symbologies by hand instead.");


/**
 * \brief Returns a settings instance initialized with the values contained in dictionary
 *
 * \param dictionary Dictionary, e.g. as deserialized from JSON to use for initializing the settings.
 * \param error Upon failure, will contain further details on why the settings instance could 
 *    not be created.
 */
+ (nullable instancetype)settingsWithDictionary:(nonnull NSDictionary<NSString *, id> *)dictionary
                                          error:(NSError * _Nullable * _Nullable)error;

/**
 * \brief The focus working range for the barcode picker
 *
 * By default, focus is optimized for scanning barcodes which are close to the device
 * (\ref SBSWorkingRangeStandard). You can change this property to \ref SBSWorkingRangeLong
 * to optimize the focus for scanning codes that are further away.
 */
@property (nonatomic, assign) SBSWorkingRange workingRange;

/**
 * \brief Enable decoding of the given symbologies.
 *
 * This function provides a convenient shortcut to enabling/disabling decoding of a
 * particular symbology without having to go through SBSSymbologySettings.
 *
 * By default, all symbologies are turned off and symbologies need to be
 * explicitly enabled.
 *
 * \param symbologies The symbologies that should be enabled.
 *
 * \since 4.7.0
 */
 - (void)enableSymbologies:(nonnull NSSet<NSNumber *> *)symbologies;

/**
 * \brief Enable/disable decoding of a certain symbology.
 *
 * This function provides a convenient shortcut to enabling/disabling decoding of a
 * particular symbology without having to go through SBSSymbologySettings.
 *
 * \code
 * SBSScanSettings* settings = ... ;
 * [settings setSymbology:SymbologyQR enabled:YES];
 *
 * // the following line has the same effect:
 * [settings settingsForSymbology:SymbologyQR].enabled = YES;
 *
 * \endcode
 
 * Some 1d barcode symbologies allow you to encode variable-length data. By default, the
 * Scandit BarcodeScanner SDK only scans barcodes in a certain length range. If your
 * application requires scanning of one of these symbologies, and the length is falling
 * outside the default range, you may need to adjust the "active symbol counts" for the
 * symbology in addition to enabling it. For details on defaults and how to calculate 
 * the symbol counts for each symbology, take a look at 
 * <a href="../ios/ios-active-symbols-counts.html">the barcode length page</a>.
 *
 * \param symbology The symbology to be enabled.
 * \param enabled YES when decoding of the symbology should be enabled, NO if not.
 *
 * \since 4.7.0
 */
- (void)setSymbology:(SBSSymbology)symbology enabled:(BOOL)enabled;

/**
 * \brief Returns the set of enabled symbologies
 */
- (nonnull NSSet<NSNumber *> *)enabledSymbologies;

/**
 * \brief Retrieve symbology-specific settings.
 *
 * \param symbology The symbology for which to retrieve the settings.
 * \return The symbology-specific settings object.
 *
 * \since 4.7.0
 */
- (nonnull SBSSymbologySettings *)settingsForSymbology:(SBSSymbology)symbology;

/**
 * \brief Forces the barcode scanner to always run the 2D decoders (QR Code, Data Matrix, etc.), even when
 *        the 2D detector did not detect the presence of a 2D code.
 *
 * This slows down the overall scanning speed, but can be useful when your application only tries to
 * read 2D codes. Force 2d recognition is set to on when micro data matrix mode is enabled.
 *
 * By default forced 2d recognition is disabled.
 */
@property (nonatomic, assign) BOOL force2dRecognition;

/**
 * \brief The maximum number of barcodes to be decoded every frame.
 *
 * If set to values smaller than one, it is set to 1.
 *
 * \since 4.7.0
 */
@property (nonatomic, assign) NSInteger maxNumberOfCodesPerFrame;

/**
 * \brief Specifies the duplicate filter to use for the session.
 *
 * Duplicate filtering affects the handling of codes with the same data and symbology.
 * When the filter is set to -1, each unique code is only added once to the session,
 * when set to 0, duplicate filtering is disabled. Otherwise the duplicate filter
 * specifies an interval in milliseconds. When the same code (data/symbology) is scanned
 * withing the specified interval is it filtered out as a duplicate.
 *
 * The default value is 500ms.
 *
 * \since 4.7.0
 */
@property (nonatomic, assign) NSInteger codeDuplicateFilter;

/**
 * \brief Determines how long codes are kept in the session.
 *
 * When set to -1, codes are kept for the duration of the session. When set to 0, codes 
 * are kept until the next frame processing call finishes. For all other values, 
 * codeCachingDuration specifies a duration in milliseconds for how long the codes are
 * kept.
 *
 * The default value is -1.
 *
 * \since 4.7.0
 */
@property (nonatomic, assign) NSInteger codeCachingDuration;

/**
 * The zoom as a percentage of the max zoom possible (between 0 and 1).
 *
 * Note that this value may be overwritten by calls to \ref SBSBarcodePicker#setRelativeZoom:, or 
 * by a manual zoom operation through pinch-to-zoom.
 */
 @property (nonatomic, assign) float relativeZoom;

/**
 * \brief The preferred camera direction.
 *
 * The picker first gives preference to cameras of the given direction. When
 * the device has no such camera, cameras of the opposite face are tried as
 * well.
 *
 * By default, the back-facing camera is preferred.
 *
 * \since 4.7.0
 */
@property (nonatomic, assign) SBSCameraFacingDirection cameraFacingPreference;

/**
 * The device name to identify the current device when looking at analytics tools. Sends 
 * a request to the server to set this as soon as a connection is available.
 *
 *
 * \since 4.7.0
 */
@property (nullable, nonatomic, strong) NSString *deviceName;

/**
 * High density mode enables phones to work at higher camera resolution,
 * provided they support it. When enabled, phones that are able to run the
 * video preview at 1080p (1920x1080) will use 1080p and not just 720p
 * (1280x720). High density mode gives better decode ranges at the
 * expense of processing speed and allows to decode smaller code in the near
 * range, or codes that further away.
 * 
 * By default, high density mode is disabled.
 *
 * \since 4.7.0
 */
@property (nonatomic, assign) BOOL highDensityModeEnabled;

/**
 * \brief The active scanning area when the picker is in landscape orientation
 *
 * The active scanning area defines the rectangle in which barcodes and 2D codes are 
 * searched and decoded when the picker is in landscape orientation. By default, this area
 * is set to the full camera preview.
 *
 * The rectangle is defined in relative coordinates, where the top-left corner
 * is (0,0) and the bottom right corner of the camera preview is (1,1).
 *
 * \since 4.7.0
 */

@property (nonatomic, assign) CGRect activeScanningAreaLandscape;

/**
 * \brief The active scanning area when the picker is in portrait orientation
 *
 * The active scanning area defines the rectangle in which barcodes and 2D codes are
 * searched and decoded when the picker is in portrait orientation. By default, this area
 * is set to the full camera preview.
 *
 * When setting this property, restricted area scanning (#restrictedAreaScanningEnabled) is
 * automatically set to true.
 *
 * The rectangle is defined in relative coordinates, where the top-left corner
 * is (0,0) and the bottom right corner of the camera preview is (1,1).
 *
 * \since 4.7.0
 */
@property (nonatomic, assign) CGRect activeScanningAreaPortrait;

/**
 * \since 4.7.0
 *
 * When set to true, barcode recognition is restricted to the rectangles defined by
 * #activeScanningAreaPortrait and #activeScanningAreaLandscape, depending on the orientation of the
 * phone. When false, the whole image is searched for barcodes.
 */
@property (nonatomic, assign) BOOL restrictedAreaScanningEnabled;

/**
 * \brief Defines the point at which barcodes and 2D codes are expected.
 *
 * The hot spot is defined in relative view coordinates, where the top-left corner
 * is (0,0) and the bottom right corner of the view is (1,1).
 *
 * The default values is (0.5, 0.5).
 *
 * \since 4.7.0
 */
@property (nonatomic, assign) CGPoint scanningHotSpot;

/**
 * \brief Convenience function to set the landscape and portrait active scanning area.
 *
 * Use this method to set \ref activeScanningAreaLandscape and \ref activeScanningAreaPortrait
 * to the same value.
 *
 * \since 4.7.0
 */
- (void)setActiveScanningArea:(CGRect)area;


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
 * \since 4.7.0
 */
@property (nonatomic, assign) BOOL motionCompensationEnabled;

/**
 * \brief Set a custom property to configure the scanner.
 *
 * Use this method to set scan settings that are not part of the public API yet. There are no
 * stability guarantees for these properties and they might get renamed, or disappear completely in 
 * future releases. Setting properties that no longer exist is not an error, but they will be 
 * ignored.
 *
 * \param property The name of the property to set. Must not be nil.
 * \param  value The value to set the property to.
 *
 * \since 4.10
 */
- (void)setProperty:(nonnull NSString *)property toValue:(int)value;

/**
 * \brief Get the value of the custom property identified by key.
 *
 * If the property is not set a default value of -1 is returned.
 *
 * \param key The name of the property to retrieve. Must not be nil.
 *
 * \since 5.5.0
 */
- (int)valueForProperty:(nonnull NSString *)key;

/**
 * \brief Whether code rejection should be enabled.
 *
 * Code rejection allows you to implement custom code verification features and reject certain 
 * codes by calling \ref SBSScanSession::rejectCode:. By default, code rejection is disabled. 
 *
 * \since 4.15
 */
@property (nonatomic, assign) BOOL codeRejectionEnabled;

/**
 * \brief Portrait area settings, if present
 *
 * This property allows a more fine-grained control over where codes are searched and scanned. By
 * default, this property is set to nil and the settings specified by \ref activeScanningAreaPortrait
 * and \ref activeScanningAreaLandscape are used to control where codes are scanned. As soon as this
 * property is set to an instance, \ref activeScanningAreaPortrait and
 * \ref activeScanningAreaLandscape have no longer any effect on the scan area.
 *
 * \since 5.0
 */
@property (nullable, nonatomic, strong) SBSScanAreaSettings *areaSettingsPortrait;

/**
 * \brief Landscape area settings, if present
 *
 * This property allows a more fine-grained control over where codes are searched and scanned. By
 * default, this property is set to nil and the settings specified by \ref activeScanningAreaPortrait 
 * and \ref activeScanningAreaLandscape are used to control where codes are scanned. As soon as this 
 * property is set to an instance, \ref activeScanningAreaPortrait and 
 * \ref activeScanningAreaLandscape have no longer any effect on the scan area.
 *
 * \since 5.0
 */
@property (nullable, nonatomic, strong) SBSScanAreaSettings *areaSettingsLandscape;

/**
 * \brief Whether matrix scan should be enabled.
 *
 * Matrix scan allows you to know the location of all localized codes.
 * In order to get the tracked codes, it is recommended to implement the
 * SBSProcessFrameDelegate protocol and to use SBSScanSession#trackedCodes.
 * To use the default matrix scan UI, it is necessary to set
 * SBSOverlayController#guiStyle to SBSGuiStyleMatrixScan.
 * When implementing a custom matrix scan UI, it is recommended to set
 * SBSOverlayController#guiStyle to SBSGuiStyleNone.
 *
 * \since 5.2
 */
@property (nonatomic, assign, getter=isMatrixScanEnabled) BOOL matrixScanEnabled;

@end
