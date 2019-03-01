//
//  SBSMatrixScanOverlay.h
//  ScanditBarcodeScanner
//
//  Created by Luca Torella on 02.03.18.
//  Copyright © 2018 Scandit. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SBSTrackedCode;
@class SBSBarcodePicker;

NS_ASSUME_NONNULL_BEGIN

/**
 * \brief The protocol overlays need to conform to.
 *
 * MatrixScan's overlays should conform to this protocol in order to be added via the
 * \link SBSMatrixScanHandler#addOverlay:\endlink method. \link SBSSimpleMatrixScanOverlay\endlink
 * and \link SBSViewBasedMatrixScanOverlay\endlink both conform to this protocol.
 * In general, it should not be necessary to create a custom overlay.
 *
 * \since 5.9.0
 */
@protocol SBSMatrixScanOverlay

/**
 * \brief The SBSBarcodePicker instance.
 * \since 5.9.0
 */
@property (nonatomic, weak, nullable) SBSBarcodePicker *picker;

/**
 * \brief Remove augmentations that are part of the MatrixScanOverlay.
 * \since 5.9.0
 */
- (void)removeAllAugmentations;

/**
 * \brief Add a new augmentation for the given code.
 *
 * The new augmentation should have an identifier equal to the given id.
 *
 * \param code SBSTrackedCode to be used to generate the new augmentation.
 * \param identifier Identifier for the new augmentation.
 * \since 5.9.0
 */
- (void)addCode:(SBSTrackedCode *)code withIdentifier:(NSNumber *)identifier;

/**
 * \brief Update (recreate) an existing augmentation with given id for the given code.
 * \param code SBSTrackedCode to be used to recreate the augmentation.
 * \param identifier Identifier of an augmentation that should be updated.
 * \since 5.9.0
 */
- (void)updateCode:(SBSTrackedCode *)code withIdentifier:(NSNumber *)identifier;

/**
 * \brief Remove an existing augmentation with the given identifier from the MatrixScanOverlay.
 * \param identifier    Identifier of an augmentation that should be removed.
 * \since 5.9.0
 */
- (void)removeCodeWithIdentifier:(NSNumber *)identifier;

@end

NS_ASSUME_NONNULL_END
