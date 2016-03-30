//
//  XLVideoPlayer.h
//  XLVideoPlayer
//
//  Created by Shelin on 16/3/23.
//  Copyright © 2016年 GreatGate. All rights reserved.
//  https://github.com/ShelinShelin
//  博客：http://www.jianshu.com/users/edad244257e2/latest_articles

#import <UIKit/UIKit.h>
@class XLVideoPlayer;

typedef void (^VideoCompletedPlayingBlock) (XLVideoPlayer *videoPlayer);

@interface XLVideoPlayer : UIView

@property (nonatomic, copy) VideoCompletedPlayingBlock completedPlayingBlock;

/** video url */
@property (nonatomic, strong) NSString *videoUrl;

/**play or pause */
- (void)playPause;
/** dealloc */
- (void)destroyPlayer;

- (void)playerWithBindTableView:(UITableView *)bindTableView currentPlayCellRect:(CGRect)currentPlayCellRect supportSmallWindowPlay:(BOOL)isSupport;

@end
