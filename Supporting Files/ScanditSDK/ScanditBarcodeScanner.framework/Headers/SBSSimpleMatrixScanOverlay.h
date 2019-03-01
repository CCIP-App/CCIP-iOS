//
//  SBSSimpleMatrixScanOverlay.h
//  ScanditBarcodeScanner
//
//  Created by Luca Torella on 02.03.18.
//  Copyright © 2018 Scandit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBSMatrixScanOverlay.h"

@class SBSTrackedCode;
@protocol SBSSimpleMatrixScanOverlayDelegate;

NS_ASSUME_NONNULL_BEGIN

/**
 * \brief A simple implementation of the abstract SBSMatrixScanOverlay class, that draws colorful,
 * rectangle overlays on top of tracked barcodes.
 * \since 5.9.0
 */
@interface SBSSimpleMatrixScanOverlay : UIView <SBSMatrixScanOverlay>

/**
 * \brief The delegate invoked to set the color of an augmentation and when an augmentation is tapped.
 * \since 5.9.0
 */
@property (nonatomic, weak, nullable) id<SBSSimpleMatrixScanOverlayDelegate> delegate;

/**
 * \brief Set to YES to make augmentations tappable. Default is NO.
 * \since 5.9.0
 */
@property (nonatomic, assign) BOOL userTapEnabled;

/**
 * \brief Change the color of the augmentation corresponding to the given identifier.
 * \param color      The color for the augmentation.
 * \param identifier The barcode identifier.
 * \since 5.9.0
 */
- (void)setColor:(UIColor *)color forCodeWithIdentifier:(NSNumber *)identifier;

/**
 * \brief Change the color of all augmentations.
 * \param color Color for the augmentations.
 * \since 5.9.0
 */
- (void)setAllAugmentationColors:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
