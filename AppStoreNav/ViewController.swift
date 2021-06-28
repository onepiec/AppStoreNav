//
//  ViewController.swift
//  AppStoreNav
//
//  Created by 唐磊 on 2021/6/17.
//

import UIKit

class ViewController: HXBaseViewController {

    var isLargeTitle    = false
    var isShowSearch    = false
    var isShowSegment   = false
    var isShowHead      = false
    var isPresent       = false
    
    private var segmentViewArr  = Array<UIView>()
    private var sgControl       : UISegmentedControl!
    
    private let headView        = UIView()
    
    private var tableView       : UITableView!
    private let dataArr = ["小标题","小标题+搜索","小标题+标签","大标题","大标题+搜索","大标题+标签","大标题+头像","全屏press","弹屏press"]
    
    fileprivate var observer: NSKeyValueObservation?
    fileprivate var isOffsetYZero = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initNavView()
        self.initTableView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.isLargeTitle == false && self.isShowSearch == true {
            for subview in self.tableView.subviews {
                if let refresh:UIRefreshControl = subview as? UIRefreshControl {
                    refresh.alpha = 0
                    break
                }
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isLargeTitle == false && self.isShowSearch == true {
            self.isOffsetYZero = false
            if self.tableView.contentOffset.y == -LargeViewHeight {
                self.isOffsetYZero = true
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.isShowHead == true {
            initTitleGesture()
        }
        if self.isLargeTitle == false && self.isShowSearch == true {
            for subview in self.tableView.subviews {
                if let refresh:UIRefreshControl = subview as? UIRefreshControl {
                    refresh.alpha = 1
                    break
                }
            }
        }
    }
    
    func initNavView() {
        self.title = "TEST"
        
        if self.isLargeTitle == true {
            self.hx_navEnableLargeTitle = true
        }
        
        if self.isShowSearch == true {
            self.tl_createSearchView(proxyVC: nil, resultVC: nil, placeStr: "请输入关键词或关键字",hidesSearch: true)
        }
        
        if self.isShowSegment == true {
            let subView0 = UIScrollView.init(frame: CGRect.init(x: 0, y: 0, width: TLDeviceWidth, height: TLDeviceHeight))
            subView0.backgroundColor = UIColor.green
            subView0.contentSize = CGSize.init(width: TLDeviceWidth, height: TLDeviceHeight * 2)
            let subView1 = UIScrollView.init(frame: CGRect.init(x: 0, y: 0, width: TLDeviceWidth, height: TLDeviceHeight))
            subView1.backgroundColor = UIColor.yellow
            subView1.contentSize = CGSize.init(width: TLDeviceWidth, height: TLDeviceHeight * 2)
            segmentViewArr.append(subView0)
            segmentViewArr.append(subView1)
            if self.isLargeTitle == false {
                subView0.tly = CurrentVC(vc: self).cNavHeight + LargeViewHeight
                subView1.tly = CurrentVC(vc: self).cNavHeight + LargeViewHeight
            }
            
            self.tl_createSegmentedControl(proxyVC: self, items: ["哈哈","嘿嘿"],width: TLDeviceWidth/2 - 15) { [weak self] (sgController) in
                self?.sgControl = (sgController as! UISegmentedControl)
            }
            self.reloadContentViewArr(item:0)
        }
        
        if self.isShowHead == true {
            self.hx_navLargeTitleTagView = UIImageView.init(image: UIImage.init(named: "imgConfirm"))
            
            self.headView.frame = CGRect.init(x: 0, y: 0, width: LargeViewHeight, height: LargeViewHeight)
            self.headView.backgroundColor = RedColor
            self.headView.normoalCornerRadius(radius: LargeViewHeight/2)
            self.hx_navLargeTitleHeadView = self.headView
            
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(navClick))
            self.headView.isUserInteractionEnabled = true
            self.headView.addGestureRecognizer(tap)
        }
        
        if self.isPresent == true {
            self.initPresentBack()
        }
    }
    
    func initTableView() {
        
        var rect = CGRect.init(x: 0, y: CurrentVC(vc: self).cNavHeight, width: TLDeviceWidth, height: CurrentVC(vc: self).cVCHeight - CurrentVC(vc: self).cNavHeight)
        if self.isLargeTitle == true {
            rect = CGRect.init(x: 0, y: 0, width: TLDeviceWidth, height: CurrentVC(vc: self).cVCHeight)
        }

        self.tableView = UITableView.init(frame: rect, style: .plain)
        self.tableView.estimatedRowHeight = 0
        self.tableView.estimatedSectionHeaderHeight = 0
        self.tableView.estimatedSectionFooterHeight = 0
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor.clear
        self.view.addSubview(self.tableView)
        self.tableView.tableFooterView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: TLDeviceWidth, height: 200))
        
        if self.isShowSegment == true {
            self.tableView.removeFromSuperview()
        }
        self.tableView.addRefresh(inVC: self) {[weak self] in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                self?.tableView.endRefresh()
                TLToastView.showToastView(str: "刷新结束")
            }
        }
        
