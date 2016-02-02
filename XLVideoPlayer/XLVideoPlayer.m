//
//  XLVideoPlayer.m
//  XLVideoPlayer
//
//  Created by Shelin on 16/2/1.
//  Copyright © 2016年 GreatGate. All rights reserved.
//

#import "XLVideoPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "XLSlider.h"
#import "XLMenuBar.h"

#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kMenuAnimateSpeed 0.8f
#define kScreenAspectRatio kScreenWidth / kScreenHeight


static BOOL isMenuBarHiden;
//static BOOL isInOperation;

@interface XLVideoPlayer ()

@property (weak, nonatomic) XLSlider *slider;

@property (weak, nonatomic) UIButton *zoomButton;

@property (nonatomic,strong) AVPlayer *player;//播放器对象

@property (nonatomic, assign) CGFloat totalTime;

@property (nonatomic, strong) NSURL *videoUrl;

@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (nonatomic, strong) XLMenuBar *menuBar;

@property (nonatomic, strong) UIView *topBar;

@property (nonatomic, strong) UIButton *playOrPause;

@property (nonatomic, strong) UILabel *totalTimeLabel;

@property (nonatomic, strong) UILabel *progressLabel;

@end

@implementation XLVideoPlayer

- (instancetype)initWithVideoUrl:(NSURL *)videoUrl {
    if ([super init]) {
        
        self.videoUrl = videoUrl;
        
        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        playerLayer.backgroundColor = [UIColor blackColor].CGColor;
        
        playerLayer.frame = CGRectMake(0, 0, kScreenWidth, kScreenWidth * kScreenAspectRatio);
        
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;//视频填充模式
        [self.layer addSublayer:playerLayer];
        self.playerLayer = playerLayer;
        
        //屏幕旋转通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        
        //显示进度栏手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showOrHidenMenuBar)];
        [self addGestureRecognizer:tap];
        
        self.slider = self.menuBar.slider;
        self.totalTimeLabel = self.menuBar.totalTimeLabel;
        self.progressLabel = self.menuBar.progressLabel;
    
        self.menuBar.frame = CGRectMake(0, kScreenWidth * kScreenAspectRatio - 30, kScreenWidth, 30);
        [self.menuBar menuBarWithZoomBlock:^(UIButton *btn) {
            [self zoomVideoPlayer:btn];

        } sliderValueChange:^(XLSlider *slider) {
            [self sliderValueChange:slider];
        }];
        
        self.topBar.frame = CGRectMake(0, 0, kScreenWidth, 44);
    
        self.playOrPause.frame = CGRectMake((kScreenWidth - 60) / 2, (kScreenWidth * kScreenAspectRatio - 60) / 2, 60, 60);
        
        isMenuBarHiden = YES;
    }
    return self;
}

#pragma mark lazy loading

- (XLMenuBar *)menuBar {
    if (!_menuBar) {
        _menuBar = [[XLMenuBar alloc] init];
        _menuBar.layer.opacity = 0.0f;
    }
    return _menuBar;
}

