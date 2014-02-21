//
//  RIPErrorManager.m
//  Notepad
//
//  Created by Nick on 1/23/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import "RIPErrorManager.h"

@implementation RIPErrorManager

+ (void)printError:(NSError *)error location:(NSString *)location {
    NSLog(@"Error %ld: %@ %@ {%@}", (long)error.code, error.localizedDescription, error.debugDescription, location);
}

@end
