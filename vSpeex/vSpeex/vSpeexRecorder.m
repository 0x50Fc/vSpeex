//
//  vSpeexRecorder.m
//  vSpeex
//
//  Created by zhang hailong on 13-6-24.
//  Copyright (c) 2013年 hailong.org. All rights reserved.
//

#import "vSpeexRecorder.h"
#import <AudioToolbox/AudioToolbox.h>

#import "vSpeexOggWriter.h"

#define AUDIO_RECORD_BUFFER_SIZE		4	

@interface vSpeexRecorder(){
    AudioQueueRef _queue;
    AudioQueueBufferRef _buffers[AUDIO_RECORD_BUFFER_SIZE];
    AudioStreamBasicDescription format;
    int _bufferSize;
    
    BOOL _finished;
    BOOL _executing;
}

@property(nonatomic,retain) vSpeexOggWriter * writer;

@end

static void vSpeexRecorder_AudioQueueInputCallback(
										 void *                          inUserData,
										 AudioQueueRef                   inAQ,
										 AudioQueueBufferRef             inBuffer,
										 const AudioTimeStamp *          inStartTime,
										 UInt32                          inNumberPacketDescriptions,
										 const AudioStreamPacketDescription *inPacketDescs){
	
    vSpeexOggWriter * writer = (vSpeexOggWriter *) inUserData;
    
    [writer writeFrame:inBuffer->mAudioData echoBytes:nil];
    
	inBuffer->mAudioDataByteSize = 0;
	
	AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
}


@implementation vSpeexRecorder

@synthesize writer = _writer;

-(void) dealloc{
    [_writer close];
    [_writer release];
    [super dealloc];
}

-(id) initWithWriter:(id<vSpeexWriter>)writer{
    if((self = [super init])){
        _writer = [writer retain];
        if(_writer == nil){
            [self autorelease];
            return nil;
        }
    }
    return self;
}



-(BOOL) isReady{
    return _writer != nil;
}

-(BOOL) isConcurrent{
    return YES;
}

-(BOOL) isExecuting{
    return _executing;
}

-(BOOL) isFinished{
    return _finished;
}

-(void) cancel{
    [super cancel];
    _finished = YES;
}

-(void) main{
    
    _executing = YES;
    
    @autoreleasepool {
        
        NSRunLoop * runloop = [NSRunLoop currentRunLoop];
        

        _bufferSize = [_writer.speex frameBytes];

        format.mFormatID = kAudioFormatLinearPCM;
        format.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
        format.mChannelsPerFrame = 1;
        format.mBitsPerChannel = 16;
        format.mFramesPerPacket = 1;
        format.mBytesPerPacket =  2;
        format.mBytesPerFrame = 2;
        format.mSampleRate = _writer.speex.samplingRate;
        
        OSStatus status;
      
        status = AudioQueueNewInput(&format, vSpeexRecorder_AudioQueueInputCallback, _writer, [runloop getCFRunLoop], kCFRunLoopCommonModes, 0, &_queue);
        
        for(int i=0;i<AUDIO_RECORD_BUFFER_SIZE;i++){
            status = AudioQueueAllocateBuffer(_queue,_bufferSize,&_buffers[i]);
            status = AudioQueueEnqueueBuffer(_queue, _buffers[i], 0, NULL);
        }
        
        AudioQueueFlush(_queue);
        
        AudioQueueSetParameter(_queue, kAudioQueueParam_Volume, 1.0);
        
        status = AudioQueueStart(_queue, NULL);
        
        while(![self isCancelled] && !_finished){
            @autoreleasepool {
                [runloop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.3]];
            }
        }
        
        AudioQueueStop(_queue, YES);
		
		for(int i=0;i<AUDIO_RECORD_BUFFER_SIZE;i++){
			AudioQueueFreeBuffer(_queue,_buffers[i]);
		}
        
		AudioQueueDispose(_queue, YES);
      
        [_writer close];
        
    }
    
    _executing = NO;
}

@end
