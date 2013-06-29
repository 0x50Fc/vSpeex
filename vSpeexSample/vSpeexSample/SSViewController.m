//
//  SSViewController.m
//  vSpeexSample
//
//  Created by zhang hailong on 13-6-24.
//  Copyright (c) 2013年 hailong.org. All rights reserved.
//

#import "SSViewController.h"

#import <vSpeex/vSpeexRecorder.h>
#import <vSpeex/vSpeexPlayer.h>
#import <vSpeex/vSpeexStreamWriter.h>
#import <vSpeex/vSpeexStreamReader.h>

@interface SSViewController ()

@property(nonatomic,retain) vSpeexRecorder * recorder;
@property(nonatomic,retain) vSpeexPlayer * player;
@property(nonatomic,retain) NSOperationQueue * operationQueue;

@end

@implementation SSViewController

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])){
        
        _operationQueue = [[NSOperationQueue alloc] init];
        
        [_operationQueue setMaxConcurrentOperationCount:2];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.recorder = [[vSpeexRecorder alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playAction:(id)sender {
    if([sender isSelected]){
        [_player cancel];
        [sender setSelected:NO];
    }
    else{
        
        vSpeexStreamReader * reader = [[vSpeexStreamReader alloc] initWithFilePath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"r.spx"]];
        
        self.player = [[vSpeexPlayer alloc] initWithReader:reader];
        [_operationQueue addOperation:_player];
        [sender setSelected:YES];
    }
}

- (IBAction)doAction:(id)sender {
    if([sender isSelected]){
        [_recorder cancel];
        [sender setSelected:NO];
    }
    else{
        vSpeex * speex = [[vSpeex alloc] initWithMode:vSpeexModeWB];
        vSpeexStreamWriter * writer = [[vSpeexStreamWriter alloc] initWithFilePath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"r.spx"] speex:speex];
        
        self.recorder = [[vSpeexRecorder alloc] initWithWriter:writer];
        
        [_operationQueue addOperation:_recorder];
        
        [sender setSelected:YES];
    }
}

@end
