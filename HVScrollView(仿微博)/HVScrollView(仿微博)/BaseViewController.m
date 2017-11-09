//
//  BaseViewController.m
//  HVScrollView
//
//  Created by Libo on 17/6/13.
//  Copyright © 2017年 iDress. All rights reserved.
//

// ----------- 悬浮菜单SPPageMenu的框架github地址:https://github.com/SPStore/SPPageMenu ---------
// ----------- 本demo地址:https://github.com/SPStore/HVScrollView ----------

#import "BaseViewController.h"

@interface BaseViewController () <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) NSInteger rowCount;
@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageTitleViewToTop) name:@"headerViewToTop" object:nil];

    [self.view addSubview:self.tableView];
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        // 上拉加载
        [self upPullLoadMoreData];
    }];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (void)pageTitleViewToTop {
    self.tableView.contentOffset = CGPointZero;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.tableView.frame = CGRectMake(0, 0, kScreenW, kScreenH-insert);
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // 滚动时发出通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SubTableViewDidScroll" object:scrollView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"cell_2";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"第%zd行",indexPath.row];
    return cell;
}

- (UITableView *)tableView {
    
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH-PageMenuH-NaviH) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.showsVerticalScrollIndicator = NO;
        
    }
    return _tableView;
}


@end
