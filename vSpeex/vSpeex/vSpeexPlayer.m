//
//  vSpeexPlayer.m
//  vSpeex
//
//  Created by zhang hailong on 13-6-24.
//  Copyright (c) 2013年 hailong.org. All rights reserved.
//

#import "vSpeexPlayer.h"
#import <AudioToolbox/AudioToolbox.h>

#import <vSpeex/vSpeexOggReader.h>

@interface vSpeexPlayer(){
    AudioQueueRef _queue;
    AudioQueueBufferRef _buffer;
    AudioStreamBasicDescription format;
    int _bufferSize;
    BOOL _finished;
    BOOL _executing;
}

@property(nonatomic,assign) int bufferSize;
@property(nonatomic,retain) vSpeexOggReader * reader;

@end

static void vSpeexPlayer_AudioQueueOutputCallback(
										void *                  inUserData,
										AudioQueueRef           inAQ,
										AudioQueueBufferRef     inBuffer){
	
    vSpeexPlayer * player = (vSpeexPlayer *) inUserData;
    
    inBuffer->mAudioDataByteSize = player.bufferSize;
    
    void * data = [player.reader readFrame];
    
    if(data){
        memcpy(inBuffer->mAudioData, data, inBuffer->mAudioDataByteSize);
        AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
    }
    else{
        [player cancel];
    }
}


@implementation vSpeexPlayer

-(void) dealloc{
    [_reader release];
    [super dealloc];
}

-(BOOL) isReady{
    return _reader != nil;
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
        
        void * data = [_reader readFrame];
        
        if(data){
            
            _bufferSize = [_reader.speex frameBytes];
            
            format.mFormatID = kAudioFormatLinearPCM;
            format.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger;
            format.mChannelsPerFrame = 1;
            format.mBitsPerChannel = 16;
            format.mFramesPerPacket = 1;
            format.mBytesPerPacket =  2;
            format.mBytesPerFrame = 2;
            format.mSampleRate = _reader.speex.samplingRate;
            
            OSStatus status;
            
            status = AudioQueueNewOutput(&format, vSpeexPlayer_AudioQueueOutputCallback, self, CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &_queue);
            
            status = AudioQueueAllocateBuffer(_queue,_bufferSize,&_buffer);
            
            _buffer->mAudioDataByteSize = _bufferSize;
            
            memcpy(_buffer->mAudioData, data, _buffer->mAudioDataByteSize);
            
            AudioQueueEnqueueBuffer(_queue, _buffer, 0, NULL);
            
            status = AudioQueuePrime(_queue, 0, NULL);
            
            AudioQueueSetParameter(_queue, kAudioQueueParam_Volume, 1.0);
        
            status = AudioQueueStart(_queue, NULL);
            
        }
        else{
            _executing = NO;
            _finished = YES;
            return;
        }
        
        while(![self isCancelled] && !_finished){
            @autoreleasepool {
                [runloop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.3]];
            }
        }
        
        AudioQueueStop(_queue, YES);
		
		AudioQueueFreeBuffer(_queue,_buffer);
		
		AudioQueueDispose(_queue, YES);
        
        
        _buffer = NULL;
        _queue = NULL;
        
    }
    
    _executing = NO;
}

-(id) initWithFilePath:(NSString *) filePath{
    if((self = [super init])){
        _reader = [[vSpeexOggReader alloc] initWithFilePath:filePath];
        if(_reader == nil){
            [self autorelease];
            return nil;
        }
    }
    return self;
}

@end
