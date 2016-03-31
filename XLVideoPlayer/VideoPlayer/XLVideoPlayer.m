//
//  XLVideoPlayer.m
//  XLVideoPlayer
//
//  Created by Shelin on 16/3/23.
//  Copyright © 2016年 GreatGate. All rights reserved.
//  https://github.com/ShelinShelin
//  博客：http://www.jianshu.com/users/edad244257e2/latest_articles

#import "XLVideoPlayer.h"
#import "XLSlider.h"
#import <AVFoundation/AVFoundation.h>

#define kPlayerBackgroundColor [UIColor blackColor].CGColor
#define kBarAnimateSpeed 0.5f
#define kBarShowDuration 4.0f
#define kOpacity 0.7f
#define kBottomBaHeight 40.0f
#define kPlayBtnSideLength 60.0f

@interface XLVideoPlayer () {
    BOOL _isOriginalFrame;
    BOOL _isFullScreen;
    BOOL _barHiden;
    BOOL _inOperation;
    BOOL _isSmallWindowPlay;
}

/**videoPlayer superView*/
@property (nonatomic, strong) UIView *playSuprView;
@property (nonatomic, strong) UIView *bottomBar;
@property (nonatomic, strong) UIButton *playOrPauseBtn;
@property (nonatomic, strong) UILabel *totalDurationLabel;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) XLSlider *slider;
@property (nonatomic, strong) UIWindow *keyWindow;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, assign) CGRect playerOriginalFrame;
@property (nonatomic, strong) UIButton *zoomScreenBtn;

@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
/**video player*/
@property (nonatomic,strong) AVPlayer *player;
/**video total duration*/
@property (nonatomic, assign) CGFloat totalDuration;

@property (nonatomic, strong) UITableView *bindTableView;
@property (nonatomic, assign) CGRect currentPlayCellRect;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;

@end

@implementation XLVideoPlayer

#pragma mark - public method

- (instancetype)init {
    if ([super init]) {
        
        self.backgroundColor = [UIColor blackColor];
        
        self.keyWindow = [UIApplication sharedApplication].keyWindow;

        //screen orientation change
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
        
        //show or hiden gestureRecognizer
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showOrHidenBar)];
        [self addGestureRecognizer:tap];
        
        _barHiden = YES;
    }
    return self;
}

- (void)setVideoUrl:(NSString *)videoUrl {
    _videoUrl = videoUrl;
    
    [self.layer addSublayer:self.playerLayer];
    [self addSubview:self.activityIndicatorView];
    [self.activityIndicatorView startAnimating];
    //play from start
    [self playOrPause:self.playOrPauseBtn];
    [self addSubview:self.bottomBar];
    [self addSubview:self.playOrPauseBtn];
    
}

- (void)playPause {
    [self playOrPause:self.playOrPauseBtn];
}

- (void)destroyPlayer {
    [self.player pause];
    [self removeFromSuperview];
}

- (void)playerWithBindTableView:(UITableView *)bindTableView currentIndexPath:(NSIndexPath *)currentIndexPath supportSmallWindowPlay:(BOOL)isSupport {

    self.bindTableView = bindTableView;
    
    self.currentPlayCellRect = [bindTableView rectForRowAtIndexPath:currentIndexPath];
    self.currentIndexPath = currentIndexPath;
    
    CGFloat cellBottom = self.currentPlayCellRect.origin.y + self.currentPlayCellRect.size.height;
    CGFloat cellUp = self.currentPlayCellRect.origin.y;
    
    if (bindTableView.contentOffset.y > cellBottom) {  //向上滑动，离开屏幕
        if (!isSupport) {
            [self destroyPlayer];
            return;
        }
        [self smallWindowPlay];
        return;
    }
    
    if (cellUp > bindTableView.contentOffset.y + bindTableView.frame.size.height) { //向下滑动，离开屏幕
        if (!isSupport) {
            [self destroyPlayer];
            return;
        }
        [self smallWindowPlay];
        return;
    }
    
    if (bindTableView.contentOffset.y < cellBottom){ //向下滑动，回到屏幕
        if (!isSupport) return;
        [self returnToOriginView];
        return;
    }
    
    if (cellUp < bindTableView.contentOffset.y + bindTableView.frame.size.height){ //向上滑动，回到屏幕
        if (!isSupport) return;
        [self returnToOriginView];
        return;
    }
}

