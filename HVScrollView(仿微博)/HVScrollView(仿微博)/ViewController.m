//
//  ViewController.m
//  HVScrollView
//
//  Created by Libo on 17/6/12.
//  Copyright © 2017年 iDress. All rights reserved.
//

#import "ViewController.h"
#import "FirstViewController.h"
#import "SecondViewController.h"
#import "ThirdViewController.h"
#import "FourViewController.h"
#import "SPPageMenu.h"
#import "MyHeaderView.h"
#import "MyTableView.h"

@interface ViewController () <SPPageMenuDelegate,UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) MyTableView *tableView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) MyHeaderView *headerView;

@property (nonatomic, strong) SPPageMenu *pageMenu;

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) CGPoint lastPoint;

@property (nonatomic, assign) BOOL headerScrollViewScrolling;
@property (nonatomic, strong) UIScrollView *childVCScrollView;

@property (nonatomic, assign) BOOL other;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    
    [self.view addSubview:self.tableView];
    
    // 添加4个子控制器
    [self addChildViewController:[[FirstViewController alloc] init]];
    [self addChildViewController:[[SecondViewController alloc] init]];
    [self addChildViewController:[[ThirdViewController alloc] init]];
    [self addChildViewController:[[FourViewController alloc] init]];
    // 先将第一个子控制的view添加到scrollView上去
    [self.scrollView addSubview:self.childViewControllers[0].view];
    
    // 添加头部视图
    self.tableView.tableHeaderView = self.headerView;
    
    // 监听子控制器发出的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subTableViewDidScroll:) name:@"SubTableViewDidScroll" object:nil];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    // 添加悬浮菜单
    [cell.contentView addSubview:self.pageMenu];
    [cell.contentView addSubview:self.scrollView];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kScreenH;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.tableView == scrollView) {
        if (self.childVCScrollView && _childVCScrollView.contentOffset.y > 0) {
            self.tableView.contentOffset = CGPointMake(0, HeaderViewH);
        }
        CGFloat offSetY = scrollView.contentOffset.y;

        if (offSetY < HeaderViewH) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"headerViewToTop" object:nil];
        }
    } else if (scrollView == self.scrollView) {
        
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
 
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        NSInteger index = scrollView.contentOffset.x / scrollView.frame.size.width;
        // 手动滑scrollView,pageMenu会根据传进去的index选中index对应的button
        [self.pageMenu selectButtonAtIndex:index];
    }
}

- (void)subTableViewDidScroll:(NSNotification *)noti {
    UIScrollView *scrollView = noti.object;
    self.childVCScrollView = scrollView;
    if (self.tableView.contentOffset.y < HeaderViewH) {
        scrollView.contentOffset = CGPointZero;
        scrollView.showsVerticalScrollIndicator = NO;
        
    } else {
//        self.tableView.contentOffset = CGPointMake(0, HeaderViewH);
        scrollView.showsVerticalScrollIndicator = YES;
    }
}


- (void)btnAction:(UIButton *)sender {
    NSLog(@"---点击了头视图上的按钮");
}

#pragma mark - SPPageMenuDelegate
- (void)pageMenu:(SPPageMenu *)pageMenu buttonClickedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    _selectedIndex = toIndex;
    // 如果上一次点击的button下标与当前点击的buton下标之差大于等于2,说明跨界面移动了,此时不动画.
    if (labs(toIndex - fromIndex) >= 2) {
        [self.scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width * toIndex, 0) animated:NO];
    } else {
        [self.scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width * toIndex, 0) animated:YES];
    }
    
    UIViewController *targetViewController = self.childViewControllers[toIndex];
    // 如果已经加载过，就不再加载
    if ([targetViewController isViewLoaded]) return;
    
    targetViewController.view.frame = CGRectMake(kScreenW*toIndex, 0, kScreenW, kScreenH);
    UIScrollView *s = targetViewController.view.subviews[0];
    CGPoint contentOffset = s.contentOffset;
    if (contentOffset.y >= HeaderViewH) {
        contentOffset.y = HeaderViewH;
    }
    s.contentOffset = contentOffset;
    [self.scrollView addSubview:targetViewController.view];
}

- (UIScrollView *)scrollView {
    
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.frame = CGRectMake(0, PageMenuH, kScreenW, kScreenH);
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.contentSize = CGSizeMake(kScreenW*4, 0);
        _scrollView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    }
    return _scrollView;
}

- (MyTableView *)tableView {
    
    if (!_tableView) {
        _tableView = [[MyTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.showsVerticalScrollIndicator = NO;
        //_tableView.sectionHeaderHeight = PageMenuH;
    }
    return _tableView;
}


- (MyHeaderView *)headerView {
    
    if (!_headerView) {
        _headerView = [[MyHeaderView alloc] init];
        _headerView.frame = CGRectMake(0, 0, kScreenW, HeaderViewH);
        _headerView.backgroundColor = [UIColor clearColor];
        _headerView.layer.masksToBounds = NO;
        
        UIView *contentView = [[UIView alloc] initWithFrame:_headerView.bounds];
        contentView.backgroundColor = [UIColor greenColor];
        [_headerView addSubview:contentView];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 60, 30);
        btn.center = CGPointMake(_headerView.center.x, _headerView.center.y);
        btn.backgroundColor = [UIColor yellowColor];
        [btn setTitle:@"点我" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:btn];

    }
    return _headerView;
}


- (SPPageMenu *)pageMenu {
    
    if (!_pageMenu) {
        _pageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(0, 0, kScreenW, PageMenuH) array:@[@"第一个",@"第二个",@"第三个",@"第四个"]];
        _pageMenu.backgroundColor = [UIColor whiteColor];
        _pageMenu.delegate = self;
        _pageMenu.buttonFont = [UIFont systemFontOfSize:16];
        _pageMenu.selectedTitleColor = [UIColor blackColor];
        _pageMenu.unSelectedTitleColor = [UIColor colorWithWhite:0 alpha:0.6];
        _pageMenu.trackerColor = [UIColor orangeColor];
        _pageMenu.firstButtonX = 15;
        _pageMenu.allowBeyondScreen = NO;
        _pageMenu.equalWidths = NO;
        
    }
    return _pageMenu;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
