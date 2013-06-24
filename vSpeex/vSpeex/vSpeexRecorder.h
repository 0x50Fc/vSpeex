//
//  vSpeexRecorder.h
//  vSpeex
//
//  Created by zhang hailong on 13-6-24.
//  Copyright (c) 2013年 hailong.org. All rights reserved.
//

#import <Foundation/Foundation.h>


#import <vSpeex/vSpeex.h>

@interface vSpeexRecorder : NSObject

@property(nonatomic,readonly,getter = isStarted) BOOL started;

-(void) start:(NSRunLoop *) runloop toFilePath:(NSString *) filePath;

-(void) start:(NSRunLoop *) runloop toFilePath:(NSString *) filePath speex:(vSpeex *) speex;

-(void) stop;

@end
