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

#define PageMenuH 40
#define HeaderViewH 200

@interface ViewController () <SPPageMenuDelegate,UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) MyHeaderView *headerView;

@property (nonatomic, strong) SPPageMenu *pageMenu;

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) CGPoint lastPoint;

@property (nonatomic, assign) BOOL headerScrollViewScrolling;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    // 添加一个全屏的scrollView
    [self.view addSubview:self.scrollView];
    
    // 添加4个子控制器
    [self addChildViewController:[[FirstViewController alloc] init]];
    [self addChildViewController:[[SecondViewController alloc] init]];
    [self addChildViewController:[[ThirdViewController alloc] init]];
    [self addChildViewController:[[FourViewController alloc] init]];
    // 先将第一个子控制的view添加到scrollView上去
    [self.scrollView addSubview:self.childViewControllers[0].view];
    
    // 添加头部视图
    [self.view addSubview:self.headerView];
    // 添加悬浮菜单
    [self.view addSubview:self.pageMenu];
    
    // 监听子控制器发出的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subTableViewDidScroll:) name:@"SubTableViewDidScroll" object:nil];
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == self.headerView) {
        self.headerScrollViewScrolling = YES;
    } }

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.headerView) {
        BaseViewController *currentVc = self.childViewControllers[_selectedIndex];
        if ([currentVc isViewLoaded]) {
            CGPoint offset = currentVc.scrollView.contentOffset;
            offset.y = scrollView.contentOffset.y;
            currentVc.scrollView.contentOffset = offset;
            
            CGRect pageMenuFrame = self.pageMenu.frame;
            pageMenuFrame.origin.y = -scrollView.contentOffset.y+HeaderViewH;
            if (pageMenuFrame.origin.y <= 0) {
                pageMenuFrame.origin.y = 0;
            }
            self.pageMenu.frame = pageMenuFrame;
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == self.headerView) {
        self.headerScrollViewScrolling = NO;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.headerView) {
        self.headerScrollViewScrolling = NO;
    } else if (scrollView == self.scrollView) {
        NSInteger index = scrollView.contentOffset.x / scrollView.frame.size.width;
        // 手动滑scrollView,pageMenu会根据传进去的index选中index对应的button
        [self.pageMenu selectButtonAtIndex:index];
    }
}

- (void)subTableViewDidScroll:(NSNotification *)noti {
    // 取出当前正在滑动的tableView
    UIScrollView *scrollingScrollView = noti.object;
    if ([self isVisibleScrollView:scrollingScrollView] && !self.headerScrollViewScrolling) {
        // 让头部视图跟随scrollView滚动
        CGPoint headerViewOffset = self.headerView.contentOffset;
        headerViewOffset.y = scrollingScrollView.contentOffset.y;
        self.headerView.contentOffset = headerViewOffset;
        // 让悬浮菜单跟随scrollView滑动
        CGRect pageMenuFrame = self.pageMenu.frame;
        pageMenuFrame.origin.y = -(scrollingScrollView.contentOffset.y-HeaderViewH);
        
        if (pageMenuFrame.origin.y <= 0) {
            pageMenuFrame.origin.y = 0;
        }
        self.pageMenu.frame = pageMenuFrame;
     
        // 让其余控制器的scrollView跟随当前正在滑动的scrollView滑动
        [self followScrollingScrollView:scrollingScrollView];
    }
    
}

- (void)followScrollingScrollView:(UIScrollView *)scrollingScrollView {
    BaseViewController *baseVc = nil;
    for (int i = 0; i < self.childViewControllers.count; i++) {
        
        baseVc = self.childViewControllers[i];
        if (baseVc.scrollView == scrollingScrollView || (baseVc.scrollView.contentOffset.y >= 200 && self.pageMenu.frame.origin.y <= 0)) {
            continue;
        }
        CGPoint contentOffSet = baseVc.scrollView.contentOffset;
        contentOffSet.y = scrollingScrollView.contentOffset.y;
        if (contentOffSet.y >= 200) {
            contentOffSet.y = 200;
        }
        baseVc.scrollView.contentOffset = contentOffSet;
    }
}

- (BOOL)isVisibleScrollView:(UIScrollView *)scrollView {
    
    CGRect rectInScrollView = [scrollView convertRect:scrollView.bounds toView:self.scrollView];
    if (fabs(rectInScrollView.origin.x/kScreenW) == _selectedIndex) {
        return YES;
    } else {
        return NO;
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
    contentOffset.y = self.headerView.contentOffset.y;
    if (contentOffset.y >= HeaderViewH) {
        contentOffset.y = HeaderViewH;
    }
    s.contentOffset = contentOffset;
    [self.scrollView addSubview:targetViewController.view];
}

- (UIScrollView *)scrollView {
    
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.frame = CGRectMake(0, 0, kScreenW, kScreenH-64);
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.contentSize = CGSizeMake(kScreenW*4, 0);
        _scrollView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    }
    return _scrollView;
}


- (MyHeaderView *)headerView {
    
    if (!_headerView) {
        _headerView = [[MyHeaderView alloc] init];
        _headerView.frame = CGRectMake(0, 0, kScreenW, HeaderViewH);
        _headerView.backgroundColor = [UIColor clearColor];
        _headerView.alwaysBounceVertical = YES;
        _headerView.delegate = self;
        _headerView.contentSize = CGSizeMake(0, kScreenH);
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
        _pageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(0, CGRectGetMaxY(self.headerView.frame), kScreenW, PageMenuH) array:@[@"第一个",@"第二个",@"第三个",@"第四个"]];
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
