//
//  SBSMatrixScanDelegate.h
//  ScanditBarcodeScanner
//
//  Created by Luca Torella on 02.03.18.
//  Copyright © 2018 Scandit. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SBSMatrixScanHandler;
@class SBSFrame;
@class SBSTrackedCode;

NS_ASSUME_NONNULL_BEGIN

/**
 * \brief The protocol used by \link SBSMatrixScanHandler\endlink instance.
 * \since 5.9.0
 */
@protocol SBSMatrixScanDelegate <NSObject>

/**
 * \brief Method invoked by \link SBSMatrixScanHandler\endlink instance every time
 * a \link SBSFrame\endlink is being processed.
 * \since 5.9.0
 */
- (void)matrixScanHandler:(SBSMatrixScanHandler *)handler didProcessFrame:(SBSFrame *)frame;

/**
 * \brief Method which can be used to define an extra condition for rejecting a barcode.
 *
 * It will be invoked by \link SBSMatrixScanHandler\endlink every time a new barcode is recognized.
 * \since 5.9.0
 */
- (BOOL)matrixScanHandler:(SBSMatrixScanHandler *)handler shouldRejectCode:(SBSTrackedCode *)code;

@end

NS_ASSUME_NONNULL_END
