//
//  SPPageMenu.m
//  SPPageMenu
//
//  Created by leshengping on 16/12/17.
//  Copyright © 2016年 leshengping. All rights reserved.
//

#import "SPPageMenu.h"

@interface SPPageMenu()

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIScrollView *scrollView;

/** 该数组中装的是字符串 */
@property (nonatomic, strong) NSArray<NSString *> *menuTitleArray;
/** 跟踪器(跟踪button的下划线) */
@property (nonatomic, weak) UIView *tracker;
/** 分割线 */
@property (nonatomic, weak) UIView *breakline;
/** 选中的button */
@property (nonatomic, strong) UIButton *selectedButton;

/** 装载menuButton的数组 */
@property (nonatomic, strong) NSMutableArray<UIButton *> *menuButtonArray;

/** 用来判断外界有没有设置firstButtonX */
@property (nonatomic, assign, getter=isSettedFirstButtonX) BOOL settedFirstButtonX;
/** 用来判断外界有没有设置spacing */
@property (nonatomic, assign, getter=isSettedspacing) BOOL settedspacing;

@end

static NSInteger tagIndex = 2016;

@implementation SPPageMenu

#pragma mark - 初始化方法
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
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

// 初始化设置
- (void)initialize {
    _buttonFont = [UIFont systemFontOfSize:15];
    _selectedTitleColor = [UIColor redColor];
    _unSelectedTitleColor = [UIColor blackColor];
    _breaklineColor = [UIColor lightGrayColor];
    _showBreakline = YES;
    _openAnimation = NO;
    _showTracker = YES;
    _trackerHeight = 2.0f;
    _animationSpeed = 0.25;
    _trackerColor = _selectedTitleColor;
    _spacing = 30.0f;
    _firstButtonX = 0.5 * _spacing;
    _allowBeyondScreen = YES;
    _equalWidths = YES;
    
    [self setupSubView];
}


- (void)setupSubView {
    // 背景view
    UIView *backgroundView = [[UIView alloc] init];
    [self addSubview:backgroundView];
    self.backgroundView = backgroundView;
    
    // 创建分割线。这个分割线起着很重要的作用，起初我并没有创建一个单独的view作为分割线，而是利用backgroundView与其子控件scrollView之间的底部设置一定的间隙，造成分割线的效果。但是这样会产生一个很严重的隐患。如果不单独创建分割线，那么backgroundView的第一个子控件将会是scrollView，而正好外界把这个封装好的菜单添加为控制器view的第一个子控件，在默认情况下，外界控制器的导航栏会将scrollView里面的内容往下压64。而此菜单栏的高度一般不会设置很高(<64)，这就会导致scrollView里面的子控件看不见。因此，必须使得backgroundView的第一个子控件不是scrollView。
    UIView *breakLine = [[UIView alloc] init];
    breakLine.backgroundColor = _breaklineColor;
    [self.backgroundView addSubview:breakLine];
    self.breakline = breakLine;
    
    // 创建承载菜单button的scrollView
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    [backgroundView addSubview:scrollView];
    self.scrollView = scrollView;
    scrollView.backgroundColor = [UIColor clearColor];
    
    [self layoutIfNeeded];
    
}

#pragma mark - public method
// 此方法是留给外界的接口，以创建菜单栏
+ (SPPageMenu *)pageMenuWithFrame:(CGRect)frame array:(NSArray *)array {
    SPPageMenu *menu = [[SPPageMenu alloc] initWithFrame:frame];
    menu.menuTitleArray = array;
    return menu;
}

- (void)setMenuTitleArray:(NSArray<NSString *> *)menuTitleArray {
    _menuTitleArray = menuTitleArray;
    [self configureMenuButtonToScrollView];
}


