//
//  BaseViewController.h
//  HVScrollView
//
//  Created by Libo on 17/6/13.
//  Copyright © 2017年 iDress. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) CGPoint lastContentOffset;

@end
