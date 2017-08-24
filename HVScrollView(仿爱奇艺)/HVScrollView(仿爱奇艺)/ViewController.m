//
//  ViewController.m
//  HVScrollView
//
//  Created by Libo on 17/6/14.
//  Copyright © 2017年 iDress. All rights reserved.
//

#import "ViewController.h"
#import "MyHeaderView.h"
#import "SPPageMenu.h"

#import "FirstViewController.h"
#import "SecondViewController.h"
#import "ThirdViewController.h"
#import "FourViewController.h"

#define kHeaderViewH 200
#define kPageMenuH 40
#define kNaviH 0

@interface ViewController () <SPPageMenuDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) MyHeaderView *headerView;
@property (nonatomic, strong) SPPageMenu *pageMenu;

@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, assign) CGFloat lastPageMenuY;

@property (nonatomic, assign) CGPoint lastPoint;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.navigationController.navigationBar.hidden = YES;
    self.navigationController.navigationBar.translucent = NO;
    //self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.lastPageMenuY = kHeaderViewH;
    
    // 添加一个全屏的scrollView
    [self.view addSubview:self.scrollView];
    
    // 添加头部视图
    //[self.view addSubview:self.headerView];
    
    // 添加悬浮菜单
    [self.view addSubview:self.pageMenu];
    
    // 添加4个子控制器
    FirstViewController *firstVc = [[FirstViewController alloc] init];
    [self addChildViewController:firstVc];
    // 先把headerView添加到第一个子控制器上
    firstVc.headerView = self.headerView;
    SecondViewController *secondVc = [[SecondViewController alloc] init];
    [self addChildViewController:secondVc];
    [self addChildViewController:[[ThirdViewController alloc] init]];
    [self addChildViewController:[[FourViewController alloc] init]];
    
    // 先将第一个子控制的view添加到scrollView上去
    [self.scrollView addSubview:self.childViewControllers[0].view];
    
    // 监听子控制器发出的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subScrollViewDidScroll:) name:@"SubScrollViewDidScroll" object:nil];
}

// 本类中的scrollView的代理方法(目前本类只有一个self.scrollView)
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    if (scrollView == self.scrollView) {
        // 将当前控制器的view带到最前面去，这是为了防止下一个控制器的view挡住了头部
        BaseViewController *baseVc = self.childViewControllers[_selectedIndex];
        if ([baseVc isViewLoaded]) {
            [self.scrollView bringSubviewToFront:baseVc.view];
        }
        // 横向切换tableView时头部不要跟随tableView偏移
        CGRect headerFrame = self.headerView.frame;
        headerFrame.origin.x = scrollView.contentOffset.x-kScreenW*_selectedIndex;
        self.headerView.frame = headerFrame;
        
        [self configerHeaderY];
        
        // 如果scrollView的内容很少，在屏幕范围内，则自动回落
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (baseVc.scrollView.contentSize.height < kScreenH && [baseVc isViewLoaded]) {
                [baseVc.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
            }
        });
        
    }
    
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        NSInteger index = scrollView.contentOffset.x / scrollView.frame.size.width;
        // 手动滑scrollView,pageMenu会根据传进去的index选中index对应的button
        [self.pageMenu selectButtonAtIndex:index];
        
        [self configerHeaderY];
        
        BaseViewController *baseVc = self.childViewControllers[_selectedIndex];
        // 如果scrollView的内容很少，在屏幕范围内，则自动回落
        if (baseVc.scrollView.contentSize.height < kScreenH && [baseVc isViewLoaded]) {
            [baseVc.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        }
    }
}

// 子控制器上的scrollView已经滑动的代理方法所发出的通知方法
- (void)subScrollViewDidScroll:(NSNotification *)noti {

    // 取出当前正在滑动的tableView
    UIScrollView *scrollingScrollView = noti.userInfo[@"scrollingScrollView"];
    CGFloat offsetDifference = [noti.userInfo[@"offsetDifference"] floatValue];
    
    CGFloat distanceY;
    
    // 取出的scrollingScrollView并非是唯一的，当有多个子控制器上的scrollView同时滑动时都会发出通知来到这个方法，所以要过滤
    BaseViewController *baseVc = self.childViewControllers[_selectedIndex];
    
    if (scrollingScrollView == baseVc.scrollView && baseVc.isFirstViewLoaded == NO) {
        // 让悬浮菜单跟随scrollView滑动
        CGRect pageMenuFrame = self.pageMenu.frame;

        if (pageMenuFrame.origin.y >= kNaviH) {
            // 往上移
            if (offsetDifference > 0) {
                
                if (((scrollingScrollView.contentOffset.y+self.pageMenu.frame.origin.y)>=kHeaderViewH) || scrollingScrollView.contentOffset.y < 0) {
                    // 悬浮菜单的y值等于当前正在滑动且显示在屏幕范围内的的scrollView的contentOffset.y的改变量(这是最难的点)
                    pageMenuFrame.origin.y += -offsetDifference;
                    if (pageMenuFrame.origin.y <= kNaviH) {
                        pageMenuFrame.origin.y = kNaviH;
                    }
                    
                }
            } else { // 往下移
                if ((scrollingScrollView.contentOffset.y+self.pageMenu.frame.origin.y)-kNaviH<kHeaderViewH) {
                    pageMenuFrame.origin.y = -scrollingScrollView.contentOffset.y+kHeaderViewH+kNaviH;
                }
            }
        }
        self.pageMenu.frame = pageMenuFrame;
        
        // 配置头视图的y值
        [self configerHeaderY];
        
        // 记录悬浮菜单的y值改变量
        distanceY = pageMenuFrame.origin.y - self.lastPageMenuY;
        self.lastPageMenuY = self.pageMenu.frame.origin.y;
        
        // 让其余控制器的scrollView跟随当前正在滑动的scrollView滑动
        [self followScrollingScrollView:scrollingScrollView distanceY:distanceY];

    }
    baseVc.isFirstViewLoaded = NO;
}

