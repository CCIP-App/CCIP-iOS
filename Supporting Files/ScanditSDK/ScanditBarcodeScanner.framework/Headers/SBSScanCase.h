//
//  SBSScanCase.h
//  ScanditBarcodeScanner
//
//  Created by Luca Torella on 17/02/16.
//  Copyright © 2016 Scandit AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "SBSCommon.h"
#import "SBSScanCaseState.h"

@class SBSScanCaseSettings;
@protocol SBSScanCaseDelegate;

/**
 * \brief Start a scanner for the Scandit case.
 *
 * SBSScanCase is a subclass of NSObject and it does not need to be added to the view hierarchy.
 *
 * Example (minimal) usage:
 *
 * \code
 *
 * // Set your app key on the license first.
 * [SBSLicense setAppKey:kScanditBarcodeScannerAppKey];
 *
 * // Create the settings used for the scan case.
 * SBSScanCaseSettings *settings = [[SBSScanCaseSettings alloc] init];
 *
 * // Enable symbologies etc.
 * [scanSettings setSymbology:SBSSymbologyEAN13 enabled:YES];
 *
 * // Instantiate the scan case and keep a strong reference to it until needed.
 * self.scanCase = [SBSScanCase acquireWithSettings:settings delegate:self];
 *
 * \endcode
 *
 * \since 4.13.0
 */
@interface SBSScanCase : NSObject

/**
 * \brief The delegate for this scan case.
 *
 * - SBSScanCaseDelegate#didInitializeScanCase: is called when the scan case finished the initalization process.
 * - SBSScanCaseDelegate#scanCase:didScan: is invoked whenever a new code is scanned.
 * - SBSScanCaseDelegate#scanCase:didChangeState:reason: is invoked whenever SBSScanCase::state changed.
 *
 * \since 4.13.0
 */
@property (nonatomic, weak, readwrite, nullable) id<SBSScanCaseDelegate> delegate;

/**
 * \brief The state of the scan case.
 *
 * Get or set the state of the scan case. Possible states:
 * - \ref SBSScanCaseStateOff to stop the scanner (camera off, torch off);
 * - \ref SBSScanCaseStateStandby to pause the scanner in order to save power but be ready to resume scanning
 *   (camera on but with throttled frame-rate, scanner off, torch off);
 * - \ref SBSScanCaseStateActive to start scanning (camera on, scanner on, torch on).
 *
 * After the initialization the default state is \ref SBSScanCaseStateStandby.
 * This property is thread safe.
 *
 * \since 4.13.0
 */
@property (nonatomic, assign, readwrite) SBSScanCaseState state;

/**
 * \brief Turn on/off scanning via the volume button
 *
 * Set to YES to change the state of the scan case using the volume button 
 * (holding the volume button changes the state to \ref SBSScanCaseStateActive,
 * while releasing it changes the state to \ref SBSScanCaseStateStandby).
 * Set to NO to avoid controlling the state of the scan case via the volume button.
 *
 * The default value is NO.
 *
 * \since 4.13.0
 */
@property (nonatomic, assign, readwrite) BOOL volumeButtonToScanEnabled;

/**
 * \brief The duration in seconds for which the scanner should remain in active state after the 
 *     volume button has been released.
 *
 * The value is clamped to be at least 0.93 seconds. The default value is 0.93 seconds.
 * \since 5.3.1
 */
@property (nonatomic, assign, readwrite) NSTimeInterval activateDurationAfterVolumeButtonRelease;

/**
 * \brief Initializes a new scan case.
 *
 * Note that the initial invocation of this method will activate the Scandit Barcode Scanner SDK,
 * after which the device will count towards your device limit.
 *
 * Make sure to set the app key available from your Scandit account through SBSLicense#setAppKey:
 * before you call this initializer.
 *
 * This is the recommended way to create a new SBSScanCase object.
 *
 * \param settings The scan settings to use. You may pass nil, which is identical to passing a
 *     settings instance constructed through SBSScanSettings#defaultSettings.
 * \param delegate The scan case delegate.
 *
 * \return The newly constructed scan case instance.
 *
 * \since 4.13.0
 */
+ (nonnull instancetype)acquireWithSettings:(nullable SBSScanCaseSettings *)settings delegate:(nullable id<SBSScanCaseDelegate>)delegate;

/**
 * \brief The designated initializer for instantiating a new scan case.
 *
 * Note that the initial invocation of this method will activate the Scandit Barcode Scanner SDK,
 * after which the device will count towards your device limit.
 *
 * Make sure to set the app key available from your Scandit account through SBSLicense#setAppKey:
 * before you call this initializer.
 *
 * \param settings The scan settings to use. You may pass nil, which is identical to passing a
 *     settings instance constructed through SBSScanSettings#defaultSettings.
 * \param delegate The scan case delegate.
 *
 * \return The newly constructed scan case instance.
 *
 * \since 4.13.0
 */
- (nonnull instancetype)initWithSettings:(nullable SBSScanCaseSettings *)settings
                                delegate:(nullable id<SBSScanCaseDelegate>)delegate SBS_DESIGNATED_INITIALIZER;

