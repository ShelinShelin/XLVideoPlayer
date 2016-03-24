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

#define videoUrl [[NSBundle mainBundle] pathForResource:@"thaiPhuketKaronBeach" ofType:@"MOV"]

#define videoListUrl @"http://c.3g.163.com/nc/video/list/VAP4BFR16/y/0-10.html"

static BOOL isExist;

@interface ExampleViewController () <UITableViewDataSource, UITableViewDelegate> {
    NSIndexPath *_indexPath;
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
        self.title = @"视频";
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
        _activityIndicatorView = [[UIActivityIndicatorView alloc] init];
        
    }
    return _activityIndicatorView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.exampleTableView.rowHeight = 300;
    
    self.activityIndicatorView.center = self.view.center;
    [[UIApplication sharedApplication].keyWindow addSubview:self.activityIndicatorView];
    [self.activityIndicatorView startAnimating];

    [self fetchVideoListData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - network

- (void)fetchVideoListData {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:videoListUrl parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSLog(@"%@", responseObject);
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

- (void)showView {
    NSLog(@"showView");
    XLVideoPlayer *player = [[XLVideoPlayer alloc] initWithVideoUrl:videoUrl];
//    XLVideoItem *item = self.videoArray[indexPath.row]
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.videoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XLVideoCell *cell = [XLVideoCell videoCellWithTableView:tableView];
    XLVideoItem *item = self.videoArray[indexPath.row];
    cell.videoItem = item;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showView)];
    [cell.videoImageView addGestureRecognizer:tap];
    cell.videoImageView.tag = indexPath.row;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    
//    XLVideoCell *cell = (XLVideoCell *)[tableView cellForRowAtIndexPath:indexPath];
//    if (!isExist) {
//        XLVideoPlayer *player = [[XLVideoPlayer alloc] initWithVideoUrl:videoUrl];
//        player.frame = cell.videoImageView.bounds;
//        [cell.contentView addSubview:player];
//    }
//    isExist = YES;
    XLVideoItem *item = self.videoArray[indexPath.row];
    VideoDetailViewController *videoDetailViewController = [[VideoDetailViewController alloc] init];
    videoDetailViewController.videoTitle = item.title;
    videoDetailViewController.mp4_url = item.mp4_url;
    [self.navigationController pushViewController:videoDetailViewController animated:YES];
}


@end
