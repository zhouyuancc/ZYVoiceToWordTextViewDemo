//
//  ZYVoiceRecognizerView.m
//  ZYVoiceToWordTextViewDemo
//
//  Created by ZhouYuan on 16/10/27.
//  Copyright © 2016年 ZY. All rights reserved.
//

#import "ZYVoiceRecognizerView.h"
#import "ZYToolBarView.h"
//语音转文字 讯飞
#import "iflyMSC/IFlyRecognizerViewDelegate.h"
#import "iflyMSC/IFlyRecognizerView.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "ISRDataHelper.h"

#define kScreen_Width [UIScreen mainScreen].bounds.size.width
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define BlueButtonColor RGBACOLOR(60, 163, 250, 1.0)

@interface ZYVoiceRecognizerView ()

//讯飞 语音转文字 按钮
@property (nonatomic, strong) UIButton *iflyVoiceBtn;
//提示label
@property (nonatomic, strong) UILabel *toolTipLabel;
//语音退格键
@property (nonatomic, strong) UIButton *backspaceBtn;

@end

@implementation ZYVoiceRecognizerView

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
    self.frame = CGRectMake(0, 0, kScreen_Width, 0);
    self.backgroundColor = [UIColor whiteColor];
    //上边线
    UIView *divide = [ZYToolBarView divideLineView:(CGPoint){0,0}];
    [self addSubview:divide];
    
    //退格键
    [self addSubview:self.backspaceBtn];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    if (frame.size.height > 0 && ![self.subviews containsObject:self.iflyVoiceBtn] && ![self.subviews containsObject:self.toolTipLabel]) {
        //按钮 讯飞 语音转文字
        [self addSubview:self.iflyVoiceBtn];
        [self addSubview:self.toolTipLabel];
    }
}

#pragma mark - 讯飞 func
/**
 设置识别参数
 ****/
