//
//  vSpeex.m
//  vSpeex
//
//  Created by Zhang Hailong on 13-6-23.
//  Copyright (c) 2013年 hailong.org. All rights reserved.
//

#import "vSpeex.h"

#include "speex/speex.h"
#include "speex/speex_preprocess.h"
#include "speex/speex_echo.h"


@interface vSpeex(){
    void * _encodeState;
	void * _decodeState;
	SpeexPreprocessState * _preprocessState;
	SpeexEchoState * _echoState;
	SpeexBits _bits;
    spx_int16_t * _ebuf;
}

@end

@implementation vSpeex

@synthesize frameSize = _frameSize;
@synthesize samplingRate = _samplingRate;
@synthesize quality = _quality;
@synthesize frameBytes = _frameBytes;

-(id) initWithMode:(vSpeexMode) mode{
    if((self = [super init])){
        
        _quality = 5;
        _mode = mode;
        
        switch (mode) {
            case vSpeexModeNB:
                _encodeState = speex_encoder_init(& speex_nb_mode);
                _decodeState = speex_decoder_init(& speex_nb_mode);
                break;
            case vSpeexModeWB:
                _encodeState = speex_encoder_init(& speex_wb_mode);
                _decodeState = speex_decoder_init(& speex_wb_mode);
                break;
            case vSpeexModeUWB:
                _encodeState = speex_encoder_init(& speex_uwb_mode);
                _decodeState = speex_decoder_init(& speex_uwb_mode);
                break;
            default:
                [self release];
                return nil;
                break;
        }
        
        speex_bits_init(& _bits);
        
        
        int b = 1;
        
        speex_encoder_ctl(_encodeState,SPEEX_GET_FRAME_SIZE,&_frameSize);
        speex_encoder_ctl(_encodeState,SPEEX_SET_QUALITY,&_quality);
        speex_encoder_ctl(_encodeState,SPEEX_GET_SAMPLING_RATE,&_samplingRate);
        speex_encoder_ctl(_encodeState,SPEEX_SET_DTX,&b);
        speex_encoder_ctl(_encodeState,SPEEX_SET_VAD,&b);
        
        _preprocessState = speex_preprocess_state_init(_frameSize,_samplingRate);
        
        speex_preprocess_ctl(_preprocessState, SPEEX_PREPROCESS_SET_DENOISE, &b);
        
        _echoState = speex_echo_state_init(_frameSize, 100 );
        
        _frameBytes = _frameSize * sizeof(spx_int16_t);
        
    }
    return self;
}

-(void) dealloc{
    
    speex_bits_destroy(& _bits);
    
    if(_encodeState){
        speex_encoder_destroy(_encodeState);
    }
    
    if(_decodeState){
        speex_decoder_destroy(_decodeState);
    }
    
    if(_preprocessState){
        speex_preprocess_state_destroy(_preprocessState);
    }
    
    if(_echoState){
        speex_echo_state_destroy(_echoState);
    }
    
    if(_ebuf){
        free(_ebuf);
    }
    
    [super dealloc];
}

-(NSInteger) encodeFrame:(void *) frameBytes encodeBytes:(void *) encodeBytes echoBytes:(void *) echoBytes{
    
    spx_int16_t * enc = (spx_int16_t *) frameBytes;
    
    if(echoBytes){
        
        if(_ebuf == NULL){
            _ebuf = (spx_int16_t *) malloc(_frameBytes);
        }
        
        speex_echo_state_reset(_echoState);
        speex_echo_cancellation(_echoState, enc, echoBytes, _ebuf);
        
        enc = _ebuf;
    }
    
    if(speex_preprocess_run(_preprocessState, enc))
    {
        speex_bits_reset(&_bits);
        speex_encode_int(_encodeState, enc, &_bits);
        return speex_bits_write(&_bits, encodeBytes, _frameBytes);
    }
    
    return 0;
}

-(NSInteger) decodeFrame:(void *) encodeBytes length:(NSInteger) length frameBytes:(void *) frameBytes{
   
    int rs = 0;
    
    speex_bits_reset(&_bits);
    speex_bits_read_from(&_bits, encodeBytes, length);
    rs = speex_decode_int(_decodeState, &_bits, frameBytes);
   
    return rs ==0 ? _frameBytes : 0;

}


-(void) setQuality:(NSInteger)quality{
    _quality = quality;
    speex_encoder_ctl(_encodeState,SPEEX_SET_QUALITY,&_samplingRate);
}

@end
