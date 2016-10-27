//
//  ViewController.m
//  ZYVoiceToWordTextViewDemo
//
//  Created by ZhouYuan on 16/10/27.
//  Copyright © 2016年 ZY. All rights reserved.
//

#import "ViewController.h"
#import "UIViewController+DismissKeyboard.h"
#import "ZYTextView.h"
#import "ZYToolBarView.h"
#import "ZYVoiceRecognizerView.h"

#define kScreen_Height [UIScreen mainScreen].bounds.size.height
#define kScreen_Width [UIScreen mainScreen].bounds.size.width

@interface ViewController ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet ZYTextView *textView;

//键盘上 文字|语音按钮
@property (nonatomic, strong) ZYToolBarView *toolBarView;

//语音识别的view
@property (nonatomic, strong) ZYVoiceRecognizerView *voiceRecognizerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupForDismissKeyboard];
    
    [self setupTextView];
    [self setupToolBarView];
}

-(void)viewWillDisappear:(BOOL)animated
{
    if (_voiceRecognizerView != nil) {
        [self.voiceRecognizerView cancel];
    }
    [super viewWillDisappear:animated];
}

#pragma mark - lazy load
- (ZYToolBarView *)toolBarView
{
    if (_toolBarView == nil) {
        _toolBarView = [[ZYToolBarView alloc] init];
        
        __weak typeof(self) weakSelf = self;
        _toolBarView.wordActionBlock = ^(){
            //展示文字键盘
            [weakSelf.textView resignFirstResponder];
            weakSelf.textView.inputView = nil;
            [weakSelf.textView becomeFirstResponder];
        };
        _toolBarView.voiceActionBlock = ^(){
            //展示语音键盘
            [weakSelf.textView resignFirstResponder];
            if (weakSelf.textView.inputView == nil) {
                weakSelf.textView.inputView = weakSelf.voiceRecognizerView;
            }
            [weakSelf.textView becomeFirstResponder];
        };
    }
    return _toolBarView;
}

- (ZYVoiceRecognizerView *)voiceRecognizerView
{
    if (_voiceRecognizerView == nil) {
        _voiceRecognizerView = [[ZYVoiceRecognizerView alloc] init];
        
        __weak typeof(self) weakSelf = self;
        _voiceRecognizerView.voiceRecResultBlock = ^(NSString *resultFromJson)
        {
            ///处理光标
            //1.获取光标位置
            NSRange selectedRange = weakSelf.textView.selectedRange;
            //2.将光标所在位置的的字符串进行替换
            weakSelf.textView.text = [weakSelf.textView.text stringByReplacingCharactersInRange:selectedRange withString:resultFromJson];
            //3.修改光标位置,光标放到新增加的文字的后面
            weakSelf.textView.selectedRange = NSMakeRange((selectedRange.location + resultFromJson.length), 0);
            ///
            
            [weakSelf textChange];
        };
        _voiceRecognizerView.voiceDeleteBackwardBlock = ^(){
            
            [weakSelf.textView deleteBackward];
        };
    }
    return _voiceRecognizerView;
}

#pragma mark - setup
- (void)setupToolBarView
{
    [self.view addSubview:self.toolBarView];
}
#pragma mark - textView
- (void)setupTextView
{
    self.textView.placeHolder = @"输入文字...";
    self.textView.font = [UIFont systemFontOfSize:16];
    self.textView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange) name:UITextViewTextDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

/**
 键盘位置改变
 */
- (void)keyboardFrameChange:(NSNotification *)note
{
    //获取键盘的frame
    //UIKeyboardFrameEndUserInfoKey是对象
    CGRect frame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    //键盘改变frame经历的时间
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    if (frame.origin.y == kScreen_Height) {//没有弹出键盘
        //包装动画
        [UIView animateWithDuration:duration animations:^{
            
            //切换键盘的时候,使它浮动不那么大
//            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            
            self.toolBarView.transform = CGAffineTransformIdentity;
            self.toolBarView.hidden = YES;
            
        }];
    }
    else//弹出键盘
    {
        //工具条向上移动
        [UIView animateWithDuration:duration animations:^{
            
//            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            
            self.toolBarView.transform = CGAffineTransformMakeTranslation(0, - frame.size.height);
            self.toolBarView.hidden = NO;
            
            //语音转文字frame
            if (_voiceRecognizerView == nil) {
                CGRect rect = self.voiceRecognizerView.frame;
                rect.size.height = frame.size.height;
                self.voiceRecognizerView.frame = rect;
            }
        }];
    }
}

/**
 textView文字改变
 */
- (void)textChange
{
    if (self.textView.text.length) {//有内容
        self.textView.hidePlaceholder = YES;
    }
    else
    {
        self.textView.hidePlaceholder = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
