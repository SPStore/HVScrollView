//
//  MyTableView.m
//  HVScrollView(仿微博)
//
//  Created by Libo on 2017/11/8.
//  Copyright © 2017年 iDress. All rights reserved.
//

#import "MyTableView.h"

@implementation MyTableView

// 这个方法是支持多手势，当滑动子控制器中的scrollView时，MyTableView也能接收滑动事件
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]];
}

@end
