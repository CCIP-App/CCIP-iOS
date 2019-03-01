//
//  SBSOverlayController.h
//  ScanditBarcodeScanner
//
//  Created by Marco Biasini on 09/06/15.
//  Copyright (c) 2015 Scandit AG. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * \brief controls the scan screen user interface.
 *
 *
 * The overlay controller can be used to configure various scan screen UI elements such as
 * toolbar, torch, camera switch icon, scandit logo and the viewfinder.
 *
 * Developers can inherit from the SBSOverlayController to implement their own
 * scan screen user interfaces.
 *
 * \since 1.0.0
 *
 * Copyright 2010 Mirasense AG. All rights reserved.
 */

#import <UIKit/UIKit.h>
#import "AudioToolbox/AudioServices.h"

#import "SBSCommon.h"

@class SBSOverlayController;
@class SBSBarcodePicker;

/**
 * \brief Protocol cancel events
 * \ingroup scanditsdk-ios-api
 * \since 4.7.0
 */
@protocol SBSOverlayControllerDidCancelDelegate

/**
 * \brief Is called when the user clicks the cancel button in the scan user interface.
 *
 * Typically implementations will stop the scanning and dismiss the barcode picker when the user
 * hits the cancel button.
 *
 * \since 4.7.0
 *
 * \param overlayController SBSOverlayController that is delegating
 * \param status dictionary (currently empty)
 *
 */
- (void)overlayController:(nonnull SBSOverlayController *)overlayController
      didCancelWithStatus:(nullable NSDictionary *)status;

@end

/**
 * Enumeration of different camera switch options.
 *
 * \since 3.0.0
 */
SBS_ENUM_BEGIN(SBSCameraSwitchVisibility) {
    SBSCameraSwitchVisibilityNever,
    SBSCameraSwitchVisibilityOnTablet,
    SBSCameraSwitchVisibilityAlways,
    CAMERA_SWITCH_NEVER SBS_DEPRECATED = SBSCameraSwitchVisibilityNever,
    CAMERA_SWITCH_ON_TABLET SBS_DEPRECATED = SBSCameraSwitchVisibilityOnTablet,
    CAMERA_SWITCH_ALWAYS SBS_DEPRECATED = SBSCameraSwitchVisibilityAlways
} SBS_ENUM_END(SBSCameraSwitchVisibility);

/**
 * Enumeration of different highlighting state of locations when using matrix scan.
 *
 * \since 5.2.0
 */
SBS_ENUM_BEGIN(SBSMatrixScanHighlightingState) {
    SBSMatrixScanHighlightingStateLocalized,
    SBSMatrixScanHighlightingStateRecognized,
    SBSMatrixScanHighlightingStateRejected,
} SBS_ENUM_END(SBSMatrixScanHighlightingState);

typedef SBSCameraSwitchVisibility CameraSwitchVisibility SBS_DEPRECATED;


/**
 * \brief  controls the scan screen user interface.
 *
 * The overlay controller can be used to configure various scan screen UI elements such as
 * toolbar, torch, camera switch icon, scandit logo and the viewfinder.
 *
 * Developers can inherit from the SBSOverlayController to implement their own scan screen 
 * user interfaces.
 *
 * \ingroup scanditsdk-ios-api
 *
 * \since 4.7.0
 *
 * \nosubgrouping
 *
 *  Copyright 2010 Mirasense AG. All rights reserved.
 */
@interface SBSOverlayController : UIViewController


/**
 * \brief The tool bar that can be shown at the bottom of the scan screen.
 *
 * \since 1.0.0
 */
@property (nullable, nonatomic, strong, readonly) UIToolbar *toolBar;

/**
 * \brief The overlay controller delegate that handles the didCancelWithStatus callback.
 *
 * \since 4.7.0
 */
@property (nullable, nonatomic, weak) id<SBSOverlayControllerDidCancelDelegate> cancelDelegate;