#pragma mark - layoutSubviews

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.playerLayer.frame = self.bounds;
    
    if (!_isOriginalFrame) {
        self.playerOriginalFrame = self.frame;
        self.playSuprView = self.superview;
        self.bottomBar.frame = CGRectMake(0, self.playerOriginalFrame.size.height - kBottomBaHeight, self.self.playerOriginalFrame.size.width, kBottomBaHeight);
        self.playOrPauseBtn.frame = CGRectMake((self.playerOriginalFrame.size.width - kPlayBtnSideLength) / 2, (self.playerOriginalFrame.size.height - kPlayBtnSideLength) / 2, kPlayBtnSideLength, kPlayBtnSideLength);
        self.activityIndicatorView.center = CGPointMake(self.playerOriginalFrame.size.width / 2, self.playerOriginalFrame.size.height / 2);
        _isOriginalFrame = YES;
    }
}

#pragma mark - lazy loading

- (AVPlayerLayer *)playerLayer {
    if (!_playerLayer) {
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        _playerLayer.backgroundColor = kPlayerBackgroundColor;
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;//视频填充模式
    }
    return _playerLayer;
}

- (AVPlayer *)player{
    if (!_player) {
        AVPlayerItem *playerItem = [self getAVPlayItem];
        self.playerItem = playerItem;
        _player = [AVPlayer playerWithPlayerItem:playerItem];
        
        [self addProgressObserver];
        
        [self addObserverToPlayerItem:playerItem];
    }
    return _player;
}

//initialize AVPlayerItem
- (AVPlayerItem *)getAVPlayItem{
    
    NSAssert(self.videoUrl != nil, @"必须先传入视频url！！！");
    
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
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    return _activityIndicatorView;
}

- (UIView *)bottomBar {
    if (!_bottomBar) {
        _bottomBar = [[UIView alloc] init];
        _bottomBar.backgroundColor = [UIColor blackColor];
        _bottomBar.layer.opacity = 0.0f;
        
        UILabel *label1 = [[UILabel alloc] init];
        label1.translatesAutoresizingMaskIntoConstraints = NO;
        label1.textAlignment = NSTextAlignmentCenter;
        label1.text = @"00:00:00";
        label1.font = [UIFont systemFontOfSize:12.0f];
        label1.textColor = [UIColor whiteColor];
        [_bottomBar addSubview:label1];
        self.progressLabel = label1;
        
        NSLayoutConstraint *label1Left = [NSLayoutConstraint constraintWithItem:label1 attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_bottomBar attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0];
        NSLayoutConstraint *label1Top = [NSLayoutConstraint constraintWithItem:label1 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_bottomBar attribute:NSLayoutAttributeTop multiplier:1.0f constant:0];
        NSLayoutConstraint *label1Bottom = [NSLayoutConstraint constraintWithItem:label1 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_bottomBar attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0];
        NSLayoutConstraint *label1Width = [NSLayoutConstraint constraintWithItem:label1 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0f constant:65.0f];
        [_bottomBar addConstraints:@[label1Left, label1Top, label1Bottom, label1Width]];
        
        
        UIButton *fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        fullScreenBtn.translatesAutoresizingMaskIntoConstraints = NO;
        fullScreenBtn.contentMode = UIViewContentModeCenter;
        [fullScreenBtn setImage:[UIImage imageNamed:@"btn_zoom_out"] forState:UIControlStateNormal];
        [fullScreenBtn setImage:[UIImage imageNamed:@"btn_zoom_in"] forState:UIControlStateSelected];
        [fullScreenBtn addTarget:self action:@selector(actionFullScreen) forControlEvents:UIControlEventTouchDown];
        [_bottomBar addSubview:fullScreenBtn];
        self.zoomScreenBtn = fullScreenBtn;
        
        NSLayoutConstraint *btnWidth = [NSLayoutConstraint constraintWithItem:fullScreenBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0f constant:40.0f];
        NSLayoutConstraint *btnHeight = [NSLayoutConstraint constraintWithItem:fullScreenBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0f constant:40.0f];
        NSLayoutConstraint *btnRight = [NSLayoutConstraint constraintWithItem:fullScreenBtn attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_bottomBar attribute:NSLayoutAttributeRight multiplier:1.0f constant:0];
        NSLayoutConstraint *btnCenterY = [NSLayoutConstraint constraintWithItem:fullScreenBtn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_bottomBar attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0];
        [_bottomBar addConstraints:@[btnWidth, btnHeight, btnRight, btnCenterY]];
        
        
        UILabel *label2 = [[UILabel alloc] init];
        label2.translatesAutoresizingMaskIntoConstraints = NO;
        label2.textAlignment = NSTextAlignmentCenter;
        label2.text = @"00:00:00";
        label2.font = [UIFont systemFontOfSize:12.0f];
        label2.textColor = [UIColor whiteColor];
        [_bottomBar addSubview:label2];
        self.totalDurationLabel = label2;

        NSLayoutConstraint *label2Right = [NSLayoutConstraint constraintWithItem:label2 attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:fullScreenBtn attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0];
        NSLayoutConstraint *label2Top = [NSLayoutConstraint constraintWithItem:label2 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_bottomBar attribute:NSLayoutAttributeTop multiplier:1.0f constant:0];
        NSLayoutConstraint *label2Bottom = [NSLayoutConstraint constraintWithItem:label2 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_bottomBar attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0];
        NSLayoutConstraint *label2Width = [NSLayoutConstraint constraintWithItem:label2 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0f constant:65.0f];
        [_bottomBar addConstraints:@[label2Right, label2Top, label2Bottom, label2Width]];
        
        XLSlider *slider = [[XLSlider alloc] init];
        slider.value = 0.0f;
        slider.middleValue = 0.0f;
        slider.translatesAutoresizingMaskIntoConstraints = NO;
        [_bottomBar addSubview:slider];
        self.slider = slider;
        __weak typeof(self) weakSelf = self;
        slider.valueChangeBlock = ^(XLSlider *slider){
            [weakSelf sliderValueChange:slider];
        };
        slider.finishChangeBlock = ^(XLSlider *slider){
            [weakSelf finishChange];
        };
        slider.dragSliderBlock = ^(XLSlider *slider){
            [weakSelf dragSlider];
        };
        
        NSLayoutConstraint *sliderLeft = [NSLayoutConstraint constraintWithItem:slider attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:label1 attribute:NSLayoutAttributeRight multiplier:1.0f constant:0];
        sliderLeft.priority = UILayoutPriorityDefaultLow;
        NSLayoutConstraint *sliderRight = [NSLayoutConstraint constraintWithItem:slider attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:label2 attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0];
        NSLayoutConstraint *sliderTop = [NSLayoutConstraint constraintWithItem:slider attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_bottomBar attribute:NSLayoutAttributeTop multiplier:1.0f constant:0];
        NSLayoutConstraint *sliderBottom = [NSLayoutConstraint constraintWithItem:slider attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_bottomBar attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0];
        [_bottomBar addConstraints:@[sliderLeft, sliderRight, sliderTop, sliderBottom]];
        
        [self updateConstraintsIfNeeded];
    }
    return _bottomBar;
}

