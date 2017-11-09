//
//  HeaderContentView.m
//  HVScrollView
//
//  Created by Libo on 17/6/16.
//  Copyright © 2017年 iDress. All rights reserved.
//

#import "HeaderContentView.h"

@implementation HeaderContentView

#warning 如果子控件的子控件还有子控件，以此下去，同样超出父控件无法点击, 此问题应该由开发者自己判定.
// 重写该方法后可以让超出父视图范围的子视图响应事件
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil) {
        for (UIView *subView in self.subviews) {
            CGPoint tp = [subView convertPoint:point fromView:self];
            if (CGRectContainsPoint(subView.bounds, tp)) {
                view = subView;
            }
            for (UIView *subsubView in subView.subviews) {
                CGPoint tp = [subsubView convertPoint:point fromView:self];
                if (CGRectContainsPoint(subsubView.bounds, tp)) {
                    view = subsubView;
                }
            }
        }
    }
    return view;
}


@end
