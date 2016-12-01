//
//  VoiceChatBtn.h
//  语音
//
//  Created by 周鹏 on 2016/12/1.
//  Copyright © 2016年 周鹏. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VoiceChatBtn;

@protocol VoiceChatBtnDelegate <NSObject>
/**
 *  开始录音
 *
 *  @param chatBox chatBox
 */
- (void)chatBoxDidStartRecordingVoice:(VoiceChatBtn *)chatBox;
- (void)chatBoxDidStopRecordingVoice:(VoiceChatBtn *)chatBox;
- (void)chatBoxDidCancelRecordingVoice:(VoiceChatBtn *)chatBox;
- (void)chatBoxDidDrag:(BOOL)inside;
@end



@interface VoiceChatBtn : UIView
@property (nonatomic, weak) id<VoiceChatBtnDelegate>delegate;
@end
