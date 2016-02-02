//
//  ViewController.m
//  XLVideoPlayer
//
//  Created by Shelin on 16/2/1.
//  Copyright © 2016年 GreatGate. All rights reserved.
//

#import "ViewController.h"
#import "XLVideoPlayer.h"
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenAspectRatio kScreenWidth / kScreenHeight

#define VIDEO_URL [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"thaiPhuketKaronBeach" ofType:@"MOV"]]

#import "XLMenuBar.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    XLVideoPlayer *player = [[XLVideoPlayer alloc] initWithVideoUrl:VIDEO_URL];
    player.frame  = CGRectMake(0, 0, kScreenWidth, kScreenWidth * kScreenAspectRatio);
    [self.view addSubview:player];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
