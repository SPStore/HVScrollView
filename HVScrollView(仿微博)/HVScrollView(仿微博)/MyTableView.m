//
//  MyTableView.m
//  HVScrollView(仿微博)
//
//  Created by Libo on 2017/11/8.
//  Copyright © 2017年 iDress. All rights reserved.
//

#import "MyTableView.h"

@implementation MyTableView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]];
}

@end
