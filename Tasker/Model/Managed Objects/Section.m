//
//  Section.m
//  Notepad
//
//  Created by Nick on 1/24/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import "UIColor+Utils.h"
#import "Section.h"
#import "Note.h"

NSString * const kSectionColorKey = @"kColor";

static NSArray * swatches = nil;

@implementation Section

@dynamic color;
@dynamic notes;

+ (UIColor *)getColor:(NSInteger)i {
    if(swatches == nil){
        swatches = @[
                     [UIColor redColor],
                     [UIColor orangeColor],
                     [UIColor goldColor],
                     [UIColor emeraldColor],
                     [UIColor tealColor],
                     [UIColor ceruleanColor],
                     [UIColor violetColor],
                     [UIColor magentaColor],
                     ];
    }
    return swatches[i % swatches.count];
}

@end
