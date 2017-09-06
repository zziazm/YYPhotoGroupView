//
//  ViewController.m
//  YYPhotoGroupView
//
//  Created by 赵铭 on 2017/9/1.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "ViewController.h"
#import "YYPhotoGroupView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#define image1 @"http://ww3.sinaimg.cn/wap720/648ac377gw1evvb5q5xw9j20k50qo7ar.jpg"
#define image2 @"http://ww4.sinaimg.cn/wap720/648ac377gw1evvb64986kj20ke0qo79q.jpg"
#define image3 @"http://ww3.sinaimg.cn/wap720/648ac377gw1evvb638ctyj20jg0qon80.jpg"
#define image4 @"http://ww2.sinaimg.cn/wap720/648ac377gw1evvb5p5racj20kg0p07eo.jpg"
#define image5 @"http://ww3.sinaimg.cn/wap720/648ac377gw1evvb61yq07j20kg0q8wqx.jpg"
#define image6 @"http://ww1.sinaimg.cn/wap720/648ac377gw1evvb671w2nj20kg0pugvo.jpg"
#define image7 @"http://ww2.sinaimg.cn/wap720/648ac377gw1evvb6917s9j20kg0qdwkm.jpg"
#define image8 @"http://ww1.sinaimg.cn/wap720/648ac377gw1evvb69y6z0j20kg0ox0y5.jpg"
#define image9 @"http://ww1.sinaimg.cn/wap720/648ac377gw1evvb6bwk53j20kg0o7q8n.jpg"

#define largeImageWidth 720
#define largeImageHeigth 900


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UIImageView *imageView3;
@property (weak, nonatomic) IBOutlet UIImageView *imageView4;
@property (weak, nonatomic) IBOutlet UIImageView *imageView5;
@property (nonatomic, strong) NSMutableArray * imageUrls;
@property (nonatomic, strong) NSArray * imageViews;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _imageViews = @[_imageView1, _imageView2, _imageView3, _imageView4, _imageView5];
    _imageUrls = @[image1, image2, image3, image4, image5].mutableCopy;
    
    for (int i = 0; i < 5; i++) {
        UIImageView * iv = _imageViews[i];
        [iv sd_setImageWithURL:[NSURL URLWithString:_imageUrls[i]] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            
        }];
    }
////    [NSJSONSerialization dataWithJSONObject:nil options:nil error:nil];
//    NSMutableURLRequest * r = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]];
//    r.HTTPMethod = @"PUT";
//    [NSURLConnection sendAsynchronousRequest:r queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
//        if (connectionError) {
//            NSLog(@"%@", connectionError);
//        }
//        
//       NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//        NSLog(@"%@", dic);
//        
//        
//    }];
        // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)image1Tap:(id)sender {
    [self prsentBrowser:0];
}
- (IBAction)image2Tap:(id)sender {
    [self prsentBrowser:1];

}
- (IBAction)image3Tap:(id)sender {
    [self prsentBrowser:2];

}
- (IBAction)image4Tap:(id)sender {
    [self prsentBrowser:3];

}
- (IBAction)image5Tap:(id)sender {
    [self prsentBrowser:4];

}

- (void)prsentBrowser:(NSInteger)idx{
    UIView *fromeView = nil;
    NSMutableArray * items = @[].mutableCopy;
    for (int i = 0; i < 5; i++) {
        UIImageView * iv = [self.view viewWithTag:1000 + i ];
        YYPhotoGroupItem * item = [YYPhotoGroupItem new];
        item.thumbView = iv;
        item.largeImageURL = [NSURL URLWithString:_imageUrls[i]];
        [items addObject:item];
        if (i == idx) {
            fromeView = iv;
        }
    }
    YYPhotoGroupView *v = [[YYPhotoGroupView alloc] initWithGroupItems:items];
    [v presentFromImageView:fromeView toContainer:self.navigationController.view animated:YES completion:nil];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
