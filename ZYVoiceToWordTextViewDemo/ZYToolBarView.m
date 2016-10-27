//
//  ZYToolBarView.m
//  ZYVoiceToWordTextViewDemo
//
//  Created by ZhouYuan on 16/10/27.
//  Copyright © 2016年 ZY. All rights reserved.
//

#import "ZYToolBarView.h"

#define kScreen_Height [UIScreen mainScreen].bounds.size.height
#define kScreen_Width [UIScreen mainScreen].bounds.size.width

//color
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define backColor RGBACOLOR(249, 249, 249, 1.0)
#define BlueButtonColor RGBACOLOR(60, 163, 250, 1.0)

#define labelFont [UIFont systemFontOfSize:16]
static const CGFloat h = 44;

@interface ZYToolBarView ()

//文字按钮
@property (nonatomic, strong) UIButton *toolWordBtn;

//语音按钮
@property (nonatomic, strong) UIButton *toolVoiceBtn;

@end

@implementation ZYToolBarView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    CGFloat y = kScreen_Height - h;
    self.frame = CGRectMake(0, y, kScreen_Width, h);
    
    //语音\文字 按钮
    //文字
    [self addSubview:self.toolWordBtn];
    //语音
    [self addSubview:self.toolVoiceBtn];
    
    //上边线
    UIView *divide = [ZYToolBarView divideLineView:(CGPoint){0,0}];
    [self addSubview:divide];
    
    //按钮中间的分割线
    CGFloat x = CGRectGetMaxX(self.toolWordBtn.frame);
    UIView *divideBtn = [ZYToolBarView divideLineView:(CGPoint){x,0}];
    [self addSubview:divideBtn];

    self.hidden = YES;
}

#pragma mark - lazy load
- (UIButton *)toolWordBtn
{
    if (_toolWordBtn == nil) {
        
        _toolWordBtn = [self toolButtonWithX:0 withText:@"文字"];

        [_toolWordBtn addTarget:self action:@selector(wordKeybroadAction) forControlEvents:UIControlEventTouchUpInside];
        _toolWordBtn.selected = YES;
    }
    
    return _toolWordBtn;
}
- (UIButton *)toolVoiceBtn
{
    if (_toolVoiceBtn == nil) {
        
        CGFloat wordX = CGRectGetMaxX(self.toolWordBtn.frame) + 0.5;
        
        _toolVoiceBtn = [self toolButtonWithX:wordX withText:@"语音"];

        [_toolVoiceBtn addTarget:self action:@selector(voiceKeybroadAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _toolVoiceBtn;
}
#pragma mark - action
/**
 文字键盘
 */
- (void)wordKeybroadAction
{
    self.toolWordBtn.selected = YES;
    self.toolVoiceBtn.selected = NO;
    
    //展示文字键盘
    if(self.wordActionBlock){
        self.wordActionBlock();
    }
}
//语音转文字
- (void)voiceKeybroadAction
{
    self.toolVoiceBtn.selected = YES;
    self.toolWordBtn.selected = NO;
    
    //展示语音键盘
    if (self.voiceActionBlock) {
        self.voiceActionBlock();
    }
}

#pragma mark - basic func
- (UIButton *)toolButtonWithX:(CGFloat)x withText:(NSString *)text
{
    CGFloat btnW = (kScreen_Width - 0.5)/2;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x, 0, btnW, h)];
    button.backgroundColor = backColor;
    button.titleLabel.font = labelFont;
    
    [button setTitle:text forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    [button setTitleColor:BlueButtonColor forState:UIControlStateHighlighted];
    [button setTitleColor:BlueButtonColor forState:UIControlStateSelected];
    
    return button;
}
/**
 封装分割线
 CGPoint:{x,y}
 */
+ (UIView *)divideLineView:(CGPoint)point
{
    CGFloat x = point.x;
    CGFloat y = point.y;
    CGFloat w = [UIScreen mainScreen].bounds.size.width - x;
    CGFloat divideH = 0.5;
    
    if (x > h) {
        w = 0.5;
        divideH = h;
    }
    
    UIView *divide = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, divideH)];
    
    divide.backgroundColor = [UIColor blackColor];
    divide.alpha = 0.1;
    
    return divide;
}

@end
