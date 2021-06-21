//
//  PCH.swift
//  AppStoreNav
//
//  Created by 唐磊 on 2021/6/17.
//

import UIKit

//MARK: Block
typealias BlockNoInNoOut = (()->())?
typealias BlockViewInNoOut = ((UIView)->())?

//MARK: Color
func TLColor_RGB(r:CGFloat,g:CGFloat,b:CGFloat) -> UIColor{
    return TLColor_RGBA(r: r, g: g, b: b, a: 1)
}
func TLColor_RGBA(r:CGFloat,g:CGFloat,b:CGFloat,a:CGFloat) -> UIColor{
    return UIColor(red: (r)/255.0, green: (g)/255.0, blue: (b)/255.0, alpha: a)
}
let BlackColor     = TLColor_RGB(r: 25 , g: 30 , b: 60 )
let RedColor       = TLColor_RGB(r: 240, g: 80 , b: 70 )

//MARK: TLKeyWindow
func TLKeyWindow() -> UIView {
    
    if #available(iOS 13.0, *) {
        return UIApplication.shared.windows[0]
    } else {
        return ((UIApplication.shared.delegate?.window)!)!
    }
}

//MARK: CGFloat
let LargeViewHeight:CGFloat = 52
let TLDeviceWidth = UIScreen.main.bounds.size.width
let TLDeviceHeight = UIScreen.main.bounds.size.height

// presentViewController之后默认是弹框，获取弹框的宽，高(适用于iOS13，iPad)
func CurrentVC(vc:UIViewController) -> (cVCHeight:CGFloat,cNavHeight:CGFloat) {
    let cVCHeight = vc.navigationController?.view.subviews[0].frame.size.height ?? TLDeviceHeight
    var cNavHeight:CGFloat = 56.0
    if cVCHeight == TLDeviceHeight {
        cNavHeight = StatusNavHeight()
    }
    return (cVCHeight,cNavHeight)
}

func StatusHeight() -> CGFloat {
    
    if #available(iOS 13.0, *) {
        return (UIApplication.shared.windows[0].windowScene?.statusBarManager?.statusBarFrame.size.height)!
    } else {
        return UIApplication.shared.statusBarFrame.size.height
    }
}
func NavHeight() -> CGFloat {
    
    return UINavigationController().navigationBar.frame.size.height
}
func StatusNavHeight() -> CGFloat {
    
    return StatusHeight() + NavHeight()
}
func BottomSafeHeight() -> CGFloat {
    
    return UIApplication.shared.windows[0].safeAreaInsets.bottom
}
func TabBarHeight() -> CGFloat {
    
    return UITabBarController().tabBar.frame.size.height
}
func SafeTabBarHeight() -> CGFloat {
    
    return BottomSafeHeight() + TabBarHeight()
}
