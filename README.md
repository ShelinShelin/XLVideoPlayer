# XLVideoPlayer
A Custom Video Player
######XLVideoPlayer是基于AVFoundation的视频播放器，完全自定义界面，支持UITableViewCell上小屏、全屏，手动及屏幕旋转切换，继承与UIView，显示包含播放进度、网络加载进度。与视图控制器解耦，不依赖与第三方库，支持mp4、m3u8、3gp、mov、flv，使用简单，运行代码务必保证模拟器/真机网络畅通，视频均来自网络，动图效果比较大，请耐心等待！如使用中遇到bug欢迎issues，更多前往 [个人博客](http://www.jianshu.com/users/edad244257e2/latest_articles)。
- 动态图。

视频列表页和详情页

![](https://github.com/ShelinShelin/XLVideoPlayer/blob/master/gif/Untitled_2.gif)
![](https://github.com/ShelinShelin/XLVideoPlayer/blob/master/gif/Untitled_4.gif)
- XLVideoPlayer.h接口定义

每次视频播放完毕默认回到起始位置，点击后可循环播放，播放完毕也可把你想做的事放在回调的block中
```
@interface XLVideoPlayer : UIView
@property (nonatomic, copy) VideoCompletedPlayingBlock completedPlayingBlock;

/** video url */
@property (nonatomic, strong) NSString *videoUrl;

/**play or pause  根据播放器当前播放状态执行播放或者暂停操作 */
- (void)playPause;

/** dealloc 暂停移除播放器，最后记得将player = nil */
- (void)destroyPlayer;

@end
```
- 使用

将VideoPlayer文件夹内四个文件，及对应图片拖入工程内
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
    _player.frame = CGRectMake(0, 64, self.view.frame.size.width, 250);
    [self.view addSubview:_player];
}
```


