//
//  SBSTrackedCode.h
//  ScanditBarcodeScanner
//
//  Created by Luca Torella on 20.01.17.
//  Copyright © 2017 Scandit AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBSCode.h"

/**
 * \brief Represents a recognized/localized barcode/2D code that is being tracked over multiple frames.
 *
 * The SBSTrackedCode class represents a barcode, or 2D code that is being tracked over multiple frames
 * by the barcode recognition engine.
 */
@interface SBSTrackedCode : SBSCode

/**
 * \brief The predicted location of the tracked code.
 *
 * The location where the tracked code is predicted to be in SBSTrackedCode#deltaTimeForPrediction
 *
 * \since 5.2.0
 *
 */
@property (nonatomic, readonly) SBSQuadrilateral predictedLocation;

/**
 * \brief The delta time for the predicted location of the code in seconds.
 *
 * The time (in seconds) it will take the tracked code to move to the predicted location 
 * (SBSTrackedCode#predictedLocation). This value can be used to animate the predicted change of 
 * location of the tracked code.
 *
 * \since 5.2.0
 *
 */
@property (nonatomic, readonly) NSTimeInterval deltaTimeForPrediction;

/**
 * \brief Whether the change in location should be animated.
 *
 * As there are state transitions that do not guarantee a stable ordering of the location's
 * corners you should always check this function before animating a location change.
 *
 * \since 5.2.0
 */
@property (nonatomic, readonly) BOOL shouldAnimateFromPreviousToNextState;

@end
