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
//#import "XLMenuBar.h"

#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kMenuAnimateSpeed 0.8f
#define kMenuShowDuration 5.0f
#define kTopBarHeight 44.0f
#define kMenuBaHeight 40.0f
#define kMagin 5.0f
#define kOpacity 0.7f;
#define kPlayerBackgroundColor [UIColor blackColor].CGColor

static BOOL isMenuBarHiden;
static BOOL isInOperation;
static CGRect tempFrame;

@interface XLVideoPlayer ()
/**
 *  progress slider
 */
@property (weak, nonatomic) XLSlider *slider;
/**
 *  full screen button
 */
@property (weak, nonatomic) UIButton *fullScreenBtn;
/**
 *  video player
 */
@property (nonatomic,strong) AVPlayer *player;
/**
 *  video total duration
 */
@property (nonatomic, assign) CGFloat totalTime;
/**
 *  video url
 */
@property (nonatomic, strong) NSURL *videoUrl;

@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (nonatomic, strong) UIView *menuBar;

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
        playerLayer.backgroundColor = kPlayerBackgroundColor;
        
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;//视频填充模式
        [self.layer addSublayer:playerLayer];
        self.playerLayer = playerLayer;
        
        //screen orientation change
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        
        //show or hiden gestureRecognizer
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showOrHidenMenuBar)];
        [self addGestureRecognizer:tap];
        
        isMenuBarHiden = YES;
        isInOperation = NO;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (kScreenWidth <= 414) {
        self.playerLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        self.menuBar.frame = CGRectMake(0, self.frame.size.height - kMenuBaHeight, self.frame.size.width, kMenuBaHeight);
        self.progressLabel.frame = CGRectMake(10, 0, 62, kMenuBaHeight);
        
        self.totalTimeLabel.frame = CGRectMake(self.menuBar.frame.size.width - 72 - kMenuBaHeight, 0, 62, kMenuBaHeight);
        
        self.slider.frame = CGRectMake(CGRectGetMaxX(self.progressLabel.frame) + kMagin, 0, CGRectGetMinX(self.totalTimeLabel.frame) - 72 - kMagin, kMenuBaHeight);
        
        self.fullScreenBtn.frame = CGRectMake(CGRectGetMaxX(self.totalTimeLabel.frame), 0, kMenuBaHeight, kMenuBaHeight);
        
        self.topBar.frame = CGRectMake(0, 0, self.frame.size.width, kTopBarHeight);
        
        self.playOrPause.frame = CGRectMake((self.frame.size.width - 60) / 2, (self.frame.size.height - 60) / 2, 60, 60);
        tempFrame = self.frame;
    }
}

#pragma mark - lazy loading

- (UIView *)menuBar {
    if (!_menuBar) {
        _menuBar = [[UIView alloc] init];
        _menuBar.backgroundColor = [UIColor blackColor];
        
        UILabel *label1 = [[UILabel alloc] init];
        label1.textAlignment = NSTextAlignmentCenter;
        label1.text = @"00:00:00";
        label1.font = [UIFont systemFontOfSize:14.0f];
        label1.textColor = [UIColor whiteColor];
        [_menuBar addSubview:label1];
        self.progressLabel = label1;
        
        UILabel *label2 = [[UILabel alloc] init];
        label2.textAlignment = NSTextAlignmentCenter;
        label2.font = [UIFont systemFontOfSize:14.0f];
        label2.textColor = [UIColor whiteColor];
        [_menuBar addSubview:label2];
        self.totalTimeLabel = label2;
        
        XLSlider *slider = [[XLSlider alloc] init];
        slider.valueChangeBlock = ^(XLSlider *slider){
            [self sliderValueChange:slider];
        };
        slider.finishChangeBlock = ^{
            [self finishChange];
        };
        [_menuBar addSubview:slider];
        self.slider = slider;
        
        UIButton *fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [fullScreenBtn setImage:[UIImage imageNamed:@"big"] forState:UIControlStateNormal];
        [fullScreenBtn addTarget:self action:@selector(fullScreen:) forControlEvents:UIControlEventTouchUpInside];
        [_menuBar addSubview:fullScreenBtn];
        self.fullScreenBtn = fullScreenBtn;
        
        _menuBar.layer.opacity = 0.0f;
    }
    return _menuBar;
}

- (UIView *)topBar {
    if (!_topBar) {
        _topBar = [[UIView alloc] init];
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [backBtn setImage:[UIImage imageNamed:@"btn_competition_day_left_arrow"] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        backBtn.frame = CGRectMake(0, 0, kTopBarHeight, kTopBarHeight);
        [_topBar addSubview:backBtn];
        _topBar.backgroundColor = [UIColor blackColor];
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

- (AVPlayer *)player{
    if (!_player) {
        AVPlayerItem *playerItem = [self getAVPlayItem];
        _player = [AVPlayer playerWithPlayerItem:playerItem];
        
        [self addProgressObserver];
        
        [self addObserverToPlayerItem:playerItem];
    }
    return _player;
}

//initialize AVPlayerItem
- (AVPlayerItem *)getAVPlayItem{
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:self.videoUrl];
    return playerItem;
}


#pragma mark - call back

- (void)fullScreen:(UIButton *)btn {
    
}

- (void)showOrHidenMenuBar {
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
        self.menuBar.layer.opacity = kOpacity;
        self.topBar.layer.opacity = kOpacity;
        self.playOrPause.layer.opacity = kOpacity;
    } completion:^(BOOL finished) {
        isMenuBarHiden = !isMenuBarHiden;
        [self performBlock:^{
            if (!isMenuBarHiden && !isInOperation) {
                [self hiden];
            }
        } afterDelay:kMenuShowDuration];
        
    }];
}

