//
//  SPPageMenu.m
//  SPPageMenu
//
//  Created by 乐升平 on 17/10/26.
//  Copyright © 2017年 iDress. All rights reserved.
//

#import "SPPageMenu.h"

#define tagBaseValue 100
#define scrollViewContentOffset @"contentOffset"

@interface SPScrollView : UIScrollView
@end

@implementation SPScrollView
// 重写这个方法的目的是：当手指长按按钮时无法滑动scrollView的问题
- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    return YES;
}
@end

@interface SPPageMenuLine : UIImageView
@property (nonatomic, copy) void(^hideBlock)(void);

@end

@implementation SPPageMenuLine

// 当外界设置隐藏和alpha值时，让pageMenu重新布局
- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    if (self.hideBlock) {
        self.hideBlock();
    }
}

- (void)setAlpha:(CGFloat)alpha {
    [super setAlpha:alpha];
    if (self.hideBlock) {
        self.hideBlock();
    }
}

@end

@interface SPItem : UIButton

- (instancetype)initWithImageRatio:(CGFloat)ratio;
// 图片的高度所占按钮的高度比例,注意要浮点数，如果传分数比如三分之二，要写2.0/3.0，不能写2/3
@property (nonatomic, assign) CGFloat imageRatio;
// 图片的位置
@property (nonatomic, assign) SPItemImagePosition imagePosition;
// 图片与标题之间的间距
@property (nonatomic, assign) CGFloat imageTitleSpace;
@end

@implementation SPItem


- (instancetype)initWithImageRatio:(CGFloat)ratio {
    if (self = [super init]) {
        _imageRatio = ratio;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {

        [self initialize];

    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {

        [self initialize];

    }
    return self;
}

- (void)initialize {
    _imageRatio = 0.5;
    _imagePosition = SPItemImagePositionDefault;

    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)setHighlighted:(BOOL)highlighted {}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    if (!self.currentTitle) { // 如果没有文字，则图片占据整个button，空格算一个文字
        return [super imageRectForContentRect:contentRect];
    }
    switch (self.imagePosition) {
        case SPItemImagePositionDefault:
        case SPItemImagePositionLeft: { // 图片在左
            _imageRatio = _imageRatio == 0.0 ? 0.5 : _imageRatio;
            CGFloat imageW =  (contentRect.size.width-_imageTitleSpace) * _imageRatio;
            CGFloat imageH = contentRect.size.height;
            return CGRectMake(self.contentEdgeInsets.left, self.contentEdgeInsets.top, imageW, imageH);
        }
            break;
        case SPItemImagePositionTop: {
            _imageRatio = _imageRatio == 0.0 ? 2.0/3.0 : _imageRatio;
            CGFloat imageW = contentRect.size.width;
            CGFloat imageH = (contentRect.size.height-_imageTitleSpace) * _imageRatio;
            return CGRectMake(self.contentEdgeInsets.left, self.contentEdgeInsets.top, imageW, imageH);
        }
            break;
        case SPItemImagePositionRight: {
            _imageRatio = _imageRatio == 0.0 ? 0.5 : _imageRatio;
            CGFloat imageW =  (contentRect.size.width-_imageTitleSpace) * _imageRatio;
            CGFloat imageH = contentRect.size.height;
            CGFloat imageX = contentRect.size.width - imageW;
            return CGRectMake(imageX+self.contentEdgeInsets.left, self.contentEdgeInsets.top, imageW, imageH);
        }
            break;
        case SPItemImagePositionBottom: {
            _imageRatio = _imageRatio == 0.0 ? 2.0/3.0 : _imageRatio;
            CGFloat imageW =  contentRect.size.width;
            CGFloat imageH = (contentRect.size.height - _imageTitleSpace) * _imageRatio;
            CGFloat imageY = contentRect.size.height-imageH;
            return CGRectMake(self.contentEdgeInsets.left, imageY+self.contentEdgeInsets.top, imageW, imageH);
        }
            break;
        default:
            break;
    }
    return CGRectZero;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    if (!self.currentImage) {  // 如果没有图片
        return [super titleRectForContentRect:contentRect];
    }
    switch (self.imagePosition) {
        case SPItemImagePositionDefault:
        case SPItemImagePositionLeft: {
            _imageRatio = _imageRatio == 0.0 ? 0.5 : _imageRatio;
            CGFloat titleX = (contentRect.size.width-_imageTitleSpace) * _imageRatio + _imageTitleSpace;
            CGFloat titleW = contentRect.size.width - titleX;
            CGFloat titleH = contentRect.size.height;
            return CGRectMake(titleX+self.contentEdgeInsets.left, self.contentEdgeInsets.top, titleW, titleH);
        }
            break;
        case SPItemImagePositionTop: {
            _imageRatio = _imageRatio == 0.0 ? 2.0/3.0 : _imageRatio;
            CGFloat titleY = (contentRect.size.height-_imageTitleSpace) * _imageRatio + _imageTitleSpace;
            CGFloat titleW = contentRect.size.width;
            CGFloat titleH = contentRect.size.height - titleY;
            return CGRectMake(self.contentEdgeInsets.left, titleY+self.contentEdgeInsets.top, titleW, titleH);
        }
            break;
        case SPItemImagePositionRight: {
            _imageRatio = _imageRatio == 0.0 ? 0.5 : _imageRatio;
            CGFloat titleW = (contentRect.size.width - _imageTitleSpace) * (1-_imageRatio);
            CGFloat titleH = contentRect.size.height;
            return CGRectMake(self.contentEdgeInsets.left, self.contentEdgeInsets.top, titleW, titleH);
        }
            break;
        case SPItemImagePositionBottom: {
            _imageRatio = _imageRatio == 0.0 ? 2.0/3.0 : _imageRatio;
            CGFloat titleW = contentRect.size.width;
            CGFloat titleH = (contentRect.size.height-_imageTitleSpace) * (1 - _imageRatio);
            return CGRectMake(self.contentEdgeInsets.left, self.contentEdgeInsets.top, titleW, titleH);
        }
            break;
        default:
            break;
    }
    return CGRectZero;

}

- (void)setImagePosition:(SPItemImagePosition)imagePosition {
    _imagePosition = imagePosition;
    [self setNeedsDisplay];
}

- (void)setImageRatio:(CGFloat)imageRatio {
    _imageRatio = imageRatio;
    [self setNeedsDisplay];
}

- (void)setImageTitleSpace:(CGFloat)imageTitleSpace {
    _imageTitleSpace = imageTitleSpace;
    [self setNeedsDisplay];
}

- (void)setContentEdgeInsets:(UIEdgeInsets)contentEdgeInsets {
    [super setContentEdgeInsets:contentEdgeInsets];
    [self setNeedsDisplay];
}

@end

@interface SPPageMenu()
@property (nonatomic, assign) SPPageMenuTrackerStyle trackerStyle;
@property (nonatomic, strong) NSArray *items; // 里面装的是字符串或者图片
@property (nonatomic, strong) UIImageView *tracker;
@property (nonatomic, assign) CGFloat trackerHeight;
@property (nonatomic, weak) UIView *backgroundView;
@property (nonatomic, strong) UIImageView *dividingLine;
@property (nonatomic, weak) SPScrollView *itemScrollView;
@property (nonatomic, weak) SPItem *functionButton;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) SPItem *selectedButton;
@property (nonatomic, strong) NSMutableDictionary *setupWidths;
@property (nonatomic, assign) BOOL insert;
// 起始偏移量,为了判断滑动方向
@property (nonatomic, assign) CGFloat beginOffsetX;

/// 开始颜色, 取值范围 0~1
@property (nonatomic, assign) CGFloat startR;
@property (nonatomic, assign) CGFloat startG;
@property (nonatomic, assign) CGFloat startB;
/// 完成颜色, 取值范围 0~1
@property (nonatomic, assign) CGFloat endR;
@property (nonatomic, assign) CGFloat endG;
@property (nonatomic, assign) CGFloat endB;

