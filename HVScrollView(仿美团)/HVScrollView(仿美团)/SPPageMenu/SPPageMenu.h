//
//  SPPageMenu.h
//  SPPageMenu
//
//  Created by 乐升平 on 17/10/26. https://github.com/SPStore/SPPageMenu
//  Copyright © 2017年 iDress. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SPPageMenuTrackerStyle) {
    SPPageMenuTrackerStyleLine = 0,                  // 下划线,默认与item等宽
    SPPageMenuTrackerStyleLineLongerThanItem,        // 下划线,比item要长(长度为item的宽+间距)
    SPPageMenuTrackerStyleLineAttachment,            // 下划线依恋样式
    SPPageMenuTrackerStyleTextZoom,                  // 文字缩放
    SPPageMenuTrackerStyleRoundedRect,               // 圆角矩形
    SPPageMenuTrackerStyleRect                       // 矩形
};

typedef NS_ENUM(NSInteger, SPPageMenuPermutationWay) {
    SPPageMenuPermutationWayScrollAdaptContent = 0,   // 自适应内容,可以左右滑动
    SPPageMenuPermutationWayNotScrollEqualWidths,     // 等宽排列,不可以滑动,整个内容被控制在pageMenu的范围之内,等宽是根据pageMenu的总宽度对每个item均分
    SPPageMenuPermutationWayNotScrollAdaptContent     // 自适应内容,不可以滑动,整个内容被控制在pageMenu的范围之内,这种排列方式下,自动计算item之间的间距,itemPadding属性设置无效
};

typedef NS_ENUM(NSInteger, SPItemImagePosition) {
    SPItemImagePositionDefault,   // 默认图片在左边
    SPItemImagePositionLeft,      // 图片在左边
    SPItemImagePositionTop,       // 图片在上面
    SPItemImagePositionRight,     // 图片在右边
    SPItemImagePositionBottom     // 图片在下面
};

@class SPPageMenu;

@protocol SPPageMenuDelegate <NSObject>

@optional
- (void)pageMenu:(SPPageMenu *)pageMenu functionButtonClicked:(UIButton *)functionButton;
// 若以下2个代理方法同时实现了，那么只会走第2个代理方法
- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedAtIndex:(NSInteger)index;
- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

@end

@interface SPPageMenu : UIView

// 创建pagMenu
+ (instancetype)pageMenuWithFrame:(CGRect)frame trackerStyle:(SPPageMenuTrackerStyle)trackerStyle;
- (instancetype)initWithFrame:(CGRect)frame trackerStyle:(SPPageMenuTrackerStyle)trackerStyle;

/**
 *  传递数组(数组元素只能是NSString或UIImage类型)
 *
 *  @param items    数组
 *  @param selectedItemIndex  选中哪个item
 */
- (void)setItems:(nullable NSArray *)items selectedItemIndex:(NSUInteger)selectedItemIndex;

/** 选中的item下标 */
@property (nonatomic) NSUInteger selectedItemIndex;

/** 是否需要文字渐变,默认为YES */
@property (nonatomic, assign) BOOL needTextColorGradients;

/** 外界的srollView，pageMenu会监听该scrollView的滚动状况，让跟踪器时刻跟随此scrollView滑动 */
@property (nonatomic, strong) UIScrollView *bridgeScrollView;
/** 关闭跟踪器的跟随效果,在外界传了scrollView进来或者调用了moveTrackerFollowScrollView的情况下,如果为YES，则当外界滑动scrollView时，跟踪器不会时刻跟随,只有滑动结束才会跟踪; 如果为NO，跟踪器会时刻跟随scrollView */
@property (nonatomic, assign) BOOL closeTrackerFollowingMode;

/** 是否显示功能按钮(功能按钮显示在最右侧),默认为NO */
@property (nonatomic, assign) BOOL showFuntionButton;
/** item之间的间距,当permutationWay为‘SPPageMenuPermutationWayNotScrollAdaptContent’时此属性无效 */
@property (nonatomic, assign) CGFloat itemPadding;
/** item的标题字体 */
@property (nonnull, nonatomic, strong) UIFont *itemTitleFont;
/** 选中的item标题颜色 */
@property (nonatomic, strong) UIColor *selectedItemTitleColor;
/** 未选中的item标题颜色 */
@property (nonatomic, strong) UIColor *unSelectedItemTitleColor;
/** 跟踪器 */
@property (nonatomic, readonly) UIImageView *tracker;
/** 分割线 */
@property (nonatomic, readonly) UIImageView *dividingLine;
/** 代理 */
@property (nonatomic, weak) id<SPPageMenuDelegate> delegate;

