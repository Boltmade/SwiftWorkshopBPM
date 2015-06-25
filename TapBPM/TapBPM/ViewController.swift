//
//  ViewController.swift
//  TapBPM
//
//  Created by Michelle Ellis on 2015-06-24.
//  Copyright (c) 2015 Boltmade. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func didTap(sender: UITapGestureRecognizer) {
        println("tapped")
    }

}

