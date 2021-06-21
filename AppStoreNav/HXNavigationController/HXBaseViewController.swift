//
//  HXBaseViewController.swift
//  HXNavigationController
//
//  Created by HongXiangWen on 2021/4/9.
//  Copyright © 2021 WHX. All rights reserved.
//

import UIKit

class HXBaseViewController: UIViewController{

    fileprivate var hx_navHidesSearchWhenScroll :Bool! = false
    private var _hx_statusBarStyle :UIBarStyle!
    private var _hx_navTintColor :UIColor!
    private var _hx_navTitleColor :UIColor!
    private var _hx_navTitleFont :UIFont!
    private var _hx_navBackgroundColor :UIColor!
    private var _hx_navBackgroundImage :UIImage!
    private var _hx_navBackImage :UIImage!
    private var _hx_navShowBackTitle :Bool!
    private var _hx_navBarAlpha :CGFloat!
    private var _hx_navLineHidden :Bool!
    private var _hx_navLineColor :UIColor!
    private var _hx_navShowShadow :Bool!
    private var _hx_navEnableLargeTitle :Bool!
    var hx_fakeNavBarFrame: CGRect?
    var hx_realNavBarFrame: CGRect?
    var hx_navEnablePopGesture :Bool! = true
    private var _hx_navLargeTitleTagView: UIImageView?
    private var _hx_navLargeTitleHeadView: UIView?
    
    fileprivate var navFrameObserver: NSKeyValueObservation?
    fileprivate var sgControlClick = false
    private var isDidAppear = false
    var appearState = 0//0-will;1-did
    deinit {
        if let tagView  = self.hx_navLargeTitleTagView {
            tagView.removeFromSuperview()
        }
        if let headView  = self.hx_navLargeTitleHeadView {
            headView.removeFromSuperview()
        }
        self.navFrameObserver = nil
    }
    // 导航栏样式，默认样式
    var hx_statusBarStyle: UIBarStyle! {
        get {
            return _hx_statusBarStyle ?? UINavigationBar.appearance().barStyle
        }
        set {
            _hx_statusBarStyle = newValue
            self.hx_setNeedsNavigationBarTintUpdate()
        }
    }
    // 导航栏前景色（item的文字图标颜色），默认黑色
    var hx_navTintColor: UIColor! {
        get {
            if let tintColor = _hx_navTintColor {
                return tintColor
            }
            if let tintColor = UINavigationBar.appearance().tintColor {
                return tintColor
            }
            return .black
        }
        set {
            _hx_navTintColor = newValue
            self.hx_setNeedsNavigationBarTintUpdate()
        }
    }
    // 导航栏前景色（item的文字图标颜色），默认黑色
    var hx_navTitleColor: UIColor! {
        get {
            if let titleColor = _hx_navTitleColor {
                return titleColor
            }
            if let titleColor = UINavigationBar.appearance().titleTextAttributes?[NSAttributedString.Key.foregroundColor] as? UIColor {
                return titleColor
            }
            return .black
        }
        set {
            _hx_navTitleColor = newValue
            self.hx_setNeedsNavigationBarTintUpdate()
        }
    }
    // 导航栏标题文字字体，默认17号粗体
    var hx_navTitleFont: UIFont {
        get {
            if let titleFont = _hx_navTitleFont {
                return titleFont
            }
            if let titleFont = UINavigationBar.appearance().titleTextAttributes?[NSAttributedString.Key.font] as? UIFont {
                return titleFont
            }
            return UIFont.boldSystemFont(ofSize: 17)
        }
        set {
            _hx_navTitleFont = newValue
            self.hx_setNeedsNavigationBarTintUpdate()
        }
    }
    // 导航栏背景色，默认白色
    var hx_navBackgroundColor: UIColor {
        get {
            if let backgroundColor = _hx_navBackgroundColor {
                return backgroundColor
            }
            if let backgroundColor = UINavigationBar.appearance().barTintColor {
                return backgroundColor
            }
            return .white
        }
        set {
            _hx_navBackgroundColor = newValue
            self.hx_setNeedsNavigationBarBackgroundUpdate()
        }
    }
    // 导航栏背景图片
    var hx_navBackgroundImage: UIImage? {
        get {
            return _hx_navBackgroundImage ?? UINavigationBar.appearance().backgroundImage(for: .default)
        }
        set {
            _hx_navBackgroundImage = newValue
            self.hx_setNeedsNavigationBarBackgroundUpdate()
        }
    }
    // 导航栏返回图片
    var hx_navBackImage: UIImage? {
        get {
            return _hx_navBackImage ?? UIImage.init(named: "imgBack")!
        }
        set {
            _hx_navBackImage = newValue
            self.hx_setNeedsNavigationBarTintUpdate()
        }
    }
    // 导航栏是否显示「返回」按钮，默认隐藏
    var hx_navShowBackTitle: Bool {
        get {
            return _hx_navShowBackTitle ?? true
        }
        set {
            _hx_navShowBackTitle = newValue
            self.hx_setNeedsNavigationBarTintUpdate()
        }
    }
    // 导航栏背景透明度，默认1
    var hx_navBarAlpha: CGFloat {
        get {
            return _hx_navBarAlpha ?? 1
        }
        set {
            _hx_navBarAlpha = newValue
            self.hx_setNeedsNavigationBarBackgroundUpdate()
        }
    }
    // 导航栏底部分割线是否隐藏，默认不隐藏
    var hx_navLineHidden: Bool {
        get {
            return _hx_navLineHidden ?? true
        }
        set {
            _hx_navLineHidden = newValue
            self.hx_setNeedsNavigationBarLineUpdate()
        }
    }
    // 导航栏底部分割线颜色
    var hx_navLineColor: UIColor {
        get {
            return _hx_navLineColor ?? .black
        }
        set {
            _hx_navLineColor = newValue
            self.hx_setNeedsNavigationBarLineUpdate()
        }
    }
    // 导航栏底阴影
    var hx_navShowShadow: Bool {
        get {
            return _hx_navShowShadow ?? false
        }
        set {
            _hx_navShowShadow = newValue
            self.hx_setNeedsNavigationBarShadowUpdate()
        }
    }
    
