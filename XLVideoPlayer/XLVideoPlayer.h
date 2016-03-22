//
//  XLVideoPlayer.h
//  XLVideoPlayer
//
//  Created by Shelin on 16/2/1.
//  Copyright © 2016年 GreatGate. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XLVideoPlayer : UIView

- (instancetype)initWithVideoUrl:(NSString *)videoUrl;

- (void)play;

- (void)pause;

@end
