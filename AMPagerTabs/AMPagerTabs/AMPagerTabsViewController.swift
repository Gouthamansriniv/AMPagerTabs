//
//  AMTabViewController.swift
//  EMS
//
//  Created by abedalkareem omreyh on 10/26/17.
//  Copyright © 2017 abedalkareem omreyh. All rights reserved.
//

import UIKit

class AMPagerTabsViewController: UIViewController {

    private var tabScrollView:UIScrollView!
    private var containerScrollView:UIScrollView!
    
    var delegate:AMPagerTabsViewControllerDelegate?

    var viewControllers:[UIViewController] = [] {
        willSet{
            checkIfCanChangeValue(withErrorMessage: "You can't set the viewControllers twice")
        }
        didSet{
            addTabButtons()
            moveTo(index: firstSelectedTabIndex)
        }
    }
    
    var firstSelectedTabIndex = 0 {
        willSet{
            checkIfCanChangeValue(withErrorMessage: "You must set the first selected tab index before set the viewcontrollers")
        }
    }
    
    var tabFont:UIFont = UIFont.systemFont(ofSize: 17) {
        willSet{
            checkIfCanChangeValue(withErrorMessage: "You must set the font before set the viewcontrollers")
        }
    }
    
    var isTabButtonShouldFit = false {
        willSet{
            checkIfCanChangeValue(withErrorMessage: "You must set the isTabButtonShouldFit before set the viewcontrollers")
        }
    }

    var isPagerScrollEnabled:Bool = true{
        didSet{
            containerScrollView.isScrollEnabled = isPagerScrollEnabled
        }
    }
    
    let settings = AMSettings()
    

    
    private var tabButtons:[AMTabButton] = []
    private var line = AMLineView()
    private var lastSelectedViewIndex = 0
    

    
    // MARK: ViewController lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initScrollView()
        
