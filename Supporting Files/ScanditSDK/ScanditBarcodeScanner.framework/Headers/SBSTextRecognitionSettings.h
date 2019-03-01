//
//  SBSTextRecognitionSettings.h
//  ScanditBarcodeScanner
//
//  Created by Marco Biasini on 03/10/16.
//  Copyright © 2016 Scandit AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CoreGraphics/CoreGraphics.h>

#include "SBSCommon.h"

@class SBSCharacterSet;

/**
 * Contains settings to control the text recognition engine.
 */
@interface SBSTextRecognitionSettings : NSObject <NSCopying>

/**
 * Regular expression for filtering the recognized characters. Text that does not match the 
 * regular expression is ignored.
 *
 * By default, the regex is set to nil. You must explicitly initialize the regex in order for
 * text recognition to work.
 *
 * \since 5.1
 */
@property (nullable, nonatomic, strong) NSRegularExpression *regex;

/**
 * The area (in relative coordinates) in which text is to be recognized. 
 *
 * While it's possible to set this area to the whole image, it is not recommended to do so for 
 * speed reasons. For best performance, set this to the smallest possible area. By default, 
 * the recognition area is set to 1/4 of the image height.
 * 
 * This value is only used when scanning in landscape orientation. \ref areaPortrait is 
 * used when scanning in portrait orientation.
 *
 * \since 5.1
 */
@property (nonatomic, assign) CGRect areaLandscape;

/**
 * The area (in relative coordinates) in which text is to be recognized.
 *
 * While it's possible to set this area to the whole image, it is not recommended to do so for
 * speed reasons. For best performance, set this to the smallest possible area. By default,
 * the recognition area is set to 1/5 of the image height.
 *
 * This value is only used when scanning in portrait orientation.
 *
 * \since 5.1
 */
@property (nonatomic, assign) CGRect areaPortrait;

/**
 * White list of recognizable characters. If the white list is non-nil, a recognition result
 * will never contain characters that are not contained in it.
 *
 * By default the white list is nil and all characters will be recognized.
 *
 * \since 5.2.0
 */
@property (nullable, nonatomic, strong) SBSCharacterSet *characterWhitelist;

- (nullable instancetype)initWithDictionary:(nonnull NSDictionary<NSString *, id> *)dict
                                      error:(NSError * _Nullable * _Nullable)error;

@end