- (UIView *)topBar {
    if (!_topBar) {
        _topBar = [[UIView alloc] init];
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [backBtn setTitle:@"返回" forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        backBtn.frame = CGRectMake(10, 22, 40, 40);
        _topBar.backgroundColor = [UIColor whiteColor];
        _topBar.layer.opacity = 0.0f;
    
    }
    return _topBar;
}

- (UIButton *)playOrPause {
    if (!_playOrPause) {
        _playOrPause = [UIButton buttonWithType:UIButtonTypeCustom];
        _playOrPause.layer.opacity = 0.0f;
        [_playOrPause setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [_playOrPause setBackgroundImage:[UIImage imageNamed:@"pause"] forState:UIControlStateSelected];
        [_playOrPause addTarget:self action:@selector(playOrPause:) forControlEvents:UIControlEventTouchDown];
    }
    return _playOrPause;
}

#pragma mark call back

- (void)showOrHidenMenuBar {
    NSLog(@"showOrHidenMenuBar");
    
    [self addSubview:self.menuBar];
    [self addSubview:self.topBar];
    [self addSubview:self.playOrPause];

    if (isMenuBarHiden) {
        [self show];
    }else {
        [self hiden];
    }
}

- (void)show {
    [UIView animateWithDuration:kMenuAnimateSpeed animations:^{
        self.menuBar.alpha = 0.7f;
        self.topBar.alpha = 0.7f;
        self.playOrPause.alpha = 0.7f;
    } completion:^(BOOL finished) {
        isMenuBarHiden = !isMenuBarHiden;
        [self performBlock:^{
            if (!isMenuBarHiden) {
                [self hiden];
            }
        } afterDelay:5.0f];
        
    }];
}

- (void)hiden {
    [UIView animateWithDuration:kMenuAnimateSpeed animations:^{
        self.menuBar.alpha = 0.0f;
        self.topBar.alpha = 0.0f;
        self.playOrPause.alpha = 0.0f;
    } completion:^(BOOL finished){
        isMenuBarHiden = !isMenuBarHiden;
        [self.topBar removeFromSuperview];
        [self.playOrPause removeFromSuperview];
        [self.menuBar removeFromSuperview];
    }];
}

- (void)backBtnClick:(UIButton *)btn {
    NSLog(@"back");

}

- (void)playOrPause:(UIButton *)btn {
    if(self.player.rate==0){ //暂停
        btn.selected = YES;
        [self.player play];
    }else if(self.player.rate==1){//正在播放
        [self.player pause];
        btn.selected = NO;
    }
}

- (void)zoomVideoPlayer:(UIButton *)btn {
    NSLog(@"zoomVideoPlayer");
   
}

- (void)sliderValueChange:(XLSlider *)slider {
    CMTime currentCMTime = CMTimeMake(slider.value * self.totalTime, 1);
    
//    NSLog(@"------%f",slider.value * self.totalTime);
    [self.player pause];
    [self.player seekToTime:currentCMTime completionHandler:^(BOOL finished) {
        
        [self.player play];
    }];
}

/**
 *  After delay
 */
- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay {
    [self performSelector:@selector(callBlockAfterDelay:) withObject:block afterDelay:delay];
}

/**
 *  After a few seconds to perform
 */
- (void)callBlockAfterDelay:(void (^)(void))block {
    block();
}

- (void)statusBarOrientationChange:(NSNotification *)notification
{
    self.playerLayer.frame = CGRectMake(0, 0, kScreenWidth, kScreenWidth * 9 / 16);
    self.menuBar.frame = CGRectMake(0, kScreenWidth * 9 / 16 - 30, kScreenWidth, 30);
    self.topBar.frame = CGRectMake(0, 0, kScreenWidth, 44);
    self.playOrPause.frame = CGRectMake((kScreenWidth - 60) / 2, (kScreenWidth * 9 / 16 - 60) / 2, 60, 60);
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationLandscapeRight){ // home键靠右
        //
    }
    if (orientation ==UIInterfaceOrientationLandscapeLeft) {// home键靠左
    //
    }
    if (orientation == UIInterfaceOrientationPortrait) {
    
        //
    }
    if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        //
    }
}

- (AVPlayer *)player{
    if (!_player) {
        AVPlayerItem *playerItem = [self getAVPlayItem];
        _player = [AVPlayer playerWithPlayerItem:playerItem];
        
        [self addProgressObserver];
        
        [self addObserverToPlayerItem:playerItem];
    }
    return _player;
}

//创建AVPlayerItem对象

- (AVPlayerItem *)getAVPlayItem{
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:self.videoUrl];
    return playerItem;
}

#pragma mark 监听播放进度

-(void)addProgressObserver{
    
    //获取播放当前的playerItem
    AVPlayerItem *playerItem = self.player.currentItem;
    __weak typeof(self) weakSelf = self;
    //这里设置每秒执行一次
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current = CMTimeGetSeconds(time);
        float total = CMTimeGetSeconds([playerItem duration]);
//        NSLog(@"当前已经播放%.2fs.",current);
        weakSelf.progressLabel.text = [weakSelf timeFormatted:current];
        if (current) {
            weakSelf.slider.value = current / total;
        }
    }];
}

#pragma mark 监听PlayerItem的属性（status，loadedTimeRanges）改变2
-(void)addObserverToPlayerItem:(AVPlayerItem *)playerItem{
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}

/**
 *  通过KVO监控播放器状态
 *
 *  @param keyPath 监控属性
 *  @param object  监视器
 *  @param change  状态改变
 *  @param context 上下文
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem = object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue];
        if(status == AVPlayerStatusReadyToPlay){
//            NSLog(@"正在播放...，视频总长度:%.2f",CMTimeGetSeconds(playerItem.duration));
            self.totalTime = CMTimeGetSeconds(playerItem.duration);
            
            self.totalTimeLabel.text = [self timeFormatted:self.totalTime];
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray *array = playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        self.slider.middleValue = totalBuffer / CMTimeGetSeconds(playerItem.duration);
//        NSLog(@"共缓冲：%.2f",totalBuffer);
    }
}

#pragma mark - timeFormat

- (NSString *)timeFormatted:(int)totalSeconds {
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}

@end
