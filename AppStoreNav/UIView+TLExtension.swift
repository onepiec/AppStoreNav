//
//  UIView+Extension.swift
//  LifeNotes
//
//  Created by XL on 2019/12/6.
//  Copyright © 2019 XL. All rights reserved.
//

import UIKit
import WebKit

extension UIView {
    
    var tlx : CGFloat {
        get{
            return self.frame.origin.x
        }
        set(newValue){
            self.frame.origin = CGPoint.init(x: newValue, y: self.frame.origin.y)
        }
    }
    var tly : CGFloat {
        get{
            return self.frame.origin.y
        }
        set(newValue){
            self.frame.origin = CGPoint.init(x: self.frame.origin.x, y: newValue)
        }
    }
    var tlwidth : CGFloat {
        get{
            return self.bounds.size.width
        }
        set(newValue){
            self.frame.size = CGSize.init(width: newValue, height: self.frame.size.height)
        }
    }
    var tlheight : CGFloat {
        get{
            return self.bounds.size.height
        }
        set(newValue){
            self.frame.size = CGSize.init(width: self.frame.size.width, height: newValue)
        }
    }
    
    func tlmaxX() -> CGFloat {
        return self.tlx + self.tlwidth
    }
    func tlmaxY() -> CGFloat {
        return self.tly + self.tlheight
    }

    var allSubViews : [UIView] {
        var array = [self.subviews].flatMap {$0}
        array.forEach { array.append(contentsOf: $0.allSubViews) }
        return array
    }
    private func dealLabLine() {
        if self.isMember(of: UILabel.self) {
            self.frame = CGRect.init(x: Int(self.tlx), y: Int(self.tly), width: Int(self.tlwidth), height: Int(self.tlheight))
        }
    }
    func normoalCornerRadius(radius: CGFloat) {
        self.dealLabLine()
        
        self.layer.cornerRadius = radius
        if self.isMember(of: UILabel.self) || self.isMember(of: UIImageView.self) {
            self.layer.masksToBounds = true
        }
    }
}


extension UIScrollView {
    private struct UIScrollViewKeys {
        static var refreshBlock     = "UIScrollViewKeys_refreshBlock"
        static var refreshCtrol     = "UIScrollViewKeys_refreshControl"
    }
    private var refreshBlock: BlockNoInNoOut? {
        get {
            return objc_getAssociatedObject(self, &UIScrollViewKeys.refreshBlock) as? BlockNoInNoOut
        }
        set {
            objc_setAssociatedObject(self, &UIScrollViewKeys.refreshBlock, newValue as Any?, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    private var refreshCtrol: UIRefreshControl? {
        get {
            return objc_getAssociatedObject(self, &UIScrollViewKeys.refreshCtrol) as? UIRefreshControl
        }
        set {
            objc_setAssociatedObject(self, &UIScrollViewKeys.refreshCtrol, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    func addRefresh(inVC:HXBaseViewController,completion:BlockNoInNoOut?) {
        
        self.refreshBlock = completion
        let refreshControl = UIRefreshControl()
        refreshControl.frame = CGRect.zero
        refreshControl.tintColor = RedColor
        refreshControl.attributedTitle = NSAttributedString.init(string: "下拉刷新", attributes: [NSAttributedString.Key.foregroundColor:RedColor])
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        if inVC.hx_navEnableLargeTitle == true {
            
            self.refreshControl = refreshControl
            self.refreshCtrol = refreshControl
        }else {
            self.addSubview(refreshControl)
            self.refreshCtrol = refreshControl
        }
    }
    @objc private func refresh() {
        DispatchQueue.main.async {
            if self.refreshBlock != nil {
                self.refreshBlock!!()
            }
        }
    }
    func beginRefresh() {

        self.refreshCtrol?.beginRefreshing()
        self.refresh()
        
    }
    func endRefresh() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.refreshCtrol?.endRefreshing()
        }
    }
}
