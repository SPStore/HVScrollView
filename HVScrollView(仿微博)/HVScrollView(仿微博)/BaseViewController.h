//
//  BaseViewController.h
//  HVScrollView
//
//  Created by Libo on 17/6/13.
//  Copyright © 2017年 iDress. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJRefresh.h"

#define PageMenuH 40
#define NaviH 64
#define HeaderViewH 200

#define isIPhoneX kScreenH==812
#define insert (isIPhoneX ? (84+34+PageMenuH) : 0)

@interface BaseViewController : UIViewController

@end
