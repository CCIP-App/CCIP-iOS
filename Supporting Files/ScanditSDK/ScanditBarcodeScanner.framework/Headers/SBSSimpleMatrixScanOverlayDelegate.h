//
//  SBSSimpleMatrixScanOverlayDelegate.h
//  ScanditBarcodeScanner
//
//  Created by Luca Torella on 02.03.18.
//  Copyright © 2018 Scandit. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SBSSimpleMatrixScanOverlay;
@class SBSTrackedCode;

NS_ASSUME_NONNULL_BEGIN

/**
 * \brief Protocol used to set the color of an augmentation or to react when an augmentation is touched.
 * \since 5.9.0
 */
@protocol SBSSimpleMatrixScanOverlayDelegate <NSObject>

/**
 * \brief Method that will be used by the \link SBSSimpleMatrixScanOverlay\endlink to set
 * a color of the augmentation corresponding to the given tracked barcode.
 * \param overlay       The simple overlay.
 * \param code          The barcode.
 * \param identifier    Barcode identifier.
 * \return Color to be used by the augmentation for the given barcode.
 * \since 5.9.0
 */
- (UIColor *)simpleMatrixScanOverlay:(SBSSimpleMatrixScanOverlay *)overlay
                        colorForCode:(SBSTrackedCode *)code
                      withIdentifier:(NSNumber *)identifier;

/**
 * \brief Method that will be called by the \link SBSSimpleMatrixScanOverlay\endlink once the given tracked barcode is
 * touched.
 * \param overlay       The simple overlay.
 * \param code          A \link SBSTrackedCode\endlink instance.
 * \param identifier    Barcode identifier.
 * \since 5.9.0
 */
- (void)simpleMatrixScanOverlay:(SBSSimpleMatrixScanOverlay *)overlay
                     didTapCode:(SBSTrackedCode *)code
                 withIdentifier:(NSNumber *)identifier;

@end

NS_ASSUME_NONNULL_END
