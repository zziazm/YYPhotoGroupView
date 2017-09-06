//
//  CustomTableViewCell.m
//  YYPhotoGroupView
//
//  Created by 赵铭 on 2017/9/6.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "CustomTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "CellModel.h"
#import "UIView+YYAdd.h"
#import <SDWebImage/UIView+WebCache.h>
#define kImageWidth 100
#define kPadding ([UIScreen mainScreen].bounds.size.width - 3*kImageWidth)/4

@interface CustomTableViewCell()
@property (nonatomic, strong) UILabel *label;

@end

@implementation CustomTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _label = [UILabel new];
        _label.top = 0;
        _label.left = 0;
        _label.height = 30;
        _label.width = 300;
        [self.contentView addSubview:_label];
        
        _imageViews = @[].mutableCopy;
        for (int i = 0; i < 9; i++) {
            UIImageView * iv = [UIImageView new];
            [_imageViews addObject:iv];
            iv.userInteractionEnabled = YES;
            UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
            iv.tag = 1000 + i;
            [iv addGestureRecognizer:tap];
            iv.hidden = YES;
            [self.contentView addSubview:iv];
        }
    }
    return self;
}

- (void)tap:(UITapGestureRecognizer *)tap{
    UIImageView * iv = (UIImageView *)tap.view;
    NSInteger idx = iv.tag - 1000;
    if ([self.delegate respondsToSelector:@selector(cell:didTapViewIndex:)]) {
        [self.delegate cell:self didTapViewIndex:idx];
    }
    
}

- (void)setModel:(CellModel *)model{
    if (model != _model) {
        _model = model;
        _label.text = model.title;
        [self cancelAllImageDownload];
        for (int i = 0; i < 9; i++) {
            UIImageView *iv = _imageViews[i];
            if (i < model.urls.count) {
                int row = i / 3;
                int column = i % 3;
                iv.top = kPadding + row*(kImageWidth + kPadding) + 30;
                iv.left = kPadding + column*(kImageWidth + kPadding);
                iv.width = kImageWidth;
                iv.height = kImageWidth;
                [iv sd_setImageWithURL:[NSURL URLWithString:model.urls[i]] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                    
                }];
                iv.hidden = NO;
            }else{
                iv.hidden = YES;
            }
           
        }
        
    }
}

- (void)cancelAllImageDownload{
    for (UIImageView *view in self.imageViews) {
        [view sd_cancelCurrentImageLoad];
    }
}

+ (CGFloat)heightForCell:(CellModel *)model{
    if (model.urls.count <= 3) {
        return 2*kPadding + kImageWidth + 30;
    }else if (model.urls.count >3 && model.urls.count <= 6){
        return 3*kPadding + 2*kImageWidth + 30;
    }else{
        return 4*kPadding + 3*kImageWidth + 30;
    }
}
- (void)awakeFromNib {
    [super awakeFromNib];

    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