/**
 * \brief The GUI style drawn to display the indicator where the code should be scanned and the
 * visualization of recognized codes.
 *
 * By default this is SBSGuiStyleDefault.
 *
 * \since 4.8.0
 */
@property (nonatomic, assign) SBSGuiStyle guiStyle;

/** \name Sound Configuration
 *  Customize the scan sound.
 */
///\{

/**
 * \brief Whether to play a sound when a barcode is recognized. If the phone's ring mode
 * is set to muted or vibrate, no beep will be played regardless of the value.
 *
 * Enabled by default.
 *
 * \since 5.3.1
 */
- (BOOL)beepEnabled;

/**
 * \brief See \ref beepEnabled
 *
 * \since 1.0.0
 */
- (void)setBeepEnabled:(BOOL)enabled;


/**
 * \brief Whether the device should vibrate when a code was recognized.
 *
 * Enabled by default.
 *
 * \since 5.3.1
 */
 - (BOOL)vibrateEnabled;

/**
 * \brief See \ref vibrateEnabled
 *
 * \since 1.0.0
 */
- (void)setVibrateEnabled:(BOOL)enabled;

/**
 * \brief Sets the audio sound played when a code has been successfully recognized.
 *
 * File needs to be placed in Resources folder.
 *
 * Note: This feature is only available with the
 * Scandit SDK Enterprise Packages.
 *
 * The default is: "beep.wav"
 *
 * \since 2.0.0
 *
 * \param path The file name of the sound file (without suffix).
 * \param extension The file type.
 * \return Whether the change was successful.
 */
- (BOOL)setScanSoundResource:(nonnull NSString *)path ofType:(nonnull NSString *)extension;
///\}


/** \name Torch Configuration
 *  Enable and customize appearance of the torch icon.
 */
///\{

/**
 * \brief Enables or disables the torch toggle button for all devices/cameras that support a torch.
 *
 * By default it is enabled. The torch icon is never shown when the camera does not have a
 * torch (most tablets, front cameras, etc).
 *
 * \since 2.0.0
 *
 * \param enabled Whether the torch button should be shown.
 */
- (void)setTorchEnabled:(BOOL)enabled;

/**
 * \brief Sets the images which are being drawn when the torch is on.
 *
 * By default these are "flashlight-turn-off-icon.png" and "flashlight-turn-off-icon-pressed.png"
 * which come with the framework's resource bundle.
 *
 * \since 4.7.0
 *
 * \param torchOnImage The image for when the torch is on.
 * \param torchOnPressedImage The image for when the torch is on and it is pressed.
 * \return Whether the change was successful.
 */
- (BOOL)setTorchOnImage:(nonnull UIImage *)torchOnImage
                pressed:(nonnull UIImage *)torchOnPressedImage SBS_SWIFT_NAME(setTorchOnImage(torchOnImage:torchOnPressedImage:));

/**
 * \brief Sets the images which are being drawn when the torch is on.
 *
 * If you want this to be displayed in proper resolution on high resolution screens, you need to
 * also provide a resource with the same name but \2x appended and in higher resolution (like
 * flashlight-turn-on-icon\2x.png).
 *
 * File needs to be placed in Resources folder.
 *
 * By default this is: "flashlight-turn-off-icon.png" and "flashlight-turn-off-icon-pressed.png"
 *
 * \since 2.0.0
 *
 * \param fileName The file name for when the torch is on (without suffix).
 * \param pressedFileName The file name for when the torch is on and it is pressed (without suffix).
 * \param extension The file type.
 * \return Whether the change was successful.
 */
- (BOOL)setTorchOnImageResource:(nonnull NSString *)fileName
                pressedResource:(nonnull NSString *)pressedFileName
                         ofType:(nonnull NSString *)extension;

