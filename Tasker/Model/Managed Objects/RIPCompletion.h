//
//  RIPCompletion.h
//  Notepad
//
//  Created by Nick on 1/25/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum RIPCompletionTag {
    RIPCompletionNotStarted = 0,
    RIPCompletionInProgess,
    RIPCompletionDone
} RIPCompletion;

static inline RIPCompletion RIPCompletionForFloat(float f){
    if(f <= 0)
        return RIPCompletionNotStarted;
    else if(f >= 1.0)
        return RIPCompletionDone;
    else
        return RIPCompletionInProgess;
}

static inline float RIPCompletionFloatForCompletion(RIPCompletion c){
    if(c == RIPCompletionNotStarted)
        return 0.0;
    else if(c == RIPCompletionInProgess)
        return 0.5;
    else
        return 1.0;
}