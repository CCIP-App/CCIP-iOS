//
//  SBSBarcodePickerManager.h
//  ScanditBarcodeScanner
//
//  Created by Moritz Hartmeier on 05/06/15.
//  Copyright (c) 2015 Scandit AG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SBSBarcodePicker.h"


/**
 * \brief Manages a barcode picker instance, allocating and releasing it dependent on need.
 *
 * Alternatively to directly allocating a SBSBarcodePicker you can use an SBSBarcodePickerManager
 * to get a SBSBarcodePicker instance. By using the manager it is possible to allocate a picker when
 * the app knows that it will likely need to scan a barcode soon such that when the app actually
 * displays the picker the camera is already running and there is no delay for the user.
 *
 * There are three important concepts for understanding the functionality of the manager:
 * - Registering/unregistering need: An object can register need for the picker which will cause 
 * the manager to keep a running instance of the picker available for future use (by any object not 
 * just the registered one).
 * - Requesting/releasing picker: An object can request the picker to use it. The object does not
 * have to register need before requesting the picker directly. As only one object can ever use the
 * picker at the same time this call is asynchronous.
 * - Freeze/unfreeze picker:
 *
 * **Important:** Be aware that the manager caches the running camera to be able to eliminate the 
 * delay that would be needed to start the camera this will lead to increased battery usage.
 */
@interface SBSBarcodePickerManager : NSObject

/**
 * The time in seconds until the picker is deallocated after the last object that has registered 
 * need unregistered and there are no more objects with registered need for the picker. If no need
 * is registered but the picker was requested and is currently in use it will never be deallocated.
 *
 * It is generally not a good idea to set this to 0 seconds as there may be times (for example when
 * animating between view controllers) where there is no need for a split second.
 *
 * By default this is set to 3.
 */
@property (nonatomic, assign) NSTimeInterval timeToDeallocAfterNoNeed;

/**
 * The time in seconds until the picker is deallocated after the last function call on the manager.
 * This comes mostly into play if the app registers need for the picker but then does not actually
 * use the picker for a prolonged time. In this case it is economical to deallocate the picker as
 * we expect it to not be requested in the near future.
 *
 * If the picker was requested and is in use it will never be deallocated no matter how much time
 * has passed.
 *
 * By default this is set to 30. Setting it to 0 causes the manager to never deallocate the picker
 * while an object has registered need.
 */
@property (nonatomic, assign) NSTimeInterval timeToDeallocAfterAction;

+ (nonnull instancetype)manager;

/**
 * \brief Registers need for the specified object in case the picker will be used in the near future.
 *
 * To unregister call unregisterNeedByObject: with the same object that this function was called 
 * with. Unless unregisterNeedByObject: is called with every object that registerNeedByObject: was
 * called with, the picker will stay cached (unless no functions are called on the manager and
 * timeToDeallocAfterAction time passes).
 *
 * \param anObject The object for which need is registered.
 */
- (void)registerNeedByObject:(nonnull id)anObject;

/**
 * \brief Unregisters need for the specified object when the picker will likely not be used in the
 * near future.
 *
 * Unless unregisterNeedByObject: is called with every object that registerNeedByObject: was
 * called with, the picker will stay cached (unless no functions are called on the manager and
 * timeToDeallocAfterAction time passes). Calling this multiple times with the same object or with 
 * an object for which registerNeedByObject: was never called has no effect.
 *
 * \param anObject The object for which need is unregistered.
 */
- (void)unregisterNeedByObject:(nonnull id)anObject;

/**
 * \brief Requests the picker for the specified object to display it and start scanning.
 *
 * As the picker might still be used by a different object it is returned asynchronously through a
 * block when it is no longer in use (possibly instantly).
 *
 * To release call releasePickerForObject: with the same object that this function was called with.
 * Unless releasePickerForObject: is called for the same object the picker will stay locked and
 * future calls to this function will never invoke the requestBlock.
 *
 * \param anObject The object for which the picker is requested.
 * \param settings The settings to be applied to the picker.
 * \param requestBlock The block that is called when the picker is available.
 */
- (void)requestPickerForObject:(nonnull id)anObject
              withScanSettings:(nonnull SBSScanSettings *)settings
                  successBlock:(nullable void(^)(SBSBarcodePicker * _Nonnull picker))requestBlock;

/**
 * \brief Releases the picker for the specified object when it no longer needs to be displayed.
 *
 * Unless releasePickerForObject: is called for the same object the picker will stay locked and
 * future calls to this function will never invoke the requestBlock. Calling this multiple times
 * with the same object or with an object for which 
 * requestPickerForObject:withScanSettings:successBlock: was never called has no effect.
 *
 * Make sure that before you release the picker it is entirely removed from the view and view
 * controller hierarchy.
 *
 * \param anObject The object for which the picker is released.
 */
- (void)releasePickerForObject:(nonnull id)anObject;

/**
 * \brief Freezes the picker's camera to allow other camera objects to be opened.
 *
 * Use this to allow another camera instance to be opened like a UIImagePickerController.
 *
 * To unfreeze call unfreezePickerForObject: with the same object that this function was called
 * with. Unless unfreezePickerForObject: is called with every object that freezePickerForObject: was
 * called with, the picker will stay frozen.
 *
 * \param anObject The object for which the picker is frozen.
 */
- (void)freezePickerForObject:(nonnull id)anObject;

/**
 * \brief Unfreezes the picker's camera after other camera objects have been closed.
 *
 * Unless unfreezePickerForObject: is called with every object that freezePickerForObject: was
 * called with, the picker will stay frozen. Calling this multiple times with the same object or 
 * with an object for which freezePickerForObject: was never called has no effect.
 *
 * \param anObject The object for which the picker is unfrozen.
 */
- (void)unfreezePickerForObject:(nonnull id)anObject;

@end

