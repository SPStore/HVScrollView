//
//  UINavigationController+NavAlpha.h
//  MTransparentNav
//
//  Created by mengqingzheng on 2017/4/20.
//  Copyright © 2017年 mengqingzheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (NavAlpha)

@end


@interface UIViewController (NavAlpha)

// navAlpha
@property (nonatomic, assign) CGFloat navAlpha;

// navbackgroundColor
@property (null_resettable, nonatomic, strong) UIColor *navBarTintColor;

// tintColor
@property (null_resettable, nonatomic, strong) UIColor *navTintColor;

// titleColor
@property (null_resettable, nonatomic, strong) UIColor *navTitleColor;

@end
