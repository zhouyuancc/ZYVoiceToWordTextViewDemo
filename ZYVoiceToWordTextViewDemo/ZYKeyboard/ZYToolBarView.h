//
//  ZYToolBarView.h
//  ZYVoiceToWordTextViewDemo
//
//  Created by ZhouYuan on 16/10/27.
//  Copyright © 2016年 ZY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZYToolBarView : UIView
/**
 文字键盘响应
 */
@property (nonatomic, copy) void (^wordActionBlock)();
/**
 语音转文字键盘响应
 */
@property (nonatomic, copy) void (^voiceActionBlock)();

/**
 封装分割线
 CGPoint:{x,y}
 */
+ (UIView *)divideLineView:(CGPoint)point;

@end