        updateScrollViewsFrame()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateScrollViewsFrame()
    }
    
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let controller = self else{ return }
            controller.updateSizes()
        })
        
    }

    
    func initScrollView(){
        tabScrollView = UIScrollView(frame: CGRect.zero)
        tabScrollView.backgroundColor = settings.tabBackgroundColor
        tabScrollView.bounces = true
        tabScrollView.showsVerticalScrollIndicator = false
        tabScrollView.showsHorizontalScrollIndicator = false

        containerScrollView = UIScrollView(frame: view.frame)
        containerScrollView.backgroundColor = settings.pagerBackgroundColor
        containerScrollView.delegate = self
        containerScrollView.bounces = false
        containerScrollView.scrollsToTop = false
        containerScrollView.showsVerticalScrollIndicator = false
        containerScrollView.showsHorizontalScrollIndicator = false
        containerScrollView.isPagingEnabled = true
        containerScrollView.isScrollEnabled = isPagerScrollEnabled
        
        self.view.addSubview(containerScrollView)
        self.view.addSubview(tabScrollView)
    }
    
    func addTabButtons(){
        let viewWidth = self.view.frame.size.width
        let viewControllerCount = CGFloat(viewControllers.count)
        var width = viewWidth / viewControllerCount
        if !isTabButtonShouldFit && viewWidth < (viewControllerCount * settings.initialTabWidth) {
            width = settings.initialTabWidth
        }
        
        for i in 0..<viewControllers.count {
            let tabButton = AMTabButton(frame: CGRect(x: width*CGFloat(i), y: 0, width: width, height: settings.tabHeight))
            tabButton.setTitle(viewControllers[i].title, for: .normal)
            tabButton.backgroundColor = settings.tabButtonColor
            tabButton.setTitleColor(settings.tabButtonTitleColor, for: .normal)
            tabButton.titleLabel?.font = tabFont
            tabButton.index = i
            tabButton.addTarget(self, action: #selector(tabClicked(sender:)), for: .touchUpInside)
            tabScrollView.addSubview(tabButton)
            tabButtons.append(tabButton)
        }
        
        tabScrollView.contentSize = CGSize(width: width*viewControllerCount, height: settings.tabHeight)
        line.frame = tabButtons.first!.frame
        line.backgroundColor = UIColor.white
        tabScrollView.addSubview(line)
        
    }
    
    // MARK: Controlling tabs
    
    func moveToViewContollerAt(index:Int){
        let contoller = viewControllers[index]
        
        if contoller.view?.superview == nil {
            addChildViewController(contoller)
            contoller.view?.frame = CGRect(x:  self.view.frame.size.width*CGFloat(index), y: 0, width:  self.view.frame.size.width, height: containerScrollView.frame.size.height)
            containerScrollView.addSubview(contoller.view)
            contoller.didMove(toParentViewController: self)
        }
        
        containerScrollView.contentSize = CGSize(width: self.view.frame.size.width*CGFloat(viewControllers.count), height: containerScrollView.frame.size.height)

        delegate?.tabDidChangeAt(index)
    }
    
    
    @objc func tabClicked(sender:AMTabButton){
        moveTo(index: sender.index!)
    }
    
    func moveTo(index:Int){
        let barButton = tabButtons[index]
        animateLineTo(frame: barButton.frame)
        lastSelectedViewIndex = index
        moveToViewContollerAt(index: index)
        changeTabTo(index: index)
    }
    
    func changeTabTo(index:Int){
        containerScrollView.setContentOffset(CGPoint(x: self.view.frame.size.width*(CGFloat(index)), y: 0), animated: true)
    }
    


    // MARK: Animation

    func animateLineTo(frame:CGRect){
        UIView.animate(withDuration: 0.5) {
            self.line.frame = frame
            self.line.draw(frame)
        }
    }
    
    // MARK: Setup Sizes

    func updateScrollViewsFrame() {

        tabScrollView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: settings.tabHeight)
        containerScrollView.frame = CGRect(x: 0, y: settings.tabHeight, width: self.view.frame.size.width, height: self.view.frame.size.height - settings.tabHeight)
    }
    
    func updateSizes(){
        
        updateScrollViewsFrame()
        
        let width = self.view.frame.size.width
        let viewWidth = self.view.frame.size.width
        let viewControllerCount = CGFloat(viewControllers.count)
        var tabWidth = viewWidth / viewControllerCount
        if !isTabButtonShouldFit && viewWidth < (viewControllerCount * settings.initialTabWidth) {
            tabWidth = settings.initialTabWidth
        }
        
        for i in 0..<viewControllers.count {
            let view = viewControllers[i].view
            let tabButton = tabButtons[i]
            view?.frame = CGRect(x: width*CGFloat(i), y: 0, width: width, height: containerScrollView.frame.size.height)
            tabButton.frame = CGRect(x: tabWidth*CGFloat(i), y: 0, width: tabWidth, height: settings.tabHeight)
        }
        
        containerScrollView.contentSize = CGSize(width: width*viewControllerCount, height: containerScrollView.frame.size.height)
        tabScrollView.contentSize = CGSize(width: tabWidth*viewControllerCount, height: settings.tabHeight)
        
        changeTabTo(index: lastSelectedViewIndex)
        
        animateLineTo(frame: tabButtons[lastSelectedViewIndex].frame)
        
        
    }
    
    func checkIfCanChangeValue(withErrorMessage message:String){
        if viewControllers.count != 0 {
            assertionFailure(message)
        }
    }
    

}


// MARK: UIScrollViewDelegate
extension AMPagerTabsViewController:UIScrollViewDelegate{
    
    var currentPage: Int {
        return Int((containerScrollView.contentOffset.x + (0.5*containerScrollView.frame.size.width))/containerScrollView.frame.width)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            moveTo(index: currentPage)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        moveTo(index: currentPage)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {

    }
    
}

class AMSettings{
    var tabBackgroundColor = #colorLiteral(red: 0.2819149196, green: 0.7462226748, blue: 0.6821211576, alpha: 1)
    var tabButtonColor = #colorLiteral(red: 0.2819149196, green: 0.7462226748, blue: 0.6821211576, alpha: 1)
    var tabButtonTitleColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    var pagerBackgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    
    var initialTabWidth:CGFloat = 100
    var tabHeight:CGFloat = 60
    
}

// MARK: AMTabViewControllerDelegate

protocol AMPagerTabsViewControllerDelegate {
    func tabDidChangeAt(_ index:Int);
}

