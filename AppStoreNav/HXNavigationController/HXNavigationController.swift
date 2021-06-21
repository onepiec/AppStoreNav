//
//  HXNavigationController.swift
//  HXNavigationController
//
//  Created by HongXiangWen on 2018/12/17.
//  Copyright © 2018年 WHX. All rights reserved.
//

import UIKit
import SnapKit

class HXNavigationController: UINavigationController {

    // MARK: -  属性
    
    private lazy var fakeBar: HXFakeNavigationBar = {
        let fakeBar = HXFakeNavigationBar()
        return fakeBar
    }()
    
    private lazy var fromFakeBar: HXFakeNavigationBar = {
        let fakeBar = HXFakeNavigationBar()
        return fakeBar
    }()
    
    private lazy var toFakeBar: HXFakeNavigationBar = {
        let fakeBar = HXFakeNavigationBar()
        return fakeBar
    }()
    
    private var fakeSuperView: UIView? {
        get {
            return navigationBar.subviews.first
        }
    }
    
    private var isPopGesture: Bool = false
    private var largeTitleSuperView: UIView?
    private weak var poppingVC: UIViewController?
    private var fakeFrameObserver: NSKeyValueObservation?
    private var realFrameObserver: NSKeyValueObservation?
    // MARK: -  override

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        interactivePopGestureRecognizer?.delegate = self
        interactivePopGestureRecognizer?.addTarget(self, action: #selector(handleinteractivePopGesture(gesture:)))
        setupNavigationBar()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let coordinator = transitionCoordinator {
            guard let fromVC = coordinator.viewController(forKey: .from) else { return }
            if fromVC == poppingVC {
                hx_updateNavigationBar(for: fromVC)
            }
        } else {
            guard let topViewController = topViewController else { return }
            hx_updateNavigationBar(for: topViewController)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let lastVc:HXBaseViewController = self.viewControllers.last as? HXBaseViewController {
            if lastVc.appearState == 1 {
                return
            }
        }
        layoutFakeSubviews()
        initLargeTitleSuperView()
        initTagView()
        initHeadView()
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.viewControllers.count == 1 {//解决iOS14tabbar消失
            viewController.hidesBottomBarWhenPushed = true
        }else {
            viewController.hidesBottomBarWhenPushed = false
        }
        super.pushViewController(viewController, animated: animated)
    }
    override func popViewController(animated: Bool) -> UIViewController? {
  
        poppingVC = topViewController
        let viewController = super.popViewController(animated: animated)
        if let topViewController = topViewController {
            hx_updateNavigationBarTint(for: topViewController, ignoreTintColor: true)
        }
        return viewController
    }

    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
    
        poppingVC = topViewController
        let vcArray = super.popToRootViewController(animated: animated)
        if let topViewController = topViewController {
            hx_updateNavigationBarTint(for: topViewController, ignoreTintColor: true)
        }
        return vcArray
    }

    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
       
        poppingVC = topViewController
        let vcArray = super.popToViewController(viewController, animated: animated)
        if let topViewController = topViewController {
            hx_updateNavigationBarTint(for: topViewController, ignoreTintColor: true)
        }
        return vcArray
    }
    
}

// MARK: -  Private Methods
extension HXNavigationController {
    
    private func setupNavigationBar() {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        setupFakeSubviews()
        setupRealObserver()
    }
    
    private func setupFakeSubviews() {
        guard let fakeSuperView = fakeSuperView else { return }
        if fakeBar.superview == nil {
            fakeFrameObserver = fakeSuperView.observe(\.frame, changeHandler: { [weak self] (obj, changed) in
                guard let `self` = self else { return }
                self.layoutFakeSubviews()
            })
            fakeSuperView.insertSubview(fakeBar, at: 0)
        }
    }
    private func setupRealObserver() {
        
        realFrameObserver = self.navigationBar.observe(\.frame, options: [.new,.old], changeHandler: { [weak self] (obj, change) in
            guard let `self` = self else { return }
            guard let newFrame = change.newValue else { return }
            if let poppingVC:HXBaseViewController = self.topViewController as? HXBaseViewController,poppingVC.appearState < 2,let frame = poppingVC.hx_realNavBarFrame{
                if newFrame != frame {
                    poppingVC.navigationController?.navigationBar.frame = frame
                }
            }
        })
    }
    
