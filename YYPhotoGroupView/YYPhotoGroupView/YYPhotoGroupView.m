//
//  YYPhotoGroupView.m
//  YYPhotoGroupView
//
//  Created by 赵铭 on 2017/9/1.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "YYPhotoGroupView.h"
#import "UIView+YYAdd.h"
#import "NSString+YYAdd.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIView+WebCache.h>
#import <SDWebImage/SDWebImageManager.h>
#import "UIImage+YYAdd.h"

#define kPadding 20
#define kHiColor [UIColor colorWithRGBHex:0x2dd6b8]
NSString * const yykitFadeAnimationKey  = @"yykit.fade";
#define YY_CLAMP(_x_, _low_, _high_)  (((_x_) > (_high_)) ? (_high_) : (((_x_) < (_low_)) ? (_low_) : (_x_)))


static CGSize CGSizePixelCeil(CGSize size){
    CGFloat scale = [UIScreen mainScreen].scale;
    return CGSizeMake((floor(size.width * scale) + 0.5) / scale,
                      (floor(size.height * scale) + 0.5) / scale);
}


@interface YYPhotoGroupItem()<NSCopying>
@property (nonatomic, readonly) UIImage *thumbImage;
@property (nonatomic, readonly) BOOL thumbClippedToTop;

- (BOOL)shouldClipToTop:(CGSize)imageSize
                forView:(UIView *)view;
@end


@implementation YYPhotoGroupItem
- (id)copyWithZone:(nullable NSZone *)zone{
    YYPhotoGroupItem * item = [self.class new];
    return item;
}

- (BOOL)thumbClippedToTop{
    if (_thumbView) {
        if (_thumbView.layer.contentsRect.size.height < 1) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)shouldClipToTop:(CGSize)imageSize forView:(UIView *)view{
    if (imageSize.width < 1 || imageSize.height < 1) {
        return NO;
    }
    
    if (view.width < 1 || view.height < 1) {
        return NO;
    }
    
    return imageSize.height / imageSize.height > view.width / view.height;
}

@end

@interface YYPhotoGroupCell : UIScrollView<UIScrollViewDelegate>
@property (nonatomic, strong) UIView *imageContainerView;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, assign) NSInteger page;

@property (nonatomic, assign) BOOL showProgress;

@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) YYPhotoGroupItem *item;
@property (nonatomic, readonly) BOOL itemDidLoad;

- (void)resizeSubviewSize;

@end

@implementation YYPhotoGroupCell

- (instancetype)init{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.delegate = self;
    self.bouncesZoom = YES;
    self.maximumZoomScale = 3;
    self.multipleTouchEnabled = YES;
    self.alwaysBounceVertical = NO;
    self.showsVerticalScrollIndicator = YES;
    self.showsHorizontalScrollIndicator = NO;
    self.frame = [UIScreen mainScreen].bounds;
    
    _imageContainerView = [UIView new];
    _imageContainerView.clipsToBounds = YES;
    [self addSubview:_imageContainerView];
    
    _imageView = [UIImageView new];
    _imageView.clipsToBounds = YES;
    _imageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
    [_imageContainerView addSubview:_imageView];
    
    _progressLayer = [CAShapeLayer layer];
    _progressLayer.frame = CGRectMake(0, 0, 40, 40);
    _progressLayer.cornerRadius = 20;
    _progressLayer.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5].CGColor;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(_progressLayer.bounds, 7, 7) cornerRadius:40 / 2 - 7];
    _progressLayer.path = path.CGPath;
    _progressLayer.fillColor = [UIColor clearColor].CGColor;
    _progressLayer.strokeColor = [UIColor whiteColor].CGColor;
    _progressLayer.lineWidth = 4;
    _progressLayer.lineCap = kCALineCapRound;
    _progressLayer.strokeStart = 0;
    _progressLayer.strokeEnd = 0;
    _progressLayer.hidden = YES;
    [self.layer addSublayer:_progressLayer];
    
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    //把_progressLayer移动到视图的中间
    _progressLayer.frame = CGRectMake(self.width/2 - _progressLayer.frame.size.width /2, self.height/2 - _progressLayer.frame.size.height/2, _progressLayer.frame.size.width, _progressLayer.frame.size.height);
}