/**
 * \brief Sets the images which are being drawn when the torch is off.
 *
 * By default this is: "flashlight-turn-on-icon.png" and "flashlight-turn-on-icon-pressed.png"
 * which come with the framework's resource bundle.
 *
 * \since 4.7.0
 *
 * \param torchOffImage The image for when the torch is off.
 * \param torchOffPressedImage The image for when the torch is off and it is pressed.
 * \return Whether the change was successful.
 */
- (BOOL)setTorchOffImage:(nonnull UIImage *)torchOffImage
                 pressed:(nonnull UIImage *)torchOffPressedImage SBS_SWIFT_NAME(setTorchOffImage(torchOffImage:torchOffPressedImage:));

/**
 * \brief Sets the images which are being drawn when the torch is off.
 *
 * If you want this to be displayed in proper resolution on high resolution screens, you need to
 * also provide a resource with the same name but \2x appended and in higher resolution (like
 * flashlight-turn-on-icon\2x.png).
 *
 * By default this is: "flashlight-turn-on-icon.png" and "flashlight-turn-on-icon-pressed.png"
 *
 * \since 2.0.0
 *
 * \param fileName The file name for when the torch is off (without suffix).
 * \param pressedFileName The file name for when the torch is off and it is pressed (without suffix).
 * \param extension The file type.
 * \return Whether the change was successful.
 */
- (BOOL)setTorchOffImageResource:(nonnull NSString *)fileName
                 pressedResource:(nonnull NSString *)pressedFileName
                          ofType:(nonnull NSString *)extension;

/**
 * \brief Sets the position at which the button to enable the torch is drawn.
 *
 * By default the margins are 15 and width and height are 40.
 *
 * \since 4.7.0
 *
 * \param leftMargin Left margin in points.
 * \param topMargin Top margin in points.
 * \param width Width in points.
 * \param height Height in points.
 */
- (void)setTorchButtonLeftMargin:(float)leftMargin
                       topMargin:(float)topMargin
                           width:(float)width
                          height:(float)height SBS_SWIFT_NAME(setTorchButton(leftMargin:topMargin:width:height:));

/**
 * \brief Sets the accessibility label and hint for the torch button while the torch is off.
 *
 * The accessibility label and hint give vision-impaired users voice over guidance for the torch
 * button while the torch is turned on. The default label is "Torch Switch (Currently Off)", the
 * default hint "Double-tap to switch the torch on"
 *
 * \since 4.9.0
 *
 * \param label The accessibility label.
 * \param hint The accessibility hint.
 */
- (void)setTorchOffButtonAccessibilityLabel:(nonnull NSString *)label
                                       hint:(nonnull NSString *)hint;

/**
 * \brief Sets the accessibility label and hint for the torch button while the torch is on.
 *
 * The accessibility label and hint give vision-impaired users voice over guidance for the torch
 * button while the torch is turned on. The default label is "Torch Switch (Currently On)", the
 * default hint "Double-tap to switch the torch off"
 *
 * \since 4.9.0
 *
 * \param label The accessibility label.
 * \param hint The accessibility hint.
 */
- (void)setTorchOnButtonAccessibilityLabel:(nonnull NSString *)label
                                      hint:(nonnull NSString *)hint;

///\}


/** \name Camera Switch Configuration
 *  Enable camera switch and set icons
 */
///\{

/**
 * \brief Sets when the camera switch button is visible for devices that have more than one camera.
 *
 * By default it is CameraSwitchVisibility#CAMERA_SWITCH_NEVER.
 *
 * \since 3.0.0
 *
 * \param visibility The visibility of the camera switch button
 *                   (\ref SBSCameraSwitchVisibilityNever, \ref SBSCameraSwitchVisibilityOnTablet,
 *                   \ref SBSCameraSwitchVisibilityAlways
 */
- (void)setCameraSwitchVisibility:(SBSCameraSwitchVisibility)visibility;

