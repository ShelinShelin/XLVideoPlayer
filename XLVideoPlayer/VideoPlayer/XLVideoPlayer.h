//
//  XLVideoPlayer.h
//  XLVideoPlayer
//
//  Created by Shelin on 16/3/23.
//  Copyright © 2016年 GreatGate. All rights reserved.
//  https://github.com/ShelinShelin

#import <UIKit/UIKit.h>

@interface XLVideoPlayer : UIView

- (instancetype)initWithVideoUrl:(NSString *)videoUrl;

- (void)play;

- (void)pause;

@end
