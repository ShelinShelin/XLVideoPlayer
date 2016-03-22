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

//#define kScreenHeight [UIScreen mainScreen].bounds.size.height
//#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kMenuAnimateSpeed 0.5f
#define kMenuShowDuration 3.0f
#define kTopBarHeight 44.0f
#define kMenuBaHeight 40.0f
#define kMagin 5.0f
#define kOpacity 0.7f;
#define kPlayerBackgroundColor [UIColor blackColor].CGColor

static BOOL isMenuBarHiden;
static BOOL isInOperation;
static BOOL isDefalutFrame;

@interface XLVideoPlayer ()

@property (nonatomic, assign) CGRect playerDefalutFrame;
/**
 *  videoPlayer superView
 */
@property (nonatomic, strong) UIView *playSuprView;
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
@property (nonatomic, strong) NSString *videoUrl;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) UIView *menuBar;
@property (nonatomic, strong) UIView *topBar;
@property (nonatomic, strong) UIButton *playOrPause;
@property (nonatomic, strong) UILabel *totalTimeLabel;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) UIWindow *keyWindow;

@end

@implementation XLVideoPlayer

#pragma mark - public method

- (instancetype)initWithVideoUrl:(NSString *)videoUrl {
    if ([super init]) {
        
        self.videoUrl = videoUrl;
        self.keyWindow = [UIApplication sharedApplication].keyWindow;
        
        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        playerLayer.backgroundColor = kPlayerBackgroundColor;
        
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;//视频填充模式
        [self.layer addSublayer:playerLayer];
        self.playerLayer = playerLayer;
        
        
        [self addSubview:self.activityIndicatorView];
        [self.activityIndicatorView startAnimating];
        
        //menuBar
        [self addSubview:self.menuBar];
        
        //topBar
        [self addSubview:self.topBar];
        
        //screen orientation change
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
        
        //show or hiden gestureRecognizer
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showOrHidenMenuBar)];
        [self addGestureRecognizer:tap];
        
        isMenuBarHiden = YES;
        isInOperation = NO;
    }
    return self;
}

- (void)play {
    [self.player play];
}

- (void)pause {
    [self.player pause];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
    
    UIInterfaceOrientation sataus=[UIApplication sharedApplication].statusBarOrientation;
    if (sataus == UIInterfaceOrientationPortrait) {
        NSLog(@"======UIDeviceOrientationPortrait");
        
    }
    if (!isDefalutFrame) {
        self.playerDefalutFrame = self.frame;
        self.playSuprView = self.superview;
    }
    isDefalutFrame = YES;
    [self setMenuBaAndTopBarConstraints];
}

#pragma mark - lazy loading

