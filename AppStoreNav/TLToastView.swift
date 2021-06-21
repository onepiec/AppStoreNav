//
//  TLToastView.swift
//  AppStoreNav
//
//  Created by 唐磊 on 2021/6/17.
//

import UIKit

class TLToastView: NSObject {

    class func showToastView(str: String) {
        
        let toastView = UIView()
        toastView.backgroundColor = BlackColor
        toastView.alpha = 0.8
        toastView.frame = CGRect.init(x: 20, y: 300, width: 100, height: 200)
        TLKeyWindow().addSubview(toastView)
        
        let toastLab = UILabel()
        toastLab.text = str
        toastLab.numberOfLines = 0
        toastLab.textAlignment = NSTextAlignment(rawValue: 1)!
        toastLab.textColor = UIColor.white
        toastLab.font = UIFont.systemFont(ofSize: 15)
        toastView.addSubview(toastLab)

        let size = toastLab.sizeThatFits(CGSize.init(width: TLDeviceWidth - 30, height: CGFloat(MAXFLOAT)))
        toastView.frame = CGRect.init(x: (TLDeviceWidth - (size.width + 30))/2.0, y: (TLDeviceHeight - (size.height + 10))/2, width: size.width + 30, height: size.height + 10)
        toastLab.frame = CGRect.init(x: 15, y: 5, width: size.width, height: size.height)
        toastView.normoalCornerRadius(radius: 6)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            UIView.animate(withDuration: 0.5, animations: {
                toastView.alpha = 0
            }) { (true) in
                toastView.removeFromSuperview()
            }
        }
    }
}