#pragma mark - private method
// 添加以及配置menubutton的相关属性
- (void)configureMenuButtonToScrollView {

    // 创建button
    CGFloat lastMenuButtonMaxX = 0.0f;
    for (int i = 0; i < _menuTitleArray.count; i++) {
        UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        menuButton.tag = tagIndex + i;
        [menuButton addTarget:self action:@selector(menuBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [menuButton setTitle:self.menuTitleArray[i] forState:UIControlStateNormal];
        menuButton.backgroundColor = [UIColor clearColor];
        menuButton.titleLabel.font = _buttonFont;
        menuButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [menuButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [menuButton sizeToFit];
        
        [self.scrollView addSubview:menuButton];
        [self.menuButtonArray addObject:menuButton];
        
        // 设置button的frame
        [self setupMenuButtonFrame:menuButton
                              font:_buttonFont
                lastMenuButtonMaxX:lastMenuButtonMaxX
                             index:i];
        // 记录此时menuButton的最大x值
        lastMenuButtonMaxX = CGRectGetMaxX(menuButton.frame);
        // 设置scrollView的容量
        self.scrollView.contentSize = CGSizeMake(lastMenuButtonMaxX + _firstButtonX, 0);
    }

    // 创建跟踪器
    [self creatTracker:self.scrollView.subviews.firstObject];
    
    [self menuBtnClick:self.scrollView.subviews.firstObject];
}

// 创建跟踪器
- (void)creatTracker:(UIButton *)button {

    UIView *tracker = [[UIView alloc] init];
    self.tracker = tracker;
    tracker.backgroundColor = _trackerColor;
    // 设置tracker的frame
    [self setupTrackerFrame:button];
 
    [self.scrollView addSubview:tracker];
    
}

// button的点击方法
- (void)menuBtnClick:(UIButton *)button {
    // 是不是第一次进入,先默认为YES
    static BOOL firstEnter = YES;
    
    // 执行代理方法
    [self delegatePerformMethodWithFromIndex:self.selectedButton.tag - tagIndex
                                     toIndex:button.tag - tagIndex];
    // 回调block
    if (self.buttonClickedBlock) {
        self.buttonClickedBlock(button.tag - tagIndex);
    }
    
    if (self.buttonClicked_from_to_Block) {
        self.buttonClicked_from_to_Block(self.selectedButton.tag - tagIndex,button.tag - tagIndex);
    }
    
    // 如果点击的是同一个button，retun掉，因为后面的操作没必要重复。
    if (self.selectedButton == button) {
        return;
    }
    
    if (!firstEnter) {
        // 移动跟踪器
        [self moveTracker:button];
    }
    
    // 给button添加缩放动画
    if (self.openAnimation) {
       [self openAnimationWithLastSelectedButton:self.selectedButton currentSelectedButton:button];
    }
    
    // 设置button的字体颜色
    [self setupButtonTitleColor:button];
    
    // 记录当前选中的button
    self.selectedButton = button;
    
    
    // 让scrollView发生偏移(重点）
    [self moveScrollViewWithSelectedButton:button];
    
    
    firstEnter = NO;
}

- (void)setupButtonTitleColor:(UIButton *)button {
    
    [self.selectedButton setTitleColor:_unSelectedTitleColor forState:UIControlStateNormal];
    [button setTitleColor:_selectedTitleColor forState:UIControlStateNormal];
    
}

- (void)delegatePerformMethodWithFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    if ([self.delegate respondsToSelector:@selector(pageMenu:buttonClickedAtIndex:)]) {
        [self.delegate pageMenu:self buttonClickedAtIndex:toIndex];
    }
    if ([self.delegate respondsToSelector:@selector(pageMenu:buttonClickedFromIndex:toIndex:)]) {
        [self.delegate pageMenu:self buttonClickedFromIndex:fromIndex toIndex:toIndex];
    }
}


- (void)moveTracker:(UIButton *)button {
    [UIView animateWithDuration:_animationSpeed animations:^{
        CGPoint trackerCenter = self.tracker.center;
        CGRect trackerFrame = self.tracker.frame;
        trackerCenter.x = button.center.x;
        trackerFrame.size.width = button.frame.size.width+_spacing;
        self.tracker.frame = trackerFrame;
        self.tracker.center = trackerCenter;
    }];
}


// 点击button让scrollView发生偏移
- (void)moveScrollViewWithSelectedButton:(UIButton *)selectedButton {
    // CGRectGetMidX(self.scrollView.frame)指的是屏幕水平中心位置，它的值是固定不变的
    // 选中button的中心x值与scrollView的中心x值之差
    CGFloat offSetX = selectedButton.center.x - CGRectGetMidX(self.scrollView.frame);
    // scrollView的容量宽与自身宽之差(难点)
    CGFloat maxOffsetX = self.scrollView.contentSize.width - self.scrollView.frame.size.width;
    // 如果选中的button中心x值小于或者等于scrollView的中心x值，或者scrollView的容量宽度小于scrollView本身，此时点击button时不发生任何偏移，置offSetX为0
    if (offSetX <= 0 || maxOffsetX <= 0) {
        offSetX = 0;
    }
    // 如果offSetX大于maxOffsetX,说明scrollView已经滑到尽头，此时button也不发生任何偏移了
    else if (offSetX > maxOffsetX){
        offSetX = maxOffsetX;
    }
    
    [self.scrollView setContentOffset:CGPointMake(offSetX, 0) animated:YES];
}

// 设置tracker的frame
- (void)setupTrackerFrame:(UIButton *)button {
    CGFloat trackerH = _trackerHeight;
    CGFloat trackerW = button.frame.size.width+_spacing;
    CGFloat trackerX = button.frame.origin.x-0.5*_spacing;
    CGFloat trackerY = self.scrollView.frame.size.height - trackerH;
    self.tracker.frame = CGRectMake(trackerX, trackerY, trackerW, trackerH);
}

- (void)setupMenuButtonFrame:(UIButton *)menuButton font:(UIFont *)buttonFont lastMenuButtonMaxX:(CGFloat)lastMenuButtonMaxX index:(NSInteger)index {
    // canScroll的状态决定着菜单中的button的布局方式
    // menuButton的宽度
    CGFloat menuButtonW = [menuButton.titleLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_buttonFont} context:nil].size.width;
    CGFloat menuButtonH = self.scrollView.frame.size.height-1;
    CGFloat menuButtonX = (index == 0) ? _firstButtonX : (lastMenuButtonMaxX + _spacing);
    CGFloat menuButtonY = 0;
    menuButton.frame = CGRectMake(menuButtonX, menuButtonY, menuButtonW, menuButtonH);
}

- (void)resetMenuButtonFrame {
    __block CGFloat lastMenuButtonMaxX = 0.0f;
    
    if (_allowBeyondScreen) { // 允许超出屏幕
        [self.menuButtonArray enumerateObjectsUsingBlock:^(UIButton * _Nonnull menuButton, NSUInteger idx, BOOL * _Nonnull stop) {
            menuButton.titleLabel.font = self.buttonFont;
            [self setupMenuButtonFrame:menuButton font:_buttonFont lastMenuButtonMaxX:lastMenuButtonMaxX index:idx];
            lastMenuButtonMaxX = CGRectGetMaxX(menuButton.frame);
        }];
    } else { // 不允许超出屏幕
        if (_equalWidths) { // 等宽
            [self.menuButtonArray enumerateObjectsUsingBlock:^(UIButton * _Nonnull menuButton, NSUInteger idx, BOOL * _Nonnull stop) {
                menuButton.titleLabel.font = self.buttonFont;
                
                CGFloat menuButtonW = (self.scrollView.frame.size.width-2*_firstButtonX-(self.menuTitleArray.count-1)*_spacing) / self.menuTitleArray.count;
                CGFloat menuButtonH = self.scrollView.frame.size.height-1;
                CGFloat menuButtonX = _firstButtonX + idx * (menuButtonW+_spacing);
                CGFloat menuButtonY = 0;
                menuButton.backgroundColor = [UIColor clearColor];
                menuButton.frame = CGRectMake(menuButtonX, menuButtonY, menuButtonW, menuButtonH);
            }];
        } else {  // 不等宽（根据文字返回宽度,间距自适应）
            CGFloat menuButtonW_Sum = 0;
            NSMutableArray *menuButtonW_Array = [NSMutableArray array];
            
            CGFloat scrollViewWidth = self.scrollView.frame.size.width;
            
            NSInteger count = self.menuTitleArray.count;
            // 提前计算button宽
            for (NSString *title in self.menuTitleArray) {
                CGFloat menuButtonW = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_buttonFont} context:nil].size.width;
                
                // 求出所有button的宽度之和，目的是算出间距
                menuButtonW_Sum += menuButtonW;
                [menuButtonW_Array addObject:@(menuButtonW)];
            }
            _spacing = (scrollViewWidth - menuButtonW_Sum-_firstButtonX*2) / (count-1);
            [self.menuButtonArray enumerateObjectsUsingBlock:^(UIButton * _Nonnull menuButton, NSUInteger idx, BOOL * _Nonnull stop) {
                CGFloat menuButtonW = [menuButtonW_Array[idx] floatValue];
                CGFloat menuButtonH = self.scrollView.frame.size.height-1;
                CGFloat menuButtonX;
                if (idx == 0) {
                    menuButtonX = _firstButtonX;
                } else {
                    menuButtonX = _spacing + lastMenuButtonMaxX;
                }
                CGFloat menuButtonY = 0;
                menuButton.frame = CGRectMake(menuButtonX, menuButtonY, menuButtonW, menuButtonH);
                lastMenuButtonMaxX = CGRectGetMaxX(menuButton.frame);
            }];
        }
        
    
    }
    
    // 设置scrollView的容量
    self.scrollView.contentSize = CGSizeMake(lastMenuButtonMaxX + _firstButtonX, 0);
}

