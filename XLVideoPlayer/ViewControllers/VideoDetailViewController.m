//
//  VideoDetailViewController.m
//  XLVideoPlayer
//
//  Created by Shelin on 16/3/24.
//  Copyright © 2016年 GreatGate. All rights reserved.
//

#import "VideoDetailViewController.h"
#import "XLVideoPlayer.h"

@interface VideoDetailViewController ()

@end

@implementation VideoDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = self.videoTitle;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    XLVideoPlayer *player = [[XLVideoPlayer alloc] initWithVideoUrl:self.mp4_url];
    player.frame = CGRectMake(0, 64, self.view.frame.size.width, 250);
    [self.view addSubview:player];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
