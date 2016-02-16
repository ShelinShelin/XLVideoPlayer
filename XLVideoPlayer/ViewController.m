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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSURL *url = [NSURL URLWithString:@"http://119.90.127.133/youku/656B810EC543818EC134A4EF2/030008010056A7138D7457003E880324242F42-0E8E-8742-2C0B-799D7B49E617.mp4"];
    
    XLVideoPlayer *player = [[XLVideoPlayer alloc] initWithVideoUrl:url];
    player.frame  = CGRectMake(0, 0, kScreenWidth, 400);
    [self.view addSubview:player];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
