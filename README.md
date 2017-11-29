
前不久腾讯Bugly发布过一篇文章[特斯拉组件](http://mp.weixin.qq.com/s/hBgvPBP12IQ1s65ru-paWw)，这个组件跟我要实现的界面是相同的，但是这文章写得很简单，也没有贡献出demo，也没有封装框架，反正我看完后还是一脸懵逼。如果你能看懂，或者看完后有了灵感，你足够自信的话，你可以去封装，我是自认菜鸟，封装这玩意儿难度真不是盖的，我写这3个程序都花了整整5天，而且后期还有过改动，不断的试，只要思路一错，就得重来，换一种思路。

这种界面在不少app上都有出现，比如微博、美团、饿了么、爱奇艺等，我实现的过程中没有一句高深莫测的代码，难就难在思路，层级结构上；
这种界面有3样控件是最为显眼的：头视图，悬浮菜单，若干个子tableView
## 微博    难度系数： ★★★★
* 层级结构描述    
首先是一个父控制器，父控制上添加一个大tableView，头视图就作为tableView的tableHeaderView，这个大tableView只有一个cell，这个cell上添加一个横向滑动的scrollView，scrollView就用来添加若干个子控制器，每个子控制器都有一个tableView,称为子tableView。其中，父控制器的大tableView必须实现下面这个手势代理方法:
```
// 这个方法是支持多手势，当滑动子控制器中的scrollView时，MyTableView也能接收滑动事件
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]];
}
```
* 重要功能
    1. 垂直方向上能够整体滑动，头部依然能够整体上下滑，滑动头部也就是滑动大tableView
    2. 头部能够触发事件
    3. 支持整体和局部刷新(局部刷新是指刷新的文字显示在悬浮菜单之下，而非导航栏之下)
    4. 横向切换tableView，当切换其余tableView再次回到原tableView时不记录原先位置，直接从第0行开始
* 效果图   
![image](https://github.com/SPStore/HVScrollView/blob/master/微博.gif)
## 美团    难度系数：★★★★★★★
* 层级结构描述    
首先是一个父控制器，父控制器添加一个横向滑动的全屏scrollView，再添加头视图和悬浮菜单，也就是，这个横向滑动的scrollView，头视图和悬浮菜单都添加在父控制器的view上.横向滑动的scrollView就是用来添加子控制器,每个子控制器有一个tableView。
* 重要功能
    1. 垂直方向上局部滑动，头部具有平移手势，可以通过平移整体上下滑动，但是不具备scrollView的弹性效果
    2. 头部能够触发事件
    3. 仅支持局部刷新
    4. 横向切换tableView，当切换其余tableView再次回到原tableView时要记录原先位置
* 效果图   
![image](https://github.com/SPStore/HVScrollView/blob/master/美团.gif)
## 爱奇艺    难度系数：★★★★★★★★★★
* 层级结构描述        
首先是一个父控制器，父控制器上添加一个全屏的横向滑动的scrollView，这个横向滑动的scrollView用来添加若干个子控制器，每个子控制器上有个tabelView。**头视图首先添加在第一个子控制器的tableView的tabelHeaderView上**，当横向切换scrollView时，头视图的x值需要改变，改变的方向与scrollView横向滑动的方向相反，否则头视图会跟着scrollView一起横向滑动，当滑动结束时，切换头视图的父视图为下一个控制器的tableView的tableHeaderView。悬浮菜单添加在父控制器上。
* 重要功能
    1. 垂直方向上能够整体滑动，头部可以整体上下滑动，具备scrollView的弹性效果，滑动头部实际上是滑动子tableVeiw
    2. 头部能够触发事件
    3. 仅支持整体刷新，刷新时大scrollView不能横向切换
    4. 横向切换tableView，当切换其余tableView再次回到原tableView时要记录原先位置
* 效果图   
![image](https://github.com/SPStore/HVScrollView/blob/master/爱奇艺.gif)

*爱奇艺难就难在头部的处理上，如果像美团一样，将头视图添加在父控制器的view上，当先添横向scrollView，再添加头视图时，那么头视图会遮挡横向滑动的scrollView，从而滑动头部的时候就不能上下滑动，只能通过添加手势，但是手势很难达到scrollView的弹性效果，滑动起来很僵硬；当先添加头视图，再添加横向scrollView时，横向scrollView又会把头视图遮挡，从而导致头视图不具备任何事件.*

## 美团和爱奇艺的若干个子tableView联动原理
当滑动其中一个子tableView时（我叫它主动tableView），发出一个通知，该通知由父控制器监听，在父控制器中遍历每个子tableVeiw（除去主动tableView之外的其余tableView叫被动tableView），让被动tableView跟随主动tableView滑动，当滑动到顶部，让悬浮菜单悬停。

大家在参考这3个demo的时候，悬浮菜单尽量使用[SPPageMenu](https://github.com/SPStore/SPPageMenu)，这是我自己封装的一个框架