// 这个高度，是存储itemScrollView的高度
@property (nonatomic, assign) CGFloat itemScrollViewH;
@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@implementation SPPageMenu


#pragma mark - public

+ (instancetype)pageMenuWithFrame:(CGRect)frame trackerStyle:(SPPageMenuTrackerStyle)trackerStyle {
    SPPageMenu *pageMenu = [[SPPageMenu alloc] initWithFrame:frame trackerStyle:trackerStyle];
    return pageMenu;
}

- (instancetype)initWithFrame:(CGRect)frame trackerStyle:(SPPageMenuTrackerStyle)trackerStyle {
    if (self = [super init]) {
        self.frame = frame;
        self.backgroundColor = [UIColor whiteColor];
        self.trackerStyle = trackerStyle;
        [self setupStartColor:_selectedItemTitleColor];
        [self setupEndColor:_unSelectedItemTitleColor];
    }
    return self;
}

- (void)setItems:(NSArray *)items selectedItemIndex:(NSInteger)selectedItemIndex {
    if (selectedItemIndex < 0) selectedItemIndex = 0;
    NSAssert(selectedItemIndex <= items.count-1, @"selectedItemIndex 大于了 %ld",items.count-1);
    _items = items.copy;
    _selectedItemIndex = selectedItemIndex;
    
    self.insert = NO;
    
    for (int i = 0; i < items.count; i++) {
        id object = items[i];
        NSAssert([object isKindOfClass:[NSString class]] || [object isKindOfClass:[UIImage class]], @"items中的元素只能是NSString或UIImage类型");
        [self addButton:i object:object animated:NO];
    }

    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    if (self.buttons.count) {
        // 默认选中selectedItemIndex对应的按钮
        SPItem *selectedButton = [self.buttons objectAtIndex:selectedItemIndex];
        [self buttonInPageMenuClicked:selectedButton];

        // SPPageMenuTrackerStyleTextZoom和SPPageMenuTrackerStyleNothing样式跟tracker没有关联
        if ([self haveOrNeedsTracker]) {
            [self.itemScrollView insertSubview:self.tracker atIndex:0];
            // 这里千万不能再去调用setNeedsLayout和layoutIfNeeded，因为如果外界在此之前对selectedButton进行了缩放，调用了layoutSubViews后会重新对selectedButton设置frame,先缩放再重设置frame会导致文字显示不全，所以我们直接跳过layoutSubViews调用resetSetupTrackerFrameWithSelectedButton：只设置tracker的frame
            [self resetSetupTrackerFrameWithSelectedButton:selectedButton];
        }
    }
}

- (void)insertItemWithTitle:(NSString *)title atIndex:(NSUInteger)itemIndex animated:(BOOL)animated {
    self.insert = YES;
    NSAssert(itemIndex <= self.items.count, @"itemIndex超过了items的总个数“%ld”",self.items.count);
    NSMutableArray *titleArr = self.items.mutableCopy;
    [titleArr insertObject:title atIndex:itemIndex];
    self.items = titleArr;
    [self addButton:itemIndex object:title animated:animated];
    if (itemIndex <= self.selectedItemIndex) {
        _selectedItemIndex += 1;
    }
}

- (void)insertItemWithImage:(UIImage *)image atIndex:(NSUInteger)itemIndex animated:(BOOL)animated {
    self.insert = YES;
    NSAssert(itemIndex <= self.items.count, @"itemIndex超过了items的总个数“%ld”",self.items.count);
    NSMutableArray *objects = self.items.mutableCopy;
    [objects insertObject:image atIndex:itemIndex];
    self.items = objects.copy;
    [self addButton:itemIndex object:image animated:animated];
    if (itemIndex <= self.selectedItemIndex) {
        _selectedItemIndex += 1;
    }
}

- (void)removeItemAtIndex:(NSUInteger)itemIndex animated:(BOOL)animated {
    NSAssert(itemIndex <= self.items.count, @"itemIndex超过了items的总个数“%ld”",self.items.count);
    // 被删除的按钮之后的按钮需要修改tag值
    for (SPItem *button in self.buttons) {
        if (button.tag-tagBaseValue > itemIndex) {
            button.tag = button.tag - 1;
        }
    }
    if (self.items.count) {
        NSMutableArray *objects = self.items.mutableCopy;
        // 特别注意的是：不能先通过itemIndex取出对象，然后再将对象删除，因为这样会删除所有相同的对象
        [objects removeObjectAtIndex:itemIndex];
        self.items = objects.copy;
    }
    if (itemIndex < self.buttons.count) {
        SPItem *button = [self.buttons objectAtIndex:itemIndex];
        if (button == self.selectedButton) { // 如果删除的正是选中的item，删除之后，选中的按钮切换为上一个item
            self.selectedItemIndex = itemIndex > 0 ? itemIndex-1 : itemIndex;
        }
        [self.buttons removeObjectAtIndex:itemIndex];
        [button removeFromSuperview];
        if (self.buttons.count == 0) { // 说明移除了所有
            [self.tracker removeFromSuperview];
            self.selectedButton = nil;
            self.selectedItemIndex = 0;
        }
    }
    if (animated) {
        [UIView animateWithDuration:0.5 animations:^{
            [self setNeedsLayout];
            [self layoutIfNeeded];
        }];
    } else {
        [self setNeedsLayout];
    }
    
}

- (void)removeAllItems {
    NSMutableArray *objects = self.items.mutableCopy;
    [objects removeAllObjects];
    self.items = objects.copy;
    self.items = nil;
    
    for (int i = 0; i < self.buttons.count; i++) {
        SPItem *button = self.buttons[i];
        [button removeFromSuperview];
    }
    
    [self.buttons removeAllObjects];
    
    [self.tracker removeFromSuperview];
    
    self.selectedButton = nil;
    self.selectedItemIndex = 0;
    
    [self setNeedsLayout];
}

- (void)setTitle:(NSString *)title forItemAtIndex:(NSUInteger)itemIndex {
    if (itemIndex < self.buttons.count) {
        SPItem *button = [self.buttons objectAtIndex:itemIndex];
        [button setImage:nil forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateNormal];

        NSMutableArray *items = self.items.mutableCopy;
        [items replaceObjectAtIndex:itemIndex withObject:title];
        self.items = items.copy;
    }
    [self setNeedsLayout];
}

- (nullable NSString *)titleForItemAtIndex:(NSUInteger)itemIndex {
    if (itemIndex < self.buttons.count) {
        SPItem *item = [self.buttons objectAtIndex:itemIndex];
        return item.currentTitle;
    }
    return nil;
}

- (void)setImage:(UIImage *)image forItemAtIndex:(NSUInteger)itemIndex {
    if (itemIndex < self.buttons.count) {
        SPItem *button = [self.buttons objectAtIndex:itemIndex];
        [button setTitle:nil forState:UIControlStateNormal];
        [button setImage:image forState:UIControlStateNormal];

        NSMutableArray *items = self.items.mutableCopy;
        [items replaceObjectAtIndex:itemIndex withObject:image];
        self.items = items.copy;
    }
    [self setNeedsLayout];
}

- (nullable UIImage *)imageForItemAtIndex:(NSUInteger)itemIndex {
    if (itemIndex < self.buttons.count) {
        SPItem *item = [self.buttons objectAtIndex:itemIndex];
        return item.currentImage;
    }
    return nil;
}


- (void)setEnabled:(BOOL)enaled forItemAtIndex:(NSUInteger)itemIndex {
    if (itemIndex < self.buttons.count) {
        SPItem *button = [self.buttons objectAtIndex:itemIndex];
        [button setEnabled:enaled];
    }
}

