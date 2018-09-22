//
//  NSArray+HighOrder.h
//  Collection
//
//  Created by Badchoice on 10/10/17.
//  Copyright © 2017 Revo. All rights reserved.
//

#import "NSArray+Collection.h"

@interface NSArray (HighOrder)

-(NSArray*)map_:(SEL)selector;
-(NSArray*)map_:(SEL)selector withObject:(id)object;

-(void)each_:(SEL)selector;
-(void)each_:(SEL)selector withObject:(id)object;

-(NSArray*)filter_:(SEL)selector;
-(NSArray*)filter_:(SEL)selector withObject:(id)object;

-(NSArray*)reject_:(SEL)selector;
-(NSArray*)reject_:(SEL)selector withObject:(id)object;

@end
