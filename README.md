# XLVideoPlayer
A Custom Video Player
######XLVideoPlayer是基于AVFoundation的视频播放器，完全自定义界面：

- 支持UITableViewCell上小屏、全屏，手动及屏幕旋转切换。
- 支持右下角小窗口悬停播放。
- 继承与UIView，不依赖与第三方库，显示包含播放进度、网络加载进度。
- 支持本地、网络（mp4、m3u8、3gp、mov）视频，拖拽、点击调整播放进度。

务必保证模拟器/真机网络畅通，视频均来自网络，动图效果比较大，请耐心等待！如使用中遇到bug欢迎issues，更多前往 [个人博客](http://www.jianshu.com/users/edad244257e2/latest_articles)。

- 动态图。

视频列表页和详情页

![](https://github.com/ShelinShelin/XLVideoPlayer/blob/master/gif/Untitled_1.gif)
![](https://github.com/ShelinShelin/XLVideoPlayer/blob/master/gif/Untitled_2.gif)
- XLVideoPlayer.h接口定义

每次视频播放完毕默认回到起始位置，点击后可循环播放，播放完毕也可把你想做的事放在回调的block中。如果加在普通UIView上播放可以不调用UITableView相关方法。
```

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

```
- 使用 

```
@interface VideoDetailViewController () {
    XLVideoPlayer *_player;
}
@end
@implementation VideoDetailViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _player = [[XLVideoPlayer alloc] init];
    _player.videoUrl = self.mp4_url;
    [_player playerBindTableView:self.exampleTableView currentIndexPath:_indexPath];
    _player.frame = CGRectMake(0, 64, self.view.frame.size.width, 250);
    [cell.contentView addSubview:_player];
}

```

```
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.exampleTableView]) {
        
        [_player playerScrollIsSupportSmallWindowPlay:YES];
    }
}

```


