//
//  MyHeaderView.m
//  HVScrollView
//
//  Created by Libo on 17/6/14.
//  Copyright © 2017年 iDress. All rights reserved.
//

#import "MyHeaderView.h"

@interface MyHeaderView()
@end

@implementation MyHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        self.button.frame = CGRectMake(0, 0, 60, 30);
        self.button.backgroundColor = [UIColor yellowColor];
        [self.button setTitle:@"点我" forState:UIControlStateNormal];
        [self.button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self addSubview:self.button];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.button.center = CGPointMake(self.bounds.size.width*0.5, self.bounds.size.height*0.5);
}

@end
