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

@interface SSViewController ()

@property(nonatomic,retain) vSpeexRecorder * recorder;
@property(nonatomic,retain) vSpeexPlayer * player;

@end

@implementation SSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.recorder = [[vSpeexRecorder alloc] init];
    self.player = [[vSpeexPlayer alloc] init];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playAction:(id)sender {
    if([sender isSelected]){
        [_player stop];
        [sender setSelected:NO];
    }
    else{
        [_player start:[NSRunLoop currentRunLoop] fromFilePath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"r.ogg"]];
        [sender setSelected:YES];
    }
}

- (IBAction)doAction:(id)sender {
    if([sender isSelected]){
        [_recorder stop];
        [sender setSelected:NO];
    }
    else{
        [_recorder start:[NSRunLoop currentRunLoop] toFilePath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"r.ogg"] speex:[[vSpeex alloc] initWithMode:vSpeexModeWB]];
        [sender setSelected:YES];
    }
}

@end
