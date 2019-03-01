/**
 * \brief controls the scan screen user interface.
 *
 *
 * The overlay controller can be used to configure various scan screen UI elements such as
 * search bar, toolbar, torch, camera switch icon, scandit logo and the viewfinder.
 *
 * Developers can inherit from the ScanditSDKOverlayController to implement their own
 * scan screen user interfaces.
 *
 * \since 1.0.0
 *
 * Copyright 2010 Mirasense AG. All rights reserved.
 */

#import <UIKit/UIKit.h>
#import "AudioToolbox/AudioServices.h"
#import "SBSOverlayController.h"

@class ScanditSDKUIView;
@class ScanditSDKBarcodePicker;
@class ScanditSDKOverlayController;

/**
 * \brief protocol to handle barcode scan, cancel and manual search events.
 * \ingroup scanditsdk-ios-api
 * \since 1.0.0
 */
SBS_DEPRECATED
@protocol ScanditSDKOverlayControllerDelegate
/**
 * \brief Is called when a barcode is successfully decoded.
 *
 * The dictionary contains two key-value pairs.
 *
 * key: "barcode"
 * value: barcode data decoded (as UTF8 encoded NSString)
 *
 * key: "symbology"
 * value: the symbology of the barcode decoded. The following barcode symbology identifiers are returned:
 *
 * "EAN8", "EAN13", "UPC12", "UPCE", "CODE128", "GS1-128", "CODE39", "CODE93", "ITF", "MSI",
 * "CODABAR", "GS1-DATABAR", "GS1-DATABAR-EXPANDED", "QR", "GS1-QR", "DATAMATRIX", "GS1-DATAMATRIX",
 * "PDF417"
 *
 * \since 1.0.0
 *
 * \param overlayController ScanditSDKOverlayController that is delegating
 * \param barcode dictionary with two key value pairs ("barcode","symbology")
 */
- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)overlayController 
                     didScanBarcode:(NSDictionary *)barcode SBS_DEPRECATED;
/**
 * \brief Is called when the user clicks the cancel button in the scan user interface
 *
 * \since 1.0.0
 *
 * \param overlayController ScanditSDKOverlayController that is delegating
 * \param status dictionary (currently empty)
 *
 */
- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)overlayController
                didCancelWithStatus:(NSDictionary *)status;


/**
 * \brief Is called when the search bar is shown and the user enters a search term manually.
 *
 * \since 1.0.0
 *
 * \param overlayController ScanditSDKOverlayController that is delegating
 * \param text manual search input encoded as an NSString
 */
- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)overlayController 
                    didManualSearch:(NSString *)text;
@end


/**
 * \brief  controls the scan screen user interface.
 *
 * The overlay controller can be used to configure various scan screen UI elements such as
 * search bar, toolbar, torch, camera switch icon, scandit logo and the viewfinder.
 *
 * Developers can inherit from the ScanditSDKOverlayController to implement their own
 * scan screen user interfaces.
 *
 * \ingroup scanditsdk-ios-api
 *
 * \since 1.0.0
 *
 * \nosubgrouping
 */
SBS_DEPRECATED
@interface ScanditSDKOverlayController : SBSOverlayController

/**
 * \brief The overlay controller delegate that handles callbacks such as didScanBarcode or
 * didCancelWithStatus.
 *
 * As of Scandit SDK 4.7.0,  ScanditSDKBarcodePicker#scanDelegate is the preferred way to 
 * listen to successful scan events, and ScanditSDKBarcodePicker#cancelDelegate to listen 
 * to cancel events.
 *
 * \since 1.0.0
 */
@property (nonatomic, weak) id<ScanditSDKOverlayControllerDelegate> delegate;

/**
 * \brief The manual search bar that can be shown at the top of the scan sreen.
 *
 * \since 1.0.0
 */
@property (nonatomic, strong, readonly) UISearchBar *manualSearchBar;


/** \name Torch Configuration
 *  Enable and customize appearance of the torch icon.
 */
///\{

/**
 * \deprecated Use #setTorchOnImageResource:pressedResource:ofType: instead.
 *
 * \brief Sets the image which is being drawn when the torch is on.
 *
 * If you want this to be displayed in proper resolution on high resolution screens, you need to
 * also provide a resource with the same name but \2x appended and in higher resolution (like
 * flashlight-turn-on-icon\2x.png).
 *
 * File needs to be placed in Resources folder.
 *
 * By default this is: "flashlight-turn-on-icon.png"
 *
 * \since 2.0.0
 *
 * \param fileName The file name for when the torch is on (without suffix).
 * \param extension The file type.
 * \return Whether the change was successful.
 */