#pragma mark - 基本布局
- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    
    self.backgroundView.frame = CGRectMake(0, 0, w, h);
    
    self.breakline.frame = CGRectMake(0, h - 1, w, 1);
    
    // 减_breaklineHeight是为了有分割线的效果
    self.scrollView.frame = CGRectMake(0, 0, w, h);
}


#pragma mark - setter方法
- (NSMutableArray *)menuButtonArray {
    if (!_menuButtonArray) {
        _menuButtonArray = [NSMutableArray array];
    }
    return _menuButtonArray;
}

// 设置button的间距
- (void)setspacing:(CGFloat)spacing {
    _spacing = spacing;
    
    // 外界是否设置了spacing，如果能进来，说明设置了. 因此在内部不要调用该set方法
    _settedspacing = YES;
    
    // 如果外界没有设置firstButtonX,默认为新的spacing的一半
    if (!_settedFirstButtonX) {
        _firstButtonX = 0.5 * spacing;
    }
    
    // 重设button的frame
    [self resetMenuButtonFrame];
    
    UIButton *menuButton = self.menuButtonArray.firstObject;
    [self setupTrackerFrame:menuButton];
}

// 设置第一个button的左间距
- (void)setFirstButtonX:(CGFloat)firstButtonX {
    _firstButtonX = firstButtonX;
    
    // 外界是否设置了firstButtonX，如果能进来，说明设置了. 因此在内部不要调用该set方法
    _settedFirstButtonX = YES;
    
    [self resetMenuButtonFrame];
    
    UIButton *menuButton = self.menuButtonArray.firstObject;
    [self setupTrackerFrame:menuButton];
}