- (void)setItem:(YYPhotoGroupItem *)item{
    if (_item == item) {
        return;
    }
    
    _item =item;
    _itemDidLoad = NO;
    
    [self setZoomScale:1.0 animated:YES];
    self.maximumZoomScale = 1;
    
    [_imageView sd_cancelCurrentImageLoad];
    [_imageView.layer removeAnimationForKey:yykitFadeAnimationKey];
    
    _progressLayer.hidden = NO;
    [CATransaction  begin];
    [CATransaction  setDisableActions:YES];
    _progressLayer.strokeEnd = 0;
    _progressLayer.hidden = YES;
    [CATransaction  commit];
    
    if (!_item) {
        _imageView.image = nil;
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [_imageView sd_setImageWithURL:item.largeImageURL placeholderImage:item.thumbImage options:kNilOptions progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        __strong typeof(self) strongSelf = weakSelf;
        CGFloat progress = receivedSize / expectedSize;
        progress = progress < 0.01 ? 0.01 : (progress > 1 ? 1 : progress);
        if (isnan(progress)) {
            progress = 0;
        }
        strongSelf.progressLayer.hidden = NO;
        //下载进度动画
        strongSelf.progressLayer.strokeEnd = progress;
        
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.progressLayer.hidden = YES;
        strongSelf.maximumZoomScale = 3;
        if (image) {
            strongSelf->_itemDidLoad = YES;
            [strongSelf resizeSubviewSize];
            CATransition * transition = [CATransition animation];
            transition.duration = 0.1;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            [strongSelf.layer addAnimation:transition forKey:yykitFadeAnimationKey];
        }
    }];
    
    [self resizeSubviewSize];
}

- (void)resizeSubviewSize{
    _imageContainerView.origin = CGPointZero;
    _imageContainerView.width = self.width;
    
    UIImage * image = _imageView.image;
    if (image.size.height / image.size.width > self.height / self.width) {
        _imageContainerView.height = floor(image.size.height / (image.size.width / self.width));
    }else{
        CGFloat height = image.size.height / image.size.width * self.width;
        if (height < 1 || isnan(height)) {
            height = self.height;
        }
        height = floor(height);
        _imageContainerView.height = height;
        _imageContainerView.centerY = self.height/2;
    }
    
    if (_imageContainerView.height > self.height && _imageContainerView.height - self.height < 1) {
        _imageContainerView.height = self.height;
    }
    self.contentSize = CGSizeMake(self.width , MAX(_imageContainerView.height, self.height));
    [self scrollRectToVisible:self.bounds animated:NO];
    if (_imageContainerView.height <= self.height) {
        self.alwaysBounceVertical = NO;
    }else {
        self.alwaysBounceVertical = YES;
    }
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _imageView.frame = _imageContainerView.bounds;
    [CATransaction commit];

}

#pragma mark -- UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _imageContainerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    UIView * subView = _imageContainerView;
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

@end

@interface YYPhotoGroupView ()<UIScrollViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, weak) UIView *fromView;

@property (nonatomic, weak) UIView *toContainerView;

/**
 toContainerView的snapshot
 */
@property (nonatomic, strong) UIImage *snapshotImage;

/**
 toContainerView隐藏掉fromView的snapshot
 */
@property (nonatomic, strong) UIImage *snapshorImageHideFromView;

@property (nonatomic, strong) UIImageView *background;

@property (nonatomic, strong) UIImageView *blurBackground;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) NSMutableArray <YYPhotoGroupCell *>*cells;

@property (nonatomic, strong) UIScrollView * scrollView;

@property (nonatomic, strong) UIPageControl * pager;

