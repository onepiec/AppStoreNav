# AppStoreNav

![AppStoreNav.gif](https://upload-images.jianshu.io/upload_images/3505762-73dc909530f41823.gif?imageMogr2/auto-orient/strip)



在我手机里，【AppStore】这款软件打开的频率虽然不是最高的，但是它是我认为做的最好的。它的亮眼之处在我看来有两点，一是首页的转场动画，我之前的文章里面已有所涉及，其二就是导航栏的动画。

现在众多的app里，为了省事，基本都是自定义导航，侧滑的时候，总感觉少了点味道。
而且苹果在iOS11上增加了大标题模式，现在在第三方app里，根本见不到其在里面的应用。

所以就有了这个导航栏框架，这是在[HXNavigationController](https://github.com/hxwxww/HXNavigationController)基础上进行修改的，拓展了大标题，导航Search，Segment，导航头像等功能。并且可以随意点切换哟。

###其中有几个注意点：
####注意点1：在实践过程中，发现在大标题模式下，用常规的第三方刷新控件会有UI方面的bug，所以在demo里面自己封装了一下系统的UIRefreshControl。在用系统的UIRefreshControl的过程中，发现只用```self.addSubview(refreshControl)```或者```self.refreshControl = refreshControl```，如果没有区分小/大标题时，会有问题产生，所以做了下兼容。
```
if inVC.hx_navEnableLargeTitle == true {
    self.refreshControl = refreshControl
    self.refreshCtrol = refreshControl
  }else {
    self.addSubview(refreshControl)
    self.refreshCtrol = refreshControl
}
```

####注意点2：UISegmentedControl其实是添加在UISearchController上面的，所以一定要实现它的代理并在代理```searchBarShouldBeginEditing```方法里面返回false，防止点击UISegment时出现键盘。

####注意点3：在各个模式切换时，【小标题】返回到【小标题+搜索模式】最为特殊，不得已做了相应的判断处理，大家可以在ViewController里面着重看一下```self.isLargeTitle == false && self.isShowSearch```这两个判断条件就可以了。
