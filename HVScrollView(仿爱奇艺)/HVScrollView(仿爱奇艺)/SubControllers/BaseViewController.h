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

@interface BaseViewController : UIViewController  <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) MyHeaderView *headerView;
@property (nonatomic, assign) CGPoint lastContentOffset;

@property (nonatomic, assign) BOOL isFirstViewLoaded;

@end
