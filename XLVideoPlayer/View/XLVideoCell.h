//
//  XLVideoCell.h
//  XLVideoPlayer
//
//  Created by Shelin on 16/3/22.
//  Copyright © 2016年 GreatGate. All rights reserved.
//  https://github.com/ShelinShelin

#import <UIKit/UIKit.h>
@class XLVideoItem;

@interface XLVideoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *videoImageView;
@property (weak, nonatomic) IBOutlet UILabel *videoTitle;

@property (nonatomic, strong) XLVideoItem *videoItem;

+ (XLVideoCell *)videoCellWithTableView:(UITableView *)tableview;

@end
