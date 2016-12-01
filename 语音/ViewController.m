//
//  ViewController.m
//  语音
//
//  Created by 周鹏 on 2016/12/1.
//  Copyright © 2016年 周鹏. All rights reserved.
//

#import "ViewController.h"
#import "VoiceChatBtn.h"
#import "ICRecordManager.h"
#import "ICVoiceHud.h"
@interface ViewController ()<VoiceChatBtnDelegate>
/** 按住说话 */
@property (nonatomic, strong) VoiceChatBtn *talkButton;
/** 录音文件名 */
@property (nonatomic, copy) NSString *recordName;
//音量大小
@property (nonatomic, strong) ICVoiceHud *voiceHud;
//定时器
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ViewController

- (ICVoiceHud *)voiceHud
{
    if (!_voiceHud) {
        _voiceHud = [[ICVoiceHud alloc] initWithFrame:CGRectMake(50, 50, 155, 155)];
        _voiceHud.hidden = YES;
    }
    return _voiceHud;
}

- (NSTimer *)timer
{
    if (!_timer) {
        _timer =[NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(progressChange) userInfo:nil repeats:YES];
    }
    return _timer;
}

- (void)progressChange
{
    AVAudioRecorder *recorder = [[ICRecordManager shareManager] recorder] ;
    [recorder updateMeters];
    float power= [recorder averagePowerForChannel:0];//取得第一个通道的音频，注意音频强度范围时-160到0,声音越大power绝对值越小
    CGFloat progress = (1.0/160)*(power + 160);
    self.voiceHud.progress = progress;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.voiceHud];
    [self.view addSubview:self.talkButton];
}

-(VoiceChatBtn *)talkButton
{
    if (!_talkButton) {
        _talkButton = [[VoiceChatBtn alloc]initWithFrame:CGRectMake(150, 400, 100, 30)];
        _talkButton.delegate = self;
    }
    return _talkButton;
}
#pragma makr ---代理事件---
- (void)chatBoxDidStartRecordingVoice:(VoiceChatBtn *)chatBox
{
    self.recordName = [self currentRecordFileName];

    [[ICRecordManager shareManager] startRecordingWithFileName:self.recordName completion:^(NSError *error) {
        if (error) {   // 加了录音权限的判断
        } else {
            [self timerInvalue];
            self.voiceHud.hidden = NO;
            [self timer];
        }
    }];
}
- (void)chatBoxDidStopRecordingVoice:(VoiceChatBtn *)chatBox
{
    __weak typeof(self) weakSelf = self;
    [[ICRecordManager shareManager] stopRecordingWithCompletion:^(NSString *recordPath) {
        if ([recordPath isEqualToString:shortRecord]) {
            [self timerInvalue];
            self.voiceHud.animationImages = nil;
            self.voiceHud.image = [UIImage imageNamed:@"voiceShort"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.voiceHud.hidden = YES;
            });
            [[ICRecordManager shareManager] removeCurrentRecordFile:weakSelf.recordName];
        } else {    // send voice message
            [self timerInvalue]; // 销毁定时器
            self.voiceHud.hidden = YES;
            if (recordPath) {
            //发消息
                NSLog(@"成功，发消息%@",recordPath);
            }
        }
    }];
}

//
- (void)chatBoxDidCancelRecordingVoice:(VoiceChatBtn *)chatBox
{
    
    [self timerInvalue];
    self.voiceHud.hidden = YES;
    
    [[ICRecordManager shareManager] removeCurrentRecordFile:self.recordName];

}

// 向外或向里移动
- (void)chatBoxDidDrag:(BOOL)inside
{
    if (inside) {
        [_timer setFireDate:[NSDate distantPast]];
        _voiceHud.image  = [UIImage imageNamed:@"voice_1"];
    } else {
        [_timer setFireDate:[NSDate distantFuture]];
        self.voiceHud.animationImages  = nil;
        self.voiceHud.image = [UIImage imageNamed:@"cancelVoice"];
    }}

#pragma mark --- 具体事件
- (NSString *)currentRecordFileName
{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [NSString stringWithFormat:@"%ld",(long)timeInterval];
    return fileName;
}

#pragma mark -- 销毁定时器
- (void)timerInvalue
{
    [_timer invalidate];
    _timer  = nil;
}

@end
