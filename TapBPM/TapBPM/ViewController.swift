//
//  ViewController.swift
//  TapBPM
//
//  Created by Michelle Ellis on 2015-06-24.
//  Copyright (c) 2015 Boltmade. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var samples:[Int] = []
    private var lastTapTime:NSDate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func didTap(sender: UITapGestureRecognizer) {
        collectBPMSample(NSDate(), optionalLastSample: self.lastTapTime)
    }

    private func collectBPMSample(now : NSDate, optionalLastSample : NSDate?) {
        if let lastSample = optionalLastSample {
            let bpm = Int(60/now.timeIntervalSinceDate(lastSample))
            self.samples += [bpm]
            println(bpm)
        }
        self.lastTapTime = now
    }
}

