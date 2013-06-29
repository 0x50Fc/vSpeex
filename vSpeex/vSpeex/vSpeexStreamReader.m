//
//  vSpeexStreamReader.m
//  vSpeex
//
//  Created by Zhang Hailong on 13-6-29.
//  Copyright (c) 2013年 hailong.org. All rights reserved.
//

#import "vSpeexStreamReader.h"


#include "speex/speex.h"
#include "speex/speex_header.h"
#include "ogg/ogg.h"


@interface vSpeexStreamReader(){
    FILE * _file;
    vSpeex * _speex;
    char * _ebuf;
    char * _dbuf;
}

@end


@implementation vSpeexStreamReader

@synthesize closed = _closed;

-(id) initWithFilePath:(NSString *) filePath{
    if((self = [super init])){
        
        _file = fopen([filePath UTF8String], "rb");
        
        if(_file == nil){
            [self autorelease];
            return nil;
        }
        
        char data[sizeof(SpeexHeader)];
        
        if(sizeof(data) != fread(data, 1, sizeof(data), _file)){
            [self autorelease];
            return nil;
        }
        
        SpeexHeader * header = speex_packet_to_header(data, sizeof(data));
        
        if(!header){
            [self autorelease];
            return nil;
        }
        
        _speex = [[vSpeex alloc] initWithMode:header->mode];
        [_speex setSamplingRate:header->rate];
        
        
        speex_header_free(header);
        
        if(_speex == nil){
            [self autorelease];
            return nil;
        }
    }
    return self;
}

-(void) dealloc{
    
    [self close];
    
    [_speex release];
    if(_ebuf){
        free(_ebuf);
    }
    if(_dbuf){
        free(_dbuf);
    }
    [super dealloc];
}

-(void *) readFrame{
    
    if(_closed ){
        return NULL;
    }
    
    if(feof(_file)){
        return NULL;
    }
    
    unsigned short l = 0;
    
    if(fread(&l, 1, sizeof(l), _file) != sizeof(l)){
        return NULL;
    }
    
    if(_ebuf == NULL){
        _ebuf = malloc(_speex.frameBytes);
    }
    
    if(_dbuf == NULL){
        _dbuf = malloc(_speex.frameBytes);
    }
    
    l = ntohs(l);
    
    if(l ==0){
        memset(_ebuf, 0, _speex.frameBytes);
    }
    else{
        if(l != fread(_dbuf, 1, l, _file)){
            return NULL;
        }
        [_speex decodeFrame:_dbuf length:l frameBytes:_ebuf];
    }
    
    return _ebuf;

}

-(BOOL) close{
    
    if(!_closed){
        
        _closed = YES;
        
        if(_file){
            fclose(_file);
            _file = NULL;
        }
        
        return YES;
    }
    return NO;
}

@end