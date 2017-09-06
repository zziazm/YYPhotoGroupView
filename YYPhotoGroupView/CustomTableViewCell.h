//
//  CustomTableViewCell.h
//  YYPhotoGroupView
//
//  Created by 赵铭 on 2017/9/6.
//  Copyright © 2017年 zm. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomTableViewCell;

@protocol CustomTableViewCellDelegate <NSObject>
@optional
- (void)cell:(CustomTableViewCell *)cell didTapViewIndex:(NSInteger)idx;

@end


@class CellModel;
@interface CustomTableViewCell : UITableViewCell
@property (nonatomic, strong) CellModel * model;
@property (nonatomic, weak) id<CustomTableViewCellDelegate>delegate;
@property (nonatomic, strong) NSMutableArray * imageViews;
+ (CGFloat)heightForCell:(CellModel *)model;
@end