    // 是否开启大标题，默认false
    var hx_navEnableLargeTitle: Bool {
        get {
            return _hx_navEnableLargeTitle ?? false
        }
        set {
            _hx_navEnableLargeTitle = newValue
            self.hx_setNeedsNavigationBarTintUpdate()
        }
    }
    
    var hx_navLargeTitleTagView: UIImageView? {
        get {
            return _hx_navLargeTitleTagView
        }
        set {
            _hx_navLargeTitleTagView = newValue
        }
    }
    //
    var hx_navLargeTitleHeadView: UIView? {
        get {
            return _hx_navLargeTitleHeadView
        }
        set {
            _hx_navLargeTitleHeadView = newValue
        }
    }
}
extension HXBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.extendedLayoutIncludesOpaqueBars = true
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.appearState = 0
        if #available(iOS 13.0, *) {
            self.navigationController?.isModalInPresentation = self.hx_navEnableLargeTitle//禁止自动dis
        }
        if self.navigationItem.searchController != nil {
            
            if self.isDidAppear == false {
                self.navigationItem.hidesSearchBarWhenScrolling = false
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.appearState = 1
        if self.navigationItem.searchController != nil {
            if self.isDidAppear == false {
                self.navigationItem.hidesSearchBarWhenScrolling = self.hx_navHidesSearchWhenScroll
            }
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
            self.appearState = 2
            self.isDidAppear = true
        }
    }

}
extension HXBaseViewController {
    
    private func hx_setNeedsNavigationBarUpdate() {
        guard let naviController = navigationController as? HXNavigationController else { return }
        naviController.hx_updateNavigationBar(for: self)
    }

    // 更新文字、title颜色
    private func hx_setNeedsNavigationBarTintUpdate() {
        guard let naviController = navigationController as? HXNavigationController else { return }
        naviController.hx_updateNavigationBarTint(for: self)
    }

    // 更新背景
    private func hx_setNeedsNavigationBarBackgroundUpdate() {
        guard let naviController = navigationController as? HXNavigationController else { return }
        naviController.hx_updateNavigationBarBackground(for: self)
    }

    // 更新navLine
    private func hx_setNeedsNavigationBarLineUpdate() {
        guard let naviController = navigationController as? HXNavigationController else { return }
        naviController.hx_updateNavigationBarLine(for: self)
    }

    // 更新阴影
    private func hx_setNeedsNavigationBarShadowUpdate() {
        guard let naviController = navigationController as? HXNavigationController else { return }
        naviController.hx_updateNavigationShadow(for: self)
    }
}

extension HXBaseViewController {
    