/**
 * \brief Sets the images which are being drawn when the camera switch button is visible.
 *
 * By default this is "camera-swap-icon.png" and "camera-swap-icon-pressed.png"
 * which come with the framework's resource bundle.
 *
 * \since 4.7.0
 *
 * \param cameraSwitchImage The image for the camera swap button.
 * \param cameraSwitchPressedImage The image for the camera swap button when pressed.
 * \return Whether the change was successful.
 */
- (BOOL)setCameraSwitchImage:(nonnull UIImage *)cameraSwitchImage
                     pressed:(nonnull UIImage *)cameraSwitchPressedImage;

/**
 * \brief Sets the images which are being drawn when the camera switch button is visible.
 *
 * If you want this to be displayed in proper resolution on high resolution screens, you need to
 * also provide a resource with the same name but \2x appended and in higher resolution (like
 * flashlight-turn-on-icon\2x.png).
 *
 * File needs to be placed in Resources folder.
 *
 * By default this is: "camera-swap-icon.png" and "camera-swap-icon-pressed.png"
 *
 * \since 3.0.0
 *
 * \param fileName The file name of the camera swap button's image (without suffix).
 * \param pressedFileName The file name of the camera swap button's image when pressed (without suffix).
 * \param extension The file type.
 * \return Whether the change was successful.
 */
- (BOOL)setCameraSwitchImageResource:(nonnull NSString *)fileName
                     pressedResource:(nonnull NSString *)pressedFileName
                              ofType:(nonnull NSString *)extension;

/**
 * \brief Sets the position at which the button to switch the camera is drawn.
 *
 * Be aware that the x coordinate is calculated from the right side of the screen and not
 * the left like with the torch button.
 *
 * By default this is set to x = 15, y = 15, width = 40 and height = 40.
 *
 * \since 3.0.0
 *
 * \param rightMargin Right margin in points.
 * \param topMargin Top margin in points
 * \param width Width in points.
 * \param height Height in points.
 */
- (void)setCameraSwitchButtonRightMargin:(float)rightMargin
                               topMargin:(float)topMargin
                                   width:(float)width
                                  height:(float)height SBS_SWIFT_NAME(setCameraSwitchButton(rightMargin:topMargin:width:height:));

/**
 * \brief Sets the accessibility label and hint for the camera switch button while the back-facing
 * camera is active.
 *
 * The accessibility label and hint give vision-impaired users voice over guidance for the camera
 * switch button while the back-facing camera is active. The default label is "Camera Switch 
 * (Currently back-facing)", the default hint "Double-tap to switch to the front-facing camera".
 *
 * \since 4.9.0
 *
 * \param label The accessibility label.
 * \param hint The accessibility hint.
 */
- (void)setCameraSwitchButtonBackAccessibilityLabel:(nonnull NSString *)label
                                               hint:(nonnull NSString *)hint;

/**
 * \brief Sets the accessibility label and hint for the camera switch button while the front-facing
 * camera is active.
 *
 * The accessibility label and hint give vision-impaired users voice over guidance for the camera
 * switch button while the front-facing camera is active. The default label is "Camera Switch 
 * (Currently front-facing)", the default hint "Double-tap to switch to the back-facing camera".
 *
 * \since 4.9.0
 *
 * \param label The accessibility label.
 * \param hint The accessibility hint.
 */
- (void)setCameraSwitchButtonFrontAccessibilityLabel:(nonnull NSString *)label
                                                hint:(nonnull NSString *)hint;

///\}


/** \name Text Recognition Switch Configuration
 *  Customize the viewfinder where the barcode location is highlighted.
 */
///\{

/**
 * Sets whether the button to switch between different recognition modes should be visible.
 * If the scanner only supports one recognition mode the button is never shown.
 *
 * \param visible Whether the button should be visible.
 *
 * \since 5.2.0
 */
- (void)setTextRecognitionSwitchVisible:(BOOL)visible;
///@}


/** \name Viewfinder Configuration
 *  Customize the viewfinder where the barcode location is highlighted.
 */
///\{

