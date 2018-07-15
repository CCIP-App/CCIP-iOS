//
//  NSObject+ValueForKeyPathWithIndexes.h
//  CCIP
//
//  Created by 腹黒い茶 on 2018/7/15.
//  Copyright © 2018 CPRTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (ValueForKeyPathWithIndexes)

- (id)valueForKeyPathWithIndexes:(NSString*)fullPath;

@end
