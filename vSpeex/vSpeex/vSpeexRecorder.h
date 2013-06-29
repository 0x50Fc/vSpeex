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

-(id) initWithWriter:(id<vSpeexWriter>) writer;

@end

@protocol vSpeexRecorderDelegate

@optional

-(void) vSpeexRecorderDidStarted:(vSpeexRecorder *) recorder;

-(void) vSpeexRecorderDidStoped:(vSpeexRecorder *)recorder;

@end