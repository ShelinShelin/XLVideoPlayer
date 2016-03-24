//
//  XLVideoCell.m
//  XLVideoPlayer
//
//  Created by Shelin on 16/3/22.
//  Copyright © 2016年 GreatGate. All rights reserved.
//  https://github.com/ShelinShelin

#import "XLVideoCell.h"

@implementation XLVideoCell

+ (XLVideoCell *)videoCellWithTableView:(UITableView *)tableview {
    static NSString *ID = @"XLVideoCell";
    XLVideoCell *cell = [tableview dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"XLVideoCell" owner:nil options:nil].lastObject;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}
@end
