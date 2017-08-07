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

#import "UINavigationController+NavAlpha.h"

#define kHeaderViewH 200
#define kPageMenuH 40
#define kNaviH 64

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
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navBarTintColor = [UIColor whiteColor];
    self.navAlpha = 0;
    
    self.lastPageMenuY = kHeaderViewH;
    
    // 添加一个全屏的scrollView
    [self.view addSubview:self.scrollView];
    
    // 添加头部视图
    [self.view addSubview:self.headerView];
    
    // 添加悬浮菜单
    [self.view addSubview:self.pageMenu];
    
    // 添加4个子控制器
    [self addChildViewController:[[FirstViewController alloc] init]];
    [self addChildViewController:[[SecondViewController alloc] init]];
    [self addChildViewController:[[ThirdViewController alloc] init]];
    [self addChildViewController:[[FourViewController alloc] init]];
    // 先将第一个子控制的view添加到scrollView上去
    [self.scrollView addSubview:self.childViewControllers[0].view];
    
    // 监听子控制器发出的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subScrollViewDidScroll:) name:@"SubScrollViewDidScroll" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshing:) name:@"isRefreshing" object:nil];
    
}

#pragma mark - 刷新通知
- (void)refreshing:(NSNotification *)noti {
    RefreshingState state = [noti.object integerValue];
    if (state == RefreshingStateRefreshing) {
        self.scrollView.userInteractionEnabled = NO;
    } else {
        self.scrollView.userInteractionEnabled = YES;
    }
}

// self.scrollView的代理方法

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    BaseViewController *baseVc = self.childViewControllers[_selectedIndex];
    if (scrollView == self.scrollView) {
        // 如果scrollView的内容很少，在屏幕范围内，则自动回落
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (baseVc.scrollView.contentSize.height < kScreenH && [baseVc isViewLoaded]) {
                [baseVc.scrollView setContentOffset:CGPointMake(0, -kScrollViewBeginTopInset) animated:YES];
            }
        });
    }
}


// 子控制器上的scrollView已经滑动的代理方法所发出的通知方法(核心)
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
            if (offsetDifference > 0 && scrollingScrollView.contentOffset.y+kScrollViewBeginTopInset > 0) {
                
                if (((scrollingScrollView.contentOffset.y+kScrollViewBeginTopInset+self.pageMenu.frame.origin.y)>=kHeaderViewH) || scrollingScrollView.contentOffset.y+kScrollViewBeginTopInset < 0) {
                    // 悬浮菜单的y值等于当前正在滑动且显示在屏幕范围内的的scrollView的contentOffset.y的改变量(这是最难的点)
                    pageMenuFrame.origin.y += -offsetDifference;
                    if (pageMenuFrame.origin.y <= kNaviH) {
                        pageMenuFrame.origin.y = kNaviH;
                    }
                }
            } else { // 往下移
                if ((scrollingScrollView.contentOffset.y+kScrollViewBeginTopInset+self.pageMenu.frame.origin.y)<kHeaderViewH) {
                    pageMenuFrame.origin.y = -scrollingScrollView.contentOffset.y-kScrollViewBeginTopInset+kHeaderViewH;
                    if (pageMenuFrame.origin.y >= kHeaderViewH) {
                        pageMenuFrame.origin.y = kHeaderViewH;
                    }
                }
            }
        }
        self.pageMenu.frame = pageMenuFrame;
        
        CGRect headerFrame = self.headerView.frame;
        headerFrame.origin.y = self.pageMenu.frame.origin.y-kHeaderViewH;
        self.headerView.frame = headerFrame;
        
        // 记录悬浮菜单的y值改变量
        distanceY = pageMenuFrame.origin.y - self.lastPageMenuY;
        self.lastPageMenuY = self.pageMenu.frame.origin.y;
        
        // 让其余控制器的scrollView跟随当前正在滑动的scrollView滑动
        [self followScrollingScrollView:scrollingScrollView distanceY:distanceY];

        [self changeColorWithOffsetY:-self.pageMenu.frame.origin.y+kHeaderViewH];
    }
    baseVc.isFirstViewLoaded = NO;
}