- (UIView *)menuBar {
    if (!_menuBar) {
        _menuBar = [[UIView alloc] init];
        _menuBar.backgroundColor = [UIColor blackColor];
        _menuBar.translatesAutoresizingMaskIntoConstraints = NO;
        
    
        UILabel *label1 = [[UILabel alloc] init];
        label1.translatesAutoresizingMaskIntoConstraints = NO;
        label1.textAlignment = NSTextAlignmentCenter;
        label1.text = @"00:00:00";
        label1.font = [UIFont systemFontOfSize:14.0f];
        label1.textColor = [UIColor whiteColor];
        [_menuBar addSubview:label1];
        self.progressLabel = label1;
        
        NSLayoutConstraint *label1Left = [NSLayoutConstraint constraintWithItem:label1 attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_menuBar attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0];
        NSLayoutConstraint *label1Top = [NSLayoutConstraint constraintWithItem:label1 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_menuBar attribute:NSLayoutAttributeTop multiplier:1.0f constant:0];
        NSLayoutConstraint *label1Bottom = [NSLayoutConstraint constraintWithItem:label1 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_menuBar attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0];
        NSLayoutConstraint *label1Width = [NSLayoutConstraint constraintWithItem:label1 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0f constant:80];
        [_menuBar addConstraints:@[label1Left, label1Top, label1Bottom, label1Width]];
        
        
        
        UIButton *fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        fullScreenBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [fullScreenBtn setImage:[UIImage imageNamed:@"big"] forState:UIControlStateNormal];
        [fullScreenBtn addTarget:self action:@selector(fullScreen:) forControlEvents:UIControlEventTouchUpInside];
        [_menuBar addSubview:fullScreenBtn];
        self.fullScreenBtn = fullScreenBtn;
        
        NSLayoutConstraint *btnWidth = [NSLayoutConstraint constraintWithItem:fullScreenBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0f constant:25];
        NSLayoutConstraint *btnHeight = [NSLayoutConstraint constraintWithItem:fullScreenBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0f constant:25];
        NSLayoutConstraint *btnRight = [NSLayoutConstraint constraintWithItem:fullScreenBtn attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_menuBar attribute:NSLayoutAttributeRight multiplier:1.0f constant:-10];
        NSLayoutConstraint *btnCenterY = [NSLayoutConstraint constraintWithItem:fullScreenBtn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_menuBar attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0];
        [_menuBar addConstraints:@[btnWidth, btnHeight, btnRight, btnCenterY]];


        UILabel *label2 = [[UILabel alloc] init];
        label2.translatesAutoresizingMaskIntoConstraints = NO;
        label2.textAlignment = NSTextAlignmentCenter;
        label2.text = @"00:00:00";
        label2.font = [UIFont systemFontOfSize:14.0f];
        label2.textColor = [UIColor whiteColor];
        [_menuBar addSubview:label2];
        self.totalTimeLabel = label2;
        
        NSLayoutConstraint *label2Right = [NSLayoutConstraint constraintWithItem:label2 attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:fullScreenBtn attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0];
        NSLayoutConstraint *label2Top = [NSLayoutConstraint constraintWithItem:label2 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_menuBar attribute:NSLayoutAttributeTop multiplier:1.0f constant:0];
        NSLayoutConstraint *label2Bottom = [NSLayoutConstraint constraintWithItem:label2 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_menuBar attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0];
        NSLayoutConstraint *label2Width = [NSLayoutConstraint constraintWithItem:label2 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0f constant:80];
        [_menuBar addConstraints:@[label2Right, label2Top, label2Bottom, label2Width]];
        
        

        XLSlider *slider = [[XLSlider alloc] init];
        slider.translatesAutoresizingMaskIntoConstraints = NO;
        slider.valueChangeBlock = ^(XLSlider *slider){
            [self sliderValueChange:slider];
        };
        slider.finishChangeBlock = ^(XLSlider *slider){
            [self finishChange];
        };
        slider.dragSliderBlock = ^(XLSlider *slider){
            [self dragSlider];
        };
        [_menuBar addSubview:slider];
        self.slider = slider;
        NSLayoutConstraint *sliderLeft = [NSLayoutConstraint constraintWithItem:slider attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:label1 attribute:NSLayoutAttributeRight multiplier:1.0f constant:0];
        NSLayoutConstraint *sliderRight = [NSLayoutConstraint constraintWithItem:slider attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:label2 attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0];
        NSLayoutConstraint *sliderTop = [NSLayoutConstraint constraintWithItem:slider attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_menuBar attribute:NSLayoutAttributeTop multiplier:1.0f constant:0];
        NSLayoutConstraint *sliderBottom = [NSLayoutConstraint constraintWithItem:slider attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_menuBar attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0];
        [_menuBar addConstraints:@[sliderLeft, sliderRight, sliderTop, sliderBottom]];

        [self addSubview:self.playOrPause];

        NSLayoutConstraint *centerBtnCenterX = [NSLayoutConstraint constraintWithItem:_playOrPause attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0];
        NSLayoutConstraint *centerBtnCenterY = [NSLayoutConstraint constraintWithItem:_playOrPause attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0];
        NSLayoutConstraint *centerBtnWidth = [NSLayoutConstraint constraintWithItem:_playOrPause attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0f constant:60];
        NSLayoutConstraint *centerBtnHeight = [NSLayoutConstraint constraintWithItem:_playOrPause attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0f constant:60];
        [self addConstraints:@[centerBtnCenterX, centerBtnCenterY, centerBtnWidth, centerBtnHeight]];
        _menuBar.layer.opacity = 0.0f;
    }
    return _menuBar;
}

- (UIView *)topBar {
    if (!_topBar) {
        _topBar = [[UIView alloc] init];
        _topBar.translatesAutoresizingMaskIntoConstraints = NO;
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
        _playOrPause.translatesAutoresizingMaskIntoConstraints = NO;
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
    
    if ([self.videoUrl rangeOfString:@"http"].location != NSNotFound) {
        AVPlayerItem *playerItem=[AVPlayerItem playerItemWithURL:[NSURL URLWithString:[self.videoUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        return playerItem;
    }else{
        AVAsset *movieAsset  = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:self.videoUrl] options:nil];
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
        return playerItem;
    }
}

- (UIActivityIndicatorView *)activityIndicatorView {
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] init];
    }
    return _activityIndicatorView;
}

