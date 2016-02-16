//
//  XLSlider.h
//  XLSlider
//
//  Created by Shelin on 16/2/4.
//  Copyright © 2016年 xiemingjiang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XLSlider;

typedef void (^SliderValueChangeBlock) (XLSlider *slider);
typedef void (^FinishChangeBlock) (void);

@interface XLSlider : UIView

@property (nonatomic, assign) CGFloat value;        /* From 0 to 1 */
@property (nonatomic, assign) CGFloat middleValue;  /* From 0 to 1 */
@property (nonatomic, copy) SliderValueChangeBlock valueChangeBlock;
@property (nonatomic, copy) FinishChangeBlock finishChangeBlock;
//@property (nonatomic, strong) UIColor* thumbTintColor;
//@property (nonatomic, strong) UIColor* minimumTrackTintColor;
//@property (nonatomic, strong) UIColor* middleTrackTintColor;
//@property (nonatomic, strong) UIColor* maximumTrackTintColor;

@end