    func tl_createSearchView(proxyVC:UIViewController? = nil ,resultVC:UIViewController? = nil ,placeStr:String? = nil ,text:String? = nil ,hidesSearch:Bool = false) {
        
        let searchController = UISearchController.init(searchResultsController: resultVC)
        searchController.delegate = (proxyVC as? UISearchControllerDelegate)
        searchController.searchResultsUpdater = (proxyVC as? UISearchResultsUpdating)
        searchController.searchBar.sizeToFit()
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.delegate = (proxyVC as? UISearchBarDelegate)
        searchController.searchBar.text = text
        searchController.searchBar.placeholder = placeStr
        searchController.searchBar.backgroundColor = UIColor.clear
        
        self.definesPresentationContext = true
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = hidesSearch
        self.hx_navHidesSearchWhenScroll = hidesSearch
    }
    func tl_createSegmentedControl(proxyVC:UIViewController ,items:[String] ,hidesSearch:Bool = false ,width:CGFloat = TLDeviceWidth - 30 ,sgControlBlock:BlockViewInNoOut = nil) {
        
        self.tl_createSearchView(proxyVC:proxyVC,hidesSearch: hidesSearch)
        self.navFrameObserver = self.navigationController?.navigationBar.observe(\.frame, options: [.new,.old], changeHandler: { [weak self] (obj, change) in
            guard let `self` = self else { return }
            guard let oldFrame = change.oldValue ,let newFrame = change.newValue else { return }

            if self.sgControlClick == true {
                self.sgControlClick = false
                if abs(oldFrame.height - newFrame.height) == 148 - 96 {
                    self.navigationController?.navigationBar.tlheight = oldFrame.height
                    UIView.animate(withDuration: 0.5) {
                        self.navigationController?.navigationBar.tlheight = newFrame.height
                        self.navigationController?.navigationBar.layoutIfNeeded()
                    }
                }
            }
        })
        
        let sgControl = UISegmentedControl.init(items: items)
        if #available(iOS 13.0, *) {
            sgControl.selectedSegmentTintColor = RedColor
        }else {
            sgControl.tintColor = RedColor
        }
        sgControl.backgroundColor = UIColor.clear
        sgControl.setTitleTextAttributes([.foregroundColor:BlackColor], for: .normal)
        sgControl.setTitleTextAttributes([.foregroundColor:UIColor.white], for: .selected)
        for subView in self.navigationItem.searchController!.searchBar.allSubViews {
            if NSStringFromClass(subView.classForCoder) == "UISearchBarTextField" {
                subView.isHidden = true
            }
        }

        sgControl.selectedSegmentIndex = 0
        self.navigationItem.searchController!.searchBar.addSubview(sgControl)
        sgControl.frame = CGRect.init(x: 15 ,y: (sgControl.superview!.tlheight - sgControl.tlheight)/2.0, width: width, height: sgControl.tlheight)

        sgControl.addTarget(proxyVC, action: #selector(sgControlClick(sgControl:)), for: .valueChanged)
        if sgControlBlock != nil {
            sgControlBlock!(sgControl)
        }
    }
    @objc func sgControlClick(sgControl:UISegmentedControl) {
        self.sgControlClick = true
        UIImpactFeedbackGenerator.init(style: .medium).impactOccurred()
    }
    func tl_createTitlteView(view: UIView) {
        self.navigationItem.titleView = view
    }
    func tl_createLeftViews(viewArr: [UIView]) {
        if 1 == viewArr.count {
            let item = UIBarButtonItem.init(customView: viewArr[0])
            self.navigationItem.leftBarButtonItems = [item];
        }else {
            let item0 = UIBarButtonItem.init(customView: viewArr[0])
            let item1 = UIBarButtonItem.init(customView: viewArr[1])
            let itemFix = UIBarButtonItem.init(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            itemFix.width = 15
            self.navigationItem.leftBarButtonItems = [item0, itemFix, item1]
        }
    }
    func tl_createRightViews(viewArr: [UIView]) {
        if 1 == viewArr.count {
            let item = UIBarButtonItem.init(customView: viewArr[0])
            self.navigationItem.rightBarButtonItems = [item]
        }else {
            let item0 = UIBarButtonItem.init(customView: viewArr[1])
            let item1 = UIBarButtonItem.init(customView: viewArr[0])
            let itemFix = UIBarButtonItem.init(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            itemFix.width = 15
            self.navigationItem.rightBarButtonItems = [item0, itemFix, item1]
        }
    }
}