/**
 * \deprecated Replaced by #setGuiStyle:SBSGuiStyleNone in 4.11.0 which is now called by this
 * function.
 *
 * \brief Shows/hides viewfinder rectangle and highlighted barcode location in the scan screen UI.
 *
 * Note: This feature is only available with the Scandit SDK Enterprise Packages.
 *
 * By default this is enabled.
 *
 * \since 1.0.0
 *
 * \param draw Whether the viewfinder rectangle should be drawn.
 */
- (void)drawViewfinder:(BOOL)draw SBS_DEPRECATED;

/**
 * \brief Sets the size of the viewfinder relative to the size of the SBSBarcodePicker's size.
 *
 * Changing this value does not(!) affect the area in which barcodes are successfully recognized.
 * It only changes the size of the box drawn onto the scan screen. To restrict the active scanning area,
 * use the properties listed below.
 *
 * \see SBSScanSettings#activeScanningAreaPortrait
 * \see SBSScanSettings#activeScanningAreaLandscape
 *
 * By default the width is 0.9, height is 0.4, landscapeWidth is 0.6, landscapeHeight is 0.4
 *
 * \since 3.0.0
 *
 * \param h Height of the viewfinder rectangle in portrait orientation.
 * \param w Width of the viewfinder rectangle in portrait orientation.
 * \param lH Height of the viewfinder rectangle in landscape orientation.
 * \param lW Width of the viewfinder rectangle in landscape orientation.
 */
- (void)setViewfinderHeight:(float)h
                      width:(float)w
            landscapeHeight:(float)lH
             landscapeWidth:(float)lW SBS_SWIFT_NAME(setViewfinder(height:width:landscapeHeight:landscapeWidth:)) SBS_DEPRECATED_MSG_ATTRIBUTE("use setViewfinderWidth:height:landscapeWidth:landscapeHeight: instead.");

/**
 * \brief Sets the size of the viewfinder relative to the size of the SBSBarcodePicker's size.
 *
 * Changing this value does not(!) affect the area in which barcodes are successfully recognized.
 * It only changes the size of the box drawn onto the scan screen. To restrict the active scanning area,
 * use the properties listed below.
 *
 * \see SBSScanSettings#activeScanningAreaPortrait
 * \see SBSScanSettings#activeScanningAreaLandscape
 *
 * By default the width is 0.9, height is 0.4, landscapeWidth is 0.6, landscapeHeight is 0.4
 *
 * \since 5.4.0
 *
 * \param w Width of the viewfinder rectangle in portrait orientation.
 * \param h Height of the viewfinder rectangle in portrait orientation.
 * \param lW Width of the viewfinder rectangle in landscape orientation.
 * \param lH Height of the viewfinder rectangle in landscape orientation.
 */
- (void)setViewfinderWidth:(float)w
                    height:(float)h
            landscapeWidth:(float)lW
           landscapeHeight:(float)lH SBS_SWIFT_NAME(setViewfinder(width:height:landscapeWidth:landscapeHeight:));

/**
 * \brief Sets the size of the viewfinder relative to the size of the SBSBarcodePicker's size 
 * in portrait orientation.
 *
 * Changing this value does not(!) affect the area in which barcodes are successfully recognized.
 * It only changes the size of the box drawn onto the scan screen. To restrict the active scanning area,
 * use the properties listed below.
 *
 * \see SBSScanSettings#activeScanningAreaPortrait
 * \see SBSScanSettings#activeScanningAreaLandscape
 *
 *
 * By default the width is 0.9, height is 0.4
 *
 * \since 4.16.0
 *
 * \param w Width of the viewfinder rectangle in portrait orientation.
 * \param h Height of the viewfinder rectangle in portrait orientation.
 */
- (void)setViewfinderPortraitWidth:(float)w
                            height:(float)h SBS_SWIFT_NAME(setViewfinderPortrait(width:height:));