- (BOOL)enabledForItemAtIndex:(NSUInteger)itemIndex {
    if (self.buttons.count) {
        SPItem *button = [self.buttons objectAtIndex:itemIndex];
        return button.enabled;
    }
    return YES;
}

- (void)setWidth:(CGFloat)width forItemAtIndex:(NSUInteger)itemIndex {
    if (itemIndex < self.buttons.count) {
        [self.setupWidths setObject:@(width) forKey:[NSString stringWithFormat:@"%lu",(unsigned long)itemIndex]];
    }
}

- (CGFloat)widthForItemAtIndex:(NSUInteger)itemIndex {
    CGFloat setupWidth = [[self.setupWidths objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)itemIndex]] floatValue];
    if (setupWidth) {
        return setupWidth;
    } else {
        if (itemIndex < self.buttons.count) {
            SPItem *button = [self.buttons objectAtIndex:itemIndex];
            return button.bounds.size.width;
        }
    }
    return 0;
}

- (void)setContentEdgeInsets:(UIEdgeInsets)contentInset forForItemAtIndex:(NSUInteger)itemIndex {
    if (itemIndex < self.buttons.count) {
        SPItem *button = [self.buttons objectAtIndex:itemIndex];
        button.contentEdgeInsets = contentInset;
    }
}

- (UIEdgeInsets)contentEdgeInsetsForItemAtIndex:(NSUInteger)itemIndex {
    if (itemIndex < self.buttons.count) {
        SPItem *button = [self.buttons objectAtIndex:itemIndex];
        return button.contentEdgeInsets;
    }
    return UIEdgeInsetsZero;
}

