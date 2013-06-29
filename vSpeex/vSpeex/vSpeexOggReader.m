//
//  vSpeexOggReader.m
//  vSpeex
//
//  Created by Zhang Hailong on 13-6-23.
//  Copyright (c) 2013年 hailong.org. All rights reserved.
//

#import "vSpeexOggReader.h"

#include "speex/speex.h"
#include "speex/speex_header.h"
#include "ogg/ogg.h"


@interface vSpeexOggReader(){
    FILE * _file;
    ogg_sync_state _oss;
    ogg_stream_state _os;
    struct {
        char data[10240];
        int length;
    } _sbuf;
    vSpeex * _speex;
    char * _ebuf;
    int _ret;
}

@end


@implementation vSpeexOggReader

@synthesize closed = _closed;

-(id) initWithFilePath:(NSString *) filePath{
    if((self = [super init])){
        
        _file = fopen([filePath UTF8String], "r");
        
        if(_file == nil){
            [self autorelease];
            return nil;
        }
        
        ogg_sync_init(&_oss);

        ogg_page page;
        ogg_packet op;
        
        while(1){
            
            if(_ret == 0){
                _sbuf.length = fread(_sbuf.data, 1, sizeof(_sbuf.data), _file);
                if(_sbuf.length ==0){
                    [self autorelease];
                    return nil;
                }
                char * data = ogg_sync_buffer(&_oss, _sbuf.length);
                memcpy(data, _sbuf.data, _sbuf.length);
                ogg_sync_wrote(&_oss, _sbuf.length);
            }
            
            _ret = ogg_sync_pageout(&_oss, &page);
            
            if(_ret < 0){
                [self autorelease];
                return nil;
            }
            
            if(_ret == 0){
                continue;
            }
            
            if(_os.serialno == 0){
                ogg_stream_init(&_os, ogg_page_serialno(& page));
            }
            
            ogg_stream_reset(&_os);
            
            ogg_stream_pagein(&_os, &page);
            
            _ret = ogg_stream_packetout(&_os, &op);
            
            if(_ret == 1){
                
                SpeexHeader * header = speex_packet_to_header((char *)op.packet, op.bytes);
                
                if(!header){
                    [self autorelease];
                    return nil;
                }
                
                _speex = [[vSpeex alloc] initWithMode:header->mode];
                [_speex setSamplingRate:header->rate];
                
                speex_header_free(header);
                
                break;
                
            }
            else{
                [self autorelease];
                return nil;
            }
            
        }
    }
    return self;
}

-(void) dealloc{
    
    [self close];
    
    ogg_sync_clear(&_oss);
    ogg_stream_clear(&_os);
    [_speex release];
    if(_ebuf){
        free(_ebuf);
    }
    [super dealloc];
}

-(void *) readFrame{
    
    if(_closed ){
        return NULL;
    }
    
    if(_ret !=0 && _ret != 1){
        return NULL;
    }
    
    ogg_page page;
    ogg_packet op;
    
    while(1){
        
        if(_ret == 0){
            _sbuf.length = fread(_sbuf.data, 1, sizeof(_sbuf.data), _file);
            if(_sbuf.length ==0){
                return NULL;
            }
            char * data = ogg_sync_buffer(&_oss, _sbuf.length);
            memcpy(data, _sbuf.data, _sbuf.length);
            ogg_sync_wrote(&_oss, _sbuf.length);
        }
        
        _ret = ogg_sync_pageout(&_oss, &page);
        
        if(_ret < 0){
            return NULL;
        }
        
        if(_ret == 0){
            continue;
        }
        
        ogg_stream_reset(&_os);
        
        ogg_stream_pagein(&_os, &page);
        
        _ret = ogg_stream_packetout(&_os, &op);
        
        if(_ret == 1){
            
            if(op.e_o_s != 0){
                return NULL;
            }
            
            if(_ebuf == NULL){
                _ebuf = malloc(_speex.frameBytes);
            }
            
            memset(_ebuf, 0, _speex.frameBytes);
            
            [_speex decodeFrame:op.packet length:op.bytes frameBytes:_ebuf];
            
            return _ebuf;
        
        }
        else{
            return NULL;
        }
        
    }
    
    return NULL;
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