    private func layoutFakeSubviews() {
        
        guard let fakeSuperView = fakeSuperView else { return }
        fakeBar.frame = fakeSuperView.bounds
        fakeBar.setNeedsLayout()
    }
    
    @objc private func handleinteractivePopGesture(gesture: UIScreenEdgePanGestureRecognizer) {

        guard let coordinator = transitionCoordinator,
              let fromVC:HXBaseViewController = coordinator.viewController(forKey: .from) as? HXBaseViewController,
              let toVC:HXBaseViewController = coordinator.viewController(forKey: .to) as? HXBaseViewController
        else {
            return
        }
        if gesture.state == .began {
            self.isPopGesture = true
        }else if gesture.state == .changed {
            navigationBar.tintColor = average(fromColor: fromVC.hx_navTintColor, toColor: toVC.hx_navTintColor, percent: coordinator.percentComplete)
            self.gestureChanged()
        }else if gesture.state == .ended {
            self.gestureEnded()
        }
    }
    
    private func average(fromColor: UIColor, toColor: UIColor, percent: CGFloat) -> UIColor {
        var fromRed: CGFloat = 0
        var fromGreen: CGFloat = 0
        var fromBlue: CGFloat = 0
        var fromAlpha: CGFloat = 0
        fromColor.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: &fromAlpha)
        var toRed: CGFloat = 0
        var toGreen: CGFloat = 0
        var toBlue: CGFloat = 0
        var toAlpha: CGFloat = 0
        toColor.getRed(&toRed, green: &toGreen, blue: &toBlue, alpha: &toAlpha)
        let red = fromRed + (toRed - fromRed) * percent
        let green = fromGreen + (toGreen - fromGreen) * percent
        let blue = fromBlue + (toBlue - fromBlue) * percent
        let alpha = fromAlpha + (toAlpha - fromAlpha) * percent
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    private func showViewController(_ viewController: UIViewController, coordinator: UIViewControllerTransitionCoordinator) {
        
        guard let fromVC = coordinator.viewController(forKey: .from),
            let toVC = coordinator.viewController(forKey: .to) else {
                return
        }
        let fromNavFrame = fromVC.navigationController?.navigationBar.frame
        resetButtonLabels(in: navigationBar)
        coordinator.animate(alongsideTransition: { (context) in
            
            self.hx_updateNavigationBarTint(for: viewController, ignoreTintColor: context.isInteractive)
            if viewController == toVC {
                self.showTempFakeBar(fromVC: fromVC, toVC: toVC)
            } else {
                self.hx_updateNavigationBarBackground(for: viewController)
                self.hx_updateNavigationBarLine(for: viewController)
            }
        }) { (context) in
            if context.isCancelled {
                self.hx_updateNavigationBar(for: fromVC)
                self.reloadNav(fromVC: fromVC, frame: fromNavFrame)
            } else {
                self.hx_updateNavigationBar(for: viewController)
            }
            if viewController == toVC {
                self.clearTempFakeBar()
            }
        }
    }
    