// 所有子控制器上的特定scrollView同时联动
- (void)followScrollingScrollView:(UIScrollView *)scrollingScrollView distanceY:(CGFloat)distanceY{
    BaseViewController *baseVc = nil;
    for (int i = 0; i < self.childViewControllers.count; i++) {
        baseVc = self.childViewControllers[i];
        if (baseVc.scrollView == scrollingScrollView) {
            continue;
        } else {
            // 除去当前正在滑动的 scrollView之外，其余scrollView的改变量等于悬浮菜单的改变量
            CGPoint contentOffSet = baseVc.scrollView.contentOffset;
            contentOffSet.y += -distanceY;
            baseVc.scrollView.contentOffset = contentOffSet;
        }
    }
}

// 此方法是难点
- (void)configerHeaderY {
    // 取出当前子控制器
    BaseViewController *baseVc = self.childViewControllers[_selectedIndex];
    CGRect headerFrame = self.headerView.frame;
    // 将pageMenu的frame转换到当前正在滑动的scrollView上去（这一步很关键）
    CGRect pageMenuFrameInScrollView = [self.pageMenu convertRect:self.pageMenu.bounds toView:baseVc.scrollView];
    // 每个tableView的头视图的y值都等于pageMenu的y值减去头部高度，这是为了保证头部的底部永远跟pageMenu的顶部紧贴
    headerFrame.origin.y = pageMenuFrameInScrollView.origin.y-kHeaderViewH;
    self.headerView.frame = headerFrame;
}

#pragma mark - SPPageMenuDelegate
- (void)pageMenu:(SPPageMenu *)pageMenu buttonClickedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    _selectedIndex = toIndex;
    // 如果上一次点击的button下标与当前点击的buton下标之差大于等于2,说明跨界面移动了,此时不动画.
    if (labs(toIndex - fromIndex) >= 2) {
        // 如果动画为NO,则会立即调用scrollViewDidScroll，scrollViewDidScroll中做了一个很重要的操作：改变每个tableView的头视图的frame，如果先调scrollViewDidScroll,然后继续来到此方法走完剩余代码，走到targetViewController.headerView = self.headerView这一行时，内部把头视图的origin都归0了，所以有时会导致头视图的origin为(0,0)的情况，为了避免这个问题，有一种办法是设置动画为YES，如果有动画，则会把本方法先走完，再去调scrollViewDidScroll,这便不会导致头视图origin为0的情况，但是这里用动画不太好看，所以固定在主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width * toIndex, 0) animated:NO];
        });
    } else {
        [self.scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width * toIndex, 0) animated:YES];
    }
    
    BaseViewController *targetViewController = self.childViewControllers[toIndex];
    targetViewController.headerView = self.headerView;
    // 如果已经加载过，就不再加载
    if ([targetViewController isViewLoaded]) return;
    // 是第一次加载控制器的view，这个属性是为了防止下面的偏移量的改变导致走scrollViewDidScroll
    targetViewController.isFirstViewLoaded = YES;
    
    targetViewController.view.frame = CGRectMake(kScreenW*toIndex, 0, kScreenW, kScreenH);
    UIScrollView *s = targetViewController.scrollView;
    CGPoint contentOffset = s.contentOffset;
    contentOffset.y = -self.pageMenu.frame.origin.y+kHeaderViewH+kNaviH;
    
    if (contentOffset.y >= kHeaderViewH) {
        contentOffset.y = kHeaderViewH;
    }
    s.contentOffset = contentOffset;
    [self.scrollView addSubview:targetViewController.view];
}

- (void)btnAction:(UIButton *)sender {
    NSLog(@"---哇，棒极了，我接收到了您的点击事件");
}

- (UIScrollView *)scrollView {
    
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.frame = CGRectMake(0, kNaviH, kScreenW, kScreenH);
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.contentSize = CGSizeMake(kScreenW*4, 0);
    }
    return _scrollView;
}

- (MyHeaderView *)headerView {
    
    if (!_headerView) {
        _headerView = [[MyHeaderView alloc] init];
        _headerView.frame = CGRectMake(0, 0, kScreenW, kHeaderViewH);
        _headerView.backgroundColor = [UIColor greenColor];
        [_headerView.button addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _headerView;
}

- (SPPageMenu *)pageMenu {
    
    if (!_pageMenu) {
        _pageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(0, CGRectGetMaxY(self.headerView.frame)+kNaviH, kScreenW, kPageMenuH) array:@[@"第一个",@"第二个",@"第三个",@"第四个"]];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
