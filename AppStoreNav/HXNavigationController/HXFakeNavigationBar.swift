//
//  HXFakeNavigationBar.swift
//  HXNavigationController
//
//  Created by HongXiangWen on 2018/12/18.
//  Copyright © 2018年 WHX. All rights reserved.
//

import UIKit

class HXFakeNavigationBar: UIView {

    // MARK: -  lazy load
    
    private lazy var fakeBackgroundImageView: UIImageView = {
        let fakeBackgroundImageView = UIImageView()
        fakeBackgroundImageView.isUserInteractionEnabled = false
        fakeBackgroundImageView.contentScaleFactor = 1
        fakeBackgroundImageView.contentMode = .scaleToFill
        fakeBackgroundImageView.backgroundColor = .clear
        return fakeBackgroundImageView
    }()
    
    private lazy var fakeBackgroundEffectView: UIVisualEffectView = {
        let fakeBackgroundEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        fakeBackgroundEffectView.isUserInteractionEnabled = false
        return fakeBackgroundEffectView
    }()
    
    private lazy var fakeLineView: UIImageView = {
        let fakeLineView = UIImageView()
        fakeLineView.isUserInteractionEnabled = false
        fakeLineView.contentScaleFactor = 1
        return fakeLineView
    }()
    
    // MARK: -  init
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .clear
        addSubview(fakeBackgroundEffectView)
        addSubview(fakeBackgroundImageView)
        addSubview(fakeLineView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        fakeBackgroundEffectView.frame = bounds
        fakeBackgroundImageView.frame = bounds
        fakeLineView.frame = CGRect(x: 0, y: bounds.height - 0.5, width: bounds.width, height: 0.5)
    }
    
    // MARK: -  public
    
    func hx_updateFakeBarBackground(for viewController: HXBaseViewController) {
        fakeBackgroundEffectView.subviews.last?.backgroundColor = viewController.hx_navBackgroundColor
        fakeBackgroundImageView.image = viewController.hx_navBackgroundImage
        if viewController.hx_navBackgroundImage != nil {
            // 直接使用fakeBackgroundEffectView.alpha控制台会有提示
            // 这样使用避免警告
            fakeBackgroundEffectView.subviews.forEach { (subview) in
                subview.alpha = 0
            }
        } else {
            fakeBackgroundEffectView.subviews.forEach { (subview) in
                subview.alpha = viewController.hx_navBarAlpha
            }
        }
        fakeBackgroundImageView.alpha = viewController.hx_navBarAlpha
        fakeLineView.alpha = viewController.hx_navBarAlpha
    }
    
    func hx_updateFakeBarLine(for viewController: HXBaseViewController) {
        fakeLineView.isHidden = viewController.hx_navLineHidden
        fakeLineView.backgroundColor = viewController.hx_navLineColor
    }
    
    func hx_updateFakeBarShadow(for viewController: HXBaseViewController) {
        
        if viewController.hx_navShowShadow == true {
            self.layer.shadowColor = UIColor.black.cgColor
        }else{
            self.layer.shadowColor = UIColor.clear.cgColor
        }
        self.layer.shadowOffset = CGSize.init(width: 0, height: 4)
        self.layer.shadowOpacity = 0.1
    }
}
