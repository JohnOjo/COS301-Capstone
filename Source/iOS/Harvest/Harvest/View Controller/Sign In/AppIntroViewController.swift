//
//  AppIntroViewController.swift
//  Harvest
//
//  Created by Letanyan Arumugam on 2018/08/05.
//  Copyright © 2018 Letanyan Arumugam. All rights reserved.
//

import UIKit
import FSPagerView

class AppIntroViewController: UIViewController, FSPagerViewDataSource, FSPagerViewDelegate {
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  var images: [UIImage] = [#imageLiteral(resourceName: "HarvestIntro"), #imageLiteral(resourceName: "HarvestManage"), #imageLiteral(resourceName: "HarvestTrack"), #imageLiteral(resourceName: "HarvestAnalyse")]
  var currentIndex = 0 {
    didSet {
      if currentIndex == 3 {
        nextButton.setTitle("Done", for: .normal)
        skipButton.isHidden = true
      } else {
        nextButton.setTitle("Next⇢", for: .normal)
        skipButton.isHidden = false
      }
    }
  }
  @IBOutlet weak var pagerView: FSPagerView! {
    didSet {
      self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
    }
  }
  @IBOutlet weak var pageControler: FSPageControl! {
    didSet {
      pageControler.numberOfPages = 4
    }
  }
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var skipButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    pagerView.transformer = FSPagerViewTransformer(type: .linear)
    pageControler.contentHorizontalAlignment = .center
  }
  
  func numberOfItems(in pagerView: FSPagerView) -> Int {
    return 4
  }
  
  func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
    let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
    
    cell.imageView?.image = images[index]
    cell.imageView?.contentMode = .scaleAspectFit
    cell.imageView?.layer.shadowRadius = 0
    cell.contentView.layer.shadowRadius = 0
    
    return cell
  }
  
  func pagerView(_ pagerView: FSPagerView, shouldSelectItemAt index: Int) -> Bool {
    return false
  }
  
  func pagerView(_ pagerView: FSPagerView, shouldHighlightItemAt index: Int) -> Bool {
    return false
  }
  
  func pagerViewDidScroll(_ pagerView: FSPagerView) {
    guard pageControler.currentPage != pagerView.currentIndex else {
      return
    }
    pageControler.currentPage = pagerView.currentIndex
    currentIndex = pagerView.currentIndex
  }
  
  @IBAction func nextButtonTouchUp(_ sender: UIButton) {
    if currentIndex == 3 {
      completeIntro()
    } else {
      currentIndex = min(currentIndex + 1, 3)
      pagerView.scrollToItem(at: currentIndex, animated: true)
    }
  }
  
  @IBAction func skipButtonTouchUp(_ sender: UIButton) {
    completeIntro()
  }
  
  func completeIntro() {
    UserDefaults.standard.set(true, forKey: "Launched")
    StatStore.shared.setUpPredefinedGraphs()
    dismiss(animated: true, completion: nil)
  }
}
