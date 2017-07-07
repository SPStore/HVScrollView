//
//  UINavigationController+NavAlpha.m
//  MTransparentNav
//
//  Created by mengqingzheng on 2017/4/20.
//  Copyright © 2017年 mengqingzheng. All rights reserved.
//

#import "UINavigationController+NavAlpha.h"
#import "UINavigationBar+NavAlpha.h"
@implementation UINavigationController (NavAlpha)

/// UINavigationBar
-(void)navigationBar:(UINavigationBar *)navigationBar didPopItem:(UINavigationItem *)item {
    navigationBar.tintColor = self.topViewController.navTintColor;
    navigationBar.barTintColor = self.topViewController.navBarTintColor;
    navigationBar.navAlpha = self.topViewController.navAlpha;
}
-(BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPushItem:(UINavigationItem *)item {
    navigationBar.tintColor = self.topViewController.navTintColor;
    navigationBar.barTintColor = self.topViewController.navBarTintColor;
    navigationBar.navAlpha = self.topViewController.navAlpha;
    return YES;
}

@end

#pragma mark - UIViewController + NavAlpha

static char *vcAlphaKey = "vcAlphaKey";
static char *vcColorKey = "vcColorKey";
static char *vcNavtintColorKey = "vcNavtintColorKey";
static char *vcTitleColorKey = "vcTitleColorKey";

@implementation UIViewController (NavAlpha)

-(CGFloat)navAlpha {
    if (objc_getAssociatedObject(self, vcAlphaKey) == nil) {
        return 1;
    }
    return [objc_getAssociatedObject(self, vcAlphaKey) floatValue];
}
-(void)setNavAlpha:(CGFloat)navAlpha {
    CGFloat alpha = MAX(MIN(navAlpha, 1), 0);// 0~1
    self.navigationController.navigationBar.navAlpha = alpha;
    objc_setAssociatedObject(self, vcAlphaKey, @(alpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

/// backgroundColor
-(UIColor *)navBarTintColor {
    UIColor *color = objc_getAssociatedObject(self, vcColorKey);
    if (color == nil) {
        color = [UINavigationBar appearance].barTintColor;
    }
    return color;
}
-(void)setNavBarTintColor:(UIColor *)navBarTintColor {
    self.navigationController.navigationBar.barTintColor = navBarTintColor;
    objc_setAssociatedObject(self, vcColorKey, navBarTintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

/// tintColor
-(UIColor *)navTintColor {
    UIColor *color = objc_getAssociatedObject(self, vcNavtintColorKey);
    if (color == nil) {
        color = [UINavigationBar appearance].tintColor;
    }
    return color;
}
-(void)setNavTintColor:(UIColor *)tintColor {
    self.navigationController.navigationBar.tintColor = tintColor;
    objc_setAssociatedObject(self, vcNavtintColorKey, tintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// titleColor
- (UIColor *)navTitleColor {
    UIColor *color = objc_getAssociatedObject(self, vcTitleColorKey);
    
    if (color == nil) {
        color = self.navigationController.navigationBar.titleTextAttributes[NSForegroundColorAttributeName];
    }
    return color;
}

- (void)setNavTitleColor:(UIColor *)navTitleColor {
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = navTitleColor;
    [self.navigationController.navigationBar setTitleTextAttributes:textAttrs];
    objc_setAssociatedObject(self, vcTitleColorKey, navTitleColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}

@end
