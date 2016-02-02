//
//  XLMenuBar.m
//  XLVideoPlayer
//
//  Created by Shelin on 16/2/1.
//  Copyright © 2016年 GreatGate. All rights reserved.
//

#import "XLMenuBar.h"

@interface XLMenuBar ()

@property (weak, nonatomic) IBOutlet UIButton *zoomButton;
@property (nonatomic, copy) ZoomBlock zoomHandle;
@property (nonatomic, copy) SliderValueChangeBlock sliderValueChangeHandle;

@end

@implementation XLMenuBar

- (instancetype)init
{
    if ([super init]) {
        self = [[NSBundle mainBundle] loadNibNamed:@"XLMenuBar" owner:nil options:nil].lastObject;
        
        self.slider.value = 0.0;
        self.slider.middleValue = 0.0;
        //设置滑块颜色
//        self.slider.thumbTintColor = [UIColor whiteColor];
        //设置slider最左边一段的颜色
        self.slider.minimumTrackTintColor = [UIColor greenColor];
        //设置slider中间一段的颜色
        self.slider.middleTrackTintColor = [UIColor lightGrayColor];
        //设置slider最右边一段的颜色
        self.slider.maximumTrackTintColor = [UIColor blackColor];
        [self.slider setThumbImage:[UIImage imageNamed:@"whitepoint"] forState:UIControlStateNormal];
        [self.slider setThumbImage:[UIImage imageNamed:@"whitepoint"] forState:UIControlStateSelected];
    }
    return self;
}

- (void)menuBarWithZoomBlock:(ZoomBlock)zoomHandle sliderValueChange:(SliderValueChangeBlock)sliderValueChangeHandle {
    self.zoomHandle = zoomHandle;
    self.sliderValueChangeHandle = sliderValueChangeHandle;
}

- (IBAction)zoomBtnClick:(id)sender {
    if (self.zoomHandle) {
        self.zoomHandle((UIButton *)sender);
    }
}

- (IBAction)sliderValueChange:(XLSlider *)sender {
    if (self.sliderValueChangeHandle) {
        self.sliderValueChangeHandle(sender);
    }
}

@end
