//
//  SBSScanAreaSettings.h
//  ScanditBarcodeScanner
//
//  Created by Marco Biasini on 27/09/16.
//  Copyright © 2016 Scandit AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

#import "SBSCommon.h"

/**
 * \brief Code location constraint.
 *
 * The code location constraint influences how the wide and square code location areas are
 * interpreted.
 *
 * \since 5.0
 */
SBS_ENUM_BEGIN(SBSCodeLocationConstraint) {
    /**
     * \brief Decoding is restricted to this area.
     *
     * Codes are no longer searched in \ref SBSScanAreaSettings#searchArea.
     *
     * \since 5.0
     */
    SBSCodeLocationConstraintRestrict = 0x01,
    /**
     * \brief The code location area is a hint.
     *
     * The code location area is a hint, higher priority is given to codes in this area, but codes 
     * continue to be searched in \ref SBSScanAreaSettings#searchArea.
     *
     * \since 5.0
     */
    SBSCodeLocationConstraintHint = 0x02,
    
    /**
     * \brief The area can be defined but will not be used by the barcode scanner
     *
     * \since 5.5
     */
    SBSCodeLocationConstraintIgnore = 0x03,
} SBS_ENUM_END(SBSCodeLocationConstraint);

/**
 * \brief An enum describing possible directions on the screen
 *
 * \since 5.1
 */
SBS_ENUM_BEGIN(SBSDirection) {
    /**
     * \brief Horizontal direction
     *
     * \since 5.1
     */
    SBSDirectionHorizontal = 0x01,
    /**
     * \brief Vertical direction
     *
     *
     * \since 5.1
     */
    SBSDirectionVertical = 0x02,
} SBS_ENUM_END(SBSDirection);

/**
 * \brief Scanning area settings control where codes are to be searched in images/frames.
 *
 * The areas as well as the hot-spot is specified in relative coordinates. The coordinates are rotated
 * with the device: The top-left corner of the camera preview is 0,0, whereas 1,1 is the bottom-right
 * corner. Coordinates specified outside of the supported range raise an exception.
 *
 * For most use-cases, the "active scanning area portrait/active scanning area landscape" available as
 * part of the \ref SBSScanSettings is sufficient and is simpler to use. We only recommend to use the
 * \ref SBSScanAreaSettings if you have very specific needs for your application that can't be met 
 * with the "active scanning area" interface.
 *
 * This class allows to control the areas separately for wide and square symbologies. Classification
 * of symbologies into square and wide is according to their aspect ratio: symbologies that have a
 * width/height ratio different from one (1d codes, PDF417, etc.) are classified as wide, symbologies 
 * whose width/height aspect ratio is close to 1.0 (QR, Aztec etc.) are classified as square. 
 * Symbologies whose aspect ratio can vary, e.g. DataMatrix, or DataBar, are classified according to 
 * their pre-dominant aspect ratio.
 *
 * \note This interface is not part of the stable API yet and is subject to change. Functionality 
 *      may dissappear, or change in future releases.
 * \since 5.0
 */
@interface SBSScanAreaSettings : NSObject


/**
 * \brief Returns a new instance with default settings for portrait scanning.
 *
 * \since 5.0
 */
+(nonnull instancetype)defaultPortraitSettings;


/**
 * \brief Returns a new instance with default settings for landscape scanning.
 *
 * \since 5.0
 */
+(nonnull instancetype)defaultLandscapeSettings;

/**
 * \brief Create scan area settings from a JSON object.
 *
 * \param dict the JSON object. The following keys are understood: \c wideCodeLocationArea and
 *    \c squareCodeLocationArea can be used to specify the code location area rectangles.
 *    The rectangles can either be objects with \c x, \c y, \c width and \c height key-value pairs,
 *    or a list of four floating-point values ordered as [x, y, width, height].
 *    \c squareCodeLocationConstraint and \c wideCodeLocationConstraint can be used to set the
 *    the respective constraint for the areas. The strings \c restrict and \c hint are mapped to
 *    their enum counter-part. \c primaryDirection can either be set to \c vertical or
 *    \c horizontal to specify the primary direction for scanning. Additional keys are ignored.
 *    Keys which are not set are left as default values.
 * \param error in case of an invalid JSON dictionary, \p error will contain more details on the 
 *      error.
 * \return The scan area settings, or null if it could not be parsed.
 *
 * \since 5.1.0
 */
+ (nullable instancetype)settingsWithDictionary:(nonnull NSDictionary<NSString *, id> *)dict
                                          error:(NSError * _Nullable * _Nullable)error;

/**
 * \brief The area in which codes are searched.
 *
 * By default, codes are searched in the whole image.
 *
 * \since 5.0
 */
@property (assign, nonatomic) CGRect searchArea;

/**
 * \brief Code location area for wide codes.
 *
 * \since 5.0
 */
@property (assign, nonatomic) CGRect wideCodesLocationArea;

/**
 * \brief Code location constraint for wide codes
 *
 * \since 5.0
 */
@property (assign, nonatomic) SBSCodeLocationConstraint wideCodesLocationConstraint;

/**
 * \brief Code location area for square codes
 *
 * \since 5.0
 */
@property (assign, nonatomic) CGRect squareCodesLocationArea;

/**
 * \brief Code location constraint for square codes
 *
 * \since 5.0
 */
@property (assign, nonatomic) SBSCodeLocationConstraint squareCodesLocationConstraint;

/**
 * \brief The primary direction to be used for scanning
 *
 * The primary direction for scanning. By default, preference is given to codes in horizontal
 * direction. Change this to \ref SBSDirectionVertical to optimize the engine for scanning
 * vertical codes. This only incluences recognition of wide codes and has no influence on
 * square codes.
 *
 * \since 5.1
 */
@property (assign, nonatomic) SBSDirection primaryDirection;


@end
