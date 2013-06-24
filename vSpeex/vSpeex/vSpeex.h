//
//  vSpeex.h
//  vSpeex
//
//  Created by Zhang Hailong on 13-6-23.
//  Copyright (c) 2013年 hailong.org. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum _vSpeexMode {
    vSpeexModeNB,vSpeexModeWB,vSpeexModeUWB
} vSpeexMode;

@interface vSpeex : NSObject

@property(nonatomic, readonly) vSpeexMode mode;
@property(nonatomic,readonly) NSInteger frameSize;
@property(nonatomic,readonly) NSInteger frameBytes;
@property(nonatomic,assign) NSInteger samplingRate;
@property(nonatomic,assign) NSInteger quality;  // 1~10 default 8

-(id) initWithMode:(vSpeexMode) mode;

-(NSInteger) encodeFrame:(void *) frameBytes encodeBytes:(void *) encodeBytes echoBytes:(void *) echoBytes;

-(NSInteger) decodeFrame:(void *) encodeBytes length:(NSInteger) length frameBytes:(void *) frameBytes;


@end
