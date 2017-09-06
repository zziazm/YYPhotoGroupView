//
//  UIImage+YYAdd.h
//  YYPhotoGroupView
//
//  Created by 赵铭 on 2017/9/4.
//  Copyright © 2017年 zm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (YYAdd)
- (UIImage *)imageByBlurRadius:(CGFloat)blurRadius
                     tintColor:(UIColor *)tintColor
                      tintMode:(CGBlendMode)tintBlendMode
                    saturation:(CGFloat)saturation
                     maskImage:(UIImage *)maskImage;

- (UIImage *)imageByBlurDark;

+ (UIImage *)imageWithColor:(UIColor *)color;
@end
