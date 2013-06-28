//
//  vSpeexOggWriter.m
//  vSpeex
//
//  Created by Zhang Hailong on 13-6-23.
//  Copyright (c) 2013年 hailong.org. All rights reserved.
//

#import "vSpeexOggWriter.h"

#include "speex/speex.h"
#include "speex/speex_header.h"
#include "ogg/ogg.h"


@interface vSpeexOggWriter(){
    FILE * _file;
    ogg_int64_t _packetno;
    ogg_stream_state _os;
    SpeexHeader _header;
    void * _ebuf;
}

@end

@implementation vSpeexOggWriter

@synthesize speex = _speex;
@synthesize closed = _closed;

-(void) dealloc{
    if(_ebuf){
        free(_ebuf);
    }
    ogg_stream_clear(&_os);
    [_speex release];
    [super dealloc];
}

-(id) initWithFilePath:(NSString *) filePath speex:(vSpeex *) speex{
    if((self = [super init])){
        
        if(speex == nil){
            [self autorelease];
            return nil;
        }
        
        _file = fopen([filePath UTF8String], "w");
        
        if(_file == nil){
            [self autorelease];
            return nil;
        }

        _speex = [speex retain];
    
        const struct SpeexMode * m = & speex_nb_mode;
        
        switch (speex.mode) {
            case vSpeexModeWB:
                m = & speex_wb_mode;
                break;
            case vSpeexModeUWB:
                m = & speex_uwb_mode;
                break;
            default:
                break;
        }
        
        srand(time(NULL));
        
        ogg_stream_init(& _os, rand());
        
        speex_init_header(&_header, speex.samplingRate, 1, m);
        
        _header.vbr = 0;
        _header.bitrate = 16;
        _header.frame_size = _speex.frameSize;
        _header.frames_per_packet = 0;
        
        int bytes = 0;
        void * data = speex_header_to_packet(&_header, & bytes);
        
        ogg_packet op;
        ogg_page page;
        int rs = 0;
        
        op.packet = data;
        op.bytes = bytes;
        op.b_o_s = 0;
        op.e_o_s = 0;
        op.granulepos = 0;
        op.packetno = _packetno++;
        
        ogg_stream_reset(& _os);
        ogg_stream_packetin(&_os, &op);
        
        while(1){
            rs = ogg_stream_flush(& _os, &page);
            if(rs <= 0){
                break;
            }
        }
        
        speex_header_free(data);
        
        if(rs != 0){
            [self autorelease];
            return nil;
        }
        
        fwrite(page.header, 1, page.header_len, _file);
        fwrite(page.body, 1, page.body_len, _file);
        
    }
    return self;
}

-(BOOL) writeFrame:(void *) frameBytes echoBytes:(void *) echoBytes{
    
    if(_closed){
        return NO;
    }
    
    int length = [_speex frameBytes];
    
    if(_ebuf == NULL){
        _ebuf = malloc(length);
    }
    
    if((length = [_speex encodeFrame:frameBytes encodeBytes:_ebuf echoBytes:echoBytes]) > 0){
    
        
        ogg_packet op;
        ogg_page page;
        int rs = 0;
        
        op.packet = _ebuf;
        op.bytes = length;
        op.b_o_s = 0;
        op.e_o_s = 0;
        op.granulepos = 0;
        op.packetno = _packetno++;
        
        ogg_stream_reset(& _os);
        ogg_stream_packetin(&_os, &op);
        
        while(1){
            rs = ogg_stream_flush(& _os, &page);
            if(rs <= 0){
                break;
            }
        }
        
        if(rs != 0){
            return NO;
        }
        
        fwrite(page.header, 1, page.header_len, _file);
        fwrite(page.body, 1, page.body_len, _file);
        
        fflush(_file);

        return YES;
    }
    
    return NO;
}

-(BOOL) close{
    
    if(!_closed){
    
        ogg_packet op;
        
        op.packet = (unsigned char*)"";
        op.bytes = 0;
        op.b_o_s = 0;
        op.e_o_s = 1;
        op.granulepos = 0;
        op.packetno = _packetno++;
        
        ogg_stream_reset(& _os);
        ogg_stream_packetin(&_os, &op);
        
        ogg_page page;
        
        int rs = 0;
        
        while(1){
            rs = ogg_stream_flush(& _os, &page);
            if(rs <= 0){
                break;
            }
        }
    
        if(_file){
            
            if(rs == 0){
                fwrite(page.header, 1, page.header_len, _file);
                fwrite(page.body, 1, page.body_len, _file);
            }
            
            fclose(_file);
            _file = NULL;
        }
        
        return rs == 0;
    }
    
    return YES;
}

-(void) flush{
    if(_file){
        fflush(_file);
    }
}

@end