- (UIButton *)playOrPauseBtn {
    if (!_playOrPauseBtn) {
        _playOrPauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _playOrPauseBtn.layer.opacity = 0.0f;
        _playOrPauseBtn.contentMode = UIViewContentModeCenter;
        [_playOrPauseBtn setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [_playOrPauseBtn setBackgroundImage:[UIImage imageNamed:@"pause"] forState:UIControlStateSelected];
        [_playOrPauseBtn addTarget:self action:@selector(playOrPause:) forControlEvents:UIControlEventTouchDown];
    }
    return _playOrPauseBtn;
}

#pragma mark - status hiden

- (void)setStatusBarHidden:(BOOL)hidden {
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    statusBar.hidden = hidden;
}

#pragma mark - Screen Orientation

- (void)statusBarOrientationChange:(NSNotification *)notification {
    if (_isSmallWindowPlay) return;
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (orientation == UIDeviceOrientationLandscapeLeft) {
//        NSLog(@"UIDeviceOrientationLandscapeLeft");
        [self orientationLeftFullScreen];
    }else if (orientation == UIDeviceOrientationLandscapeRight) {
//        NSLog(@"UIDeviceOrientationLandscapeRight");
        [self orientationRightFullScreen];
    }else if (orientation == UIDeviceOrientationPortrait) {
//        NSLog(@"UIDeviceOrientationPortrait");
        [self smallScreen];
    }
}

- (void)actionFullScreen {
    if (!_isFullScreen) {
        [self orientationLeftFullScreen];
    }else {
        [self smallScreen];
    }
}

- (void)orientationLeftFullScreen {
    _isFullScreen = YES;
    self.zoomScreenBtn.selected = YES;
    [self.keyWindow addSubview:self];
    
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];
    [self updateConstraintsIfNeeded];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformMakeRotation(M_PI / 2);
        self.frame = self.keyWindow.bounds;
        self.bottomBar.frame = CGRectMake(0, self.keyWindow.bounds.size.width - kBottomBaHeight, self.keyWindow.bounds.size.height, kBottomBaHeight);
        self.playOrPauseBtn.frame = CGRectMake((self.keyWindow.bounds.size.height - kPlayBtnSideLength) / 2, (self.keyWindow.bounds.size.width - kPlayBtnSideLength) / 2, kPlayBtnSideLength, kPlayBtnSideLength);
        self.activityIndicatorView.center = CGPointMake(self.keyWindow.bounds.size.height / 2, self.keyWindow.bounds.size.width / 2);
    }];
    
    [self setStatusBarHidden:YES];
}

