//
//  SecondViewController.m
//  YYPhotoGroupView
//
//  Created by 赵铭 on 2017/9/6.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "SecondViewController.h"
#import "CustomTableViewCell.h"
#import "CellModel.h"
#import "YYPhotoGroupView.h"
#define image1 @"http://ww3.sinaimg.cn/wap720/648ac377gw1evvb5q5xw9j20k50qo7ar.jpg"
#define image2 @"http://ww4.sinaimg.cn/wap720/648ac377gw1evvb64986kj20ke0qo79q.jpg"
#define image3 @"http://ww3.sinaimg.cn/wap720/648ac377gw1evvb638ctyj20jg0qon80.jpg"
#define image4 @"http://ww2.sinaimg.cn/wap720/648ac377gw1evvb5p5racj20kg0p07eo.jpg"
#define image5 @"http://ww3.sinaimg.cn/wap720/648ac377gw1evvb61yq07j20kg0q8wqx.jpg"
#define image6 @"http://ww1.sinaimg.cn/wap720/648ac377gw1evvb671w2nj20kg0pugvo.jpg"
#define image7 @"http://ww2.sinaimg.cn/wap720/648ac377gw1evvb6917s9j20kg0qdwkm.jpg"
#define image8 @"http://ww1.sinaimg.cn/wap720/648ac377gw1evvb69y6z0j20kg0ox0y5.jpg"
#define image9 @"http://ww1.sinaimg.cn/wap720/648ac377gw1evvb6bwk53j20kg0o7q8n.jpg"
@interface SecondViewController ()<CustomTableViewCellDelegate>
@property (nonatomic, strong) NSMutableArray * datasource;
@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _datasource = @[].mutableCopy;
    CellModel * model1 = [CellModel new];
    model1.urls = @[image1, image2, image3, image4, image5, image6, image7, image8, image9];
    model1.largeUrls = @[image1, image2, image3, image4, image5, image6, image7, image8, image9];
    model1.title = @"9";
    [_datasource addObject:model1];
    
    CellModel * model2 = [CellModel new];
    model2.urls = @[image1, image2, image3];
    model2.largeUrls = @[image1, image2, image3, ];
    [_datasource addObject:model2];
    model2.title = @"3";

    CellModel * model3 = [CellModel new];
    model3.urls = @[image1, image2, image3, image4, image5, image6, ];
    model3.largeUrls = @[image1, image2, image3, image4, image5, image6];
    [_datasource addObject:model3];
    model3.title = @"6";

    CellModel * model4 = [CellModel new];
    model4.urls = @[image1, image2, image3, image4, image5, ];
    model4.largeUrls = @[image1, image2, image3, image4, image5];
    [_datasource addObject:model4];
    model4.title = @"5";
    [self.tableView reloadData];

    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return _datasource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.delegate = self;
    }
    CellModel *model = _datasource[indexPath.row];
    cell.model = model;
    // Configure the cell...
    return cell;
}



#pragma mark -- CustomTableViewCellDelegate
- (void)cell:(CustomTableViewCell *)cell didTapViewIndex:(NSInteger)idx{
    CellModel *model = cell.model;
    UIView *originalView = [cell viewWithTag:1000 + idx];
    NSMutableArray * items = @[].mutableCopy;
    for (int i = 0; i < model.largeUrls.count; i++) {
        if(i >= 9) return;
        YYPhotoGroupItem * item = [YYPhotoGroupItem new];
        item.thumbView = cell.imageViews[i];
        item.largeImageURL = [NSURL URLWithString:model.largeUrls[i]];
        [items addObject:item];
    }
    YYPhotoGroupView * v = [[YYPhotoGroupView alloc] initWithGroupItems:items];
    [v presentFromImageView:originalView toContainer:self.navigationController.view animated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CellModel *model = _datasource[indexPath.row];
    return [CustomTableViewCell heightForCell:model];
    
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