    private func showTempFakeBar(fromVC: UIViewController, toVC: UIViewController) {
        
        UIView.setAnimationsEnabled(false)
        fakeBar.alpha = 0
        // from
        fromVC.view.addSubview(fromFakeBar)
        fromFakeBar.frame = fakerBarFromFrame(for: fromVC)
        fromFakeBar.setNeedsLayout()
        if let fromVC:HXBaseViewController = fromVC as? HXBaseViewController {
            fromFakeBar.hx_updateFakeBarBackground(for: fromVC)
            fromFakeBar.hx_updateFakeBarLine(for: fromVC)
            fromFakeBar.hx_updateFakeBarShadow(for: fromVC)
            
        }
        // to
        toVC.view.addSubview(toFakeBar)
        toFakeBar.frame = fakerBarToFrame(for: toVC)//修改
        toFakeBar.setNeedsLayout()
        if let toVC:HXBaseViewController = toVC as? HXBaseViewController {
            toFakeBar.hx_updateFakeBarBackground(for: toVC)
            toFakeBar.hx_updateFakeBarLine(for: toVC)
            toFakeBar.hx_updateFakeBarShadow(for: toVC)
        }
        self.reloadToFakeBar(toVC: toVC)//修改
        self.saveFakeNavFrame(fromVC: fromVC)
        UIView.setAnimationsEnabled(true)
        
    }
    private func reloadToFakeBar(toVC: UIViewController) {
        if let toVC:HXBaseViewController = toVC as? HXBaseViewController {
            if toVC.hx_fakeNavBarFrame != nil {
                toFakeBar.frame = toVC.hx_fakeNavBarFrame!
                return
            }
            if CurrentVC(vc: toVC).cNavHeight == StatusNavHeight() {

                if toVC.navigationItem.searchController != nil && toVC.hx_navEnableLargeTitle == true{
                    toFakeBar.tlheight = 195
                }else if toVC.navigationItem.searchController != nil {
                    toFakeBar.tlheight = 143
                }else if toVC.hx_navEnableLargeTitle == true {
                    toFakeBar.tlheight = StatusNavHeight()
                }else if toVC.hx_navEnableLargeTitle == false {
                    toFakeBar.tlheight = StatusNavHeight()
                }
            }else {
                if toVC.navigationItem.searchController != nil && toVC.hx_navEnableLargeTitle == true{
                    toFakeBar.tlheight = 160
                }else if toVC.navigationItem.searchController != nil {
                    toFakeBar.tlheight = 108
                }else if toVC.hx_navEnableLargeTitle == true {
                    toFakeBar.tlheight = 56
                }else if toVC.hx_navEnableLargeTitle == false {
                    toFakeBar.tlheight = 56
                }
            }
        }
    }
    private func reloadNav(fromVC: UIViewController,frame:CGRect?) {
        if let fromVC:HXBaseViewController = fromVC as? HXBaseViewController,let frame = frame {
            fromVC.navigationController?.navigationBar.frame = frame
        }
    }
    private func reloadNav(toVC: UIViewController) {
        if let toVC:HXBaseViewController = toVC as? HXBaseViewController {
            if toVC.hx_realNavBarFrame != nil {
                toVC.navigationController?.navigationBar.frame = toVC.hx_realNavBarFrame!
                return
            }
            
            if CurrentVC(vc: toVC).cNavHeight == StatusNavHeight() {
                
                if toVC.hx_navEnableLargeTitle == true {
                    if toVC.navigationItem.searchController != nil {
                        toVC.navigationController?.navigationBar.tlheight = 148
                    }else{
                        if toVC.navigationController?.navigationBar.tlheight == 44 {
                            toVC.navigationController?.navigationBar.tlheight = 96
                        }
                    }
                }else {
                    if toVC.navigationItem.searchController != nil {
                        toVC.navigationController?.navigationBar.tlheight = 96
                    }else {
                        toVC.navigationController?.navigationBar.tlheight = 44
                    }
                    
                }
            }else{
                if toVC.hx_navEnableLargeTitle == true {
                    if toVC.navigationItem.searchController != nil {
                        toVC.navigationController?.navigationBar.tlheight = 160
                    }else{
                        if toVC.navigationController?.navigationBar.tlheight == 56 {
                            toVC.navigationController?.navigationBar.tlheight = 108
                        }
                    }
                }else {
                    if toVC.navigationItem.searchController != nil {
                        toVC.navigationController?.navigationBar.tlheight = 108
                    }else {
                        toVC.navigationController?.navigationBar.tlheight = 56
                    }
                }
            }
        }
    }
    private func saveFakeNavFrame(fromVC: UIViewController) {
        if let fromVC:HXBaseViewController = fromVC as? HXBaseViewController {
            fromVC.hx_fakeNavBarFrame = fromFakeBar.frame
        }
    }
    private func saveRealNavFrame(fromVC: UIViewController) {
        if let fromVC:HXBaseViewController = fromVC as? HXBaseViewController {
            fromVC.hx_realNavBarFrame = fromVC.navigationController?.navigationBar.frame
        }
    }
    private func clearTempFakeBar() {
        fakeBar.alpha = 1
        fromFakeBar.removeFromSuperview()
        toFakeBar.removeFromSuperview()
    }
    
