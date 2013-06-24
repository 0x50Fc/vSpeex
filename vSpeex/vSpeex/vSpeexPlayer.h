//
//  vSpeexPlayer.h
//  vSpeex
//
//  Created by zhang hailong on 13-6-24.
//  Copyright (c) 2013年 hailong.org. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface vSpeexPlayer : NSObject

@property(nonatomic,readonly,getter = isStarted) BOOL started;

-(void) start:(NSRunLoop *) runloop fromFilePath:(NSString *) filePath;

-(void) stop;

@end