/**
 * \brief Sets the size of the viewfinder relative to the size of the SBSBarcodePicker's size in 
 * landscape orientation.
 *
 * Changing this value does not(!) affect the area in which barcodes are successfully recognized.
 * It only changes the size of the box drawn onto the scan screen. To restrict the active scanning area,
 * use the properties listed below.
 *
 * \see SBSScanSettings#activeScanningAreaPortrait
 * \see SBSScanSettings#activeScanningAreaLandscape
 *
 *
 * By default the width is 0.6, height is 0.4
 *
 * \since 4.16.0
 *
 * \param w Width of the viewfinder rectangle in landscape orientation.
 * \param h Height of the viewfinder rectangle in landscape orientation.
 */
- (void)setViewfinderLandscapeWidth:(float)w
                             height:(float)h SBS_SWIFT_NAME(setViewfinderLandscape(width:height:));

/**
 * \brief Sets the color of the viewfinder before a bar code has been recognized
 *
 * Note: This feature is only available with the Scandit SDK Enterprise Packages.
 *
 * By default this is: white (1.0, 1.0, 1.0)
 *
 * \since 1.0.0
 *
 * \param r Red component (between 0.0 and 1.0).
 * \param g Green component (between 0.0 and 1.0).
 * \param b Blue component (between 0.0 and 1.0).
 */
- (void)setViewfinderColor:(float)r green:(float)g blue:(float)b SBS_SWIFT_NAME(setViewfinderColor(red:green:blue:));

/**
 * \brief Sets the color of the viewfinder once the bar code has been recognized.
 *
 * Note: This feature is only available with the Scandit SDK Enterprise Packages.
 *
 * By default this is: light blue (0.222, 0.753, 0.8)
 *
 * \since 1.0.0
 *
 * \param r Red component (between 0.0 and 1.0).
 * \param g Green component (between 0.0 and 1.0).
 * \param b Blue component (between 0.0 and 1.0).
 */
- (void)setViewfinderDecodedColor:(float)r green:(float)g blue:(float)b SBS_SWIFT_NAME(setViewfinderDecodedColor(red:green:blue:));


/**
 * \brief Resets the scan screen user interface to its initial state.
 *
 * This resets the animation showing the barcode
 * locations to its initial state.
 *
 * \since 1.0.0
 */
- (void)resetUI;
///\}


/** \name Toolbar Configuration
 *  Customize toolbar appearance
 */
///\{

/**
 * \brief Adds (or removes) a tool bar to/from the bottom of the scan screen.
 *
 * \since 1.0.0
 *
 * \param show boolean indicating whether toolbar should be shown.
 */
- (void)showToolBar:(BOOL)show;

/**
 * \brief Sets the caption of the toolbar button.
 *
 * By default this is: "Cancel"
 *
 * \since 1.0.0
 *
 * \param caption string used for cancel button caption
 */
- (void)setToolBarButtonCaption:(nonnull NSString *)caption;
///\}


/** \name Camera Permission Configuration
 *  Customize the text shown if the camera can not be aquired.
 */
///\{

/**
 * \brief Sets the text shown if the camera can not be aquired because the app does not have
 *        permission to access the camera.
 *
 * By default this is: "The Barcode Picker was unable to access the device's camera.\n\nGo to 
 * Settings -> Privacy -> Camera and check that this app has permission to use the camera."
 *
 * \since 4.7.0
 *
 * \param infoText Text shown if the camera can not be aquired.
 */
- (void)setMissingCameraPermissionInfoText:(nonnull NSString *)infoText;
///\}

/**
 * \brief Sets the color of the tracked barcodes to use for the specified state.
 *
 * \since 5.2.0
 *
 * \param color The color to use for tracked barcodes in the specified state.
 * \param state The state that uses the specified color.
 */
- (void)setMatrixScanHighlightingColor:(nonnull UIColor *)color forState:(SBSMatrixScanHighlightingState)state;

@end

