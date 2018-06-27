//
//  SlideViewController.swift
//  Taxi
//
//  Created by Tran Ngoc Nam on 6/25/18.
//  Copyright © 2018 Tran Ngoc Nam. All rights reserved.
//

import UIKit

class SlideViewController: UIViewController {

    @IBOutlet weak var sideMenuConstraint: NSLayoutConstraint!
    
    var isSlideMenuHidden = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sideMenuConstraint.constant = -200
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func searchButtton(_ sender: UIBarButtonItem) {
        
        if isSlideMenuHidden {
            sideMenuConstraint.constant = 0
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        } else {
            sideMenuConstraint.constant = -200
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
        
        isSlideMenuHidden = !isSlideMenuHidden
    }
}