#pragma mark - call back

- (void)fullScreen:(UIButton *)btn {
    
}

- (void)showOrHidenMenuBar {
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
        if (finished) {
            isMenuBarHiden = !isMenuBarHiden;
            [self performBlock:^{
                if (!isMenuBarHiden && !isInOperation) {
                    [self hiden];
                }
            } afterDelay:kMenuShowDuration];
        }
    }];
}

- (void)hiden {
    isInOperation = NO;
    [UIView animateWithDuration:kMenuAnimateSpeed animations:^{
        self.menuBar.layer.opacity = 0.0f;
        self.topBar.layer.opacity = 0.0f;
        self.playOrPause.layer.opacity = 0.0f;
    } completion:^(BOOL finished){
        if (finished) {
            isMenuBarHiden = !isMenuBarHiden;
        }
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
    NSLog(@"sliderValueChange");
    self.progressLabel.text = [self timeFormatted:slider.value * self.totalTime];
}

- (void)finishChange {
    isInOperation = NO;
    CMTime currentCMTime = CMTimeMake(self.slider.value * self.totalTime, 1);

    [self.player seekToTime:currentCMTime completionHandler:^(BOOL finished) {
        [self.player play];
        self.playOrPause.selected = YES;
    }];
}

- (void)dragSlider {
    NSLog(@"dragSlider");
    isInOperation = YES;
    [self.player pause];
}

- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay {
    [self performSelector:@selector(callBlockAfterDelay:) withObject:block afterDelay:delay];
}

- (void)callBlockAfterDelay:(void (^)(void))block {
    block();
}

- (void)statusBarOrientationChange:(NSNotification *)notification {

    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    [self removeFromSuperview];
    [self.keyWindow addSubview:self];
    if (orientation == UIDeviceOrientationLandscapeLeft) {
//        NSLog(@"UIDeviceOrientationLandscapeLeft");
        self.frame = self.keyWindow.bounds;
    }else if (orientation == UIDeviceOrientationLandscapeRight) {
//        NSLog(@"UIDeviceOrientationLandscapeRight");
        self.frame = self.keyWindow.bounds;
    }else if (orientation == UIDeviceOrientationPortrait) {
//        NSLog(@"UIDeviceOrientationPortrait");
        self.frame = self.playerDefalutFrame;
        [self removeFromSuperview];
        [self.playSuprView addSubview:self];
    }
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
            NSLog(@"%f", current / total);
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
        //remove loading
        if (self.slider.middleValue < self.slider.value) {
            [self addSubview:self.activityIndicatorView];
            [self.activityIndicatorView startAnimating];
            
        }else if(self.slider.middleValue >= self.slider.value) {
            [self.activityIndicatorView removeFromSuperview];
        }
    }
}

#pragma mark - timeFormat

- (NSString *)timeFormatted:(int)totalSeconds {
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
}

#pragma mark - setMenuBaAndTopBarConstraints

- (void)setMenuBaAndTopBarConstraints {
    
    NSLayoutConstraint *menuBarLeft = [NSLayoutConstraint constraintWithItem:self.menuBar attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *menuBarRight = [NSLayoutConstraint constraintWithItem:self.menuBar attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *menuBarBottom = [NSLayoutConstraint constraintWithItem:self.menuBar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *menuBarHeight = [NSLayoutConstraint constraintWithItem:self.menuBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0f constant:kMenuBaHeight];
    [self addConstraints:@[menuBarLeft, menuBarRight, menuBarBottom, menuBarHeight]];
    
    
    NSLayoutConstraint *topBarLeft = [NSLayoutConstraint constraintWithItem:self.topBar attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *topBarRight = [NSLayoutConstraint constraintWithItem:self.topBar attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *topBarTop = [NSLayoutConstraint constraintWithItem:self.topBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *topBarHeight = [NSLayoutConstraint constraintWithItem:self.topBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0f constant:kTopBarHeight];
    [self addConstraints:@[topBarLeft, topBarRight, topBarTop, topBarHeight]];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
