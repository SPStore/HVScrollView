//
//  UINavigationBar+NavAlpha.m
//  MTransparentNav
//
//  Created by mengqingzheng on 2017/4/20.
//  Copyright © 2017年 mengqingzheng. All rights reserved.
//

#import "UINavigationBar+NavAlpha.h"

#define IOS10 [[[UIDevice currentDevice]systemVersion] floatValue] >= 10.0

@implementation UINavigationBar (NavAlpha)
static char *navAlphaKey = "navAlphaKey";
-(CGFloat)navAlpha {
    if (objc_getAssociatedObject(self, navAlphaKey) == nil) {
        return 1;
    }
    return [objc_getAssociatedObject(self, navAlphaKey) floatValue];
}
-(void)setNavAlpha:(CGFloat)navAlpha {
    CGFloat alpha = MAX(MIN(navAlpha, 1), 0);// 必须在 0~1的范围
    
    UIView *barBackground = self.subviews[0];
    if (self.translucent == NO || [self backgroundImageForBarMetrics:UIBarMetricsDefault] != nil) {
        barBackground.alpha = alpha;
        
    } else {
        
        if (IOS10) {
            UIView *effectFilterView = barBackground.subviews.lastObject;
            effectFilterView.alpha = alpha;
        } else {
            UIView *effectFilterView = barBackground.subviews.firstObject;
            effectFilterView.alpha = alpha;
        }
    }
    /// 黑线
    UIView *shadowView = [barBackground valueForKey:@"_shadowView"];
    shadowView.alpha = alpha;
    
    objc_setAssociatedObject(self, navAlphaKey, @(alpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
