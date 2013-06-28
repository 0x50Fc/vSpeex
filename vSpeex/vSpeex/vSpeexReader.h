//
//  vSpeexReader.h
//  vSpeex
//
//  Created by Zhang Hailong on 13-6-28.
//  Copyright (c) 2013年 hailong.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol vSpeexReader <NSObject>

-(void *) readFrame;

-(BOOL) close;

@end
