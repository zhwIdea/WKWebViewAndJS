//
//  JcMessageView.m
//  TheCountdownButton
//
//  Created by zjc on 2017/6/20.
//  Copyright © 2017年 zjc. All rights reserved.
//
#define WS(weakSelf) __weak __typeof(&*self) weakSelf = self
#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeightkHeight [UIScreen mainScreen].bounds.size.height
#define KmsgViewWidth  kWidth *0.8

#import "JcMessageView.h"

@interface JcMessageView()
@property(nonatomic,strong)UIView *MessageView;
@property(nonatomic,strong)UILabel *MessageLabel;

@end

@implementation JcMessageView


static JcMessageView *instance;

+(JcMessageView *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[JcMessageView alloc]init];
    });
    return instance;
}
- (JcMessageView *)copyWithZone:(NSZone *)zone {
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}
-(UIView *)MessageView{
    if (_MessageView == nil) {
        _MessageView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,KmsgViewWidth, 50)];
        _MessageView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.75];
        _MessageView.layer.cornerRadius = 5;
        [self addSubview:_MessageView];
    }
    return _MessageView;
}
-(UILabel *)MessageLabel{
    if (_MessageLabel == nil) {
        _MessageLabel = [[UILabel alloc]initWithFrame:UIEdgeInsetsInsetRect(_MessageView.bounds, UIEdgeInsetsMake(8, 8, 8, 8))];
        _MessageLabel.textAlignment = NSTextAlignmentCenter;
        _MessageLabel.numberOfLines = 0;
        _MessageLabel.textColor = [UIColor whiteColor];
        _MessageLabel.font = [UIFont systemFontOfSize:14];
        _MessageLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_MessageView addSubview:_MessageLabel];
    }
    return _MessageLabel;
}
- (instancetype)init
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
        self.MessageView = [self MessageView];
        self.MessageLabel = [self MessageLabel];
    }
    return self;
}

-(void)ShowMessage:(NSString *)msg
{
    if ([NSThread isMainThread]) {
        [self safelyShowMessage:msg];
    }
    else {
        __weak typeof (self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf safelyShowMessage:msg];
        });
    }
}

- (void)safelyShowMessage:(NSString *)msg
{
    [[self lastWindow] addSubview:self];
    CGFloat Msgheight = [self heightWithFont:[UIFont systemFontOfSize:16] constrainedToWidth:KmsgViewWidth str:msg];
    [_MessageView setFrame:CGRectMake(0, 0,KmsgViewWidth,Msgheight + 16)];
    [_MessageView setCenter:self.center];
    [_MessageLabel setText: msg];
    
    WS(weakSelf);
    [UIView animateWithDuration:0.25 animations:^{
        [weakSelf.MessageView setAlpha:1];
    } completion:^(BOOL finished) {
        [self close];
    }];
}

- (UIWindow *)lastWindow
{
    NSArray *windows = [UIApplication sharedApplication].windows;
    for(UIWindow *window in [windows reverseObjectEnumerator]) {
        if ([window isKindOfClass:[UIWindow class]] &&
            CGRectEqualToRect(window.bounds, [UIScreen mainScreen].bounds))
            return window;
    }
    
    return [UIApplication sharedApplication].keyWindow;
}
- (void)close
{
    WS(weakSelf);
    [UIView animateWithDuration:0.25 delay:1.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [weakSelf.MessageView setAlpha:0];
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     } ];
}


- (CGFloat)heightWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width str:(NSString *)str {
    UIFont *textFont = font ? font : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                 NSParagraphStyleAttributeName: paragraph};
    CGSize textSize = [str boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                        options:(NSStringDrawingUsesLineFragmentOrigin |
                                                 NSStringDrawingTruncatesLastVisibleLine)
                                     attributes:attributes
                                        context:nil].size;
    return ceil(textSize.height);
}

@end
