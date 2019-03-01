//
//  SBSViewBasedMatrixScanOverlay.h
//  ScanditBarcodeScanner
//
//  Created by Luca Torella on 02.03.18.
//  Copyright © 2018 Scandit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBSMatrixScanOverlay.h"

@class SBSTrackedCode;
@protocol SBSViewBasedMatrixScanOverlayDelegate;

NS_ASSUME_NONNULL_BEGIN

/**
 * \brief An implementation of MatrixScanOverlay, that uses UIView class instances
 * as augmentations for all of the tracked barcodes.
 * \since 5.9.0
 */
@interface SBSViewBasedMatrixScanOverlay : UIView <SBSMatrixScanOverlay>

/**
 * \brief The delegate invoked to set the UIView that will be shown over the tracked barcode.
 * \since 5.9.0
 */
@property (nonatomic, weak, nullable) id<SBSViewBasedMatrixScanOverlayDelegate> delegate;

/**
 * \brief Change the UIView shown over the tracked barcode.
 * \param view       UIView instance, to be used as an augmentation.
 * \param identifier Barcode identifier.
 * \since 5.9.0
 */
- (void)setView:(UIView *)view forCodeWithIdentifier:(NSNumber *)identifier;

/**
 * \brief Change the offset of the augmentation with respect to the center of the tracked code.
 * \param offset     The offset from the center of the tracked code.
 * \param identifier Barcode identifier.
 * \since 5.9.0
 */
- (void)setOffset:(UIOffset)offset forCodeWithIdentifier:(NSNumber *)identifier;

@end

NS_ASSUME_NONNULL_END