/**
 * \brief A convenience initializer for instantiating a new scan case.
 *
 * Note that the initial invocation of this method will activate the Scandit Barcode Scanner SDK,
 * after which the device will count towards your device limit.
 *
 * Make sure to set the app key available from your Scandit account through SBSLicense#setAppKey:
 * before you call this initializer.
 *
 * Note that the delegate must be set in order to receive scan events.
 *
 * \param settings The scan settings to use. You may pass nil, which is identical to passing a
 *     settings instance constructed through SBSScanSettings#defaultSettings.
 *
 * \return The newly constructed scan case instance.
 *
 * \since 5.2.0
 */
- (nonnull instancetype)initWithSettings:(nullable SBSScanCaseSettings *)settings;

/**
 * \brief Change the scan settings of an existing picker instance.
 *
 * The scan settings are applied asynchronously after this call returns. You may use the completion
 * handler to get notified when the settings have been applied to the picker. All frames processed
 * after the settings have been applied will use the new scan settings.
 *
 * \param settings The new scan settings to apply.
 * \param completionHandler An optional block that will be invoked when the settings have been
 *    applied to the picker. The block will be invoked on an internal picker dispatch queue.
 *
 * \since 4.13.0
 */
- (void)applySettings:(nonnull SBSScanCaseSettings *)settings
    completionHandler:(nullable void (^)(void))completionHandler;

/**
 * \brief Set a timeout to automatically change state after a specific interval.
 *
 * Set a timer that is started whenever the state is changed to fromState. 
 * The timer will have a time interval equal to timeout and then it will switch the state of the 
 * scan case to toState. The timer will be created every time the state of the scan case is equal to 
 * fromState.
 * At any given time there could not be more than one timeout for each fromState.
 *
 * Note that this method is actually calling SBSScanCase::setTimeout:tolerance:fromState:toState:
 * with 0 as tolerance. Please also note that in most of the cases it is better to set a tolerance 
 * higher than 0, as it gives the system more flexibility to schedule the firing date and increases 
 * responsiveness.
 *
 * \param timeout The interval of the timer.
 * \param fromState The state from which the timer should start.
 * \param toState The new state when the timer is fired.
 *
 * \since 4.13.0
 */
- (void)setTimeout:(NSTimeInterval)timeout
         fromState:(SBSScanCaseState)fromState
           toState:(SBSScanCaseState)toState;

/**
 * \brief Set a timeout to automatically change state after a specific interval.
 *
 * Set a timer that is started whenever the state is changed to fromState.
 * The timer will have a time interval equal to timeout and then it will switch the state of the scan case to toState.
 * The timer will be created every time the state of the scan case is equal to fromState.
 * At any given time there could not be more than one timeout for each fromState.
 *
 * Please also note that in most of the cases it is better to set a tolerance higher than 0, 
 * as it gives the system more flexibility to schedule the firing date and increases responsiveness.
 *
 * \param timeout The interval of the timer.
 * \param tolerance The tolerance of the timer.
 * \param fromState The state from which the timer should start.
 * \param toState The new state when the timer is fired.
 *
 * \since 4.13.0
 */
- (void)setTimeout:(NSTimeInterval)timeout
         tolerance:(NSTimeInterval)tolerance
         fromState:(SBSScanCaseState)fromState
           toState:(SBSScanCaseState)toState;

/**
 * \brief Remove a previously set timeout.
 *
 * Remove a previously set timeout to avoid starting a new timer when the state is changed to fromState.
 *
 * \param fromState The state from which the timer should start.
 *
 * \since 4.13.0
 */
- (void)removeTimeoutFromState:(SBSScanCaseState)fromState;

/**
 * \brief The camera preview
 *
 * Use this accessor if you would like to display a camera preview when using the scan case.
 *
 * \since 4.14
 */
@property (nonnull, nonatomic, readonly, strong) UIViewController *cameraPreview;

/**
 * \brief Whether to play a beep sound upon a successful scan.
 * 
 * By default, a beep sound is played upon successfully scanning a barcode. Set this property to 
 * NO, to disable the sound. If the ringer mode is set to silent, no beep sound is played,
 * regardless of the value of this property.
 *
 * \since 5.3.1
 */
@property (nonatomic, assign) BOOL scanBeepEnabled;

/**
 * \brief Whether to play an error sound when no code was scanned.
 *
 * By default, an error sound is played when activating the scanner using the volume button control 
 * when no could be scanned. If the ringer mode is set to silent, no sound is played, regardless of 
 * the value of this property.
 *
 * \since 5.3.1
 */
@property (nonatomic, assign) BOOL errorSoundEnabled;

/**
 * \brief Sets the audio sound played when a code has been successfully recognized.
 *
 * The file needs to be included in the application bundle.
 *
 * The default is: "beep.wav"
 *
 * \since 5.3.1
 *
 * \param path The file name of the sound file (without suffix).
 * \param extension The file type.
 * \return Whether the change was successful.
 */
- (BOOL)setScanSoundResource:(nonnull NSString *)path ofType:(nonnull NSString *)extension;

/**
 * \brief Sets the audio sound played when no code was recognized
 *
 * This sound file is played when controlling the scan case with the volume button and no code was 
 * scanned.
 * 
 * The file needs to be included in the application bundle.
 *
 * The default is: "error.wav"
 *
 * \since 5.3.1
 *
 * \param path The file name of the sound file (without suffix).
 * \param extension The file type.
 * \return Whether the change was successful.
 */
- (BOOL)setErrorSoundResource:(nonnull NSString *)path ofType:(nonnull NSString *)extension;

@end