@property (nonatomic, assign) NSInteger pagerCurrentPage;

@property (nonatomic, assign) BOOL fromNavigationBarHidden;

@property (nonatomic, assign) NSInteger fromItemIndex;

@property (nonatomic, assign) BOOL isPresented;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, assign) CGPoint panGestureBeginPoint;

@end

@implementation YYPhotoGroupView

- (instancetype)initWithGroupItems:(NSArray<YYPhotoGroupItem *>*)groupItems{
    self = [super init];
    if (groupItems.count == 0) {
        return nil;
    }
    _groupItems = groupItems.copy;
    _blurEffectBackground = YES;
    
    self.backgroundColor = [UIColor clearColor];
    self.frame = [UIScreen mainScreen].bounds;
    self.clipsToBounds = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    tap2.delegate= self;
    tap2.numberOfTapsRequired = 2;
    [tap requireGestureRecognizerToFail:tap2];
    [self addGestureRecognizer:tap2];
    
    UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress)];
    press.delegate = self;
    [self addGestureRecognizer:press];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
    _panGesture = pan;
    
    _cells = @[].mutableCopy;
    
    _background = [[UIImageView alloc] init];
    _background.frame = self.bounds;
    _background.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _blurBackground = [[UIImageView alloc] init];
    _blurBackground.frame = self.bounds;
    _blurBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _contentView = [[UIView alloc] init];
    _contentView.frame = self.bounds;
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.frame = CGRectMake(-kPadding/2, 0, self.width + kPadding, self.height);
    _scrollView.delegate = self;
    _scrollView.scrollsToTop = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.alwaysBounceHorizontal = groupItems.count > 1;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.autoresizingMask =  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.delaysContentTouches = NO;
    _scrollView.canCancelContentTouches = YES;
    
    _pager = [[UIPageControl alloc] init];
    _pager.hidesForSinglePage = YES;
    _pager.userInteractionEnabled = NO;
    _pager.width = self.width - 36;
    _pager.height = 30;
    _pager.center = CGPointMake(self.width/2, self.height - 18);
    _pager.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    [self addSubview:_background];
    [self addSubview:_blurBackground];
    [self addSubview:_contentView];
    [_contentView addSubview:_scrollView];
    [_contentView addSubview:_pager];
    
    return self;
}

