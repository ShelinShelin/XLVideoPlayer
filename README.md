# XLVideoPlayer
A Custom Video Player
######XLVideoPlayer是基于AVFoundation的视频播放器，完全自定义界面，支持UITableViewCell小屏、全屏手动及重力感应切换，继承与UIView，与视图控制器解耦，不依赖与第三方库，支持mp4、m3u8、3gp、mov、flv，使用简单，运行务必保证模拟器/真机网络畅通，视频均来自网络，动图效果比较大，请耐心等待！如使用中遇到bug欢迎issues，更多前往 [个人博客](http://www.jianshu.com/users/edad244257e2/latest_articles"Title")。
- 动态图。

![](https://github.com/ShelinShelin/XLVideoPlayer/blob/master/gif/Untitled_1.gif)
![](https://github.com/ShelinShelin/XLVideoPlayer/blob/master/gif/Untitled_2.gif)
- XLVideoPlayer.h接口定义
```
@interface XLVideoPlayer : UIView
@property (nonatomic, copy) VideoCompletedPlayingBlock completedPlayingBlock;
/**video url*/
@property (nonatomic, strong) NSString *videoUrl;
@end
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
    _player.frame = CGRectMake(0, 64, self.view.frame.size.width, 250);
    [self.view addSubview:_player];
}
```


