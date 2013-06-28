//
//  vSpeexOggReader.h
//  vSpeex
//
//  Created by Zhang Hailong on 13-6-23.
//  Copyright (c) 2013年 hailong.org. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <vSpeex/vSpeex.h>

#import <vSpeex/vSpeexReader.h>

@interface vSpeexOggReader : NSObject<vSpeexReader>

@property(nonatomic,readonly) vSpeex * speex;
@property(nonatomic,readonly, getter = isClosed) BOOL closed;

-(id) initWithFilePath:(NSString *) filePath;

-(void *) readFrame;

-(BOOL) close;

@end
