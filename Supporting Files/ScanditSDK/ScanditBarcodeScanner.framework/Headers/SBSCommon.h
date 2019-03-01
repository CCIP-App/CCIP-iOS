//  ScanditSDKCommon.h
//  ScanditBarcodeScanner
//
//  Created by Marco Biasini on 29/05/15.
//  Copyright (c) 2015 Scandit AG. All rights reserved.
//


#define SBS_DEPRECATED __attribute__((deprecated))

// we can't use NS_ENUM directly, but rather have to use a macro that gets replaced with
// the proper meaning when generating the documentation.

//! \{
#if defined(SBS_GENERATE_DOCS)
#   define SBS_ENUM_BEGIN(name) typedef enum
#   define SBS_ENUM_END(name) name
#   define SBS_DESIGNATED_INITIALIZER
#   define SBS_NOT_AVAILABLE_IN_SWIFT
#   define SBS_SWIFT_NAME(method)
#   define SBS_DEPRECATED_MSG_ATTRIBUTE(message)
#else
#   define SBS_ENUM_BEGIN(name) typedef NS_ENUM(NSInteger, name)
#   define SBS_ENUM_END(name)
#   define SBS_DESIGNATED_INITIALIZER NS_DESIGNATED_INITIALIZER
#   if __has_attribute(swift_private)
#     define SBS_NOT_AVAILABLE_IN_SWIFT __attribute__((swift_private))
#   endif
#   define SBS_SWIFT_NAME(method) NS_SWIFT_NAME(method)
#   define SBS_DEPRECATED_MSG_ATTRIBUTE(message) DEPRECATED_MSG_ATTRIBUTE(message)
#endif
//! \}


/**
 * Enumeration of different camera orientations.
 *
 * \since 2.1.7
 */
SBS_ENUM_BEGIN(SBSCameraFacingDirection) {
    SBSCameraFacingDirectionBack, /**< Default camera orientation - facing away from user */
    SBSCameraFacingDirectionFront, /**< Facetime camera orientation - facing the user */
    CAMERA_FACING_BACK SBS_DEPRECATED SBS_NOT_AVAILABLE_IN_SWIFT = SBSCameraFacingDirectionBack,
    CAMERA_FACING_FRONT SBS_DEPRECATED SBS_NOT_AVAILABLE_IN_SWIFT = SBSCameraFacingDirectionFront,
} SBS_ENUM_END(SBSCameraFacingDirection);

typedef SBSCameraFacingDirection CameraFacingDirection SBS_DEPRECATED SBS_NOT_AVAILABLE_IN_SWIFT;


SBS_ENUM_BEGIN(SBSOrientation)  {
    SBSOrientationPortrait,
    SBSOrientationLandscape,
    ORIENTATION_PORTRAIT SBS_DEPRECATED SBS_NOT_AVAILABLE_IN_SWIFT = SBSOrientationPortrait,
    ORIENTATION_LANDSCAPE SBS_DEPRECATED SBS_NOT_AVAILABLE_IN_SWIFT = SBSOrientationLandscape
} SBS_ENUM_END(SBSOrientation);

typedef SBSOrientation Orientation SBS_DEPRECATED SBS_NOT_AVAILABLE_IN_SWIFT;


/**
 * Enumerates the possible working ranges for the barcode picker
 *
 * \since 4.1.0
 */
SBS_ENUM_BEGIN(SBSWorkingRange) {
    /**
     * The camera tries to focus on barcodes which are close to the camera. To scan far-
     * away codes (30-40cm+), user must tap the screen. This is the default working range
     * and works best for most use-cases. Only change the default value if you expect the
     * users to often scan codes which are far away.
     */
    SBSWorkingRangeStandard,
    /**
     * The camera tries to focus on barcodes which are far from the camera. This will make
     * it easier to scan codes that are far away but degrade performance for very close
     * codes.
     */
    SBSWorkingRangeLong,
    STANDARD_RANGE SBS_DEPRECATED SBS_NOT_AVAILABLE_IN_SWIFT = SBSWorkingRangeStandard,
    LONG_RANGE SBS_DEPRECATED SBS_NOT_AVAILABLE_IN_SWIFT = SBSWorkingRangeLong,
    /**
     * \deprecated This value has been deprecated in Scandit SDK 4.2+. Setting it has no effect.
     */
    HIGH_DENSITY SBS_DEPRECATED
} SBS_ENUM_END(SBSWorkingRange);