- (void)orientationRightFullScreen {
    _isFullScreen = YES;
    self.zoomScreenBtn.selected = YES;
    [self.keyWindow addSubview:self];
    
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeRight] forKey:@"orientation"];
    
    [self updateConstraintsIfNeeded];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformMakeRotation(-M_PI / 2);
        self.frame = self.keyWindow.bounds;
        self.bottomBar.frame = CGRectMake(0, self.keyWindow.bounds.size.width - kBottomBaHeight, self.keyWindow.bounds.size.height, kBottomBaHeight);
        self.playOrPauseBtn.frame = CGRectMake((self.keyWindow.bounds.size.height - kPlayBtnSideLength) / 2, (self.keyWindow.bounds.size.width - kPlayBtnSideLength) / 2, kPlayBtnSideLength, kPlayBtnSideLength);
        self.activityIndicatorView.center = CGPointMake(self.keyWindow.bounds.size.height / 2, self.keyWindow.bounds.size.width / 2);
    }];
    [self setStatusBarHidden:YES];
}

- (void)smallScreen {
    _isFullScreen = NO;
    self.zoomScreenBtn.selected = NO;
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
    
    [self.playSuprView addSubview:self];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformMakeRotation(0);
        self.frame = self.playerOriginalFrame;
        self.bottomBar.frame = CGRectMake(0, self.playerOriginalFrame.size.height - kBottomBaHeight, self.self.playerOriginalFrame.size.width, kBottomBaHeight);
        self.playOrPauseBtn.frame = CGRectMake((self.playerOriginalFrame.size.width - kPlayBtnSideLength) / 2, (self.playerOriginalFrame.size.height - kPlayBtnSideLength) / 2, kPlayBtnSideLength, kPlayBtnSideLength);
        self.activityIndicatorView.center = CGPointMake(self.playerOriginalFrame.size.width / 2, self.playerOriginalFrame.size.height / 2);
        [self updateConstraintsIfNeeded];
    }];
    [self setStatusBarHidden:NO];
}

#pragma mark - button action

- (void)playOrPause:(UIButton *)btn {
    if(self.player.rate == 0){      //pause
        btn.selected = YES;
        [self.player play];
    }else if(self.player.rate == 1){    //playing
        [self.player pause];
        btn.selected = NO;
    }
}

- (void)showOrHidenBar {
    if (_barHiden) {
        [self show];
    }else {
        [self hiden];
    }
}

- (void)show {
    [UIView animateWithDuration:kBarAnimateSpeed animations:^{
        self.bottomBar.layer.opacity = kOpacity;
        self.playOrPauseBtn.layer.opacity = kOpacity;
    } completion:^(BOOL finished) {
        if (finished) {
            _barHiden = !_barHiden;
            [self performBlock:^{
                if (!_barHiden && !_inOperation) {
                    [self hiden];
                }
            } afterDelay:kBarShowDuration];
        }
    }];
}

- (void)hiden {
    _inOperation = NO;
    [UIView animateWithDuration:kBarAnimateSpeed animations:^{
        self.bottomBar.layer.opacity = 0.0f;
        self.playOrPauseBtn.layer.opacity = 0.0f;
    } completion:^(BOOL finished){
        if (finished) {
            _barHiden = !_barHiden;
        }
    }];
}

#pragma mark - call back

- (void)sliderValueChange:(XLSlider *)slider {
    self.progressLabel.text = [self timeFormatted:slider.value * self.totalDuration];
}

