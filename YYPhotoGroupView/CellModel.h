//
//  CellModel.h
//  YYPhotoGroupView
//
//  Created by 赵铭 on 2017/9/6.
//  Copyright © 2017年 zm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CellModel : NSObject
@property (nonatomic, copy) NSArray <NSString *>* urls;
@property (nonatomic, copy) NSArray <NSString *>*largeUrls;
@property (nonatomic, copy) NSString * title;
@end