    private func fakerBarFromFrame(for viewController: UIViewController) -> CGRect {
        
        guard let fakeSuperView = fakeSuperView else {
            return navigationBar.frame
        }
        var frame = navigationBar.convert(fakeSuperView.frame, to: viewController.view)
        frame.origin.x = viewController.view.frame.origin.x
        return frame
    }
    
    private func fakerBarToFrame(for viewController: UIViewController) -> CGRect {
        
        guard let fakeSuperView = fakeSuperView else {
            return navigationBar.frame
        }

        var frame = navigationBar.convert(fakeSuperView.frame, to: viewController.view)
        frame.origin.x = viewController.view.frame.origin.x
        return frame
    }
    
    private func resetButtonLabels(in view: UIView) {
        let viewClassName = view.classForCoder.description().replacingOccurrences(of: "_", with: "")
        if viewClassName == "UIButtonLabel" {
            view.alpha = 1
        } else {
            if view.subviews.count > 0 {
                for subview in view.subviews {
                    resetButtonLabels(in: subview)
                }
            }
        }
    }

}
// MARK: -  gesture
extension HXNavigationController {
    
    private func gestureChanged() {
        
        guard let coordinator = transitionCoordinator,
              let fromVC:HXBaseViewController = coordinator.viewController(forKey: .from) as? HXBaseViewController,
              let toVC:HXBaseViewController = coordinator.viewController(forKey: .to) as? HXBaseViewController else {
            return
        }

        fromVC.hx_navLargeTitleTagView?.alpha = 1 - coordinator.percentComplete
        fromVC.hx_navLargeTitleHeadView?.alpha = 1 - coordinator.percentComplete
        
        toVC.hx_navLargeTitleTagView?.alpha = coordinator.percentComplete
        toVC.hx_navLargeTitleHeadView?.alpha = coordinator.percentComplete

    }
    private func gestureEnded() {
        
        guard let coordinator = transitionCoordinator,
              let fromVC:HXBaseViewController = coordinator.viewController(forKey: .from) as? HXBaseViewController,
              let toVC:HXBaseViewController = coordinator.viewController(forKey: .to) as? HXBaseViewController else {
            return
        }
        
        fromVC.hx_navLargeTitleTagView?.alpha = coordinator.isCancelled == true ? 1 : 0
        fromVC.hx_navLargeTitleHeadView?.alpha = coordinator.isCancelled == true ? 1 : 0
        
        toVC.hx_navLargeTitleTagView?.alpha = coordinator.isCancelled == true ? 0 : 1
        toVC.hx_navLargeTitleHeadView?.alpha = coordinator.isCancelled == true ? 0 : 1
        
        self.isPopGesture = false
        
    }
    
}
// MARK: -  HeadView
extension HXNavigationController {
    
    private func initLargeTitleSuperView() {
        if self.largeTitleSuperView != nil {return}
        for subView in self.navigationBar.subviews {
            if NSStringFromClass(subView.classForCoder) == "_UINavigationBarLargeTitleView" {
                self.largeTitleSuperView = subView
                break
            }
        }
    }
    
