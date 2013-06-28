//
//  vSpeexWriter.h
//  vSpeex
//
//  Created by Zhang Hailong on 13-6-28.
//  Copyright (c) 2013年 hailong.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol vSpeexWriter <NSObject>

-(BOOL) writeFrame:(void *) frameBytes echoBytes:(void *) echoBytes;

-(BOOL) close;

@end
