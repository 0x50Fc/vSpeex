//
//  vSpeexStreamWriter.h
//  vSpeex
//
//  Created by Zhang Hailong on 13-6-29.
//  Copyright (c) 2013年 hailong.org. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <vSpeex/vSpeexWriter.h>
#import <vSpeex/vSpeex.h>

@interface vSpeexStreamWriter : NSObject<vSpeexWriter>

@property(nonatomic,readonly) vSpeex * speex;
@property(nonatomic,readonly, getter = isClosed) BOOL closed;

-(id) initWithFilePath:(NSString *) filePath speex:(vSpeex *) speex;

@end
