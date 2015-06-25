//
//  ViewController.swift
//  TapBPM
//
//  Created by Michelle Ellis on 2015-06-24.
//  Copyright (c) 2015 Boltmade. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var averageLabel: UILabel!
    
    private var samples:[Int] = []
    private var lastTapTime:NSDate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func didTap(sender: UITapGestureRecognizer) {
        collectBPMSample(NSDate(), optionalLastSample: self.lastTapTime)
        updateAverage()
    }

    private func collectBPMSample(now : NSDate, optionalLastSample : NSDate?) {
        if let lastSample = optionalLastSample {
            let bpm = Int(60/now.timeIntervalSinceDate(lastSample))
            self.samples += [bpm]
        }
        self.lastTapTime = now
    }
    
    private func updateAverage() {
        let optionalAverage = averageBPM(self.samples)
        if let average = optionalAverage {
            self.averageLabel.text = String(average)
        } else {
            self.averageLabel.text = "First Beat"
        }
    }
    
    private func averageBPM(samples: [Int]) -> Int? {
        if (samples.count == 0) {
            return nil
        }
        
        var sum = 0
        for sample in samples {
            sum += sample
        }
        return sum/samples.count
    }
}

