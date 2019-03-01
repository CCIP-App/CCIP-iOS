//
//  SBSPropertyObserver.h
//  ScanditBarcodeScanner
//
//  Created by Marco Biasini on 15/04/16.
//  Copyright © 2016 Scandit AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SBSBarcodePicker;

/**
 * \brief Defines the protocol for an observer of property changes
 *
 * This API is experimental. There are no API stability guarantees at this point and the
 * functionality might disappear or change in future releases.
 *
 * \since 4.14.0
 */
@protocol SBSPropertyObserver

/**
 * \brief Method invoked when a property changed to a new value.
 *
 * The property is invoked in the calling thread, so make sure to move any UI work to the main 
 * thread.
 */
- (void)barcodePicker:(nonnull SBSBarcodePicker *)barcodePicker
             property:(nonnull NSString *)property
       changedToValue:(nullable NSObject *)value;

@end
