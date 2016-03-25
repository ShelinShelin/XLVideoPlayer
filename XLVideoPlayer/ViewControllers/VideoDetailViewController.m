//
//  VideoDetailViewController.m
//  XLVideoPlayer
//
//  Created by Shelin on 16/3/24.
//  Copyright © 2016年 GreatGate. All rights reserved.
//

#import "VideoDetailViewController.h"
#import "XLVideoPlayer.h"

@interface VideoDetailViewController () {
    XLVideoPlayer *_player;
}
@end

@implementation VideoDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = self.videoTitle;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _player = [[XLVideoPlayer alloc] initWithVideoUrl:self.mp4_url];
    _player.frame = CGRectMake(0, 64, self.view.frame.size.width, 250);
    [self.view addSubview:_player];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_player removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