- (BOOL)setTorchOnImageResource:(NSString *)fileName
                         ofType:(NSString *)extension SBS_DEPRECATED;


/**
 * \deprecated Use #setTorchButtonLeftMargin:topMargin:width:height: instead.
 *
 * \brief Sets the position at which the button to enable the torch is drawn.
 *
 * The X and Y coordinates are relative to the screen size, which means they have to be between
 * 0 and 1.
 *
 * There are no defaults as the margins are now set through setTorchButtonLeftMargin:topMargin:width:height:.
 *
 * \since 2.0.0
 *
 * \param x Relative x coordinate.
 * \param y Relative y coordinate.
 * \param width Width in points.
 * \param height Height in points.
 */
- (void)setTorchButtonRelativeX:(float)x
                      relativeY:(float)y
                          width:(float)width
                         height:(float)height SBS_DEPRECATED;
///\}


/** \name Camera Switch Configuration
 *  Enable camera switch and set icons
 */
///\{

/**
 * \brief Sets the image which is being drawn when the camera switch button is visible.
 *
 * If you want this to be displayed in proper resolution on high resolution screens, you need to
 * also provide a resource with the same name but \2x appended and in higher resolution (like
 * flashlight-turn-on-icon\2x.png).
 *
 * File needs to be placed in Resources folder.
 *
 * By default this is: "camera-swap-icon.png"
 *
 * \since 3.0.0
 *
 * \param fileName The file name of the camera swap button's image (without suffix).
 * \param extension The file type.
 * \return Whether the change was successful.
 */
- (BOOL)setCameraSwitchImageResource:(NSString *)fileName
                              ofType:(NSString *)extension SBS_DEPRECATED;

/**
 * \deprecated Use #setCameraSwitchButtonRightMargin:topMargin:width:height: instead.
 *
 * \brief Sets the position at which the button to switch the camera is drawn.
 *
 * The X and Y coordinates are relative to the screen size, which means they have to be between
 * 0 and 1. Be aware that the x coordinate is calculated from the right side of the screen and not
 * the left like with the torch button.
 *
 * By default this is set to x = 0.04, y = 0.02, width = 40 and height = 40.
 *
 * \since 3.0.0
 *
 * \param x Relative x coordinate (from the right screen edge).
 * \param y Relative y coordinate.
 * \param width Width in points.
 * \param height Height in points.
 */
- (void)setCameraSwitchButtonRelativeInverseX:(float)x
                                    relativeY:(float)y
                                        width:(float)width
                                       height:(float)height SBS_DEPRECATED;
///\}


/** \name Viewfinder Configuration
 *  Customize the viewfinder where the barcode location is highlighted.
 */
///\{

/**
 * \deprecated  Replaced by #setViewfinderHeight:width:landscapeHeight:landscapeWidth:
 *              If you are using a rotating BarcodePicker, migrate to the new function if possible
 *              since it will allow you to properly adjust the viewfinder for each screen dimension
 *              individually.
 *
 * \brief Deprecated: Sets the size of the viewfinder relative to the size of the screen size.
 *
 * Changing this value does not(!) affect the area in which barcodes are successfully recognized.
 * It only changes the size of the box drawn onto the scan screen.
 *
 * By default the width is 0.6 and the height is 0.25
 *
 * \param h Height of the viewfinder rectangle.
 * \param w Width of the viewfinder rectangle.
 */
- (void)setViewfinderHeight:(float)h width:(float)w SBS_DEPRECATED;


///\}


/** \name Logo Configuration
 *  Customize the scanning by Scandit logo - Note that including the logo in the UI is mandatory.
 */
///\{

/**
 * \brief Sets the x and y offset at which the scanning by Scandit logo is drawn for both portrait and landscape
 * orientation.
 *
 * Please note that the standard Scandit SDK license do not allow you to hide the logo.
 *
 * By default this is set to xOffset = 0, yOffset = 0, landscapeXOffset = 0, landscapeYOffset = 0.
 *
 * \since 2.0.0
 *
 * \param xOffset x offset in pixels in portrait mode
 * \param yOffset y offset in pixels in portrait mode
 * \param landscapeXOffset x offset in pixels in landscape mode
 * \param landscapeYOffset y offset in pixels in landscape mode
 *
 */