- (void)presentFromImageView:(UIView *)fromView toContainer:(UIView *)toContainer animated:(BOOL)animated completion:(void (^)())completion{
    if (!toContainer) {
        return;
    }
    
    _fromView = fromView;
    _toContainerView = toContainer;
    
    NSInteger page = 0;
    for (NSUInteger i = 0; i < self.groupItems.count; i++) {
        if (fromView == self.groupItems[i].thumbView) {
            page = i;
            break;
        }
    }
    
    _fromItemIndex = page;
    
    _snapshotImage = [_toContainerView snapshotImageAfterScreenUpdates:NO];
    BOOL fromViewHidden = fromView.hidden;
    fromView.hidden = YES;
    _snapshorImageHideFromView = [_toContainerView snapshotImage];
    fromView.hidden = fromViewHidden;
    
    _background.image = _snapshorImageHideFromView;
    
    if (_blurEffectBackground) {
        _blurBackground.image = [_snapshorImageHideFromView imageByBlurDark];
    }else{
        _blurBackground.image = [UIImage imageWithColor:[UIColor blackColor]];
    }
    
    self.size = _toContainerView.size;
    self.blurBackground.alpha = 0.0;
    self.pager.alpha = 0.0;
    self.pager.numberOfPages = _groupItems.count;
    self.pager.currentPage = page;
    
    [_toContainerView addSubview:self];
    
    
    _scrollView.contentSize = CGSizeMake(_scrollView.width * _groupItems.count, _scrollView.height);
    [_scrollView scrollRectToVisible:CGRectMake(_scrollView.width * page, 0, _scrollView.width, _scrollView.height) animated:NO];
    [self scrollViewDidScroll:_scrollView];
    
    [UIView setAnimationsEnabled:YES];
    _fromNavigationBarHidden = [UIApplication sharedApplication].statusBarHidden;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:animated ? UIStatusBarAnimationFade : UIStatusBarAnimationNone];
    
    YYPhotoGroupCell * cell = [self cellForPage:self.currentPage];
    YYPhotoGroupItem * item = _groupItems[self.currentPage];
    
    if (!item.thumbClippedToTop) {
        NSString *imageKey = [[SDWebImageManager sharedManager] cacheKeyForURL:item.largeImageURL];
        if ([[SDWebImageManager sharedManager].imageCache imageFromMemoryCacheForKey:imageKey]) {
            cell.item = item;
        }
    }
    
    if (!cell.item){
        cell.imageView.image = item.thumbImage;
        [cell resizeSubviewSize];
    }
    
    if (item.thumbClippedToTop) {
        CGRect fromFrame = [_fromView convertRect:_fromView.bounds toView:cell];
        CGRect originFrame = cell.imageContainerView.frame;
        CGFloat scale = fromView.size.width / cell.imageContainerView.width;
        
        cell.imageContainerView.centerX = CGRectGetMaxX(fromFrame);
        cell.imageContainerView.height = fromFrame.size.height / scale;
        [cell.imageContainerView.layer setValue:@(scale) forKey:@"transform.scale"];
        cell.imageContainerView.centerY = CGRectGetMaxY(fromFrame);
        
        float oneTime = animated ? 0.25 : 0;
        [UIView animateWithDuration:oneTime delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
            _blurBackground.alpha = 1;
        } completion:nil ];
        
        _scrollView.userInteractionEnabled = NO;
        
        [UIView animateWithDuration:oneTime delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [cell.imageContainerView.layer setValue:@1 forKey:@"transform.scale"];
            cell.imageContainerView.frame = originFrame;
            _pager.alpha = 1;
        } completion:^(BOOL finished) {
            _isPresented = YES;
            [self scrollViewDidScroll:_scrollView];
            _scrollView.userInteractionEnabled = YES;
            [self hidePager];
            if (completion) {
                completion();
            }
        }];
        
    }else{
        CGRect fromFrame = [_fromView convertRect:_fromView.bounds toView:cell.imageContainerView];
        cell.imageContainerView.clipsToBounds = NO;
        cell.imageView.frame = fromFrame;
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        float oneTime = animated ? 0.18 : 0;
        [UIView animateWithDuration:oneTime *2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
            _blurBackground.alpha = 1;
        } completion:^(BOOL finished) {
            
        }];
        _scrollView.userInteractionEnabled = NO;
        [UIView animateWithDuration:oneTime delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
            cell.imageView.frame = cell.imageContainerView.bounds;
            [cell.imageView.layer setValue:@(1.01) forKey:@"transform.scale"];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:oneTime delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
                [cell.imageView.layer setValue:@1 forKey:@"transform.scale"];
            } completion:^(BOOL finished) {
                cell.imageContainerView.clipsToBounds = YES;
                _isPresented = YES;
                [self scrollViewDidScroll:_scrollView];
                _scrollView.userInteractionEnabled = YES;
                [self hidePager];
                if (completion) {
                    completion();
                }
            }];
        }];
        
    }
}