- (void)setTrackerHeight:(CGFloat)trackerHeight cornerRadius:(CGFloat)cornerRadius {
    _trackerHeight = trackerHeight;
    self.tracker.layer.cornerRadius = cornerRadius;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setTitle:(nullable NSString *)title image:(nullable UIImage *)image imagePosition:(SPItemImagePosition)imagePosition imageRatio:(CGFloat)ratio imageTitleSpace:(CGFloat)imageTitleSpace forItemIndex:(NSUInteger)itemIndex {
    if (itemIndex < self.buttons.count) {
        SPItem *button = [self.buttons objectAtIndex:itemIndex];
        [button setTitle:title forState:UIControlStateNormal];
        [button setImage:image forState:UIControlStateNormal];
        button.imagePosition = imagePosition;
        button.imageRatio = ratio;
        button.imageTitleSpace = imageTitleSpace;
        
        // 文字和图片只能替换其一，因为items数组里不能同时装文字和图片。当文字和图片同时设置时，items里只更新文字
        if (title == nil || title.length == 0 || [title isKindOfClass:[NSNull class]]) {
            NSMutableArray *items = self.items.mutableCopy;
            [items replaceObjectAtIndex:itemIndex withObject:image];
            self.items = items.copy;
        } else if (image == nil) {
            NSMutableArray *items = self.items.mutableCopy;
            [items replaceObjectAtIndex:itemIndex withObject:title];
            self.items = items.copy;
        } else {
            NSMutableArray *items = self.items.mutableCopy;
            [items replaceObjectAtIndex:itemIndex withObject:image];
            self.items = items.copy;
        }
        
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
}

- (void)setFunctionButtonTitle:(nullable NSString *)title image:(nullable UIImage *)image imagePosition:(SPItemImagePosition)imagePosition imageRatio:(CGFloat)ratio imageTitleSpace:(CGFloat)imageTitleSpace forState:(UIControlState)state {
    [self.functionButton setTitle:title forState:state];
    [self.functionButton setImage:image forState:state];
    self.functionButton.imagePosition = imagePosition;
    self.functionButton.imageRatio = ratio;
    self.functionButton.imageTitleSpace = imageTitleSpace;
}

// 以下2个方法在3.0版本上有升级，可以使用但不推荐
- (void)setTitle:(nullable NSString *)title image:(nullable UIImage *)image imagePosition:(SPItemImagePosition)imagePosition imageRatio:(CGFloat)ratio forItemIndex:(NSUInteger)itemIndex {
    if (itemIndex < self.buttons.count) {
        SPItem *button = [self.buttons objectAtIndex:itemIndex];
        [button setTitle:title forState:UIControlStateNormal];
        [button setImage:image forState:UIControlStateNormal];
        button.imagePosition = imagePosition;
        button.imageRatio = ratio;
        
        // 文字和图片只能替换其一，因为items数组里不能同时装文字和图片。当文字和图片同时设置时，items里只更新文字
        if (title == nil || title.length == 0 || [title isKindOfClass:[NSNull class]]) {
            NSMutableArray *items = self.items.mutableCopy;
            [items replaceObjectAtIndex:itemIndex withObject:image];
            self.items = items.copy;
        } else if (image == nil) {
            NSMutableArray *items = self.items.mutableCopy;
            [items replaceObjectAtIndex:itemIndex withObject:title];
            self.items = items.copy;
        } else {
            NSMutableArray *items = self.items.mutableCopy;
            [items replaceObjectAtIndex:itemIndex withObject:image];
            self.items = items.copy;
        }
        
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
}
- (void)setFunctionButtonTitle:(nullable NSString *)title image:(nullable UIImage *)image imagePosition:(SPItemImagePosition)imagePosition imageRatio:(CGFloat)ratio forState:(UIControlState)state {
    [self.functionButton setTitle:title forState:state];
    [self.functionButton setImage:image forState:state];
    self.functionButton.imagePosition = imagePosition;
    self.functionButton.imageRatio = ratio;
}

- (void)setFunctionButtonTitleTextAttributes:(nullable NSDictionary *)attributes forState:(UIControlState)state {
    if (attributes[NSFontAttributeName]) {
        self.functionButton.titleLabel.font = attributes[NSFontAttributeName];
    }
    if (attributes[NSForegroundColorAttributeName]) {
        [self.functionButton setTitleColor:attributes[NSForegroundColorAttributeName] forState:state];
    }
    if (attributes[NSBackgroundColorAttributeName]) {
        self.functionButton.backgroundColor = attributes[NSBackgroundColorAttributeName];
    }
}

- (void)moveTrackerFollowScrollView:(SPScrollView *)scrollView {
    
    // 说明外界传进来了一个scrollView,如果外界传进来了，pageMenu会观察该scrollView的contentOffset自动处理跟踪器的跟踪
    if (self.bridgeScrollView == scrollView) { return; }
    
    [self beginMoveTrackerFollowScrollView:scrollView];
}
 

#pragma mark - private

- (void)addButton:(NSInteger)index object:(id)object animated:(BOOL)animated {
    
    // 如果是插入，需要改变已有button的tag值
    for (SPItem *button in self.buttons) {
        if (button.tag-tagBaseValue >= index) {
            button.tag = button.tag + 1; // 由于有新button的加入，新button后面的button的tag值得+1
        }
    }
    SPItem *button = [SPItem buttonWithType:UIButtonTypeCustom];
    [button setTitleColor:_unSelectedItemTitleColor forState:UIControlStateNormal];
    button.titleLabel.font = _itemTitleFont;
    [button addTarget:self action:@selector(buttonInPageMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = tagBaseValue + index;
    if ([object isKindOfClass:[NSString class]]) {
        [button setTitle:object forState:UIControlStateNormal];
    } else {
        [button setImage:object forState:UIControlStateNormal];
    }
    if (self.insert) {
        if ([self haveOrNeedsTracker]) {
            if (self.buttons.count == 0) { // 如果是第一个插入，需要将跟踪器加上,第一个插入说明itemScrollView上没有任何子控件
                [self.itemScrollView insertSubview:self.tracker atIndex:0];
                [self.itemScrollView insertSubview:button atIndex:index+1];
            } else { // 已经有跟踪器
                [self.itemScrollView insertSubview:button atIndex:index+1]; // +1是因为跟踪器
            }
        } else {
            [self.itemScrollView insertSubview:button atIndex:index];
        }
        if (!self.buttons.count) {
            [self buttonInPageMenuClicked:button];
        }
    } else {
        [self.itemScrollView insertSubview:button atIndex:index];
    }
    [self.buttons insertObject:button atIndex:index];
    
    // setNeedsLayout会标记为需要刷新,layoutIfNeeded只有在有标记的情况下才会立即调用layoutSubViews,当然标记为刷新并非只有调用setNeedsLayout,如frame改变，addSubView等都会标记为刷新
    
    if (self.insert && animated) { // 是插入的新按钮,且需要动画
        // 取出上一个按钮
        SPItem *lastButton;
        if (index > 0) {
            lastButton = self.buttons[index-1];
        }
        // 先给初始的origin，按钮将会从这个origin开始动画
        button.frame = CGRectMake(CGRectGetMaxX(lastButton.frame)+_itemPadding*0.5, 0, 0, 0);
        button.titleLabel.frame = button.bounds;
        [UIView animateWithDuration:.5 animations:^{
            [self setNeedsLayout];
            [self layoutIfNeeded];
        }];
    }
}

// 是否已经或者即将有跟踪器
- (BOOL)haveOrNeedsTracker {
    if (self.trackerStyle != SPPageMenuTrackerStyleTextZoom && self.trackerStyle != SPPageMenuTrackerStyleNothing) {
        return YES;
    }
    return NO;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    
    _itemPadding = 30;
    _itemTitleFont = [UIFont systemFontOfSize:16];
    _selectedItemTitleColor = [UIColor redColor];
    _unSelectedItemTitleColor = [UIColor blackColor];
    _trackerHeight = 3;
    _dividingLineHeight = 1 / [UIScreen mainScreen].scale; // 适配屏幕分辨率
    _contentInset = UIEdgeInsetsZero;
    _selectedItemIndex = 0;
    _showFuntionButton = NO;
    _selectedItemZoomScale = 1;
    _needTextColorGradients = YES;
    
    [self setupSubViews];
}

- (void)setupSubViews {
    // 必须先添加分割线，再添加backgroundView;假如先添加backgroundView,那也就意味着backgroundView是SPPageMenu的第一个子控件,而scrollView又是backgroundView的第一个子控件,当外界在由导航控制器管理的控制器中将SPPageMenu添加为第一个子控件时，控制器会不断的往下遍历第一个子控件的第一个子控件，直到找到为scrollView为止,一旦发现某子控件的第一个子控件为scrollView,会将scrollView的内容往下偏移64;这时控制器中必须设置self.automaticallyAdjustsScrollViewInsets = NO;为了避免这样做，这里将分割线作为第一个子控件
    SPPageMenuLine *dividingLine = [[SPPageMenuLine alloc] init];
    dividingLine.backgroundColor = [UIColor lightGrayColor];
    __weak typeof(self) weakSelf = self;
    dividingLine.hideBlock = ^() {
        [weakSelf setNeedsLayout];
    };
    [self addSubview:dividingLine];
    _dividingLine = dividingLine;
    
    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.layer.masksToBounds = YES;
    [self addSubview:backgroundView];
    _backgroundView = backgroundView;
    
    SPScrollView *itemScrollView = [[SPScrollView alloc] init];
    itemScrollView.showsVerticalScrollIndicator = NO;
    itemScrollView.showsHorizontalScrollIndicator = NO;
    itemScrollView.scrollsToTop = NO; // 目的是不要影响到外界的scrollView置顶功能
    itemScrollView.bouncesZoom = NO;
    itemScrollView.bounces = YES;
    if (@available(iOS 11.0, *)) {
        itemScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [backgroundView addSubview:itemScrollView];
    _itemScrollView = itemScrollView;
    
    SPItem *functionButton = [SPItem buttonWithType:UIButtonTypeCustom];
    functionButton.backgroundColor = [UIColor whiteColor];
    [functionButton setTitle:@"＋" forState:UIControlStateNormal];
    [functionButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [functionButton addTarget:self action:@selector(functionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    functionButton.layer.shadowColor = [UIColor blackColor].CGColor;
    functionButton.layer.shadowOffset = CGSizeMake(0, 0);
    functionButton.layer.shadowRadius = 2;
    functionButton.layer.shadowOpacity = 0.5; // 默认是0,为0的话不会显示阴影
    functionButton.hidden = !_showFuntionButton;
    [backgroundView addSubview:functionButton];
    _functionButton = functionButton;
}

// 按钮点击方法
- (void)buttonInPageMenuClicked:(SPItem *)sender {
    // 如果sender是新的选中的按钮，则上一次的按钮颜色为非选中颜色，当前选中的颜色为选中颜色
    if (self.selectedButton != sender) {
        [self.selectedButton setTitleColor:_unSelectedItemTitleColor forState:UIControlStateNormal];
        [sender setTitleColor:_selectedItemTitleColor forState:UIControlStateNormal];
    } else { // 如果选中的按钮没有发生变化，比如用户往左边滑scrollView，还没滑动结束又开始往右滑动，此时选中的按钮就没变。如果设置了颜色渐变，而且当未选中的颜色带了不等于1的alpha值，如果用户往一边滑动还未结束又往另一边滑，则未选中的按钮颜色不是很准确。这个else就是去除这种不准确现象
        // 获取RGB和Alpha
        CGFloat red = 0.0;
        CGFloat green = 0.0;
        CGFloat blue = 0.0;
        CGFloat alpha = 0.0;
        [_unSelectedItemTitleColor getRed:&red green:&green blue:&blue alpha:&alpha];
        // 此时alpha已经获取到了
        if (alpha < 1) { // 因为相信alpha=1的情况还是占多数的，如果不做判断，apha=1时也for循环设置未选中按钮的颜色有点浪费.alpha=1时不会产生颜色不准确问题
            for (SPItem *button in self.buttons) {
                if (button == sender) {
                    [button setTitleColor:_selectedItemTitleColor forState:UIControlStateNormal];
                } else {
                    [button setTitleColor:_unSelectedItemTitleColor forState:UIControlStateNormal];
                }
            }
        } else {
            [sender setTitleColor:_selectedItemTitleColor forState:UIControlStateNormal];
        }
    }
    
    CGFloat fromIndex = self.selectedButton ? self.selectedButton.tag-tagBaseValue : sender.tag - tagBaseValue;
    CGFloat toIndex = sender.tag - tagBaseValue;
    // 更新下item对应的下标,必须在代理之前，否则外界在代理方法中拿到的不是最新的,必须用下划线，用self.会造成死循环
    _selectedItemIndex = toIndex;
    [self delegatePerformMethodWithFromIndex:fromIndex toIndex:toIndex];

    [self moveItemScrollViewWithSelectedButton:sender];
    
    if (self.trackerStyle == SPPageMenuTrackerStyleTextZoom || _selectedItemZoomScale != 1) {
        if (self.selectedButton != sender) {
            self.selectedButton.transform = CGAffineTransformIdentity;
            sender.transform = CGAffineTransformMakeScale(_selectedItemZoomScale, _selectedItemZoomScale);
        } else {
            sender.transform = CGAffineTransformMakeScale(_selectedItemZoomScale, _selectedItemZoomScale);
        }
    }
    if (fromIndex != toIndex) { // 如果相等，说明是第一次进来，或者2次点了同一个，此时不需要动画
        [self moveTrackerWithSelectedButton:sender];
    }
    
    self.selectedButton = sender;
}

// 点击button让itemScrollView发生偏移
- (void)moveItemScrollViewWithSelectedButton:(SPItem *)selectedButton {
    if (CGRectEqualToRect(self.backgroundView.frame, CGRectZero)) {
        return;
    }
    // 转换点的坐标位置
    CGPoint centerInPageMenu = [self.backgroundView convertPoint:selectedButton.center toView:self];
    // CGRectGetMidX(self.backgroundView.frame)指的是屏幕水平中心位置，它的值是固定不变的
    CGFloat offSetX = centerInPageMenu.x - CGRectGetMidX(self.backgroundView.frame);
    
    // itemScrollView的容量宽与自身宽之差(难点)
    CGFloat maxOffsetX = self.itemScrollView.contentSize.width - self.itemScrollView.frame.size.width;
    // 如果选中的button中心x值小于或者等于itemScrollView的中心x值，或者itemScrollView的容量宽度小于itemScrollView本身，此时点击button时不发生任何偏移，置offSetX为0
    if (offSetX <= 0 || maxOffsetX <= 0) {
        offSetX = 0;
    }
    // 如果offSetX大于maxOffsetX,说明itemScrollView已经滑到尽头，此时button也发生任何偏移了
    else if (offSetX > maxOffsetX){
        offSetX = maxOffsetX;
    }

    [self.itemScrollView setContentOffset:CGPointMake(offSetX, 0) animated:YES];
    
}

// 移动跟踪器
- (void)moveTrackerWithSelectedButton:(SPItem *)selectedButton {
    [UIView animateWithDuration:0.25 animations:^{
        [self resetSetupTrackerFrameWithSelectedButton:selectedButton];
    }];
}

// 执行代理方法
- (void)delegatePerformMethodWithFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    if (self.delegate && [self.delegate respondsToSelector:@selector(pageMenu:itemSelectedFromIndex:toIndex:)]) {
        [self.delegate pageMenu:self itemSelectedFromIndex:fromIndex toIndex:toIndex];
    } else if (self.delegate && [self.delegate respondsToSelector:@selector(pageMenu:itemSelectedAtIndex:)]) {
        [self.delegate pageMenu:self itemSelectedAtIndex:toIndex];
    }
}

// 功能按钮的点击方法
- (void)functionButtonClicked:(SPItem *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(pageMenu:functionButtonClicked:)]) {
        [self.delegate pageMenu:self functionButtonClicked:sender];
    }
}

- (void)beginMoveTrackerFollowScrollView:(UIScrollView *)scrollView {

    // 这个if条件的意思就是没有滑动的意思
    if (!scrollView.dragging && !scrollView.decelerating) {return;}

    // 当滑到边界时，继续通过scrollView的bouces效果滑动时，直接return
    if (scrollView.contentOffset.x < 0 || scrollView.contentOffset.x > scrollView.contentSize.width-scrollView.bounds.size.width) {
        return;
    }
    
    static int i = 0;
    if (i == 0) {
        // 记录起始偏移量，注意千万不能每次都记录，只需要第一次纪录即可。
        // 初始值不要等于scrollView.contentOffset.x,因为第一次进入此方法时，scrollView.contentOffset.x的值已经有一点点偏移了，不是很准确
        _beginOffsetX = scrollView.bounds.size.width * self.selectedItemIndex;
        i = 1;
    }
    // 当前偏移量
    CGFloat currentOffSetX = scrollView.contentOffset.x;
    // 偏移进度
    CGFloat offsetProgress = currentOffSetX / scrollView.bounds.size.width;
    CGFloat progress = offsetProgress - floor(offsetProgress);

    NSInteger fromIndex;
    NSInteger toIndex;
    
    // 以下注释的“拖拽”一词很准确，不可说成滑动，例如:当手指向右拖拽，还未拖到一半时就松开手，接下来scrollView则会往回滑动，这个往回，就是向左滑动，这也是_beginOffsetX不可时刻纪录的原因，如果时刻纪录，那么往回(向左)滑动时会被视为“向左拖拽”,然而，这个往回却是由“向右拖拽”而导致的
    if (currentOffSetX - _beginOffsetX > 0) { // 向左拖拽了
        // 求商,获取上一个item的下标
        fromIndex = currentOffSetX / scrollView.bounds.size.width;
        // 当前item的下标等于上一个item的下标加1
        toIndex = fromIndex + 1;
        if (toIndex >= self.buttons.count) {
            toIndex = fromIndex;
        }
    } else if (currentOffSetX - _beginOffsetX < 0) {  // 向右拖拽了
        toIndex = currentOffSetX / scrollView.bounds.size.width;
        fromIndex = toIndex + 1;
        progress = 1.0 - progress;

    } else {
        progress = 1.0;
        fromIndex = self.selectedItemIndex;
        toIndex = fromIndex;
    }

    if (currentOffSetX == scrollView.bounds.size.width * fromIndex) {// 滚动停止了
        progress = 1.0;
        toIndex = fromIndex;
    }

    // 如果滚动停止，直接通过点击按钮选中toIndex对应的item
    if (currentOffSetX == scrollView.bounds.size.width*toIndex) { // 这里toIndex==fromIndex
        i = 0;
        // 这一次赋值起到2个作用，一是点击toIndex对应的按钮，走一遍代理方法,二是弥补跟踪器的结束跟踪，因为本方法是在scrollViewDidScroll中调用，可能离滚动结束还有一丁点的距离，本方法就不调了,最终导致外界还要在scrollView滚动结束的方法里self.selectedItemIndex进行赋值,直接在这里赋值可以让外界不用做此操作
        self.selectedItemIndex = toIndex;
        // 要return，点击了按钮，跟踪器自然会跟着被点击的按钮走
        return;
    }
    // 没有关闭跟踪模式
    if (!self.closeTrackerFollowingMode) {
        [self moveTrackerWithProgress:progress fromIndex:fromIndex toIndex:toIndex currentOffsetX:currentOffSetX beginOffsetX:_beginOffsetX];
    }
}

- (void)moveTrackerWithProgress:(CGFloat)progress fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex currentOffsetX:(CGFloat)currentOffsetX beginOffsetX:(CGFloat)beginOffsetX {
    // 下面才开始真正滑动跟踪器，上面都是做铺垫
    UIButton *fromButton = self.buttons[fromIndex];
    UIButton *toButton = self.buttons[toIndex];
    
    // 2个按钮之间的距离
    CGFloat xDistance = toButton.center.x - fromButton.center.x;
    // 2个按钮宽度的差值
    CGFloat wDistance = toButton.frame.size.width - fromButton.frame.size.width;
    
    CGRect newFrame = self.tracker.frame;
    CGPoint newCenter = self.tracker.center;
    if (self.trackerStyle == SPPageMenuTrackerStyleLine) {
        newCenter.x = fromButton.center.x + xDistance * progress;
        newFrame.size.width = _trackerWidth ? _trackerWidth : (fromButton.frame.size.width + wDistance * progress);
        self.tracker.frame = newFrame;
        self.tracker.center = newCenter;
        if (_selectedItemZoomScale != 1) {
            [self zoomForTitleWithProgress:progress fromButton:fromButton toButton:toButton];
        }
    } else if (self.trackerStyle == SPPageMenuTrackerStyleLineAttachment) {
        // 这种样式的计算比较复杂,有个很关键的技巧，就是参考progress分别为0、0.5、1时的临界值
        // 原先的x值
        CGFloat originX = fromButton.frame.origin.x+(fromButton.frame.size.width-(_trackerWidth ? _trackerWidth : fromButton.titleLabel.font.pointSize))*0.5;
        // 原先的宽度
        CGFloat originW = _trackerWidth ? _trackerWidth : fromButton.titleLabel.font.pointSize;
        if (currentOffsetX - _beginOffsetX >= 0) { // 向左拖拽了
            if (progress < 0.5) {
                newFrame.origin.x = originX; // x值保持不变
                newFrame.size.width = originW + xDistance * progress * 2;
            } else {
                newFrame.origin.x = originX + xDistance * (progress-0.5) * 2;
                newFrame.size.width = originW + xDistance - xDistance * (progress-0.5) * 2;
            }
        } else { // 向右拖拽了
            // 此时xDistance为负
            if (progress < 0.5) {
                newFrame.origin.x = originX + xDistance * progress * 2;
                newFrame.size.width = originW - xDistance * progress * 2;
            } else {
                newFrame.origin.x = originX + xDistance;
                newFrame.size.width = originW - xDistance + xDistance * (progress-0.5) * 2;
            }
        }
        self.tracker.frame = newFrame;
        if (_selectedItemZoomScale != 1) {
            [self zoomForTitleWithProgress:progress fromButton:fromButton toButton:toButton];
        }
        
    } else if (self.trackerStyle == SPPageMenuTrackerStyleTextZoom || self.trackerStyle == SPPageMenuTrackerStyleNothing) {
        // 缩放文字
        if (_selectedItemZoomScale != 1) {
            [self zoomForTitleWithProgress:progress fromButton:fromButton toButton:toButton];
        }
    } else if (self.trackerStyle == SPPageMenuTrackerStyleRoundedRect) {
        newCenter.x = fromButton.center.x + xDistance * progress;
        newFrame.size.width = _trackerWidth ? _trackerWidth : (fromButton.frame.size.width + wDistance * progress + _itemPadding);
        self.tracker.frame = newFrame;
        self.tracker.center = newCenter;
        if (_selectedItemZoomScale != 1) {
            [self zoomForTitleWithProgress:progress fromButton:fromButton toButton:toButton];
        }
    } else {
        newCenter.x = fromButton.center.x + xDistance * progress;
        newFrame.size.width = _trackerWidth ? _trackerWidth : (fromButton.frame.size.width + wDistance * progress + _itemPadding);
        self.tracker.frame = newFrame;
        self.tracker.center = newCenter;
        if (_selectedItemZoomScale != 1) {
            [self zoomForTitleWithProgress:progress fromButton:fromButton toButton:toButton];
        }
    }
    // 文字颜色渐变
    if (self.needTextColorGradients) {
        [self colorGradientForTitleWithProgress:progress fromButton:fromButton toButton:toButton];
    }
}

// 颜色渐变方法
- (void)colorGradientForTitleWithProgress:(CGFloat)progress fromButton:(UIButton *)fromButton toButton:(UIButton *)toButton {
    // 获取 targetProgress
    CGFloat fromProgress = progress;
    // 获取 originalProgress
    CGFloat toProgress = 1 - fromProgress;
    
    CGFloat r = self.endR - self.startR;
    CGFloat g = self.endG - self.startG;
    CGFloat b = self.endB - self.startB;
    UIColor *fromColor = [UIColor colorWithRed:self.startR +  r * fromProgress  green:self.startG +  g * fromProgress  blue:self.startB +  b * fromProgress alpha:1];
    UIColor *toColor = [UIColor colorWithRed:self.startR + r * toProgress green:self.startG + g * toProgress blue:self.startB + b * toProgress alpha:1];
    
    // 设置文字颜色渐变
    [fromButton setTitleColor:fromColor forState:UIControlStateNormal];
    [toButton setTitleColor:toColor forState:UIControlStateNormal];
}

// 获取颜色的RGB值
- (void)getRGBComponents:(CGFloat [3])components forColor:(UIColor *)color {
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char resultingPixel[4];
    CGContextRef context = CGBitmapContextCreate(&resultingPixel, 1, 1, 8, 4, rgbColorSpace, 1);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    CGContextRelease(context);
    CGColorSpaceRelease(rgbColorSpace);
    for (int component = 0; component < 3; component++) {
        components[component] = resultingPixel[component] / 255.0f;
    }
}

/// 开始颜色设置
- (void)setupStartColor:(UIColor *)color {
    CGFloat components[3];
    [self getRGBComponents:components forColor:color];
    self.startR = components[0];
    self.startG = components[1];
    self.startB = components[2];
}

/// 结束颜色设置
- (void)setupEndColor:(UIColor *)color {
    CGFloat components[3];
    [self getRGBComponents:components forColor:color];
    self.endR = components[0];
    self.endG = components[1];
    self.endB = components[2];
}

- (void)zoomForTitleWithProgress:(CGFloat)progress fromButton:(UIButton *)fromButton toButton:(UIButton *)toButton {
    CGFloat diff = _selectedItemZoomScale - 1;
    fromButton.transform = CGAffineTransformMakeScale((1 - progress) * diff + 1, (1 - progress) * diff + 1);
    toButton.transform = CGAffineTransformMakeScale(progress * diff + 1, progress * diff + 1);
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.bridgeScrollView) {
        if ([keyPath isEqualToString:scrollViewContentOffset]) {
            // 当scrolllView滚动时,让跟踪器跟随scrollView滑动
            [self beginMoveTrackerFollowScrollView:self.bridgeScrollView];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


#pragma mark - setter

- (void)setBridgeScrollView:(UIScrollView *)bridgeScrollView {
    _bridgeScrollView = bridgeScrollView;
    if (bridgeScrollView) {
        
        [bridgeScrollView addObserver:self forKeyPath:scrollViewContentOffset options:NSKeyValueObservingOptionNew context:nil];
    } else {
        NSLog(@"你传了一个空的scrollView");
    }
}

- (void)setTrackerStyle:(SPPageMenuTrackerStyle)trackerStyle {
    _trackerStyle = trackerStyle;
    switch (trackerStyle) {
        case SPPageMenuTrackerStyleLine:
        case SPPageMenuTrackerStyleLineLongerThanItem:
        case SPPageMenuTrackerStyleLineAttachment:
            self.tracker.backgroundColor = _selectedItemTitleColor;
            break;
        case SPPageMenuTrackerStyleRoundedRect:
        case SPPageMenuTrackerStyleRect:
            self.tracker.backgroundColor = [UIColor redColor];
            _selectedItemTitleColor = [UIColor whiteColor];
            // _trackerHeight是默认有值的，所有样式都会按照事先询问_trackerHeight有没有值，如果有值则采用_trackerHeight，如果矩形或圆角矩形样式下也用_trackerHeight高度太小了，除非外界用户自己设置了_trackerHeight
            _trackerHeight = 0;
            break;
        case SPPageMenuTrackerStyleTextZoom:
            // 此样式下默认1.3
            self.selectedItemZoomScale = 1.3;
            break;
        default:
            break;
    }
}

- (void)setBounces:(BOOL)bounces {
    _bounces = bounces;
    self.itemScrollView.bounces = bounces;
}

- (void)setAlwaysBounceHorizontal:(BOOL)alwaysBounceHorizontal {
    _alwaysBounceHorizontal = alwaysBounceHorizontal;
    self.itemScrollView.alwaysBounceHorizontal = alwaysBounceHorizontal;
}

- (void)setTrackerWidth:(CGFloat)trackerWidth {
    _trackerWidth = trackerWidth;
    CGRect trackerRect = self.tracker.frame;
    trackerRect.size.width = trackerWidth;
    self.tracker.frame = trackerRect;
    CGPoint trackerCenter = self.tracker.center;
    trackerCenter.x = _selectedButton.center.x;
    self.tracker.center = trackerCenter;
}

- (void)setDividingLineHeight:(CGFloat)dividingLineHeight {
    _dividingLineHeight = dividingLineHeight;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setSelectedItemZoomScale:(CGFloat)selectedItemZoomScale {
    _selectedItemZoomScale = selectedItemZoomScale;
    if (selectedItemZoomScale != 1) {
        _selectedButton.transform = CGAffineTransformMakeScale(_selectedItemZoomScale, _selectedItemZoomScale);
        self.tracker.transform = CGAffineTransformMakeScale(_selectedItemZoomScale, 1);
    } else {
        _selectedButton.transform = CGAffineTransformIdentity;
        self.tracker.transform = CGAffineTransformIdentity;
    }
}

- (void)setShowFuntionButton:(BOOL)showFuntionButton {
    _showFuntionButton = showFuntionButton;
    self.functionButton.hidden = !showFuntionButton;
    [self setNeedsLayout];
    [self layoutIfNeeded];
    // 修正scrollView偏移
    [self moveItemScrollViewWithSelectedButton:self.selectedButton];
}

- (void)setItemPadding:(CGFloat)itemPadding {
    _itemPadding = itemPadding;
    [self setNeedsLayout];
    [self layoutIfNeeded];
    // 修正scrollView偏移
    [self moveItemScrollViewWithSelectedButton:self.selectedButton];
}

- (void)setItemTitleFont:(UIFont *)itemTitleFont {
    _itemTitleFont = itemTitleFont;
    for (SPItem *button in self.buttons) {
        button.titleLabel.font = itemTitleFont;
    }
    [self setNeedsLayout];
    [self layoutIfNeeded];
    // 修正scrollView偏移
    [self moveItemScrollViewWithSelectedButton:self.selectedButton];
}

- (void)setSelectedItemTitleColor:(UIColor *)selectedItemTitleColor {
    _selectedItemTitleColor = selectedItemTitleColor;
    [self setupStartColor:_selectedItemTitleColor];
    [self.selectedButton setTitleColor:selectedItemTitleColor forState:UIControlStateNormal];
}

- (void)setUnSelectedItemTitleColor:(UIColor *)unSelectedItemTitleColor {
    _unSelectedItemTitleColor = unSelectedItemTitleColor;
    [self setupEndColor:_unSelectedItemTitleColor];
    for (SPItem *button in self.buttons) {
        if (button == _selectedButton) {
            continue;  // 跳过选中的那个button
        }
        [button setTitleColor:unSelectedItemTitleColor forState:UIControlStateNormal];
    }
}

- (void)setSelectedItemIndex:(NSInteger)selectedItemIndex {
    _selectedItemIndex = selectedItemIndex;
    if (self.buttons.count) {
        SPItem *button = [self.buttons objectAtIndex:selectedItemIndex];
        [self buttonInPageMenuClicked:button];
    }
}

- (void)setDelegate:(id<SPPageMenuDelegate>)delegate {
    if (delegate == _delegate) {return;}
    _delegate = delegate;
    if (self.buttons.count) {
        SPItem *button = [self.buttons objectAtIndex:_selectedItemIndex];
        [self delegatePerformMethodWithFromIndex:button.tag-tagBaseValue toIndex:button.tag-tagBaseValue];
        [self moveItemScrollViewWithSelectedButton:button];
        //[self buttonInPageMenuClicked:button];
    }
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    _contentInset = contentInset;
    [self setNeedsLayout];
    [self layoutIfNeeded];
    // 修正scrollView偏移
    [self moveItemScrollViewWithSelectedButton:self.selectedButton];
}

- (void)setPermutationWay:(SPPageMenuPermutationWay)permutationWay {
    _permutationWay = permutationWay;
    [self setNeedsLayout];
    [self layoutIfNeeded];
    // 修正scrollView偏移
    [self moveItemScrollViewWithSelectedButton:self.selectedButton];
}

#pragma mark - getter

- (NSArray *)items {
    if (!_items) {
        _items = [NSMutableArray array];
    }
    return _items;
}

- (NSMutableArray *)buttons {
    
    if (!_buttons) {
        _buttons = [NSMutableArray array];
        
    }
    return _buttons;
}

- (NSMutableDictionary *)setupWidths {
    
    if (!_setupWidths) {
        _setupWidths = [NSMutableDictionary dictionary];
    }
    return _setupWidths;
}

- (UIImageView *)tracker {
    
    if (!_tracker) {
        _tracker = [[UIImageView alloc] init];
        _tracker.layer.cornerRadius = _trackerHeight * 0.5;
        _tracker.layer.masksToBounds = YES;
    }
    return _tracker;
}

- (NSUInteger)numberOfItems {
    return self.items.count;
}

#pragma mark - 布局

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat backgroundViewX = self.bounds.origin.x+_contentInset.left;
    CGFloat backgroundViewY = self.bounds.origin.y+_contentInset.top;
    CGFloat backgroundViewW = self.bounds.size.width-(_contentInset.left+_contentInset.right);
    CGFloat backgroundViewH = self.bounds.size.height-(_contentInset.top+_contentInset.bottom);
    self.backgroundView.frame = CGRectMake(backgroundViewX, backgroundViewY, backgroundViewW, backgroundViewH);
    
    CGFloat dividingLineW = self.bounds.size.width;
    CGFloat dividingLineH = (self.dividingLine.hidden || self.dividingLine.alpha < 0.01) ? 0 : _dividingLineHeight;
    CGFloat dividingLineX = 0;
    CGFloat dividingLineY = self.bounds.size.height-dividingLineH;
    self.dividingLine.frame = CGRectMake(dividingLineX, dividingLineY, dividingLineW, dividingLineH);

    CGFloat functionButtonH = backgroundViewH-dividingLineH;
    CGFloat functionButtonW = functionButtonH;
    CGFloat functionButtonX = backgroundViewW-functionButtonW;
    CGFloat functionButtonY = 0;
    self.functionButton.frame = CGRectMake(functionButtonX, functionButtonY, functionButtonW, functionButtonH);
    // 通过shadowPath设置功能按钮的单边阴影
    self.functionButton.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 2.5, 2, functionButtonH-5)].CGPath;

    CGFloat itemScrollViewX = 0;
    CGFloat itemScrollViewY = 0;
    CGFloat itemScrollViewW = self.showFuntionButton ? backgroundViewW-functionButtonW : backgroundViewW;
    CGFloat itemScrollViewH = backgroundViewH-dividingLineH;
    self.itemScrollView.frame = CGRectMake(itemScrollViewX, itemScrollViewY, itemScrollViewW, itemScrollViewH);
    
    // 存储itemScrollViewH,目的是解决选中按钮缩放后高度变化了的问题，我们要让选中的按钮缩放之后，依然保持原始高度
    _itemScrollViewH = itemScrollViewH;

    __block CGFloat buttonW = 0.0;
    __block CGFloat lastButtonMaxX = 0.0;
    
    CGFloat contentW = 0.0; // 内容宽
    CGFloat contentW_sum = 0.0; // 所有文字宽度之和
    NSMutableArray *buttonWidths = [NSMutableArray array];
    // 提前计算每个按钮的宽度，目的是为了计算间距
    for (int i= 0 ; i < self.buttons.count; i++) {
        SPItem *button = self.buttons[i];
        
        CGFloat setupButtonW = [[self.setupWidths objectForKey:[NSString stringWithFormat:@"%d",i]] floatValue];
        CGFloat textW = [button.titleLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, itemScrollViewH) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_itemTitleFont} context:nil].size.width;
        // CGImageGetWidth获取的图片宽度是图片在@1x、@2x、@3x的位置上的实际宽度
        // button.currentImage.size.width获取的宽度永远是@1x位置上的宽度，比如一张图片在@3x上的位置为300,那么button.currentImage.size.width就为100
        CGFloat imageW = CGImageGetWidth(button.currentImage.CGImage);
        CGFloat imageH = CGImageGetHeight(button.currentImage.CGImage);
        CGFloat ratio = imageW / imageH;
        if (ratio >= 1) { // 宽大于高
            if (imageH > itemScrollViewH) { // 按比例适应在button中
                imageH = itemScrollViewH;
                imageW = imageH * ratio;
            }
        }
        if (button.currentTitle && !button.currentImage) {
            contentW = textW;
        } else if(button.currentImage && !button.currentTitle) {
            contentW = imageW;
        } else if (button.currentTitle && button.currentImage && (button.imagePosition == SPItemImagePositionRight || button.imagePosition == SPItemImagePositionLeft)) {
            contentW = textW + imageW;
        } else if (button.currentTitle && button.currentImage && (button.imagePosition == SPItemImagePositionTop || button.imagePosition == SPItemImagePositionBottom)) {
            contentW = MAX(textW, imageW);
        }
        if (setupButtonW) {
            contentW_sum += setupButtonW;
            [buttonWidths addObject:@(setupButtonW)];
        } else {
            contentW_sum += contentW;
            [buttonWidths addObject:@(contentW)];
        }
    }
    CGFloat diff = itemScrollViewW - contentW_sum;
    
    [self.buttons enumerateObjectsUsingBlock:^(SPItem *button, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat setupButtonW = [[self.setupWidths objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)idx]] floatValue];
        if (self.permutationWay == SPPageMenuPermutationWayScrollAdaptContent) {
            buttonW = [buttonWidths[idx] floatValue];
            if (idx == 0) {
                button.frame = CGRectMake(self->_itemPadding*0.5+lastButtonMaxX, 0, buttonW, itemScrollViewH);
            } else {
                button.frame = CGRectMake(self->_itemPadding+lastButtonMaxX, 0, buttonW, itemScrollViewH);

            }
        } else if (self.permutationWay == SPPageMenuPermutationWayNotScrollEqualWidths) {
            // 求出外界设置的按钮宽度之和
            CGFloat totalSetupButtonW = [[self.setupWidths.allValues valueForKeyPath:@"@sum.floatValue"] floatValue];
            // 如果该按钮外界设置了宽，则取外界设置的，如果外界没设置，则其余按钮等宽
            buttonW = setupButtonW ? setupButtonW : (itemScrollViewW-self->_itemPadding*(self.buttons.count)-totalSetupButtonW)/(self.buttons.count-self.setupWidths.count);
            if (buttonW < 0) { // 按钮过多时,有可能会为负数
                buttonW = 0;
            }
            if (idx == 0) {
                button.frame = CGRectMake(self->_itemPadding*0.5+lastButtonMaxX, 0, buttonW, itemScrollViewH);
            } else {
                button.frame = CGRectMake(self->_itemPadding+lastButtonMaxX, 0, buttonW, itemScrollViewH);
            }
            
        } else {
            self->_itemPadding = diff/self.buttons.count;
            buttonW = [buttonWidths[idx] floatValue];
            if (idx == 0) {
                button.frame = CGRectMake(self->_itemPadding*0.5+lastButtonMaxX, 0, buttonW, itemScrollViewH);
            } else {
                button.frame = CGRectMake(self->_itemPadding+lastButtonMaxX, 0, buttonW, itemScrollViewH);
            }
        }
        lastButtonMaxX = CGRectGetMaxX(button.frame);
    }];
    
    // 如果selectedButton有缩放，走完上面代码selectedButton的frame会还原，这会导致文字显示不全问题，为了解决这个问题，这里将selectedButton的frame强制缩放
    if (!CGAffineTransformEqualToTransform(self.selectedButton.transform, CGAffineTransformIdentity)) {
        CGRect selectedButtonRect = self.selectedButton.frame;
        selectedButtonRect.origin.y = selectedButtonRect.origin.y-(selectedButtonRect.size.height*_selectedItemZoomScale - selectedButtonRect.size.height)/2;
        selectedButtonRect.origin.x = selectedButtonRect.origin.x-((selectedButtonRect.size.width*_selectedItemZoomScale - selectedButtonRect.size.width)/2);
        selectedButtonRect.size = CGSizeMake(selectedButtonRect.size.width * _selectedItemZoomScale, selectedButtonRect.size.height*_selectedItemZoomScale);
        self.selectedButton.frame = selectedButtonRect;
    }
    
    [self resetSetupTrackerFrameWithSelectedButton:self.selectedButton];
    
    self.itemScrollView.contentSize = CGSizeMake(lastButtonMaxX+_itemPadding*0.5, 0);
    
    if (self.translatesAutoresizingMaskIntoConstraints == NO) {
        
        [self moveItemScrollViewWithSelectedButton:self.selectedButton];
    }
}

- (void)resetSetupTrackerFrameWithSelectedButton:(SPItem *)selectedButton {
    
    CGFloat trackerX;
    CGFloat trackerY;
    CGFloat trackerW;
    CGFloat trackerH;
    
    CGFloat selectedButtonWidth = selectedButton.frame.size.width;
    
    switch (self.trackerStyle) {
        case SPPageMenuTrackerStyleLine:
        {
            trackerW = _trackerWidth ? _trackerWidth : selectedButtonWidth;
            trackerH = _trackerHeight;
            trackerX = selectedButton.frame.origin.x;
            trackerY = self.itemScrollView.bounds.size.height - trackerH;
            self.tracker.frame = CGRectMake(trackerX, trackerY, trackerW, trackerH);
        }
            break;
        case SPPageMenuTrackerStyleLineLongerThanItem:
        {
            trackerW = _trackerWidth ? _trackerWidth : (selectedButtonWidth+(selectedButtonWidth ? _itemPadding : 0));
            trackerH = _trackerHeight;
            trackerX = selectedButton.frame.origin.x;
            trackerY = self.itemScrollView.bounds.size.height - trackerH;
            self.tracker.frame = CGRectMake(trackerX, trackerY, trackerW, trackerH);
        }
            break;
        case SPPageMenuTrackerStyleLineAttachment:
        {
            trackerW = _trackerWidth ? _trackerWidth : (selectedButtonWidth ? selectedButton.titleLabel.font.pointSize : 0); // 没有自定义宽度就固定宽度为字体大小
            trackerH = _trackerHeight;
            trackerX = selectedButton.frame.origin.x;
            trackerY = self.itemScrollView.bounds.size.height - trackerH;
            self.tracker.frame = CGRectMake(trackerX, trackerY, trackerW, trackerH);
        }
            break;
        case SPPageMenuTrackerStyleRect:
        {
            trackerW = _trackerWidth ? _trackerWidth : (selectedButtonWidth+(selectedButtonWidth ? _itemPadding : 0));
            trackerH = _trackerHeight ? _trackerHeight : (selectedButton.frame.size.height);
            trackerX = selectedButton.frame.origin.x;
            trackerY = (_itemScrollViewH-trackerH)*0.5;
            self.tracker.frame = CGRectMake(trackerX, trackerY, trackerW, trackerH);
            self.tracker.layer.cornerRadius = 0;

        }
            break;
        case SPPageMenuTrackerStyleRoundedRect:
        {
            trackerH = _trackerHeight ? _trackerHeight : (_itemTitleFont.lineHeight+10);
            trackerW = _trackerWidth ? _trackerWidth : (selectedButtonWidth+_itemPadding);
            trackerX = selectedButton.frame.origin.x;
            trackerY = (_itemScrollViewH-trackerH)*0.5;
            self.tracker.frame = CGRectMake(trackerX, trackerY, trackerW, trackerH);
            self.tracker.layer.cornerRadius = MIN(trackerW, trackerH)*0.5;
            self.tracker.layer.masksToBounds = YES;
        }
            break;
        default:
            break;
    }
    
    CGPoint trackerCenter = self.tracker.center;
    trackerCenter.x = selectedButton.center.x;
    self.tracker.center = trackerCenter;
}

- (void)dealloc {
    [self.bridgeScrollView removeObserver:self forKeyPath:scrollViewContentOffset];
}

@end

#pragma clang diagnostic pop