- (void)setLogoXOffset:(int)xOffset
               yOffset:(int)yOffset
      landscapeXOffset:(int)landscapeXOffset
      landscapeYOffset:(int)landscapeYOffset SBS_DEPRECATED;

/**
 * \deprecated:  This function was replaced by setLogoXOffset:yOffset: in Scandit SDK 3.*
 *
 * \brief Deprecated: Sets the y offset at which the Scandit logo should be drawn.
 *
 * Please note that the standard Scandit SDK licenses do not allow you to hide the logo. Do not
 * use this method to hide the poweredby logo.
 *
 * \since 2.0.0
 *
 * \param offset vertical offset in pixels by which logo should be moved
 *
 * By default this is: 0
 */
- (void)setInfoBannerOffset:(int)offset SBS_DEPRECATED;

/**
 * \brief Sets the "scanning by Scandit" image which is being drawn at the bottom of the scan screen.
 *
 * Use this method to show an alternative scanning by Scandit logo provided for your application
 * by the Scandit team. Do not use this method without consulting with the Scandit team.
 *
 * Note: This feature is only available with the
 * Scandit SDK Enterprise Packages.
 *
 * By default this is: "poweredby.png"
 *
 * \param fileName of poweredby logo (without suffix)
 * \param extension file type
 * \return boolean indicating whether the change was successful.
 */
- (BOOL)setBannerImageWithResource:(NSString *)fileName ofType:(NSString *)extension;
///\}

/** \name Searchbar Configuration
 *  Customize searchbar appearance
 */
///\{

/**
 * \brief Shows (or hides) a search bar at the top of the scan screen.
 *
 * \since 1.0.0
 *
 * \param show Whether the search bar should be visible.
 */
- (void)showSearchBar:(BOOL)show;

/**
 * \brief Sets the caption of the search button at the top of the numerical keyboard.
 *
 * By default this is: "Go"
 *
 * \since 1.0.0
 *
 * \param caption Caption of the search button.
 */
- (void)setSearchBarActionButtonCaption:(NSString *)caption;

/**
 * \deprecated This method serves no purpose any more under iOS 7+ and is deprecated.
 *
 * \brief Sets the caption of the manual entry at the top.
 *
 * By default this is: "Cancel"
 *
 * \since 1.0.0
 *
 * \param caption Caption of the cancel button.
 */
- (void)setSearchBarCancelButtonCaption:(NSString *)caption SBS_DEPRECATED;

/**
 * \brief Sets the text shown in the manual entry field when nothing has been entered yet.
 *
 * By default this is: "Scan barcode or enter it here"
 *
 * \since 1.0.0
 *
 * \param text A placeholder text shown when the search bar is empty.
 */
- (void)setSearchBarPlaceholderText:(NSString *)text;

/**
 * \brief Sets the type of keyboard that is shown to enter characters into the search bar.
 *
 * By default this is: UIKeyboardTypeNumberPad
 *
 * \since 1.0.0
 *
 * \param keyboardType Type of keyboard that is shown when user uses search bar.
 */
- (void)setSearchBarKeyboardType:(UIKeyboardType)keyboardType;

/**
 * \brief Sets the minimum size that a barcode entered in the manual searchbar has to have to possibly be valid.
 *
 * By default this is set to 8.
 *
 * \since 1.0.0
 *
 * \param length Minimum number of input characters.
 */
- (void)setMinSearchBarBarcodeLength:(NSInteger)length;

/**
 * \brief Sets the maximum size that a barcode entered in the manual searchbar can have to possibly be valid.
 *
 * By default this is set to 100.
 *
 * \since 1.0.0
 *
 * \param length Maximum number of input characters.
 */
- (void)setMaxSearchBarBarcodeLength:(NSInteger)length;
///\}


/** \name Deprecated
 *  Deprecated methods.
 */
///\{

/**
 * \deprecated This method serves no purpose any more in Scandit SDK 3.* and is deprecated.
 *
 * \brief Deprecated: Add the 'most likely barcode' UI element.
 *
 * This element is displayed below the viewfinder when the barcode engine is not 100% confident
 * in its result and asks for user confirmation. This element is seldom displayed - typically only 
 * when decoding challenging barcodes with fixed focus cameras.
 *
 * \param show whether to show the most likely barcode element.
 */
- (void)showMostLikelyBarcodeUIElement:(BOOL)show SBS_DEPRECATED;

