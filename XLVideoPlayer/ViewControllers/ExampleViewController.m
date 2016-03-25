//
//  ExampleViewController.m
//  XLVideoPlayer
//
//  Created by Shelin on 16/3/23.
//  Copyright © 2016年 GreatGate. All rights reserved.
//  https://github.com/ShelinShelin

#import "ExampleViewController.h"
#import "VideoDetailViewController.h"
#import "XLVideoCell.h"
#import "XLVideoPlayer.h"
#import "XLVideoItem.h"
#import "AFNetworking.h"
#import "MJExtension.h"

#define videoListUrl @"http://c.3g.163.com/nc/video/list/VAP4BFR16/y/0-10.html"

@interface ExampleViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate> {
    NSIndexPath *_indexPath;
    XLVideoPlayer *_player;
    CGRect _currentPlayCellRect;
}

@property (weak, nonatomic) IBOutlet UITableView *exampleTableView;

@property (nonatomic, strong) NSMutableArray *videoArray;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;



@end

@implementation ExampleViewController

- (instancetype)init {
    if (self = [super init]) {
        self = [[NSBundle mainBundle] loadNibNamed:@"ExampleViewController" owner:nil options:nil].lastObject;
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.title = @"视频列表";
    }
    return self;
}

- (NSMutableArray *)videoArray {
    if (!_videoArray) {
        _videoArray = [NSMutableArray array];
    }
    return _videoArray;
}

- (UIActivityIndicatorView *)activityIndicatorView {
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _activityIndicatorView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.exampleTableView.rowHeight = 300;

    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    self.activityIndicatorView.center = keyWindow.center;
    [keyWindow addSubview:self.activityIndicatorView];
    [self.activityIndicatorView startAnimating];

    [self fetchVideoListData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self destroyVideoPlayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)destroyVideoPlayer {
    [_player removeFromSuperview];
    _player = nil;
}

#pragma mark - network

- (void)fetchVideoListData {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:videoListUrl parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
//        NSLog(@"%@", responseObject);
        NSArray *dataArray = responseObject[@"VAP4BFR16"];
        for (NSDictionary *dict in dataArray) {
            [self.videoArray addObject:[XLVideoItem mj_objectWithKeyValues:dict]];
        }
        [self.exampleTableView reloadData];
        [self.activityIndicatorView stopAnimating];
        [self.activityIndicatorView removeFromSuperview];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}

- (void)showView:(UITapGestureRecognizer *)tapGesture {
    [self destroyVideoPlayer];

    UIView *view = tapGesture.view;
    XLVideoItem *item = self.videoArray[view.tag - 100];
    _player = [[XLVideoPlayer alloc] initWithVideoUrl:item.mp4_url];
    _player.frame = view.bounds;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:view.tag - 100 inSection:0];
    XLVideoCell *cell = [self.exampleTableView cellForRowAtIndexPath:indexPath];
    [cell.contentView addSubview:_player];
    _currentPlayCellRect = [self.exampleTableView rectForRowAtIndexPath:indexPath];
    _player.completedPlayingBlock = ^(XLVideoPlayer *player) {
        [player removeFromSuperview];
        player = nil;
    };
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.videoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XLVideoCell *cell = [XLVideoCell videoCellWithTableView:tableView];
    XLVideoItem *item = self.videoArray[indexPath.row];
    cell.videoItem = item;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showView:)];
    [cell.videoImageView addGestureRecognizer:tap];
    cell.videoImageView.tag = indexPath.row + 100;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    XLVideoItem *item = self.videoArray[indexPath.row];
    VideoDetailViewController *videoDetailViewController = [[VideoDetailViewController alloc] init];
    videoDetailViewController.videoTitle = item.title;
    videoDetailViewController.mp4_url = item.mp4_url;
    [self.navigationController pushViewController:videoDetailViewController animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.exampleTableView]) {
        
        CGFloat cellBottom = _currentPlayCellRect.origin.y + _currentPlayCellRect.size.height;
        if (scrollView.contentOffset.y > cellBottom) {
            if (_player) {
                [self destroyVideoPlayer];
            }
            return;
        }
        CGFloat cellUp = _currentPlayCellRect.origin.y;
        if (cellUp > scrollView.contentOffset.y + scrollView.frame.size.height) {
            if (_player) {
                [self destroyVideoPlayer];
            }
            return;
        }
    }
}

@end
