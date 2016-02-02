//
//  XLSlider.m
//  XLVideoPlayer
//
//  Created by Shelin on 16/2/1.
//  Copyright © 2016年 GreatGate. All rights reserved.
//

#import "XLSlider.h"
#import <objc/message.h>

#define POINT_OFFSET    (2)

@interface UIImage (YDSlider)
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
@end

@implementation UIImage (XLSlider)

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    UIImage *img = nil;
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,
                                   color.CGColor);
    CGContextFillRect(context, rect);
    
    img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}
@end

#pragma mark - YDSlider

@interface XLSlider () {
    UISlider*       _slider;
    UIProgressView* _progressView;
    BOOL            _loaded;
    
    id              _target;
    SEL             _action;
    
}
@end

@implementation XLSlider

- (void)loadSubView {
    if (_loaded) return;
    _loaded = YES;
    
    self.backgroundColor = [UIColor clearColor];
    
    _slider = [[UISlider alloc] initWithFrame:self.bounds];
    _slider.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self addSubview:_slider];
    
    CGRect rect = _slider.bounds;
    
    rect.origin.x += POINT_OFFSET;
    rect.size.width -= POINT_OFFSET*2;
    _progressView = [[UIProgressView alloc] initWithFrame:rect];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _progressView.center = _slider.center;
    _progressView.userInteractionEnabled = NO;
    
    [_slider addSubview:_progressView];
    [_slider sendSubviewToBack:_progressView];
    
    _progressView.progressTintColor = [UIColor darkGrayColor];
    _progressView.trackTintColor = [UIColor lightGrayColor];
    _slider.maximumTrackTintColor = [UIColor clearColor];
}

- (void)awakeFromNib {
    [self loadSubView];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self loadSubView];
    }
    return self;
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    [self loadSubView];
    
    _target = target;
    _action = action;
    [_slider addTarget:self action:@selector(onSliderValueChanged:) forControlEvents:controlEvents];
}

- (void)onSliderValueChanged:(UISlider* )slider {
    objc_msgSend(_target, _action, self);
    
}

/* setting & getting */
- (CGFloat)value {
    return _slider.value;
}

- (void)setValue:(CGFloat)value {
    _slider.value = value;
}

- (CGFloat)middleValue {
    return _progressView.progress;
}

- (void)setMiddleValue:(CGFloat)middleValue {
    _progressView.progress = middleValue;
}

- (UIColor* )thumbTintColor {
    return _slider.thumbTintColor;
}

- (void)setThumbTintColor:(UIColor *)thumbTintColor {
    [_slider setThumbTintColor:thumbTintColor];
}

- (UIColor* )minimumTrackTintColor {
    return _slider.minimumTrackTintColor;
}

- (void)setMinimumTrackTintColor:(UIColor *)minimumTrackTintColor {
    [_slider setMinimumTrackTintColor:minimumTrackTintColor];
}

- (UIColor* )middleTrackTintColor {
    return _progressView.progressTintColor;
}

- (void)setMiddleTrackTintColor:(UIColor *)middleTrackTintColor {
    _progressView.progressTintColor = middleTrackTintColor;
}

- (UIColor* )maximumTrackTintColor {
    return _progressView.trackTintColor;
}

- (void)setMaximumTrackTintColor:(UIColor *)maximumTrackTintColor {
    _progressView.trackTintColor = maximumTrackTintColor;
}

- (UIImage* )thumbImage {
    return _slider.currentThumbImage;
}

- (void)setThumbImage:(UIImage *)image forState:(UIControlState)state {
    [_slider setThumbImage:image forState:state];
}

- (UIImage* )minimumTrackImage {
    return _slider.currentMinimumTrackImage;
}

- (void)setMinimumTrackImage:(UIImage *)minimumTrackImage {
    [_slider setMinimumTrackImage:minimumTrackImage forState:UIControlStateNormal];
}

- (UIImage* )middleTrackImage {
    return _progressView.progressImage;
}

- (void)setMiddleTrackImage:(UIImage *)middleTrackImage {
    _progressView.progressImage = middleTrackImage;
}

- (UIImage* )maximumTrackImage {
    return _progressView.trackImage;
}

- (void)setMaximumTrackImage:(UIImage *)maximumTrackImage {
    [_slider setMaximumTrackImage:[UIImage imageWithColor:[UIColor clearColor] size:maximumTrackImage.size] forState:UIControlStateNormal];
    _progressView.trackImage = maximumTrackImage;
}

@end

