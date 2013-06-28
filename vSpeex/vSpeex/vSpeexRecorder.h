//
//  vSpeexRecorder.h
//  vSpeex
//
//  Created by zhang hailong on 13-6-24.
//  Copyright (c) 2013年 hailong.org. All rights reserved.
//

#import <Foundation/Foundation.h>


#import <vSpeex/vSpeex.h>

@interface vSpeexRecorder : NSOperation

-(id) initWithFilePath:(NSString *) filePath speex:(vSpeex *) speex;

@end