- (void)finishChange {
    _inOperation = NO;
    [self performBlock:^{
        if (!_barHiden && !_inOperation) {
            [self hiden];
        }
    } afterDelay:kBarShowDuration];
    CMTime currentCMTime = CMTimeMake(self.slider.value * self.totalDuration, 1);

    [self.player seekToTime:currentCMTime completionHandler:^(BOOL finished) {
        [self.player play];
        self.playOrPauseBtn.selected = YES;
    }];
}

//Dragging the thumb to suspend video playback

- (void)dragSlider {
    _inOperation = YES;
    [self.player pause];;
}

- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay {
    [self performSelector:@selector(callBlockAfterDelay:) withObject:block afterDelay:delay];
}

- (void)callBlockAfterDelay:(void (^)(void))block {
    block();
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
        weakSelf.progressLabel.text = [weakSelf timeFormatted:current];
        if (current) {
//            NSLog(@"%f", current / total);
            weakSelf.slider.value = current / total;
            
            if (weakSelf.slider.value == 1) {      //complete block
                if (weakSelf.completedPlayingBlock) {
                    [weakSelf setStatusBarHidden:NO];
                    weakSelf.completedPlayingBlock(weakSelf);
                }else {       //finish and loop playback
                    weakSelf.playOrPauseBtn.selected = NO;
                    [weakSelf showOrHidenBar];
                    CMTime currentCMTime = CMTimeMake(0, 1);
                    [weakSelf.player seekToTime:currentCMTime completionHandler:^(BOOL finished) {
                        weakSelf.slider.value = 0.0f;
                    }];
                }
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
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem = object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue];
        if(status == AVPlayerStatusReadyToPlay){
            self.totalDuration = CMTimeGetSeconds(playerItem.duration);
            self.totalDurationLabel.text = [self timeFormatted:self.totalDuration];
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray *array = playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        self.slider.middleValue = totalBuffer / CMTimeGetSeconds(playerItem.duration);
//        NSLog(@"totalBuffer：%.2f",totalBuffer);
        //remove loading animation
        if (self.slider.middleValue <= self.slider.value) {
            self.activityIndicatorView.center = self.center;
            [self addSubview:self.activityIndicatorView];
            [self.activityIndicatorView startAnimating];
        }else {
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

#pragma mark - animation smallWindowPlay

- (void)smallWindowPlay {
    if ([self.superview isKindOfClass:[UIWindow class]]) return;
    _isSmallWindowPlay = YES;
    self.playOrPauseBtn.hidden = YES;
    self.bottomBar.hidden = YES;
    
    CGRect tableViewframe = [self.bindTableView convertRect:self.bindTableView.bounds toView:self.keyWindow];
    self.frame = [self convertRect:self.frame toView:self.keyWindow];
    [self.keyWindow addSubview:self];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        CGFloat w = self.playerOriginalFrame.size.width * 0.5;
        CGFloat h = self.playerOriginalFrame.size.height * 0.5;
        CGRect smallFrame = CGRectMake(tableViewframe.origin.x + tableViewframe.size.width - w, tableViewframe.origin.y + tableViewframe.size.height - h, w, h);
        self.frame = smallFrame;
        self.playerLayer.frame = self.bounds;
        self.activityIndicatorView.center = CGPointMake(w / 2.0, h / 2.0);
    }];
}

- (void)returnToOriginView {
    if (![self.superview isKindOfClass:[UIWindow class]]) return;
    _isSmallWindowPlay = NO;
    self.playOrPauseBtn.hidden = NO;
    self.bottomBar.hidden = NO;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.frame = CGRectMake(self.currentPlayCellRect.origin.x, self.currentPlayCellRect.origin.y, self.playerOriginalFrame.size.width, self.playerOriginalFrame.size.height);
        self.playerLayer.frame = self.bounds;
        self.activityIndicatorView.center = CGPointMake(self.playerOriginalFrame.size.width / 2, self.playerOriginalFrame.size.height / 2);
    } completion:^(BOOL finished) {
        self.frame = self.playerOriginalFrame;
        UITableViewCell *cell = [self.bindTableView cellForRowAtIndexPath:self.currentIndexPath];
        UIView *currentSuperView;
        
        for (UIView *subView in cell.contentView.subviews) {
            if ([subView isKindOfClass:[self.playSuprView class]]) {
                currentSuperView = subView;
            }
        }
        if ([cell.contentView isKindOfClass:[self.playSuprView class]]) {
            currentSuperView = cell.contentView;
        }
        [currentSuperView addSubview:self];
    }];
}

#pragma mark - dealloc

- (void)dealloc {
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    NSLog(@"video player - dealloc");
}

@end
