//
//  SBSCharacterSet.h
//  ScanditBarcodeScanner
//
//  Created by Luca Torella on 07.04.17.
//  Copyright © 2017 Scandit AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBSCommon.h"

@interface SBSCharacterSet : NSObject <NSCopying>

+ (nonnull SBSCharacterSet *)characterSetWithString:(nonnull NSString *)whitelist;
- (nonnull instancetype)initWithString:(nonnull NSString *)whitelist SBS_DESIGNATED_INITIALIZER;

@end