- (void)dismissAnimationed:(BOOL)animated completion:(void(^)())completion{
    [UIView setAnimationsEnabled:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:_fromNavigationBarHidden withAnimation:animated ? UIStatusBarAnimationFade : UIStatusBarAnimationNone];
    NSInteger currentPage = self.currentPage;
    YYPhotoGroupCell * cell = [self cellForPage:currentPage];
    YYPhotoGroupItem * item = _groupItems[currentPage];
    
    UIView *fromView = nil;
    if (_fromItemIndex == currentPage) {
        fromView = _fromView;
    }else{
        fromView = item.thumbView;
    }
    
    [self cancelAllImageLoad];
    _isPresented = NO;
    BOOL isFromImageClipped = fromView.layer.contentsRect.size.height < 1;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    if (isFromImageClipped) {
        CGRect frame = cell.imageContainerView.frame;
        cell.imageContainerView.layer.anchorPoint = CGPointMake(0.5, 0);
        cell.imageContainerView.frame = frame;
    }
    cell.progressLayer.hidden = YES;
    [CATransaction commit];
    
    if (fromView == nil) {
        self.background.image = _snapshotImage;
        [UIView animateWithDuration:animated ? 0.25 : 0 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
            self.alpha = 0.0;
            [self.scrollView.layer setValue:@(0.95) forKey:@"transform.scale"];
            self.scrollView.alpha = 0;
            self.pager.alpha = 0;
            self.blurBackground.alpha = 0;
        } completion:^(BOOL finished) {
            [self.scrollView.layer setValue:@1 forKey:@"transform.scale"];
            [self removeFromSuperview];
            [self cancelAllImageLoad];
            if (completion) {
                completion();
            }
        }];
        return;
    }
    
    if (_fromItemIndex !=  currentPage) {
        _background.image = _snapshotImage;
        CATransition *transition = [CATransition animation];
        transition.duration = 0.25;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        transition.type = kCATransitionFade;
        [_background.layer addAnimation:transition forKey:yykitFadeAnimationKey];
    }else{
        _background.image = _snapshorImageHideFromView;
    }
    
    if (isFromImageClipped) {
        CGPoint off = cell.contentOffset;
        off.y = 0 - cell.contentInset.top;
        [cell setContentOffset:off animated:animated];
    }
    
    [UIView animateWithDuration:animated ? 0.2 : 0 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
        _pager.alpha = 0.0;
        _blurBackground.alpha = 0.0;
        if (isFromImageClipped) {
            CGRect fromFrame = [fromView convertRect:fromView.bounds toView:cell];
            CGFloat scale = fromView.width / cell.imageContainerView.width * cell.zoomScale;
            CGFloat height = fromFrame.size.height / fromFrame.size.width*cell.imageContainerView.width;
            if (isnan(height)) {
                height = cell.imageContainerView.height;
            }
            
            cell.imageContainerView.height = height;
            cell.imageContainerView.center = CGPointMake(CGRectGetMidX(fromFrame), CGRectGetMidY(fromFrame));
            [cell.imageContainerView.layer setValue:@(scale) forKey:@"transform.scale"];
        }else{
            CGRect fromFrame  = [fromView convertRect:fromView.bounds toView:cell.imageContainerView];
            cell.imageContainerView.clipsToBounds = NO;
            cell.imageView.contentMode = fromView.contentMode;
            cell.imageView.frame = fromFrame;
        }
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:animated ? 0.15 : 0 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            cell.imageContainerView.layer.anchorPoint = CGPointMake(0.5, 0.5);
            [self removeFromSuperview];
            if (completion) {
                completion();
            }
        }];
    }];
}

- (void)dismiss{
    [self dismissAnimationed:YES completion:nil];
}

- (void)cancelAllImageLoad{
    [_cells enumerateObjectsUsingBlock:^(YYPhotoGroupCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.imageView sd_cancelCurrentImageLoad];
    }];
}

