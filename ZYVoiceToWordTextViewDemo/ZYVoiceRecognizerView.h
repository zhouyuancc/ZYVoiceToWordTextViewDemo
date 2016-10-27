//
//  ZYVoiceRecognizerView.h
//  ZYVoiceToWordTextViewDemo
//
//  Created by ZhouYuan on 16/10/27.
//  Copyright © 2016年 ZY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iflyMSC/iflyMSC.h"

@interface ZYVoiceRecognizerView : UIView<IFlySpeechRecognizerDelegate>

@property (nonatomic, strong) IFlySpeechRecognizer *iFlySpeechRecognizer;

@property (nonatomic, copy) void (^voiceRecResultBlock)(NSString *result);

@property (nonatomic, copy) void (^voiceDeleteBackwardBlock)();

- (void)cancel;

@end
