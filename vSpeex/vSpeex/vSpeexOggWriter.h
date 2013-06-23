//
//  vSpeexOggWriter.h
//  vSpeex
//
//  Created by Zhang Hailong on 13-6-23.
//  Copyright (c) 2013年 hailong.org. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <vSpeex/vSpeex.h>

@interface vSpeexOggWriter : NSObject

@property(nonatomic,readonly) vSpeex * speex;
@property(nonatomic,readonly, getter = isClosed) BOOL closed;

-(id) initWithFilePath:(NSString *) filePath speex:(vSpeex *) speex;

-(BOOL) writeFrame:(void *) frameBytes echoBytes:(void *) echoBytes;

-(BOOL) close;

@end
