//
//  ZYTextView.m
//  ZYVoiceToWordTextViewDemo
//
//  Created by ZhouYuan on 16/10/27.
//  Copyright © 2016年 ZY. All rights reserved.
//

#import "ZYTextView.h"

@interface ZYTextView ()

@property (nonatomic,weak) UILabel *placeHolderLabel;

@end

@implementation ZYTextView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.font = [UIFont systemFontOfSize:13];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.font = [UIFont systemFontOfSize:13];
    }
    return self;
}

- (UILabel *)placeHolderLabel
{
    if (_placeHolderLabel == nil) {
        
        UILabel *label = [[UILabel alloc] init];
        [label setTextColor:[UIColor lightGrayColor]];
        
        [self addSubview:label];
        
        _placeHolderLabel = label;
    }
    
    return _placeHolderLabel;
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    
    self.placeHolderLabel.font = font;
    
    //label的尺寸跟文字一样
    [self.placeHolderLabel sizeToFit];
}

- (void)setPlaceHolder:(NSString *)placeHolder
{
    _placeHolder = placeHolder;
    
    self.placeHolderLabel.text = placeHolder;
    
    //label的尺寸跟文字一样
    [self.placeHolderLabel sizeToFit];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.placeHolderLabel.frame;
    frame.origin.x = 5;
    frame.origin.y = 8;
    self.placeHolderLabel.frame = frame;
    
    self.placeHolderLabel.font = self.font;
}

- (void)setHidePlaceholder:(BOOL)hidePlaceholder
{
    _hidePlaceholder = hidePlaceholder;
    self.placeHolderLabel.hidden = hidePlaceholder;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
}

@end
