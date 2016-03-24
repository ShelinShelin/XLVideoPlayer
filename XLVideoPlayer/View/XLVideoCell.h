//
//  XLVideoCell.h
//  XLVideoPlayer
//
//  Created by Shelin on 16/3/22.
//  Copyright © 2016年 GreatGate. All rights reserved.
//  https://github.com/ShelinShelin

#import <UIKit/UIKit.h>

@interface XLVideoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *videoImageView;

+ (XLVideoCell *)videoCellWithTableView:(UITableView *)tableview;
@end
