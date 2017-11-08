//
//  BaseViewController.m
//  HVScrollView
//
//  Created by Libo on 17/6/13.
//  Copyright © 2017年 iDress. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController () <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageTitleViewToTop) name:@"headerViewToTop" object:nil];

    [self.view addSubview:self.tableView];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)pageTitleViewToTop {
    self.tableView.contentOffset = CGPointZero;
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
