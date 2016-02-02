//
//  XLMenuBar.h
//  XLVideoPlayer
//
//  Created by Shelin on 16/2/1.
//  Copyright © 2016年 GreatGate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLSlider.h"

typedef void(^ZoomBlock) (UIButton *btn);
typedef void (^SliderValueChangeBlock) (XLSlider *slider);

@interface XLMenuBar : UIView

@property (weak, nonatomic) IBOutlet XLSlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;


- (void)menuBarWithZoomBlock:(ZoomBlock)zoomHandle sliderValueChange:(SliderValueChangeBlock)sliderValueChangeHandle;
@end
