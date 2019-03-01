//
//  SBSScanCaseSettings.h
//  ScanditBarcodeScanner
//
//  Created by Luca Torella on 17/02/16.
//  Copyright © 2016 Scandit AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBSCode.h"

@class SBSScanSettings, SBSSymbologySettings;

/**
 * \brief Holds settings that affect the recognition of barcodes (e.g. enabled barcode
 * symbologies).
 *
 * The settings are passed to the SBSScanCase when it is constructed.
 *
 * \since 4.13.0
 */
@interface SBSScanCaseSettings : NSObject<NSCopying>

/**
 * \brief Initialize a new setting object.
 *
 * \return new settings object
 */
- (nonnull instancetype)init;

/**
 * \brief Returns a settings instance initialized with the values contained in dictionary.
 *
 * \param dictionary Dictionary, e.g. as deserialized from JSON to use for initializing the settings.
 *
 * \return new settings object
 */
- (nullable instancetype)initWithDictionary:(nullable NSDictionary<NSString *, id> *)dictionary SBS_DESIGNATED_INITIALIZER;

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
 * \since 4.13.0
 */
- (void)enableSymbologies:(nonnull NSSet<NSNumber *> *)symbologies;

/**
 * \brief Enable/disable decoding of a certain symbology.
 *
 * This function provides a convenient shortcut to enabling/disabling decoding of a
 * particular symbology without having to go through SBSSymbologySettings.
 *
 * \code
 * SBSScanCaseSettings *settings = ... ;
 * [settings setSymbology:SymbologyQR enabled:YES];
 *
 * // the following line has the same effect:
 * [settings settingsForSymbology:SymbologyQR].enabled = YES;
 *
 * \endcode
 *
 * \param symbology The symbology to be enabled.
 * \param enabled YES when decoding of the symbology should be enabled, NO if not.
 *
 * \since 4.13.0
 */
- (void)setSymbology:(SBSSymbology)symbology enabled:(BOOL)enabled;

/**
 * \brief Retrieve symbology-specific settings.
 *
 * \param symbology The symbology for which to retrieve the settings.
 * \return The symbology-specific settings object.
 *
 * \since 4.13.0
 */
- (nonnull SBSSymbologySettings *)settingsForSymbology:(SBSSymbology)symbology;

/**
 * \brief Set the active scanning height.
 *
 * Use this method to set the active scanning height.
 *
 * \since 4.13.0
 */
- (void)setScanningAreaHeight:(float)height;

/**
 * \brief Set the active scanning height for 2d codes
 *
 * Use this method to set the active scanning height for 2d codes.
 *
 * \since 5.7
 */
- (void)setScanningAreaHeight2d:(float)height;

/**
 * \brief Retrieve the scan settings to initialize a barcode picker
 *
 * Use these scan to initialize the barcode picker for use with the Scandit Scan case. 
 * Note that while it's possible for you to modify the settings returned by this 
 * property, it is not recommended to do so.
 *
 * \since 4.13.0
 */
@property (nonatomic, readonly, nonnull) SBSScanSettings *scanSettings;

@end