/**
 * \deprecated This method serves no purpose any more in Scandit SDK 3.* and is deprecated.
 *
 * \brief Deprecated: Sets the text that will be displayed above the viewfinder to tell the user 
 *    to align it with the barcode that should be recognized.
 *
 * \param text The text to use.
 */
- (void)setTextForInitialScanScreenState:(NSString *)text SBS_DEPRECATED;

/**
 * \deprecated This method serves no purpose any more in Scandit SDK 3.* and is deprecated.
 *
 * \brief Deprecated: Sets the text that will be displayed above the viewfinder to tell the user to align it with the
 * barcode and hold still because a potential code seems to be on the screen.
 *
 * \param text The text to use.
 */
- (void)setTextForBarcodePresenceDetected:(NSString *)text SBS_DEPRECATED;

/**
 * \deprecated This method serves no purpose any more in Scandit SDK 3.* and is deprecated.
 *
 * \brief Deprecated: Sets the text that will be displayed above the viewfinder when decoding is in progress
 *
 * \param text The text to use.
 */
- (void)setTextForBarcodeDecodingInProgress:(NSString *)text SBS_DEPRECATED;

/**
 * \deprecated This method serves no purpose any more in Scandit SDK 3.* and is deprecated.
 *
 * \brief Deprecated: Sets the text that will be displayed if the engine was unable to recognize the barcode.
 *
 * \param text The text to use.
 */
- (void)setTextWhenNoBarcodeWasRecognized:(NSString *)text SBS_DEPRECATED;

/**
 * \deprecated - This method serves no purpose any more in Scandit SDK 3.* and is deprecated.
 *
 * \brief Deprecated: Sets the text that will be displayed if the engine was unable to recognize the barcode and it is
 * suggested to enter the barcode manually.
 *
 * \param text The text to use.
 */
- (void)setTextToSuggestManualEntry:(NSString *)text SBS_DEPRECATED;

/**
 * \deprecated This method serves no purpose any more in Scandit SDK 3.* and is deprecated.
 *
 * \brief Deprecated: Sets the text that is displayed alongside the 'most likely barcode' UI element that
 * is displayed when the barcode engine is not 100% confident in its result and asks for user
 * confirmation.
 *
 * By default this is: "Tap to use"
 *
 * \param text The text to use.
 */
- (void)setTextForMostLikelyBarcodeUIElement:(NSString *)text SBS_DEPRECATED;

/**
 * \deprecated This method serves no purpose any more in Scandit SDK 3.* and is deprecated.
 *
 * \brief Sets the font size of the text in the view finder.
 *
 * Note: This feature is only available with the
 * Scandit SDK Enterprise Packages.
 *
 * \param fontSize the font size to use
 *
 * \since 1.0.0
 */
- (void)setViewfinderFontSize:(float)fontSize SBS_DEPRECATED;

/**
 * \deprecated This method serves no purpose any more in Scandit SDK 3.* and is deprecated.
 *
 * \brief Sets the font of all text displayed in the UI.
 *
 * Note: This feature is only available with the Scandit SDK Enterprise Packages.
 *
 * \param font The font to use.
 *
 * \since 1.0.0
 */
- (void)setUIFont:(NSString *)font SBS_DEPRECATED;

/**
 * \deprecated This method serves no purpose any more in Scandit SDK 3.* and is deprecated.
 * Use method drawViewfinder instead.
 *
 * \brief Deprecated: Sets whether the overlay controller draws the static viewfinder (i.e. white 
 *    rectangle) when no code was detected yet.
 *
 * \param draw Whether the static view finder should be drawn.
 */
- (void)drawStaticViewfinder:(BOOL)draw SBS_DEPRECATED;

/**
 * \deprecated This method serves no purpose any more in Scandit SDK 3.* and is deprecated.
 *
 * \brief Deprecated: Sets whether to draw the hook at the top of the viewfinder that displays text.
 *
 * \param draw Whether view finder text hook should be drawn.
 */
- (void)drawViewfinderTextHook:(BOOL)draw SBS_DEPRECATED;

/**
 * \deprecated This method serves no purpose any more in Scandit SDK 3.* and is deprecated.
 *
 * \brief Deprecated: Enables (or disables) the "flash" when a barcode is successfully scanned.
 *
 * \param enabled Whether the scan flash should be enabled.
 */
- (void)setScanFlashEnabled:(BOOL)enabled SBS_DEPRECATED;

///\}

@end