#pragma mark -- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self updateCellsForReuse];
    
    CGFloat floatPage = _scrollView.contentOffset.x / _scrollView.width;
    NSInteger page = _scrollView.contentOffset.x / _scrollView.width + 0.5;
    for (NSInteger i = page - 1; i <= page + 1; i++) {
        if (i>=0 && i < self.groupItems.count) {
            YYPhotoGroupCell * cell = [self cellForPage:i];
            if (!cell) {
                YYPhotoGroupCell * cell = [self dequeueReusableCell];
                cell.page = i;
                cell.left = (self.width + kPadding)*i + kPadding/2;
                if (_isPresented) {
                    cell.item = self.groupItems[i];
                }
                [self.scrollView addSubview:cell];
            }else{
                if (_isPresented && !cell.item) {
                    cell.item = self.groupItems[i];
                }
            }
        }
    }
    
    NSInteger intPage = floatPage + 0.5;
    intPage = intPage < 0 ? 0 : (intPage > self.groupItems.count ? self.groupItems.count - 1 : intPage);
    _pager.currentPage = intPage;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
        _pager.alpha = 1;
    } completion:nil];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        [self hidePager];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self hidePager];
}

- (void)updateCellsForReuse{
    for (YYPhotoGroupCell *cell in _cells) {
        if (cell.superview) {
            if (cell.left > _scrollView.contentOffset.x + 2*_scrollView.width || cell.right < _scrollView.contentOffset.x - _scrollView.width) {
                [cell removeFromSuperview];
                cell.page = -1;
                cell.item = nil;
            }
        }
    }
}

- (YYPhotoGroupCell *)cellForPage:(NSInteger)page{
    for (YYPhotoGroupCell *cell in _cells) {
        if (cell.page == page) {
            return cell;
        }
    }
    return nil;
}

- (YYPhotoGroupCell *)dequeueReusableCell{
    YYPhotoGroupCell * cell = nil;
    for (cell in _cells) {
        if (!cell.superview) {
            return cell;
        }
    }
    
    cell = [YYPhotoGroupCell new];
    cell.frame = self.bounds;
    cell.imageContainerView.frame = self.bounds;
    cell.imageView.frame = cell.bounds;
    cell.page = -1;
    cell.item = nil;
    [_cells addObject:cell];
    return cell;
}

- (void)hidePager{
    [UIView animateWithDuration:0.3 delay:0.8 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut animations:^{
        _pager.alpha = 0;
    } completion:nil];
}

- (NSInteger)currentPage{
    NSInteger page = _scrollView.contentOffset.x / _scrollView.width + 0.5;
    if (page >= _groupItems.count) {
        page = (NSInteger)_groupItems.count - 1;
    }
    if (page < 0) {
        page = 0;
    }
    return page;
}

- (void)showHUD:(NSString *)msg{
    if (!msg.length) {
        return;
    }
    
    UIFont *font = [UIFont systemFontOfSize:17];
    CGSize size = [msg sizeForFont:font size:CGSizeMake(200, 200) mode:NSLineBreakByCharWrapping];
    UILabel *label = [UILabel new];
    label.size = CGSizePixelCeil(size);
    label.font = font;
    label.text = msg;
    label.textColor = [UIColor whiteColor];
    label.numberOfLines = 0;
    
    UIView *hud = [UIView new];
    hud.size = CGSizeMake(label.width + 20, label.height + 20);
    hud.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.650];
    hud.clipsToBounds = YES;
    hud.layer.cornerRadius = 8;
    
    label.center = CGPointMake(hud.width/2, hud.height/2);
    [hud addSubview:label];
    
    hud.center = CGPointMake(self.width/2, self.height/2);
    hud.alpha = 0;
    [self addSubview:hud];
    
    [UIView animateWithDuration:0.4 animations:^{
       hud.alpha = 1;
    }];
    double delayInSeconds = 1.5;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.4 animations:^{
            hud.alpha = 0;
        } completion:^(BOOL finished) {
            [hud removeFromSuperview];
        }];
    });
    
}