- (void)followScrollingScrollView:(UIScrollView *)scrollingScrollView distanceY:(CGFloat)distanceY{
    BaseViewController *baseVc = nil;
    for (int i = 0; i < self.childViewControllers.count; i++) {
        baseVc = self.childViewControllers[i];
        if (baseVc.scrollView == scrollingScrollView) {
            continue;
        } else {
            CGPoint contentOffSet = baseVc.scrollView.contentOffset;
            contentOffSet.y += -distanceY;
            baseVc.scrollView.contentOffset = contentOffSet;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x / scrollView.frame.size.width;
    // 手动滑scrollView,pageMenu会根据传进去的index选中index对应的button
    [self.pageMenu selectButtonAtIndex:index];
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
    
    BaseViewController *targetViewController = self.childViewControllers[toIndex];
    // 如果已经加载过，就不再加载
    if ([targetViewController isViewLoaded]) return;
    
    // 来到这里必然是第一次加载控制器的view，这个属性是为了防止下面的偏移量的改变导致走scrollViewDidScroll
    targetViewController.isFirstViewLoaded = YES;
    
    targetViewController.view.frame = CGRectMake(kScreenW*toIndex, 0, kScreenW, kScreenH);
    UIScrollView *s = targetViewController.scrollView;
    CGPoint contentOffset = s.contentOffset;
    contentOffset.y = -self.headerView.frame.origin.y-kScrollViewBeginTopInset;
    if (contentOffset.y + kScrollViewBeginTopInset >= kHeaderViewH) {
        contentOffset.y = kHeaderViewH-kScrollViewBeginTopInset;
    }
    s.contentOffset = contentOffset;
    [self.scrollView addSubview:targetViewController.view];
}

- (void)panGestureRecognizerAction:(UIPanGestureRecognizer *)pan {
    if (pan.state == UIGestureRecognizerStateBegan) {
        
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        CGPoint currenrPoint = [pan translationInView:pan.view];
        CGFloat distanceY = currenrPoint.y - self.lastPoint.y;
        self.lastPoint = currenrPoint;

        BaseViewController *baseVc = self.childViewControllers[_selectedIndex];
        CGPoint offset = baseVc.scrollView.contentOffset;
        offset.y += -distanceY;
        if (offset.y <= -kScrollViewBeginTopInset) {
            offset.y = -kScrollViewBeginTopInset;
        }
        baseVc.scrollView.contentOffset = offset;
    } else {
        [pan setTranslation:CGPointZero inView:pan.view];
         self.lastPoint = CGPointZero;
    }
   
}

- (void)changeColorWithOffsetY:(CGFloat)offsetY {
    // 滑出20偏移时开始发生渐变,(kHeaderViewH - 20 - 64)决定渐变时间长度
    
    if (offsetY >= 0) {
        CGFloat alpha = (offsetY)/(kHeaderViewH-64);
        // 该属性是设置导航栏背景渐变
        self.navAlpha = alpha;
        
    } else {
        self.navAlpha = 0;
        
    }
}

- (void)btnAction:(UIButton *)sender {
    NSLog(@"---哇，棒极了，我接收到了您的点击事件");
}

- (UIScrollView *)scrollView {
    
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.frame = CGRectMake(0, 0, kScreenW, kScreenH);
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
        _headerView.frame = CGRectMake(0, 0, kScreenW, kHeaderViewH);
        _headerView.backgroundColor = [UIColor greenColor];
        [_headerView.button addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerAction:)];
        [_headerView addGestureRecognizer:pan];
    }
    return _headerView;
}

- (SPPageMenu *)pageMenu {
    
    if (!_pageMenu) {
        _pageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(0, CGRectGetMaxY(self.headerView.frame), kScreenW, kPageMenuH) array:@[@"第一个",@"第二个",@"第三个",@"第四个"]];
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