// 设置字体，字体变了，button的frame和跟踪器的frame需要重新设置
- (void)setButtonFont:(UIFont *)buttonFont {
    _buttonFont = buttonFont;
    
    [self resetMenuButtonFrame];
    
    UIButton *menuButton = self.menuButtonArray.firstObject;
    [self setupTrackerFrame:menuButton];
}

// 设置选中的button文字颜色
- (void)setSelectedTitleColor:(UIColor *)selectedTitleColor {
    _selectedTitleColor = selectedTitleColor;
    
    [self.selectedButton setTitleColor:selectedTitleColor forState:UIControlStateNormal];
    self.tracker.backgroundColor = selectedTitleColor;
}

// 设置没有选中的button文字颜色
- (void)setUnSelectedTitleColor:(UIColor *)unSelectedTitleColor {
    _unSelectedTitleColor = unSelectedTitleColor;
    
    for (UIButton *menuButton in self.menuButtonArray) {
        if (menuButton == _selectedButton) {
            continue;  // 跳过选中的那个button
        }
        [menuButton setTitleColor:unSelectedTitleColor forState:UIControlStateNormal];
    }
}

// 设置分割线颜色
- (void)setBreaklineColor:(UIColor *)breaklineColor {
    _breaklineColor = breaklineColor;
    self.breakline.backgroundColor = breaklineColor;
}