- (void)doubleTap:(UITapGestureRecognizer *)g {
    if (!_isPresented) {
        return;
    }
    YYPhotoGroupCell *tile = [self cellForPage:self.currentPage];
    if (tile) {
        if (tile.zoomScale > 1) {
            [tile setZoomScale:1 animated:YES];
        }else{
            CGPoint touchPoint = [g locationInView:tile.imageView];
            CGFloat newZoomScale = tile.maximumZoomScale;
            CGFloat xsize = self.width / newZoomScale;
            CGFloat ysize = self.height / newZoomScale;
            [tile zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
        }
    }
}

- (void)longPress{
    if (!_isPresented) {
        return;
    }
    YYPhotoGroupCell *tile = [self cellForPage:self.currentPage];
    if (!tile.imageView.image) {
        return;
    }
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:@[tile.imageView.image] applicationActivities:nil];
    if ([activityViewController respondsToSelector:@selector(popoverPresentationController)]) {
        activityViewController.popoverPresentationController.sourceView = self;
    }
    
    UIViewController *toVC = self.toContainerView.viewController;
    if (!toVC) toVC = self.viewController;
    [toVC presentViewController:activityViewController animated:YES completion:nil];
}

- (void)pan:(UIPanGestureRecognizer *)g{
    switch (g.state) {
        case UIGestureRecognizerStateBegan:{
            if (_isPresented) {
                _panGestureBeginPoint = [g locationInView:self];
            }else{
                _panGestureBeginPoint = CGPointZero;
            }
        }
        break;
        
        case UIGestureRecognizerStateChanged:{
            if ((_panGestureBeginPoint.x == 0 && _panGestureBeginPoint.y == 0)) {
                return;
            }
            CGPoint p = [g locationInView:self];
            CGFloat deltaY = p.y - _panGestureBeginPoint.y;
            _scrollView.top = deltaY;
            
            CGFloat alphaDelta = 160;
            CGFloat alpha = (alphaDelta - fabs(deltaY) + 50) / alphaDelta;
            
            alpha = YY_CLAMP(alpha, 0, 1);
            [UIView animateKeyframesWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveLinear animations:^{
                _blurBackground.alpha = alpha;
                _pager.alpha = alpha;
            } completion:^(BOOL finished) {
                
            }];
        }
        break;
        
        case UIGestureRecognizerStateEnded:{
            if (_panGestureBeginPoint.x == 0 && _panGestureBeginPoint.y == 0) {
                return;
            }
            
            CGPoint v = [g velocityInView:self];
            CGPoint p = [g locationInView:self];
            CGFloat deltaY = p.y - _panGestureBeginPoint.y;
            if (fabs(v.y)>1000 || fabs(deltaY)>120) {
                [self cancelAllImageLoad];
                _isPresented = NO;
                [[UIApplication sharedApplication] setStatusBarHidden:_fromNavigationBarHidden withAnimation:UIStatusBarAnimationFade];
                BOOL moveToTop = (v.y < -50 || (v.y < 50 && deltaY < 0));
                CGFloat vy = fabs(v.y);
                
                if (vy < 1) {
                    vy = 1;
                }
                
                CGFloat duration = (moveToTop ? _scrollView.bottom : self.height - _scrollView.top) / vy;
                duration *= 0.8;
                duration = YY_CLAMP(duration, 0.05, 0.3);
                [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState animations:^{
                    _blurBackground.alpha = 0;
                    _pager.alpha = 0;
                    if (moveToTop) {
                        _scrollView.bottom = 0;
                    }else{
                        _scrollView.top = self.height;
                    }
                } completion:^(BOOL finished) {
                    [self removeFromSuperview];
                }];
                
                _background.image = _snapshotImage;
                CATransition *transition = [CATransition animation];
                transition.duration = duration;
                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                transition.type = kCATransitionFade;
                [_background.layer addAnimation:transition forKey:@"yykit.fade"];
            }else{
                [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:v.y / 1000 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
                    _scrollView.top = 0;
                    _blurBackground.alpha = 1;
                    _pager.alpha = 1;
                } completion:^(BOOL finished) {
                    
                }];
            }
        }
        break;
        case UIGestureRecognizerStateCancelled:
        {
            _scrollView.top = 0;
            _blurBackground.alpha = 1;
        }
            break;
            
            
        default:
            break;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
