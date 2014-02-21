//
//  RIPErrorManager.h
//  Notepad
//
//  Created by Nick on 1/23/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RIPErrorManager : NSObject

+ (void)printError:(NSError *)error location:(NSString *)location;

@end
