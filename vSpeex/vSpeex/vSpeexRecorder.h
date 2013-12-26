//
//  vSpeexRecorder.h
//  vSpeex
//
//  Created by zhang hailong on 13-6-24.
//  Copyright (c) 2013年 hailong.org. All rights reserved.
//

#import <Foundation/Foundation.h>


#import <vSpeex/vSpeex.h>
#import <vSpeex/vSpeexWriter.h>

@interface vSpeexRecorder : NSOperation

@property(nonatomic,unsafe_unretained) id delegate;
@property(nonatomic,readonly) NSTimeInterval duration;
@property(nonatomic,readonly) SInt16 * frameBytes;
@property(nonatomic,readonly) UInt32 frameSize;

-(id) initWithWriter:(id<vSpeexWriter>) writer;

-(void) stop;

-(void) resume;

-(void) pause;

@end

@protocol vSpeexRecorderDelegate

@optional

-(void) vSpeexRecorderDidStarted:(vSpeexRecorder *) recorder;

-(void) vSpeexRecorderDidStoped:(vSpeexRecorder *)recorder;

@end