- (void)hiden {
    isInOperation = NO;
    [UIView animateWithDuration:kMenuAnimateSpeed animations:^{
        self.menuBar.layer.opacity = 0.0f;
        self.topBar.layer.opacity = 0.0f;
        self.playOrPause.layer.opacity = 0.0f;
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
    if(self.player.rate == 0){      //pause
        btn.selected = YES;
        [self.player play];
    }else if(self.player.rate == 1){    //playing
        [self.player pause];
        btn.selected = NO;
    }
}

- (void)zoomVideoPlayer:(UIButton *)btn {
    NSLog(@"zoomVideoPlayer");
   
}

- (void)sliderValueChange:(XLSlider *)slider {
    
    isInOperation = YES;
    [self.player pause];
    self.progressLabel.text = [self timeFormatted:slider.value * self.totalTime];
}

- (void)finishChange {
//    NSLog(@"finishChange");
    isInOperation = NO;
    CMTime currentCMTime = CMTimeMake(self.slider.value * self.totalTime, 1);

    [self.player seekToTime:currentCMTime completionHandler:^(BOOL finished) {
        [self.player play];
        self.playOrPause.selected = YES;
    }];
    [self showOrHidenMenuBar];
}

- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay {
    [self performSelector:@selector(callBlockAfterDelay:) withObject:block afterDelay:delay];
}

- (void)callBlockAfterDelay:(void (^)(void))block {
    block();
}

- (void)statusBarOrientationChange:(NSNotification *)notification
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGSize screenSize;
    if (orientation == UIInterfaceOrientationLandscapeRight
        || orientation == UIInterfaceOrientationLandscapeLeft
        || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        screenSize = CGSizeMake(kScreenWidth, kScreenHeight);
        [self updateFrameWithPlayerSize:screenSize];
        
    }
    if (orientation == UIInterfaceOrientationPortrait) {
        screenSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
        [self updateFrameWithPlayerSize:screenSize];
        self.frame = tempFrame;
    }
}

- (void)updateFrameWithPlayerSize:(CGSize)size {
    CGFloat screenWidth = size.width;
    CGFloat screenHeight = size.height;
    self.playerLayer.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    self.frame = CGRectMake(0, 0, self.playerLayer.frame.size.width, self.playerLayer.frame.size.height);
    self.menuBar.frame = CGRectMake(0, screenHeight - kMenuBaHeight, screenWidth, kMenuBaHeight);
    
    self.totalTimeLabel.frame = CGRectMake(self.menuBar.frame.size.width - 72 - kMenuBaHeight, 0, 62, kMenuBaHeight);
    self.slider.frame = CGRectMake(CGRectGetMaxX(self.progressLabel.frame) + kMagin, 0, CGRectGetMinX(self.totalTimeLabel.frame) - 72 - kMagin, kMenuBaHeight);
    self.fullScreenBtn.frame = CGRectMake(CGRectGetMaxX(self.totalTimeLabel.frame), 0, kMenuBaHeight, kMenuBaHeight);
    
    self.topBar.frame = CGRectMake(0, 0, screenWidth, kTopBarHeight);
    self.playOrPause.frame = CGRectMake((screenWidth - 60) / 2, (screenHeight - 60) / 2, 60, 60);
}

#pragma mark - monitor video playing course

-(void)addProgressObserver{
    
    //get current playerItem object
    AVPlayerItem *playerItem = self.player.currentItem;
    __weak typeof(self) weakSelf = self;
    
    //Set once per second
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current = CMTimeGetSeconds(time);
        float total = CMTimeGetSeconds([playerItem duration]);
//        NSLog(@"already play ---- %.2fs.",current);
        weakSelf.progressLabel.text = [weakSelf timeFormatted:current];
        if (current) {
            weakSelf.slider.value = current / total;
            
            //finish and loop playback
            if (weakSelf.slider.value == 1) {
                weakSelf.playOrPause.selected = NO;
                [weakSelf showOrHidenMenuBar];
                CMTime currentCMTime = CMTimeMake(0, 1);
                [weakSelf.player seekToTime:currentCMTime completionHandler:^(BOOL finished) {
                    weakSelf.slider.value = 0.0f;
                }];
            }
        }
    }];
}

#pragma mark - PlayerItem （status，loadedTimeRanges）

-(void)addObserverToPlayerItem:(AVPlayerItem *)playerItem{
    
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //network loading progress
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
//        NSLog(@"%f",self.slider.middleValue);
//        NSLog(@"totalBuffer：%.2f",totalBuffer);
//        NSLog(@"--%f----",self.slider.middleValue);

        //首次加载缓存后执行，可在此移除加载动画
    }
}

#pragma mark - timeFormat

- (NSString *)timeFormatted:(int)totalSeconds {
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
}

@end
