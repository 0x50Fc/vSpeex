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
        [player performSelectorOnMainThread:@selector(stop) withObject:nil waitUntilDone:NO];
    }
}


@implementation vSpeexPlayer

@synthesize started = _started;

-(void) dealloc{
    [self stop];
    [_reader release];
    [super dealloc];
}

-(void) start:(NSRunLoop *) runloop fromFilePath:(NSString *) filePath{
    
    if(!_started){
        
        self.reader = [[[vSpeexOggReader alloc] initWithFilePath:filePath] autorelease];
        
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
            
            status = AudioQueueNewOutput(&format, vSpeexPlayer_AudioQueueOutputCallback, self, [runloop getCFRunLoop], kCFRunLoopCommonModes, 0, &_queue);
            
            status = AudioQueueAllocateBuffer(_queue,_bufferSize,&_buffer);
            
            _buffer->mAudioDataByteSize = _bufferSize;
            
            memcpy(_buffer->mAudioData, data, _buffer->mAudioDataByteSize);
            
            AudioQueueEnqueueBuffer(_queue, _buffer, 0, NULL);
            
            status = AudioQueuePrime(_queue, 0, NULL);
            
            status = AudioQueueStart(_queue, NULL);
            
            _started = YES;

        }
    }
}

-(void) stop{
    if(_started){
        
		AudioQueueStop(_queue, YES);
		
		AudioQueueFreeBuffer(_queue,_buffer);
		
		AudioQueueDispose(_queue, YES);
		
		_started = NO;
	}
}


@end
