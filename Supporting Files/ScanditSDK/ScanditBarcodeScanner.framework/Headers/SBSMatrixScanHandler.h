//
//  SBSMatrixScanHandler.h
//  ScanditBarcodeScanner
//
//  Created by Luca Torella on 01.03.18.
//  Copyright © 2018 Scandit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBSCommon.h"

@protocol SBSMatrixScanDelegate;
@protocol SBSMatrixScanOverlay;
@class SBSBarcodePicker;

NS_ASSUME_NONNULL_BEGIN

/**
 * \brief An high-level abstraction of the Scandit Matrix Scan.
 *
 * This class can be used to track multiple barcodes simultaneously and to draw multiple augmentations
 * on top of the detected barcodes.
 * \since 5.9.0
 */
@interface SBSMatrixScanHandler : NSObject

/**
 * \brief The delegate invoked when a new frame is proccessed.
 * \since 5.9.0
 */
@property (nonatomic, weak, nullable) id<SBSMatrixScanDelegate> delegate;

/**
 * \brief Set to YES if only recognized barcodes will be tracked by the matrix scan. Default is YES.
 * \since 5.9.0
 */
@property (nonatomic, assign) BOOL recognizedOnly;

/**
 * \brief Set to NO if you want to stop moving/updating the augmentations. Default is YES.
 * \since 5.9.0
 */
@property (nonatomic, assign) BOOL enabled;

/**
 * \brief Set to YES to beep whenever a new code is recognized. Default is NO.
 * \since 5.9.0
 */
@property (nonatomic, assign) BOOL beepOnNewCode;

+ (instancetype)new NS_UNAVAILABLE;

/**
 * \brief SBSMatrixScanHandler desginated initializer.
 * \param picker   Underlying \link SBSBarcodePicker\endlink to be used by \link SBSMatrixScanHandler\endlink.
 * \since 5.9.0
 */
- (instancetype)initWithPicker:(nullable SBSBarcodePicker *)picker SBS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/**
 * \brief Add a \link SBSMatrixScanOverlay\endlink on top of the picker.
 * \param overlay The overlay that needs to be added on top of the picker.
 * \since 5.9.0
 */
- (void)addOverlay:(UIView<SBSMatrixScanOverlay> *)overlay;

/**
 * \brief Remove the given overlay.
 * \param overlay The overlay that needs to be removed.
 * \since 5.9.0
 */
- (void)removeOverlay:(UIView<SBSMatrixScanOverlay> *)overlay;

/**
 * \brief Remove all augmentations of every overlay.
 *
 * This method will call the \link SBSMatrixScanOverlay.removeAllAugmentations\endlink method on every overlay.
 *
 * \since 5.9.0
 */
- (void)removeAllAugmentations;

/**
 * \brief Programmatically trigger a beep sound.
 * \since 5.9.0
 */
- (void)beep;

@end

NS_ASSUME_NONNULL_END