    private func initTagView() {

        if let coordinator = transitionCoordinator {
            guard let fromVC:HXBaseViewController = coordinator.viewController(forKey: .from) as?       HXBaseViewController,
                  let toVC:HXBaseViewController = coordinator.viewController(forKey: .to) as? HXBaseViewController else { return }
            
            self.reloadTagView(fromVC: fromVC, toVC: toVC)
        }else {
            self.initTagView(with: self.children.last as! HXBaseViewController)
        }
    }
    private func initTagView(with vc:HXBaseViewController) {
        
        if self.largeTitleSuperView != nil {
            if vc.hx_navLargeTitleTagView != nil {
                
                if vc.hx_navLargeTitleTagView!.superview == nil {
                    vc.hx_navLargeTitleTagView?.alpha = 0
                    UIView.animate(withDuration: 0.5) {
                        vc.hx_navLargeTitleTagView?.alpha = 1
                    }
                    for subView in self.largeTitleSuperView!.allSubViews {
                        if let titleLab:UILabel = subView as? UILabel , titleLab.isUserInteractionEnabled == false {
                            subView.addSubview(vc.hx_navLargeTitleTagView!)//
                            vc.hx_navLargeTitleTagView!.snp.makeConstraints { (make) in
                                make.leading.equalTo(titleLab.snp.trailing).offset(5)
                                make.bottom.equalTo(-8)
                                make.size.equalTo(24)
                            }
                            break
                        }
                    }
                }else if vc.hx_navLargeTitleTagView?.alpha == 0 {
                    UIView.animate(withDuration: 0.5) {
                        vc.hx_navLargeTitleTagView?.alpha = 1
                    }
                }
            }
        }
    }
    private func reloadTagView(fromVC:HXBaseViewController ,toVC:HXBaseViewController) {

        if self.poppingVC == nil {//push
            UIView.animate(withDuration: 0.5) {
                fromVC.hx_navLargeTitleTagView?.alpha = 0
            }
        }else {//pop
            if self.isPopGesture == false {
                UIView.animate(withDuration: 0.5) {
                    fromVC.hx_navLargeTitleTagView?.alpha = 0
                }
            }
        }
        self.initTagView(with: toVC)
    }
    
    
    private func initHeadView() {

        if let coordinator = transitionCoordinator {
            guard let fromVC:HXBaseViewController = coordinator.viewController(forKey: .from) as?       HXBaseViewController,
                  let toVC:HXBaseViewController = coordinator.viewController(forKey: .to) as? HXBaseViewController else { return }
            
            self.reloadHeadView(fromVC: fromVC, toVC: toVC)
        }else {
            self.initHeadView(with: self.children.last as! HXBaseViewController)
        }
    }
    private func initHeadView(with vc:HXBaseViewController) {
        
        if self.largeTitleSuperView != nil {
            if vc.hx_navLargeTitleHeadView != nil {
                
                if vc.hx_navLargeTitleHeadView!.superview == nil {
                    self.largeTitleSuperView?.addSubview(vc.hx_navLargeTitleHeadView!)
                    vc.hx_navLargeTitleHeadView?.alpha = 0
                    UIView.animate(withDuration: 0.5) {
                        vc.hx_navLargeTitleHeadView?.alpha = 1
                    }
                    vc.hx_navLargeTitleHeadView!.snp.makeConstraints { (make) in
                        make.trailing.equalTo(-15)
                        make.bottom.equalToSuperview()
                        make.size.equalTo(LargeViewHeight)
                    }
                }else if vc.hx_navLargeTitleHeadView?.alpha == 0{
                    UIView.animate(withDuration: 0.5) {
                        vc.hx_navLargeTitleHeadView?.alpha = 1
                    }
                }
            }
        }
    }
    private func reloadHeadView(fromVC:HXBaseViewController ,toVC:HXBaseViewController) {

        if self.poppingVC == nil {//push
            UIView.animate(withDuration: 0.5) {
                fromVC.hx_navLargeTitleHeadView?.alpha = 0
            }
        }else {//pop
            if self.isPopGesture == false {
                UIView.animate(withDuration: 0.5) {
                    fromVC.hx_navLargeTitleHeadView?.alpha = 0
                }
            }
        }
        self.initHeadView(with: toVC)
    }
}