-(void)initRecognizer
{
    NSString *initString = @"appid=58119529";
    [IFlySpeechUtility createUtility:initString];
    
    [IFlySetting showLogcat:NO];//关闭日志
    
    //初始化语音识别控件
    if (_iFlySpeechRecognizer == nil) {
        _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
        
        [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
        
        //设置听写模式
        [_iFlySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    }
    _iFlySpeechRecognizer.delegate = self;
    
    //设置音频来源为麦克风
    [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
    
    //设置听写结果格式为json
    [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
    //保存录音文件，保存在sdk工作路径中，如未设置工作路径，则默认保存在library/cache下
    [_iFlySpeechRecognizer setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
    //设置最长录音时间
    [_iFlySpeechRecognizer setParameter:@"30000" forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
    //设置后端点
    [_iFlySpeechRecognizer setParameter:@"3000" forKey:[IFlySpeechConstant VAD_EOS]];
    //设置前端点
    [_iFlySpeechRecognizer setParameter:@"3000" forKey:[IFlySpeechConstant VAD_BOS]];
    //网络等待时间
    [_iFlySpeechRecognizer setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
    //设置采样率，推荐使用16K
    [_iFlySpeechRecognizer setParameter:@"16000" forKey:[IFlySpeechConstant SAMPLE_RATE]];
    //设置语言
    [_iFlySpeechRecognizer setParameter:@"zh_cn" forKey:[IFlySpeechConstant LANGUAGE]];
    [_iFlySpeechRecognizer setParameter:@"mandarin" forKey:[IFlySpeechConstant ACCENT]];
    //设置是否返回标点符号
    [_iFlySpeechRecognizer setParameter:@"1" forKey:[IFlySpeechConstant ASR_PTT]];
}
/**
 停止录音回调
 ****/
- (void)onEndOfSpeech
{
    if (self.iflyVoiceBtn.selected == YES) {
        
        self.toolTipLabel.text = @"识别结束";
        
        self.iflyVoiceBtn.userInteractionEnabled = NO;
        
        //停留1s
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self iflyAction];
            self.iflyVoiceBtn.userInteractionEnabled = YES;
        });
    }
}
/*!
 *  开始录音回调
 *   当调用了`startListening`函数之后，如果没有发生错误则会回调此函数。
 *  如果发生错误则回调onError:函数
 */
- (void)onBeginOfSpeech {
    self.toolTipLabel.text = @"识别中...";
}
/*识别结果返回代理
 @param resultArray 识别结果
 @ param isLast 表示是否最后一次结果
 */
- (void)onResults:(NSArray *)results isLast:(BOOL)isLast
{
    NSMutableString *result = [[NSMutableString alloc] init];
    NSDictionary *dic = [results objectAtIndex:0];
    
    for (NSString *key in dic) {
        [result appendFormat:@"%@",key];
    }
    
    NSString *resultFromJson = [ISRDataHelper stringFromJson:result];
    
    //    ZYLog(@"听写结果(json)：%@测试",  resultFromJson);
    //    resultFromJson = @"测试";
    
    if (self.voiceRecResultBlock) {
        self.voiceRecResultBlock(resultFromJson);
    }
}
/*识别会话错误返回代理
 @ param  error 错误码
 */
- (void)onError: (IFlySpeechError *) error
{
    NSLog(@"error.errorDesc %@",error.errorDesc);
}

- (void)cancel
{
    [_iFlySpeechRecognizer cancel]; //取消识别
    [_iFlySpeechRecognizer setDelegate:nil];
    [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
}

#pragma mark - action
/**
 开始|停止 语音转文字
 */
- (void)iflyAction
{
    self.iflyVoiceBtn.selected = !self.iflyVoiceBtn.selected;
    
    if (self.iflyVoiceBtn.isSelected == YES) {//开始 语音转文字
        
        //启动识别服务
        [_iFlySpeechRecognizer cancel];
        
        BOOL ret = [_iFlySpeechRecognizer startListening];
        
        if (!ret) {
            //            [MBProgressHUD showHudTipStr:@"启动语音识别失败，请稍后重试"];
        }
        [self.iflyVoiceBtn setBackgroundColor:[UIColor orangeColor]];
    }
    else//停止 语音转文字
    {
        [_iFlySpeechRecognizer stopListening];
        
        self.toolTipLabel.text = @"点击按钮开始语音转文字";
        [self.iflyVoiceBtn setBackgroundColor:BlueButtonColor];
    }
}
/**
 语音退格键
 */
- (void)backspaceAction
{
    if (self.voiceDeleteBackwardBlock) {
        self.voiceDeleteBackwardBlock();
    }
}
#pragma mark - lazy load
- (UIButton *)iflyVoiceBtn
{
    if (_iflyVoiceBtn == nil) {
        
        CGFloat wh = 100;
        CGFloat x = (kScreen_Width - wh) / 2;
        CGFloat y = (self.frame.size.height - wh) / 2 - 30;
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x, y, wh, wh)];
        [button setBackgroundColor:BlueButtonColor];
        button.layer.cornerRadius = wh / 2;
        button.clipsToBounds = YES;
        _iflyVoiceBtn = button;
        
        [_iflyVoiceBtn setImage:[UIImage imageNamed:@"voice"] forState:UIControlStateNormal];
        
        //语音初始化
        [self initRecognizer];
        
        [_iflyVoiceBtn addTarget:self action:@selector(iflyAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _iflyVoiceBtn;
}
- (UILabel *)toolTipLabel
{
    if (_toolTipLabel == nil) {
        
        _toolTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
        _toolTipLabel.text = @"点击按钮开始语音转文字";
        _toolTipLabel.font = [UIFont systemFontOfSize:16];
        _toolTipLabel.textColor = BlueButtonColor;
        _toolTipLabel.center = CGPointMake(self.iflyVoiceBtn.center.x, CGRectGetMaxY(self.iflyVoiceBtn.frame) + 30);
        _toolTipLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _toolTipLabel;
}
- (UIButton *)backspaceBtn
{
    if (_backspaceBtn == nil) {
        //退格键
        CGFloat w = 56;
        CGFloat h = 40;
        UIButton *backspaceBtn = [[UIButton alloc] initWithFrame:CGRectMake((kScreen_Width - w), 10, w, h)];
        [backspaceBtn setImage:[UIImage imageNamed:@"backspace"] forState:UIControlStateNormal];
        [backspaceBtn setImage:[UIImage imageNamed:@"backspace_click"] forState:UIControlStateHighlighted];
        [backspaceBtn addTarget:self action:@selector(backspaceAction) forControlEvents:UIControlEventTouchUpInside];
        _backspaceBtn = backspaceBtn;
    }
    return _backspaceBtn;
}

@end