/** 内容的四周内边距(内容不包括分割线) */
@property (nonatomic, assign) UIEdgeInsets contentInset;
/** 排列方式 */
@property (nonatomic, assign) SPPageMenuPermutationWay permutationWay;

// 插入item,插入和删除操作时,如果itemIndex超过了了items的个数,则不做任何操作
- (void)insertItemWithTitle:(nullable NSString *)title atIndex:(NSUInteger)itemIndex animated:(BOOL)animated;
- (void)insertItemWithImage:(nullable UIImage *)image  atIndex:(NSUInteger)itemIndex animated:(BOOL)animated;
// 如果移除的正是当前选中的item(当前选中的item下标不为0),删除之后,选中的item会切换为上一个item
- (void)removeItemAtIndex:(NSUInteger)itemIndex animated:(BOOL)animated;
- (void)removeAllItems;

// 设置指定item的标题,设置后，如果原先的item为image，则image会被title替换
- (void)setTitle:(nullable NSString *)title forItemAtIndex:(NSUInteger)itemIndex;
// 获取指定item的标题
- (nullable NSString *)titleForItemAtIndex:(NSUInteger)itemIndex;

// 设置指定item的图片,设置后，如果原先的item为title，则title会被图片替换
- (void)setImage:(nullable UIImage *)image forItemAtIndex:(NSUInteger)itemIndex;
// 获取指定item的图片
- (nullable UIImage *)imageForItemAtIndex:(NSUInteger)itemIndex;

// 设置指定item的enabled状态
- (void)setEnabled:(BOOL)enaled forItemAtIndex:(NSUInteger)itemIndex;
// 获取指定item的enabled状态
- (BOOL)enabledForItemAtIndex:(NSUInteger)itemIndex;

// 设置指定item的宽度(如果width为0,则item将自动计算)
- (void)setWidth:(CGFloat)width forItemAtIndex:(NSUInteger)itemIndex;
// 获取指定item的宽度
- (CGFloat)widthForItemAtIndex:(NSUInteger)itemIndex;

/**
 *  同时为指定item设置标题和图片
 *
 *  @param title    标题
 *  @param image    图片
 *  @param imagePosition    图片的位置，分上、左、下、右
 *  @param ratio            图片所占item的比例,默认0.5,如果给0,同样会自动默认为0.5
 *  @param itemIndex        item的下标
 */
- (void)setTitle:(nullable NSString *)title image:(nullable UIImage *)image imagePosition:(SPItemImagePosition)imagePosition imageRatio:(CGFloat)ratio forItemIndex:(NSUInteger)itemIndex;

/**
 *  同时为functionButton设置标题和图片
 *
 *  @param title    标题
 *  @param image    图片
 *  @param imagePosition    图片的位置，分上、左、下、右
 *  @param ratio            图片所占item的比例,默认0.5,如果给0,同样会自动默认为0.5
 *  @param state            控件状态
 */
- (void)setFunctionButtonTitle:(nullable NSString *)title image:(nullable UIImage *)image imagePosition:(SPItemImagePosition)imagePosition imageRatio:(CGFloat)ratio forState:(UIControlState)state;

/* 为functionButton配置相关属性，如设置字体、文字颜色等
   在此,attributes中,只有NSFontAttributeName、NSForegroundColorAttributeName、NSBackgroundColorAttributeName有效
 */
- (void)setFunctionButtonTitleTextAttributes:(nullable NSDictionary *)attributes forState:(UIControlState)state;

/* 1.让跟踪器时刻跟随外界scrollView滑动,实现了让跟踪器的宽度逐渐适应item宽度的功能;
   2.这个方法用于scrollViewDidScroll代理方法中，如
 
    - (void)scrollViewDidScroll:(UIScrollView *)scrollView {
        [self.pageMenu moveTrackerFollowScrollView:scrollView];
    }
 
    3.如果外界对SPPageMenu的属性"bridgeScrollView"赋了值，那么外界就可以不用在scrollViewDidScroll方法中调用这个方法来实现跟踪器时刻跟随外界scrollView的效果,内部会自动处理; 外界对SPPageMenu的属性"bridgeScrollView"赋值是实现此效果的最简便的操作
    4.如果不想要此效果,可设置closeTrackerFollowingMode==YES
 */
- (void)moveTrackerFollowScrollView:(UIScrollView *)scrollView;

@end

NS_ASSUME_NONNULL_END





