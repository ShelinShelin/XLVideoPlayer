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

/**
 *  video url
 */
@property (nonatomic, strong) NSString *videoUrl;

/**
 *  play or pause
 */
- (void)playPause;

/**
 *  dealloc
 */
- (void)destroyPlayer;

/**
 *  在scrollview的scrollViewDidScroll代理中调用
 *
 *  @param bindTableView       当前绑定的tableview
 *  @param currentPlayCellRect 当前播放的cell相对tableview的frame
 *  @param isSupport           是否支持右下角小窗悬停播放
 */
- (void)playerWithBindTableView:(UITableView *)bindTableView currentPlayCellRect:(CGRect)currentPlayCellRect supportSmallWindowPlay:(BOOL)isSupport;

@end