        if self.isLargeTitle == false && self.isShowSearch == true {
            observer = self.tableView.observe(\.contentOffset, options: [.new,.old], changeHandler: { [weak self] (obj, change) in
                guard let `self` = self else { return }
                guard let newPoint = change.newValue else { return }
                if self.appearState < 2 && self.isOffsetYZero == true && newPoint.y != -LargeViewHeight {
                    self.tableView.contentOffset = CGPoint.init(x: 0, y: -LargeViewHeight)
                }
                
            })
        }
    }
}

//MARK: Present
extension ViewController {
    private func initPresentBack() {
        
        let backBtn = UIButton.init(type: .custom)
        backBtn.frame = CGRect.init(x: 0, y: 0, width: 20, height: 20)
        backBtn.setImage(UIImage.init(named: "imgBack"), for: .normal)
        backBtn.addTarget(self, action: #selector(navBackClick), for: .touchUpInside)
        self.tl_createLeftViews(viewArr: [backBtn])

    }
    @objc private func navBackClick() {
        self.dismiss(animated: true, completion: nil)
    }
}
//MARK: Head
extension ViewController {
    private func initTitleGesture() {
        for subView in self.hx_navLargeTitleHeadView!.superview?.subviews ?? [] {
            if let lab:UILabel = subView as? UILabel {
                if lab.gestureRecognizers?.count ?? 0 == 0 {
                    let tap = UITapGestureRecognizer.init(target: self, action: #selector(navClick))
                    lab.isUserInteractionEnabled = true
                    lab.addGestureRecognizer(tap)
                }
                break
            }
        }
    }
    @objc private func navClick() {
        TLToastView.showToastView(str: "头像或标题")
    }
}
//MARK: Segment
extension ViewController:UISearchBarDelegate {
    override func sgControlClick(sgControl:UISegmentedControl) {
        super.sgControlClick(sgControl: sgControl)
        self.reloadContentViewArr(item: sgControl.selectedSegmentIndex)
    }
    func reloadContentViewArr(item:Int) {
        
        for (index,subView) in self.segmentViewArr.enumerated() {
            if index == item {
                self.view.insertSubview(subView, at: 0)
            }else {
                subView.removeFromSuperview()
            }
        }
    }
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if self.isShowSegment == true {
            return false
        }
        return true
    }
}
//MARK: TableView
extension ViewController:UITableViewDelegate,UITableViewDataSource {
    private func scrollViewDidEndScroll(_ scrollView: UIScrollView) {
        
        if self.isLargeTitle == true {
            self.tableView.contentOffset = CGPoint.init(x: 0, y: floor(self.tableView.contentOffset.y))
        }
        
        if self.isLargeTitle == false && self.isShowSearch == true{
            if scrollView.contentOffset.y < 0 && scrollView.contentOffset.y > -LargeViewHeight {
                
                var newY:CGFloat = 0
                if scrollView.contentOffset.y < -LargeViewHeight/2 {
                    newY = -LargeViewHeight
                }
                scrollView.setContentOffset(CGPoint.init(x: 0, y: newY), animated: true)
            }
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollViewDidEndScroll(scrollView)
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.scrollViewDidEndScroll(scrollView)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "UITableViewCell")
        }
        cell?.textLabel?.text = dataArr[indexPath.row]
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let vc = ViewController()
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else if indexPath.row == 1 {
            let vc = ViewController()
            vc.isShowSearch = true
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else if indexPath.row == 2 {
            let vc = ViewController()
            vc.isShowSegment = true
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else if indexPath.row == 3 {
            let vc = ViewController()
            vc.isLargeTitle = true
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else if indexPath.row == 4 {
            let vc = ViewController()
            vc.isLargeTitle = true
            vc.isShowSearch = true
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else if indexPath.row == 5 {
            let vc = ViewController()
            vc.isLargeTitle = true
            vc.isShowSegment = true
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else if indexPath.row == 6 {
            let vc = ViewController()
            vc.isLargeTitle = true
            vc.isShowHead = true
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else if indexPath.row == 7 {
            let vc = ViewController()
            vc.isPresent = true
            let nav = HXNavigationController.init(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.navigationController?.present(nav, animated: true, completion: nil)
            
        }else if indexPath.row == 8 {
            let vc = ViewController()
            vc.isPresent = true
            let nav = HXNavigationController.init(rootViewController: vc)
            self.navigationController?.present(nav, animated: true, completion: nil)
        }
    }
    
}
