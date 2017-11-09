//
//  BaseViewController.h
//  HVScrollView
//
//  Created by Libo on 17/6/14.
//  Copyright © 2017年 iDress. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyHeaderView.h"

#define isIPhoneX kScreenH==812
#define bottomMargin (isIPhoneX ? 34 : 0)

UIKIT_EXTERN NSNotificationName const ChildScrollViewDidScrollNSNotification;
UIKIT_EXTERN NSNotificationName const ChildScrollViewRefreshStateNSNotification;

@interface BaseViewController : UIViewController
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) MyHeaderView *headerView;
@property (nonatomic, assign) CGPoint lastContentOffset;

@property (nonatomic, assign) BOOL isFirstViewLoaded;

@property (nonatomic, assign) BOOL refreshState;

@end