typedef SBSWorkingRange WorkingRange SBS_DEPRECATED SBS_NOT_AVAILABLE_IN_SWIFT;

/**
 * \brief Enumeration of different MSI Checksums
 *
 * \since 3.0.0
 */
SBS_ENUM_BEGIN(SBSMsiPlesseyChecksumType) {
    SBSMsiPlesseyChecksumTypeNone,
    SBSMsiPlesseyChecksumTypeMod10, /**< Default MSI Plessey Checksum */
    SBSMsiPlesseyChecksumTypeMod1010,
    SBSMsiPlesseyChecksumTypeMod11,
    SBSMsiPlesseyChecksumTypeMod1110,
    
    NONE SBS_NOT_AVAILABLE_IN_SWIFT SBS_DEPRECATED  = SBSMsiPlesseyChecksumTypeNone,
    CHECKSUM_MOD_10 SBS_NOT_AVAILABLE_IN_SWIFT SBS_DEPRECATED = SBSMsiPlesseyChecksumTypeMod10,
    CHECKSUM_MOD_1010 SBS_NOT_AVAILABLE_IN_SWIFT SBS_DEPRECATED = SBSMsiPlesseyChecksumTypeMod1010,
    CHECKSUM_MOD_11 SBS_NOT_AVAILABLE_IN_SWIFT SBS_DEPRECATED = SBSMsiPlesseyChecksumTypeMod11,
    CHECKSUM_MOD_1110 SBS_NOT_AVAILABLE_IN_SWIFT SBS_DEPRECATED = SBSMsiPlesseyChecksumTypeMod1110
} SBS_ENUM_END(SBSMsiPlesseyChecksumType);

typedef SBSMsiPlesseyChecksumType MsiPlesseyChecksumType SBS_DEPRECATED SBS_NOT_AVAILABLE_IN_SWIFT;


/**
 * \brief Enumeration of different GUI styles.
 *
 * \since 4.8.0
 */
SBS_ENUM_BEGIN(SBSGuiStyle) {
    /**
     * A rectangular viewfinder with rounded corners is shown in the specified size. Recognized 
     * codes are marked with four corners.
     */
    SBSGuiStyleDefault,
    /**
     * A laser line is shown with the specified width while the height is not changeable. This mode
     * should generally not be used if the recognition is running on the whole screen as it 
     * indicates that the code should be placed at the location of the laser line.
     */
    SBSGuiStyleLaser,
    /**
     * No UI is shown to indicate where the barcode should be placed. Be aware that the Scandit
     * logo continues to be displayed as showing it is part of the license agreement.
     *
     * Barcode locations are not highlighted when using this UI style. Use
     * \ref SBSGuiStyleLocationsOnly if you would like to see the barcode locations highlighted.
     */
    SBSGuiStyleNone,
    /**
     * The matrix scan UI is shown. In order to use this UI, it is required to set
     * SBSScanSettings::matrixScanEnabled to YES.
     *
     * \since 5.2.0
     */
    SBSGuiStyleMatrixScan,
    /**
     * Like \ref SBSGuiStyleNone, but barcode locations are highlighted in the UI.
     *
     * \since 5.3.0
     */
    SBSGuiStyleLocationsOnly,
} SBS_ENUM_END(SBSGuiStyle);


/**
 * \brief Error domain for the ScanditBarcodeScanner framework
 *
 * \since 4.11.0
 */
FOUNDATION_EXPORT NSString * const SBSErrorDomain;

/**
 * \brief enumeration of various error codes
 */
SBS_ENUM_BEGIN(SBSError) {
    /**
     * \brief An invalid argument has been passed to a method/function.
     */
    SBSErrorInvalidArgument = 1
} SBS_ENUM_END(SBSError);

