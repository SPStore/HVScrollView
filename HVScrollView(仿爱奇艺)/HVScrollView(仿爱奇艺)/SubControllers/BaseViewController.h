//
//  BaseViewController.h
//  HVScrollView
//
//  Created by Libo on 17/6/14.
//  Copyright © 2017年 iDress. All rights reserved.
//  基类控制器

#import <UIKit/UIKit.h>
#import "MyHeaderView.h"
#import "HeaderContentView.h"

#define kHeaderViewH 200
#define kPageMenuH 40
#define kNaviH 0

#define isIPhoneX kScreenH==812
#define bottomMargin (isIPhoneX ? (84+34) : 64)

UIKIT_EXTERN NSNotificationName const ChildScrollViewDidScrollNSNotification;
UIKIT_EXTERN NSNotificationName const ChildScrollViewRefreshStateNSNotification;

@interface BaseViewController : UIViewController  <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) MyHeaderView *headerView;
@property (nonatomic, assign) CGPoint lastContentOffset;

@property (nonatomic, assign) BOOL isFirstViewLoaded;

@end
