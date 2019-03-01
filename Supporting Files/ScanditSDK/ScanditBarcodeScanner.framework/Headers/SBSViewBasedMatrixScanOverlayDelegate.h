//
//  SBSViewBasedMatrixScanOverlayDelegate.h
//  ScanditBarcodeScanner
//
//  Created by Luca Torella on 02.03.18.
//  Copyright © 2018 Scandit. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SBSViewBasedMatrixScanOverlay;
@class SBSTrackedCode;

NS_ASSUME_NONNULL_BEGIN

/**
 * \brief Protocol used to change the view corresponding to .
 * \since 5.9.0
 */
@protocol SBSViewBasedMatrixScanOverlayDelegate <NSObject>

/**
 * \brief Method that will be used by the \link SBSViewBasedMatrixScanOverlay\endlink to set
 * a UIView for the augmentation corresponding to the given tracked barcode.
 * \param overlay       The view based overlay.
 * \param code          The tracked barcode.
 * \param identifier    Barcode identifier.
 * \return View for the given barcode.
 */
- (UIView *)viewBasedMatrixScanOverlay:(SBSViewBasedMatrixScanOverlay *)overlay
                           viewForCode:(SBSTrackedCode *)code
                        withIdentifier:(NSNumber *)identifier;

/**
 * \brief Method that will be used by the \link SBSViewBasedMatrixScanOverlay\endlink to set
 * an offset to the augmentation corresponding to the given tracked barcode.
 * \param overlay       The view based overlay.
 * \param code          The tracked barcode.
 * \param identifier    Barcode identifier.
 * \return Offset for the given barcode.
 */
- (UIOffset)viewBasedMatrixScanOverlay:(SBSViewBasedMatrixScanOverlay *)overlay
                         offsetForCode:(SBSTrackedCode *)code
                        withIdentifier:(NSNumber *)identifier;

@end

NS_ASSUME_NONNULL_END
