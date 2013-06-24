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
@synthesize started = _started;

-(void) dealloc{
    [self stop];
    [_writer release];
    [super dealloc];
}

-(void) start:(NSRunLoop *) runloop toFilePath:(NSString *) filePath{
    [self start:runloop toFilePath:filePath speex:[[[vSpeex alloc] initWithMode:vSpeexModeNB] autorelease]];
}

-(void) start:(NSRunLoop *) runloop toFilePath:(NSString *) filePath speex:(vSpeex *) speex{
    if(!_started){
        
        self.writer = [[[vSpeexOggWriter alloc] initWithFilePath:filePath speex:speex] autorelease];
        
        _bufferSize = _writer.speex.frameBytes;
        
        format.mFormatID = kAudioFormatLinearPCM;
		format.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger;
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
        
        status = AudioQueueStart(_queue, NULL);

        _started = YES;
    }
}

-(void) stop{
    
    if(_started){
        
		AudioQueueStop(_queue, YES);
		
		for(int i=0;i<AUDIO_RECORD_BUFFER_SIZE;i++){
			AudioQueueFreeBuffer(_queue,_buffers[i]);
		}

		AudioQueueDispose(_queue, YES);
        
        _started = NO;
        
        [_writer close];
        self.writer = nil;
    }
}

@end