// MARK: -  UINavigationControllerDelegate
extension HXNavigationController: UINavigationControllerDelegate {
 
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let fromVc = transitionCoordinator?.viewController(forKey: .from) {
            self.saveRealNavFrame(fromVC: fromVc)
        }
        self.reloadNav(toVC: viewController)//修改
        if let coordinator = transitionCoordinator {
            showViewController(viewController, coordinator: coordinator)
        } else {
            if !animated && viewControllers.count > 1 {
                let lastButOneVC = viewControllers[viewControllers.count - 2]
                showTempFakeBar(fromVC: lastButOneVC, toVC: viewController)
                return
            }
            hx_updateNavigationBar(for: viewController)
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if !animated {
            hx_updateNavigationBar(for: viewController)
            clearTempFakeBar()
        }
        poppingVC = nil
    }
    
}

// MARK: -  UIGestureRecognizerDelegate
extension HXNavigationController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if viewControllers.count <= 1 {
            return false
        }
        if let topViewController = topViewController {
            if let topViewController:HXBaseViewController = topViewController as? HXBaseViewController {
                return topViewController.hx_navEnablePopGesture
            }
        }
        return true
    }

}

// MARK: -  Public
extension HXNavigationController {
    
    func hx_updateNavigationBar(for viewController: UIViewController) {
        setupFakeSubviews()
        hx_updateNavigationBarTint(for: viewController)
        hx_updateNavigationBarBackground(for: viewController)
        hx_updateNavigationBarLine(for: viewController)
        hx_updateNavigationShadow(for: viewController)
    }
 
    func hx_updateNavigationBarTint(for viewController: UIViewController, ignoreTintColor: Bool = false) {
        if viewController != topViewController {
            return
        }
        if let viewController:HXBaseViewController = viewController as? HXBaseViewController {
            
            
            UIView.setAnimationsEnabled(false)
            
            navigationBar.backIndicatorImage = viewController.hx_navBackImage
            navigationBar.backIndicatorTransitionMaskImage = viewController.hx_navBackImage
            
            let item0: UINavigationItem = navigationBar.items![0]
            if viewController.hx_navShowBackTitle != true {
                if item0.title?.count ?? 0 > 0 {
                    item0.prompt = item0.title
                }
                item0.title = ""
            }else{
                if item0.prompt != nil {
                    item0.title = item0.prompt
                    item0.prompt = nil
                }
            }
            if viewController.hx_navEnableLargeTitle == true {
                viewController.navigationItem.largeTitleDisplayMode = .always
            }else {
                viewController.navigationItem.largeTitleDisplayMode = .never//.never--.always
            }
           
            navigationBar.barStyle = viewController.hx_statusBarStyle
            let titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: viewController.hx_navTitleColor!,
                NSAttributedString.Key.font: viewController.hx_navTitleFont
            ]
            navigationBar.titleTextAttributes = titleTextAttributes
            if !ignoreTintColor {
                navigationBar.tintColor = viewController.hx_navTintColor
            }
            UIView.setAnimationsEnabled(true)
        }
    }
    
    func hx_updateNavigationBarBackground(for viewController: UIViewController) {
        if viewController != topViewController {
            return
        }
        if let viewController:HXBaseViewController = viewController as? HXBaseViewController {
            fakeBar.hx_updateFakeBarBackground(for: viewController)
        }
    }
    
    func hx_updateNavigationBarLine(for viewController: UIViewController) {
        if viewController != topViewController {
            return
        }
        if let viewController:HXBaseViewController = viewController as? HXBaseViewController {
            fakeBar.hx_updateFakeBarLine(for: viewController)
        }
    }

    func hx_updateNavigationShadow(for viewController: UIViewController) {
        if viewController != topViewController {
            return
        }
        if let viewController:HXBaseViewController = viewController as? HXBaseViewController {
            fakeBar.hx_updateFakeBarShadow(for: viewController)
        }
    }
}
