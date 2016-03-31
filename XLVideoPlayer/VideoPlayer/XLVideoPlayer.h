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
 *  video url 视频路径
 */
@property (nonatomic, strong) NSString *videoUrl;

/**
 *  play or pause
 */
- (void)playPause;

/**
 *  dealloc 销毁
 */
- (void)destroyPlayer;

/**
 *  在cell上播放必须绑定TableView、当前播放cell的IndexPath
 */
- (void)playerBindTableView:(UITableView *)bindTableView currentIndexPath:(NSIndexPath *)currentIndexPath;

/**
 *  在scrollview的scrollViewDidScroll代理中调用
 *
 *  @param support        是否支持右下角小窗悬停播放
 */
- (void)playerScrollIsSupportSmallWindowPlay:(BOOL)support;

@end
