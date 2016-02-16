//
//  XLSlider.m
//  XLSlider
//
//  Created by Shelin on 16/2/4.
//  Copyright © 2016年 xiemingjiang. All rights reserved.
//

#import "XLSlider.h"

@interface XLSlider ()

@property (nonatomic, strong) UIImageView *point;
@property (nonatomic, strong) UIView *minimumView;
@property (nonatomic, strong) UIView *middleView;
@property (nonatomic, strong) UIView *maximumView;
@property (nonatomic, assign) CGFloat totalOffset;

@end

@implementation XLSlider

- (UIImageView *)point {
    if (!_point) {
        _point = [[UIImageView alloc] init];
        _point.image = [self drawRound];
        _point.frame = CGRectMake(0, 0, 10, 10);
    }
    return _point;
}

- (UIView *)minimumView {
    if (!_minimumView) {
        _minimumView = [[UIView alloc] init];
        _minimumView.backgroundColor = [UIColor greenColor];
        _minimumView.frame = CGRectMake(0, 0, 0, 2);
    }
    return _minimumView;
}

- (UIView *)middleView {
    if (!_middleView) {
        _middleView = [[UIView alloc] init];
        _middleView.backgroundColor = [UIColor lightGrayColor];
        _middleView.frame = CGRectMake(0, 0, 0, 2);
    }
    return _middleView;
}

- (UIView *)maximumView {
    if (!_maximumView) {
        _maximumView = [[UIView alloc] init];
        _maximumView.backgroundColor = [UIColor whiteColor];
    }
    return _maximumView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] init];
        [panGesture addTarget:self action:@selector(sliderPan:)];
        [self addGestureRecognizer:panGesture];
        
        [self addSubview:self.maximumView];
        [self addSubview:self.middleView];
        [self addSubview:self.minimumView];
        [self addSubview:self.point];
        
        [self addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"middleValue" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.maximumView.frame = CGRectMake(0, (self.frame.size.height - 2) / 2, self.frame.size.width , 2);
    
    CGRect tempFrame1 = self.point.frame;
    tempFrame1.origin.y = (self.frame.size.height - 10) / 2;
    self.point.frame = tempFrame1;
    
    CGRect tempFrame2 = self.minimumView.frame;
    tempFrame2.origin.y = (self.frame.size.height - 2) / 2;
    self.minimumView.frame = tempFrame2;
    
    CGRect tempFrame3 = self.middleView.frame;
    tempFrame3.origin.y = (self.frame.size.height - 2) / 2;
    self.middleView.frame = tempFrame3;
}

- (void)sliderPan:(UIPanGestureRecognizer *)panGesture {
    CGFloat detalX = [panGesture translationInView:self].x;

    if (self.valueChangeBlock) {
        self.valueChangeBlock(self);
    }
    CGRect tempFrame = self.point.frame;
    tempFrame.origin.x += detalX;
    tempFrame.origin.x = tempFrame.origin.x >= 0 ? tempFrame.origin.x : 0;
    tempFrame.origin.x = tempFrame.origin.x <= (self.frame.size.width - 10) ? tempFrame.origin.x : (self.frame.size.width - 10);
    self.point.frame = tempFrame;
    [panGesture setTranslation:CGPointZero inView:self];
    
    self.value = self.point.frame.origin.x / (self.frame.size.width - 10);
    
    if (panGesture.state ==  UIGestureRecognizerStateEnded && self.finishChangeBlock) {
        self.finishChangeBlock();
    }
}

#pragma mark - key value observing

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"value"]){
        [self updateMinimumFrame];
        [self updateMaximumFrame];
    }
    if ([keyPath isEqualToString:@"middleValue"]) {
        [self updateMiddleFrame];
    }
    if ([keyPath isEqualToString:@"frame"]) {
        [self updateMiddleFrame];
    }
}

- (void)updateMinimumFrame {
    CGRect tempFrame = self.minimumView.frame;
    tempFrame.size.width = self.value * (self.frame.size.width - 10);
    self.minimumView.frame = tempFrame;
    
    CGRect tempFrame1 = self.point.frame;
    tempFrame1.origin.x = CGRectGetMaxX(self.minimumView.frame);
    self.point.frame = tempFrame1;
}

- (void)updateMiddleFrame {
    CGRect tempFrame = self.middleView.frame;
    tempFrame.size.width = self.middleValue * self.frame.size.width;
    self.middleView.frame = tempFrame;
}

- (void)updateMaximumFrame {
    CGRect tempFrame = self.maximumView.frame;
    tempFrame.size.width = (self.frame.size.width - CGRectGetMidX(self.point.frame));
    tempFrame.origin.x = CGRectGetMidX(self.point.frame);
    self.maximumView.frame = tempFrame;
}

- (UIImage *)drawRound {
    
    UIGraphicsBeginImageContext(CGSizeMake(10, 10));
    //获取当前CGContextRef
    CGContextRef gc = UIGraphicsGetCurrentContext();
    CGRect frame = CGRectMake(0, 0, 10, 10);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor whiteColor] set];
    CGContextFillEllipseInRect(context, frame);
    CGContextFillPath(context);
    
    CGContextStrokePath(gc);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}



@end