// 设置是否显示分割线
- (void)setShowBreakline:(BOOL)showBreakline {
    _showBreakline = showBreakline;
    self.breakline.hidden = !showBreakline;
}

// 设置是否显示跟踪器
- (void)setShowTracker:(BOOL)showTracker {
    _showTracker = showTracker;
    self.tracker.hidden = !showTracker;
}

// 设置跟踪器的高度
- (void)setTrackerHeight:(CGFloat)trackerHeight {
    _trackerHeight = trackerHeight;
    
    CGRect trackerFrame = self.tracker.frame;
    trackerFrame.size.height = trackerHeight;
    trackerFrame.origin.y = self.scrollView.frame.size.height - trackerHeight;
    self.tracker.frame = trackerFrame;
}

// 设置跟踪器的颜色
- (void)setTrackerColor:(UIColor *)trackerColor {
    _trackerColor = trackerColor;
    self.tracker.backgroundColor = trackerColor;
}

// 设置是否开启动画
- (void)setOpenAnimation:(BOOL)openAnimation {
    _openAnimation = openAnimation;
    if (openAnimation) {
        // 取出第一个button
        UIButton *menuButton = [self.menuButtonArray firstObject];
        // 如果外界开启了动画，则给第一个button加上放大动画。如果不这样做，外界开启动画后，第一个button是不会有放大效果的，只有点击了其它button之后才会有动画效果。
        CABasicAnimation *animation = [self enlargeAnimation];
        [menuButton.titleLabel.layer addAnimation:animation forKey:@"animation"];
    } else {
        // 遍历所有的button，如果外界关闭了动画，则将所有button上动画移除
        [self.menuButtonArray enumerateObjectsUsingBlock:^(UIButton*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj.titleLabel.layer removeAllAnimations];
        }];
    }
}

// 返回放大的动画
- (CABasicAnimation *)enlargeAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.fromValue = [NSNumber numberWithFloat:1.0f];
    animation.toValue  = [NSNumber numberWithFloat:1.2f];
    animation.duration = 0.1;
    animation.repeatCount = 1;
    // 以下两个属性是让动画保持动画结束的状态
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.autoreverses = NO;
    return animation;
}

// 返回缩小动画
- (CABasicAnimation *)narrowAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.fromValue = [NSNumber numberWithFloat:1.2f];
    animation.toValue  = [NSNumber numberWithFloat:1.0f];
    animation.duration = 0.1;
    animation.repeatCount = 1;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.autoreverses = NO;
    return animation;
}

// 开启动画
- (void)openAnimationWithLastSelectedButton:(UIButton *)lastSelectedButton currentSelectedButton:(UIButton *)currentSelectedButton {
    CABasicAnimation *animation1 = [self enlargeAnimation];
    CABasicAnimation *animation2 = [self narrowAnimation];
    [lastSelectedButton.titleLabel.layer addAnimation:animation2 forKey:@"animation2"];
    [currentSelectedButton.titleLabel.layer addAnimation:animation1 forKey:@"animation1"];
}

