//
//  FirstViewController.m
//  HVScrollView
//
//  Created by Libo on 17/6/12.
//  Copyright © 2017年 iDress. All rights reserved.
//

#import "BaseViewController.h"
#import "MJRefresh.h"

@interface BaseViewController ()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) HeaderContentView *placeholderHeaderView;
@property (nonatomic, assign) NSInteger rowCount;
@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.rowCount = 20;

    self.tableView.tableHeaderView = self.placeholderHeaderView;
    [self.view addSubview:self.tableView];
    self.scrollView = self.tableView;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 下拉刷新
        [self downPullUpdateData];
    }];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        // 上拉加载
        [self upPullLoadMoreData];
    }];
}

// 下拉刷新
- (void)downPullUpdateData {
    // 模拟网络请求，1秒后结束刷新
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.rowCount = 20;
        [self.tableView.mj_header endRefreshing];
    });
}

// 上拉加载
- (void)upPullLoadMoreData {
    self.rowCount = 30;
    [self.tableView reloadData];
    // 模拟网络请求，1秒后结束刷新
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.rowCount = 20;
        [self.tableView.mj_footer endRefreshing];
    });
}

- (void)setHeaderView:(MyHeaderView *)headerView {
    _headerView = headerView;
    CGRect headerFrame = self.headerView.frame;
    // 修正origin
    headerFrame.origin.y = 0;
    headerFrame.origin.x = 0;
    self.headerView.frame = headerFrame;
    [self.placeholderHeaderView addSubview:headerView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetDifference = scrollView.contentOffset.y - self.lastContentOffset.y;
    // 滚动时发出通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SubScrollViewDidScroll" object:nil userInfo:@{@"scrollingScrollView":scrollView,@"offsetDifference":@(offsetDifference)}];
    self.lastContentOffset = scrollView.contentOffset;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.lastContentOffset = scrollView.contentOffset;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"cell_1";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"第%zd行",indexPath.row];
    return cell;
}

- (UITableView *)tableView {
    
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH-64) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.layer.masksToBounds = NO;
    }
    return _tableView;
}

- (HeaderContentView *)placeholderHeaderView {
    
    if (!_placeholderHeaderView) {
        _placeholderHeaderView = [[HeaderContentView alloc] init];
        _placeholderHeaderView.frame = CGRectMake(0, 0, kScreenW, 240);
    }
    return _placeholderHeaderView;
}


@end
