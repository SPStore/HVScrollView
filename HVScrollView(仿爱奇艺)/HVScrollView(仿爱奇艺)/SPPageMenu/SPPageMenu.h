//
//  SPPageMenu.h
//  SPPageMenu
//
//  Created by leshengping on 16/12/17.
//  Copyright © 2016年 leshengping. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SPPageMenu;
@protocol SPPageMenuDelegate <NSObject>

@optional
/** 
 * pageMenu:菜单对象
 * index:当前选中的button下标
 */
- (void)pageMenu:(SPPageMenu *)pageMenu buttonClickedAtIndex:(NSInteger)index;
/** 
 * pageMenu:菜单对象
 * fromIndex:上一个被选中的button下标
 * toIndex:当前被选中的button下标
 */
- (void)pageMenu:(SPPageMenu *)pageMenu buttonClickedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;
@end


@interface SPPageMenu : UIView

@property (nonatomic, weak) id<SPPageMenuDelegate> delegate;

/** block方式监听button被点击，外界可选择代理方式，也可以选择block方式 */
@property (nonatomic, copy) void(^buttonClickedBlock)(NSInteger index);
@property (nonatomic, copy) void(^buttonClicked_from_to_Block)(NSInteger fromIndex,  NSInteger toIndex);


/** button之间的间距,默认为30 */
@property (nonatomic, assign) CGFloat spacing;
/** 第一个button的左边距，默认为间距的一半 */
@property (nonatomic, assign) CGFloat firstButtonX;
/** button的字体,默认为15号字体 */
@property (nonatomic, strong) UIFont *buttonFont;
/** 选中的button的字体颜色 */
@property (nonatomic, strong) UIColor *selectedTitleColor;
/** 未选中的button字体颜色,默认为黑色 */
@property (nonatomic, strong) UIColor *unSelectedTitleColor;
/** 分割线颜色，默认为亮灰色 */
@property (nonatomic, strong) UIColor *breaklineColor;
/** 是否显示分割线,默认为YES */
@property (nonatomic, assign, getter=isShowBreakline) BOOL showBreakline;
/** 是否显示跟踪器，默认为YES */
@property (nonatomic, assign, getter=isShowTracker) BOOL showTracker;
/** 跟踪器的高度,默认为2.0f */
@property (nonatomic, assign) CGFloat trackerHeight;
/** 跟踪器的颜色，默认与选中的button字体颜色一致 */
@property (nonatomic, strong) UIColor *trackerColor;
/** 是否开启动画,默认为NO */
@property (nonatomic, assign, getter=isOpenAnimation) BOOL openAnimation;
/** 跟踪器的动画速率*/
@property (nonatomic, assign) CGFloat animationSpeed;


/** 当以下两个属性同时为NO时，spacing和firstButtonX属性将不受用户控制，这是合情合理的 */
/** 是否允许超出屏幕,默认为YES,如果设置了NO,则菜单上的所有button都将示在在屏幕范围之内，并且默认等宽，整体居中显示 ，如果想要button根据文字自适应宽度，还要配合下面的“equalWidths”属性 */
@property (nonatomic, assign, getter=isAllowBeyondScreen) BOOL allowBeyondScreen;
/** 是否等宽，默认为YES,这个属性只有在屏幕范围之内的布局方式才有效 */
@property (nonatomic, assign, getter=isEqualWidths) BOOL equalWidths;

/** 快速创建菜单 */
+ (SPPageMenu *)pageMenuWithFrame:(CGRect)frame array:(NSArray *)array;


/*
 *  外界只要告诉该类index,内部会处理哪个button被选中
 */
- (void)selectButtonAtIndex:(NSInteger)index;

/*
 *  1.这个方法的功能是实现跟踪器跟随scrollView的滚动而滚动;
 *  2.调用这个方法必须在scrollViewDidScrollView里面调;
 *  3.beginOffset:scrollView刚开始滑动的时候起始偏移量,在scrollViewWillBeginDragging:方法内部获取起始偏移量;
 *  4.scrollView:外面正在拖拽的scrollView;
 */
- (void)moveTrackerFollowScrollView:(UIScrollView *)scrollView beginOffset:(CGFloat)beginOffset;
@end






