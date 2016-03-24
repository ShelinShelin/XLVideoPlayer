//
//  ExampleViewController.m
//  XLVideoPlayer
//
//  Created by Shelin on 16/3/23.
//  Copyright © 2016年 GreatGate. All rights reserved.
//  https://github.com/ShelinShelin

#import "ExampleViewController.h"
#import "XLVideoCell.h"
#import "XLVideoPlayer.h"

#define videoUrl [[NSBundle mainBundle] pathForResource:@"thaiPhuketKaronBeach" ofType:@"MOV"]

static BOOL isExist;

@interface ExampleViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *exampleTableView;

@end

@implementation ExampleViewController

- (instancetype)init {
    if (self = [super init]) {
        self = [[NSBundle mainBundle] loadNibNamed:@"ExampleViewController" owner:nil options:nil].lastObject;
        self.title = @"视频";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.exampleTableView.rowHeight = 300;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [XLVideoCell videoCellWithTableView:tableView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    XLVideoCell *cell = (XLVideoCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (!isExist) {
        XLVideoPlayer *player = [[XLVideoPlayer alloc] initWithVideoUrl:videoUrl];
        player.frame = cell.videoImageView.bounds;
        
        [cell.contentView addSubview:player];
    }
    isExist = YES;
}


@end
