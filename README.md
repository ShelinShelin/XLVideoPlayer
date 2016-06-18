# XLVideoPlayer
A Custom Video Player

![](https://github.com/ShelinShelin/XLVideoPlayer/blob/master/gif/Untitled_1.gif)
![](https://github.com/ShelinShelin/XLVideoPlayer/blob/master/gif/Untitled_2.gif)
- XLVideoPlayer.h接口定义
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


