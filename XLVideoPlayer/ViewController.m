//
//  ViewController.m
//  XLVideoPlayer
//
//  Created by Shelin on 16/2/1.
//  Copyright © 2016年 GreatGate. All rights reserved.
//

#import "ViewController.h"
#import "XLVideoPlayer.h"
#import "XLVideoCell.h"

#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenAspectRatio kScreenWidth / kScreenHeight

#define VIDEO_URL [NSURL fileURLWithPath:]

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.estimatedRowHeight = 100;
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
   
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [XLVideoCell videoCellWithTableView:tableView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"didSelectRowAtIndexPath");
    XLVideoCell *cell = (XLVideoCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    XLVideoPlayer *player = [[XLVideoPlayer alloc] initWithVideoUrl:[[NSBundle mainBundle] pathForResource:@"thaiPhuketKaronBeach" ofType:@"MOV"]];
    player.frame = cell.videoImageView.bounds;
    
    [cell insertSubview:player aboveSubview:cell.videoImageView];
}
@end