// 是否允许超出屏幕
- (void)setAllowBeyondScreen:(BOOL)allowBeyondScreen {
    _allowBeyondScreen = allowBeyondScreen;
    // 如果不能超出屏幕，且外界没有设置spacing，让间距默认为0.
    if (!self.allowBeyondScreen && !_settedspacing) {
        _spacing = 0.0f;
        //_firstButtonX = 0.0f;
    }
    
    [self resetMenuButtonFrame];
    
    UIButton *menuButton = self.menuButtonArray.firstObject;
    [self setupTrackerFrame:menuButton];
}

// 是否让button等宽
- (void)setEqualWidths:(BOOL)equalWidths {
    _equalWidths = equalWidths;
    
    [self resetMenuButtonFrame];
    
    UIButton *menuButton = self.menuButtonArray.firstObject;
    [self setupTrackerFrame:menuButton];
}


#pragma mark － 提供给外界的方法
- (void)selectButtonAtIndex:(NSInteger)index{
    UIButton *selectedBtn = (UIButton *)self.menuButtonArray[index];
    [self menuBtnClick:selectedBtn];

}

- (void)moveTrackerFollowScrollView:(UIScrollView *)scrollView beginOffset:(CGFloat)beginOffset {

    // dragging是scrollView的一个属性， 如果为YES，说明用户中正在拖拽scrollView。
    // 如果用户在外面调用了这个方法 那么本方法会在点击菜单按钮的时候和用户拖拽外面的scrollView的时候调用.
    // 如果是用户点击菜单按钮进入的此方法，那dragging必然为NO(没有拖拽)，并且没有在减速，此时直接retun，让跟踪器跟着菜单按钮走。
    // 如果是用户在外面拖拽scrollView而进入的此方法，那dragging必然为YES(正在拖拽)，此时让跟踪器跟着scrollView的偏移量走
    // 当手指松开，decelerating属性为YES,表示scrolview正在减速
    if (!scrollView.dragging && !scrollView.decelerating) {
        return;
    }
    
    if (scrollView.contentOffset.x < 0 || scrollView.contentOffset.x > scrollView.contentSize.width-scrollView.bounds.size.width) {
        return;
    }
    
    CGFloat offSetX = scrollView.contentOffset.x;
    CGFloat tempProgress = offSetX / scrollView.bounds.size.width;
    CGFloat progress = tempProgress - floor(tempProgress);
    
    NSInteger oldIndex;
    NSInteger currentIndex;
    
    if (offSetX - beginOffset >= 0) { // 向左滑动
        oldIndex = offSetX / scrollView.bounds.size.width;
        currentIndex = oldIndex + 1;
        if (currentIndex >= self.menuTitleArray.count) {
            currentIndex = oldIndex - 1;
        }
        if (offSetX - beginOffset == scrollView.bounds.size.width) {// 滚动停止了
            progress = 1.0;
            currentIndex = oldIndex;
        }
    } else {  // 向右滑动
        currentIndex = offSetX / scrollView.bounds.size.width;
        oldIndex = currentIndex + 1;
        progress = 1.0 - progress;
        
    }
    
    [self moveTrackerWithProgress:progress fromIndex:oldIndex toIndex:currentIndex];
}

- (void)moveTrackerWithProgress:(CGFloat)progress fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    
    UIButton *oldButton = self.menuButtonArray[fromIndex];
    UIButton *currentButton = self.menuButtonArray[toIndex];
    
    CGFloat xDistance = currentButton.frame.origin.x - oldButton.frame.origin.x;
    CGFloat wDistance = currentButton.frame.size.width - oldButton.frame.size.width;
    
    
    CGRect newFrame = self.tracker.frame;
    newFrame.origin.x = oldButton.frame.origin.x + xDistance * progress - 0.5*_spacing;
    newFrame.size.width = oldButton.frame.size.width + wDistance * progress + _spacing;
    self.tracker.frame = newFrame;
}


@end





